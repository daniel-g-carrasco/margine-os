# Migrazione selettiva dei profili personali - review del 2026-03-30

## Legenda

- `Versiona`: entra nel repo come baseline o asset.
- `Non migrare`: resta fuori da `Margine v1`.
- `Rivedi piu' avanti`: non entra ora, ma puo' valere una estrazione piu'
  mirata in futuro.

## Browser e mail

### Firefox / Floorp

- Path osservati:
  - `~/.mozilla/firefox`
  - `~/.floorp`
- Decisione: `Non migrare`
- Motivo:
  - profili browser completi troppo opachi;
  - storico, estensioni, sessioni, database e stato locale;
  - `Margine` usa policy di sistema per `Firefox`.

### Thunderbird

- Path osservato:
  - `~/.thunderbird`
- Decisione: `Non migrare`
- Motivo:
  - contiene account, mail, indici, chiavi, cache e stato locale;
  - e' materiale da backup o migrazione personale, non baseline.

## Creativita' e media

### Darktable

- Path osservato:
  - `~/.config/darktable`
- Decisione: `Versiona` in forma selettiva
- Sottoinsieme scelto:
  - `darktablerc` baseline curato
  - `darktablerc-common`
  - stili `.dtstyle`
- Da NON migrare:
  - `library.db`
  - `data.db`
  - il `darktablerc` completo della macchina sorgente

### EasyEffects

- Path osservato:
  - `~/.config/easyeffects`
- Decisione: `Versiona` in forma selettiva
- Sottoinsieme scelto:
  - preset `fw13-easy-effects`
  - IR collegata
- Da NON migrare:
  - database `db/*`
  - lock e stato runtime

### GIMP

- Path osservato:
  - `~/.config/GIMP/3.0`
- Decisione: `Rivedi piu' avanti`
- Motivo:
  - `gimprc` e `sessionrc` mischiano preferenze e stato finestra;
  - le directory `brushes`, `palettes`, `scripts`, `plug-ins` oggi risultano
    vuote, quindi non c'e' ancora un sottoinsieme creativo reale da estrarre.
- Regola futura:
  - se compariranno pennelli, palette, script o plug-in personali, si
    versioneranno solo quelli.

### VLC

- Path osservato:
  - `~/.config/vlc`
- Decisione: `Non migrare`
- Motivo:
  - `vlcrc` e' in gran parte un dump di opzioni generate;
  - non esprime una baseline chiara abbastanza da giustificarne il trasporto.

### Papers

- Path osservato:
  - `~/.config/papers/print-settings`
- Decisione: `Non migrare`
- Motivo:
  - contiene stato di stampa locale e nome stampante corrente;
  - non e' una baseline portabile.

## Produttivita' e cloud

### Bitwarden

- Path osservato:
  - `~/.config/Bitwarden`
- Decisione: `Non migrare`
- Motivo:
  - contiene stato applicativo Electron, app id, preferenze runtime, storage e
    dati sensibili della sessione;
  - va trattato come dato personale locale, non come baseline di sistema.

### LibreOffice

- Path osservato:
  - `~/.config/libreoffice/4`
- Decisione: `Rivedi piu' avanti`
- Motivo:
  - il profilo completo e' troppo ampio e poco didattico;
  - oggi non emergono template o macro personali gia' isolati.
- Regola futura:
  - se avrai template, dizionari o macro davvero tuoi, si potranno estrarre da
    soli.

### Koofr

- Path osservato:
  - `~/.koofr`
- Decisione: `Non migrare`
- Motivo:
  - contiene config account, database di sync, log e stato runtime;
  - e' materiale sensibile e macchina-specifico.

### rclone

- Path osservato:
  - nessun `~/.config/rclone/rclone.conf` presente al momento
- Decisione: `Non migrare` come baseline di repo
- Motivo:
  - quando esiste, `rclone.conf` contiene remote e credenziali;
  - va gestito come segreto utente, non come file versionato pubblico della
    baseline.

## Terminali, editor e desktop

### Neovim

- Path osservato:
  - `~/.config/nvim`
- Decisione: `Versiona`
- Motivo:
  - e' configurazione leggibile, testuale e didattica.

### Kitty

- Path osservato:
  - `~/.config/kitty/kitty.conf`
- Decisione: `Versiona`
- Motivo:
  - config chiara e portabile.

### Ghostty

- Path osservato:
  - `~/.config/ghostty/config`
- Decisione: `Non migrare`
- Motivo:
  - `Margine` usa `kitty` come terminale baseline;
  - non vogliamo mantenere due terminali come default della `v1`;
  - il profilo `ghostty` non porta abbastanza valore da giustificarne la
    migrazione adesso.

### VS Code

- Path osservato:
  - `~/.config/Code/User`
- Decisione: `Non migrare` nella `v1`
- Motivo:
  - quasi tutto il valore e' mischiato a stato Electron, history, workspace
    storage ed estensioni;
  - l'unico `settings.json` attuale e' minimo e non giustifica ancora una
    baseline dedicata.

### GTK bookmarks

- Path osservato:
  - `~/.config/gtk-3.0/bookmarks`
- Decisione: `Non migrare`
- Motivo:
  - e' una lista di percorsi personali rapidi, non una baseline universale del
    sistema.

### Desktop entries locali

- Path osservato:
  - `~/.local/share/applications`
- Decisione: `Non migrare` in blocco
- Motivo:
  - contiene molta roba generata (`userapp-*`, wrapper casuali, desktop file
    di app locali o storiche).
- Eccezione:
  - eventuali launcher davvero tuoi e puliti possono essere estratti uno per
    uno, non in massa.

## Asset colore

### ICC personali

- Path osservato:
  - `~/.local/share/icc`
- Decisione: `Versiona` in forma selettiva
- Sottoinsieme scelto:
  - profili ICC riconosciuti come buoni
- Da NON migrare:
  - profili intermedi;
  - EDID generici;
  - storico sperimentale.

## Conclusione

Il quadro attuale e' questo:

- `Versiona`: `Neovim`, `Kitty`, `Darktable` selettivo, `EasyEffects`
  selettivo, ICC selettivi.
- `Non migrare`: `Firefox/Floorp`, `Thunderbird`, `Bitwarden`, `VLC`,
  `Papers`, `Koofr`, `rclone.conf`, `VS Code`, `Ghostty`, `gtk bookmarks`,
  `~/.local/share/applications` in blocco.
- `Rivedi piu' avanti`: `GIMP`, `LibreOffice`.
