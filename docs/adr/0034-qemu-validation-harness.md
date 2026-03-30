# ADR 0034 - Harness QEMU per validazione installativa

## Stato

Accettato

## Problema

Una validazione seria di `Margine` non va fatta prima sul laptop reale.

Prima serve un ambiente che permetta di testare:

- live ISO Arch;
- disco vuoto;
- firmware UEFI;
- reboot senza rischi;
- ciclo completo installazione -> primo boot.

## Decisione

Introduciamo un harness di validazione basato su:

- `QEMU`
- `OVMF`
- Arch ISO ufficiale

Lo scopo non e' sostituire la prova sul ferro vero, ma diventare il primo gate
obbligatorio prima di toccare il laptop reale.

## Conseguenze

- i regressi nel bootstrap diventano piu' visibili;
- il testing iniziale resta ripetibile;
- il rischio sul sistema reale si abbassa molto.
