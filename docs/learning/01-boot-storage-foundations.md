# Boot, cifratura e snapshot: spiegazione didattica

Questa nota non decide l'architettura.
La decisione ufficiale è nell'ADR 0002.

Questa nota serve a capire i concetti con calma.

## 1. Che cos'è il boot

Quando premi il tasto di accensione, il computer non sa ancora nulla di Linux.

La sequenza, in modo semplificato, è:

1. parte il firmware UEFI;
2. l'UEFI cerca un bootloader;
3. il bootloader avvia il kernel;
4. il kernel porta il sistema fino al root filesystem;
5. da lì parte lo spazio utente.

Se questa catena è confusa, il sistema diventa fragile.
Per questo la prima regola di `Margine` è: catena di boot leggibile.

## 2. Perché `Limine`

`Limine` non è una versione modificata di `systemd-boot`.
È un bootloader diverso, con priorità diverse.

Per noi conta perché:

- ci dà una UX di recovery più forte;
- si presta bene a snapshot bootabili;
- si sposa bene con l'idea di testare e ripristinare rapidamente;
- rende il boot menu uno strumento operativo, non solo un dettaglio tecnico.

Tradotto da studente a studente:

- `systemd-boot` è più lineare;
- `Limine` è più orientato alla recovery e alla gestione del boot in modo più
  ricco.

Noi stiamo scegliendo `Limine` non perché sia "più figo", ma perché risponde
meglio a un requisito reale del progetto.

## 3. Che cos'è una `UKI`

`UKI` significa `Unified Kernel Image`.

In pratica è un'immagine che mette insieme, in modo più ordinato:

- kernel;
- initramfs;
- cmdline;
- metadati utili al boot.

Perché ci piace:

- è più facile da firmare;
- è più facile da ragionare;
- riduce il disordine della fase di avvio.

## 4. Perché `Secure Boot`

`Secure Boot` non serve a "fare scena".
Serve a controllare cosa è autorizzato a partire.

Noi vogliamo tenerlo, ma non a costo di inventarci una catena fragile.

Per questo, nel caso di `Limine`, il punto non è solo "abilitarlo".
Il punto è verificare che tutta la catena sia davvero sotto controllo.

In pratica:

- non basta che il boot "parta";
- deve anche essere chiaro cosa viene firmato;
- deve anche essere chiaro cosa succede quando qualcosa cambia.

## 5. Perché `LUKS2`

`LUKS2` è il contenitore di cifratura del disco.

In termini pratici significa:

- se qualcuno prende fisicamente il portatile spento, i dati non sono leggibili
  banalmente;
- la protezione non dipende solo dal login della sessione.

È la base seria per parlare di sicurezza dei dati.

## 6. Perché `TPM2`

`TPM2` è un chip hardware che può custodire materiale crittografico.

Nel nostro caso ci interessa per sbloccare il disco in modo più comodo, ma senza
rinunciare a un piano di recupero.

Punto chiave:

- `TPM2` non sostituisce la responsabilità;
- `TPM2` aggiunge comodità controllata.

Per questo in `Margine` non useremo mai solo il TPM:

- ci sarà anche una recovery key;
- ci sarà anche una passphrase di emergenza;
- tutto sarà documentato.

## 7. Perché `Btrfs`

`Btrfs` ci interessa per tre motivi:

- snapshot;
- subvolumi;
- flessibilità operativa.

Per un sistema personale che vuoi aggiornare, rompere, capire e ripristinare,
questo è molto utile.

## 8. Perché `Snapper`

`Snapper` non è il filesystem.
È lo strumento che aiuta a gestire bene gli snapshot su `Btrfs`.

Lo scegliamo come base perché:

- è allineato al tipo di progetto che stiamo costruendo;
- è più coerente con un sistema Arch rigoroso;
- si presta bene a una strategia pensata, non improvvisata.

## 9. Perché non `systemd-boot` nella v1

`systemd-boot` non è sbagliato.
Anzi, è molto pulito.

Se scegliessimo solo in base alla semplicità del boot stack, probabilmente
vincerebbe lui.

Ma il progetto ha espresso un requisito più forte:

- recovery semplice;
- snapshot bootabili;
- capacità di tornare indietro in modo molto concreto.

Per questo nella `v1` non scegliamo il bootloader più minimale.
Scegliamo il bootloader che promette la recovery più convincente, a patto di
validarlo bene.

## 10. Cosa dobbiamo validare davvero

La scelta `Limine-first` è seria solo se verifichiamo quattro cose:

1. `Limine` avvia `UKI` in modo affidabile.
2. `Secure Boot` resta sotto il nostro controllo.
3. `TPM2` con `LUKS2` ha un recovery path chiaro.
4. Gli snapshot `Snapper` sono davvero bootabili e ripristinabili.

Questa è una lezione importante:

- una buona architettura non si sceglie solo per intuizione;
- si sceglie, poi si verifica.

## 11. La lezione da portarsi a casa

La cosa importante non è memorizzare i nomi.

La cosa importante è capire il criterio:

- scegliamo il pezzo che risolve meglio il problema vero;
- non confondiamo "più semplice internamente" con "più utile operativamente";
- ogni feature deve essere spiegabile;
- ogni livello deve poter essere modificato a mano;
- ogni comodità deve avere un piano di recovery.
