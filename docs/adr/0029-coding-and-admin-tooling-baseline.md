# ADR 0029 - Baseline tooling per coding e amministrazione

## Stato

Accettato

## Contesto

`Margine` non e' solo un desktop grafico.
Deve nascere anche come macchina pratica per:

- coding quotidiano;
- ispezione del sistema;
- debugging leggero;
- lavoro terminal-first.

Lasciare questi strumenti impliciti dentro `base` o dispersi tra altri layer
renderebbe il progetto meno leggibile.

## Decisione

`Margine v1` introduce un layer dedicato:

- `coding-system-tools`

Questo layer raccoglie il tooling workstation per terminale e amministrazione,
separandolo da:

- base di sistema;
- desktop Hyprland;
- applicazioni utente.

## Contenuto baseline

Il layer include, tra gli altri:

- `tmux`
- `opencode`
- `htop`
- `btop`
- `radeontop`
- `ripgrep`
- `fd`
- `jq`
- `tree`
- `curl`
- `grep`
- `less`
- `openssh`
- `rsync`
- `strace`
- `lsof`

## Scelte specifiche

### 1. Kitty resta il terminale baseline

`kitty` non entra in questo layer.

Motivo:

- fa parte del desktop baseline;
- non e' uno strumento ausiliario, ma il terminale standard della sessione.

### 2. Opencode entra nei repo ufficiali

Poiche' `opencode` oggi risulta disponibile nei repo ufficiali Arch, non viene
trattato come eccezione AUR.

### 3. Comandi base gia' presenti

Alcuni strumenti sono gia' portati in macchina da Arch stessa o da dipendenze
ampie.

Li rendiamo comunque espliciti quando fanno parte dell'esperienza che vogliamo
garantire, cosi' il manifest descrive davvero il sistema target.

### 4. Ghostty esce dal perimetro

`Ghostty` non entra nella baseline `v1`.

Motivo:

- il terminale baseline e' gia' `kitty`;
- mantenere due terminali come default aumenterebbe rumore e duplicazione.

## Conseguenze

### Positive

- il progetto dichiara chiaramente il suo corredo da workstation;
- i tool utili per coding e amministrazione non restano impliciti;
- il layer resta facile da estendere.

### Negative

- il numero di pacchetti espliciti aumenta;
- alcune utility risultano ridondanti rispetto a cio' che Arch gia' porta con
  se'.

## Per uno studente

La regola qui e' semplice:

- non tutto cio' che esiste nel sistema merita un layer;
- ma cio' che definisce il tuo modo di lavorare si'.

Per questo `Margine` separa:

- la base del sistema;
- il desktop;
- il tooling da terminale.
