# ADR 0022 - Desktop layer Hyprland versionato e riproducibile

## Stato

Accettato

## Problema

Fino a qui `Margine` aveva già:

- i manifest pacchetti;
- il bootstrap;
- il login path;
- alcuni fix runtime isolati.

Mancava però il pezzo più importante per l'esperienza quotidiana: un vero
desktop layer versionato.

Senza questo layer, il progetto installa i pacchetti giusti ma non ricostruisce
davvero il sistema che l'utente usa ogni giorno.

## Decisione

`Margine v1` versiona un desktop layer utente completo basato su:

- `Hyprland`
- `hypridle`
- `hyprlock`
- `hyprpaper`
- `waybar`
- `mako`
- `walker`
- `satty`
- `swayosd`
- helper script sotto `~/.local/bin`

Questo layer viene installato da un provisioner dedicato, separato dai
provisioner di sistema.

## Cosa entra nel layer

Entrano:

- i file `~/.config/hypr/*`;
- i file `~/.config/waybar/*`;
- la config `mako`;
- la config `walker`;
- la config `satty`;
- lo stile `swayosd`;
- i wrapper locali per launcher, screenshot, recording, OSD, rete e Bluetooth.

Non entrano invece:

- wallpaper personali dell'utente;
- cache;
- database runtime;
- stato locale transitorio.

## Launcher

La baseline scelta è:

- `walker` come launcher preferito;
- `hyprlauncher` come fallback ufficiale;
- wrapper `margine-launcher` come punto unico di invocazione.

Questo permette al desktop di restare coerente anche quando `walker` non è
installato o viene disabilitato.

## Screenshot e recording

Il progetto mantiene il workflow screenshot/recording oggi validato sulla
macchina reale:

- screenshot con menu coerente al launcher;
- annotazione con `satty`;
- recording con indicatore `REC` in `waybar`;
- OSD volume/luminosità con `swayosd`.

La baseline `v1` usa direttamente:

- `grim`
- `slurp`
- `satty`
- `wf-recorder`

Questo evita che il desktop dipenda da un wrapper AUR per funzioni di base come
screenshot e recording.

## Wallpaper

Il progetto non copia uno sfondo personale.

`Margine` installa invece un asset di default neutro sotto
`/usr/share/margine/wallpapers`, così:

- il bootstrap produce sempre un desktop completo;
- il repository non ingloba immagini private;
- il wallpaper utente può essere cambiato dopo senza sporcare la baseline.

## Implementazione v1

`Margine` versiona:

- i file del desktop sotto `files/home/.config`
- gli helper sotto `files/home/.local/bin`
- un asset wallpaper sotto `files/usr/share/margine`
- un provisioner dedicato che installa il tutto per l'utente finale

Il bootstrap `chroot` richiama questo provisioner dopo il provisioning utente e
prima dei layer opzionali specifici hardware.

## Conseguenze pratiche

Questa decisione dà a `Margine`:

- un desktop realmente riproducibile;
- meno dipendenza da copie manuali dei dotfiles;
- un confine chiaro tra sistema e sessione utente;
- una base concreta da rifinire senza perdere il controllo del progetto.

## Per uno studente: la versione semplice

Installare i pacchetti non basta.

Un desktop reale nasce quando metti insieme tre cose:

- i programmi giusti;
- i file di configurazione giusti;
- i piccoli script che tengono insieme l'esperienza.

Questo ADR dice proprio questo: il desktop non è un dettaglio. È un layer.
