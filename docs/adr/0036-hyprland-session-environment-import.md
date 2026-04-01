# ADR 0036: import esplicito dell'ambiente Hyprland nel manager `systemd --user`

## Stato

Accettato

## Contesto

`Margine` usa `Walker` come launcher di default e `Elephant` come backend dati.
`Elephant` puo' lanciare applicazioni attraverso `systemd-run --user --scope`.

Questo crea una distinzione importante:

- il terminale utente vede direttamente l'ambiente ricco della sessione
  Hyprland;
- il manager `systemd --user` non vede automaticamente tutte le variabili della
  sessione grafica;
- le app avviate da `Walker -> Elephant -> systemd-run --user --scope` possono
  quindi ricevere un contesto grafico piu' povero o incoerente.

Il caso locale di `wayland-scroll-factor` ha reso il problema piu' evidente, ma
non e' la root cause architetturale da correggere in `Margine`.

## Decisione

`Margine` importa esplicitamente l'ambiente grafico essenziale della sessione
Hyprland nel manager `systemd --user` e nel contesto di attivazione D-Bus.

La soluzione e':

- script versionato `margine-import-session-environment`;
- esecuzione come prima `exec-once` della sessione in `hyprland.conf`;
- avvio del servizio launcher subito dopo l'import dell'ambiente;
- uso congiunto di:
  - `systemctl --user import-environment`
  - `dbus-update-activation-environment --systemd`

Le variabili candidate sono:

- `DISPLAY`
- `WAYLAND_DISPLAY`
- `XDG_CURRENT_DESKTOP`
- `XDG_SESSION_TYPE`
- `XDG_SESSION_DESKTOP`
- `DESKTOP_SESSION`
- `GDK_BACKEND`
- `MOZ_ENABLE_WAYLAND`
- `_JAVA_AWT_WM_NONREPARENTING`
- `HYPRLAND_INSTANCE_SIGNATURE`
- `XDG_RUNTIME_DIR`

Lo script applica anche default sensati quando la sessione non ha ancora
esplicitato alcuni valori:

- `XDG_CURRENT_DESKTOP=Hyprland`
- `XDG_SESSION_TYPE=wayland`
- `XDG_SESSION_DESKTOP=hyprland`
- `DESKTOP_SESSION=hyprland`
- `GDK_BACKEND=wayland`
- `MOZ_ENABLE_WAYLAND=1`
- `_JAVA_AWT_WM_NONREPARENTING=1`

## Perche' qui e non altrove

Il punto scelto e' Hyprland stesso, non `greetd`.

Motivo:

- `greetd` puo' avviare la sessione, ma non conosce ancora variabili come
  `WAYLAND_DISPLAY` o `HYPRLAND_INSTANCE_SIGNATURE`;
- quelle variabili esistono in modo affidabile solo dopo che Hyprland ha creato
  davvero la sessione;
- quindi il primo punto architetturalmente corretto per importarle e'
  l'avvio iniziale della sessione Hyprland.

## Conseguenze

Positive:

- `Walker` e `Elephant` smettono di dipendere da workaround locali;
- il manager `systemd --user` riceve lo stesso contesto grafico essenziale che
  vede la shell della sessione;
- anche le attivazioni D-Bus grafiche restano coerenti.
- `Elephant` non viene piu' abilitato come servizio di sessione persistente:
  viene avviato on-demand dal launcher dopo l'import dell'ambiente, cosi' non
  puo' partire troppo presto.

Negative:

- il fix dipende da un passaggio esplicito in `hyprland.conf`;
- se in futuro `Margine` cambiera' entrypoint di sessione, questo punto andra'
  rivalutato.
