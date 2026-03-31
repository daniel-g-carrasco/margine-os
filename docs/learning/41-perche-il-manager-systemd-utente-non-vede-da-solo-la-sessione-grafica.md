# Perche' il manager `systemd --user` non vede da solo la sessione grafica

Questo problema e' facile da fraintendere.

## Il terminale e il manager utente non sono la stessa cosa

Quando lanci un comando da terminale, il processo figlio eredita l'ambiente
della shell:

- `WAYLAND_DISPLAY`
- `DISPLAY`
- `HYPRLAND_INSTANCE_SIGNATURE`
- variabili dei toolkit

Quando invece un'app viene lanciata da:

- `systemd-run --user --scope`

la sorgente dell'ambiente non e' la tua shell. E' il manager `systemd --user`.

Quindi la domanda giusta non e':

- "Il terminale vede la variabile?"

ma:

- "Il manager utente la conosce?"

## Perche' Walker ed Elephant fanno emergere il bug

Nel workflow di `Margine`:

- `Walker` e' il launcher;
- `Elephant` fa da backend;
- il lancio finale puo' passare per `systemd-run --user --scope`.

Se `systemd --user` non conosce la sessione grafica corretta, le app:

- possono non aprirsi;
- possono aprirsi in modo incoerente;
- possono sembrare sane da terminale ma non dal launcher.

## Perche' `greetd` non basta

`greetd` avvia la sessione, ma non puo' materializzare in anticipo variabili
che esistono solo quando Hyprland e' gia' partito davvero.

Per esempio:

- `WAYLAND_DISPLAY`
- `HYPRLAND_INSTANCE_SIGNATURE`

Per questo il punto corretto non e' "prima di Hyprland", ma "subito dopo il
bootstrap della sessione Hyprland".

## La soluzione giusta

La soluzione non e' correggere app per app.

La soluzione giusta e':

1. prendere le variabili essenziali dalla sessione Hyprland reale;
2. importarle nel manager `systemd --user`;
3. importarle anche nell'ambiente di attivazione D-Bus;
4. farlo molto presto nel bootstrap della sessione.

In pratica:

- `systemctl --user import-environment ...`
- `dbus-update-activation-environment --systemd ...`

## Cosa valida davvero il fix

Il fix e' valido quando:

- `systemctl --user show-environment` contiene le stesse variabili essenziali
  della shell della sessione;
- `Walker` lancia app con lo stesso contesto grafico essenziale del terminale.
