# Perché la migrazione a ZFS va separata tra data layer e root-on-ZFS

## Cosa stiamo cercando di fare

`Margine` oggi ha una baseline molto chiara:

- `ESP` su `/boot`
- `LUKS2` per il disco di root
- `Btrfs` con subvolumi
- `Snapper` per snapshot e rollback
- `Limine + UKI` per il boot
- `Secure Boot + sbctl`
- `TPM2` per l'auto-unlock del root `LUKS`

Passare a `ZFS` non significa solo cambiare filesystem. Significa toccare
insieme:

- provisioning storage
- boot chain
- modello di snapshot
- recovery
- update path
- rapporto tra cifratura, initramfs e bootloader

Per questo la prima decisione corretta non e` "come creare il pool", ma
"qual e` il perimetro della migrazione".

## La conclusione architetturale piu` importante

Per `Margine`, queste due cose NON sono lo stesso progetto:

1. usare `ZFS` come layer dati opzionale
2. portare il root filesystem di `Margine` su `ZFS`

Devono essere trattate come due fasi diverse.

La ragione e` semplice:

- `ZFS` come dataset dati puo` convivere con l'attuale boot chain
- `root-on-ZFS` mette invece in discussione la forma stessa del boot, del
  rollback e del recovery model

Quindi la raccomandazione iniziale e`:

- **fase 1:** validare `ZFS` come data layer e come modello snapshot
- **fase 2:** solo dopo decidere se esiste un vero `Margine root-on-ZFS`

## Cosa dicono davvero le fonti ufficiali

### 1. Root-on-ZFS su Linux non e` "solo filesystem"

La documentazione amministrativa di OpenZFS e` netta: quando il root e` su
`ZFS`, il pool deve essere importato prima che il kernel possa montare la
root, e su Linux questo richiede initramfs e stato di import esplicito
(`zpool.cache`, `hostid`).

Questa non e` una sfumatura. E` una differenza strutturale dal modello
`LUKS2 -> Btrfs -> subvolume`.

### 2. La guida Arch ufficiale OpenZFS esiste, ma non coincide con Margine

La guida ufficiale `Arch Linux Root on ZFS` mostra un layout e un flow propri:

- `modprobe zfs` gia` in installazione
- `zpool create` come passo centrale
- dataset `mountpoint=legacy` o `mountpoint=/`
- snapshot iniziale `zfs snapshot -r rpool@initial-installation`

In piu` apre con due warning importanti:

- se vuoi `ZFSBootMenu`, **non** seguire quella pagina perche' i layout non
  sono compatibili
- usare solo feature set ben collaudati

Questo ci dice subito una cosa utile: il progetto `root-on-ZFS` non puo`
essere affrontato come semplice sostituzione del `mkfs.btrfs` nel nostro
installer.

### 3. ZFSBootMenu e boot environments hanno un modello diverso dal nostro

`ZFSBootMenu` cerca boot environments ZFS che:

- siano importabili come pool ZFS
- espongano un filesystem candidato
- contengano una sottodirectory `/boot` con kernel e initramfs associati

Raccomanda inoltre che un boot environment sia, idealmente, un singolo
filesystem che contenga tutto lo stato di sistema accoppiato, per mantenere
atomicita` di snapshot, clone e rollback.

Questo collide direttamente con il modello attuale di `Margine`:

- `/boot` e` una `ESP FAT`
- i kernel artifact sono `UKI` su `ESP`
- il rollback attuale e` pensato come `Btrfs + Snapper + Limine`

Tradotto:

- se vogliamo boot environments ZFS veri, probabilmente non stiamo piu`
  parlando dell'attuale modello `Limine + UKI + /boot FAT` cosi` com'e`
- se invece vogliamo mantenere `Limine + UKI` quasi invariati, allora non
  stiamo adottando il modello classico piu` naturale di `ZFSBootMenu`

Questa e` la frattura architetturale centrale.

### 4. Cifratura e mount automation esistono, ma non coincidono col nostro flow

OpenZFS documenta:

