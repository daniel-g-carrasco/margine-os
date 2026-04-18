# Gaming stack layering and the `split_lock_mitigate` tradeoff

## What this note explains

This note explains three related decisions:

1. why `Margine-CachyOS` does not import `cachyos-gaming-meta` and
   `cachyos-gaming-applications` as opaque metapackages
2. why the gaming stack is split into runtime compatibility versus user-facing
   applications
3. why `gamescope` is installed as an optional tool rather than autostarted
   from `Hyprland`
4. why the `split_lock_mitigate=0` tweak is kept operator-controlled instead of
   being silently enabled

## What CachyOS ships

At the time of writing, CachyOS exposes gaming support in two layers:

- `cachyos-gaming-meta`
- `cachyos-gaming-applications`

Their responsibilities are different:

- `cachyos-gaming-meta` provides the technical runtime side: Proton, Wine,
  helper tools, Vulkan tooling, and compatibility libraries
- `cachyos-gaming-applications` adds the user-facing tools: Steam, Lutris,
  Heroic, MangoHud, Gamescope, GOverlay, and related launchers

The important detail is that `cachyos-gaming-meta` also drops a sysctl file
that sets:

```text
kernel.split_lock_mitigate=0
```

So the metapackage does two things at once:

- installs gaming compatibility packages
- changes a kernel mitigation policy

`Margine` deliberately separates those concerns.

## Why `Margine` does not import the Cachy metapackages wholesale

The project rule is that package installation and system policy should remain
legible and independently controllable.

If `Margine` imported the Cachy gaming metapackages as-is:

- package composition would be delegated to an external package owner
- the security/performance tradeoff around split-lock mitigation would be
  applied implicitly
- future debugging would be harder because the system behavior would be owned by
  a meta package rather than by versioned `Margine` manifests and scripts

That is why the project mirrors the *idea* of the gaming stack, but not the
opaque package boundary.

## The `Margine` model

`Margine` uses two optional layers:

- `gaming-runtime-compat`
- `gaming-apps-launchers`

The split is intentional:

- `gaming-runtime-compat` is the technical substrate needed by Steam,
  Proton/Wine, and related game runtimes
- `gaming-apps-launchers` is the user-facing layer that installs launchers,
  overlays, and tools

This gives operators three deployment shapes:

1. no gaming stack at all
2. compatibility/runtime only
3. full gaming workstation

The important consequence is that gaming compatibility can be installed without
automatically forcing launchers or changing kernel mitigation policy.

The product-specific detail is in the package choice:

- `Margine Personal / CachyOS` uses the same layer names, but with
  Cachy-oriented packages such as `proton-cachyos-slr`, `wine-cachyos-opt`,
  and `heroic-games-launcher`
- `Margine Public / Arch` exposes the same two optional layers with
  Arch-native packages from the official repositories, such as `wine`,
  `winetricks`, `steam`, `lutris`, `gamescope`, and `mangohud`

This keeps the operator model stable across products even when the package
composition differs underneath.

## Why `gamescope` is optional rather than autostarted

`gamescope` is useful, but it is not a desktop-wide requirement.

It helps most when an operator needs one of these:

- per-game display scaling
- a more controlled fullscreen path
- an isolated compositor wrapper around a specific title
- workaround space for problematic XWayland or Proton cases

That does **not** mean it should be launched globally from `hyprland.conf`.

`Margine` therefore treats `gamescope` as:

- an installable gaming tool
- available through the optional gaming layers
- usable per game, per launcher, or per troubleshooting case
- not part of the default compositor startup path

The correct baseline is:

- install it when the operator wants the gaming stack
- leave Hyprland startup untouched
- decide per title whether normal execution or `gamescope` gives the better
  result

## What `split_lock_mitigate` means

`split_lock_mitigate` is an x86 kernel sysctl.

Split locks are a class of memory operations that can trigger very expensive
bus locking behavior on modern x86 systems. The kernel exposes controls for how
aggressively it should mitigate the impact of such operations.

In practical terms for this project:

- `kernel.split_lock_mitigate=1` keeps the mitigation active
- `kernel.split_lock_mitigate=0` disables the mitigation and only warns in the
  kernel log

Why do gaming-oriented distributions sometimes set it to `0`?

