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

## Preferred entrypoint

For installed systems, prefer the consolidated validator instead of manually
remembering every check family.

The consolidated validator:

- autodetects the installed `product` and `flavor` from the runtime state;
- validates against the real Arch or CachyOS baseline expected by that product;
- supports explicit overrides with `--product` and `--flavor`;
- prints a concise `PASS / WARN / FAIL` report by default;
- supports `--verbose` when the full validator output is needed;
- returns non-zero when it finds actual baseline drift or suspect runtime state.

From the graphical user session:

```bash
/usr/local/lib/margine/scripts/validate-host-health --session
```

Or, if the convenience wrapper is installed:

```bash
margine-validate-host-health --session
```

Explicit override examples:

```bash
margine-validate-host-health --session --product margine-public --flavor arch
sudo /usr/local/lib/margine/scripts/validate-host-health --root --product margine-cachyos --flavor cachyos
```

Then, from a root shell:

```bash
sudo /usr/local/lib/margine/scripts/validate-host-health --root
```

Optional virtualization/container checks:

```bash
sudo /usr/local/lib/margine/scripts/validate-host-health --root --with-virtualization
```

Verbose examples:

```bash
margine-validate-host-health --session --verbose
sudo /usr/local/lib/margine/scripts/validate-host-health --root --verbose
```

Why two passes:

- session mode validates the live desktop/session/runtime state from the real user context
- root mode validates boot, recovery, Secure Boot, and TPM2 state that the user session cannot inspect correctly

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

Also verify that the installed update path can materialize snapshot recovery
entries in `Limine` after a maintenance run:

```bash
sudo snapper --no-dbus -c root list | tail -n 10
grep -n '^/Recovery\\|^//Snapshot' /boot/EFI/BOOT/limine.conf
```

Check:

- `update-all` has created new `source=pre-update` snapshots
- `limine.conf` contains `//Snapshot ...` entries under `/Recovery`
- the generated recovery menu follows the current Snapper state instead of
  staying stale after updates

For the installed trust-refresh path, also verify:

```bash
update-all --dry-run --no-aur --no-flatpak --no-fwupd
sudo sbctl verify
```

Check:

- the dry-run shows `install -Dm755 /usr/share/limine/BOOTX64.EFI` on the
  active loader path before `limine enroll-config`
- the dry-run shows a subsequent `sbctl sign` on the same active loader path
- `sbctl verify` is clean after a real `update-all` run

## 3. Package presence

Adjust package names to the product under test.

Public product example:

```bash
pacman -Q linux linux-headers hyprland waybar swaync hyprlock walker elephant kitty firefox chromium loupe gnome-text-editor showtime decibels
```

Private Cachy product example:

```bash
pacman -Q linux-cachyos linux-cachyos-headers cachyos-keyring cachyos-mirrorlist hyprland waybar swaync hyprlock walker elephant kitty firefox chromium loupe gnome-text-editor showtime decibels
```

Check:

- kernel package is the expected one
- desktop packages are installed
- media players and launcher stack are installed
- the GNOME audio player may appear under different branding in the UI, but the package baseline is `decibels`

Also verify the launcher AUR baseline explicitly:

```bash
pacman -Q yay elephant-all ttf-ms-fonts walker
elephant listproviders
ls ~/.local/share/icons/hicolor/256x256/apps/duckduckgo.png
```

Check:

- all baseline AUR launcher packages are installed
- `elephant` exposes `calc`, `websearch`, `windows`, and `runner`
- the DuckDuckGo icon asset exists for the Walker websearch entry

## 4. System services

```bash
systemctl --failed --no-pager
systemctl status greetd NetworkManager bluetooth iwd power-profiles-daemon ufw avahi-daemon cups sshd --no-pager
```

Check:

- there are no unexpected failed units
- the expected baseline services are enabled/running
- `greetd` is active on systems that use the `greetd + tuigreet` login path

If you want the enablement state too, use:

