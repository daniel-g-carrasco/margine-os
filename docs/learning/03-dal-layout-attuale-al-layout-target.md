# Dal layout attuale al layout target di Margine

Questa nota mette a confronto due cose:

- il layout che hai oggi sulla macchina;
- il layout che vogliamo per `Margine`.

L'obiettivo non è dire che il sistema attuale è "sbagliato".
L'obiettivo è capire perché una base già buona va raffinata quando il progetto
diventa più ambizioso.

## 1. Il layout che hai oggi

Oggi la macchina usa già una struttura pulita:

- `ESP` separata su `/boot`
- resto del disco in `LUKS2`
- `Btrfs` dentro il volume cifrato
- subvolumi per:
  - `/`
  - `/home`
  - `/.snapshots`
  - `/var/cache`
  - `/var/log`

Questo è importante: non stiamo partendo dal caos.
Stiamo partendo da una base già sensata.

## 2. Perché allora cambiare?

Perché gli obiettivi di `Margine` sono più severi di quelli di una installazione
normale.

Vogliamo insieme:

- snapshot puliti;
- rollback leggibile;
- boot snapshot-friendly;
- spazio ordinato per dataset pesanti;
- uso futuro con VM e container;
- comportamento prevedibile anche a mente fredda.

Il layout attuale copre bene il caso "desktop personale ordinato".
Il layout target deve coprire anche il caso "workstation personale con recovery
seria".

## 3. Cosa teniamo del layout attuale

Tenere ciò che è già buono è una disciplina.

Non cambiamo:

- `ESP + LUKS2 + Btrfs`
- `@` per `/`
- `@home` per `/home`
- `@snapshots`
- `@var_cache`
- `@var_log`

Questa continuità è utile perché:

- riduce complessità gratuita;
- mantiene il progetto leggibile;
- ti permette di riconoscere la parentela tra macchina attuale e sistema futuro.

## 4. Cosa aggiungiamo e perché

### `@var_tmp`

Serve a togliere dal root snapshot i temporanei persistenti.

Lezione:
- non tutto ciò che sta in `/var` è "stato del sistema";
- alcune aree vanno isolate perché sporcano i rollback.

### `@root`

Serve a separare lo spazio operativo dell'amministratore.

Lezione:
- file, appunti, script o chiavi di `root` non sono la stessa cosa del sistema
  operativo;
- un rollback di sistema non deve per forza trascinare con sé tutto ciò che è
  passato per `/root`.

### `@srv`

Serve a dare un posto ordinato a dati serviti localmente.

Esempi:

- export locali;
- directory servite in rete;
- materiale che non è sistema ma neppure "home utente".

### `@data`

È uno dei punti più importanti.

Serve a evitare che `/home` diventi il contenitore universale di tutto:

- foto;
- archivi grandi;
- staging;
- export;
- immagini VM utente;
- backup locali.

Lezione:
- un layout buono non separa solo il sistema;
- separa anche i grossi volumi di dati per darti più controllo mentale.

## 5. Perché VM e container meritano subvolumi propri

Le VM e i container sono workload ad alta scrittura.

Se li lasci nel root snapshot:

- gli snapshot crescono troppo;
- il rollback diventa meno leggibile;
- il confine tra "sistema" e "workload" si rovina.

Per questo `Margine` separa:

- `/var/lib/libvirt`
- `/var/lib/machines`
- `/var/lib/containers`

### Distinzione importante: rootful vs rootless

Questa è una sottigliezza che vale la pena imparare bene.

`Podman` rootful tende a stare sotto:

- `/var/lib/containers`

`Podman` rootless tende a stare sotto:

- `~/.local/share/containers`

Quindi:

- i container rootful vanno trattati come workload di sistema e separati;
- i container rootless fanno parte della vita utente e stanno naturalmente in
  `@home`.

## 6. Perché non continuiamo ad aggiungere subvolumi all'infinito

Perché più subvolumi non significa automaticamente più qualità.

Un layout degenera quando ogni directory diventa candidata a essere separata.

La regola sana è questa:

- separa solo ciò che deve vivere o rollbackare in modo diverso.

Per questo NON separiamo, per esempio:

- `/opt`
- `/var/lib/pacman`
- gran parte di `/usr` e `/etc`

Lezione:
- separare male è peggio che non separare affatto.

## 7. Perché `compress=zstd:3`

Qui la lezione non è "usa questa opzione e basta".

La lezione è:

- scegli mount options che abbiano un senso operativo;
- evita il tuning estetico o da benchmark.

`compress=zstd:3` ha senso perché:

- migliora l'efficienza dello storage;
- ha un costo CPU ragionevole;
- resta una scelta spiegabile su un laptop moderno.

## 8. Che cosa rende questo layout davvero migliore

Non lo rende migliore il numero di subvolumi.

Lo rende migliore il fatto che definisce bene i confini tra:

- sistema operativo;
- dati utente;
- cache e rumore;
- workload virtualizzati;
- dataset voluminosi.

Questa è la vera architettura.
Il resto è solo sintassi.

## 9. La regola finale da ricordare

Se un giorno dovrai cambiare il layout da solo, parti sempre da questa domanda:

- "questi dati devono fare rollback insieme al sistema?"

Se la risposta è:

- sì -> probabilmente stanno nel root snapshot
- no -> probabilmente meritano un subvolume separato
