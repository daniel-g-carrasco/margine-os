# Margine Branding Assets

This runbook defines where the Margine logo is stored, how it reaches the
installed system, and how to refresh boot-time branding after changing the
source artwork.

## Source Model

The repository stores generated, install-ready assets rather than depending on a
large design source file during installation.

- System logo assets: `files/usr/share/margine/branding/`
- UKI/systemd-stub splash bitmap: `files/usr/share/margine/boot/margine-splash.bmp`
- Plymouth theme and watermark: `files/usr/share/plymouth/themes/margine/`
- Application/logo icons: `files/usr/share/icons/hicolor/` and `files/usr/share/pixmaps/`
- Terminal identity logo: `files/home/.config/fastfetch/` and
  `files/home/.local/bin/margine-fetch`

`margine-splash.bmp` is intentionally a small bitmap, not a full-screen
1920x1080 image. The goal is to give `systemd-stub` a compact OS logo during
early boot without blanketing the firmware/vendor splash screen.

## Installed Paths

`scripts/provision-branding-assets` installs the system assets:

- `/usr/share/margine/branding/margine-logo.png`
- `/usr/share/margine/branding/margine-logo-wide.png`
- `/usr/share/margine/branding/margine-logo-square.png`
- `/usr/share/margine/branding/ascii-logo.txt`
- `/usr/share/margine/boot/margine-splash.bmp`
- `/usr/share/plymouth/themes/margine/margine.plymouth`
- `/usr/share/plymouth/themes/margine/watermark.png`
- `/usr/share/icons/hicolor/{256x256,512x512}/apps/margine.png`
- `/usr/share/pixmaps/margine.png`
- `/usr/share/pixmaps/margine-logo.png`

When called with `--username NAME`, it also installs:

- `/home/NAME/.config/fastfetch/config.jsonc`
- `/home/NAME/.config/fastfetch/margine-ascii.txt`
- `/home/NAME/.local/bin/margine-fetch`

`provision-boot-baseline` delegates to `provision-branding-assets`, so normal
boot-chain provisioning refreshes Plymouth and UKI splash assets together with
the `mkinitcpio` baseline.

## Refresh Host Branding

From the public repo on an installed Margine host:

```bash
cd /home/daniel/dev/margine-os
sudo ./scripts/provision-branding-assets --username "$USER"
sudo ./scripts/provision-boot-baseline
sudo mkinitcpio -P
```

Then reboot and check:

```bash
margine-fetch
sudo ./scripts/validate-boot-recovery-baseline
```

If the host uses root-on-ZFS, the safer full-update path is still `update-all`
after the root-on-ZFS update workflow is installed, because it regenerates and
validates boot artifacts around the snapshot/rollback flow.

## Refresh Installed VM Branding

Prefer the host-side SSH helper. It avoids the QEMU `9p` mount path, which can
hang in long validation sessions and is not needed once SSH is enabled in the
guest:

```bash
cd /home/daniel/dev/margine-os-personal
./scripts/apply-qemu-branding-assets-over-ssh --user USERNAME --prompt-sudo
```

For public Arch validation guests, pass the public product explicitly if the
helper cannot infer it from the repository:

```bash
./scripts/apply-qemu-branding-assets-over-ssh \
  --user USERNAME \
  --product margine-public \
  --flavor arch \
  --prompt-sudo
```

If SSH is not available yet, mount the repo in the VM and run the same
provisioners inside the guest:

```bash
sudo /root/margine-repo/scripts/provision-branding-assets --username "$USER"
sudo /root/margine-repo/scripts/provision-boot-baseline --product margine-public --flavor arch
sudo mkinitcpio -P
```

For `margine-cachyos` personal VMs, use the personal repo and the matching
product/flavor-aware boot provisioner already documented in the root-on-ZFS
validation runbooks.

## Validation Gates

The static pipeline validator checks that:

- all generated logo assets exist in the repo;
- Plymouth loads assets from `/usr/share/plymouth/themes/margine`;
- the branding provisioner installs system logo, Plymouth, hicolor, pixmaps and
  terminal identity assets;
- `provision-boot-baseline` calls the branding provisioner;
- the user layer installs the `fastfetch` config and `margine-fetch` wrapper;
- `fastfetch` is part of default workstation tooling.

The installed-system boot validator checks that the host has:

- Plymouth in `mkinitcpio` hooks;
- `/etc/plymouth/plymouthd.conf`;
- `/usr/share/margine/boot/margine-splash.bmp`;
- `/usr/share/margine/branding/margine-logo.png`;
- `/usr/share/plymouth/themes/margine/watermark.png`;
- `splash` in `/etc/kernel/cmdline`.
