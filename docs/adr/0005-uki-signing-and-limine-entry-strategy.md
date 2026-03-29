# ADR 0005 - Strategia per UKI, firme e entry Limine

## Stato

Accettato

## Perché esiste questo ADR

Gli ADR precedenti hanno fissato:

- il bootloader (`Limine`);
- il formato di boot (`UKI`);
- la catena di fiducia (`Secure Boot`, `TPM2`);
- il layout storage (`LUKS2`, `Btrfs`, `Snapper`).

Mancava però la parte operativa più importante:

- dove vivono i file di boot;
- come vengono generate le `UKI`;
- cosa viene firmato;
- come si distinguono boot normale e recovery;
- come si conciliano snapshot bootabili e politica `TPM2`.

## Problema da risolvere

C'è una tensione tecnica reale:

- per il boot quotidiano vogliamo una catena stabile, semplice e poco fragile;
- per la recovery snapshot-friendly vogliamo invece poter cambiare la root bootata
  in modo esplicito.

Con `systemd-stub`, se una `UKI` contiene una `.cmdline` incorporata e
`Secure Boot` è attivo, gli override della kernel command line via bootloader
vengono ignorati.

Questo è ottimo per il boot normale, ma rende meno naturale una recovery basata
su snapshot diversi.

## Decisione

Per `Margine v1` adottiamo una strategia a due percorsi:

1. percorso `prod`, stabile e TPM-friendly;
2. percorso `recovery`, flessibile e snapshot-friendly.

Questa separazione è intenzionale.
Non è ridondanza: è gestione corretta di due casi d'uso diversi.

## Percorso prod

### File previsti

- `ESP/EFI/BOOT/BOOTX64.EFI` -> binario `Limine` firmato
- `ESP/EFI/BOOT/limine.conf` -> configurazione principale
- `ESP/EFI/Linux/margine-linux.efi` -> `UKI` principale firmata
- `ESP/EFI/Linux/margine-linux-fallback.efi` -> `UKI` fallback firmata

### Generazione

Le `UKI` di produzione saranno generate con `mkinitcpio`.

La command line di produzione sarà incorporata nella `UKI`, partendo da:

- `/etc/kernel/cmdline`

### Motivo

Questo ci dà:

- boot ripetibile;
- meno ambiguità;
- una catena `TPM2` più leggibile;
- minor dipendenza da parametri passati al volo dal bootloader.

### Uso previsto

Questo è il percorso usato per:

- boot quotidiano;
- fallback kernel ordinario;
- validazione stabile di `TPM2`.

## Percorso recovery

### File previsti

- `ESP/EFI/Linux/margine-recovery.efi` -> `UKI` di recovery firmata

### Generazione

La `UKI` di recovery sarà costruita senza command line incorporata.

Le entry `Limine` di recovery passeranno quindi la command line al momento del
boot.

### Motivo

Questo permette di cambiare in modo esplicito:

- `rootflags=subvol=...`
- target snapshot
- eventuali parametri di manutenzione

senza dover rigenerare una `UKI` diversa per ogni snapshot.

### Uso previsto

Questo percorso è pensato per:

- boot di snapshot `Snapper`;
- manutenzione;
- recovery ragionata;
- boot di emergenza.

### Regola di sicurezza importante

Nel percorso recovery NON assumiamo come requisito il comodo sblocco automatico
via `TPM2`.

Qui il percorso umano corretto è:

- recovery key;
- oppure passphrase amministrativa.

Questo è accettabile, perché la recovery non è il path ottimizzato per la
frizione minima.
È il path ottimizzato per rientrare in controllo.

## Strategia per TPM2

La politica `TPM2` iniziale resta:

- `PCR 7+11`

ma solo per il percorso `prod`.

Motivo:

- `PCR 7` lega lo sblocco allo stato `Secure Boot`;
- `PCR 11` lega lo sblocco al contenuto della `UKI` bootata.

Non usiamo `PCR 12` nel percorso `prod`, perché non vogliamo dipendere da una
command line esterna.

Nel percorso `recovery`, dove la command line arriva da `Limine`, accettiamo
che il boot possa richiedere il fallback umano.

## Strategia per Secure Boot

Adottiamo:

- chiavi proprietarie gestite con `sbctl`;
- firma delle `UKI`;
- firma del binario EFI di `Limine`.

In più, seguendo la documentazione ufficiale di `Limine`, il file
`limine.conf` dovrà essere vincolato al binario EFI tramite:

