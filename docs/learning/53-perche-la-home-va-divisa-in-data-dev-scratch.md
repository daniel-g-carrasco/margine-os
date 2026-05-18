# Perche la home va divisa in data, dev e scratch

Una home stabile non dovrebbe dipendere dai nomi scelti dalle applicazioni.

`Downloads`, `Documents`, `Pictures` e le varianti localizzate sono utili come
default storici, ma non spiegano il ciclo di vita dei file. Margine OS usa tre
radici esplicite:

- `~/data` contiene file durevoli e comprensibili da una persona;
- `~/dev` contiene repository e ambienti di sviluppo;
- `~/scratch` contiene materiale eliminabile, cache, scambi e lavori temporanei.

La distinzione riduce ambiguita operative:

- il backup include `data` e di norma esclude `scratch`;
- i repository non si mescolano ai documenti personali;
- i download completi arrivano in un inbox da svuotare;
- gli incompleti e gli scambi temporanei non entrano nel backup;
- photo, audio e video hanno percorsi stabili per applicazioni e strumenti desktop.

Margine OS applica il modello creando directory, XDG user dirs, bookmark GTK e
metadata GIO per le icone. Non sposta dati esistenti, perche migrare documenti
personali e archivi fotografici e una scelta da fare con verifica esplicita.

La regola pratica e semplice: se un file deve sopravvivere e avere significato
fra un anno, sta in `data`; se e codice, sta in `dev`; se puo essere ricreato o
buttato, sta in `scratch`.
