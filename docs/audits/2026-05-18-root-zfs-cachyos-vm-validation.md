# 2026-05-18 Root-on-ZFS CachyOS VM Validation

## Scope

Validation run for the current Margine CachyOS root-on-ZFS installation path,
including the home-organization baseline, Framework ICC/color-management
baseline, Hyprland Lua lab payload, and recent desktop/runtime provisioning
changes.

The live environment was a CachyOS graphical ISO. The target was a disposable
QEMU VM using a 128 GiB virtual disk, LUKS2, and `rpool`.

## Result

The installation reached the end of `bootstrap-live-zfs-root-guided`.

The boot-chain gate passed from the live ISO:

```bash
/root/margine-repo/scripts/validate-root-zfs-target \
  --target-root /mnt \
  --pool-name rpool \
  --zfs-root-dataset rpool/ROOT/default \
  --crypt-name cryptroot \
  --mode boot-chain
```

Observed result:

```text
Root-on-ZFS target validation: OK
```

This proves the installed target had the expected mounted root dataset, ESP
policy, pool bootfs, root dataset properties, LUKS mapper, fstab policy, hostid,
zpool cache, root-on-ZFS command line, and UKI artifacts at the time of
validation.

## Issue 1: Home Organization Ownership During Install

The first bootstrap attempt failed during `provision-user-app-config`:

```text
/home/margine-user/.local/bin/margine-home-configure-xdg-user-dirs:
line 154: /home/margine-user/.config/gtk-3.0/bookmarks: Permission denied
```

Cause:

- application config provisioning had already copied `~/.config/gtk-3.0`;
- the directory could remain owned by root;
- `provision-home-organization` then ran the XDG/bookmark helper as the target
  user before fixing ownership.

Fix:

- `provision-home-organization` now prepares and chowns user-writable config
  paths before running the user helpers;
- final ownership repair now skips paths that do not exist instead of assuming
  the whole layout is present.

Validation:

- `bash -n scripts/provision-home-organization`
- `shellcheck scripts/provision-home-organization`
- `./scripts/validate-home-organization-baseline`
- `./scripts/validate-installation-pipeline`

## Issue 2: Live ISO Detach Failure After Successful Validation

After the boot-chain validator passed, the conservative detach path failed:

```text
umount: /mnt: target is busy
cannot unmount '/mnt': pool or dataset is busy
```

Diagnostics showed no direct file references under `/mnt`, but multiple live
ISO service mount namespaces still contained:

```text
rpool/ROOT/default  /mnt
```

Examples included `upowerd`, `power-profiles-daemon`, `systemd-resolved`,
`systemd-networkd`, `dbus-broker-launch`, `ananicy-cpp`, `NetworkManager`,
`polkitd`, `systemd-logind`, and `ModemManager`.

The final disposable-live recovery path also failed, so the VM was powered off
after the successful boot-chain validation. That is acceptable only as a final
action for a disposable VM whose boot-chain gate already passed. It is not a
clean detach and must not be treated as normal success.

## Root Cause Hypothesis

`mount-zfs-root-target` already makes the current live mount namespace private
before importing an existing pool. The first-install storage path did not do the
same before creating and mounting the new root pool.

On a graphical live ISO, this can allow live services to retain `/mnt` ZFS
mounts in their own mount namespaces before the later mount helper ever runs.
The unmount helper can diagnose and try to clean that state, but it should not
be the normal expected path.

## Issue 3: Installed VM Boot Panic After a Passing Gate

The first installed-VM boot reached the kernel and then panicked before
userspace:

```text
Kernel panic - not syncing: Attempted to kill init! exitcode=0x00000100
PID: 1 Comm: init
```

Inspection of the generated UKI showed:

- the embedded command line was correct:
  `cryptdevice=UUID=...:cryptroot root=ZFS=rpool/ROOT/default`;
- the initramfs included ZFS and dm-crypt support;
- the initramfs did not include the VirtIO block stack needed by this QEMU
  disk, including `virtio_blk`, `virtio_pci`, and `virtio_ring`.

The most likely failure mode is therefore:

1. the kernel starts from the UKI;
2. initramfs starts `/init`;
3. the initramfs cannot see the virtual root disk;
4. the `encrypt` hook cannot resolve the LUKS UUID;
5. ZFS cannot import the root dataset;
6. `/init` exits and the kernel panics.

