# Scope e allowlist iniziale

Questo file è fondamentale: evita di clonare la spazzatura della macchina
attuale.

## Regola base

Entra nel progetto solo ciò che è:

- voluto;
- compreso;
- mantenibile;
- coerente con gli obiettivi.

## Incluso da subito

- Arch Linux minimale e riproducibile
- `Hyprland` e componenti collegati
- `waybar`
- `hyprlock`
- `hypridle`
- `hyprpaper`
- `mako`
- `walker`
- stack screenshot / screen recording
- `EasyEffects`
- `update-all` come entrypoint operativo
- `Btrfs` + `LUKS2`
- `Secure Boot` + `TPM2`
- documentazione didattica
- repository Git locale + GitHub
- `Firefox` puro, con configurazione enforced ma non estrema

## Escluso da subito

- `Floorp`
- `GNOME` come ambiente principale
- copia cieca dei pacchetti attuali
- componenti `-git` come base del sistema
- AUR non strettamente necessari
- `HyprPanel`

## Eccezioni AUR candidate

- `koofr-desktop-bin`

Nota:
- al momento, sulla macchina attuale, `Koofr` risulta installato come pacchetto
  AUR (`koofr-desktop-bin`);
- non entra automaticamente nel progetto: va prima giustificato come eccezione.

## Elementi da decidere più avanti

- display manager finale (`greetd`, TTY, altro)
- gestore snapshot (`Snapper` come base, eventuale compat layer)
- scelta definitiva del bootloader
- sostituti non-GNOME per alcune app correnti
- workflow colore / ICC / viewer per fotografia
