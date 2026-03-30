# Perché servono due livelli di snapshot durante gli update

Se vuoi un comportamento "alla Manjaro" o "alla Omarchy", il requisito reale e'
questo:

- avere uno snapshot subito prima di toccare il sistema.

Ma in `Margine` non ci fermiamo li'.

## Livello 1: snapshot pre-update globale

Appena parte `update-all`, creiamo uno snapshot esplicito del root.

Questo snapshot rappresenta:

- lo stato prima dell'intera manutenzione;
- un punto di ritorno semplice da capire;
- il "grande bottone rosso" prima di iniziare.

## Livello 2: snapshot pre/post di pacman

Dentro lo stesso flusso, `snap-pac` continua a creare snapshot pre/post per la
transazione `pacman`.

Questi sono piu' granulari:

- aiutano a capire cosa e' successo attorno al cambio pacchetti;
- restano utili anche se `pacman` viene usato fuori da `update-all`.

## Perché non sceglierne uno solo

Se usi solo lo snapshot globale:

- perdi dettaglio sulla transazione `pacman`.

Se usi solo `snap-pac`:

- non hai un punto di ritorno chiaro prima di AUR, Flatpak, firmware e boot
  regeneration.

Quindi in `Margine` li usiamo entrambi.

## La formula semplice

- snapshot globale per la manutenzione intera;
- snapshot granulari per `pacman`.

E' proprio questa combinazione che rende il flusso piu' robusto.
