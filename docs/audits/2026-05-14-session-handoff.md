# 2026-05-14 - Margine OS session handoff

This file updates the 2026-04-29 handoff after the long follow-up chat that
validated root-on-ZFS installation, rollback boot environments, desktop
polishing, package baseline changes, and the first Hyprland 0.55 ICC/Lua
assessment.

Use it as the starting context for a new Codex session. Do not reconstruct the
state from memory.

## Local chat references

Primary local session logs:

- Foundational Margine history, explicitly referenced by Daniel:
  `/home/daniel/.codex/sessions/2026/03/29/rollout-2026-03-29T22-18-00-019d3b3f-08d9-7ea2-8068-8ede52caf8a7.jsonl`
- Current heavy continuation chat:
  `/home/daniel/.codex/sessions/2026/04/29/rollout-2026-04-29T17-56-33-019dd9f4-d1da-72b1-9448-31ba2f568811.jsonl`
- Continuation/compaction segment containing the final ZFS rollback canary
  validation and later desktop work:
  `/home/daniel/.codex/sessions/2026/05/10/rollout-2026-05-10T17-57-03-019e129b-3a8f-7350-97b3-1af6c7f753b3.jsonl`
- Latest local fragments from 2026-05-14, useful for the ICC/Lua tail if needed:
  `/home/daniel/.codex/sessions/2026/05/14/rollout-2026-05-14T16-01-03-019e26ca-773b-7af2-b6cb-a661278cf632.jsonl`
  and
  `/home/daniel/.codex/sessions/2026/05/14/rollout-2026-05-14T17-08-17-019e2708-04a4-71e3-aada-5975bf4ccd5e.jsonl`

## Repositories and current state

- Public repo: `/home/daniel/dev/margine-os`
- Personal repo: `/home/daniel/dev/margine-os-personal`
- Current branch in both repos at handoff time: `main`
- The previous `codex/memtest-baseline` work has been integrated into `main`.
- Do not assume clean worktrees. Inspect `git status --short` first.
- At the time this handoff was written, both repos had uncommitted ICC/color
  management work. The personal repo also had an unrelated untracked
  `enable-vm-ssh` helper; do not remove it unless Daniel asks.

Known uncommitted ICC-related paths at handoff time:

- `docs/05-post-install-validation.md`
- `docs/adr/0027-photography-and-color-management-baseline.md`
- `docs/learning/30-perche-su-hyprland-l-icc-del-compositor-resta-opzionale.md`
- `docs/status/2026-03-30.md`
- `files/home/.config/hypr/monitors.conf`
- `inventory/apps/2026-03-30-photography-color.md`
- `scripts/provision-photo-color-assets`
- `scripts/validate-installation-pipeline`
- `docs/audits/2026-05-14-hyprland-icc-fw13-validation.md`
- `files/usr/share/margine/icc/`

## Operating rules

- Do not run `git reset --hard`, `git checkout --`, or destructive cleanup.
- Do not revert unrelated changes. Treat dirty files as user or prior-Codex work.
- Do not commit or push unless Daniel explicitly asks.
- Use `apply_patch` for manual edits.
- Prefer scripts/helpers over asking Daniel to type long command blocks by hand.
- Do not suggest broad destructive live-session commands such as `fuser -km /mnt`.
- For root-on-ZFS mount/unmount work, use the dedicated helpers first.
- Do not run full `pacman -Syu` in the live ISO.
- Do not build AUR overrides in the live ISO unless explicitly validating that
  narrow behavior.
- Keep public and personal repos aligned when a change applies to both.
- Keep VM-only validation behavior out of bare-metal defaults.

Before claiming a fix is safe, run in the public repo:

```bash
cd /home/daniel/dev/margine-os
./scripts/validate-installation-pipeline
./scripts/check-shell-and-manifests
./scripts/check-bash-errexit-footguns
git diff --check
```

When relevant, run the same checks in the personal repo:

```bash
cd /home/daniel/dev/margine-os-personal
./scripts/validate-installation-pipeline
./scripts/check-shell-and-manifests
./scripts/check-bash-errexit-footguns
git diff --check
```

