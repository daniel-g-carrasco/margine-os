# Programma root-on-ZFS per Margine

Stato: proposta di architettura, non implementazione.

Questo documento riparte da zero dal punto di vista storage: non assume che
l'attuale layout Btrfs debba essere copiato su ZFS. L'obiettivo e' progettare un
sistema Margine con root su ZFS che resti adatto a un laptop
consumer-professionale: piu' robusto e verificabile di Btrfs, ma senza tuning da
server, senza consumo eccessivo di RAM/CPU, e senza rendere fragile la catena di
boot.

## Decisione iniziale

La migrazione root-on-ZFS deve essere un nuovo track di installazione, non una
conversione in-place dell'installazione attuale.

Motivo:
- il boot cambia davvero;
- gli snapshot non hanno la stessa semantica dei subvolumi Btrfs;
- il rollback deve essere bootabile, non solo "ripristinabile";
- su Arch/CachyOS il rischio principale e' l'accoppiamento kernel/ZFS module;
- Secure Boot, UKI, TPM2 e recovery devono essere validati insieme, non dopo.

La scelta raccomandata per il primo prototipo e':

```text
ESP /boot
  -> Limine primary
  -> systemd-boot fallback
  -> signed UKIs

LUKS2 system container
  -> ZFS pool rpool
     -> root dataset and desktop datasets
```

ZFS native encryption e ZFSBootMenu vanno studiati, ma non devono essere il primo
salto. Il motivo e' pragmatico: Margine ha gia' una catena LUKS2 + TPM2 + UKI +
Secure Boot che funziona. Cambiare contemporaneamente encryption model,
bootloader model e filesystem root aumenta troppo il raggio del guasto.

## Vincoli non negoziabili

- Il sistema deve poter avviare con Secure Boot abilitato.
- Lo sblocco TPM2 deve restare possibile almeno nel profilo LUKS2.
- Deve esistere una voce di boot fallback indipendente dal bootloader primario.
- Ogni aggiornamento kernel/ZFS deve essere verificato prima di diventare stato
  di boot normale.
- `update-all` deve creare uno snapshot pre-update coerente prima di pacman.
- Il rollback deve avere una procedura esplicita e testata in VM.
- Il sistema non deve dipendere da dedup, L2ARC, SLOG o tuning server-style.
- L'ARC deve essere osservabile e, se necessario, limitabile da profilo Margine.
- Il layout deve degradare bene su laptop singolo disco.
- I dataset devono essere pochi e motivati: troppi dataset rendono rollback e
  policy snapshot difficili da capire.

## Modelli possibili

### A. LUKS2 -> ZFS root con boot Margine attuale

Schema:

```text
/dev/nvme0n1p1  ESP FAT32  /boot
/dev/nvme0n1p2  LUKS2      cryptsystem
/dev/mapper/cryptsystem -> ZFS rpool
```

Vantaggi:
- preserva il modello TPM2 attuale;
- preserva UKI, Limine, systemd-boot fallback e firma Secure Boot;
- riduce il numero di variabili rispetto a ZFS native encryption;
- e' il modo piu' diretto per validare root-on-ZFS nel sistema esistente.

Svantaggi:
- gli snapshot ZFS non sbloccano da soli la complessita' dei boot environment;
- il rollback bootabile richiede entry/clone/bootfs progettati bene;
- initramfs deve aprire LUKS e importare il pool in modo affidabile.

Valutazione: scelta raccomandata per il primo prototipo.

### B. ZFS native encryption + ZFSBootMenu

Schema:

```text
ESP
ZFS pool con encryption nativa
ZFSBootMenu gestisce boot environments
```

Vantaggi:
- boot environments piu' naturali;
- rollback e selezione snapshot piu' vicini al modello ZFS;
- ZFSBootMenu e' pensato esattamente per root-on-ZFS.

