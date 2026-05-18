# Fotografia e color management - review del 2026-03-30

## Pacchetti baseline

Da tenere nella baseline di `Margine`:

- `darktable`
- `argyllcms`
- `displaycal`
- `colord`

## Darktable

Decisione:

- tenere configurazione leggera, un `darktablerc` baseline curato e stili;
- non migrare database libreria o stato pesante.

Da versionare:

- `darktablerc`
- `darktablerc-common`
- stili `.dtstyle`

Da NON versionare:

- `library.db`
- `data.db`
- snapshot `*-pre-*`, `*-snp-*`
- il `darktablerc` completo della macchina sorgente

## DisplayCAL

Decisione:

- tenere il pacchetto;
- non migrare `DisplayCAL.ini`, log o report come baseline.

Motivo:

- contengono path locali, storico sessione, output e finestre;
- non sono una baseline pulita.

## Profili ICC

Decisione:

- preservare solo i profili nominati bene e riconosciuti come profili buoni.

Scelti per `Margine`:

- `FW13_D65_GNOME_COLORS.icc`
- `FW13_140cd_D65_2.2_S.icc`
- `DELL_P2415Q_D65_high.icc`

Default Hyprland per il pannello Framework 13 BOE:

- `FW13_D65_GNOME_COLORS.icc`, titolo profilo `FW13 D65`;
- profilo GNOME Colors / `colord-session`, display RGB ICC v2.2,
  matrix/TRC semplice, TRC gamma `2.06640625`;
- `vcgt` presente, 3 canali, 256 entry, 16 bit.

Profilo conservato ma non usato come default Hyprland:

- `FW13_140cd_D65_2.2_S.icc`, profilo DisplayCAL/Argyll diverso,
  `XYZLUT+MTX`, circa 1.1 MB.

Esclusi:

- profili EDID generici;
- profili intermedi o sperimentali;
- copie duplicate in `var/lib/colord`;
- storico `DisplayCAL`.

## Colord

Decisione:

- da installare e tenere in baseline;
- non versionare database runtime come `mapping.db` o `storage.db`.

## Nota Wayland

La baseline forza il profilo display a livello compositor solo per match
espliciti e validati.

La parte sicura da portare in `Margine` e':

- stack corretto;
- asset ICC corretti;
- applicazioni color-managed.

Scelta aggiornata:

- su `Hyprland` 0.55 il profilo `FW13_D65_GNOME_COLORS.icc` viene applicato
  solo al pannello `desc:BOE NE135A1M-NY1`;
- il profilo viene installato anche come asset di sistema in
  `/usr/share/margine/icc`;
- la `v1` continua a usare `colord + app-first` per monitor non validati.
