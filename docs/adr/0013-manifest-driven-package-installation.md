# ADR 0013 - Installazione dei pacchetti guidata dai manifest

## Stato

Accettato

## Perché esiste questo ADR

Ora che `Margine` ha manifest separati per:

- base;
- hardware;
- security;
- desktop;
- app;
- font;
- AUR;
- Flatpak;

serve un modo coerente per trasformarli in installazione vera.

## Problema da risolvere

Se i manifest restano solo documentazione, il progetto perde forza.

Se invece li usiamo senza regole, rischiamo di:

- mischiare repo ufficiali, AUR e Flatpak;
- perdere l'ordine dei layer;
- introdurre installazioni poco leggibili;
- rendere `Margine` difficile da mantenere.

## Decisione

Per `Margine v1`, l'installazione dei pacchetti sarà manifest-driven.

Questo significa:

1. i pacchetti ufficiali vengono letti da manifest `*.txt` versionati;
2. i layer ufficiali hanno un ordine esplicito;
3. un piccolo baseline AUR entra nel percorso di default solo dove serve a non
   rompere il desktop target;
4. Flatpak non entra nel percorso di default;
5. le eccezioni AUR non essenziali e Flatpak si abilitano solo con flag
   espliciti.

## Ordine canonico dei layer ufficiali

L'ordine base è:

1. `base-system`
2. `hardware-framework13-amd`
3. `connectivity-stack`
4. `security-and-recovery`
5. `hyprland-core`
6. `toolkit-gtk-qt`
7. `desktop-integration`
8. `apps-core`
9. `apps-photo-audio-video`
10. `fonts`

## Regola AUR

Il manifest `aur-baseline.txt` viene installato automaticamente.

Motivo:

- `Margine` usa `walker` come launcher preferito;
- `walker` richiede `elephant`;
- il workflow screenshot validato usa `hyprcap`;
- senza questi pacchetti il desktop installato sarebbe incoerente rispetto alla
  baseline dichiarata.

Il manifest `aur-exceptions.txt` invece non viene installato automaticamente.

Motivo:

- vogliamo che il percorso standard resti il piu' possibile ancorato ai repo
  ufficiali;
- le eccezioni AUR non essenziali devono restare una scelta consapevole.

## Regola Flatpak

Il manifest `flatpaks/apps.txt` non viene installato automaticamente.

Motivo:

- Flatpak è un layer diverso da `pacman`;
- vogliamo evitare che entri "di nascosto" nel bootstrap base.

## Regola di deduplicazione

Se lo stesso pacchetto finisce in più manifest selezionati, lo script lo
installa una sola volta.

Questo rende i manifest più tolleranti senza degradare l'esecuzione.

## Regola di leggibilità

Lo script installativo deve:

- supportare `dry-run`;
- poter mostrare i layer disponibili;
- poter installare solo alcuni layer;
- restare piccolo e leggibile.

## Conseguenze pratiche

Questa scelta ci dà:

- un bootstrap iniziale già utile;
- manifest che diventano davvero eseguibili;
- un confine chiaro tra ufficiale, AUR di baseline, AUR opzionale e Flatpak;
- una base buona per lo script da live ISO.

## Per uno studente: la versione semplice

Pensa ai manifest come a una distinta base.

Lo script non deve "decidere" cosa installare.
Deve solo:

1. leggere i manifest giusti;
2. rispettare l'ordine;
3. usare il gestore corretto;
4. non mescolare i mondi per sbaglio.
