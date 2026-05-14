# Desktop, boot and login theme

Date: 2026-05-13

Sources:

- tuigreet README: https://github.com/apognu/tuigreet
- Limine configuration reference: https://github.com/limine-bootloader/limine/blob/v11.x/CONFIG.md
- Hyprland variables: https://wiki.hypr.land/Configuring/Variables/

## Scope

This runbook explains where Margine theme decisions live across the boot and
login chain:

1. firmware screen;
2. Limine boot menu;
3. UKI, initramfs and kernel command line;
4. LUKS/Plymouth splash;
5. greetd/tuigreet login;
6. Hyprland session and user applications.

Do not hand-edit generated runtime files unless recovering a broken system.
Change the repository templates, then run the provisioning scripts that install,
enroll and validate the final files.

## Sources of truth

Desktop and user applications:

- `files/home/.config/margine/theme.env`
- `scripts/render-theme-artifacts`

Login greeter:

- `files/etc/greetd/config.toml.template`

Limine:

- `files/esp/EFI/BOOT/limine.conf.template`
- `files/esp/EFI/BOOT/limine.zfs.conf.template`

Boot visuals and Plymouth:

- `files/etc/plymouth/`
- boot-chain provisioning scripts
- generated UKIs under `/boot/EFI/Linux/`

## Boot and login sequence

### 1. Firmware

The firmware can display the vendor logo before Limine starts. Margine does not
fully own this screen.

### 2. Limine

Limine reads the ESP configuration and renders the boot menu. Margine owns the
template and generated config.

Important runtime files:

- `/boot/EFI/BOOT/limine.conf`
- `/boot/limine.conf` on some host paths
- `/boot/EFI/Margine/BOOTX64.EFI` on side-by-side host installs
- `/boot/EFI/BOOT/BOOTX64.EFI` for the default fallback path

### 3. UKI and initramfs

The selected Limine entry loads a UKI. The UKI contains the kernel, initramfs and
command line. This is where `quiet`, `splash`, root device, LUKS and ZFS/Btrfs
parameters matter.

### 4. LUKS and Plymouth

Plymouth owns the graphical password/splash phase when enabled. If the handoff
falls back to console text, inspect the kernel command line, initramfs hooks and
Plymouth theme packaging before changing tuigreet.

### 5. greetd and tuigreet

greetd starts tuigreet on the configured VT. tuigreet only controls the login
prompt, not the previous boot splash and not Hyprland after login.

### 6. Hyprland

After authentication, tuigreet runs:

```sh
/usr/local/bin/margine-start-hyprland
```

That wrapper prepares the session environment and starts Hyprland. Terminal text
shown between login and the graphical session is usually caused by boot/session
handoff behavior, not by tuigreet colors.

## Changing tuigreet theme

Edit:

```text
files/etc/greetd/config.toml.template
```

The theme is passed in the `--theme` argument:

```text
--theme 'border=yellow;text=magenta;prompt=lightgray;time=yellow;action=lightgray;button=yellow;container=black;input=white'
```

Supported theme keys:

- `border`
- `text`
- `prompt`
- `time`
- `action`
- `button`
- `container`
- `input`

Upstream tuigreet documents regular ANSI colors. Use these as the portable
baseline:

- `black`
- `red`
- `green`
- `yellow`
- `blue`
- `magenta`
- `cyan`
- `white`

Bright or alias names such as `lightgray` can work in the installed version, but
must be tested locally before becoming policy. Semantic Margine names such as
`earth_yellow`, `mercury` or `grayish_magenta` are not tuigreet color names. If
we want semantic theme names, Margine needs a generator layer that maps them to
ANSI colors before writing the tuigreet command.

Useful tuigreet layout options already relevant to Margine:

- `--time`
- `--remember`
- `--remember-session`
- `--user-menu`
- `--asterisks`
- `--window-padding`
- `--container-padding`
- `--prompt-padding`
- `--greet-align`
- `--width`
- `--time-format`

Validate the installed binary before depending on an option:

```sh
tuigreet --help
```

Safe host test flow:

```sh
cd /home/daniel/dev/margine-os
./scripts/validate-installation-pipeline
sudo ./scripts/provision-host-greetd-baseline
```

