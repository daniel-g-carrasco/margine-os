# 2026-04-29 - Margine OS session handoff

This file is the compact handoff for continuing the Margine OS work in a new
chat. The current chat became too heavy, so the next session should start from
this document instead of reconstructing context from memory.

## Repositories

- Public repo: `/home/daniel/dev/margine-os`
- Personal repo: `/home/daniel/dev/margine-os-personal`
- Current branch in both repos: `codex/memtest-baseline`
- Last known public commit: `8dee6ae Scale hyprlock separately for HiDPI panels`
- Last known personal commit: `9c2fb46 Scale hyprlock separately for HiDPI panels`
- Both worktrees are intentionally dirty and contain many uncommitted changes.
- Do not run `git reset --hard`, `git checkout --`, or broad cleanup commands.
- Do not revert user changes unless the user explicitly asks.
- Do not commit or push unless explicitly asked.

## Operating rules for the next chat

- Inspect local files before making claims. The repos changed heavily.
- Prefer scripts/helpers over asking the user to type long commands by hand.
- Never suggest broad destructive commands such as `fuser -km /mnt`.
- For root-on-ZFS mount/unmount work, use the dedicated helpers first.
- Do not run a full live ISO system upgrade just to build or install overrides.
- Do not build AUR/local overrides in the live ISO unless explicitly validating that path.
- Use `apply_patch` for manual edits.
- Keep answers concise but technically specific.
- If a command must be run by the user inside a VM, provide a short ordered block.
- Treat VM/bare-metal separation carefully. VM-only behavior must not leak into bare-metal defaults.

## Documentation map

Read these first in the next chat:

- `/home/daniel/dev/margine-os/docs/audits/2026-04-29-session-handoff.md`
- `/home/daniel/dev/margine-os/docs/audits/2026-04-29-cachyos-zfs-installer-analysis.md`
- `/home/daniel/dev/margine-os/docs/audits/2026-04-29-root-zfs-state-validator-hardening.md`
- `/home/daniel/dev/margine-os/docs/audits/2026-04-26-installation-pipeline-hardening-audit.md`
- `/home/daniel/dev/margine-os/docs/adr/0041-root-on-zfs-storage-and-boot-model.md`
- `/home/daniel/dev/margine-os/docs/adr/0042-local-package-overrides.md`
- `/home/daniel/dev/margine-os/docs/runbooks/root-on-zfs-live-target-mounting.md`

ADR files document decisions and rationale. Runbooks document exact operational
procedures. Keep both categories separate.

## Current product direction

Margine has two variants:

- `margine-public`: Arch-based public/general version.
- `margine-cachyos`: personal CachyOS-based version.

The installer should remain general-purpose. It must not hardcode:

- `daniel`
- `danielito`
- `danielitoss`
- `Daniel G Carrasco`
- `margine-zfs-vm`

Hostname, username, real name, and user password must be explicit installer
inputs or prompted interactively by guided scripts.

The gaming runtime compatibility layer should be part of the default runtime
baseline. Gaming launcher applications are separate and optional.

For `margine-cachyos`, keep `lib32-opencl-icd-loader` as the 32-bit OpenCL ICD
loader. Do not also install `lib32-ocl-icd`; current CachyOS packages mark the
two as conflicting, and the live installer runs pacman non-interactively.

## Current desktop decisions

- Default launcher: Walker.
- Fallback app launcher: Fuzzel, app-launch only, used also as fallback for screenshot/screenrecord flows.
- Walker should be kept warm through the user systemd service by default.
- `SUPER+SPACE` should call Walker.
- `SUPER+SHIFT+SPACE` should call Fuzzel fallback.
- Walker warm service tradeoff is acceptable: small resident memory cost, much faster launch.
- If theme/config changes affect Walker, restart the user Walker service after rendering/applying theme artifacts.
- greetd/tuigreet is the default login path. No autologin.
- `aurbuilder` must not appear as a selectable graphical login user.

Relevant files:

- `/home/daniel/dev/margine-os/files/home/.config/systemd/user/walker.service`
- `/home/daniel/dev/margine-os/files/home/.config/hypr/conf.d/10-variables.conf`
- `/home/daniel/dev/margine-os/files/home/.config/hypr/conf.d/60-binds.conf`
- `/home/daniel/dev/margine-os/files/home/.local/bin/margine-launcher-service`
- `/home/daniel/dev/margine-os/files/home/.local/bin/margine-launcher-walker`
- `/home/daniel/dev/margine-os/files/home/.config/fuzzel/theme-generated.ini`

## Icon and theme direction

- Current desired icon direction: GNOME/Adwaita-first.
- MoreWaita should be used selectively where useful, especially folders, MIME,
  devices, and places, but not as a full app-icon takeover.
- Custom launcher/script entries should have a coherent dedicated icon set.
- Theme application must update Waybar, SwayNC, Walker, Fuzzel, GTK, KDE/Qt
  hints, folder color, and notification styling consistently.
