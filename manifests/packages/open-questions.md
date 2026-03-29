# Questioni aperte sui pacchetti

## Già deciso

- `Nautilus` resta il file manager.
- Per VPN, Wi-Fi e Bluetooth la direzione resta `terminal-first`.
- `Firefox` resta il browser principale.
- `Thunderbird` entra nel progetto.
- `Koofr` resta una eccezione AUR motivata.

## Da ricordare

- il database `pacman` attuale della tua macchina mostra `230` pacchetti
  espliciti;
- `Margine` non deve copiarli: deve selezionarli.
- `walker` e `hyprcap` oggi risultano AUR sulla macchina attuale, quindi li
  trattiamo come eccezioni finché non decidiamo diversamente.

## Ambiguità da chiudere

### Thunderbird ESR

Nel database pacchetti attuale della macchina risulta `thunderbird` nei repo
ufficiali, non un pacchetto `thunderbird-esr`.

Decisione da chiudere:

- accettiamo `thunderbird` ufficiale come baseline Arch;
- oppure cerchiamo una strada diversa se vuoi davvero pinning ESR.

### LazyVim

`LazyVim` non va trattato come pacchetto di sistema.
Va trattato come configurazione di `Neovim`.

Quindi:

- nei manifest entra `neovim` + tooling di supporto;
- `LazyVim` entrerà più avanti come layer config sotto `files/home`.

### DaVinci Resolve

`davinci-resolve` oggi non compare nei repo ufficiali della tua macchina.
È da trattare come eccezione AUR con installazione più delicata del normale.

### Gapless

Nel database AUR attuale della tua macchina esiste `gapless`, che fornisce
`g4music`.

Qui va solo chiarito se il pacchetto giusto per te è davvero quello.

### Timeshift

`Timeshift` può entrare, ma non deve confondere l'architettura:

- `Snapper` resta il motore principale del rollback;
- `Timeshift` è un compat layer / strumento comodo.
