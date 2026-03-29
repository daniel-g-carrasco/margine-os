# Perché gli snapshot non bastano da soli

Questa nota spiega una cosa molto importante da capire presto:

- avere `Btrfs + Snapper` non significa che tutto il sistema sia automaticamente
  ripristinabile in un solo gesto.

## 1. Cosa proteggono gli snapshot

Gli snapshot di `Snapper` proteggono il subvolume che hai deciso di
snapshotare.

Nel nostro progetto, il focus è:

- root `Btrfs`

Quindi proteggono molto bene:

- `/etc`
- `/usr`
- parte strutturale di `/var`
- lo stato del sistema nel filesystem root

## 2. Cosa NON proteggono da soli

Non proteggono automaticamente:

- la `ESP`
- i file EFI
- le `UKI`
- il binario `Limine`
- la configurazione EFI già copiata sulla partizione di boot

Questo succede per un motivo semplice:

- la `ESP` non vive dentro il subvolume root snapshotato.

## 3. Perché questa distinzione è fondamentale

Se non la capisci bene, rischi di fare un errore pericoloso:

- credere che uno snapshot root basti a riportare indietro l'intera macchina.

Non basta.

Lo snapshot ti riporta indietro il sistema root.
Il boot path, invece, va:

- mantenuto coerente;
- oppure rigenerato.

## 4. E allora a cosa servono davvero gli snapshot?

Servono eccome.
Servono tantissimo.

Ma servono per il loro compito giusto:

- recuperare il sistema root;
- confrontare stati;
- tornare indietro dopo update o modifiche rischiose;
- fornire una base forte per la recovery.

Non servono, da soli, a risolvere tutta la catena di boot.

## 5. Dove entra in gioco update-all

Qui entra in gioco il disegno corretto della pipeline.

`snap-pac` crea snapshot pre/post durante `pacman`.
Poi `update-all` deve occuparsi del resto:

- rigenerare `UKI`
- aggiornare `limine.conf`
- fare `limine enroll-config`
- firmare
- verificare

Questa è una lezione importante:

- la recovery buona non si affida a un solo strumento;
- mette insieme strumenti con responsabilità diverse.

## 6. Perché non attiviamo subito le timeline

Perché nella `v1` vogliamo prima massimizzare il segnale.

Il valore più grande oggi viene da:

- snapshot pre/post degli update;
- snapshot manuali prima di interventi rischiosi.

Le timeline automatiche sul root rischiano di creare molto rumore prima ancora
che abbiamo chiuso bene il resto della pipeline.

## 7. La regola finale da ricordare

Se un giorno ti chiedi:

- "ho uno snapshot, quindi sono totalmente al sicuro?"

la risposta corretta è:

- sei molto più al sicuro sul root filesystem;
- ma la coerenza del boot path va comunque gestita.

Questa distinzione è uno dei punti che separa un setup "appariscente" da una
architettura davvero solida.
