# ADR 0003 - Layout di partizioni, subvolumi e mount strategy

## Stato

Accettato

## Contesto

La macchina attuale ha già una base sensata:

- `ESP` separata montata su `/boot`
- resto del disco in `LUKS2`
- root `Btrfs`
- subvolumi separati per `/`, `/home`, `/.snapshots`, `/var/cache`,
  `/var/log`

Questa base è buona, ma non è ancora il layout migliore per gli obiettivi di
`Margine`:

- `Limine` + snapshot bootabili
- `Btrfs` + `Snapper`
- recovery molto forte
- uso futuro con VM e container
- snapshot puliti e poco rumorosi

## Requisiti

Il layout deve:

- restare semplice da capire;
- supportare `LUKS2` e `Btrfs` in modo pulito;
- non gonfiare inutilmente gli snapshot root;
- distinguere bene tra "stato del sistema" e "dati ad alta mutazione";
- essere pronto per `libvirt`, `systemd-nspawn` e container;
- non complicare inutilmente `Limine + UKI`.

## Decisione

Per `Margine v1` adottiamo questo layout target.

## Partizioni

### Partizione 1

- tipo: `ESP`
- filesystem: `FAT32`
- dimensione: `4 GiB`
- mountpoint: `/boot`

Motivo:

- con `Limine + UKI + snapshot bootabili` è utile avere un `/boot` ampio;
- evitare `ESP` piccole riduce attrito quando aumentano kernel, UKI e artefatti
  di recovery;
- un singolo `/boot` FAT e molto più semplice da capire di una combinazione
  `ESP + XBOOTLDR` nella `v1`.

### Partizione 2

- tipo: `LUKS2`
- dimensione: resto del disco
- contenuto: un solo filesystem `Btrfs`

Motivo:

- struttura pulita;
- recovery lineare;
- nessuna frammentazione architetturale inutile.

## Swap

Per la `v1` NON adottiamo una partizione swap dedicata.

Scelta:

- `zram` come swap principale;
- niente ibernazione come requisito della `v1`.

Motivo:

- l'ibernazione aggiunge complessità importante a `LUKS2 + TPM2 + snapshot`;
- non è coerente con l'obiettivo di tenere la prima versione leggibile.

Se in futuro l'ibernazione diventa requisito reale, verrà affrontata come ADR
separato.

## Subvolumi target

### Subvolumi di base

- `@` -> `/`
- `@home` -> `/home`
- `@snapshots` -> `/.snapshots`
- `@var_log` -> `/var/log`
- `@var_cache` -> `/var/cache`
- `@var_tmp` -> `/var/tmp`
- `@root` -> `/root`
- `@srv` -> `/srv`
- `@data` -> `/data`

### Subvolumi per virtualizzazione e container

- `@var_lib_libvirt` -> `/var/lib/libvirt`
- `@var_lib_machines` -> `/var/lib/machines`
- `@var_lib_containers` -> `/var/lib/containers`

### Subvolumi opzionali, solo se servono davvero

- `@var_lib_docker` -> `/var/lib/docker`
- `@var_lib_flatpak` -> `/var/lib/flatpak`

## Tabella operativa di riferimento

| Subvolume | Mountpoint | Ruolo | Entra nel rollback di sistema? | Nota |
| --- | --- | --- | --- | --- |
| `@` | `/` | stato del sistema | sì | contiene il sistema operativo vero e proprio |
| `@home` | `/home` | dati utente | no | tiene separata la vita dell'utente dal rollback root |
| `@snapshots` | `/.snapshots` | storage Snapper | non direttamente | ospita gli snapshot e la loro metadata |
| `@var_log` | `/var/log` | log persistenti | no | evita rumore negli snapshot root |
| `@var_cache` | `/var/cache` | cache persistenti | no | evita crescita inutile degli snapshot |
| `@var_tmp` | `/var/tmp` | temporanei persistenti | no | separa file effimeri ma persistenti ai reboot |
| `@root` | `/root` | spazio operativo amministrativo | no | evita di mescolare materiale admin e stato OS |
| `@srv` | `/srv` | dati serviti localmente | no | utile per servizi locali e publish tree |
| `@data` | `/data` | dataset, archivi, staging | no | punto ordinato per materiale grande o longevo |
| `@var_lib_libvirt` | `/var/lib/libvirt` | virtualizzazione rootful | no | contiene immagini, XML e runtime di libvirt |
| `@var_lib_machines` | `/var/lib/machines` | `systemd-nspawn` | no | separa macchine/immagini nspawn dagli snapshot OS |
| `@var_lib_containers` | `/var/lib/containers` | container rootful | no | copre Podman rootful e workload simili |
| `@var_lib_docker` | `/var/lib/docker` | Docker rootful | no | si crea solo se Docker entra davvero nel progetto |
| `@var_lib_flatpak` | `/var/lib/flatpak` | Flatpak di sistema | no | opzionale: utile solo se Flatpak system-wide sarà parte della allowlist |

## Politica dati per workload moderni

### VM

Per le VM ci interessa separare due categorie:

- metadata e runtime del gestore;
- immagini disco vere e proprie.

