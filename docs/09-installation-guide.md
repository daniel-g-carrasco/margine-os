# Installation Guide

This guide documents the actual install path of `Margine` as it exists today.

It separates three different things that are easy to confuse:

- a working base installation
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

Today, the installer does **not** automatically do:

- `sbctl create-keys` + `sbctl enroll-keys`
- firmware-side Secure Boot setup
- `systemd-cryptenroll --tpm2-device=auto`
- `crypttab` or initramfs integration for TPM2 auto-unlock

That distinction must stay explicit.

## 2. Guided installation

From the live environment:

```bash
mkdir -p /root/margine-repo
mount -t 9p -o trans=virtio,version=9p2000.L margine /root/margine-repo
/root/margine-repo/scripts/install-live-iso-guided --product margine-public
```

Private CachyOS product example:

```bash
/root/margine-repo/scripts/install-live-iso-guided --product margine-cachyos --flavor cachyos
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

## 4. Secure Boot with sbctl

`Margine` keeps Secure Boot bootstrap separate from the core installer on
purpose.

Current implementation:

- installer lays out EFI artifacts and UKIs
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

### What to run on hardware

After the base system is installed and validated:

```bash
sudo /usr/local/lib/margine/scripts/provision-secure-boot --esp-path /boot
```

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

## 5. TPM2-backed automatic LUKS unlock

This is the most important clarification.

`Margine` documents TPM2 in architecture notes, but the installer does **not**
currently automate TPM2 enrollment.

What is missing today in the versioned install path:

- no call to `systemd-cryptenroll --tpm2-device=auto`
- no versioned `crypttab` entry with `tpm2-device=auto`
- no versioned initramfs path specifically enabling TPM2 unlock
- no post-install validation that proves TPM2 unlock is actually working

So the correct statement today is:

- `LUKS2` is installed
- TPM2 tooling packages may be present
- TPM2 auto-unlock is **not yet guaranteed by the installer**

If your host already auto-unlocks LUKS via TPM2, that behavior is currently
host-specific state and is not yet captured by the repository well enough.

## 6. Why the current VM cannot validate TPM2 unlock

The current QEMU harness does not attach a virtual TPM device.

That means this VM is good for validating:

- installation
- desktop provisioning
- update pipeline
- boot artifact generation

But it is **not** sufficient to validate TPM2 auto-unlock end-to-end.

To validate TPM2 in QEMU, the harness would need an explicit `swtpm` / vTPM
device wired into the guest.

## 7. Operational policy

For now, the correct operational model is:

1. install the system
2. validate the base boot/desktop/update path
3. bootstrap Secure Boot separately, with explicit user interaction in firmware
4. treat TPM2 auto-unlock as a separate implementation task, not as an assumed
   installed feature

## 8. Required follow-up work

The repository should grow the following pieces explicitly:

1. a post-install `TPM2 enrollment` script built around `systemd-cryptenroll`
2. a documented policy for PCR selection
3. a validation step proving that the volume unlocks automatically without
   prompting
4. an optional QEMU/vTPM validation path
5. installer documentation that clearly flags when user firmware action is
   required for Secure Boot