Do not restart `greetd` casually from the active graphical session. Restarting
the display manager can terminate the current session.

## Hiding terminal text after login

The text scroll after login is not controlled by tuigreet theme colors. Possible
owners are:

- kernel command line verbosity (`quiet`, `loglevel`, `rd.udev.log_level`);
- Plymouth presence in initramfs;
- systemd unit output during handoff;
- `margine-start-hyprland` output;
- failed services writing to the active VT.

The safe policy is:

- keep enough diagnostics visible while root-on-ZFS and rollback are still being
  validated;
- suppress only known benign noise;
- do not hide boot failures that would otherwise explain a broken graphical
  session.

Debug:

```sh
journalctl -b -p warning..alert --no-pager
systemctl --failed --no-pager
systemctl status greetd --no-pager
```

## Changing Limine theme

Edit both templates:

```text
files/esp/EFI/BOOT/limine.conf.template
files/esp/EFI/BOOT/limine.zfs.conf.template
```

Theme-related fields currently used by Margine:

- `interface_branding`
- `interface_branding_colour`
- `interface_help_hidden`
- `term_palette`
- `term_palette_bright`
- `term_background`
- `term_foreground`
- `term_background_bright`
- `term_foreground_bright`
- `term_margin`
- `term_margin_gradient`

Menu behavior fields nearby:

- `timeout`
- `default_entry`
- `remember_last_entry`
- `quiet`
- `verbose`
- `editor_enabled`

Palette values are semicolon-separated RGB hex colors:

```text
term_palette: 050505;3a3a3a;4a4a4a;5a5a5a;6a6a6a;7a7a7a;9a9a9a;d8d8d8
```

Current background values use the working Limine color format already validated
in Margine templates:

```text
term_background: ff050505
term_foreground: e6e6e6
```

Keep the same format unless changing it against the official Limine reference
and a VM boot test.

`interface_branding_colour` selects a palette color by index. With the current
palette, changing the palette can also change the branding color even when the
index stays the same.

## Installing Limine theme changes

Btrfs host:

```sh
cd /home/daniel/dev/margine-os
sudo ./scripts/provision-host-root-baseline
```

Root-on-ZFS target:

```sh
sudo /usr/local/lib/margine/scripts/provision-initial-boot-chain-zfs \
  --product margine-cachyos \
  --flavor cachyos \
  --esp-path /boot
```

If Secure Boot or Limine config enrollment is active, do not hand-edit
`/boot/limine.conf`. The provisioning path refreshes the Limine config hash and
signatures where required.

Validate:

```sh
grep -nE 'interface_branding|term_palette|term_background|term_margin' /boot/limine.conf /boot/EFI/BOOT/limine.conf 2>/dev/null
sudo sbctl verify
```

For ZFS:

```sh
sudo /usr/local/lib/margine/scripts/validate-root-zfs-target --target-root / --mode boot-chain
sudo /usr/local/lib/margine/scripts/validate-zfs-rollback-boot-environment --mode published --target-root /
```

## Applying theme changes in VM

User app and desktop config:

```sh
cd /home/daniel/dev/margine-os-personal
./scripts/apply-qemu-user-app-config-over-ssh --user danielitivov --prompt-sudo
```

Root update runtime:

```sh
cd /home/daniel/dev/margine-os-personal
./scripts/apply-qemu-root-zfs-update-runtime-over-ssh --user danielitivov --prompt-sudo
```

Boot-chain changes must be tested with a reboot and a validation log collection:

```sh
./scripts/enable-qemu-validation-inhibit-over-ssh --user danielitivov --prompt-sudo
./scripts/collect-qemu-root-zfs-validation-logs --user danielitivov --prompt-sudo
```

## Practical policy

- `theme.env` owns normal desktop fonts, colors and application styling.
- tuigreet has a small ANSI-color theme surface; do not expect full Margine
  palette names there without a generator.
- Limine has its own boot-menu palette; keep Btrfs and ZFS templates aligned.
- Plymouth owns the graphical LUKS/splash phase.
- Secure Boot and Limine enrollment mean `/boot` must be changed through
  provisioning scripts, not by hand.
