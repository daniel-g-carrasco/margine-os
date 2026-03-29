# Layout storage attuale osservato

Questa nota fotografa il layout visto sulla macchina corrente.

## Partizioni

- `nvme0n1p1` -> `vfat`, `4 GiB`, montata su `/boot`
- `nvme0n1p2` -> `LUKS2`
- `root` dentro `LUKS2` -> `Btrfs`

## Subvolumi montati

- `/` -> `@`
- `/home` -> `@home`
- `/.snapshots` -> `@snapshots`
- `/var/cache` -> `@var_cache`
- `/var/log` -> `@var_log`

## Mount options attuali rilevate

Per `Btrfs`:

- `rw`
- `relatime`
- `ssd`
- `space_cache=v2`

Nota:
- al momento non risulta `compress=zstd`.

## Valutazione sintetica

Il layout attuale è già buono come punto di partenza:

- architettura pulita;
- cifratura sensata;
- subvolumi essenziali già presenti.

Non è però ancora il layout target di `Margine`, perché mancano:

- separazione per `var/tmp`;
- separazione per dati/servizi più mutabili;
- strategia dedicata per VM e container;
- mount strategy ripensata per `Limine + Snapper + snapshot bootabili`.