## Must-read documents for the next session

Read these first:

- `docs/audits/2026-05-14-session-handoff.md`
- `docs/audits/2026-05-10-root-zfs-rollback-canary-validation.md`
- `docs/audits/2026-05-08-root-zfs-rollback-validation.md`
- `docs/audits/2026-05-07-root-zfs-update-all-zfs-mode.md`
- `docs/audits/2026-05-07-qemu-validation-idle-inhibit-hardening.md`
- `docs/audits/2026-05-14-hyprland-icc-fw13-validation.md`
- `docs/runbooks/root-on-zfs-live-target-mounting.md`
- `docs/runbooks/root-on-zfs-update-rollback.md`
- `docs/runbooks/desktop-boot-login-theme.md`
- `docs/runbooks/margine-branding-assets.md`
- `docs/adr/0041-root-on-zfs-storage-and-boot-model.md`
- `docs/adr/0042-local-package-overrides.md`
- `docs/adr/0027-photography-and-color-management-baseline.md`
- `docs/adr/0007-limine-config-generation-model.md`
- `docs/adr/0008-snapshot-and-update-policy.md`
- `docs/adr/0009-update-all-orchestration-model.md`
- `docs/adr/0013-manifest-driven-package-installation.md`
- `docs/learning/52-hyprland-options-for-margine.md`

Also keep the older handoff as historical context:

- `docs/audits/2026-04-29-session-handoff.md`

## Current product direction

Margine has two variants:

- Public repo/version: Arch-based general Margine OS.
- Personal repo/version: CachyOS-based Margine Personal.

Strategic target:

- Root-on-ZFS is the primary finished product direction.
- Btrfs remains a possible alternative/legacy path, but should not drive risky
  changes that compromise ZFS.
- The installer must remain guided, reproducible, and general-purpose: no
  hardcoded Daniel-specific hostname, username, real name, or VM identity.
- LUKS2 remains the encryption layer. `cryptroot` is only the mapper name.
- `/games` must remain a dedicated dataset and must not be treated like root
  in rollback/snapshot policy.
- Walker is the default launcher; Fuzzel remains the app-launch fallback.
- Gaming runtime compatibility is installed by default; optional gaming
  launchers are separate.
- Steam was moved into the default gaming runtime baseline. Other launchers
  remain optional.

## Root-on-ZFS status

The personal CachyOS root-on-ZFS VM reached the key gates:

- Fresh install succeeded.
- LUKS unlock worked.
- ZFS import worked.
- Limine booted the installed system.
- `greetd` appeared.
- User login reached Hyprland.
- Root-on-ZFS validators passed.
- `update-all` gained ZFS-aware pre-update snapshot and rollback boot
  environment behavior.
- A real pre-update rollback entry appeared under Limine `Rollback`.
- Booting the rollback entry worked.
- Canary rollback validation passed:
  - active root was the rollback clone;
  - root canaries reverted to the pre-update state;
  - `/home` canary persisted;
  - `/games` canary persisted.

Important validated command:

```bash
cd /home/daniel/dev/margine-os-personal
./scripts/qemu-root-zfs-rollback-canary-over-ssh --user danielitivov --verify-rollback --prompt-sudo
```

Observed successful validation output included:

```text
ZFS rollback boot environment validation: OK
rollback canary validation: OK
  active root: rpool/ROOT/margine-pre-update-...
  root canaries reverted to pre-update state
  /home canary persisted across rollback
  /games canary persisted across rollback
```

## Root-on-ZFS update and rollback model

`update-all` on root-on-ZFS is not the same path as the older Btrfs/Snapper
model.

Current ZFS update flow:

1. Validate current root-on-ZFS boot chain.
2. Create a pre-update snapshot of the root dataset.
3. Clone it into a rollback boot environment under `rpool/ROOT/`.
4. Build/freeze rollback boot artifacts before the package update.
5. Publish a Limine rollback entry.
6. Run package updates.
7. Regenerate primary boot artifacts.
8. Validate root-on-ZFS boot chain again.

