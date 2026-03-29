# ADR 0012 - Bootstrap di Secure Boot con sbctl

## Stato

Accettato

## Perché esiste questo ADR

Finora abbiamo definito:

- come generare `limine.conf`;
- come deployare gli artefatti sulla `ESP`;
- come enrollare la config Limine e firmare la catena EFI.

Mancava però un punto fondamentale:

- come si inizializza davvero `Secure Boot` su una macchina nuova.

## Problema da risolvere

`update-all` non è il posto giusto per creare chiavi o enrollarle nel firmware.

Quelle operazioni:

- sono rare;
- possono richiedere `Setup Mode` nel firmware;
- hanno un profilo di rischio diverso dal normale update del sistema.

Serve quindi un flusso separato, esplicito e didattico.

## Decisione

Per `Margine v1`, il bootstrap di `Secure Boot` viene gestito con `sbctl` in un
percorso separato da `update-all`.

La sequenza canonica è:

1. verificare stato UEFI e `Setup Mode`;
2. creare le chiavi con `sbctl create-keys`, se mancanti;
3. enrollare le chiavi con `sbctl enroll-keys -m`;
4. refreshare la trust chain EFI;
5. riavviare;
6. verificare `sbctl status`.

## Regola di Setup Mode

Il bootstrap non deve tentare di aggirare il firmware.

Se la macchina non è in `Setup Mode`, il provisioning deve fermarsi e chiedere
all'utente di:

- riavviare nel firmware;
- entrare nel menu Secure Boot;
- cancellare almeno la `PK` o comunque portare la macchina in `Setup Mode`.

In `Margine v1` non usiamo opzioni aggressive tipo `--yolo`.

## Regola Microsoft

Per l'enrollment usiamo di default:

```bash
sbctl enroll-keys -m
```

Motivo:

- `sbctl` raccomanda di includere i certificati Microsoft per ridurre i rischi
  legati a Option ROM e firmware firmati dal vendor.

## Regola chiavi

In `Margine v1`, le chiavi `sbctl` restano del tipo predefinito `file`.

Motivi:

- root è già cifrata con `LUKS2`;
- il modello è più semplice da capire e da debuggare;
- non vogliamo intrecciare da subito due usi diversi del `TPM`:
  - sblocco `LUKS2`;
  - protezione delle chiavi `Secure Boot`.

Le chiavi `TPM` di `sbctl` restano un possibile esperimento futuro, non la base
della `v1`.

## Regola export

L'export di chiavi private non è automatico.

Se l'utente vuole esportarle, deve farlo in modo esplicito e consapevole.

Motivo:

- esportare chiavi di `Secure Boot` è un'operazione sensibile;
- non vogliamo generare copie extra senza una decisione chiara.

## Separazione dei ruoli

Per `Margine` la divisione corretta diventa:

- `provision-secure-boot`: bootstrap iniziale delle chiavi e dell'enrollment;
- `refresh-efi-trust`: refresh della catena EFI già deployata;
- `update-all`: manutenzione ordinaria del sistema.

## Conseguenze pratiche

Questa scelta ci dà:

- un bootstrap leggibile;
- meno rischio di mischiare update ordinari e operazioni firmware;
- un recovery path più chiaro se qualcosa va storto;
- una base didattica solida.

## Per uno studente: la versione semplice

Pensa a `Secure Boot` come a due problemi diversi:

1. chi decide di chi fidarsi;
2. quali file vengono effettivamente firmati.

`sbctl create-keys` e `sbctl enroll-keys` risolvono il primo problema.

`refresh-efi-trust` risolve il secondo.

È per questo che i due flussi devono restare separati.
