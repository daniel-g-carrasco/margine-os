# Installation Guide

This guide documents the actual install path of `Margine` as it exists today.

It separates three different things that are easy to confuse:

- a working base installation
- SSH access to the installed system
- Secure Boot bootstrap with `sbctl`
- TPM2-backed automatic LUKS unlock

These are not currently completed by the same phase.

## 1. Current truth table

Today, the installer does:

- partition and encrypt the target disk with `LUKS2`
- create the `Btrfs` layout
- install the base system and desktop stack
- build the initial boot chain with `UKI` + `Limine`
- install recovery and snapshot baseline
- install the SSH package and the on-demand SSH helper scripts

Today, the installer does **not** automatically do:

- `sbctl create-keys` + `sbctl enroll-keys`
- firmware-side Secure Boot setup
- `systemd-cryptenroll --tpm2-device=auto`
- `crypttab` or initramfs integration for TPM2 auto-unlock
- automatic `sshd` enablement and firewall opening

That distinction must stay explicit.

## 2. Guided installation

From the live environment:

```bash
mkdir -p /root/margine-repo
mount -t 9p -o trans=virtio,version=9p2000.L margine /root/margine-repo
/root/margine-repo/scripts/install-live-iso-guided --product margine-public
```

The guided installer is now expected to:

1. ask essential questions
2. print a summary
3. ask for the final destructive confirmation
4. start the real installation

If it prints the summary and returns to the shell without the final confirmation,
that is a regression.

## 3. First boot after install

After the installer finishes:

1. power off the live environment
2. boot the installed disk
3. validate the system with:
   [05-post-install-validation.md](/home/daniel/dev/margine-os/docs/05-post-install-validation.md)

This first post-install validation should happen before trying to bootstrap
Secure Boot or TPM2.

If the repository evolves later, you do not need to reinstall the whole
machine just to pick up new package blocks or desktop/application payloads.

See:

- [12-post-install-layer-realignment.md](/home/daniel/dev/margine-os/docs/12-post-install-layer-realignment.md)

## 4. SSH access after install

`Margine` installs the SSH baseline, but it does not expose `sshd`
automatically.

The current model is:

- package installed
- config baseline installed
- helper installed
- service still off until the operator enables it explicitly

From inside the installed system:

```bash
sudo margine-enable-ssh-server
```

Disable again when no longer needed:

```bash
sudo margine-disable-ssh-server
```

QEMU validation VM connection example:

```bash
ssh -p 2222 daniel@127.0.0.1
```

Full SSH notes:

- [10-ssh-access.md](/home/daniel/dev/margine-os/docs/10-ssh-access.md)

## 5. Secure Boot with sbctl

`Margine` keeps Secure Boot bootstrap separate from the core installer on
purpose.

Current implementation:

- installer lays out EFI artifacts and UKIs
- `provision-secure-boot-preflight` exports current public keys and inspects the ESP before firmware work
- `provision-secure-boot` handles `sbctl` key creation and enrollment
- `refresh-efi-trust` handles signing and verification
- `update-all` can verify Secure Boot state later, but it is not the bootstrap
  step

### Important user step

On real hardware, Secure Boot key enrollment is not fully hands-off.

The firmware must allow custom key enrollment first. In practice this usually
means:

1. entering the UEFI setup
2. moving Secure Boot into `Setup Mode`, or clearing existing platform keys
3. booting back into `Margine`
4. running the Secure Boot bootstrap script

The script already expects this and will stop if the firmware is not in the
right state.

### Safe rollout order

Do not jump directly to `provision-secure-boot`.

The safer order is:

1. validate the base installation
2. run the Secure Boot preflight helper
3. enter firmware and move the machine to `Setup Mode`
4. run the Secure Boot bootstrap script
5. reboot and validate `sbctl`

Preflight helper:

```bash
sudo /usr/local/lib/margine/scripts/provision-secure-boot-preflight --esp-path /boot
```

Bootstrap:

```bash
sudo /usr/local/lib/margine/scripts/provision-secure-boot --esp-path /boot
```

By default, `provision-secure-boot` expects the recorded preflight stamp
created by the helper above. This is deliberate. It reduces the chance that an
operator jumps directly into key enrollment without first exporting the current
public-key state and inspecting the ESP.

Then reboot and confirm:

```bash
sudo sbctl status
sudo sbctl verify
```

### Why the VM shows sbctl warnings

The current QEMU validation flow installs `sbctl`, but it does not bootstrap its
keys during installation. Therefore:

- `/var/lib/sbctl/keys/...` does not exist yet
- `update-all` reaches the final `sbctl verify`
- verification warns, but the core package/update path can still complete

That is expected with the current flow, not a mystery failure.

## 6. TPM2-backed automatic LUKS unlock

This is the most important clarification.

`Margine` documents TPM2 in architecture notes, but the installer still does
**not** automate TPM2 enrollment directly during install.

What is true today:

- the installer does not auto-enroll TPM2
- the repository now provides a staged post-install TPM2 workflow
- the workflow is built around `systemd-cryptenroll` and `crypttab.initramfs`
- the workflow is intentionally split across two boots to avoid sealing TPM2
  against the wrong PCR state

So the correct statement today is:

- `LUKS2` is installed
- TPM2 tooling is versioned
- TPM2 auto-unlock is **not guaranteed by the installer alone**
- TPM2 auto-unlock is now a separate post-install rollout step

If your host already auto-unlocks LUKS via TPM2, that behavior is currently
meant to converge on the versioned staged workflow instead of staying as purely
host-specific state.

## 7. QEMU TPM2 validation

The QEMU harness can attach a virtual TPM when the host has `swtpm` installed. Without `swtpm`, TPM2 validation remains unavailable in the VM.

That means this VM is good for validating:

- installation
- desktop provisioning
- update pipeline
- boot artifact generation

But it is **not** sufficient to validate TPM2 auto-unlock end-to-end.

To validate TPM2 end-to-end in QEMU, use a host with `swtpm` available so that
the generated launchers expose a vTPM to the guest.

## 8. Operational policy

For now, the correct operational model is:

1. install the system
2. validate the base boot/desktop/update path
3. optionally enable SSH when remote validation is needed
4. bootstrap Secure Boot separately, with explicit user interaction in firmware
5. stage TPM2 auto-unlock and reboot once
6. enroll TPM2 on the final boot state and reboot again

The detailed operational guide now lives in:

- [11-boot-security-and-tpm2.md](/home/daniel/dev/margine-os/docs/11-boot-security-and-tpm2.md)

## 9. Dual-boot and pre-existing Secure Boot setups

The default `Margine` Secure Boot path is deliberately conservative:

- include Microsoft certificates
- include firmware builtin `db/KEK`
- export the current enrolled public keys before firmware changes

This protects the common cases:

- Windows present on the same machine
- OEM firmware paths that still depend on vendor certificates

But there is one case that still requires explicit operator judgment:

- another Linux installation already booting from its own custom Secure Boot key

In that case, do not continue blindly. `Margine` does not currently promise to
preserve arbitrary third-party custom keys automatically. Stop, export the
current enrolled public keys, document the other EFI loaders present, and only
then decide whether to migrate that machine to a unified key hierarchy.
`sbctl` supports advanced paths such as `--append` and `--custom`, but those are
intentionally left outside the default `Margine` flow.

## 10. Remaining follow-up work

The repository should grow the following pieces explicitly:

1. more automated TPM2 validation after reboot
2. a documented PCR-policy evolution path beyond the initial `7+11`
3. explicit dual-boot validation against real Windows/OEM cases
