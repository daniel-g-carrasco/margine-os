# Come imposterei un layer ZFS non-root e una policy snapshot locale

## Obiettivo

Questa nota continua il ragionamento della nota precedente:

- [46-perche-la-migrazione-a-zfs-va-separata-tra-data-layer-e-root-on-zfs.md](/home/daniel/dev/margine-os/docs/learning/46-perche-la-migrazione-a-zfs-va-separata-tra-data-layer-e-root-on-zfs.md)

L'obiettivo qui non e` decidere un `root-on-ZFS`.

L'obiettivo e` definire il primo perimetro utile e prudente per `Margine`:

- un layer `ZFS` non-root
- una politica snapshot automatica locale
- una semantica coerente con il modo in cui oggi `Margine` separa
  `system-state`, `user-data`, `service-data` e dati molto mutabili

## Regola di partenza

Nel primo ciclo `ZFS` deve entrare dove porta vantaggi senza entrare nel boot.

Quindi:

- niente root su `ZFS`
- niente `/boot` su `ZFS`
- niente sostituzione immediata di `Snapper` per il root `Btrfs`

Nel primo ciclo si usa `ZFS` per dataset aggiuntivi, non per la root attiva.

## Quale problema risolve davvero ZFS nel primo giro

`ZFS` da layer non-root serve bene soprattutto per:

- dataset grandi o a lunga vita
- dataset che beneficiano di snapshot nativi locali
- dataset che in futuro possono diventare candidati a `send/receive`
- dataset dove la separazione di policy vale piu` del rollback di sistema

I candidati naturali in `Margine` sono:

- `/data`
- `/srv`
- `/var/lib/libvirt`
- `/var/lib/machines`
- `/var/lib/containers`

I candidati da rinviare sono:

- `/`
- `/boot`
- `/.snapshots`
- `/var/log`
- `/var/cache`
- `/var/tmp`

Il motivo e` semplice:

- i primi sono dataset operativi o di servizio, con vita autonoma dal root
- i secondi sono ancora fortemente legati all'attuale modello `Btrfs +
  Snapper + Limine + UKI`

## Topologia consigliata per il primo prototipo reale

La topologia piu` prudente e` questa:

### Opzione preferita

- `Btrfs` root invariato
- un secondo disco o una seconda partizione dedicata a `ZFS`
- se serve cifratura: `LUKS2 -> ZFS pool`

### Opzione accettabile

- `Btrfs` root invariato
- pool `ZFS` su disco esterno o NVMe secondario

### Opzione da evitare nel primo giro

- ridimensionare il contenitore root attuale per far spazio a `ZFS`
- usare lo stesso disco root in modo invasivo

La ragione non e` teorica:

- nel primo giro vogliamo validare il modello operativo di `ZFS`
- non vogliamo contemporaneamente fare chirurgia distruttiva sul root

## Layout dataset proposto

### Nome del pool

Per `Margine` userei un nome esplicito e neutro:

- `tank`

oppure, se vuoi un nome piu` dichiarativo:

- `margine`

Io preferisco `tank` solo perche' e` immediatamente riconoscibile come pool
operativo e non si confonde con la root `Btrfs`.

## Gerarchia dataset consigliata

### Root logico del pool

- `tank`
  - `tank/data`
  - `tank/archive`
  - `tank/srv`
  - `tank/vm`
  - `tank/machines`
  - `tank/containers`
  - `tank/home` (solo fase successiva)

### Mountpoint consigliati

| Dataset | Mountpoint | Primo giro? | Snapshot automatici? | Note |
| --- | --- | --- | --- | --- |
| `tank/data` | `/data` | si` | si` | dataset generico per archivi, staging, project data |
| `tank/archive` | `/archive` o `/data/archive` | si` | si`, piu` radi | dataset long-lived, poca mutabilita` |
| `tank/srv` | `/srv` | si` | si` | servizi locali e publish trees |
| `tank/vm` | `/var/lib/libvirt` oppure `/data/vm` | si` | limitati | meglio dataset separato da immagini generiche |
| `tank/machines` | `/var/lib/machines` | si` | limitati | `systemd-nspawn` rootful |
| `tank/containers` | `/var/lib/containers` | si` | limitati | rootful Podman/containers |
| `tank/home` | `/home` | no, non subito | forse | da valutare solo dopo aver validato il modello |

## Mapping rispetto ai subvolumi attuali

Oggi `Margine` separa in `Btrfs`:

- `@data`
- `@srv`
- `@var_lib_libvirt`
- `@var_lib_machines`
- `@var_lib_containers`

Il mapping piu` naturale in `ZFS` non-root e`:

- `@data` -> `tank/data`
- `@srv` -> `tank/srv`
- `@var_lib_libvirt` -> `tank/vm`
- `@var_lib_machines` -> `tank/machines`
- `@var_lib_containers` -> `tank/containers`

Questa continuita` e` importante:

- non cambia il ragionamento architetturale
- cambia solo il backend storage/snapshot di quei mountpoint

## Dataset che NON metterei subito su ZFS

### `/home`

Non nel primo giro.

Motivi:

- e` un dataset importante e molto ampio
- ha forte interazione con profili utente, cache, tool GUI, sync personali
- se qualcosa va storto, il costo operativo e` molto piu` alto