Svantaggi:
- cambia il modello di sblocco;
- TPM2 e Secure Boot richiedono un disegno separato;
- si sovrappone alla strategia UKI/Limine gia' esistente;
- introduce troppa complessita' nel primo passaggio.

Valutazione: track sperimentale successivo, non baseline iniziale.

### C. Hybrid di transizione

Schema:

```text
Prima fase: LUKS2 -> ZFS root + Limine/UKI
Seconda fase: prototipo separato ZFSBootMenu
Terza fase: scelta definitiva solo dopo test comparativi
```

Valutazione: questo e' il programma piu' sicuro.

## Layout disco raccomandato

Baseline laptop singolo disco:

```text
Disk
|- p1 ESP FAT32, 2-4 GiB, mounted at /boot, umask=0077
`- p2 LUKS2 system container
   `- rpool ZFS
```

Note:
- `/boot` resta fuori da ZFS per mantenere semplice la catena UKI/Secure Boot.
- La ESP deve essere trattata come materiale sensibile: `umask=0077`.
- Non serve una partizione swap classica come default; Margine puo' continuare a
  usare zram.
- Un eventuale swap persistente deve essere una decisione separata, perche'
  swap su ZFS richiede vincoli propri e puo' complicare il recovery.

## Pool ZFS

Nome consigliato: `rpool`.

Proprieta' iniziali:

```text
ashift=12
autotrim=on
compression=lz4
acltype=posixacl
xattr=sa
atime=off
mountpoint=none
canmount=off
```

Scelte intenzionali:
- `compression=lz4` e' il default prudente per root: quasi sempre utile, basso
  costo CPU, minore rischio rispetto a zstd come baseline.
- `zstd` puo' diventare un profilo opzionale dopo benchmark su hardware reale.
- `dedup=off` deve restare non negoziabile.
- `autotrim=on` e' sensato su SSD/NVMe consumer; va verificato con i modelli
  reali ma non richiede un timer fstrim separato come default.
- `atime=off` riduce scritture non utili sul laptop desktop.

Da non fare nel baseline:
- non abilitare dedup;
- non creare L2ARC;
- non creare SLOG;
- non forzare `recordsize` globalmente;
- non abilitare feature flags senza una matrice di boot compatibility.

## Dataset layout

Il layout deve essere ZFS-native, non una traduzione dei subvolumi Btrfs.

Proposta iniziale:

