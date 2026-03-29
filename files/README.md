# Files

Questa cartella conterrà i file da installare nel sistema target.

Struttura prevista:

- `etc/` per file destinati a `/etc`
- `usr/` per file destinati a `/usr`
- `home/` per file utente da distribuire nella home

Regola:

- nessun file qui dentro deve essere "misterioso";
- ogni file importante deve essere spiegato da un ADR, da una nota didattica,
  oppure da commenti locali chiari.
