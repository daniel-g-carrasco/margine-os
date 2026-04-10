# Post-install validation

This checklist is the baseline post-install validation flow for `Margine`.

Use it after:

- a first installation in QEMU
- a real installation on hardware
- major boot / desktop / update stack changes

The goal is not just to confirm that packages exist, but to verify that:

- the system boots correctly
- the recovery layout is sane
- core services are enabled and working
- the desktop stack is coherent
- audio, video, networking, and theming behave as expected

## 1. Boot and filesystem

```bash
cat /proc/cmdline
findmnt /
findmnt /.snapshots
lsblk -f
```

Check:

- the expected kernel command line is present
- root is mounted from the expected filesystem
- `/.snapshots` exists and is mounted correctly when the layout expects it

## 2. Boot artifacts and recovery

```bash
ls -l /boot/EFI/BOOT
ls -l /boot/EFI/Linux
cat /boot/EFI/BOOT/limine.conf
sbctl status
```

Check:

- `BOOTX64.EFI` exists
- `limine.conf` exists and points to the expected entries
- the main, fallback, and recovery UKIs exist
- Secure Boot state is coherent

## 3. Package presence

Adjust package names to the product under test.

Public product example:

```bash
pacman -Q linux linux-headers hyprland waybar swaync hyprlock walker elephant kitty firefox showtime decibels
```

Private Cachy product example:

```bash
pacman -Q linux-cachyos linux-cachyos-headers cachyos-keyring cachyos-mirrorlist hyprland waybar swaync hyprlock walker elephant kitty firefox showtime decibels
```

Check:

- kernel package is the expected one
- desktop packages are installed
- media players and launcher stack are installed

Also verify the launcher AUR baseline explicitly:

```bash
pacman -Q yay elephant elephant-providerlist elephant-desktopapplications elephant-files elephant-clipboard elephant-calc elephant-websearch elephant-windows elephant-runner msttcorefonts walker
elephant listproviders
```

Check:

- all baseline AUR launcher packages are installed
- `elephant` exposes `calc`, `websearch`, `windows`, and `runner`

## 4. System services

```bash
systemctl --failed
systemctl status NetworkManager bluetooth iwd power-profiles-daemon ufw avahi-daemon cups sshd --no-pager
```

Check:

- there are no unexpected failed units
- the expected baseline services are enabled/running

If you want the enablement state too, use:

```bash
systemctl is-enabled NetworkManager bluetooth iwd power-profiles-daemon ufw avahi-daemon cups sshd
```

## 5. User services and session state

Run these from the graphical session when possible:

```bash
systemctl --user --failed
systemctl --user show-environment | rg '^(DISPLAY|WAYLAND_DISPLAY|XDG_CURRENT_DESKTOP|XDG_SESSION_TYPE|XDG_SESSION_DESKTOP|DESKTOP_SESSION|HYPRLAND_INSTANCE_SIGNATURE|XDG_RUNTIME_DIR)='
systemctl --user status elephant.service keep-awake.service hypr-refresh-rate.service margine-maintenance-check.timer --no-pager
```

Check:

- no unexpected failed user units
- Wayland / Hyprland session variables exist
- `elephant.service` is alive if `walker` depends on it
- `keep-awake.service` exists and can be toggled
- the maintenance timer exists

## 6. Networking

```bash
nmcli general
nmcli device
ip addr
resolvectl status
```

Check:

- `NetworkManager` sees devices correctly
- links are up as expected
- name resolution works

## 7. Audio and video stack

```bash
wpctl status
pactl info
vainfo 2>/dev/null | sed -n '1,80p'
```

Check:

- PipeWire and the default sink/source look sane
- the active audio server is the expected one
- VA-API does not error unexpectedly

## 8. Desktop stack

```bash
which walker elephant hyprlauncher grim slurp wl-copy waybar swaync-client hyprlock hyprpaper
ls ~/.local/bin/{battery-status,network-status,notification-status,keep-awake-daemon,keep-awake-status,keep-awake-toggle,easyeffects-status,screenshot-menu,open-network-tui,open-network-settings,open-bluetooth-tui}
hyprctl version
hyprctl monitors
hyprctl clients
```

Check:

- launcher and screenshot stack binaries exist
- versioned helper scripts actually landed in the target home
- Hyprland is responsive and reports outputs/windows normally

## 9. User config deployment

```bash
ls ~/.config/hypr
ls ~/.config/elephant
ls ~/.config/waybar
ls ~/.config/swaync
ls ~/.config/kitty
ls ~/.config/walker
ls ~/.config/walker/themes/default
```

Check:

- versioned config trees are actually present in the target home
- `~/.config/elephant/websearch.toml` exists
- Walker theme assets exist, not just `config.toml`

## 10. Snapper and rollback

```bash
snapper list-configs
snapper -c root list
systemctl status snapper-cleanup.timer --no-pager
```

Check:

- the `root` config exists
- at least one sane root snapshot exists
- cleanup timer is enabled

## 11. SSH

```bash
systemctl status sshd --no-pager
ufw status
ss -ltnp | grep ':22'
```

Check:

- `sshd` is enabled/running when intentionally enabled
- firewall state is coherent

## 12. Logs to collect when debugging

```bash
journalctl -b -p warning..alert --no-pager
journalctl -b --no-pager | tail -n 300
systemctl --failed
systemctl --user --failed
```

These are the first logs to save when something is suspicious.

## Minimal validation bundle

If you want one compact block to paste after a first boot, use:

```bash
cat /proc/cmdline
findmnt /
findmnt /.snapshots
systemctl --failed
systemctl --user --failed
nmcli general
wpctl status
snapper list-configs
snapper -c root list
journalctl --user -b --no-pager | rg 'elephant|waybar|swaync|hyprpaper|walker' || true
journalctl -b -p warning..alert --no-pager
```

For the private CachyOS product, also include:

```bash
pacman -Q linux-cachyos linux-cachyos-headers cachyos-keyring cachyos-mirrorlist hyprland waybar swaync hyprlock walker elephant elephant-providerlist elephant-desktopapplications elephant-files elephant-clipboard elephant-calc elephant-websearch elephant-windows elephant-runner yay msttcorefonts
elephant listproviders
```