```bash
systemctl is-enabled greetd NetworkManager bluetooth iwd power-profiles-daemon ufw avahi-daemon cups sshd
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

### Power, lid, and suspend

On real hardware, also verify:

```bash
pgrep -af hypridle
systemd-analyze cat-config systemd/logind.conf | rg 'HandleLidSwitch|HandleLidSwitchExternalPower|HandleLidSwitchDocked'
loginctl session-status | sed -n '1,80p'
```

Check:

- `hypridle` is running inside the graphical session
- the lid policy resolves to `HandleLidSwitch=suspend`
- the lid policy resolves to `HandleLidSwitchExternalPower=suspend`
- the docked policy remains `HandleLidSwitchDocked=ignore`

Manual checks:

- closing the laptop lid on real hardware must lock and suspend the machine instead of leaving the panel visibly active
- reopening the lid must resume into the locked session with the display restored
- when `greetd` is the chosen login path, logout must return to `tuigreet`
- on supported fingerprint hardware, both `tuigreet` and `hyprlock` must keep password fallback and allow fingerprint unlock when enrolled

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
hyprctl workspaces
hyprctl activeworkspace
hyprctl clients
```

Check:

- launcher and screenshot stack binaries exist
- versioned helper scripts actually landed in the target home
- Hyprland is responsive and reports outputs/windows normally
- the active workspace is the expected one after login, not a stray workspace

### 8.1 Hyprlock dynamic scaling

If `jq` is available, `hyprlock` is launched through:

```bash
~/.local/bin/margine-hyprlock
```

This wrapper:

- reads the focused monitor geometry from `hyprctl -j monitors`
- computes a scale factor using logical width (`width / scale`) against a
  1920px baseline
- rescales and clamps selected values (time/date/user/prompt fonts, input field,
  accent line width)
- writes a temporary generated config and launches `hyprlock -c` with it

Quick checks:

```bash
command -v margine-hyprlock
command -v jq
margine-hyprlock --margine-hyprlock-dry-run >/tmp/margine-hyprlock.debug 2>&1
sed -n '1,40p' /tmp/margine-hyprlock.debug
```

The debug output should show the computed scale and selected temp config path.

Failure fallback path is expected when no monitor JSON is available: lock still
starts via plain `hyprlock` without crash.

## 9. Launcher, search, and browser defaults

```bash
systemctl --user status elephant.service --no-pager
elephant listproviders
grep -n 'DuckDuckGo' ~/.config/elephant/websearch.toml
grep -n '"Default": "DuckDuckGo"' /etc/firefox/policies/policies.json
xdg-mime query default image/png
xdg-mime query default video/mp4
xdg-mime query default audio/mpeg
xdg-mime query default text/plain
find /usr/share/applications ~/.local/share/applications -maxdepth 1 -name '*.desktop' | sed -n '1,20p'
```

Check:

- `elephant.service` is running from the graphical session when Walker needs it
- provider list includes at least `desktopapplications`, `calc`, `websearch`, `windows`, and `runner`
- `~/.config/elephant/websearch.toml` points to DuckDuckGo
- Firefox policy forces DuckDuckGo as default search engine
- MIME defaults resolve to `org.gnome.Loupe.desktop`, `org.gnome.Showtime.desktop`, `org.gnome.Decibels.desktop`, and `org.gnome.TextEditor.desktop`
- desktop files are actually present when debugging an empty Walker application list

Manual checks:

- open Walker with empty query: desktop applications should appear
- try `=1+1`: calculator result must appear
- try `@firefox`: websearch result must appear with the DuckDuckGo icon
- try `$` window search only if windows are open; if it is empty with open windows, treat it as a regression

## 10. User config deployment

```bash
ls ~/.config/hypr
ls ~/.config/elephant
ls ~/.config/waybar
ls ~/.config/swaync
ls ~/.config/kitty
ls ~/.config/easyeffects/db
ls ~/.config/walker
ls ~/.config/walker/themes/default
```

Check:

