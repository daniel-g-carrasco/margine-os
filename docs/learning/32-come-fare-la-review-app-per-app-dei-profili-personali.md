# Come fare la review app-per-app dei profili personali

Questa e' la procedura da seguire ogni volta che vuoi capire se il profilo di
una applicazione va:

- versionato;
- escluso;
- oppure rivisto in un secondo momento.

## Passo 1: trova dove l'app salva davvero i dati

Non fermarti a `~/.config`.

Controlla sempre anche:

- `~/.local/share`
- `~/.mozilla`
- `~/.thunderbird`
- directory nascoste dedicate come `~/.koofr`

Perche' molte applicazioni tengono il profilo vero fuori da `~/.config`.

## Passo 2: distingui config da stato

La domanda giusta non e':

- \"mi serve questa app?\"

La domanda giusta e':

- \"questo file spiega una preferenza utile o contiene solo stato locale?\"

Segnali di stato locale:

- cache;
- log;
- database sqlite;
- lockfile;
- geometria finestre;
- sessioni recenti;
- token;
- chiavi;
- percorsi macchina-specifici.

## Passo 3: scegli uno dei tre esiti

Per ogni app devi arrivare a uno di questi tre esiti:

### A. Versiona

Usalo quando il contenuto e':

- leggibile;
- portabile;
- didattico;
- utile su una installazione nuova.

### B. Non migrare

Usalo quando il contenuto e':

- personale;
- segreto;
- volatile;
- generato;
- troppo legato alla macchina corrente.

### C. Rivedi piu' avanti

Usalo quando:

- la struttura e' promettente;
- ma oggi non c'e' ancora un sottoinsieme pulito da estrarre.

## Passo 4: se versioni, versiona solo il sottoinsieme giusto

Quasi mai si versiona una directory intera.

Di solito si versiona un sottoinsieme, per esempio:

- stili;
- template;
- preset;
- un singolo file di config ragionato.

## Passo 5: aggiorna i tre posti giusti nel repo

Quando una decisione e' chiusa, aggiorna sempre:

1. l'inventario/review app;
2. l'allowlist `home-approved.txt` se qualcosa entra davvero;
3. il provisioner relativo, se il file va davvero installato.

## Passo 6: non confondere backup e baseline

Una cosa puo' essere importantissima per te e comunque non entrare in
`Margine`.

Esempio:

- il profilo `Thunderbird` e' prezioso;
- ma non e' baseline di sistema.

Quindi:

- lo fai rientrare nella strategia backup/migrazione personale;
- non nella baseline riproducibile del sistema.

## Regola finale

Se un profilo ti fa dire:

- \"questa roba mi serve tantissimo\"

non hai ancora deciso nulla.

Devi ancora capire se:

- e' configurazione;
- e' dato personale;
- oppure e' rumore.
