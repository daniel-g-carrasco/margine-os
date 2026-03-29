# ADR 0008 - Policy snapshot e aggiornamento del sistema

## Stato

Accettato

## Perché esiste questo ADR

Ora che il progetto ha:

- `Btrfs`
- `Snapper`
- `Limine`
- `UKI`
- `ESP` separata

serve decidere come vogliamo usare davvero gli snapshot durante gli update.

La domanda corretta non è:

- "vogliamo gli snapshot?"

Quella è già chiusa.

La domanda vera è:

- "quali snapshot facciamo, quando, con quale strumento, e per quali percorsi?"

## Problema da risolvere

Ci sono quattro esigenze da tenere insieme:

1. avere snapshot pre/post durante gli update pacman;
2. non dipendere da una sola abitudine manuale dell'utente;
3. non riempire il sistema di snapshot rumorosi e poco utili;
4. non illudersi che gli snapshot Btrfs coprano anche la `ESP`.

Quest'ultimo punto è cruciale:

- gli snapshot di `Snapper` proteggono il root `Btrfs`;
- non proteggono automaticamente `ESP/EFI/...`, che vive fuori dal volume
  snapshotato.

## Decisione

Per `Margine v1` adottiamo questa politica.

## 1. Strumento base

Adottiamo:

- `snapper`
- `snap-pac`

Motivo:

- `snapper` è il motore di snapshot e cleanup;
- `snap-pac` è il safety net che crea snapshot pre/post per le transazioni
  `pacman`, indipendentemente da come `pacman` venga invocato.

Questo è importante perché evita una fragilità molto comune:

- perdere gli snapshot solo perché una volta si è aggiornato con `pacman`
  diretto invece che con lo script "ufficiale".

## 2. Configurazione snapshotata in automatico

Nella `v1` snapshotiamo in automatico solo:

- configurazione `root`

Non snapshotiamo in automatico:

- `home`
- `data`
- subvolumi per VM
- subvolumi per container

Motivo:

- gli snapshot automatici servono soprattutto alla recovery del sistema;
- i dati utente e i workload ad alta mutazione hanno politiche diverse.

## 3. Tipo di snapshot automatici

Gli snapshot automatici obbligatori nella `v1` sono:

- pre/post delle transazioni `pacman`

Questi snapshot saranno il percorso normale di recovery dopo update.

## 4. Timeline

Nella `v1` disabilitiamo le timeline automatiche sul root.

Scelta:

- `TIMELINE_CREATE=no`
- `TIMELINE_CLEANUP=no`

Motivo:

- vogliamo snapshot ad alto segnale;
- il valore principale oggi è la recovery da update e manutenzione;
- le timeline orarie sul root generano rapidamente rumore.

Questo non esclude che in futuro si possano attivare.
Significa solo che non sono parte della baseline.

## 5. Cleanup

Manteniamo:

- cleanup `number`
- cleanup `empty-pre-post`

Politica iniziale consigliata per `root`:

- `NUMBER_CLEANUP=yes`
- `NUMBER_LIMIT=30`
- `NUMBER_LIMIT_IMPORTANT=12`
- `EMPTY_PRE_POST_CLEANUP=yes`

Motivo:

- conserviamo uno storico utile di transazioni;
- teniamo un po' più a lungo gli snapshot considerati importanti;
- eliminiamo automaticamente le coppie pre/post prive di differenze rilevanti.

## 6. Snapshot importanti

Vogliamo che alcuni update siano chiaramente riconoscibili come importanti.

Per questo i pacchetti più sensibili devono marcare gli snapshot con:

- `important=yes`

Pacchetti iniziali consigliati:

- `linux`
- `linux-lts`
- `amd-ucode`
- `systemd`
- `mkinitcpio`
- `cryptsetup`
- `sbctl`
- `limine`
- `snapper`

Inoltre, un:

- `pacman -Syu`

va considerato importante a livello semantico, anche se i pacchetti coinvolti
non vengono filtrati singolarmente.

## 7. Ruolo di update-all

`update-all` resta il percorso canonico di aggiornamento di `Margine`.

Il suo ruolo corretto sarà:

- orchestrare l'update;
- lasciare a `snap-pac` gli snapshot pre/post della transazione `pacman`;
- gestire i passaggi extra di `Margine`, come:
  - rigenerazione `UKI`
  - refresh `limine.conf`
  - `limine enroll-config`
  - firma e verifica

In altre parole:

- `snap-pac` protegge il root durante `pacman`;
- `update-all` protegge la coerenza della pipeline completa di `Margine`.

## 8. Regola fondamentale sulla ESP

Gli snapshot root NON sostituiscono il recovery del boot path.

La `ESP` è fuori dal root snapshot.

Quindi, dopo un update o dopo un rollback, la coerenza di:

- `Limine`
- `UKI`
- config EFI
- firme

va mantenuta tramite rigenerazione deterministica, non aspettandosi che uno
snapshot Btrfs rimetta a posto anche la `ESP`.

Questa è una regola architetturale, non un dettaglio operativo.

## 9. Cosa significa rollback in questa v1

Nella `v1`, rollback significa soprattutto:

- tornare a uno stato precedente del root filesystem;
- poi riallineare o rigenerare il boot path se necessario.

Non significa:

- "tutto il sistema, inclusa la `ESP`, torna indietro magicamente da solo".

## 10. Avvertenza su pacman database

La documentazione di `snap-pac` ricorda un punto importante:

- gli snapshot pre vengono creati dopo l'eventuale sync del database pacman.

Quindi un rollback filesystem dopo `pacman -Syu` non equivale automaticamente a
un "rewind perfetto" dell'intero stato pacman.

Questo significa che gli snapshot sono uno strumento fortissimo di recovery, ma
non vanno scambiati per un lasciapassare verso partial upgrade casuali.

## 11. Snapshot manuali

Per lavori rischiosi che NON passano da `pacman`, la policy corretta è:

- creare uno snapshot manuale esplicito

Esempi:

- modifica pesante di `/etc`
- interventi su auth, boot o cifratura
- migrazioni locali fuori dal normale flusso update

Questo potrà essere orchestrato in futuro da uno script dedicato.

## Per uno studente: la versione semplice

Se la riduciamo all'essenziale:

- `snap-pac` fa da airbag;
- `update-all` fa da direttore d'orchestra;
- gli snapshot proteggono il root;
- la `ESP` si recupera con rigenerazione, non con magia;
- niente timeline rumorose nella `v1`.
