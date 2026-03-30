# Perche' il tooling da terminale merita un layer dedicato

Quando costruisci un sistema tuo, c'e' un errore molto comune:

- pensare che i tool da terminale siano \"sottintesi\"

In realta' non lo sono.

Tra:

- un sistema che ha solo Arch di base;
- e un sistema pensato per lavorare davvero;

la differenza spesso sta proprio qui.

## Esempio semplice

`tmux`, `ripgrep`, `fd`, `jq`, `htop`, `radeontop`, `opencode`.

Nessuno di questi e' \"ornamentale\".
Definiscono il modo in cui lavori, cerchi, debuggghi e amministri la macchina.

## Perche' non basta dire \"tanto c'e' base\"

Alcuni comandi arrivano gia' con Arch.

Ma se li lasci impliciti:

- il repo non spiega piu' il sistema target;
- non sai piu' quali strumenti consideri davvero essenziali;
- il bootstrap diventa meno leggibile.

## La scelta di Margine

Per questo `Margine` tiene separati:

- base del sistema;
- desktop grafico;
- tooling da terminale e amministrazione.

## Cosa ci guadagni

Quando tra mesi riaprirai il repo, capirai subito:

- quali strumenti servono a lavorare;
- quali servono al desktop;
- quali sono solo dipendenze incidentali.
