# ADR 0027 - Baseline fotografia e color management

## Stato

Accettato

## Contesto

`Margine` nasce anche come workstation fotografica.

Questo significa che il progetto deve esplicitare almeno quattro livelli:

- sviluppo RAW e workflow fotografico;
- color management applicativo;
- calibrazione/profilazione display;
- gestione degli asset ICC prodotti dall'utente.

Su `Hyprland`, inoltre, esiste oggi anche una possibilita' reale di applicare un
profilo ICC direttamente a livello compositor.

Questo apre una domanda architetturale importante:

- il profilo colore va imposto dal compositor;
- oppure conviene partire dal sistema (`colord`) e dalle applicazioni che sanno
  davvero gestirlo.

## Decisione

Per `Margine v1` la baseline fotografia e color management e':

- `darktable`
- `argyllcms`
- `displaycal`
- `colord`

piu' una piccola libreria di profili ICC utente versionati nel repo quando sono
stabili e riconosciuti come "buoni".

Inoltre, `Margine v1` adotta un modello esplicito di applicazione del profilo:

- `colord` come fonte di verita' dei profili display;
- applicazioni color-managed come primo punto di applicazione reale del profilo;
- `Hyprland` ICC compositor-level lasciato opzionale e non attivato di default.

## Scelte specifiche

### 1. Darktable

`Darktable` resta il tool fotografico principale.

La baseline versionata include:

- configurazione leggera e stabile;
- stili utente;
- nessun database libreria o cache.

`Darktable` e' anche il riferimento principale per la parte display profile:
quando il sistema espone correttamente il profilo display, e' l'applicazione a
fare la trasformazione colore dove serve davvero.

### 2. ArgyllCMS e DisplayCAL

Servono per:

- misurare;
- calibrare;
- profilare;
- verificare.

Non vengono pero' trasformati in un sistema "magico" di autoconfigurazione.

### 3. Colord

`colord` entra nella baseline come servizio di sistema per i profili colore.

Questo e' coerente anche con la documentazione `darktable`, che su Linux
interroga il sistema e `colord` per trovare il display profile corretto.

La stessa documentazione `darktable` ricorda anche che un profilo display
scadente puo' fare piu' danni di un semplice `sRGB`, quindi `Margine` conserva
solo i profili che consideriamo davvero validati.

### 4. Profili ICC utente

I profili ICC validati e utili possono essere versionati come asset.

Per `Margine v1` questo vale per:

- il profilo del pannello interno Framework 13;
- il profilo del monitor esterno Dell `P2415Q`.

Non vengono invece versionati:

- log `DisplayCAL`;
- report di misura;
- database `colord`;
- profili vecchi o sperimentali;
- binding runtime opachi come `DisplayCAL.ini` o `color.jcnf`.

### 5. Hyprland ICC

`Hyprland` supporta il caricamento di un ICC per monitor, ma `Margine v1` NON lo
attiva di default.

Motivo:

- e' una leva potente, ma cambia il comportamento dell'intera sessione grafica;
- puo' confondere il debugging se viene attivata troppo presto;
- su `Hyprland` l'ICC compositor-level forza `sRGB` per `sdr_eotf` e sovrascrive
  il preset CM del monitor;
- la stessa documentazione `Hyprland` segnala che ICC e HDR/gaming non sono una
  combinazione tranquilla.

Per questo la regola di `v1` e':

- prima sistema e app;
- poi, solo dopo validazione, eventuale ICC nel compositor.

### 6. Browser e altre applicazioni grafiche

Per `Margine v1` non introduciamo tweak aggressivi o hack browser-specifici per
il color management.

La baseline resta questa:

- installare applicazioni che gia' supportano bene il color management;
- far emergere il profilo corretto dal sistema;
- evitare impostazioni nascoste difficili da mantenere.

In pratica:

- `darktable` e le applicazioni fotografiche sono il primo bersaglio;
- il browser resta color-managed a livello applicativo, ma senza policy
  speciali dedicate all'ICC nella `v1`.

## Limite esplicito

`Margine v1` NON promette una applicazione compositor-level del profilo colore
su Wayland come parte del bootstrap standard.

La baseline si concentra invece su:

- asset ICC preservati;
- app color-managed correttamente installate;
- base solida per usare `darktable`, soft-proof e profiling;
- un percorso futuro pulito per abilitare l'ICC di `Hyprland` in modo
  consapevole.

## Conseguenze

### Positive

- il sistema nasce gia' con lo stack fotografico corretto;
- i profili ICC buoni non si perdono;
- il progetto evita automazioni colore fragili o opache;
- il compositor non diventa una fonte di confusione nella `v1`.

### Negative

- l'assegnazione finale del profilo al display resta una fase consapevole;
- alcune tarature restano legate al contesto hardware reale;
- l'ICC compositor-level su `Hyprland` resta da validare in una fase successiva.

## Per uno studente

Qui la differenza cruciale e':

- una cosa e' avere i profili e gli strumenti giusti;
- un'altra e' decidere dove applicarli;
- un'altra ancora e' non confondere il sistema intero con una singola app.

`Margine` sceglie la strada prudente:

- preservare gli asset validi;
- preparare lo stack corretto;
- partire dalle applicazioni che supportano davvero il color management;
- rinviare l'ICC del compositor a quando potra' essere validato bene.
