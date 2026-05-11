# Root-on-ZFS update snapshots and rollback

This runbook explains the current Margine root-on-ZFS update and rollback model.
It is intentionally specific to the first `update-all` implementation used by
`margine-cachyos` validation VMs.

## Mental model

Margine does not currently perform an in-place `zfs rollback` of the primary
root dataset during boot.

The current model is:

1. `update-all` validates the active root-on-ZFS boot chain.
2. `update-all` creates a pre-update snapshot of the primary root dataset.
3. `update-all` clones that snapshot into a separate bootable root dataset.
4. `update-all` builds the pre-update ZFS boot artifacts.
5. `update-all` freezes a clone-specific rollback UKI on the ESP.
6. `update-all` publishes a Limine `/Rollback` entry for the clone before
   package mutation starts. The entry points at the frozen rollback UKI, not at
   the mutable shared recovery UKI.
7. The primary update continues on `rpool/ROOT/default`.
8. If the updated primary boot path is broken, the operator selects the
   rollback entry in Limine.
9. Limine boots the clone directly with `root=ZFS=<clone-dataset>`.

So the rollback entry is a bootable root dataset clone, not the original
snapshot mounted directly and not a permanent promotion of that clone.

The clone and its rollback UKI are a consistency pair. This matters after kernel
updates: the post-update shared UKIs may no longer match the modules inside the
pre-update clone. A rollback entry must therefore keep pointing at the frozen
pre-update UKI that was built before package mutation.

## Dataset roles

The primary root dataset is:

```text
rpool/ROOT/default
```

The bootable rollback datasets are created as siblings under the same parent:

```text
rpool/ROOT/margine-pre-update-YYYYMMDD-HHMMSS
```

The pool `bootfs` remains pointed at the primary root:

```text
rpool bootfs rpool/ROOT/default
```

That is expected. Rollback entries do not require changing `bootfs` because
they carry an explicit kernel command line:

```text
root=ZFS=rpool/ROOT/margine-pre-update-YYYYMMDD-HHMMSS
```

## What update-all creates

For each real root-on-ZFS `update-all` run, the current implementation creates
one mandatory pair:

```text
rpool/ROOT/default@margine-pre-update-YYYYMMDD-HHMMSS
rpool/ROOT/margine-pre-update-YYYYMMDD-HHMMSS
```

The first object is a snapshot. The second object is a clone of that snapshot.

The clone is marked with ZFS user properties:

```text
org.margine:bootenv=pre-update
org.margine:origin-snapshot=rpool/ROOT/default@margine-pre-update-YYYYMMDD-HHMMSS
org.margine:description=margine pre-update rollback environment
org.margine:created=<ISO timestamp>
```

The clone is created with:

```text
mountpoint=/
canmount=noauto
```

This matches the primary root dataset policy. The dataset should not be mounted
automatically by generic ZFS service ordering; it is selected explicitly by the
initramfs through `root=ZFS=...`.

After the pre-update boot artifacts are built, `update-all` copies the recovery
UKI to a clone-specific path such as:

```text
/boot/EFI/Linux/margine-rollback/rpool-ROOT-margine-pre-update-YYYYMMDD-HHMMSS.efi
```

The clone records that path with:

```text
org.margine:rollback-uki=boot():/EFI/Linux/margine-rollback/rpool-ROOT-margine-pre-update-YYYYMMDD-HHMMSS.efi
```

If Secure Boot signing material is initialized, the frozen UKI is signed and
enrolled with `sbctl` before the package update starts.

## Creation-time validation gate

Before `update-all` starts the package transaction, it must validate the complete
rollback publication chain. The dedicated gate is:

```bash
sudo /usr/local/lib/margine/scripts/validate-zfs-rollback-boot-environment \
  --mode published \
  --dataset rpool/ROOT/margine-pre-update-YYYYMMDD-HHMMSS \
  --snapshot rpool/ROOT/default@margine-pre-update-YYYYMMDD-HHMMSS \
  --target-root /
```

The check is deliberately stricter than the generic root-on-ZFS target
validator. It fails the update before package mutation if any of these facts is
false:

```text
rpool bootfs is still rpool/ROOT/default
the rollback dataset exists below rpool/ROOT
org.margine:bootenv=pre-update is set on the clone
the clone origin points to the expected primary-root snapshot
the origin snapshot still exists
mountpoint=/ and canmount=noauto are set on the clone
org.margine:rollback-uki points at a clone-specific frozen UKI
the frozen UKI exists on the ESP
Limine has a /Rollback menu entry for root=ZFS=<clone>
Limine points that entry at the frozen UKI, not at a mutable shared UKI
```

