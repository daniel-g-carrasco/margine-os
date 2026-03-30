# Roadmap

## Fase 0 - Metodo

Obiettivo:
- fissare struttura, naming, principi, documentazione e regole del gioco.

Deliverable:
- repo inizializzata;
- vision;
- roadmap;
- ADR iniziale;
- allowlist iniziale.

## Fase 1 - Architettura

Obiettivo:
- decidere le fondamenta che influenzano tutto il resto.

Temi:
- bootloader;
- Secure Boot;
- TPM2;
- LUKS2;
- layout Btrfs;
- strategia snapshot / rollback;
- session manager;
- policy AUR.

## Fase 2 - Inventario guidato

Obiettivo:
- capire il sistema attuale senza copiarlo alla cieca.

Output:
- lista pacchetti da tenere;
- lista pacchetti da scartare;
- lista servizi da replicare;
- lista configurazioni da riscrivere;
- lista componenti da sostituire.

## Fase 3 - Manifests

Obiettivo:
- creare manifests piccoli e leggibili.

Esempi:
- `base`
- `hardware-framework13-amd`
- `connectivity-stack`
- `security`
- `hyprland-core`
- `desktop-tools`
- `photo`
- `aur-exceptions`

## Fase 4 - Bootstrap

Obiettivo:
- scrivere gli script di installazione da live ISO.

Temi:
- partizionamento;
- cifratura;
- subvolumi;
- `pacstrap`;
- chroot;
- boot;
- utente;
- servizi base.

## Fase 5 - Desktop layer

Obiettivo:
- rendere il sistema usabile, coerente e centralizzato.

Temi:
- config Hyprland;
- `greetd + tuigreet`;
- tema centralizzato in stile Omarchy;
- waybar;
- hyprpaper;
- hyprlock;
- mako;
- walker;
- screenshot e recording;
- audio, bluetooth, rete.

## Fase 6 - Operazioni e rollback

Obiettivo:
- creare un sistema che si aggiorna e si ripristina bene.

Temi:
- `update-all`;
- pre/post snapshots;
- firma kernel/UKI;
- verifica integrità;
- procedure di rollback;
- documentazione di manutenzione.

## Fase 7 - Photo profile

Obiettivo:
- chiudere il cerchio per l'uso fotografico.

Temi:
- stack AMD stabile;
- accelerazione;
- color management;
- ABM / power tuning;
- applicazioni foto;
- file management e ingest.
