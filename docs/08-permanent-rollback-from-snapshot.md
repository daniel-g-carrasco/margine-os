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

This is a safer inspection path.

It is not designed to mutate the system in place and replace the normal `@`
root subvolume automatically.

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
cryptsetup open /dev/<root-device> cryptroot
mount -o subvol=/ /dev/mapper/cryptroot /mnt

# move the current system root out of the way
mv /mnt/@ /mnt/@rollback-old-$(date +%F-%H%M%S)

# create a writable clone from the chosen snapshot
btrfs subvolume snapshot /mnt/@snapshots/<N>/snapshot /mnt/@
```

After that:

```bash
umount /mnt
cryptsetup close cryptroot
reboot
```

Then boot `Primary`.

## Step 4. Re-sync the boot chain

Once the system boots again on the restored `@`, run:

```bash
sudo /home/daniel/dev/margine-os/scripts/provision-host-root-baseline
```

This re-checks:

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
