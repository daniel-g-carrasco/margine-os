# Perché migrare non significa clonare la home

Quando si reinstalla un sistema, la tentazione naturale e':

- "copio tutta la home e ho finito".

Sembra comodo, ma di solito e' il modo migliore per:

- trascinare bug;
- tenersi file ormai inutili;
- perdere la comprensione di cosa stia davvero configurando il sistema.

La home contiene di tutto:

- configurazioni utili;
- cache;
- database locali;
- stato temporaneo;
- file generati da app specifiche;
- identificatori casuali.

In `Margine` non vogliamo trattare tutto questo come se fosse equivalente.

## Il criterio corretto

La domanda non e':

- "questo file esiste?"

La domanda corretta e':

- "questo file merita di diventare parte del sistema target?"

Se la risposta e' si', il file viene:

- capito;
- ripulito;
- versionato.

Se la risposta e' no, il file resta fuori.

## Esempi

### Da migrare

- `~/.config/nvim`
- `~/.config/kitty/kitty.conf`
- `~/.config/user-dirs.dirs`

Perché:

- sono leggibili;
- esprimono preferenze vere;
- hanno senso anche su una macchina nuova.

### Da NON migrare alla cieca

- interi profili browser;
- cache di editor;
- `userapp-*.desktop`;
- workspace storage di VS Code;
- directory `.cache`.

Perché:

- portano dentro rumore e stato opaco;
- non insegnano nulla;
- spesso peggiorano la riproducibilita'.

## Regola pratica

Se un file non sapresti spiegare a voce in due minuti, non dovrebbe entrare in
repo senza review.

