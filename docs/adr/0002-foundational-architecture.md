# ADR 0002 - Architettura fondativa di Margine

## Stato

Accettato

## Perché esiste questo ADR

Questo è il primo ADR veramente strutturale.
Serve a decidere le fondamenta che influenzano quasi tutto il resto:

- come parte il sistema;
- come viene protetto;
- come si sblocca il disco;
- come si organizzano i dati;
- come si fanno snapshot e rollback.

Se sbagliamo qui, ci portiamo dietro attrito e fragilità in tutte le fasi
successive.

## Requisiti del progetto

La base architetturale deve essere:

- compatibile con `Arch Linux`;
- coerente con `Framework Laptop 13 AMD`;
- adatta a `Hyprland` come ambiente principale;
- orientata a stabilità e manutenzione;
- sicura, ma non inutilmente barocca;
- abbastanza semplice da poter essere capita e modificata a mano da Daniel;
- molto forte sul piano della recovery.

## Problema da risolvere

Ci sono due tensioni principali:

1. vogliamo una base moderna e pulita (`UKI`, `Secure Boot`, `TPM2`, `LUKS2`);
2. vogliamo anche una recovery molto semplice da usare, specialmente tramite
   snapshot bootabili.

In precedenza avevamo dato più peso alla pulizia architetturale.
Dopo chiarimento dei requisiti, è emerso che la semplicità della recovery non è
un vezzo: è un requisito vero del progetto.

## Opzioni considerate

### Opzione A

`systemd-boot` + `UKI` + `sbctl` + `TPM2` + `LUKS2` + `Btrfs` + `Snapper`

Vantaggi:

- è la soluzione più pulita e moderna per Arch;
- si integra molto bene con `Secure Boot`;
- si integra molto bene con `TPM2` via `systemd-cryptenroll`;
- riduce la complessità della catena di boot;
- è molto adatta a un sistema personale mantenuto con disciplina.

Svantaggi:

- il rollback da boot menu non è immediato;
- richiede una recovery più procedurale;
- non valorizza il requisito espresso da Daniel: snapshot bootabili facili da
  usare.

### Opzione B

`Limine` + `UKI` + `Snapper` + `LUKS2` + `TPM2` + `Btrfs`

Vantaggi:

- migliora molto la UX di recovery;
- si presta bene a snapshot bootabili, in linea con il modello adottato da
  Omarchy;
- rende più naturale testare e ripristinare snapshot dal boot;
- risponde meglio al requisito "recovery semplice e concreta".

Svantaggi:

- richiede più validazione sul fronte `Secure Boot`;
- richiede più attenzione nel disegno della trust chain;
- è meno lineare della strada `systemd-boot` se l'unico criterio fosse la
  pulizia del boot stack.

### Opzione C

`GRUB` + `Snapper` + `grub-btrfs`

Vantaggi:

- rollback da menu di boot noto e collaudato;
- ecosistema molto diffuso quando si parla di snapshot avviabili.

Svantaggi:

- non è la direzione architetturale che vogliamo privilegiare;
- catena di boot più pesante;
- meno coerenza con l'obiettivo di tenere il progetto moderno e leggibile.

## Decisione

Per `Margine v1` adottiamo:

- `UEFI` puro;
- `Limine` come bootloader e boot manager principale;
- `UKI` come formato standard di boot;
- `LUKS2` per la cifratura del disco;
- `TPM2` tramite `systemd-cryptenroll`, con fallback umano esplicito;
- `Btrfs` come filesystem principale;
- `Snapper` come motore base per snapshot e rollback;
- `Secure Boot` come obiettivo esplicito della `v1`, ma solo dopo validazione
  rigorosa della catena con `Limine`.

## Chiarimento importante

Questa decisione NON dice:

- "Limine è una versione migliorata di `systemd-boot`";
- "systemd-boot è sbagliato";
- "la pulizia architetturale non conta più".

Dice invece:

- `Limine` e `systemd-boot` sono due bootloader distinti, con priorità diverse;
- per questo progetto, adesso, la recovery semplice pesa più della minimizzazione
  assoluta del boot stack;
