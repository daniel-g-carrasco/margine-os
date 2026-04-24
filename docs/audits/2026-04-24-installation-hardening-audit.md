# 2026-04-24 installation hardening audit

Scope: Margine public installation path after the Limine, service-enablement,
and hardware-layer issues found during the CachyOS/ZFS/gaming VM validation.

## Result

Status: pass with one explicit residual risk.

The public installer path no longer depends on the old combined
`hardware-framework13-amd` default layer. New installs use generic phase-2
layers plus auto-detected hardware layers:

- `hardware-amd-cpu`
- `hardware-intel-cpu`
- `hardware-amd-graphics`
- `hardware-intel-graphics`
- `hardware-nvidia-open-graphics`
- `hardware-framework13`

On the current host the detector resolves:

- `hardware-amd-cpu`
- `hardware-amd-graphics`
- `hardware-framework13`

## Fixes verified

- `security-and-recovery` is now part of `bootstrap-in-chroot` phase 2 before
  boot-chain provisioning, so `limine`, `mkinitcpio`, `sbctl`, `snapper`, and
  related boot/recovery tools are installed before UKIs and Limine are built.
- `provision-initial-boot-chain` self-heals a missing
  `/usr/share/limine/BOOTX64.EFI` by installing the `limine` package before
  failing hard.
- `power-profiles-daemon` moved from the Framework/AMD layer into
  `desktop-integration`, because power profiles are a generic laptop/desktop
  baseline requirement.
- `amd-ucode` was removed from `base-system`; CPU microcode now follows CPU
  detection through `hardware-amd-cpu` or `hardware-intel-cpu`.
- `hardware-framework13-amd` remains as a deprecated compatibility alias only;
  it is no longer a default layer.
- `snap-pac` important packages now include both `amd-ucode` and `intel-ucode`
  so either CPU microcode package can trigger a meaningful pre/post snapshot.

## Bare-metal risk review

- Bare-metal installs should not hit the VM failure where Limine was missing:
  the package is installed by phase 2 before the initial boot chain, and the
  boot provisioner has a second defensive install path.
- Missing base services should be treated as hard errors. The services enabled
  by `bootstrap-in-chroot` are backed by default phase-2 layers:
  `connectivity-stack`, `printing-scanning-stack`, and `desktop-integration`.
- Framework-specific audio provisioning remains guarded by DMI checks and
  skips unsupported systems.
- Framework power provisioning installs generic lid and power-key policy plus a
  `power-profiles-daemon` baseline. AMD-specific live action changes are
  best-effort and non-fatal.

## Residual risk

`hardware-nvidia-open-graphics` is auto-detected when an NVIDIA display adapter
is present. It installs the open NVIDIA kernel module stack. This is the right
layering direction, but it still needs real NVIDIA bare-metal validation,
especially on older GPUs and hybrid systems. The safe fallback layer
`hardware-mesa-graphics-all` intentionally excludes NVIDIA kernel modules.

## Validation commands run

```bash
./scripts/check-shell-and-manifests
git diff --check
./scripts/install-from-manifests --product margine-public --flavor arch --dry-run
./scripts/install-from-manifests --product margine-public --flavor arch --list-layers
./scripts/bootstrap-in-chroot --product margine-public --flavor arch --username test --dry-run
./scripts/prepare-qemu-archiso-validation --product margine-public --flavor arch --workdir build/audit-qemu-public --dry-run
```

Package-name checks were also run locally with `pacman -Si` for the new CPU/GPU
hardware layers and their fallback layers.
