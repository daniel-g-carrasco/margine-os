# ADR 0004 - Matrice di validazione per boot, trust chain e recovery

## Stato

Accettato

## Perché esiste questo ADR

Gli ADR 0002 e 0003 hanno scelto una direzione ambiziosa:

- `Limine`
- `UKI`
- `Secure Boot`
- `LUKS2`
- `TPM2`
- `Btrfs`
- `Snapper`

Questa combinazione è interessante, ma non va trattata come un collage di
feature.

Un sistema del genere è valido solo se reggono insieme tre cose:

- la catena di fiducia;
- la recovery;
- la manutenzione dopo gli aggiornamenti.

Per questo `Margine` adotta una matrice di validazione esplicita.

## Problema da risolvere

Le architetture di boot falliscono spesso in uno di questi modi:

- funzionano solo sulla carta;
- sono sicure ma troppo fragili agli aggiornamenti;
- fanno recovery male;
- fanno recovery bene ma rompono la trust chain;
- dipendono da passaggi manuali troppo opachi.

Il nostro obiettivo non è "abilitare feature".
È dimostrare che la combinazione scelta è sostenibile.

## Decisione

Per `Margine v1`, la catena `Limine + UKI + Secure Boot + TPM2 + Snapper` sarà
considerata riuscita solo se supera cinque gate.

## Gate 1 - UKI affidabili e avviabili

### Ipotesi da validare

`Limine` deve poter avviare in modo affidabile una `UKI` generata con strumenti
standard di Arch.

### Scelta operativa

Partiamo con la soluzione più lineare:

- generazione `UKI` tramite `mkinitcpio`
- una sola linea kernel "prod" nella prima validazione
- kernel command line incorporata nella `UKI`

### Perché questa scelta

- `mkinitcpio` su Arch supporta già `UKI`;
- incorporare la command line nella `UKI` riduce ambiguità;
- meno variabili al primo giro significa validazione più seria.

### Evidenze richieste

- la `UKI` viene generata in modo ripetibile;
- `Limine` la mostra e la avvia;
- il sistema fa boot normale senza file di boot "sparsi";
- la command line effettiva è quella prevista.

### Condizione di fallimento

Fallisce il gate se:

- la generazione `UKI` dipende da workaround opachi;
- `Limine` non la gestisce in modo stabile;
- la boot entry dipende da manipolazioni manuali non ripetibili.

## Gate 2 - Secure Boot sotto il nostro controllo

### Ipotesi da validare

Possiamo usare `Secure Boot` senza delegare la fiducia a una catena che non
controlliamo davvero.

### Scelta operativa

Adottiamo:

- chiavi nostre gestite con `sbctl`
- firma delle `UKI`
- firma dei binari EFI di `Limine`
- mantenimento dei certificati Microsoft se servono per firmware o Option ROM

Non adottiamo nella `v1`:

- `shim`
- `MOK`

salvo necessità reale emersa dai test.

### Perché questa scelta

- `sbctl` è il gestore naturale su Arch;
- tenere il controllo sulle chiavi è un requisito del progetto;
- evitare `shim/MOK` nella `v1` riduce complessità gratuita.

### Evidenze richieste

- `sbctl status` mostra `Secure Boot` attivo;
- `sbctl verify` conferma i file previsti firmati;
- il sistema avvia `Limine` e la `UKI` firmata senza degradare la UX;
- dopo un riavvio reale la macchina resta in modalità coerente con la policy.

### Condizione di fallimento

Fallisce il gate se:

- la firma dei binari non è automatizzabile in modo chiaro;
- aggiornare `Limine` o `UKI` richiede passaggi troppo fragili;
- per far funzionare tutto dobbiamo introdurre una catena più complessa di
  quella che volevamo evitare.

## Gate 3 - TPM2 utile, non fragile

### Ipotesi da validare

`TPM2` deve migliorare l'esperienza di sblocco del disco, senza trasformare ogni
update in una trappola.

### Scelta operativa

Ordine di enrollment:

1. passphrase amministrativa
2. recovery key
3. sblocco `TPM2`

Policy iniziale consigliata:

- PCR `7+11`

Non includiamo nella `v1`, salvo necessità dimostrata:

- PCR `0`
- PCR `2`
- PCR `12`

### Perché questa scelta

Dal manuale di `systemd-cryptenroll`:

- `PCR 7` riflette stato e certificati di `Secure Boot`
- `PCR 11` riflette il contenuto della `UKI`

