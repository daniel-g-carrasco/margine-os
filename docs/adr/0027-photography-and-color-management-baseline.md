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

## Decisione

Per `Margine v1` la baseline fotografia e color management e':

- `darktable`
- `argyllcms`
- `displaycal`
- `colord`

piu' una piccola libreria di profili ICC utente versionati nel repo quando sono
stabili e riconosciuti come "buoni".

## Scelte specifiche

### 1. Darktable

`Darktable` resta il tool fotografico principale.

La baseline versionata include:

- configurazione leggera e stabile;
- stili utente;
- nessun database libreria o cache.

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

## Limite esplicito

`Margine v1` NON promette una applicazione compositor-level del profilo colore
su Wayland come parte del bootstrap standard.

Motivo:

- questo livello resta ancora troppo dipendente da stack, sessione e supporto
  reale del compositor.

La baseline si concentra invece su:

- asset ICC preservati;
- app color-managed correttamente installate;
- base solida per usare `darktable`, soft-proof e profiling.

## Conseguenze

### Positive

- il sistema nasce gia' con lo stack fotografico corretto;
- i profili ICC buoni non si perdono;
- il progetto evita automazioni colore fragili o opache.

### Negative

- l'assegnazione finale del profilo al display resta una fase consapevole;
- alcune tarature restano legate al contesto hardware reale.

## Per uno studente

Qui la differenza cruciale e':

- una cosa e' avere i profili e gli strumenti giusti;
- un'altra e' far finta che il sistema possa calibrare tutto da solo.

`Margine` sceglie la strada onesta:

- preservare gli asset validi;
- preparare lo stack corretto;
- evitare illusioni sulla parte piu' fragile.
