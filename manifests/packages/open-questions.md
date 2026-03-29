# Questioni aperte sui pacchetti

## Già deciso

- `Nautilus` resta il file manager.
- Per VPN, Wi-Fi e Bluetooth la direzione resta `terminal-first`.
- `Firefox` resta il browser principale.
- `Thunderbird` entra nel progetto come pacchetto ufficiale `thunderbird`.
- `Koofr` resta una eccezione AUR motivata.
- `DaVinci Resolve` entra come eccezione AUR motivata.
- `Gapless` entra come eccezione AUR motivata.
- `LazyVim` verrà trattato come configurazione di `Neovim`, non come pacchetto.
- `Timeshift` puo' entrare, ma `Snapper` resta il motore architetturale
  principale del rollback.
- `hyprcap` non entra nella baseline `v1`: useremo stack screenshot/recording
  ufficiale (`grim`, `slurp`, `satty`, `wf-recorder`).

## Da ricordare

- il database `pacman` attuale della tua macchina mostra `230` pacchetti
  espliciti;
- `Margine` non deve copiarli: deve selezionarli.
- `walker` oggi risulta AUR sulla macchina attuale;
- `fuzzel` e' disponibile nei repo ufficiali e puo' coprire il ruolo di
  launcher/menu fallback.

## Ambiguità da chiudere

### Walker

Va deciso se:

- tenerlo come eccezione AUR stabile del desktop;
- oppure usare `fuzzel` come baseline ufficiale e lasciare `walker` fuori dalla
  `v1`.

### Firefox

Il pacchetto e' deciso.
Manca ancora la parte piu' importante:

- definire il layer di configurazione enforced ma non invasivo.