This gate is what prevents the failure class seen on the Btrfs host recovery
path: an old userspace/root tree booted with a newer kernel or UKI.

## What update-all snapshots

The dedicated root-on-ZFS update path snapshots only the primary root dataset:

```text
rpool/ROOT/default
```

This is deliberate. It keeps system rollback coherent for the parts that define
the booted OS:

```text
/usr
/etc
/opt
/var/lib/pacman
/var/lib/systemd
```

Those paths live inside the root dataset in the current model.

The following datasets are not part of the root pre-update rollback snapshot:

```text
rpool/home
rpool/root
rpool/var/log
rpool/var/cache
rpool/var/tmp
rpool/data
rpool/games
rpool/srv
rpool/containers
rpool/machines
rpool/vm
```

The most important consequence is that a rollback boot environment restores the
system root view, but it does not roll back user data, logs, caches, games,
containers, VMs, or service data.

That is intentional for this phase:

- `/home` should not be silently reverted by a system package rollback.
- `/games` is large, reinstallable, and intentionally excluded from root-like
  snapshot retention.
- VM/container datasets are high churn and must not be captured by every system
  update unless a later explicit policy says so.
- `/boot` is the ESP, not ZFS. It is regenerated and validated, not snapshotted
  by ZFS.

## Limine entries

The ZFS boot-chain provisioner scans:

```text
rpool/ROOT
```

It renders entries only for datasets that satisfy all of these rules:

```text
org.margine:bootenv=pre-update
origin contains a ZFS snapshot
dataset is below rpool/ROOT
```

The rendered menu is:

```text
/Rollback
  /Pre-update YYYY-MM-DD HH:MM
```

The default entry limit is `8`. This is a display limit, not a retention policy.
If more than eight marked clones exist, Limine shows the eight newest entries
generated by `generate-zfs-boot-environment-entries`.

For new rollback clones, the rendered entry path comes from
`org.margine:rollback-uki`. Older clones without that property fall back to the
shared recovery UKI path and should be treated as legacy validation artifacts,
not as the target production guarantee.

## Retention and pruning

Automatic pruning of root rollback snapshots and clones is intentionally not
enabled inside `update-all`.

Current behavior:

- each real root-on-ZFS update creates one root snapshot and one bootable clone;
- existing rollback clones remain available until manually removed;
- Limine generation shows up to the configured entry limit;
- old clones are not destroyed automatically by `update-all`;
- old snapshots are not destroyed automatically by `update-all`.

This is conservative by design. Deleting the wrong ZFS object can remove the
only known-good rollback path.

Use the pruning helper for operator-driven retention. Without `--destroy`, it is
read-only and prints the plan:

```bash
sudo /usr/local/lib/margine/scripts/prune-zfs-rollback-boot-environments --keep 3
```

Apply the plan only after the primary boot path has been validated:

```bash
sudo /usr/local/lib/margine/scripts/validate-root-zfs-target --target-root / --mode boot-chain
sudo /usr/local/lib/margine/scripts/validate-zfs-rollback-boot-environment --mode published --target-root /
sudo /usr/local/lib/margine/scripts/prune-zfs-rollback-boot-environments --keep 3 --destroy
```

The helper refuses destructive pruning unless the active root is the primary
dataset, keeps at least one rollback boot environment, validates the newest
published rollback before destruction, destroys the clone before the origin
snapshot, removes only frozen UKIs under `EFI/Linux/margine-rollback`, and
republishes Limine after pruning.

Important ZFS dependency rule:

```text
rpool/ROOT/default@margine-pre-update-...
```

cannot normally be destroyed while:

```text
rpool/ROOT/margine-pre-update-...
```

still depends on it as its clone origin. Destroy the clone first, or design a
future promotion workflow. Margine does not yet automate clone promotion.

## Sanoid is separate

Sanoid is used for local automatic snapshots in the non-root ZFS adoption model.
It is not the current root rollback mechanism.

The root-on-ZFS `update-all` pre-update snapshot is explicit and update-bound.
It does not come from Sanoid.

The current Sanoid baseline is aimed at non-root datasets such as data/archive
style pools and explicitly avoids treating root rollback as generic periodic
data retention.

## How to verify a rollback boot

After selecting a rollback entry in Limine, verify the running kernel command
line:

```bash
cat /proc/cmdline
```

Expected rollback signal:

```text
root=ZFS=rpool/ROOT/margine-pre-update-YYYYMMDD-HHMMSS
```

Verify the mounted root:

```bash
findmnt /
```

Expected rollback signal:

```text
/  rpool/ROOT/margine-pre-update-YYYYMMDD-HHMMSS  zfs
```

