# Perche' su Hyprland l'ICC del compositor resta opzionale

Il punto non e' se `Hyprland` supporta oppure no gli ICC.

Li supporta.

Il punto vero e' un altro:

- dove vuoi applicare la trasformazione colore;
- quanto facilmente vuoi poter capire un problema;
- quanto sei sicuro del profilo che stai usando.

## I tre livelli

Nel nostro caso esistono tre livelli distinti:

- il profilo ICC come asset;
- `colord` come registro di sistema;
- il compositor `Hyprland` come possibile punto di applicazione globale.

Questi tre livelli non vanno confusi.

## Perche' non lo attiviamo subito

Un ICC caricato nel compositor cambia il comportamento di tutta la sessione.

Questo significa che, se qualcosa non torna:

- non capisci subito se il problema e' nel profilo;
- non capisci subito se il problema e' nell'applicazione;
- non capisci subito se il problema e' nel compositor.

Per una `v1` didattica e stabile, questa e' una pessima partenza.

## La strategia di Margine

La strategia scelta e' questa:

1. preservare i profili ICC buoni;
2. installare e tenere `colord`;
3. usare prima le applicazioni che supportano davvero il color management;
4. lasciare l'ICC di `Hyprland` come passo successivo e consapevole.

## Cosa significa in pratica

Per ora:

- `darktable` e' il punto principale in cui il profilo display conta davvero;
- il browser non riceve tweak ICC aggressivi;
- `Hyprland` non impone un ICC globale di default.

Poi, quando il flusso sara' validato bene sul monitor reale, potremo aggiungere
la riga `icc` nella configurazione monitor di `Hyprland`.

## Regola mentale giusta

Se stai ancora costruendo il sistema:

- prima rendi affidabili stack e asset;
- poi scegli dove applicare il colore;
- solo alla fine sposti la leva piu' globale.
