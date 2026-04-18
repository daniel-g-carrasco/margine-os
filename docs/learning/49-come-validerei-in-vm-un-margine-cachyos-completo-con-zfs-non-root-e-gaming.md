# Come validerei in VM un Margine CachyOS completo con ZFS non-root e gaming

## Obiettivo

Dopo aver deciso che il primo ingresso di `ZFS` in `Margine` deve essere:

- non-root
- separato dal boot path
- separato da `root-on-ZFS`

serve un metodo di validazione piu` serio della sola domanda:

- "si installa?"

La domanda corretta diventa:

- "si installa, boota, entra in sessione, mantiene il baseline desktop, e
  regge anche un layer `ZFS` non-root e un game stack completo senza introdurre
  ambiguita` architetturali?"

## Perche' usare una VM completa

La VM completa serve a validare insieme:

- il prodotto target reale (`margine-cachyos`)
- il bootstrap installativo completo
- il boot chain generato
- il runtime desktop minimo
- il layer `ZFS` non-root
- il packaging del game stack

Non serve invece a validare:

- prestazioni gaming reali
- anti-cheat
- VRR
- HDR
- comportamento grafico bare metal

Queste cose restano test da fare dopo, su ferro reale o in una VM molto piu`
specializzata con passthrough.

## Perimetro corretto del test

Il test completo in VM deve coprire almeno quattro blocchi.

### 1. Installazione del prodotto giusto

La VM deve installare:

- `margine-cachyos`

e non solo il baseline pubblico.

Questo e` importante perche' vogliamo testare anche:

- i layer personali
- il game stack personale
- la coerenza del fallback launcher

### 2. Boot e sessione desktop

Dopo l'installazione, il guest deve:

- bootare dal disco installato
- non rientrare nella live ISO
- arrivare al login previsto
- avere una sessione utente coerente con `systemd --user`

In particolare vanno verificati:

- `greetd`
- variabili di sessione importate
- `walker`
- `fuzzel`
- `elephant`
- stack screenshot/recording

Questo chiude subito i regressioni "sembra installato ma il desktop non e`
davvero sano".

### 3. Root baseline ancora su Btrfs

Il guest deve continuare a mostrare chiaramente che:

- la root resta su `Btrfs`
- `Snapper` continua a essere il meccanismo snapshot/recovery della root

Questo e` fondamentale per non mischiare concettualmente:

- test `ZFS` non-root
- progetto `root-on-ZFS`

### 4. Layer ZFS non-root reale

Se abilitiamo `zfs-non-root-stack`, il guest deve dimostrare che:

- `zfs-dkms`
- `zfs-utils`
- `sanoid`

sono installati e coerenti.

Ma non basta vedere i package.

Serve provare:

- caricamento del modulo
- creazione pool
- creazione dataset
- snapshot manuale
- rollback manuale
- snapshot automatico `sanoid`

Per questo la VM deve avere un secondo disco dedicato, separato dal disco root.

### 5. Game stack completo

Se vogliamo una VM "completa", dobbiamo installare anche:

- `gaming-runtime-compat`
- `gaming-apps-launchers`

Qui pero' va mantenuta disciplina tecnica.

In QEMU il test corretto non e`:

- "Steam fa 120 FPS?"

Il test corretto e`:

- i package sono installati?
- i binari principali esistono?
- la toolchain runtime parte senza errori banali di linking o packaging?

Quindi il minimo serio da verificare e`:

- `steam`
- `gamescope`
- `mangohud`
- `umu-launcher`
- `obs-studio`
- `lact`
- `vkbasalt`
- plugin `obs-vkcapture`
- `vulkaninfo`

Su `margine-cachyos` c'e` anche un vincolo packaging da fissare esplicitamente:

- non mischiare il pacchetto Arch standalone `vulkan-mesa-layers` con il lato
  `lib32-mesa-git` che il game stack CachyOS puo` risolvere come provider
  Vulkan a 32 bit

In pratica il flavor `cachyos` deve avere un override del baseline AMD che
evita proprio quella combinazione, altrimenti il test VM puo` fermarsi su
conflitti file di `mesa-overlay-control.py` prima ancora di validare il game
stack vero e proprio.

## Sequenza di validazione che sceglierei

### Fase 1: installazione dalla live ISO

Usare:

- live ISO Arch ufficiale
- repo `Margine` montato via `9p`
- `install-live-iso-guided` o `install-live-iso`

con:

- `--product margine-cachyos`
- `--extra-layer zfs-non-root-stack`
- `--extra-layer gaming-runtime-compat`
- `--extra-layer gaming-apps-launchers`

### Fase 2: primo boot del guest installato

Primo gate:

- il guest parte dal disco installato
- `Limine` e le UKI esistono
- la live ISO non e` piu` coinvolta

### Fase 3: baseline desktop

Secondo gate:

- login coerente
- sessione grafica coerente
- launcher e servizi utente principali coerenti

### Fase 4: root snapshot baseline

Terzo gate:

- `Snapper` funziona ancora per la root `Btrfs`

Questo e` importante perche' dimostra che il layer `ZFS` non ha contaminato il
modello di recovery del sistema base.

### Fase 5: ZFS lab su disco separato

Quarto gate:

- cifrare `/dev/vdb`
- creare un pool `tank`
- creare dataset `tank/data`, `tank/srv`, `tank/archive`
- eseguire snapshot e rollback
- eseguire `sanoid --take-snapshots`

Qui si valida davvero il primo utilizzo operativo di `ZFS`.

### Fase 6: game stack packaging/runtime

Quinto gate:

- package presence
- binary resolution
- help/summary commands che non esplodono subito

Questo non chiude il progetto gaming, ma chiude il rischio piu` brutto per la
baseline:

- package installato ma runtime gia` rotto in una VM pulita

## Criterio di successo

Considererei la VM un successo solo se tutte queste condizioni sono vere:

- installazione completata senza workaround strani
- primo boot del disco installato riuscito
- baseline desktop coerente
- `Snapper` root coerente
- `ZFS` non-root funzionante davvero sul secondo disco
- `sanoid` funzionante davvero
- game stack presente e lanciabile ai livelli minimi sensati in QEMU

Se manca uno di questi punti, il risultato non e`:

- "quasi buono"

Il risultato e`:

- "perimetro ancora non convergente"

## Implicazione per Margine

Questa VM completa non deve essere un test "una tantum".

Deve diventare:

- un runbook ripetibile
- una guida generata insieme agli artifact QEMU
- un criterio di ammissione minimo prima di parlare seriamente di `root-on-ZFS`

In altre parole:

- prima VM completa `Btrfs root + ZFS data layer + gaming`
- poi discussione su `root-on-ZFS`

Non il contrario.