- A previous bug left notification borders stuck on the pink theme. That was a
  theme artifact/rendering issue and must be regression-tested after theme edits.

Relevant files:

- `/home/daniel/dev/margine-os/files/home/.config/margine/theme.env`
- `/home/daniel/dev/margine-os/files/home/.config/margine/themes/`
- `/home/daniel/dev/margine-os/scripts/render-theme-artifacts`
- `/home/daniel/dev/margine-os/scripts/provision-user-app-config`

## Root-on-ZFS target model

Root-on-ZFS is the strategic target. The non-root ZFS layer was only a test
phase.

Current intended model:

- ESP mounted at `/boot`
- LUKS2 block device
- Device-mapper name defaults to `cryptroot`
- ZFS pool name defaults to `rpool`
- Root dataset: `rpool/ROOT/default`
- Separate datasets for `/home`, `/root`, `/var`, `/var/log`, `/var/cache`,
  `/var/tmp`, `/srv`, `/data`, containers, machines, libvirt, and games.
- `/games` should exist to avoid huge unnecessary snapshots of game libraries.
- Native ZFS encryption is not the current default.
- Hibernation is out of scope for now; zram remains the default swap approach.

Important clarification: `cryptroot` is not an alternative to LUKS. It is only
the LUKS device-mapper name, typically `/dev/mapper/cryptroot`.

## Root-on-ZFS scripts

Important scripts currently under development:

- `/home/daniel/dev/margine-os/scripts/bootstrap-live-zfs-tools`
- `/home/daniel/dev/margine-os/scripts/provision-storage-zfs-root`
- `/home/daniel/dev/margine-os/scripts/bootstrap-live-zfs-root-guided`
- `/home/daniel/dev/margine-os/scripts/bootstrap-live-iso`
- `/home/daniel/dev/margine-os/scripts/bootstrap-in-chroot`
- `/home/daniel/dev/margine-os/scripts/provision-initial-boot-chain-zfs`
- `/home/daniel/dev/margine-os/scripts/mount-zfs-root-target`
- `/home/daniel/dev/margine-os/scripts/unmount-zfs-root-target`
- `/home/daniel/dev/margine-os/scripts/repair-zfs-root-user-login`
- `/home/daniel/dev/margine-os/scripts/repair-zfs-root-desktop-session`
- `/home/daniel/dev/margine-os/scripts/validate-installation-pipeline`
- `/home/daniel/dev/margine-os/scripts/validate-live-install-sources`
- `/home/daniel/dev/margine-os/scripts/validate-root-zfs-target`
- `/home/daniel/dev/margine-os/scripts/check-bash-errexit-footguns`

Current intended live target mount flow:

```bash
sudo mkdir -p /root/margine-repo
sudo mount -t 9p -o trans=virtio,version=9p2000.L margine /root/margine-repo
sudo /root/margine-repo/scripts/mount-zfs-root-target
```

Current intended detach flow:

```bash
cd /
sudo /root/margine-repo/scripts/unmount-zfs-root-target
```

If detach fails, the helper should report the specific blockers and offer safe
escalation flags. Do not suggest `sudo fuser -km /mnt`; it can kill the live
session.

## Recent root-on-ZFS problems

These are still important and must not be hand-waved:

- Previous attempts reached Limine, asked for the LUKS passphrase, then panicked
  with `Kernel panic - not syncing: Attempted to kill init!`.
- On 2026-04-30 the current `margine-cachyos` personal root-on-ZFS VM booted
  through LUKS unlock, ZFS import, `greetd`, login and graphical session.
- Treat this as the first successful boot gate, not as full acceptance: second
  boot, installed-system validation, update/reboot, and rollback gates still
  need to run.
- There were prior storage layout issues around `mountpoint=legacy`; the target
  direction is `mountpoint=/`, `canmount=noauto`, explicit live mounting with
  `mount -t zfs -o zfsutil`.
- Root-on-ZFS boot artifacts must include `root=ZFS=...`, LUKS mapping data,
  zpool cachefile, hostid, and the required mkinitcpio hooks/modules.
- The live installer must not proceed to desktop repair if boot-chain validation
  is incomplete.

## Live ISO and package-management problems

Do not use the live ISO as if it were the installed system.

Observed failures:

- Full live ISO upgrades caused OOM and package skew.
- CachyOS live package databases produced duplicate database warnings.
- Mirror 404 and transient failures happened during huge package downloads.
- AUR build dependencies caused live ISO dependency conflicts.
- `install-aur-packages --upgrade walker` failed in live media because `patch`
  was absent or because the live package graph was not stable.

Current strategy:

- The live ISO should only prepare storage and bootstrap the target.
- Avoid `pacman -Syu` in the live ISO.
- Do not build patched Walker in the live ISO.
- Prefer prebuilt local repo support or first-boot best-effort local override
  build on the installed target.

## Local package override strategy