Important scripts:

- `scripts/create-zfs-pre-update-snapshots`
- `scripts/create-zfs-boot-environment`
- `scripts/create-zfs-rollback-uki`
- `scripts/validate-zfs-rollback-boot-environment`
- `scripts/provision-initial-boot-chain-zfs`
- `scripts/qemu-root-zfs-rollback-canary-over-ssh`
- `files/home/.local/bin/update-all`

Do not remove the frozen rollback UKI step. It exists because package updates
can make the current primary UKI/kernel incompatible with a pre-update root.

Open follow-up items:

- Decide and implement retention policy for old ZFS rollback boot environments.
- Decide how to promote a rollback clone into primary.
- Keep active-rollback validation explicit.
- Keep `/home` and `/games` out of root rollback semantics.

## QEMU validation workflow

Primary personal VM build directory:

```text
/home/daniel/dev/margine-os-personal/build/qemu-root-zfs-cachyos-fresh-20260429
```

Typical VM identity:

- SSH user: `danielitivov`
- Host alias used by Daniel: `ssh margine-zfs`
- Forwarded port used by scripts: `127.0.0.1:2222`

Important host-side helpers:

- `scripts/enable-qemu-validation-inhibit-over-ssh`
- `scripts/collect-qemu-root-zfs-validation-logs`
- `scripts/apply-qemu-root-zfs-update-runtime-over-ssh`
- `scripts/apply-qemu-user-app-config-over-ssh`
- `scripts/qemu-root-zfs-rollback-canary-over-ssh`

The VM can idle/suspend and break SSH/log collection. Before longer validation,
run:

```bash
cd /home/daniel/dev/margine-os-personal
./scripts/enable-qemu-validation-inhibit-over-ssh --user danielitivov --prompt-sudo
```

The intended inhibitor state:

- system service: `margine-qemu-validation-inhibit.service`
- user service: `keep-awake.service`
- `systemd-inhibit --list` contains a blocking `sleep:idle` inhibitor from
  `Margine-QEMU-validation`.

If SSH suddenly fails, check for:

- VM sleep/idle;
- UFW rate limiting on repeated SSH handshakes;
- wrong identity file;
- stale VM instance or port forwarding;
- `sshd.service` state inside the guest.

Prefer SSH upload helpers over copying the whole repository through 9p. The 9p
path is useful but previously hit hangs, permission problems, and quota issues
when copying build artifacts.

## Live ISO and target mount rules

Inside the live ISO, root access is usually required. CachyOS live sessions often
need `sudo -i` or explicit `sudo`.

Typical 9p mount in live ISO:

```bash
sudo mkdir -p /root/margine-repo
sudo mount -t 9p -o trans=virtio,version=9p2000.L margine /root/margine-repo
```

For installed VM testing, if 9p is needed:

```bash
sudo modprobe 9p 9pnet 9pnet_virtio
sudo mkdir -p /root/margine-repo
sudo mountpoint -q /root/margine-repo || sudo mount -t 9p -o trans=virtio,version=9p2000.L,msize=262144 margine /root/margine-repo
```

Use the dedicated helpers for root-on-ZFS:

- `scripts/mount-zfs-root-target`
- `scripts/unmount-zfs-root-target`

Avoid broad process killing. Previous unmount failures were caused by the live
ISO's services retaining ZFS mounts in other mount namespaces. The helper was
expanded to diagnose and handle that case.

## Host Btrfs snapshot warning

Daniel's current host remains Arch/Btrfs, not root-on-ZFS. Limine Btrfs snapshot
entries were repaired enough to boot older snapshots by masking `boot.mount`,
but old snapshots still showed hardware/session degradation:

- touchpad not working;
- external dock/monitor not detected;
- Wi-Fi stack missing or unusable;
- `/dev/zram0` start job timeout.

