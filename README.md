# Margine OS

`Margine` è il nome del sistema.
`margine-os` è il nome del repository.

Obiettivo: costruire una base Arch Linux riproducibile, didattica e mantenibile,
orientata a `Hyprland`, `Framework Laptop 13 AMD`, fotografia, affidabilità e
rollback sicuro.

`Margine` non è pensato come fork congelato di Arch.
È pensato come un layer riproducibile sopra Arch rolling:

- Arch fornisce i pacchetti aggiornati;
- `Margine` definisce come quei pacchetti vengono selezionati, configurati,
  mantenuti e recuperati.

Il progetto non parte da una ISO custom. Parte da una repo leggibile e
versionata, con:

- documentazione chiara e aggiornata;
- decisioni architetturali tracciate;
- allowlist esplicita di ciò che entra nel sistema;
- script di installazione e post-installazione;
- configurazioni utente e di sistema separate;
- apprendimento continuo: ogni pezzo deve essere spiegabile.

## Principi

- `Official repos first`: AUR solo se davvero necessario e sempre documentato.
- `Allowlist, non dump`: non copiamo la macchina attuale alla cieca.
- `Didattica prima della magia`: ogni scelta deve essere comprensibile.
- `Rollback reale`: snapshot, hook e procedure di ripristino devono essere
  pensati come parte del design.
- `Hyprland-first`: niente GNOME come ambiente principale.
- `Framework-aware`: si segue la documentazione ufficiale/ArchWiki aggiornata
  per AMD, power management, firmware e stabilità.

## Struttura

- `docs/`: obiettivi, roadmap, ADR, note didattiche, stato del progetto.
- `manifests/`: liste curate di pacchetti e componenti da includere.
- `scripts/`: bootstrap, post-install, verifica, manutenzione.
- `files/`: file da installare in `/etc` o nella home.
- `inventory/`: stato macchina, note hardware, mapping servizi/config.

## Stato attuale

Il progetto ha già fissato le fondamenta:

- approccio repo-first;
- Arch rolling come base;
- `Limine + UKI + Secure Boot + TPM2 + Btrfs + Snapper`;
- layout storage target;
- separazione tra boot `prod` e `recovery`;
- primo template versionato di `limine.conf`;
- primo modello completo di deploy e refresh della trust chain EFI;
- primo modello di bootstrap iniziale di Secure Boot con `sbctl`;
- login path `greetd + tuigreet + autologin iniziale + hyprlock`;
- layer di connettivita' e desktop versionati;
- primi layer applicativi e modello di migrazione selettiva.

## Prossimo passo

1. Validare end-to-end snapshot bootabili e rollback operativo.
2. Chiudere app per app le configurazioni ancora aperte.
3. Rifinire il percorso di reinstallazione guidata e mounted-target.
4. Affrontare la fase estetica solo dopo che il sistema e' coerente.