Verify the primary dataset remains the pool bootfs:

```bash
sudo zpool get bootfs rpool
```

Expected:

```text
rpool  bootfs  rpool/ROOT/default  local
```

Verify the clone origin and Margine marker:

```bash
sudo zfs list -o name,origin,mountpoint,canmount,mounted rpool/ROOT/default rpool/ROOT/margine-pre-update-YYYYMMDD-HHMMSS
sudo zfs get org.margine:bootenv,org.margine:origin-snapshot,org.margine:description rpool/ROOT/margine-pre-update-YYYYMMDD-HHMMSS
```

Expected:

```text
origin = rpool/ROOT/default@margine-pre-update-YYYYMMDD-HHMMSS
mountpoint = /
canmount = noauto
mounted = yes for the selected rollback clone
org.margine:bootenv = pre-update
```

Verify the primary snapshot exists:

```bash
sudo zfs list -t snapshot | grep 'rpool/ROOT/default@margine-pre-update'
```

Run the dedicated active rollback validator:

```bash
sudo /usr/local/lib/margine/scripts/validate-zfs-rollback-boot-environment \
  --mode active \
  --target-root /
```

Expected result:

```text
ZFS rollback boot environment validation: OK
```

In `active` mode the validator also checks:

```text
findmnt / reports the rollback clone
/proc/cmdline contains root=ZFS=<rollback-clone>
the clone still has its frozen UKI property
Limine still contains the matching rollback entry
pool bootfs still points to the primary root
```

## How to read validation logs

Host-side QEMU validation logs are collected with:

```bash
cd /home/daniel/dev/margine-os-personal
./scripts/collect-qemu-root-zfs-validation-logs --user USERNAME --prompt-sudo
```

The logs are written under:

```text
build/qemu-root-zfs-validation-logs/YYYYMMDD-HHMMSS/
```

The key files are:

```text
guest-user.log
guest-root.log
summary.txt
```

For rollback verification, inspect:

```bash
rg -n 'root=ZFS|root-on-ZFS mounts|ZFS datasets|bootfs|margine-pre-update|org.margine|root validator|ZFS rollback validator|active rollback' build/qemu-root-zfs-validation-logs/YYYYMMDD-HHMMSS/*.log
```

Evidence of a successful rollback boot is:

```text
/proc/cmdline contains root=ZFS=rpool/ROOT/margine-pre-update-...
findmnt / reports rpool/ROOT/margine-pre-update-...
the clone exists below rpool/ROOT
the clone origin points to rpool/ROOT/default@margine-pre-update-...
the clone has org.margine:bootenv=pre-update
the Limine entry path points at /EFI/Linux/margine-rollback/<clone>.efi
validate-zfs-rollback-boot-environment --mode active reports OK
```

## Canary rollback test in QEMU

The strongest VM-level test is not only "the rollback entry boots". It must
also prove that root dataset changes are reverted while independent datasets are
not silently rolled back.

Use the host-side helper from `margine-os-personal` against the running QEMU
guest:

```bash
cd /home/daniel/dev/margine-os-personal
./scripts/qemu-root-zfs-rollback-canary-over-ssh --user danielitivov --seed --prompt-sudo
```

Then run the real update path from the host or from inside the guest:

```bash
ssh -t margine-zfs 'update-all --no-aur --no-flatpak --no-fwupd |& tee ~/update-all-zfs-real-$(date +%Y%m%d-%H%M%S).log'
```

Before rebooting, mutate the canaries on the updated primary root:

```bash
./scripts/qemu-root-zfs-rollback-canary-over-ssh --user danielitivov --mutate --prompt-sudo
```

Reboot the VM and select the newest Limine `/Rollback/Pre-update ...` entry.
After logging into that rollback boot, run:

```bash
./scripts/qemu-root-zfs-rollback-canary-over-ssh --user danielitivov --verify-rollback --prompt-sudo
```

Expected result:

```text
rollback canary validation: OK
```

The helper checks these facts:

```text
/ is mounted from rpool/ROOT/margine-pre-update-...
/proc/cmdline contains root=ZFS=rpool/ROOT/margine-pre-update-...
the active clone has org.margine:bootenv=pre-update
the root canary modified after update reverted to the pre-update content
the root canary deleted after update exists again
the root canary created after update is absent
the /home canary created after update is still present
the /games canary created after update is still present when /games is mounted
validate-zfs-rollback-boot-environment --mode active reports OK
```

This is the intended boundary. The rollback environment restores the OS root
dataset. It does not restore `/home`, `/games`, logs, caches, containers, VMs or
other dedicated datasets.

