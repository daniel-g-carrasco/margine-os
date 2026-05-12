# Root-on-ZFS Live Target Mounting Runbook

This runbook is the canonical live-ISO procedure for mounting, repairing, and
cleanly detaching a Margine root-on-ZFS target.

## Principles

- Do not run broad process killers such as `fuser -km /mnt`.
- Do not run a full live-ISO system upgrade to solve install-time package
  problems.
- Keep the installed target mounted under `/mnt` only for the duration of the
  repair or validation step.
- Use the Margine helpers first; manual commands are fallback diagnostics, not
  the normal path.
- Treat the live ISO as hostile mount-propagation territory. Desktop live media
  can have long-running services in separate mount namespaces; the Margine mount
  helper makes the current live mount namespace recursively private before
  importing ZFS so target mounts do not propagate into those services.
- After importing the pool with an altroot such as `/mnt`, mount root datasets
  with `zfs mount DATASET`. Do not manually mount a root dataset at `/mnt` with
  `mount -t zfs`; the live altroot can make `zfs get mountpoint` report `/mnt`
  even when the logical root mountpoint is `/`, and manual mounts make that
  state harder to validate safely.

## Mount Existing Target

From a fresh live ISO boot:

```bash
sudo mkdir -p /root/margine-repo
sudo mount -t 9p -o trans=virtio,version=9p2000.L margine /root/margine-repo
sudo /root/margine-repo/scripts/mount-zfs-root-target
```

Some live ISOs, including CachyOS desktop images, start from an unprivileged
live user. In that case, it is cleaner to switch to a root shell once after the
repository mount and run the remaining recovery or install commands without
repeating `sudo`:

```bash
sudo -i
cd /
```

Expected checks:

```bash
findmnt /mnt
findmnt /mnt/home
findmnt /mnt/boot
sudo zpool get bootfs rpool
sudo /root/margine-repo/scripts/validate-root-zfs-target --target-root /mnt
```

`/mnt` must be the root dataset, `/mnt/home` must be mounted when the target has
a dedicated home dataset, `/mnt/boot` must be the ESP, and `bootfs` must point to
the configured root dataset. The validator also checks the LUKS mapper, root
dataset properties, ESP mount hardening, and generated fstab policy.

The storage provisioner writes the canonical layout facts to:

```text
/run/margine-install/root-zfs.env
/mnt/etc/margine/install-layout.env
```

Recovery helpers read these manifests when present, so explicit `--pool-name`,
`--crypt-name`, `--luks-part`, and `--esp-part` overrides are only needed when
the manifest is absent or intentionally being overridden.

## Repair Login Or Desktop Payload

Use the repair helpers instead of manually copying desktop files:

```bash
sudo /root/margine-repo/scripts/repair-zfs-root-user-login --username USERNAME --leave-mounted
sudo /root/margine-repo/scripts/repair-zfs-root-desktop-session --username USERNAME --leave-mounted
```

If a helper is run without `--leave-mounted`, it will try to detach the target at
the end. If the target remains busy, use the clean detach procedure below.

## Repair Boot Chain After Broken Update

If an installed root-on-ZFS system reaches Limine but then fails with
`Failed to mount /sysroot`, treat the boot artifacts as suspect before changing
storage state. Known causes include a stale non-ZFS update runtime overwriting
`/etc/mkinitcpio.conf`, `/etc/kernel/cmdline`, UKIs or `limine.conf`, or a
root-on-ZFS update interrupted before the final ZFS boot-chain validation.

From a fresh live ISO boot:

```bash
sudo mkdir -p /root/margine-repo
sudo mount -t 9p -o trans=virtio,version=9p2000.L margine /root/margine-repo
sudo /root/margine-repo/scripts/repair-zfs-root-boot-chain --flavor cachyos --live-iso-recovery
```

The helper:

- bootstraps live ZFS tooling if needed;
- mounts the target through `mount-zfs-root-target`;
- refreshes the target repo copy at `/root/margine-os`;
- runs `provision-initial-boot-chain-zfs` in the target chroot;
- validates the target with `validate-root-zfs-target --target-root / --mode boot-chain`;
- detaches the target with `unmount-zfs-root-target --live-iso-recovery`.

Use `--leave-mounted` instead of `--live-iso-recovery` only when you intend to
continue inspecting the mounted target.

## Clean Detach

First try the conservative path:

```bash
cd /
sudo /root/margine-repo/scripts/unmount-zfs-root-target
```

Default mode never kills processes, never force-unmounts ZFS datasets, never
lazy-unmounts, and never force-exports the pool. If export fails, it prints
process references under `/mnt`.

Lines prefixed with `# current shell/script process tree` are diagnostic only:
the helper reports them so the caller can `cd /` or close that terminal, but it
does not terminate its own shell ancestry. Plain PID lines are external
processes that `--terminate-busy` can handle in a disposable live ISO. The
process table also reports whether a reference came from a direct link such as
`cwd` or `fd`, or from a memory map. The mount namespace table reports separate
mount namespaces that still contain the pool dataset.

When retained mount namespaces are present, the helper enters each namespace
with `nsenter` and unmounts the target tree there before retrying `zpool export`.
This handles live ISO services that inherited the `/mnt` ZFS mount without
killing those services or force-exporting the pool.