`/home` puo` diventare candidato solo dopo che:

- il pool `ZFS` e` gia` operativo bene
- snapshot e pruning sono compresi
- recovery e import/export del pool sono diventati routine

### `/var/log`, `/var/cache`, `/var/tmp`

Non lo farei nel primo giro.

Motivi:

- non sono il caso d'uso piu` interessante per `ZFS`
- aumentano il numero di mountpoint da portarsi dietro
- non portano abbastanza valore da giustificare la complessita` iniziale

### `/.snapshots`

No.

Se il root resta `Btrfs`, `/.snapshots` resta parte del modello `Snapper`.

Se in futuro il root passera` a `ZFS`, allora `/.snapshots` probabilmente non
avra` piu` senso nello stesso modo.

## Proprietà ZFS consigliate per la baseline

Per il primo layer `ZFS` non-root, la baseline prudente e`:

### Pool

- `ashift=12`
- `autotrim=on`

### Dataset default

- `compression=lz4`
- `atime=off`
- `acltype=posixacl`
- `xattr=sa`

Perche' `atime=off` qui e non `relatime`:

- sui dataset dati non-root la compatibilita` semantica con root Linux e`
  meno critica
- il guadagno nel ridurre writes inutili e` spesso sensato

### Dataset specifici

#### `tank/data`

- default `recordsize`

#### `tank/archive`

- valutare `recordsize=1M` se ospita file grandi sequenziali

#### `tank/vm`

- dataset dedicato
- niente tuning aggressivo subito
- valutare `recordsize` solo dopo misure reali

#### `tank/containers`

- dataset dedicato
- default all'inizio

La regola resta:

- tuning locale, non tuning globale

## Policy snapshot automatica: cosa sostituisce e cosa no

### Cosa NON sostituisce subito

Non sostituisce:

- `Snapper` del root
- recovery entry `Limine` basate su snapshot `Btrfs`
- pre-update snapshot del sistema root

Quelle restano come sono.

### Cosa sostituisce nel perimetro ZFS

Sostituisce solo questo:

- snapshot periodici dei dataset `ZFS`
- snapshot pre-mutation dei dataset `ZFS`
- retention locale di quei dataset

Quindi il concetto corretto e`:

- due modelli snapshot convivono per un po'

1. `Btrfs + Snapper` per il sistema root
2. `ZFS + sanoid` per il layer dati ZFS

Non e` brutto.
E` la cosa piu` rigorosa da fare durante la transizione.

## Tool consigliato: `sanoid`

Per il primo ciclo sceglierei `sanoid`.

Motivi:

- fa bene snapshot automatici locali
- retention semplice e leggibile
- e` piu` vicino al problema attuale di `Margine`
- non obbliga subito a pensare in termini di replica remota

`zrepl` resta candidato successivo, ma non come primo mattone.

## Policy snapshot proposta

### Classe 1 - Dataset importanti ma non ad altissima churn

Candidati:

- `tank/data`
- `tank/srv`

Retention proposta:

- hourly: 24
- daily: 14
- monthly: 3

Questa politica da`:

- copertura breve utile
- rollback locale ragionevole
- costo spazio ancora leggibile

### Classe 2 - Archive / long-lived data

Candidato:

- `tank/archive`

Retention proposta:

- daily: 7
- monthly: 6

Niente hourly di default.

### Classe 3 - VM e container rootful

Candidati:

- `tank/vm`
- `tank/machines`
- `tank/containers`

Retention proposta iniziale:

- autosnapshot frequenti: no
- snapshot espliciti pre-mutation: si`
- snapshot periodici radi: opzionali, da valutare

Motivo:

- VM e container grandi possono esplodere rapidamente in uso spazio
- snapshot frequenti su immagini molto scritte portano rumore prima ancora che
  valore

Per questi dataset preferisco partire da:

