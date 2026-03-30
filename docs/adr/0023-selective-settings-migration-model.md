# ADR 0023 - Modello di migrazione selettiva delle configurazioni

## Stato

Accettato

## Contesto

Il progetto ha ormai una base installativa abbastanza matura da poter portare in
`Margine` anche configurazioni nate sulla macchina reale.

Qui nasce un rischio classico:

- copiare tutta la home;
- copiare `/etc` per inerzia;
- trasferire stato, cache, desktop file generati, profili browser o file
  temporanei come se fossero configurazione.

Questo approccio e' l'opposto di quello che vogliamo.

## Decisione

`Margine` adotta un modello di migrazione selettiva basato su:

- allowlist esplicita dei file `home` approvati;
- lista separata delle configurazioni di sistema da riesaminare;
- versionamento nel repo solo dei file che hanno senso come baseline target;
- esclusione esplicita di profili opachi, cache, stato volatile e artefatti
  generati.

## Regole operative

### 1. Home

Un file o directory della home entra nel progetto solo se:

- e' leggibile e spiegabile;
- ha senso su una nuova installazione;
- non contiene stato effimero;
- non dipende da identificatori generati localmente.

Esempi tipici:

- `~/.config/nvim`
- `~/.config/kitty/kitty.conf`
- `~/.config/mimeapps.list`
- `~/.config/user-dirs.*`
- piccoli wrapper in `~/.local/bin`

### 2. Sistema

Le configurazioni fuori dalla home non vengono importate automaticamente.

Vengono invece classificate in una lista di review:

- se sono ancora corrette, si traducono in file target puliti;
- se sono workaround locali o dipendono dal sistema attuale, si riscrivono;
- se sono rumore, si scartano.

### 3. Browser e profili utente

I profili browser completi NON entrano nel repo.

Motivo:

- mischiano impostazioni, cache, stato, estensioni, database e cronologia;
- sono poco didattici;
- sono fragili come baseline riproducibile.

Per i browser si preferiscono:

- policy di sistema;
- file di configurazione chiari;
- provisioning esplicito delle scelte basilari.

### 4. Inventario

`Margine` mantiene:

- una allowlist `home` approvata;
- una lista `system` da riesaminare;
- uno script di inventario che confronta macchina corrente e repo.

## Conseguenze

### Positive

- si evita di trascinare spazzatura nel nuovo sistema;
- la migrazione resta leggibile e didattica;
- app per app diventa chiaro cosa stiamo davvero portando.

### Negative

- serve piu' lavoro iniziale;
- alcune configurazioni vanno ricostruite meglio invece che copiate;
- la migrazione non e' mai "tutto e subito".

## Per uno studente

Migrare bene non significa "fare il backup della home".
Significa distinguere:

- stato personale;
- configurazione utile;
- rumore tecnico.

`Margine` porta solo il secondo.