```text
rpool
`- ROOT
   `- default              mountpoint=/, canmount=noauto
`- home                    mountpoint=/home
`- root                    mountpoint=/root
`- var
   `- log                  mountpoint=/var/log
   `- cache                mountpoint=/var/cache
   `- tmp                  mountpoint=/var/tmp
`- data                    mountpoint=/data
`- srv                     mountpoint=/srv
`- containers              mountpoint=/var/lib/containers
`- machines                mountpoint=/var/lib/machines
`- vm                      mountpoint=/var/lib/libvirt
```

Dataset da non separare nella prima baseline:

```text
/usr
/etc
/opt
/var/lib/pacman
/var/lib/systemd
```

Motivo: questi percorsi devono restare coerenti con il root dataset durante un
rollback di sistema. Separarli rende piu' probabile un sistema formalmente
avviabile ma incoerente.

Dataset con policy speciale:

```text
/home
/data
/games
/srv
/var/log
/var/cache
/var/lib/containers
/var/lib/machines
/var/lib/libvirt
```

Motivo: questi dati hanno ritmi, dimensioni e valore di rollback diversi.

## Recordsize e proprieta' per dataset

Baseline:

```text
rpool/ROOT/default        recordsize=128K
rpool/home                recordsize=128K
rpool/data                recordsize=128K
rpool/games               recordsize=128K, no autosnapshot by default
rpool/srv                 recordsize=128K
rpool/var/log             recordsize=128K
rpool/var/cache           recordsize=128K
rpool/containers          recordsize=128K
rpool/machines            recordsize=128K
rpool/vm                  recordsize=64K, da validare
```

Regola:
- non ottimizzare prima di misurare;
- non impostare recordsize piccoli globalmente;
- non snapshotare automaticamente librerie di giochi reinstallabili;
- per VM e immagini disco valutare dataset dedicato o zvol solo dopo benchmark;
- per archivi grandi si puo' introdurre un dataset `rpool/archive` con
  `recordsize=1M`, ma non serve nel primo root-on-ZFS.

## Boot chain

Primo prototipo:

```text
Firmware UEFI
-> Limine signed
-> signed UKI
-> systemd-stub
-> initramfs
-> unlock LUKS2
-> import rpool
-> mount rpool/ROOT/default as /
```

Fallback:

```text
Firmware UEFI
-> systemd-boot signed
-> signed fallback UKI
-> same root import path
```

Check bloccanti:
- `hostid` persistente e incluso dove necessario;
- `zpool.cache` o import path gestito in modo deterministico;
- initramfs contiene moduli ZFS compatibili con il kernel corrente;
- UKI primary/fallback/recovery generati e firmati;
- Limine config enrolled dopo la generazione e prima della firma;
- systemd-boot fallback resta installato e selezionabile da UEFI;
- Secure Boot `sbctl verify` passa;
- TPM2 unlock funziona solo dopo boot chain stabile, non prima.

## Initramfs

Domanda aperta: `mkinitcpio` o `dracut`.

Regola per il primo prototipo:
- partire dal tool gia' usato da Margine, quindi `mkinitcpio`, se il path ZFS
  root risulta affidabile;
- aprire un branch sperimentale `dracut` solo se `mkinitcpio` rende fragile la
  gestione ZFS root;
- non cambiare initramfs tool e bootloader nello stesso prototipo.

Check necessari:

```text
lsinitcpio /boot/EFI/Linux/margine-linux.efi
modinfo zfs
uname -r
pacman -Q linux-cachyos-zfs zfs-utils
zpool status
zfs get bootfs rpool
```

## Snapshot model

Con root-on-ZFS, Snapper non deve piu' essere il modello primario.

Policy proposta:

```text
Root system snapshots:
  manual/pre-update only, named and retained conservatively

Home/data snapshots:
  periodic via sanoid, with retention per dataset

Large mutable workloads:
  explicit policy, usually fewer snapshots