Why the previous validator missed it:

- it checked the mounted target, pool state, cmdline text, Limine config and
  UKI file presence;
- it did not inspect the actual UKI initramfs module inventory.

The underlying provisioning bug was the mkinitcpio `autodetect` assumption.
The boot chain is generated inside a live chroot, so autodetect describes the
live ISO environment, not the eventual QEMU or bare-metal root disk.

## Follow-Up Fixes

`provision-storage-zfs-root` now calls a new
`prepare_private_live_mount_namespace` step before touching target mounts:

```bash
install -d "$target_root"
mount --make-rprivate /
```

The installation pipeline validator now checks that the storage path contains
this guard.

`provision-initial-boot-chain-zfs` now preloads root-critical storage modules
in `/etc/mkinitcpio.conf` and disables live-ISO `autodetect` for the primary
root-on-ZFS UKI:

```bash
MODULES=(zfs virtio_pci virtio_blk virtio_scsi virtio_ring virtio nvme ahci sd_mod)
HOOKS=(base udev microcode modconf kms keyboard keymap consolefont block encrypt zfs filesystems)
```

`validate-root-zfs-target --mode boot-chain` now inspects the primary and
fallback UKIs with `lsinitcpio -a` and rejects a target whose initramfs lacks
ZFS, dm-crypt, VirtIO block, NVMe, AHCI or `sd_mod` support unless that support
is built into the target kernel.

Next validation expectation:

- a fresh VM build should create storage with the live namespace already private;
- `unmount-zfs-root-target --live-iso-recovery` should become exceptional, not
  the expected end-of-install path;
- a boot-chain gate must fail before reboot if generated UKIs cannot see common
  QEMU and bare-metal root disks;
- a successful run should end with the pool exported and the LUKS mapper closed.

## Final Repair Result

After the boot-chain fix was copied through the live ISO 9p mount, the same VM
was repaired with:

```bash
/root/margine-repo/scripts/repair-zfs-root-boot-chain --flavor cachyos --live-iso-recovery
```

Observed final result:

```text
Root-on-ZFS target validation: OK
UKI initramfs root modules: OK
/dev/mapper/cryptroot is inactive.
=== DONE ===
```

This confirms the corrected boot-chain validator accepts target-kernel built-in
drivers, rejects genuinely missing root-critical initramfs support, and that the
repair path can now cleanly detach the live target after validation.

Regression coverage now lives in `validate-installation-pipeline`:

- root-on-ZFS storage provisioning must make the live mount namespace private;
- root-on-ZFS mkinitcpio generation must avoid live-ISO `autodetect`;
- root-on-ZFS mkinitcpio generation must preload common VM and bare-metal root
  disk modules;
- `validate-root-zfs-target --mode boot-chain` must inspect real UKI initramfs
  contents with `lsinitcpio -a`;
- the validator must account for modules compiled directly into the target
  kernel through `modinfo -b "$target_root" -k "$kernel_version"`.

## Issue 4: Graphical Session Smoke Test Over SSH

After the repaired VM booted, Hyprland reached the wallpaper and accepted login,
but the first visual smoke test showed no Waybar and the Walker hotkey did not
open the launcher.

The QEMU validation SSH helper was enabled from inside the guest:

```bash
sudo mount -t 9p -o trans=virtio,version=9p2000.L,msize=262144 margine /mnt
sudo /mnt/enable-vm-ssh
```

The first SSH attempts reached TCP port 2223 but timed out during banner
exchange until `sshd` was restarted in the guest. After that, host-side
diagnostics confirmed:

- `Hyprland` was running;
- `walker.service` and `elephant.service` were active;
- no user systemd units were failed;
- `waybar` was not running until `~/.config/waybar/launch.sh` was invoked
  manually.

Host-side inspection showed the QEMU user-networking forward listening with a
single-entry backlog:

```text
LISTEN 0 1 0.0.0.0:2223 users:(("qemu-system-x86",...))
```

That makes the validation SSH path sensitive to multiple short-lived or
parallel probes. A stuck or slow banner exchange can block subsequent host-side
diagnostics even though the guest is otherwise alive. Prefer one SSH transport
at a time for QEMU `hostfwd` sessions, and bundle file refreshes into a single
tar-over-SSH stream when possible.

Waybar then started successfully on the VM output:

```text
Bar configured (width: 1280, height: 36) for output: Virtual-1
```

The Walker failure had a concrete wrapper bug. The VM did not provide `nc`, and
`margine-launcher-walker` removed the live Walker socket whenever the socket
existed but `nc -U` was unavailable. That left an active service without its
socket path and made the hotkey appear inert.

Fix:

- `margine-launcher-walker` no longer depends on `nc`;
- the wrapper removes `walker.sock` only when no Walker process is running;
- `margine-import-session-environment`, `margine-launcher-walker`,
  `margine-elephant-service`, Waybar and SwayNC launchers now force
  `XDG_SESSION_TYPE=wayland` for the Margine Hyprland session instead of
  preserving `XDG_SESSION_TYPE=tty` from SSH diagnostics;
- `validate-installation-pipeline` now rejects reintroducing the netcat socket
  dependency and checks that graphical-session helpers force Wayland session
  identity.

Operational note:

- during QEMU validation, avoid running multiple simultaneous SSH probes
  against the slirp-forwarded guest until `sshd` health is known;
- if `ssh` reaches TCP but reports `Connection timed out during banner
  exchange`, restart `sshd` in the guest and resume with serialized host-side
  SSH commands;
- if the guest accepts login graphically but Waybar/Walker are missing, first
  enable the validation SSH helper and inspect user services, Hyprland layers,
  `~/.cache/waybar.log`, and `/run/user/$uid/walker/walker.sock` from the host.

## Issue 5: First-Boot Home Layout and Privacy Indicator Drift

After login, the new `~/data`, `~/dev`, and `~/scratch` roots existed, but
localized legacy XDG folders such as `~/Documenti`, `~/Scaricati`,
`~/Immagini`, and `~/Scrivania` were still visible. The VM XDG mapping was
correct, but the empty legacy directories created by desktop defaults had not
been removed.

The VM also had no custom folder icons after install. Running
`margine-home-configure-folder-icons --apply` from the active graphical session
successfully wrote GIO `metadata::custom-icon` entries for the new roots. That
confirms the icon resolver was correct and the missing piece was first-login
session refresh of per-user GIO metadata.

A follow-up visual check showed that this was still not strict enough. Some
folders were pinned to blue, low-resolution assets such as:

```text
/usr/share/icons/Adwaita/16x16/places/folder-download.png
/usr/share/icons/Adwaita/16x16/places/folder-documents.png
```

Those paths came from the resolver consulting the active theme before
`Adwaita-yellow`, then accepting PNG assets from the first match. Nautilus then
upscaled those 16 px icons in icon view.

Fix:

- `margine-home-configure-xdg-user-dirs` now removes only empty legacy XDG
  directories after writing the new mapping and GTK bookmarks;
- non-empty legacy directories are preserved for explicit manual migration;
- GTK/Nautilus bookmarks now match the compact host/template baseline:
  Documents, Downloads, Pictures, Music, Videos, Shared, Projects,
  Development, and Scratch;
- `margine-apply-desktop-defaults` reruns the folder icon helper from the
  graphical session so GIO metadata is refreshed after first login;
- `margine-home-configure-folder-icons` now prefers `Adwaita-yellow` scalable
  SVG folder icons before the active theme, falls back to a generic yellow
  `folder.svg` before any blue-prone theme, and no longer pins PNG folder icons
  into GIO metadata.

A final comparison against the host GIO metadata tightened the semantic mapping
for prominent roots: `data/library` now uses `folder-books`, `data/work` uses
`folder-work`, `data/media` uses `folder-camera`, and `data/library/software`
uses `folder-appimage`. The home-organization validator now checks these exact
host-reference mappings, not only the yellow/scalable icon policy.

The Waybar privacy indicator showed a camera icon in the VM even though the
guest had no `/dev/video*` or `/dev/media*` devices. The helper enabled
`nullglob`, then invoked `lsof -w -n /dev/video* /dev/media*`; with no matching
paths, the command became `lsof -w -n` and scanned all open files. Hyprland
dmabuf entries were then misclassified as camera clients.

Fix:

- `privacy-device-status` now builds an explicit list of existing video/media
  devices;
- if the list is empty, it returns before calling `lsof`;
- direct device and default microphone probes are bounded with `timeout 2`;
- regression coverage rejects reintroducing the unscoped `lsof` scan.