- versioned config trees are actually present in the target home
- `~/.config/elephant/websearch.toml` exists
- `~/.config/easyeffects/db/easyeffectsrc` and `graphrc` exist when the desktop layer has been provisioned
- Walker theme assets exist, not just `config.toml`

## 11. Wallpaper, theming, and autostart

```bash
ls -l /usr/share/margine/wallpapers/default.jpg
pgrep -af 'hyprpaper|koofr'
gsettings get org.gnome.desktop.interface color-scheme
gsettings get org.gnome.desktop.interface gtk-theme
gsettings get org.gnome.desktop.interface icon-theme
gsettings get org.gnome.TextEditor style-scheme
gsettings get org.gnome.TextEditor style-variant
gsettings get org.gnome.Loupe show-properties
sed -n '1,120p' ~/.config/easyeffects/db/easyeffectsrc
sed -n '1,40p' ~/.config/easyeffects/db/graphrc
```

Check:

- the default wallpaper asset exists at `/usr/share/margine/wallpapers/default.jpg`
- `hyprpaper` is running in the session
- GTK applications are on the intended dark theme
- GNOME Text Editor inherits the intended dark baseline via `gsettings`
- Easy Effects UI defaults are present and sane, without dragging in hardware-specific runtime bindings
- Koofr autostarts if expected, but does not steal focus as a normal foreground window

Manual checks:

- after login, the intended wallpaper is actually visible
- GTK / GNOME apps such as Nautilus, Calendar, Calculator, Loupe, Text Editor, and Firefox use the dark theme

## 12. Waybar, notifications, and maintenance UX

```bash
upower -e
command -v update-all
command -v update-all-launcher || true
test -f ~/.local/share/applications/update-all.desktop && echo desktop-entry:yes || echo desktop-entry:no
systemctl --user status margine-maintenance-check.timer margine-notification-action-router.service --no-pager
~/.local/bin/margine-maintenance-check --test-notification
```

Check:

- `update-all` resolves to the installed global entry point
- `update-all-launcher` exists for notification-click actions
- the `Update All` desktop launcher entry exists in `~/.local/share/applications/update-all.desktop`
- `margine-notification-action-router.service` is active during the user session
- the maintenance timer is active in the user session

Manual checks:

- on systems without a battery, Waybar must not show a fake `0%` battery icon
- the keep-awake icon state must match the real monitor-idle state after reboot
- active workspace highlight changes correctly when switching workspaces
- the notification counter stays aligned with the bell and does not shift the rest of the bar
- clicking the maintenance test notification body opens a terminal and launches `update-all`

## 13. Hyprlock visual review

Manual checks:

- in QEMU, `hyprlock` must stay proportionate; if clock, username, or password field dominate the screen, treat it as a regression
- on hardware, the layout must remain visually balanced and not overlap or drift between elements
- fingerprint prompt and password field must remain readable on both low- and high-resolution outputs

## 14. Snapper and rollback

```bash
snapper --no-dbus list-configs
snapper --no-dbus -c root list
systemctl status snapper-cleanup.timer --no-pager
```

Check:

- the `root` config exists
- at least one sane root snapshot exists
- cleanup timer is enabled

## 15. SSH

```bash
sudo margine-enable-ssh-server
systemctl status sshd --no-pager
ufw status
ss -ltnp | grep ':22'
```

Check:

- `sshd` is enabled/running when intentionally enabled
- firewall state is coherent
- in QEMU, `ssh -p 2222 daniel@127.0.0.1` works after explicit enablement

## 16. Secure Boot and TPM2 rollout checks

```bash
sudo sbctl status
sudo sbctl verify
systemd-analyze has-tpm2
sudo /usr/local/lib/margine/scripts/validate-tpm2-auto-unlock || true
```

Check:

- `sbctl` is either clearly bootstraped or clearly not bootstraped, without ambiguous red-noise failures
- `systemd-analyze has-tpm2` reports `yes` on hardware or on QEMU guests started with `swtpm`
- TPM2 rollout is validated only after the staged post-install flow, not assumed from a fresh install
- production boot auto-unlocks only after the second TPM2 step and final reboot