- la scelta di `Limine` è accettata solo insieme a un piano serio di validazione
  per `Secure Boot`, `UKI` e `TPM2`.

## Perché Limine in questa v1

La ragione centrale è semplice:

- Daniel considera la recovery semplice una caratteristica molto importante;
- `Limine` rende più naturale un'esperienza con snapshot bootabili;
- Omarchy usa proprio questa direzione per sbloccare una UX di recovery molto
  forte.

Quindi, per `Margine`, `Limine` non entra come vezzo estetico.
Entra come risposta a un requisito operativo reale.

## Condizioni di validazione

La scelta è considerata riuscita solo se verifichiamo tutti questi punti:

1. `Limine` avvia `UKI` firmate in modo affidabile.
2. `Secure Boot` resta effettivamente sotto controllo nostro.
3. `TPM2` con `LUKS2` ha un recovery path pulito e documentato.
4. Gli snapshot `Snapper` sono davvero bootabili e ripristinabili in modo
   coerente.

Se uno di questi quattro punti fallisce in modo strutturale, la fallback
architecture sarà:

- `systemd-boot`
- `UKI`
- `sbctl`
- `LUKS2`
- `TPM2`
- `Btrfs`
- `Snapper`

Quindi la decisione è forte, ma non cieca.

## Implicazioni pratiche

### Boot

La catena di boot sarà pensata così:

1. firmware UEFI;
2. `Limine`;
3. `UKI`;
4. sblocco disco con `LUKS2` e supporto `TPM2`;
5. root su `Btrfs`.

### Sicurezza

La sicurezza non dovrà dipendere da un solo fattore.

Quindi prevediamo:

- sblocco tramite `TPM2` come percorso comodo;
- recovery key;
- passphrase di emergenza;
- documentazione chiara di recovery.

### Snapshot

Gli snapshot saranno progettati come funzione operativa centrale, non come
accessorio.

Quindi:

- layout Btrfs pensato per snapshot sensati;
- hook aggiornamenti pre/post;
- snapshot bootabili come obiettivo esplicito;
- procedura di restore documentata.

### Manutenibilità

Questa scelta è meno minimale della strada `systemd-boot`, ma più aderente ai
requisiti reali di `Margine`.

In altre parole:

- perdiamo un po' di linearità teorica;
- guadagniamo una recovery più forte e più usabile.

## Decisioni rinviate

Questo ADR NON chiude ancora:

- schema esatto delle partizioni;
- schema esatto dei subvolumi Btrfs;
- policy operativa di snapshot automatici;
- dettagli di firma e hook della catena `Limine + UKI + Secure Boot`;
- policy PCR per `TPM2`.

Questi punti verranno affrontati in ADR successivi.

Nota:
- il login path finale è stato poi chiuso in ADR successivi con `greetd +
  tuigreet`, autologin iniziale e `hyprlock`.

## Per uno studente: la versione semplice

Se lo spiegassimo in modo diretto:

- `Limine` è il pezzo che ci dà una recovery più interessante al boot;
- `UKI` è un formato di boot moderno e ordinato;
- `LUKS2` protegge i dati sul disco;
- `TPM2` può aiutare a sbloccare il disco in modo comodo, ma non sostituisce il
  recovery;
- `Btrfs` ci dà snapshot e flessibilità;
- `Snapper` ci aiuta a gestire bene gli snapshot;
- non stiamo scegliendo la strada più minimale;
- stiamo scegliendo la strada che valorizza di più la recovery, ma senza
  rinunciare a rigore e verifiche.

## Riferimenti

- Omarchy, issue ufficiale su `Limine + Snapper`:
  https://github.com/basecamp/omarchy/issues/1068
- Limine, repository ufficiale:
  https://github.com/limine-bootloader/limine
- ArchWiki, panoramica bootloader:
  https://wiki.archlinux.org/title/Boot_loader
- ArchWiki, `Secure Boot`:
  https://wiki.archlinux.org/title/Secure_Boot
- ArchWiki, `systemd-cryptenroll`:
  https://wiki.archlinux.org/title/Systemd-cryptenroll
- ArchWiki, `Snapper`:
  https://wiki.archlinux.org/title/Snapper
