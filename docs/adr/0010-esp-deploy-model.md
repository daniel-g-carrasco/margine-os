# ADR 0010 - Modello di deploy degli artefatti di boot sulla ESP

## Stato

Accettato

## Perché esiste questo ADR

Finora abbiamo già:

- generazione di `limine.conf`
- orchestrazione di `update-all`
- strategia `UKI`

Mancava però un principio fondamentale:

- come gli artefatti generati arrivano davvero sulla `ESP`

Questa fase è delicata.
Se la progetti male, ottieni un boot path fragile.

## Problema da risolvere

La `ESP` è un luogo speciale:

- è fuori dagli snapshot root;
- contiene file critici per l'avvio;
- sulla macchina corrente contiene già artefatti esistenti.

Quindi non vogliamo:

- editare file direttamente sulla `ESP`;
- fare sovrascritture opache;
- assumere che la `ESP` sia vuota;
- introdurre script distruttivi.

## Decisione

Per `Margine v1`, il deploy su `ESP` segue questa regola:

1. gli artefatti si generano fuori dalla `ESP`;
2. il deploy avviene tramite uno script dedicato;
3. i file esistenti vengono backuppati prima della sovrascrittura;
4. in `v1` non si fanno rimozioni automatiche aggressive.

## Artefatti previsti

I target canonici sono:

- `EFI/BOOT/BOOTX64.EFI`
- `EFI/BOOT/limine.conf`
- `EFI/Linux/margine-linux.efi`
- `EFI/Linux/margine-linux-fallback.efi`
- `EFI/Linux/margine-recovery.efi`

## Regola di staging

Il file finale sulla `ESP` non è la sorgente autorevole.

La sorgente autorevole resta:

- il template o gli output generati fuori dalla `ESP`

Questo implica che il deploy deve copiare artefatti già pronti, non costruirli
mentre scrive sulla partizione di boot.

## Regola di backup

Ogni file target già presente e destinato a essere sovrascritto deve essere
copiato in una directory di backup prima del deploy.

Questo backup deve:

- essere separato dalla `ESP`;
- conservare la struttura relativa dei path;
- essere ispezionabile dall'utente.

## Regola di prudenza

Nella `v1`, il deploy:

- copia e aggiorna;
- non ripulisce automaticamente la `ESP` da file sconosciuti.

Motivo:

- prima vogliamo un deploy affidabile;
- poi, semmai, una pulizia più intelligente.

## Integrazione con update-all

`update-all` può invocare il deploy se riceve:

- il path della `ESP`
- e i path degli artefatti necessari

Questo mantiene una separazione sana:

- `update-all` orchestra;
- il deploy script installa sulla `ESP`.

## Conseguenze pratiche

Questa scelta ci dà:

- deploy leggibile;
- rischio ridotto;
- possibilità di capire cosa è stato sovrascritto;
- base buona per aggiungere dopo `limine enroll-config` e firma finale.

## Per uno studente: la versione semplice

Se lo spieghiamo in modo diretto:

- non si scrive a mano sulla `ESP`;
- si genera fuori;
- si fa backup;
- poi si installa in modo deterministico.

Questo è il modo corretto di trattare un boot path serio.
