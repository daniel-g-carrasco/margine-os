# Files

This directory contains the files that get installed onto the target system.

Expected structure:

- `etc/` for files destined for `/etc`
- `usr/` for files destined for `/usr`
- `home/` for user files to distribute into the home directory
- `esp/` for files destined for the EFI System Partition

Examples already present:

- `etc/snap-pac.ini`
- `etc/snapper/configs/root`
- `etc/sudoers.d/10-margine-wheel`
- `home/.local/share/easyeffects/output/fw13-easy-effects.json`
- `home/.config/systemd/user/margine-framework-audio.service`
- `home/.config/margine/theme.env`

Note:

- files under `home/` are versioned user files that provisioning copies into
  the target home only when they genuinely make sense for that hardware profile
  or workflow.

Rule:

- no file here should be "mysterious";
- every important file should be explained by an ADR, a learning note, or clear
  local comments.

Theme note:

- `home/.config/margine/theme.env` is the canonical source of truth for the
  shared desktop theme baseline
- derived files such as GTK settings, Walker/Fuzzel launcher theme artifacts,
  and the managed Firefox theme policy should be rendered from there instead of
  edited independently
