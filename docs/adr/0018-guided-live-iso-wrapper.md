# ADR 0018 - Wrapper guidato per installazione da live ISO

## Stato

Accettato

## Perché esiste questo ADR

Gli script di `Margine` sono ormai abbastanza maturi da coprire:

- storage provisioning;
- bootstrap live ISO;
- bootstrap in chroot;
- provisioning utente.

Mancava però un punto importante di usabilità:

- un entrypoint guidato, passo passo.

## Problema da risolvere

Un set di script robusti non equivale ancora a una buona esperienza
d'installazione.

Molti utenti si aspettano:

- domande ordinate;
- riepilogo finale;
- distinzione chiara tra modalità distruttiva e non distruttiva;
- istruzioni semplici da seguire anche mesi dopo.

## Decisione

Per `Margine v1` introduciamo:

- `scripts/install-live-iso-guided`

Questo script non sostituisce i wrapper e gli script sottostanti.

Li usa in modo guidato.

## Modalità previste

La prima versione supporta due modalità:

- `erase-disk`
- `mounted-target`

La prima usa `install-live-iso`.

La seconda usa `bootstrap-live-iso` su un target già montato.

## Regola UX

La UX della `v1` resta volutamente semplice:

- prompt testuali in shell;
- nessuna dipendenza obbligatoria da `dialog`, `gum` o TUI esterne;
- riepilogo finale prima dell'esecuzione.

## Regola password

Se `openssl` è disponibile, il wrapper può generare al volo l'hash password
utente.

Se non lo è, oppure se l'utente sceglie di non impostarla subito, il flow resta
valido ma richiede un `passwd` finale.

## Conseguenze pratiche

Questa scelta ci dà:

- un'esperienza già molto più vicina a `archinstall`;
- zero dipendenze UX extra;
- una reinstallazione futura più semplice da ricordare.

## Per uno studente: la versione semplice

Prima abbiamo costruito il motore.

Adesso stiamo mettendo un cruscotto leggibile davanti al motore.
