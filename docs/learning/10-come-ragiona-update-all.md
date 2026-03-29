# Come ragiona update-all

Questa nota accompagna:

- [update-all](/home/daniel/dev/margine-os/scripts/update-all)

La domanda giusta non è:

- "quali comandi lancia?"

La domanda giusta è:

- "in che ordine ragiona?"

## 1. Perché l'ordine conta

In un sistema come `Margine`, aggiornare non significa solo scaricare pacchetti.

Aggiornare significa anche:

- preservare la recovery;
- rigenerare il boot path;
- verificare che la trust chain non si rompa.

Per questo `update-all` ha bisogno di fasi, non di una lista casuale di
comandi.

## 2. Cosa è core e cosa è accessorio

Per `Margine v1` il core è:

- `pacman`
- `mkinitcpio`
- generazione `limine.conf`
- verifiche finali

Gli strati accessori sono:

- AUR
- Flatpak
- `fwupd`

Questo non vuol dire che siano inutili.
Vuol dire che non hanno lo stesso peso architetturale del core.

## 3. Perché alcuni errori devono fermare tutto

Se fallisce `pacman`, oppure fallisce la rigenerazione della parte boot, non ha
senso continuare come se nulla fosse.

Quello è un errore hard.

Se invece fallisce un layer accessorio, come `Flatpak`, il sistema base può
essere comunque stato aggiornato correttamente.

Quello è un errore soft.

Questa distinzione è molto importante da imparare:

- non tutti i fallimenti hanno lo stesso peso.

## 4. Perché supportiamo il dry-run

`--dry-run` serve a una cosa molto precisa:

- vedere il flusso prima di eseguirlo davvero.

È utile per tre motivi:

- didattica;
- debugging;
- fiducia nel processo.

Uno script importante che non puoi ispezionare con calma prima di lanciarlo è
uno script che ti educa male.

## 5. Perché non fa ancora tutto

La prima versione di `update-all` non chiude tutta la pipeline finale EFI.

Questo è intenzionale.

La regola del progetto è:

- prima rendiamo chiaro il modello;
- poi completiamo l'automazione.

Meglio uno script incompleto ma leggibile, che uno script apparentemente
"completo" ma opaco.

## 6. La regola finale da ricordare

`update-all` non è un posto dove si nasconde la complessità.

È un posto dove la complessità viene messa in ordine.