Lo stesso manuale segnala che PCR come `0` e `2` sono spesso troppo fragili per
gli aggiornamenti. Inoltre, se la command line resta incorporata nella `UKI`,
non abbiamo motivo di partire subito con `PCR 12`.

### Evidenze richieste

- boot normale con sblocco via `TPM2`;
- fallimento corretto dello sblocco se la trust chain cambia in modo rilevante;
- sblocco riuscito con recovery key quando `TPM2` non può unsealare;
- procedura di re-enrollment comprensibile dopo aggiornamenti importanti.

### Condizione di fallimento

Fallisce il gate se:

- aggiornamenti normali rompono troppo spesso l'unseal;
- il recovery umano è ambiguo o incompleto;
- la policy PCR è troppo fragile per un laptop reale.

## Gate 4 - Snapshot davvero bootabili

### Ipotesi da validare

Gli snapshot di `Snapper` devono essere avviabili tramite `Limine` in modo
coerente con il nostro modello di recovery.

### Scelta operativa

La recovery via snapshot deve dimostrare almeno tre cose:

- boot di uno snapshot root noto;
- riconoscibilità chiara dello stato bootato;
- procedura di restore o rollback documentata.

Gli snapshot bootabili sono una feature di recovery, non il percorso normale di
boot.

### Perché questa scelta

Qui si gioca il motivo vero per cui abbiamo scelto `Limine`.
Se gli snapshot non diventano davvero bootabili, stiamo assorbendo complessità
senza incassare il vantaggio principale.

### Evidenze richieste

- creazione di snapshot pre-update e post-update;
- presenza di entry di recovery comprensibili;
- boot riuscito in uno snapshot noto;
- verifica che il sistema dentro lo snapshot corrisponda davvero allo stato
  atteso;
- procedura di ritorno al sistema corrente o di rollback spiegabile.

### Condizione di fallimento

Fallisce il gate se:

- le entry di snapshot risultano troppo fragili;
- la procedura richiede interventi manuali pericolosi su `/boot`;
- la recovery è bella da vedere ma poco affidabile.

## Gate 5 - Aggiornamenti sostenibili

### Ipotesi da validare

La catena completa deve sopravvivere agli aggiornamenti ordinari, non solo al
giorno zero.

### Scelta operativa

Ogni update importante deve poter attraversare questa pipeline:

1. snapshot pre
2. update pacchetti
3. rigenerazione `UKI`
4. rifirma dei binari EFI
5. refresh delle entry di boot/recovery
6. snapshot post
7. reboot di verifica

### Evidenze richieste

- almeno un aggiornamento kernel riuscito end-to-end;
- nessun passaggio essenziale lasciato "a memoria";
- stato `Secure Boot` ancora valido dopo l'update;
- `TPM2` ancora coerente oppure recovery documentata e rapida;
- snapshot di recovery ancora utilizzabili.

### Condizione di fallimento

Fallisce il gate se:

- il sistema è affidabile solo prima del primo kernel update;
- la manutenzione richiede troppa manualità;
- recovery e trust chain divergono dopo gli aggiornamenti.

## Criterio finale di accettazione

L'architettura `Limine-first` resta accettata solo se tutti e cinque i gate
passano.

Se fallisce un gate strutturale, il fallback architetturale resta quello già
definito:

- `systemd-boot`
- `UKI`
- `Secure Boot`
- `LUKS2`
- `TPM2`
- `Btrfs`
- `Snapper`

## Conseguenze pratiche

Questo ADR ci impone disciplina:

- niente attivazioni "a sentimento";
- niente sicurezza non testata;
- niente recovery solo teorica;
- ogni sottosistema dovrà produrre evidenza verificabile.

## Per uno studente: la versione semplice

La domanda non è:

- "riusciamo ad accendere tutto?"

La domanda giusta è:

- "questa catena continua a funzionare bene anche dopo errori, aggiornamenti e
  recovery?"

Questa matrice serve esattamente a questo:

- prima dimostriamo che il design regge;
- poi lo trasformiamo in installer e automazione.

## Riferimenti

- `systemd-cryptenroll(1)`:
  man locale
- `systemd-stub(7)`:
  man locale
- `mkinitcpio(8)`:
  man locale
- `sbctl(8)`:
  https://man.archlinux.org/man/sbctl.8.en
- `limine` pacchetto Arch:
  output locale di `pacman -Si limine`
- Limine, repository ufficiale:
  https://github.com/limine-bootloader/limine