After the rollback boot has been validated, reboot back into the primary entry
and confirm that the system is again running from `rpool/ROOT/default`:

```bash
./scripts/qemu-root-zfs-rollback-canary-over-ssh --user danielitivov --status --prompt-sudo
```

Then remove the validation canaries from the active root and from the persistent
datasets:

```bash
./scripts/qemu-root-zfs-rollback-canary-over-ssh --user danielitivov --cleanup --prompt-sudo
```

The cleanup phase intentionally removes only canary files from the currently
active root plus `/home` and `/games`. It does not destroy rollback clones or
their source snapshots.

## Snapshot and rollback object policy

Each real root-on-ZFS `update-all` run creates these root rollback objects before
package mutation:

```text
rpool/ROOT/default@margine-pre-update-YYYYMMDD-HHMMSS
rpool/ROOT/margine-pre-update-YYYYMMDD-HHMMSS
/boot/EFI/Linux/margine-rollback/<clone>.efi
/boot/EFI/BOOT/limine.conf entry under /Rollback
```

The snapshot captures the root dataset only. Dedicated datasets such as `/home`,
`/games`, `/var/log`, `/var/cache`, `/var/tmp`, containers, machines, VM storage
and service data are outside the root rollback transaction. This is deliberate:
boot rollback must recover the operating system without rolling back personal
data, game libraries, logs or large mutable stores.

Rollback clones are boot environments, not automatic promotion targets. Booting a
rollback clone is a recovery action. Until a dedicated promotion workflow exists,
do not treat a rollback clone as the permanent root, do not rewrite `rpool
bootfs` to the clone, and do not merge clone changes back into
`rpool/ROOT/default`.

Retention is conservative for now. `update-all` publishes rollback entries but
does not automatically delete older clones or their source snapshots. Manual
cleanup must use the pruning helper after these checks pass:

```bash
sudo /usr/local/lib/margine/scripts/validate-root-zfs-target --target-root / --mode boot-chain
sudo /usr/local/lib/margine/scripts/validate-zfs-rollback-boot-environment --mode published --target-root /
sudo zfs list -t snapshot | grep margine-pre-update
sudo zfs list -o name,origin,mountpoint,canmount,mounted rpool/ROOT
sudo /usr/local/lib/margine/scripts/prune-zfs-rollback-boot-environments --keep 3
sudo /usr/local/lib/margine/scripts/prune-zfs-rollback-boot-environments --keep 3 --destroy
```

Destroy old rollback objects in dependency order: clone first, then source
snapshot. The helper enforces that order. Keep at least the newest known-good
rollback environment until a successful primary boot has been validated after the
update.

## Current validation caveat

Older installed validators expected `/` to always be `rpool/ROOT/default`.
That is correct for primary boot, but false for a selected rollback boot
environment. In a rollback session, `/` is expected to be the selected marked
clone.

The validator must therefore accept this shape:

```text
target root source = rpool/ROOT/margine-pre-update-...
kernel cmdline     = root=ZFS=rpool/ROOT/margine-pre-update-...
clone marker       = org.margine:bootenv=pre-update
clone origin       = rpool/ROOT/default@margine-pre-update-...
pool bootfs        = rpool/ROOT/default
```

## What rollback does not do yet

The current implementation does not yet:

- promote a rollback clone to become the new primary root;
- rewrite `rpool bootfs` to the rollback clone;
- merge rollback clone changes back into `rpool/ROOT/default`;
- prune old rollback clones automatically;
- prune old root pre-update snapshots automatically;
- snapshot `/home`, `/games`, VM/container datasets, or other non-root datasets
  as part of the root update transaction;
- roll back the ESP as a ZFS object.

Those are separate lifecycle decisions. They should be implemented only after
the bootable clone model is repeatedly validated.

## Operational guidance

Use the primary entry for normal daily boot.

Use a rollback entry when a package update breaks the primary boot path or the
desktop enough that the system is not usable.

After booting a rollback clone, treat it as a recovery environment until a
promotion or repair policy exists. Do not assume that running indefinitely from
the clone has become the new permanent state.

Before deleting rollback datasets, record:

```bash
sudo zfs list -t snapshot | grep margine-pre-update
sudo zfs list -o name,origin,mountpoint,canmount,mounted rpool/ROOT
sudo zfs get -r org.margine:bootenv,org.margine:origin-snapshot rpool/ROOT
sudo grep -n 'Rollback\|root=ZFS=rpool/ROOT/margine-pre-update' /boot/EFI/BOOT/limine.conf
```

Then destroy in dependency order:

```text
clone first, source snapshot second
```

Manual destruction should remain out of routine validation until an explicit
Margine pruning helper exists.