```

Snapshot pre-update:

```text
rpool/ROOT/default@margine-pre-update-YYYYMMDD-HHMMSS
rpool/home@margine-pre-update-YYYYMMDD-HHMMSS
rpool/data@margine-pre-update-YYYYMMDD-HHMMSS
```

Il root snapshot deve essere atomicamente associato all'update. Non basta avere
snapshot periodici.

## Boot environments e rollback

Il rollback non deve essere un comando magico che distrugge lo stato corrente.

Modello consigliato:

1. Creare snapshot pre-update.
2. In caso di problema, creare un clone bootabile dello snapshot.
3. Aggiungere una entry Limine temporanea per il clone.
4. Avviare il clone e validare.
5. Solo dopo validazione, promuovere o impostare il nuovo dataset di root.

Esempio concettuale:

```text
rpool/ROOT/default
rpool/ROOT/rollback-20260425
```

Check:
- il clone deve montare `/` come root;
- `/home` puo' restare quello corrente o usare snapshot dedicato secondo policy;
- pacman database e root devono essere coerenti;
- la entry recovery deve essere rimovibile in modo sicuro.

## update-all su root-on-ZFS

`update-all` deve essere storage-aware.

Stato operativo attuale: il primo percorso dedicato e' implementato in forma
conservativa. Su root-on-ZFS, `update-all` non usa piu' il percorso
Btrfs/Snapper. La sequenza accettata e':

1. validare la root ZFS installata con `validate-root-zfs-target --target-root / --mode boot-chain`;
2. verificare pool sano e capacita' sotto soglia;
3. creare uno snapshot obbligatorio del root dataset con
   `create-zfs-pre-update-snapshots --strict --dataset rpool/ROOT/default`;
4. creare un clone bootabile dello snapshot sotto `rpool/ROOT/...`;
5. rigenerare subito la boot chain con la voce rollback, prima di toccare i
   pacchetti;
6. eseguire pacman/AUR/Flatpak/fwupd;
7. rigenerare di nuovo la boot chain con `provision-initial-boot-chain-zfs`, includendo
   le voci Limine per i cloni marcati come rollback;
8. aggiornare la trust chain EFI se `sbctl` e' inizializzato;
9. rieseguire il validator root-on-ZFS.

Limite deliberato: questa fase rende selezionabile da Limine il clone
pre-update, ma non promuove automaticamente il clone dopo il boot. Promozione,
abbandono e pruning dei boot environment devono restare procedure esplicite e
validate.

Per update reali root-on-ZFS, `--no-boot` e `--no-pre-update-snap` non sono
opzioni accettate: toglierebbero proprio i due controlli che impediscono di
ricadere nel guasto `/sysroot`.

## Live ISO, mount propagation e detach ZFS

Il target root-on-ZFS non va montato in una `/mnt` che propaga mount event al
resto della live ISO. Su CachyOS desktop, servizi come `NetworkManager`,
`systemd-resolved`, `polkit` o `dbus` possono vivere in mount namespace separati
ma ereditare il mount ZFS del target. In quel caso non stanno necessariamente
scrivendo nel target: possono semplicemente tenere vivo un namespace che
contiene ancora `rpool/ROOT/default`.

La regola operativa diventa:

1. prima di importare il pool, rendere privata la mount namespace corrente;
2. montare ZFS solo tramite l'helper;
3. verificare che il source esatto di `/mnt` sia `rpool/ROOT/default`, non
   `airootfs`/`overlay`;
4. in detach, tentare prima cleanup visibile e namespace cleanup;
5. usare lazy unmount solo come ultima recovery da live ISO, perche' puo'
   nascondere `/mnt` dalle diagnostiche mentre `zpool export` resta busy.

Preflight obbligatorio:

```text
zpool status -x
zfs list rpool/ROOT/default
modinfo zfs
uname -r
pacman -Q zfs-utils
check kernel package and zfs module package compatibility
check /boot mount permissions
check free space and pool capacity
```

Sequenza:

1. Verifica pool sano.
2. Verifica spazio libero sufficiente.
3. Verifica kernel/ZFS module installabili insieme.
4. Crea snapshot pre-update root; dataset aggiuntivi solo se esplicitamente
   configurati, mantenendo `/games` fuori dalla policy generica.
5. Esegue pacman/AUR/local overrides.
6. Rigenera initramfs/UKI.
7. Firma EFI/UKI.
8. Verifica Limine, systemd-boot fallback e Secure Boot database.
9. Esegue un check post-update ZFS.
10. Scrive o mostra un report con snapshot creato e boot artifacts.

No-go:
- se ZFS module per il nuovo kernel non e' disponibile, non aggiornare il
  kernel;
- se `/boot` non e' montato correttamente, non rigenerare UKI;
- se `zpool status -x` non e' clean, non procedere automaticamente;
- se lo snapshot pre-update fallisce, non procedere.

## Sanoid policy

Sanoid resta sensato, ma non deve sostituire i pre-update snapshot.

Esempio:

```text
[rpool/home]
  frequently = 0
  hourly = 24
  daily = 14
  monthly = 3
  autosnap = yes
  autoprune = yes

[rpool/data]
  hourly = 24
  daily = 14
  monthly = 6

[rpool/ROOT/default]
  autosnap = no
  autoprune = no