- snapshot manuali/espliciti
- snapshot `pre-update` o `pre-maintenance`

e solo dopo decidere se aggiungere schedulazione periodica.

## Snapshot pre-update in un mondo ibrido

Oggi `Margine` ha gia`:

- `create-pre-update-snapshot` per `Snapper`
- `update-all` che lo richiama per il root

Nel mondo ibrido che propongo, il comportamento corretto diventa:

1. `Snapper` crea lo snapshot root `Btrfs`
2. un nuovo hook `ZFS pre-update` crea snapshot espliciti dei dataset `ZFS`
   rilevanti

Per esempio:

- `tank/data@margine-pre-update-<timestamp>`
- `tank/srv@margine-pre-update-<timestamp>`
- opzionalmente `tank/vm@margine-pre-update-<timestamp>`

Questa semantica e` molto vicina a quella che hai gia` in testa con `Margine`:

- prima di una mutazione importante, lasciare un punto di ritorno leggibile

## Cosa NON fare sugli snapshot ZFS

### 1. Non snapshotare tutto con la stessa retention

Dataset diversi hanno costi e benefici diversi.

### 2. Non usare snapshot VM come sostituto di backup guest-aware

Snapshot ZFS su immagini VM sono utili, ma non equivalgono automaticamente a
backup applicativo consistente.

### 3. Non assumere che ogni dataset debba essere auto-snapshottato

Alcuni dataset meritano solo snapshot espliciti.

## Naming e policy operativa

### Naming snapshot espliciti

Consiglio:

- `margine-pre-update-YYYYMMDD-HHMMSS`
- `margine-pre-maintenance-YYYYMMDD-HHMMSS`
- `margine-manual-<label>-YYYYMMDD-HHMMSS`

Perche':

- leggibili da umano
- facilmente filtrabili da tool/script

### Policy di pruning

Per gli snapshot periodici:

- `sanoid` fa pruning automatico

Per gli snapshot espliciti:

- non cancellarli automaticamente subito
- dare una retention minima oppure una review manuale

## Validazione minima che vorrei prima di dichiararlo baseline

Per un host con layer `ZFS` non-root, la validazione minima dovrebbe includere:

- `zpool status` pulito
- `zfs list` coerente con i mountpoint previsti
- import automatico del pool al boot
- `sanoid` attivo e capace di creare snapshot
- almeno uno snapshot `pre-update` esplicito riuscito
- restore manuale documentato di un dataset non-root

Questa parte e` cruciale:

- prima di dichiarare "snapshot automatici funzionanti", bisogna provare anche
  il restore, non solo la creazione

## Proposta concreta per Margine

Se dovessi trasformare oggi questo studio in un primo progetto reale, farei:

### Fase 1 - Storage layer opzionale

Supportare un pool `ZFS` non-root per:

- `/data`
- `/srv`
- `/var/lib/libvirt`
- `/var/lib/machines`
- `/var/lib/containers`

### Fase 2 - Snapshot locali ZFS

Introdurre:

- `sanoid`
- un file di policy versionato
- un hook `pre-update` per snapshot espliciti dei dataset ZFS

### Fase 3 - Restore drill

Documentare e provare:

- rollback file-level
- clone temporaneo
- restore di dataset non-root

### Fase 4 - Solo dopo, discutere `/home`

Se il modello e` sano, allora si discute se `/home` debba entrare o no in
`ZFS`.

## Come lo cambierei in futuro

Se questa fase funziona bene, i passi successivi sensati sono:

1. aggiungere `send/receive` come backup opzionale
2. decidere se `zrepl` serve davvero oppure no
3. solo dopo tornare sul tema `root-on-ZFS`

Questo ordine conta.

Se si parte da `root-on-ZFS`, si salta la parte piu` utile dell'apprendimento:

- capire come `ZFS` si comporta davvero dentro `Margine`

senza mettere subito a rischio il boot.

## Riferimenti

Fonti ufficiali:

- OpenZFS workload tuning:
  https://openzfs.github.io/openzfs-docs/Performance%20and%20Tuning/Workload%20Tuning.html
- OpenZFS `zfsprops`:
  https://openzfs.github.io/openzfs-docs/man/v2.3/7/zfsprops.7.html
- OpenZFS concepts:
  https://openzfs.github.io/openzfs-docs/man/v2.0/8/zfsconcepts.8.html
- OpenZFS system administration:
  https://openzfs.org/wiki/System_Administration

Tooling:

- Sanoid:
  https://github.com/jimsalterjrs/sanoid
- zrepl:
  https://zrepl.github.io/
