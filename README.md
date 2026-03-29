# Margine OS

`Margine` è il nome del sistema.
`margine-os` è il nome del repository.

Obiettivo: costruire una base Arch Linux riproducibile, didattica e mantenibile,
orientata a `Hyprland`, `Framework Laptop 13 AMD`, fotografia, affidabilità e
rollback sicuro.

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

Il progetto è iniziato con una decisione metodologica importante:

- si costruirà una distro personale tramite repo riproducibile;
- non si farà un clone indiscriminato della macchina corrente;
- si userà una allowlist concordata da Daniel;
- il primo obiettivo è congelare architettura, scope e priorità.

## Prossimo passo

1. Fissare l'allowlist iniziale.
2. Fissare le scelte architetturali non negoziabili.
3. Eseguire un inventario guidato del sistema attuale.
4. Costruire il primo manifest minimale.