- `zfs-mount-generator` per generare mount unit `systemd`
- key loading per dataset cifrati con `keylocation=prompt|file://...|https://`
- `dracut.zfs` per il boot di root-on-ZFS
- `zgenhostid` per generare e mantenere `/etc/hostid`

Questo significa che il mondo `root-on-ZFS` ha gia` un proprio linguaggio
operativo:

- `hostid`
- `zpool.cache`
- `bootfs`
- dataset mount generator
- key loading ZFS-native

`Margine` oggi invece ragiona in questi termini:

- `LUKS2`
- `crypttab.initramfs`
- `UKI`
- `Secure Boot`
- `TPM2`
- `Limine`

Le due architetture possono essere rese compatibili, ma non sono la stessa
architettura.

## Errori di configurazione piu` comuni da evitare

Questa e` la parte in cui e` piu` facile farsi male.

### 1. Trattare root-on-ZFS come "Btrfs ma con altri comandi"

Errore classico:

- lasciare invariato il boot model
- cambiare solo provisioning e mount

Questo approccio rompe facilmente:

- boot
- rollback
- recovery
- update safety

### 2. Tenere lo stesso modello `Snapper mental model`

Su `ZFS` gli strumenti nativi sono:

- snapshot
- clone
- bookmark
- `send` / `receive`

Provare a ricreare pari pari la semantica di `Snapper` spesso porta a una
soluzione peggiore della baseline originale.

### 3. Sottovalutare il coupling kernel <-> modulo ZFS su Arch

Su Ubuntu la situazione e` piu` favorevole perche' `ZFS` e` gia` incluso nel
kernel packaging della distribuzione. Su Arch no.

Per `root-on-ZFS`, questo e` il rischio operativo piu` importante:

- se il kernel va avanti prima del modulo `ZFS`, il root puo` non bootare
- il rischio non e` teorico: e` parte del modello operativo stesso di
  `OpenZFS on Linux`

Questa e` una delle ragioni per cui `root-on-ZFS` su Arch va trattato come
progetto separato e validato in VM prima del ferro reale.

### 4. Ignorare `hostid` e `zpool.cache`

La documentazione OpenZFS li tratta come componenti normali del boot path.

Se non vengono gestiti bene, il risultato tipico e`:

- pool non importato al boot
- import forzato manualmente
- mismatch tra host che ha creato/importato il pool e host che prova a
  riaprirlo

### 5. Abilitare feature del pool senza politica di compatibilita`

OpenZFS supporta il property `compatibility=` per limitare le feature del pool
e non accendere tutto implicitamente.

Se vogliamo:

- supportare recovery da strumenti esterni
- mantenere compatibilita` tra versioni
- limitare sorprese durante future migrazioni

serve una policy esplicita sulle feature del pool.

### 6. Usare `dedup` per "fare il figo"

No.

La doc OpenZFS e` esplicita:

- `dedup` consuma CPU, RAM e I/O
- puo` degradare pesantemente performance e operazioni amministrative
- puo` perfino rendere problematica l'importazione del pool per esaurimento di
  memoria

Per un laptop/workstation `Margine`, `dedup` e` **out by default**.

### 7. Fare over-tuning di `ARC`, `L2ARC`, `SLOG`

Altro errore comune:

- decidere prima i tunables
- misurare dopo

Per una workstation/laptop:

- `ARC` di default e` spesso il punto giusto di partenza
- `L2ARC` non ha senso come baseline laptop
- `SLOG` ha senso solo per workload con I/O sincrono reale e dispositivi adatti

La regola per `Margine` deve essere:

- niente tuning aggressivo finche' non c'e` misura reale

### 8. Non separare i dataset per semantica

Con `ZFS`, dataset diversi servono a dare policy diverse a classi diverse di
dati:

- sistema
- home
- log
- cache
- VM
- container
- dataset grandi o archival

Se tutto finisce in un solo dataset, poi snapshot, retention, tuning e backup
diventano piu` rozzi di quanto serva.

### 9. Riempire il pool troppo