Do not over-optimize this path at the expense of ZFS. The likely issue is
booting old root userspace against current boot/kernel/firmware/mount state.
Keep Btrfs as a supported/legacy alternative, but the finished Margine target is
root-on-ZFS.

## ICC and color management status

Hyprland 0.55 made compositor-side ICC much more relevant for Margine.

Superseded note, 2026-05-16: the Framework 13 BOE Hyprland default is now the
GNOME Colors / `colord-session` profile titled `FW13 D65`, not the earlier
DisplayCAL/Argyll `FW13_140cd_D65_2.2_S.icc` test profile.

Daniel's current Framework 13 ICC profile:

```text
/home/daniel/.local/share/icc/BOE NE135A1M-NY1 (high) 2025-12-24 17-14-39 i1-display3.icc
```

Host live test used:

```bash
hyprctl keyword monitor 'desc:BOE NE135A1M-NY1, preferred, 0x0, 2.0, icc, /home/daniel/.local/share/icc/BOE NE135A1M-NY1 (high) 2025-12-24 17-14-39 i1-display3.icc'
hyprctl keyword render:cm_enabled 1
hyprctl keyword render:icc_vcgt_enabled 1
hyprctl reload
```

Repo baseline uses system asset paths:

```text
/usr/share/margine/icc/FW13_D65_GNOME_COLORS.icc
/usr/share/margine/icc/DELL_P2415Q_D65_high.icc
```

Current intended monitor config includes:

```text
monitor = desc:BOE NE135A1M-NY1, preferred, 0x0, 2.0, icc, /usr/share/margine/icc/FW13_D65_GNOME_COLORS.icc
```

Important caveat: `hyprctl monitors` may still show `colorManagementPreset:
srgb`; do not treat that field alone as proof that ICC is not active.

Relevant docs:

- `docs/audits/2026-05-14-hyprland-icc-fw13-validation.md`
- `docs/adr/0027-photography-and-color-management-baseline.md`
- `docs/learning/30-perche-su-hyprland-l-icc-del-compositor-resta-opzionale.md`

## Hyprland 0.55 and Lua config

Hyprland 0.55 introduced Lua configuration support. The old Hyprlang config is
still usable for now, but upstream has described it as deprecated and expected
to remain supported only for a short transition window.

Current Margine status:

- Margine still uses `~/.config/hypr/hyprland.conf`.
- Several scripts hardcode that path:
  - `files/usr/local/bin/margine-start-hyprland`
  - `scripts/bootstrap-in-chroot`
  - `scripts/repair-zfs-root-desktop-session`
  - `scripts/validate-runtime-baseline`
  - `scripts/provision-hyprland-desktop`
- Do not add `hyprland.lua` casually. If present, it can become the active
  configuration and bypass the existing `hyprland.conf` tree.
- The recent `dwindle:pseudotile` startup error was caused by an upstream
  option removal. Keep `dwindle:pseudotile` out of the baseline unless a
  version-gated compatibility strategy is added.
- Keep `ecosystem:no_donation_nag = true` in the current Hyprland config.

Recommended next step:

1. Keep Hyprlang as the production baseline for now.
2. Add a validation gate that fails if `hyprland.lua` appears without an
   explicit migration switch.
3. Create a separate Lua migration plan/audit.
4. Build an experimental Lua config in VM only.
5. Validate login, binds, window rules, monitor config, ICC, Walker, Fuzzel,
   portals, Waybar, hypridle, WSF, privacy indicators, and rollback after an
   update before switching production defaults.

## Desktop baseline and recent decisions

Launcher/session:

- Walker remains the default launcher.
- Fuzzel remains the fallback app-launcher and powers the `SUPER+ESC` menu.
- Walker should remain warm through its user service.
- Power/logout/reboot commands should ask for confirmation before taking action.
- The old broken `SUPER+ESC` menu was removed/replaced.

Waybar:

- EasyEffects `FX` status indicator was removed.
- Wi-Fi should show a simple state icon, not signal strength text.
- Clicking the network indicator should open `nm-connection-editor`.
- Privacy indicators for microphone and camera were added.
- When both privacy indicators are visible, microphone should be left of camera
  and there must be visible spacing.
