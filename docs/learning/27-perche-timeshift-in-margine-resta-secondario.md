# Perché Timeshift in Margine resta secondario

Potrebbe sembrare strano:

- installiamo `Timeshift`;
- ma non lo facciamo diventare il motore principale.

La ragione e' semplice: i progetti seri devono distinguere tra:

- strumento disponibile;
- strumento architettonicamente centrale.

## Chi comanda davvero il rollback

In `Margine` il rollback serio passa da:

- `Snapper`
- `Btrfs`
- `Limine`
- `UKI`

Questo e' il percorso che stiamo progettando e validando.

## Perché non forzare Timeshift

La documentazione ufficiale di `Timeshift` e' chiara:

- la modalita' Btrfs supporta solo layout Ubuntu-style con `@` e `@home`.

Noi abbiamo scelto un layout piu' ricco.

Quindi forzare `Timeshift` come se niente fosse vorrebbe dire:

- ignorare un limite dichiarato;
- creare aspettative sbagliate;
- rischiare un sistema meno comprensibile.

## Allora perché tenerlo?

Perché puo' comunque servire:

- come strumento manuale;
- come utility familiare;
- come extra opzionale, non come cuore del sistema.

## La lezione

Un buon progetto non usa tutti gli strumenti allo stesso livello.
Li mette in gerarchia.

In `Margine`:

- `Snapper` e' il motore del rollback;
- `Timeshift` e' un accessorio prudente.

