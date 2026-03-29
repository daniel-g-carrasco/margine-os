# ADR 0016 - Orchestratore top-level per installazione da live ISO

## Stato

Accettato

## Perché esiste questo ADR

Con ADR 0014 e ADR 0015 abbiamo già due pezzi corretti:

- `provision-storage`
- `bootstrap-live-iso`

Mancava però un entrypoint unico da live ISO che li usasse in sequenza.

## Problema da risolvere

Se l'utente deve ricordarsi sempre:

1. quale script chiamare per primo;
2. quali argomenti replicare nel secondo;
3. come passare dal partizionamento al bootstrap;

allora il progetto resta corretto ma poco usabile.

## Decisione

Per `Margine v1` introduciamo uno script top-level:

- `scripts/install-live-iso`

Questo script non sostituisce i due mattoni sottostanti.

Li orchestra.

## Regola di progettazione

La regola è:

- composizione sopra separazione;
- non monolite al posto della separazione.

Quindi:

- `provision-storage` resta responsabile dello storage;
- `bootstrap-live-iso` resta responsabile del bootstrap di fase 1;
- `install-live-iso` li chiama nel giusto ordine.

## Regola degli argomenti

Lo script top-level espone:

- parametri del disco;
- parametri storage principali;
- parametri del bootstrap live ISO;
- flag distruttivo esplicito;
- `dry-run`.

Così l'utente può lavorare da un solo comando senza perdere leggibilità.

## Regola di ambito

In `Margine v1`, `install-live-iso` non fa ancora:

- bootstrap utente finale;
- enrollment `TPM2`;
- firma completa della trust chain;
- generazione del blocco recovery da snapshot reali.

Fa una cosa precisa:

- unire storage provisioning e fase 1 del bootstrap in una pipeline lineare.

## Conseguenze pratiche

Questa scelta ci dà:

- un entrypoint più umano da live ISO;
- riuso vero degli script già separati;
- testabilità migliore;
- meno rischio di introdurre un mega-script ingestibile.

## Per uno studente: la versione semplice

Pensa a tre livelli:

- attrezzi singoli;
- una procedura;
- un comando che esegue la procedura.

`provision-storage` e `bootstrap-live-iso` sono gli attrezzi singoli.

`install-live-iso` è il comando che li usa bene.