Manual checks:

- if Secure Boot has just been bootstraped, reboot once before starting TPM2 staging
- if TPM2 has just been staged, reboot once and unlock manually before the final TPM2 enrollment run
- after final TPM2 enrollment, production boot should stop asking for the LUKS password
- recovery boot may still ask for manual credentials; this is acceptable

## 17. Graphics, acceleration, and application exposure

```bash
lspci -k | sed -n '/VGA compatible controller/,+6p;/3D controller/,+6p;/Display controller/,+6p'
lsmod | rg 'amdgpu|i915|nvidia|nouveau|virtio_gpu|snd|snd_hda|snd_sof|kvm'
systemctl --user status pipewire.service pipewire-pulse.service wireplumber.service --no-pager
pactl info
wpctl status
ffmpeg -hide_banner -hwaccels
glxinfo -B 2>/dev/null || true
vulkaninfo --summary 2>/dev/null || true
vainfo 2>/dev/null | sed -n '1,120p'
journalctl -b --no-pager | rg 'drm|gpu|amdgpu|i915|virtio_gpu|pipewire|wireplumber|snd_hda|snd_sof' || true
```

Check:

- kernel drivers are bound to the expected GPU and audio devices
- PipeWire, Pulse compatibility, and WirePlumber are all alive
- `ffmpeg -hwaccels`, `glxinfo`, `vulkaninfo`, and `vainfo` reflect the acceleration paths actually exposed to applications
- a VM may expose only CPU decode paths; if a benchmark shows CPU works but GPU is `0 FPS`, treat it as "GPU path not exposed to the app", not as a generic CachyOS failure

## 18. CachyOS-specific verification

Use this only for the private CachyOS product:

```bash
pacman -Q linux-cachyos linux-cachyos-headers cachyos-keyring cachyos-mirrorlist cachyos-settings
grep -Rni 'cachyos' /etc/pacman.conf /etc/pacman.conf.d 2>/dev/null
uname -r
zramctl
systemctl status systemd-zram-setup@zram0.service --no-pager || true
```

Check:

- the CachyOS kernel, keyring, mirrorlist, and settings packages are installed
- CachyOS repositories are present in pacman configuration
- zram is available if the product baseline expects it
- this verifies the presence of CachyOS artifacts and tunings; it does not by itself prove a performance uplift on the current workload

## 19. Logs to collect when debugging

```bash
journalctl -b -p warning..alert --no-pager
journalctl -b --no-pager | tail -n 300
systemctl --failed --no-pager
systemctl --user --failed
```

These are the first logs to save when something is suspicious.

## Minimal validation bundle

If you want one compact block to paste after a first boot, use:

```bash
cat /proc/cmdline
findmnt /
findmnt /.snapshots
systemctl --failed --no-pager
systemctl --user --failed
nmcli general
wpctl status
snapper --no-dbus list-configs
snapper --no-dbus -c root list
hyprctl activeworkspace
elephant listproviders
grep -n '"Default": "DuckDuckGo"' /etc/firefox/policies/policies.json
journalctl --user -b --no-pager | rg 'elephant|waybar|swaync|hyprpaper|walker' || true
journalctl -b -p warning..alert --no-pager
```

For the private CachyOS product, also include:

```bash
pacman -Q linux-cachyos linux-cachyos-headers cachyos-keyring cachyos-mirrorlist cachyos-settings hyprland waybar swaync hyprlock walker elephant-all yay ttf-ms-fonts firefox chromium loupe gnome-text-editor showtime decibels easyeffects
elephant listproviders
xdg-mime query default image/png
xdg-mime query default text/plain
ffmpeg -hide_banner -hwaccels
glxinfo -B 2>/dev/null || true
vulkaninfo --summary 2>/dev/null || true
vainfo 2>/dev/null | sed -n '1,80p'
```