La doc OpenZFS raccomanda di stare sopra il 10% di spazio libero per evitare
che il metaslab allocator diventi molto piu` costoso e che la frammentazione
peggiori il comportamento del pool.

Per una baseline `Margine` la regola deve essere semplice:

- warning operativo prima del 85%
- regime di rischio dal 90% in su

## Tuning iniziale consigliato per Margine

Questo non e` il tuning "massimo". E` il tuning prudente che evita sprechi.

### Pool-wide baseline

Per SSD/NVMe desktop:

- `ashift=12` salvo evidenza forte di device da `8K` fisico
- `autotrim=on`
- `acltype=posixacl`
- `xattr=sa`
- `compression=lz4`
- `relatime=on`

Note:

- `xattr=sa` migliora molto il comportamento degli extended attributes e dei
  `POSIX ACL`, ma riduce la portabilita` verso implementazioni OpenZFS non
  Linux
- `dnodesize=auto` ha senso solo dove `xattr=sa` e uso di xattr sono reali;
  non va imposto senza pensarci su dataset che richiedono compatibilita`

### Tuning da NON fare come baseline

- non forzare `zfs_arc_max` subito
- non introdurre `L2ARC`
- non introdurre `SLOG`
- non abilitare `special vdev`
- non cambiare `recordsize` globalmente

### Dataset-specific tuning

L'approccio corretto e` dataset per dataset:

- dataset generici desktop: default `recordsize`
- grandi file sequenziali / librerie giochi / archivi: valutare `recordsize=1M`
- database: solo dataset dedicati, con tuning specifico e misurato
- VM images: dataset separato, tuning separato

In altre parole:

- il tuning globale deve essere piccolo
- il tuning locale deve essere motivato dal carico

## Come sostituire Snapper con una politica snapshot supportata da ZFS

### Prima regola: usare primitive ZFS, non emulazioni Btrfs

Le primitive corrette sono:

- `zfs snapshot`
- `zfs clone`
- `zfs rollback`
- `zfs bookmark`
- `zfs send` / `zfs receive`

### Cosa serve a Margine v1

Per il primo ciclo di adozione non serve subito replicazione complessa.

Serve prima:

- snapshot locali automatici
- retention chiara
- naming coerente
- hook pre-update / pre-mutation
- eventuale integrazione con rollback/recovery

Per questo, la raccomandazione iniziale e`:

- **snapshot locali automatici con `sanoid`**
- **replica remota e retention differenziata rinviate a fase successiva**

Perche' `sanoid` prima di `zrepl`:

- fa bene il caso locale "autosnapshot + retention"
- e` piu` leggero concettualmente
- e` molto piu` vicino al bisogno immediato che oggi copre `Snapper`

`zrepl` resta interessante, ma soprattutto come fase successiva per:

- backup remoto
- replica raw
- pruning sender/receiver differenziato

Non e` il primo mattone da posare per sostituire `Snapper`.

### Come mappare la semantica attuale

L'attuale semantica `Margine` da preservare e` questa:

- snapshot automatico pre-update
- snapshot periodici leggibili
- recovery robusta
- distinzione tra stato di sistema e dati utente

Traduzione proposta per `ZFS`:

- `sanoid` per snapshot periodici su dataset scelti
- hook `pre-update` che crea snapshot espliciti prima di upgrade
- dataset di sistema separato da `/home`
- retention piu` breve e densa sul sistema, piu` rilassata o nulla su dati
  molto mutabili

## Decisione tecnica preliminare per Margine

La scelta prudente per ora e` questa.

### Fase A - Non migrare subito il root

Prototipare prima:

- pool/dataset ZFS non-root
- snapshot automatici locali
- eventuale backup `send/receive`

Obiettivo:

- imparare il modello operativo
- validare tuning e naming
- fissare la policy dataset

senza mettere a rischio il boot.

### Fase B - Prototipo root-on-ZFS solo in VM

Solo dopo la fase A:

- creare una VM dedicata `Margine root-on-ZFS`
- validare update, reboot, failure modes, recovery
- decidere il boot model reale

Le due strade da confrontare esplicitamente sono:

1. mantenere `Limine + UKI` e adattare `root-on-ZFS`
2. adottare `ZFSBootMenu` per i boot environments e ridefinire il recovery model

### Fase C - Solo se il prototipo e` solido, scrivere una nuova ADR