See ADR 0042.

Preferred model:

- Build local override packages into a local pacman repository.
- Install from that local repository during normal package installation.
- Keep first-boot local override build as fallback only.

Walker patching must be reproducible. If the PKGBUILD changes upstream, the
override logic should fail clearly and should not break the base system install.

## Known validation commands

Run these from the public repo before claiming installer changes are safe:

```bash
cd /home/daniel/dev/margine-os
./scripts/validate-installation-pipeline
./scripts/check-shell-and-manifests
./scripts/check-bash-errexit-footguns
git diff --check
```

Run equivalent checks in the personal repo when changes are mirrored there:

```bash
cd /home/daniel/dev/margine-os-personal
./scripts/validate-installation-pipeline
./scripts/check-shell-and-manifests
./scripts/check-bash-errexit-footguns
git diff --check
```

If a script is absent in one repo, inspect the repo layout before assuming.

## Recommended next technical step

Do not continue random VM repair. First make the root-on-ZFS install path
boring and deterministic:

1. Audit generated boot artifacts after a fresh root-on-ZFS install attempt:
   `limine.conf`, UKI cmdline, mkinitcpio config, hostid, zpool cachefile,
   `/etc/crypttab`, `/etc/fstab`, ZFS dataset properties.
2. Compare those artifacts with CachyOS official root-on-ZFS behavior and the
   findings in `2026-04-29-cachyos-zfs-installer-analysis.md`.
3. Fix scripts so one guided command can perform the bootstrap after storage is
   prepared, without requiring manual mount reconstruction.
4. Make `mount-zfs-root-target` and `unmount-zfs-root-target` the only user-facing
   repair path for live media.
5. Re-run `validate-installation-pipeline`.
6. Only then retry a clean QEMU install.

## Prompt for the new chat

Copy this prompt into the new chat:

```text
You are continuing Margine OS work from a previous very long Codex chat.

Environment:
- User: Daniel
- Host path: /home/daniel
- Public repo: /home/daniel/dev/margine-os
- Personal repo: /home/daniel/dev/margine-os-personal
- Current branch in both repos: codex/memtest-baseline
- Current date: 2026-04-29
- Timezone: Europe/Rome

Start by reading:
- /home/daniel/dev/margine-os/docs/audits/2026-04-29-session-handoff.md
- /home/daniel/dev/margine-os/docs/audits/2026-04-29-cachyos-zfs-installer-analysis.md
- /home/daniel/dev/margine-os/docs/audits/2026-04-26-installation-pipeline-hardening-audit.md
- /home/daniel/dev/margine-os/docs/adr/0041-root-on-zfs-storage-and-boot-model.md
- /home/daniel/dev/margine-os/docs/adr/0042-local-package-overrides.md
- /home/daniel/dev/margine-os/docs/runbooks/root-on-zfs-live-target-mounting.md

Important operating rules:
- Do not assume clean worktrees. Inspect git status first.
- Do not revert unrelated changes.
- Do not run git reset --hard or git checkout --.
- Do not commit or push unless explicitly asked.
- Use apply_patch for manual edits.
- Do not ask me to type long command blocks by hand inside the VM if a helper
  script can be created or reused.
- Do not suggest broad destructive live-session commands like fuser -km /mnt.
- Use the mount/unmount root-on-ZFS helpers instead.
- Do not run full pacman -Syu in the live ISO.
- Do not build AUR overrides in the live ISO unless explicitly validating that
  narrow behavior.

Current priorities:
1. Stabilize Margine root-on-ZFS installation and boot.
2. Diagnose the post-LUKS kernel panic after ZFS loads:
   "Kernel panic - not syncing: Attempted to kill init!".
3. Make the installer guided, reproducible, and general-purpose:
   no hardcoded Daniel-specific hostname, username, or real name.
4. Keep LUKS2 as the encryption layer. cryptroot is only the mapper name.
5. Ensure /games is a dedicated dataset excluded or treated differently by
   snapshot policy.
6. Keep Walker as the default launcher and keep walker.service warm by default.
7. Keep Fuzzel as the app-launch-only fallback.
8. Keep gaming runtime compatibility installed by default, but keep gaming app
   launchers as optional.
9. Keep documentation updated in ADRs, audits, and runbooks.

Before claiming a fix is safe, run:
cd /home/daniel/dev/margine-os
./scripts/validate-installation-pipeline
./scripts/check-shell-and-manifests
./scripts/check-bash-errexit-footguns
git diff --check

Then mirror/check the personal repo when relevant:
cd /home/daniel/dev/margine-os-personal
./scripts/validate-installation-pipeline
./scripts/check-shell-and-manifests
./scripts/check-bash-errexit-footguns
git diff --check

Communication style:
- Be concise, direct, and technical.
- Explain concrete risks and assumptions.
- Prefer implementing/verifying over theorizing.
- If VM commands are needed, give the shortest safe ordered sequence.
```