- some games, anti-cheat components, Proton/Wine workloads, or proprietary
  binaries can behave poorly under the mitigation
- disabling it can remove a source of stalls or throttling in those workloads

Why is this not free?

- the mitigation exists for a reason
- disabling it weakens protection against a class of denial-of-service behavior
- therefore it is a performance-versus-safety tradeoff, not a universal win

## Is it immutable once enabled

No.

It is not a one-way firmware setting and not a permanent bootloader decision.
It is a runtime sysctl, so it can be changed live when the kernel exposes:

```text
/proc/sys/kernel/split_lock_mitigate
```

That means there are two distinct states to think about:

- runtime value right now
- persistent value that will be re-applied after reboot

CachyOS handles persistence by shipping a sysctl drop-in in the gaming meta
package. It does not, by itself, provide a special graphical toggle.

## How `Margine` handles the toggle

`Margine` keeps the toggle explicit through:

- `scripts/provision-gaming-split-lock`

The operator interface is:

```bash
sudo /root/margine-os/scripts/provision-gaming-split-lock --status
sudo /root/margine-os/scripts/provision-gaming-split-lock --enable
sudo /root/margine-os/scripts/provision-gaming-split-lock --disable
```

The semantics are:

- `--enable`: enable the gaming override (`kernel.split_lock_mitigate=0`)
- `--disable`: restore mitigation (`kernel.split_lock_mitigate=1`)

The script can:

- inspect the current runtime value
- inspect the persisted drop-in value
- change the runtime value immediately with `sysctl`
- persist the chosen value under `/etc/sysctl.d/`

This is a better fit for `Margine` because it makes the tradeoff visible and
reviewable.

## Runtime safety signal in Waybar

Because this toggle is security-sensitive, the desktop also exposes a Waybar
indicator.

The indicator is intentionally conservative:

- it stays hidden when mitigation is active and no override is pending
- it shows `SL0` when the runtime value is actually `0`
- it shows `SL!` when runtime and persistent intent do not match

The tooltip reports:

- current runtime value
- effective persistent value
- source file that currently wins in the sysctl configuration order

This gives operators a lightweight but explicit signal when the gaming override
is active or when the next reboot will not match the current runtime state.

For terminal-side management, the desktop also exposes:

- `~/.local/bin/gaming-split-lock-menu`
- `~/.local/bin/open-gaming-split-lock-menu`

The menu is intentionally simple:

- show status
- enable the gaming override
- disable the gaming override
- require explicit terminal-side confirmation through `sudo`

So the operator gets a controllable TTY workflow without turning Waybar itself
into a one-click kernel-policy toggle.

## Why this model is preferable for `Margine`

The project benefits are concrete:

- operators can install gaming compatibility without committing to the mitigation
  change
- operators can test the tweak live before making it persistent
- debugging stays simpler because packages and policy are separated
- documentation can explain the tradeoff clearly

This is consistent with how `Margine` already treats boot trust, TPM2, Snapper,
and other high-impact settings: explicit, versioned, and reversible.

## How to change it safely

### Install the runtime only

```bash
sudo /root/margine-os/scripts/install-from-manifests \
  --product <product> \
  --flavor <flavor> \
  --layer gaming-runtime-compat
```

### Install the full gaming stack

```bash
sudo /root/margine-os/scripts/install-from-manifests \
  --product <product> \
  --flavor <flavor> \
  --layer gaming-runtime-compat \
  --layer gaming-apps-launchers
```

### Inspect the split-lock status

```bash
sudo /root/margine-os/scripts/provision-gaming-split-lock --status
```

### Enable the gaming override

```bash
sudo /root/margine-os/scripts/provision-gaming-split-lock --enable
```

### Revert to the mitigated state

```bash
sudo /root/margine-os/scripts/provision-gaming-split-lock --disable
```

## Final position

The correct `Margine` position is:

- adopt the gaming stack as optional layers
- separate runtime compatibility from apps and launchers
- keep `gamescope` out of global `Hyprland` startup
- keep `split_lock_mitigate=0` out of the default path
- expose it as a deliberate operator toggle

That preserves most of the practical value of the CachyOS gaming model without
hiding the kernel policy tradeoff inside an opaque metapackage.
