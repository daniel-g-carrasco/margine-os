# ADR 0011 - Enrollment della config Limine e firma della catena EFI

## Stato

Accettato

## Perché esiste questo ADR

Con ADR 0010 abbiamo definito come gli artefatti arrivano sulla `ESP`.

Mancava però l'ultimo pezzo della trust chain:

- come si protegge `limine.conf`;
- quando si modifica `BOOTX64.EFI`;
- quando si firma davvero la catena EFI;
- come si collega tutto a `update-all`.

## Problema da risolvere

Con `Limine`, la sola firma del binario EFI non basta a proteggere anche la
configurazione.

La documentazione ufficiale di Limine raccomanda infatti:

- di calcolare il `BLAKE2B` di `limine.conf`;
- di incorporarlo nel binario EFI con `limine enroll-config`;
- di firmare poi il binario risultante con Secure Boot.

Se si firma `BOOTX64.EFI` prima di `enroll-config`, la firma viene invalidata.

## Decisione

Per `Margine v1`, il refresh della trust chain EFI segue questa sequenza:

1. si generano gli artefatti di boot fuori dalla `ESP`;
2. si fa il deploy sulla `ESP`;
3. si calcola il `BLAKE2B` del `limine.conf` già deployato;
4. si esegue `limine enroll-config` sul `BOOTX64.EFI` già deployato;
5. si firma con `sbctl` il `BOOTX64.EFI` risultante;
6. si firmano con `sbctl` anche le `UKI` presenti sulla `ESP`;
7. si esegue `sbctl verify` come controllo finale.

## Regola fondamentale

L'enrollment della config e la firma devono avvenire sugli artefatti finali
presenti sulla `ESP`, non sulle copie di staging.

Motivo:

- `limine enroll-config` modifica in-place il binario EFI;
- la firma valida deve corrispondere al file effettivamente bootato dal
  firmware.

## Regola di sequenza

L'ordine corretto è:

1. deploy;
2. enrollment del digest config;
3. firma;
4. verifica.

Non è ammesso invertire `enroll-config` e `sbctl sign`.

## Regola di rientro

Ogni volta che cambia `limine.conf`, il `BOOTX64.EFI` deve essere:

1. reenrolled con il nuovo hash;
2. rifirmato.

Questa non è una stranezza di `Margine`.
È una proprietà del modello di sicurezza di `Limine`.

## Ruolo di sbctl

In `Margine v1`, `sbctl` gestisce:

- creazione delle chiavi;
- enrollment delle chiavi nel firmware;
- firma dei binari EFI;
- verifica della catena firmata.

La creazione/enrollment delle chiavi non è parte del ciclo di update ordinario.
La firma e la verifica invece sì.

## Integrazione con update-all

`update-all` può orchestrare anche il refresh della trust chain, ma solo dopo
il deploy su `ESP`.

La divisione dei ruoli diventa quindi:

- `generate-limine-config`: produce `limine.conf`;
- `deploy-boot-artifacts`: copia gli artefatti sulla `ESP`;
- `refresh-efi-trust`: enrolla la config e firma la catena EFI;
- `update-all`: orchestra l'ordine corretto.

## Conseguenze pratiche

Questa scelta ci dà:

- una trust chain leggibile;
- una relazione esplicita tra config deployata e binario firmato;
- un processo ripetibile dopo ogni update del kernel o del bootloader;
- meno spazio per errori manuali.

## Per uno studente: la versione semplice

Pensa così:

- `limine.conf` è importante quanto il bootloader;
- `Limine` controlla questa config tramite il suo hash;
- quell'hash viene scritto dentro `BOOTX64.EFI`;
- quindi il file cambia;
- quindi la firma va fatta dopo.

La regola mentale da ricordare è:

`deploy -> enroll-config -> sign -> verify`
