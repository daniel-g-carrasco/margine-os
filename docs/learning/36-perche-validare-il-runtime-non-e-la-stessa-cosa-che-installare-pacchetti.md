# Perche' validare il runtime non e' la stessa cosa che installare pacchetti

Quando un progetto cresce, e' facile cadere in questa illusione:

- "se il pacchetto e' nel manifest, allora il sottosistema e' a posto"

Non e' vero.

## Tre livelli diversi

Per ogni sottosistema hai almeno tre livelli:

1. pacchetto installato
2. servizio o configurazione attiva
3. comportamento reale sull'hardware

## Esempio semplice

Puoi avere:

- `fprintd` installato
- il hook di resume presente
- e comunque trovare errori reali durante la sospensione

Oppure:

- `snapper` installato
- `/.snapshots` montato
- ma nessuna config vera o snapshot utili

## La regola di Margine

Per questo `Margine` vuole sia:

- script di bootstrap;
- sia script di validazione runtime.

Gli script di installazione dicono:

- cosa dovrebbe esserci

Gli script di validazione dicono:

- cosa sta davvero funzionando

## Per uno studente

Installare e validare sono due fasi diverse.

Se le confondi, costruisci sistemi che sembrano completi nei file, ma si
rompono appena li usi davvero.