`/var/lib/libvirt` viene quindi separato come subvolume dedicato.
Se useremo immagini molto grandi o ad alta scrittura, potremo applicare
`NOCOW` in modo mirato solo a directory come:

- `/var/lib/libvirt/images`
- `/data/vm`

### Container

Per i container dobbiamo distinguere tra `rootful` e `rootless`.

- `rootful` usa tipicamente `/var/lib/containers`
- `rootless` usa tipicamente `~/.local/share/containers`

Questo significa che il layout proposto copre già bene i container `rootful`,
mentre quelli `rootless` restano naturalmente dentro `@home`, cioè fuori dal
rollback di sistema ma dentro i dati utente.

### Flatpak

Non diamo per scontato che `Flatpak` faccia parte della `v1`.
Se entrerà, distingueremo:

- `system-wide`: candidato a `@var_lib_flatpak`
- `per-user`: resterà sotto `~/.local/share/flatpak`, quindi dentro `@home`

## Regola architetturale importante

Gli snapshot root devono contenere lo stato del sistema.

Non devono contenere, per quanto possibile:

- cache;
- log ad alta rotazione;
- file temporanei persistenti;
- dischi di VM;
- storage dei container;
- dataset utente voluminosi e molto mutabili.

Questa è la vera ragione del layout.
Non è "ordine estetico". È qualità del rollback.

## Cosa resta dentro il root snapshot

Resta dentro `@` tutto ciò che definisce il sistema:

- `/etc`
- `/usr`
- `/opt`
- `/var/lib/pacman`
- `/var/lib/systemd`
- le configurazioni di sistema che devono tornare indietro insieme al sistema

## Cosa NON separiamo

### `/opt`

Resta dentro `@`.

Motivo:

- molti pacchetti installano lì;
- separarlo aumenterebbe il rischio di disallineamento tra package database e
  contenuto reale.

### `/var/lib/pacman`

Resta dentro `@`.

Motivo:

- il database dei pacchetti deve restare coerente con lo snapshot del sistema;
- separarlo renderebbe i rollback molto più ambigui.

## Mount options

### Btrfs

Per i subvolumi Btrfs useremo come base:

- `rw`
- `relatime`
- `compress=zstd:3`
- `ssd`

Scelte consapevoli:

- non puntiamo a mount options aggressive o "da benchmark";
- vogliamo un sistema stabile e leggibile;
- la compressione `zstd` è un vantaggio concreto su laptop moderno.

Non fisseremo invece in `fstab`, salvo necessità reale:

- `space_cache=v2`
- `autodefrag`
- `discard=async`

Motivo:

- preferiamo esplicitare solo ciò che è davvero una scelta architetturale;
- lasciamo ai default moderni del kernel Btrfs ciò che non ci serve irrigidire.

### Trim

Usiamo:

- `fstrim.timer`

Non usiamo come default:

- `discard=async`

Motivo:

- preferiamo una strategia più lineare e meno rumorosa dal punto di vista del
  mount.

## NOCOW

Non useremo `NOCOW` in modo indiscriminato.

Lo applicheremo solo dove ha davvero senso, e prima che i dati vengano scritti:

- `/var/lib/libvirt/images`
- eventuali directory utente dedicate a immagini disco, per esempio
  `/data/vm`

Non lo applicheremo di default a:

- `/var/lib/containers`

Motivo:

- i container hanno pattern diversi dalle immagini disco delle VM;
- un blanket `NOCOW` qui sarebbe una scelta troppo grossolana.

## Filosofia di recovery

La recovery del sistema seguirà questa logica:

- gli snapshot root servono a recuperare lo stato del sistema;
- `home`, `data`, VM e container non devono inquinare quello snapshot;
- `Limine` deve poter esporre snapshot bootabili in modo chiaro;
- il restore deve essere comprensibile anche a mente fredda.

## Rapporto con il layout attuale

### Cosa manteniamo

- `ESP + LUKS2 + Btrfs`
- `@`
- `@home`
- `@snapshots`
- `@var_log`
- `@var_cache`

### Cosa miglioriamo

- aggiungiamo `@var_tmp`
- aggiungiamo `@root`
- aggiungiamo `@srv`
- aggiungiamo `@data`
- separiamo le aree di virtualizzazione e container
- definiamo una strategia esplicita `NOCOW`
- fissiamo mount options più sensate per la nuova architettura

## Perché questo è il layout migliore per Margine

Perché bilancia bene quattro cose insieme:

1. recovery forte;
2. semplicità mentale;
3. compatibilità con `Btrfs + Snapper`;
4. crescita futura verso VM e container senza sporcare gli snapshot root.

Non è il layout "più minimale possibile".
È il layout più coerente con il progetto.

## Riferimenti

- ArchWiki, `Btrfs`:
  https://wiki.archlinux.org/title/Btrfs
- ArchWiki, `Snapper`:
  https://wiki.archlinux.org/title/Snapper
- ArchWiki, note su layout Btrfs e snapshot:
  https://wiki.archlinux.org/title/User:M0p/Btrfs_subvolumes
- ArchWiki, esempio di layout con subvolumi separati:
  https://wiki.archlinux.org/title/User:Thawn