The helper deliberately keeps lazy unmount disabled during the first cleanup
passes, even when `--live-iso-recovery` is selected. Lazy unmount is only a final
recovery step because it can hide `/mnt` from diagnostics while the kernel still
keeps the ZFS pool busy.

If `findmnt /mnt` reports `airootfs`, `overlay`, or anything other than
`rpool/ROOT/default`, the target root is not actually mounted even if child
mounts such as `/mnt/home` or `/mnt/boot` exist. Rerun `mount-zfs-root-target`;
the helper clears that stale non-ZFS `/mnt` mount and mounts the root dataset
before continuing.

If the diagnostics show external processes under `/mnt`, close them or run the
explicit recovery mode:

```bash
cd /
sudo /root/margine-repo/scripts/unmount-zfs-root-target --terminate-busy
```

If the diagnostics show no external busy processes but the root dataset remains
busy, use the ZFS-specific force-unmount step before the final recovery path:

```bash
cd /
sudo /root/margine-repo/scripts/unmount-zfs-root-target --force-zfs-unmount
```

If a disposable live-ISO validation session is still stuck, the final recovery
path is:

```bash
cd /
sudo /root/margine-repo/scripts/unmount-zfs-root-target --terminate-busy --kill-busy --force-zfs-unmount --lazy-unmount --force-export
```

The equivalent shorthand is:

```bash
cd /
sudo /root/margine-repo/scripts/unmount-zfs-root-target --live-iso-recovery
```

Use the final path only inside the live ISO, never from an installed system.
It is intended for the exact disposable-live-media case where services have
retained the target ZFS mount in separate mount namespaces and normal export is
therefore blocked even though no direct file references are visible.

If even `--live-iso-recovery` reports `cannot export 'rpool': pool is busy`
after diagnostics show no direct processes and no retained mount namespaces, do
not keep touching the target from that live session. Reboot the live ISO and
rerun the mount or repair helper. A previous early lazy detach can leave kernel
references alive but invisible to user-space diagnostics until the live session
ends.

## Manual Diagnostics

If the helper cannot export the pool:

```bash
findmnt -R /mnt
sudo zfs mount
sudo zpool status rpool
sudo /root/margine-repo/scripts/unmount-zfs-root-target
```

Do not use `fuser -km /mnt`: `-k` kills matching processes and `-m` works at the
filesystem/mount level, which is too easy to aim at the wrong live session.

## After Detach

A clean detach means:

```bash
findmnt -R /mnt
sudo zpool list rpool
sudo cryptsetup status cryptroot
```

The first command should show no mounted target subtree, the pool should be
exported, and the mapper should be closed unless `--keep-crypto` was used.

After booting the installed VM, enable SSH with the generated QEMU validation
key from the mounted repository instead of copying the key by hand. Run this
from the normal user shell, not from an interactive `sudo -i` root shell, so
`$USER` expands to the guest login user:

```bash
sudo modprobe 9p 9pnet 9pnet_virtio
sudo mkdir -p /root/margine-repo
sudo mountpoint -q /root/margine-repo || sudo mount -t 9p -o trans=virtio,version=9p2000.L,msize=262144 margine /root/margine-repo
sudo /root/margine-repo/scripts/enable-qemu-validation-ssh --user "$USER"
```

If you are already inside `sudo -i`, use the real guest username explicitly:

```bash
/root/margine-repo/scripts/enable-qemu-validation-ssh --user USERNAME
```

The SSH helper also starts the validation idle inhibitor from a temporary local
guest copy. Collect evidence from the host instead of relying on screenshots:

```bash
cd /home/daniel/dev/margine-os-personal
./scripts/collect-qemu-root-zfs-validation-logs --user USERNAME --prompt-sudo
```

Do not rely on a separate host-side inhibitor command as the first power
management guard: if the guest has already idled or suspended, SSH may be the
first component that fails. `enable-qemu-validation-ssh` starts the inhibitor
inside the guest before the host collector is used. The host-side
`enable-qemu-validation-inhibit-over-ssh` helper remains useful for status,
re-enable, or disable operations because it uploads the guest helper to `/tmp`
first and executes it from the guest's local filesystem instead of from the 9p
mount.

The resulting logs live under
`build/qemu-root-zfs-validation-logs/TIMESTAMP/` and include mount state, ZFS
state, boot artifacts, host-health validators, journals, and an `update-all`
root-on-ZFS dry-run. With `--prompt-sudo`, enter the
guest user's sudo password in the host terminal when prompted; root output is
still written to `guest-root.log`. The collector also records the systemd
validation inhibitor and the user `keep-awake.service` state.

On a root-on-ZFS guest, `update-all --dry-run --no-aur --no-flatpak --no-fwupd`
must show the dedicated ZFS path: root validator, strict root dataset snapshot,
package phases, `provision-initial-boot-chain-zfs`, and final validator. If an
older VM still runs an outdated update runtime and fails with
`Failed to mount /sysroot`, recover from the live ISO with
`repair-zfs-root-boot-chain --live-iso-recovery`; the repair path refreshes the
installed update runtime so the stale generic updater cannot run again.

After collection, disable the validation-only inhibitor inside the guest:

```bash
./scripts/enable-qemu-validation-inhibit-over-ssh --user USERNAME --disable --prompt-sudo
```