Se e solo se il prototipo funziona davvero, allora si scrive:

- nuova ADR storage
- nuovo installer path
- nuova documentazione boot/recovery
- nuova validazione host

Prima no.

## Raccomandazione concreta per la cifratura

Per `Margine`, il default da esplorare per un eventuale `root-on-ZFS` non
dovrebbe essere la cifratura ZFS-native come primo step.

La ragione e` pratica:

- oggi tutta la catena `Secure Boot + TPM2 + auto-unlock` e` gia` costruita
  attorno a `LUKS2`
- spostarsi subito su cifratura ZFS-native significa cambiare filesystem **e**
  modello di unlocking nello stesso colpo

Quindi la raccomandazione iniziale e`:

- se si prototipa `root-on-ZFS`, iniziare con `LUKS outside -> ZFS inside`

La cifratura ZFS-native puo` essere una fase ulteriore, non il primo passo.

## Piano di lavoro iniziale

### Step 1

Versionare una nota di decisione preliminare:

- `ZFS data layer` supportato prima
- `root-on-ZFS` rinviato a prototipo dedicato

### Step 2

Disegnare un layout dataset `ZFS` non-root per `Margine`, per esempio:

- `tank/data`
- `tank/archive`
- `tank/vm`
- `tank/containers`

### Step 3

Disegnare una baseline `sanoid` locale che sostituisca `Snapper` solo per il
perimetro ZFS.

### Step 4

Preparare una VM di validazione `root-on-ZFS`.

### Step 5

Solo dopo, decidere:

- `Limine + UKI` adattato
- oppure `ZFSBootMenu`

## Come cambierei Margine senza fare danni

Ordine corretto:

1. `ZFS` come storage opzionale non-root
2. snapshot automatici locali `ZFS` con retention
3. backup/replica `send/receive` opzionale
4. prototipo `root-on-ZFS` in VM
5. decisione sul boot stack
6. solo infine eventuale install path root-on-ZFS

Ordine sbagliato:

1. sostituire `Btrfs` con `ZFS` nell'installer
2. sperare che il resto regga

Il secondo ordine e` il modo piu` rapido per ottenere un sistema che "sembra
quasi pronto" ma non ha un recovery model difendibile.

## Riferimenti

Fonti ufficiali principali:

- OpenZFS Arch root-on-ZFS:
  https://openzfs.github.io/openzfs-docs/Getting%20Started/Arch%20Linux/Root%20on%20ZFS.html
- OpenZFS workload tuning:
  https://openzfs.github.io/openzfs-docs/Performance%20and%20Tuning/Workload%20Tuning.html
- OpenZFS dataset properties:
  https://openzfs.github.io/openzfs-docs/man/v2.3/7/zfsprops.7.html
- OpenZFS concepts:
  https://openzfs.github.io/openzfs-docs/man/v2.0/8/zfsconcepts.8.html
- OpenZFS system administration:
  https://openzfs.org/wiki/System_Administration
- OpenZFS `zfs-mount-generator`:
  https://openzfs.github.io/openzfs-docs/man/v2.3/8/zfs-mount-generator.8.html
- OpenZFS `dracut.zfs`:
  https://openzfs.github.io/openzfs-docs/man/master/7/dracut.zfs.7.html
- OpenZFS `zgenhostid`:
  https://openzfs.github.io/openzfs-docs/man/v2.2/8/zgenhostid.8.html
- OpenZFS pool features and compatibility:
  https://openzfs.github.io/openzfs-docs/man/master/7/zpool-features.7.html
- OpenZFS release notes / supported kernels:
  https://github.com/openzfs/zfs/releases

Tooling e modelli operativi:

- ZFSBootMenu overview:
  https://docs.zfsbootmenu.org/en/v3.0.x/
- ZFSBootMenu boot environments primer:
  https://docs.zfsbootmenu.org/en/v2.2.x/general/bootenvs-and-you.html
- ZFSBootMenu snapshot management:
  https://docs.zfsbootmenu.org/en/latest/online/snapshot-management.html
- Sanoid:
  https://github.com/jimsalterjrs/sanoid
- zrepl:
  https://zrepl.github.io/
