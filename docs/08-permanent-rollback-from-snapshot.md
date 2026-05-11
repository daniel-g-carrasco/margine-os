# Permanent Rollback From a Booted Snapshot

This document describes the **current v1** rollback model in `Margine`.

## Short answer

If `Primary` breaks:

1. boot a snapshot entry from `Limine`
2. confirm that the snapshot state is the one you want
3. do the **permanent rollback from outside that read-only snapshot boot**

Do **not** treat the snapshot boot itself as the permanent rollback.

## Why

Snapshot entries in `Margine` boot:

- `margine-recovery.efi`
- a specific `Snapper` root snapshot
- in `ro`
- without mounting the live ESP at `/boot`

This is a safer inspection path.

It is not designed to mutate the system in place and replace the normal `@`
root subvolume automatically.

The boot entry generation applies to old snapshots too, because the generated
`Limine` command line points at an existing snapshot. It does **not** rewrite
the contents of old snapshots. Their old `/etc/fstab`, packages and module
state remain exactly as they were. For that reason snapshot entries mask
`boot.mount`: `/boot` is the current ESP outside the Btrfs snapshot and is not
required for a temporary read-only recovery session.

## Temporary recovery vs permanent rollback

### Temporary recovery

Use a snapshot entry when you want to:

- get back into an older state quickly
- inspect what changed
- confirm that an older root still boots
- recover files or configuration references

After rebooting into `Primary`, the normal root subvolume is used again.

### Permanent rollback

Use a permanent rollback when you want the machine to boot the older root state
as the normal system again.

That requires an explicit operator action.

## What the storage model changes

### On a full `Margine` installation

`Margine` installs the Btrfs target layout from
[storage-subvolumes.txt](/home/daniel/dev/margine-os/manifests/storage-subvolumes.txt).

That means:

- `@` is the system root
- `@home` is separate
- `@snapshots` is separate
- noisy/runtime areas are split out

So a permanent rollback mainly affects the system state in `@`, not every path
on the machine.

### On your current host

Your host is **not** yet the full target storage layout from `Margine`.

So snapshot-based rollback on the host is still useful, but it does not carry
the same separation quality as a fresh `Margine` installation.

That difference must be kept in mind while debugging.

## Current safe operator procedure

The current `v1` permanent rollback procedure is:

1. Boot the snapshot entry in `Limine`.
2. Verify that it is really the desired snapshot.
3. Reboot into a writable maintenance environment.
4. Promote the selected snapshot into the normal `@` root layout.
5. Boot `Primary`.
6. Re-run the boot baseline to re-sync the boot chain if needed.

## Step 1. Verify the booted snapshot

From the booted snapshot session:

```bash
findmnt -no SOURCE /
cat /proc/cmdline
```

You should see:

- root mounted from `@snapshots/<N>/snapshot`
- `ro`
- `systemd.mask=boot.mount` in `/proc/cmdline`

If an old snapshot drops into emergency mode with `Failed to mount /boot`, the
boot menu was generated before the `boot.mount` mask was added. Boot `Primary`
or a live ISO, regenerate the host boot baseline, then retry the snapshot entry.

If an old snapshot boots but the touchpad does not work, first assume an input
module gap rather than a failed rollback. The Framework touchpad is an I2C HID
device; keyboard input may be available from the initramfs while the touchpad
driver would otherwise need matching modules from the old read-only snapshot
root. The Margine mkinitcpio baseline includes `i2c_hid_acpi`, `i2c_hid`, and
`hid_multitouch` to keep this recovery path usable after UKIs are regenerated.

If an old snapshot boots with no touchpad, missing Wi-Fi, missing dock/display
support, or a long `/dev/zram0` wait, treat it as a kernel/userspace coherence
failure in the temporary Btrfs recovery path. The host boot menu is using the
current ESP and current UKIs to inspect an old read-only root snapshot; old
userspace, old module trees, old generated units and the current kernel are not
a guaranteed boot environment. Do not use that failure mode as a production
requirement for Margine root-on-ZFS. The ZFS update path must instead publish a
coherent rollback clone with its matching frozen UKI.

## Step 2. Use a writable maintenance environment

Use one of these:

- live ISO
- a future dedicated rollback helper
- a writable maintenance path you explicitly trust

Do **not** perform the permanent rollback from the read-only snapshot boot.

## Step 3. Promote the snapshot manually

This is the current manual model.

Example outline from a live ISO:

```bash
crypt_name=root
cryptsetup open /dev/<root-device> "$crypt_name"
mount -o subvol=/ "/dev/mapper/${crypt_name}" /mnt

# move the current system root out of the way
mv /mnt/@ /mnt/@rollback-old-$(date +%F-%H%M%S)

# create a writable clone from the chosen snapshot
btrfs subvolume snapshot /mnt/@snapshots/<N>/snapshot /mnt/@
```

After that:

```bash
umount /mnt
cryptsetup close "$crypt_name"
reboot
```

Then boot `Primary`.

## Step 4. Re-sync the boot chain

Once the system boots again on the restored `@`, run:

```bash
sudo /home/daniel/dev/margine-os/scripts/provision-host-root-baseline
```

This re-checks:

- the currently active LUKS mapper name (`root` on Daniel's Arch/Btrfs host,
  `cryptroot` on the current Margine VM defaults);
- the Btrfs root UUID;
- the LUKS container UUID;
- the generated Limine primary, manual recovery and snapshot recovery cmdlines.

- fingerprint baseline
- snapper baseline
- generated recovery entries
- `limine.conf`
- `enroll-config`
- EFI signing / verification

## Important limitation of v1

`Margine v1` does **not** yet ship an automated "promote this snapshot to the
live root" command.

So today:

- booting a snapshot is implemented
- permanent rollback is documented and manual
- full automation of snapshot promotion is still future work