- `limine enroll-config`

Questo è fondamentale.

Firmare il solo binario EFI senza proteggere anche la configurazione
significherebbe lasciare scoperto il file che decide:

- quali entry esistono;
- quali path vengono usate;
- quali parametri di boot vengono passati.

## Posizionamento dei file

### Limine

`Limine` sarà installato nel percorso fallback UEFI:

- `ESP/EFI/BOOT/BOOTX64.EFI`

La configurazione principale vivrà accanto al binario:

- `ESP/EFI/BOOT/limine.conf`

Questa scelta sfrutta direttamente il comportamento documentato da `Limine`,
che su UEFI cerca prima il config file accanto al proprio EFI executable.

### UKI

Le `UKI` vivranno in:

- `ESP/EFI/Linux/`

Motivo:

- percorso chiaro e standardizzato;
- separa il boot manager dai payload di boot;
- resta coerente con l'ecosistema moderno delle `UKI`.

## Struttura logica delle entry Limine

La configurazione `Limine` distinguerà almeno tre gruppi:

- `Margine`
- `Fallback`
- `Recovery`

### Entry normali

Le entry normali useranno:

- `protocol: efi`
- `path: boot():/EFI/Linux/margine-linux.efi`

oppure:

- `path: boot():/EFI/Linux/margine-linux-fallback.efi`

### Entry recovery

Le entry recovery useranno:

- `protocol: efi`
- `path: boot():/EFI/Linux/margine-recovery.efi`
- `cmdline: ...`

con parametri mirati allo snapshot o al contesto di manutenzione.

## Config statica e parti generate

`limine.conf` non dovrà essere mantenuto tutto a mano.

Adottiamo questa regola:

- intestazione e entry base versionate nel repository;
- sezione recovery generata automaticamente.

In pratica:

- una parte del file è stabile;
- una parte dipende dagli snapshot disponibili.

Questo evita due errori opposti:

- configurazione completamente manuale e fragile;
- configurazione completamente opaca e non leggibile.

## Pipeline di update attesa

Dopo ogni aggiornamento rilevante del boot path, la pipeline dovrà essere:

1. snapshot pre-update
2. rigenerazione `UKI` normali
3. rigenerazione `UKI` recovery, se necessario
4. copia/refresh del binario `Limine`
5. generazione di `limine.conf`
6. `limine enroll-config`
7. firma con `sbctl`
8. verifica firme
9. snapshot post-update

## Conseguenze pratiche

Questa scelta ci dà un compromesso forte:

- boot normale pulito e stabile;
- recovery più flessibile;
- nessun obbligo di generare una `UKI` diversa per ogni snapshot;
- `TPM2` concentrato dove ha davvero senso;
- recovery ancora possibile anche quando la trust chain "comoda" non è
  disponibile.

## Cosa NON facciamo nella v1

Non facciamo, per ora:

- una `UKI` diversa per ogni snapshot;
- un design che pretende `TPM2` seamless anche nella recovery;
- una dipendenza da `shim/MOK`;
- una configurazione `Limine` editata solo a mano direttamente sulla `ESP`.

## Per uno studente: la versione semplice

Se lo diciamo in modo molto diretto:

- il boot di tutti i giorni deve essere stabile;
- la recovery deve essere flessibile;
- non è obbligatorio che siano lo stesso percorso tecnico.

Per questo usiamo:

- `UKI` con command line incorporata per il boot normale;
- `UKI` recovery più flessibile per snapshot e manutenzione.

Questa è una vera decisione architetturale:

- non massimizza la purezza teorica;
- massimizza il controllo operativo.

## Riferimenti

- `mkinitcpio(8)`:
  man locale
- `systemd-stub(7)`:
  man locale
- `systemd-cryptenroll(1)`:
  man locale
- `sbctl(8)`:
  https://man.archlinux.org/man/sbctl.8.en
- `Limine` `CONFIG.md`:
  https://raw.githubusercontent.com/limine-bootloader/limine/v11.x/CONFIG.md
- `Limine` `USAGE.md`:
  https://raw.githubusercontent.com/limine-bootloader/limine/v11.x/USAGE.md
- `Limine` `FAQ.md`:
  https://raw.githubusercontent.com/limine-bootloader/limine/v11.x/FAQ.md
- file list del pacchetto Arch `limine`:
  https://archlinux.org/packages/extra/x86_64/limine/files/
