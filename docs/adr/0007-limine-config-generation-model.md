# ADR 0007 - Modello di generazione di limine.conf

## Stato

Accettato

## Perché esiste questo ADR

Abbiamo già:

- una strategia per `Limine`
- un template versionato di `limine.conf`
- una distinzione chiara tra percorso `prod` e `recovery`

Mancava però una regola operativa su un punto importante:

- `limine.conf` finale si scrive a mano o si genera?

## Problema da risolvere

Il file `limine.conf` contiene due tipi di informazione molto diversi:

### Struttura stabile

- timeout
- branding
- entry `Produzione`
- entry `Fallback`
- schema della sezione `Recovery`

### Dati variabili

- `UUID` del root filesystem
- `UUID` del contenitore `LUKS2`
- elenco di entry recovery e snapshot

Se trattiamo tutto il file allo stesso modo, cadiamo in uno di due errori:

- o lo manteniamo tutto a mano, e diventa fragile;
- o lo generiamo tutto in modo opaco, e smette di essere leggibile.

## Decisione

Per `Margine v1`, `limine.conf` sarà un artefatto generato.

La sua sorgente logica sarà composta da:

1. template versionato nel repository;
2. facts macchina passati al generatore;
3. blocco recovery generato o fornito separatamente.

## Regola fondamentale

Il file finale sulla `ESP` NON è la sorgente autorevole.

La sorgente autorevole è:

- il template in Git;
- più i dati macchina;
- più il blocco recovery generato.

Questo significa che:

- il file finale può essere rigenerato;
- non deve essere editato a mano come fonte principale;
- se viene editato manualmente, quelle modifiche non sono considerate stabili.

## Scelta operativa iniziale

Introduciamo uno script piccolo e leggibile:

- `scripts/generate-limine-config`

Lo script deve:

- leggere il template;
- sostituire i placeholder macchina;
- opzionalmente sostituire il blocco recovery tra marker noti;
- scrivere il risultato su file o su `stdout`.

## Input iniziali richiesti

Per la `v1`, gli input minimi del generatore sono:

- `ROOT_UUID`
- `LUKS_UUID`

Input opzionale:

- file esterno con entry recovery già pronte

## Cosa NON fa il generatore nella prima versione

Nella prima versione il generatore NON:

- scandisce da solo gli snapshot `Snapper`;
- interroga direttamente il sistema installato per scoprire ogni dettaglio;
- modifica la `ESP` per conto proprio;
- firma file;
- esegue `limine enroll-config`.

Questa limitazione è intenzionale.

La prima versione deve essere:

- facile da leggere;
- facile da testare;
- facile da comporre con step successivi.

## Perché questa scelta è sana

Perché separa bene le responsabilità:

- template: struttura
- generatore: rendering
- futuro discovery layer: recupero snapshot
- futuro deploy layer: copia su `ESP`, enroll config, firma

In altre parole:

- prima costruiamo la pipeline;
- poi la automatizziamo a strati.

## Conseguenze pratiche

Questa scelta ci permette di fare tre cose utili:

1. testare il rendering senza toccare il boot reale;
2. versionare la struttura senza congelare dati macchina;
3. aggiungere più avanti generatori recovery senza riscrivere tutto.

## Per uno studente: la versione semplice

Se lo spieghiamo in modo diretto:

- il template è lo stampo;
- gli UUID e le entry recovery sono il contenuto variabile;
- lo script mette insieme le due cose;
- il file finale non è "la verità", è il risultato del processo.