```

Root:
- snapshot solo pre-update, pre-risk e manuali;
- niente hourly automatici sul root come default.

Home/data:
- snapshot periodici utili.

VM/container:
- policy conservativa, perche' snapshot frequenti su immagini grandi possono
  crescere rapidamente.

## Tuning laptop

Obiettivo: ZFS deve migliorare integrita', snapshot e rollback senza trasformare
il laptop in un server.

Baseline:

```text
dedup=off
compression=lz4
atime=off
autotrim=on
xattr=sa
acltype=posixacl
```

ARC:

Non impostare un cap aggressivo alla cieca. Prima misurare. Poi offrire profili.

Profili possibili:

```text
16 GiB RAM: zfs_arc_max=4G
32 GiB RAM: zfs_arc_max=8G
64 GiB RAM: zfs_arc_max=16G
```

Questi valori non sono tuning universale. Sono limiti pragmatici per evitare che
su laptop desktop l'ARC competa troppo con browser, IDE, VM e giochi.

Strumenti:

```text
arcstat
arc_summary
zpool iostat -v 1
zfs get all
```

Da evitare:
- ridurre ARC cosi' tanto da rendere ZFS lento;
- cambiare `zfs_txg_timeout` senza benchmark;
- usare zstd alto su root;
- recordsize piccoli globali;
- snapshot infiniti.

## Security model

Baseline iniziale:

```text
LUKS2 encryption
TPM2 unlock gated by Secure Boot policy
signed UKIs
signed Limine/systemd-boot
ESP hardened
```

ZFS native encryption resta fuori dal primo prototipo.

Motivo:
- LUKS2 protegge l'intero pool;
- il modello TPM2 e' gia' noto;
- evita doppia gestione passphrase/keylocation;
- riduce i casi di recovery.

Check:
- boot con Secure Boot off deve chiedere passphrase se la policy TPM2 lo
  richiede;
- boot con Secure Boot on deve sbloccare via TPM2 se enrolled;
- recovery deve poter sbloccare manualmente;
- le chiavi non devono finire nella ESP.

## Failure modes da simulare

Prima del bare metal, la VM deve coprire:

```text
poweroff forzato durante update
kernel update con ZFS module disponibile
kernel update con ZFS module mancante
UKI non firmato
Limine config non enrolled
pool non importabile automaticamente
hostid mancante
zpool.cache mancante o stale
snapshot pre-update fallito
rollback clone bootabile
rollback abbandonato
/boot non montato
/boot permessi errati
pool oltre 80% e 90%
sanoid timer su dataset mancanti
```

## Validazione VM

Track minimo:

1. `margine-public` Arch root-on-ZFS.
2. `margine-cachyos` personal root-on-ZFS.
3. `margine-cachyos` personal root-on-ZFS + gaming + ZFS data workloads.

Per ogni track:

```text
installazione da zero
primo boot
secondo boot
Secure Boot off
Secure Boot on
TPM2 unlock
update-all
reboot dopo update
snapshot pre-update
rollback boot environment
systemd failed units
sbctl verify
bootctl status
zpool status
zfs list -t snapshot
```

La validazione bare metal non parte finche' questi test non passano.

## Implementazione a fasi

### Fase 0 - ADR

Creare un ADR dedicato:

```text
docs/adr/0041-root-on-zfs-storage-and-boot-model.md
```

Contenuto:
- scelta LUKS2 -> ZFS root per il primo prototipo;
- motivazione del rinvio ZFSBootMenu;
- layout dataset;
- policy snapshot;
- preflight update-all;
- no-go criteria.

### Fase 1 - Harness VM

Creare un nuovo harness:

```text
scripts/prepare-qemu-root-zfs-validation
```

Deve generare:
- disco installazione;
- ESP;
- LUKS2;
- ZFS root pool;
- checklist live ISO;
- checklist installed system;
- script di recovery.

### Fase 2 - Storage provisioner

Nuovo script, senza sostituire quello attuale:

```text
scripts/provision-storage-zfs-root
```

Responsabilita':
- partizionare;
- creare LUKS2;
- creare `rpool`;
- creare dataset;
- impostare proprieta';
- montare target;
- generare fstab solo per ESP e pseudo-filesystem necessari.

### Fase 3 - Boot provisioner ZFS

Estendere o affiancare:

```text
scripts/provision-boot-baseline
scripts/generate-limine-config
```

Responsabilita':
- root argument ZFS;
- initramfs con ZFS;
- UKI ZFS root;
- fallback UKI;
- recovery UKI;
- Limine entries per root e rollback candidate;
- systemd-boot fallback.

### Fase 4 - update-all ZFS mode

`update-all` deve rilevare:

```text
root filesystem = zfs
root dataset = rpool/ROOT/default
pool health
ZFS module/kernel compatibility
```

Poi applicare la sequenza storage-aware descritta sopra.

Fase 4a implementata: `update-all` crea lo snapshot root, pubblica una entry
rollback prima degli aggiornamenti, aggiorna, rigenera UKI/Limine ZFS e valida
il risultato. Fase 4b implementata in forma conservativa: lo snapshot root
viene clonato in un boot environment `rpool/ROOT/margine-pre-update-*` e Limine
riceve una voce `/Rollback` che usa la recovery UKI con `root=ZFS=<clone>`.
Restano da implementare promozione, abbandono e retention dei cloni.

### Fase 5 - Recovery tools

Comandi dedicati:

```text
margine-zfs-snapshot-pre-update
margine-zfs-create-rollback-bootenv
margine-zfs-list-bootenv
margine-zfs-abandon-rollback
margine-zfs-promote-rollback
```

Questi comandi devono essere noiosi, espliciti e difficili da usare male.

### Fase 6 - Bare metal candidate

Solo dopo:
- VM public passata;
- VM personal passata;
- gaming stack passato;
- kernel update passato;
- rollback bootabile passato;
- Secure Boot/TPM2 passato.

## Checklist di accettazione

Root-on-ZFS e' accettabile per Margine solo se:

```text
boot normale passa
boot fallback passa
recovery passa
Secure Boot passa
TPM2 unlock passa
update-all passa
rollback bootabile passa
ZFS module mismatch viene bloccato prima di rompere il boot
ARC e' osservabile e controllabile
snapshot policy non cresce senza limiti
pool health viene controllato prima degli update
documentazione utente esiste
```

## Prossimo passo concreto

Il prossimo passo non e' modificare l'installer attuale. E':

1. creare ADR 0041 con la decisione `LUKS2 -> ZFS root`;
2. creare harness VM root-on-ZFS separato;
3. implementare solo il provisioning storage in VM;
4. validare boot senza Secure Boot;
5. aggiungere Secure Boot;
6. aggiungere TPM2;
7. integrare `update-all`;
8. solo dopo valutare installazione reale.

## Fonti tecniche da mantenere come riferimento

- OpenZFS Arch Linux root-on-ZFS:
  https://openzfs.github.io/openzfs-docs/Getting%20Started/Arch%20Linux/Root%20on%20ZFS.html
- OpenZFS module parameters:
  https://openzfs.github.io/openzfs-docs/Performance%20and%20Tuning/Module%20Parameters.html
- OpenZFS workload tuning:
  https://openzfs.github.io/openzfs-docs/Performance%20and%20Tuning/Workload%20Tuning.html
- OpenZFS zpool properties:
  https://openzfs.github.io/openzfs-docs/man/master/7/zpoolprops.7.html
- OpenZFS zfs dataset properties:
  https://openzfs.github.io/openzfs-docs/man/master/7/zfsprops.7.html
- CachyOS filesystem guidance:
  https://wiki.cachyos.org/installation/filesystem/
- CachyOS kernel and prebuilt modules:
  https://wiki.cachyos.org/features/kernel/
- ZFSBootMenu documentation:
  https://docs.zfsbootmenu.org/
- Sanoid upstream:
  https://github.com/jimsalterjrs/sanoid
