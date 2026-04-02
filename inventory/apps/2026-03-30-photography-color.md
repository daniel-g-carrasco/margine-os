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

- `FW13_140cd_D65_2.2_S.icc`
- `DELL_P2415Q_D65_high.icc`

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

La baseline non forza una applicazione automatica del profilo display a livello
compositor.

La parte sicura da portare in `Margine` e':

- stack corretto;
- asset ICC corretti;
- applicazioni color-managed.

Scelta aggiuntiva:

- su `Hyprland` l'ICC compositor-level resta opzionale e non attivo di default;
- la `v1` privilegia `colord + app-first`.