- Tray bracket styling was tested.
- Battery spacing should remain visually tight: one space between icon and
  percentage if spacing is represented in text.
- Update latency of right-side status modules was improved but should remain a
  regression target.

Touchpad/input:

- `disable_while_typing` should be a standard baseline condition.
- Palm rejection should be checked via Hyprland/libinput options, but do not
  overfit Daniel's host without VM/bare-metal separation.
- `wayland-scroll-factor` is now available from AUR as
  `wayland-scroll-factor`; use the AUR package, not a local recipe.

Fonts:

- Desired current baseline:
  - UI: `Iosevka Etoile`
  - Terminal/code: `Ioskeley Mono`
  - Compact UI: `Ioskeley Mono Condensed`
  - Neutral fallback: `Iosevka Aile`
- `theme.env` should remain the source of truth.
- Avoid hardcoding fonts directly in generated configs where the renderer can
  consume theme variables.
- Fuzzel menus should follow the normal UI font, not the condensed font.
- Waybar active window title should use the compact/condensed font.
- Hyprlock text should use Ioskeley.

Open desktop issue:

- Hyprlock password unlock can sometimes fail or feel delayed, while fingerprint
  unlock is reliable. Suspect PAM/fprint/password path timing, but this remains
  unresolved.

## Boot, login, branding, and theme

Relevant runbook:

- `docs/runbooks/desktop-boot-login-theme.md`

Current direction:

- Margine Logo V2 is the desired final logo asset.
- Use proper logo assets in boot, Plymouth, desktop branding, and fastfetch-like
  terminal identity tooling.
- Avoid the old full-screen BMP approach as the only boot visual.
- Tuigreet color theme was tested but Daniel did not like the latest result.
  Future changes should be made through documented palette variables and tested
  on host first.
- Daniel wants the post-login terminal text scroll hidden or masked if possible.
  Do not break diagnosability while making that smoother.

## Audio, creative apps, and gaming

Audio/creative baseline changes from this chat:

- Audacity had incompatible plugin warnings with some VST paths.
- `lsp-plugins-vst3` should be in the baseline.
- Do not remove or disable Carla just to silence Audacity warnings. Reaper has
  priority, and Carla can be valuable there.
- Reaper should be preinstalled in Margine together with its practical runtime
  dependencies.
- Reaper was fixed enough on host to launch correctly; a previous cursor
  scaling issue over Reaper must not regress in new installs.
- EasyEffects remains important for the Framework speaker preset. Do not remove
  LV2/VST packages without checking the preset and PipeWire chain.

Gaming:

- Steam should be part of the default gaming runtime baseline.
- Other game launchers remain optional.
- Proton GE support should be verified before claiming it is installed by
  default.

DaVinci Resolve:

- DavinciBox evaluation was started but not completed.
- Installing `podman`, `distrobox`, and `lshw` only installs the container
  tooling; it does not install Resolve.
- Blackmagic's official download flow requires registration/personal data.
  Do not automate unauthorized downloads.
- VM installs previously handled Resolve because the installer had access to
  the required installer asset or package path; do not assume a fresh host can
  download it without the official installer file.

## Package baseline reminders

Recently requested/added baseline packages include:

- `dosfstools`
- `parted`
- `unzip`
- `lsp-plugins-vst3`
- `wayland-scroll-factor` from AUR
- Steam in the default gaming runtime
- Reaper and supporting audio/plugin runtime where appropriate

Watch for repository/package differences between Arch and CachyOS. In the
CachyOS personal path, prefer the CachyOS package when it is the intended
provider.

## License and branch state

- Both repos were moved to GPL-3.0-or-later.
- The license metadata should refer to:
  - product: `Margine OS`
  - author: `Daniel Grasso`
- Placeholder text from the GPL how-to appendix must not remain in the project
  metadata or README snippets.
- If a stale remote `codex/memtest-baseline` branch remains visible on GitHub,
  confirm with Daniel before deleting it.

