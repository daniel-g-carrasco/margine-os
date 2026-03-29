# Come funziona l'installer guidato dai manifest

## L'idea chiave

I manifest sono la verità sul contenuto del sistema.

Lo script installativo non è la fonte della policy.
È solo il motore che esegue quella policy.

## Perché è importante

Se la lista dei pacchetti sta dentro uno script gigantesco, succedono due cose:

- diventa difficile capire cosa stai installando;
- diventa difficile cambiare una scelta senza toccare la logica.

Separare `dati` e `logica` è il modo corretto.

In questo caso:

- i `dati` sono i manifest;
- la `logica` è lo script che li legge.

## I tre mondi diversi

In `Margine` distinguiamo tre mondi:

1. repo ufficiali Arch
2. AUR
3. Flatpak

Sembrano tutti "software da installare", ma non sono la stessa cosa.

Per questo lo script non li tratta tutti allo stesso modo.

## Cosa fa il percorso di default

Il percorso normale installa solo i layer ufficiali, nell'ordine deciso dal
progetto.

Questo è il punto importante:

- il default deve essere il percorso più solido e più supportabile.

## Perché AUR e Flatpak non sono di default

Perché sono due scelte consapevoli:

- AUR aumenta la superficie di manutenzione;
- Flatpak aggiunge un altro ecosistema.

Non sono "sbagliati".
Semplicemente non devono entrare nel bootstrap base senza che tu lo decida.

## Perché serve il dry-run

`dry-run` ti permette di vedere:

- quali layer stai installando;
- quali pacchetti verranno passati a `pacman`;
- se stai per includere AUR o Flatpak.

Didatticamente è molto utile perché ti fa leggere il piano prima di eseguirlo.

## Come modificarlo bene

Se vuoi cambiare il sistema target:

- modifichi i manifest.

Se vuoi cambiare il comportamento dell'installer:

- modifichi lo script.

Questa distinzione è fondamentale.

## La regola mentale giusta

Se ti trovi a voler modificare un pacchetto dentro lo script, probabilmente stai
toccando il posto sbagliato.
