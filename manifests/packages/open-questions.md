# Questioni aperte sui pacchetti

## Già deciso

- `Nautilus` resta il file manager.
- Per VPN, Wi-Fi e Bluetooth la direzione resta `terminal-first`.
- `Firefox` resta il browser principale.
- `Thunderbird` entra nel progetto come pacchetto ufficiale `thunderbird`.
- `Thunderbird ESR` non risulta disponibile nei repo ufficiali Arch al
  `2026-03-30`, quindi non diventa baseline `v1`.
- `Koofr` resta una eccezione AUR motivata.
- `DaVinci Resolve` resta una eccezione AUR motivata.
- `Gapless` entra come Flatpak esplicito (`com.github.neithern.g4music`).
- `LazyVim` verrà trattato come configurazione di `Neovim`, non come pacchetto.
- `Timeshift` puo' entrare, ma `Snapper` resta il motore architetturale
  principale del rollback.
- `greetd + tuigreet` diventa il login path baseline.
- l'utente principale entra con autologin iniziale via `greetd`, poi viene
  accolto da `hyprlock`.
- `walker` diventa il launcher preferito.
- `fuzzel` resta il fallback ufficiale se `walker` non e' presente.
- `kitty` resta il terminale baseline.
- `Ghostty` esce dal perimetro della `v1`.
- nasce un layer dedicato al tooling da coding e amministrazione, con:
  - `tmux`
  - `opencode`
  - `htop`
  - `btop`
  - `radeontop`
  - `ripgrep`
  - `fd`
  - `jq`
  - `tree`
  - utility CLI esplicite come `curl`, `grep`, `less`, `openssh`
- la connettivita' di sistema entra in un layer dedicato:
  - `networkmanager`
  - `networkmanager-openvpn`
  - `openvpn`
  - `iwd`
  - `iw`
  - `wireguard-tools`
  - `bluez`
  - `bluez-utils`
  - `bluetui`
  - `impala`
  - `wireless-regdb`
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
- stampa e scanner entrano in un layer dedicato:
  - `cups`
  - `cups-filters`
  - `cups-pk-helper`
  - `avahi`
  - `nss-mdns`
  - `ipp-usb`
  - `sane`
  - `sane-airscan`
  - `simple-scan`
  - `system-config-printer`
  - `ghostscript`

## Da ricordare

- il database `pacman` attuale della tua macchina mostra `230` pacchetti
  espliciti;
- `Margine` non deve copiarli: deve selezionarli.
- `walker` oggi risulta AUR;
- `elephant` oggi risulta AUR;
- `fuzzel` invece e' disponibile nei repo ufficiali Arch.
- `openssh` oggi e' gia' nel progetto anche come stack server/client;
- `ufw` viene scelto come firewall baseline della `v1`.
- la baseline stampa/scanner `v1` e' `driverless-first`.
- virtualizzazione e container entrano in una baseline dedicata:
  - `libvirt`
  - `qemu-desktop`
  - `virt-manager`
  - `virt-viewer`
  - `edk2-ovmf`
  - `dnsmasq`
  - `swtpm`
  - `podman`

## Decisioni architetturali chiuse

### Login path

`Margine v1` adotta:

- `greetd`
- `tuigreet`
- `initial_session` per l'autologin iniziale dell'utente principale
- `hyprlock` come lockscreen immediata della sessione grafica

Questo chiude il dubbio precedente tra `greetd`, TTY puro o altro display
manager.

## Ambiguità da chiudere

### EasyEffects per Framework 13

Il layer base e' ormai chiaro:

- preset ufficiale `fw13-easy-effects` versionato nel progetto;
- IR del convolver versionato nel progetto;
- provisioning condizionale solo su `Framework Laptop 13`;
- autoload generato a runtime per gli altoparlanti interni, non in modo
  globale e cieco.

Resta solo da vedere, piu' avanti, se vorremo aggiungere:

- un eventuale toggle utente piu' comodo;
- profili separati per cuffie o output esterni.

### Networking su Framework 13 AMD

Il layer di configurazione ormai e' chiuso in questa forma:

- `NetworkManager` come orchestratore principale;
- `iwd` come backend Wi-Fi;
- regulatory domain versionato;
- `impala` e `bluetui` come TUI baseline.

Resta aperta solo una validazione futura:

- capire se per `MT7922` servira' davvero un tuning driver dedicato oppure no.

### Migrazione applicativa

Il modello di migrazione selettiva e' deciso.
Restano da chiudere app per app, piu' avanti:

- eventuali config per editor aggiuntivi o IDE;
- eventuali preferenze browser utente non esprimibili bene via policy.

### Stampa e scanner

La baseline e' ormai chiusa in questa forma:

- `CUPS + Avahi + ipp-usb` lato stampa;
- `SANE + sane-airscan` lato scanner;
- `system-config-printer` come gestione principale stampanti;
- `simple-scan` come frontend scanner semplice;
- `nss-mdns` per discovery locale coerente.

Resta aperta solo una validazione futura:

- verificare se, oltre alla baseline `driverless-first`, serviranno eccezioni
  per stampanti o scanner vecchi.

### Virtualizzazione e container

La baseline viene chiusa cosi':

- `libvirt + qemu-desktop + OVMF` per le VM;
- `virt-manager + virt-viewer` per la gestione grafica;
- `swtpm` per guest che richiedono TPM virtuale;
- `podman` per i container.

Resta aperta solo una validazione futura:

- decidere se `podman-compose` debba entrare davvero nella `v1` oppure no.
