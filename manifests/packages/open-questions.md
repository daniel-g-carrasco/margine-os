# Questioni aperte sui pacchetti

## Già deciso

- `Nautilus` resta il file manager.
- Per VPN, Wi-Fi e Bluetooth la direzione resta `terminal-first`.
- `Firefox` resta il browser principale.
- `Thunderbird` entra nel progetto come pacchetto ufficiale `thunderbird`.
- `Thunderbird ESR` non risulta disponibile nei repo ufficiali Arch al
  `2026-03-29`, quindi non diventa baseline `v1`.
- `Koofr` resta una eccezione AUR motivata.
- `DaVinci Resolve` resta una eccezione AUR motivata.
- `Gapless` entra come Flatpak esplicito (`com.github.neithern.g4music`).
- `LazyVim` verrà trattato come configurazione di `Neovim`, non come pacchetto.
- `Timeshift` puo' entrare, ma `Snapper` resta il motore architetturale
  principale del rollback.
- `hyprcap` non entra nella baseline `v1`: useremo stack screenshot/recording
  ufficiale (`grim`, `slurp`, `satty`, `wf-recorder`).
- `hyprlauncher` diventa il launcher predefinito.
- `walker` resta una seconda scelta opzionale.
- per toolkit e portal si rende esplicito un layer dedicato:
  - `xdg-desktop-portal`
  - `xdg-desktop-portal-hyprland`
  - `xdg-desktop-portal-gtk`
  - `qt5-wayland`
  - `qt6-wayland`
  - `qt5ct`
  - `qt6ct`
  - `nwg-look`
  - `adwaita-icon-theme`

## Da ricordare

- il database `pacman` attuale della tua macchina mostra `230` pacchetti
  espliciti;
- `Margine` non deve copiarli: deve selezionarli.
- `walker` oggi risulta AUR;
- `hyprlauncher` invece e' disponibile nei repo ufficiali Arch.

## Ambiguità da chiudere

### Firefox

Il pacchetto e' deciso.
Manca ancora la parte piu' importante:

- definire il layer di configurazione enforced ma non invasivo.

### EasyEffects per Framework 13

I pacchetti base per il profilo altoparlanti sono stati chiariti:

- `easyeffects`
- `calf`
- `lsp-plugins-lv2`

Resta da chiudere il layer di provisioning:

- import del preset `fw13-easy-effects`;
- attivazione di default sull'output analogico interno;
- documentazione del comportamento atteso e del rollback.