## Current near-term priorities

1. Commit or otherwise preserve the current ICC/color-management changes when
   Daniel asks.
2. Finish documenting the ICC migration and ensure both repos match.
3. Add a Hyprland 0.55/Lua migration audit and a validation gate preventing
   accidental `hyprland.lua` activation.
4. Keep root-on-ZFS rollback as the protected baseline and avoid destabilizing
   it during desktop work.
5. Improve/update READMEs and runbooks that still overemphasize Btrfs while
   preserving Btrfs as an alternative path.
6. Continue package baseline cleanup for audio, gaming, and creative workflows.
7. Validate any substantial desktop change in VM before considering it a
   default.

## Prompt for the next chat

Daniel can paste this into the next Codex chat:

```text
You are continuing Margine OS work from a previous very long Codex chat.

Environment:
- User: Daniel
- Host path: /home/daniel
- Public repo: /home/daniel/dev/margine-os
- Personal repo: /home/daniel/dev/margine-os-personal
- Current branch in both repos: main
- Current date: 2026-05-14 or later
- Timezone: Europe/Rome

Start by reading:
- /home/daniel/dev/margine-os/docs/audits/2026-05-14-session-handoff.md
- /home/daniel/dev/margine-os/docs/audits/2026-05-10-root-zfs-rollback-canary-validation.md
- /home/daniel/dev/margine-os/docs/audits/2026-05-14-hyprland-icc-fw13-validation.md
- /home/daniel/dev/margine-os/docs/runbooks/root-on-zfs-update-rollback.md
- /home/daniel/dev/margine-os/docs/runbooks/root-on-zfs-live-target-mounting.md
- /home/daniel/dev/margine-os/docs/runbooks/desktop-boot-login-theme.md
- /home/daniel/dev/margine-os/docs/adr/0041-root-on-zfs-storage-and-boot-model.md
- /home/daniel/dev/margine-os/docs/adr/0027-photography-and-color-management-baseline.md
- /home/daniel/dev/margine-os/docs/learning/52-hyprland-options-for-margine.md

Useful local chat logs:
- Foundational history:
  /home/daniel/.codex/sessions/2026/03/29/rollout-2026-03-29T22-18-00-019d3b3f-08d9-7ea2-8068-8ede52caf8a7.jsonl
- Current heavy continuation:
  /home/daniel/.codex/sessions/2026/04/29/rollout-2026-04-29T17-56-33-019dd9f4-d1da-72b1-9448-31ba2f568811.jsonl
- Later continuation:
  /home/daniel/.codex/sessions/2026/05/10/rollout-2026-05-10T17-57-03-019e129b-3a8f-7350-97b3-1af6c7f753b3.jsonl

Important operating rules:
- Do not assume clean worktrees. Inspect git status first in both repos.
- Do not revert unrelated changes.
- Do not run git reset --hard or git checkout --.
- Do not commit or push unless explicitly asked.
- Use apply_patch for manual edits.
- Prefer helper scripts over asking me to type long command blocks by hand.
- Do not suggest broad destructive live-session commands like fuser -km /mnt.
- Do not run full pacman -Syu in the live ISO.
- Keep VM-only validation helpers out of bare-metal defaults.
- Keep documentation updated in ADRs, audits, runbooks, and learning docs.

Current state summary:
- Root-on-ZFS install, boot, update-all ZFS mode, rollback Limine entry, frozen
  rollback UKI, and rollback canary validation have passed in the personal VM.
- /home and /games persist across ZFS root rollback; root canaries revert.
- ICC is being migrated to Hyprland 0.55 compositor-side monitor ICC using the
  Framework 13 `FW13_D65_GNOME_COLORS.icc` profile and system assets under
  /usr/share/margine/icc.
- Hyprland 0.55 Lua migration has not started; Margine still uses Hyprlang
  hyprland.conf. Plan it as a VM-tested migration, not an immediate host switch.
- Walker remains default, Fuzzel fallback, Steam in gaming runtime, Reaper/audio
  baseline under active cleanup.

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
