# What CachyOS adds beyond kernel and repositories

## The short answer

If you reduce `CachyOS` to:

- `linux-cachyos`
- `cachyos-keyring`
- `cachyos-mirrorlist`

you only keep the distribution identity at the package source and kernel level.

That is useful, but it is not the whole CachyOS experience.

CachyOS also ships:

- installer choices and helper tooling
- post-install GUI utilities
- desktop-specific settings packages
- system behavior packages such as hooks, rate-mirror tooling, and scheduler
  rules
- optional gaming and shell-configuration bundles

For `Margine`, the correct question is not:

> "Should we clone CachyOS?"

The correct question is:

> "Which CachyOS components materially improve the personal product without
> taking control away from Margine's versioned model?"

## What the official CachyOS installer selects

As of April 13, 2026, CachyOS Calamares `netinstall.yaml` separates several
layers.

### Hidden required CachyOS packages

These are effectively part of the base CachyOS identity:

- `cachyos-hooks`
- `cachyos-keyring`
- `cachyos-mirrorlist`
- `cachyos-v3-mirrorlist`
- `cachyos-v4-mirrorlist`
- `cachyos-rate-mirrors`
- `linux-cachyos`
- `linux-cachyos-headers`
- `linux-cachyos-lts`
- `linux-cachyos-lts-headers`
- `chwd`

These packages are not "cosmetic". They define:

- trust and repository bootstrap
- mirror selection behavior
- kernel choice
- hardware-aware package/driver logic

### Visible CachyOS-branded packages

The current online installer also selects:

- `cachyos-hello`
- `cachyos-kernel-manager`
- `cachyos-packageinstaller`
- `cachyos-settings`
- `cachyos-micro-settings`
- `cachyos-wallpapers`

This is the first important distinction:

- some packages are true distribution foundations
- others are convenience applications or branded defaults

### Shell configuration packages

The installer also proposes:

- `cachyos-fish-config`
- `cachyos-zsh-config`

This confirms that part of the CachyOS experience is not just package origin,
but opinionated user-space configuration.

## What belongs to the live ISO, and what belongs to the installed system

The live ISO package list includes installer-oriented packages such as:

- `cachyos-calamares`
- `cachyos-cli-installer-new`
- `cachy-chroot`

It also includes a number of operational and rescue packages used by the live
environment.

That does **not** mean they should automatically exist in the installed target
system.

This distinction matters for Margine:

- ISO tooling belongs to the installation environment
- runtime tooling belongs to the installed product

If you blur those layers, the final system becomes harder to reason about and
harder to validate.

## The important CachyOS packages, one by one

## `chwd`

### What it is

`chwd` is the hardware detection / driver selection component used by CachyOS.

### Why it matters

It is one of the few pieces that can materially improve the out-of-box
experience on real hardware:

- graphics driver selection
- vendor-specific handling
- hardware-sensitive install behavior

### Margine position

`Adopt`

For `margine-cachyos` personal, this is one of the strongest candidates because
it improves hardware onboarding without trying to replace your desktop layer or
update model.

## `cachyos-kernel-manager`

### What it is

A GUI kernel manager that can install kernels from the repo and expose advanced
kernel configuration features.

### Why it matters

It fits the CachyOS philosophy well and gives the user direct access to the
kernel ecosystem that distinguishes CachyOS.

### Margine position

`Adopt as optional`

This makes sense in the personal product, but not as a hard dependency of the
runtime baseline.

Reason:

- useful if you actually want to explore Cachy kernels
- unnecessary if the distro should stay tightly curated

## `cachyos-hello`

### What it is

A welcome/onboarding application.

### Why it matters

Low risk. It can expose onboarding, links, or first-run operations without
interfering with system architecture.

### Margine position

`Adopt or rebrand`

For the personal product this is reasonable. For the public product, not
appropriate unless reworked under Margine branding.

## `cachyos-packageinstaller`

### What it is

A GUI package installer.

### Why it matters

This is the main convenience layer many users mentally associate with
"CachyOS having more than Arch".

However, it creates an architectural question:

- should package bundles be managed by a foreign GUI
- or by Margine manifests and layered provisioning

### Margine position

`Do not adopt for now`

Reason:

- Margine already has a stronger architectural story with
  `install-from-manifests`
- a second bundle manager dilutes source of truth
- it adds convenience, but also multiplies the number of package decision
  surfaces

If adopted later, it should be treated as:

- a convenience frontend
- not the canonical owner of package composition

## `cachyos-settings`

### What it is

A system behavior package that pulls in:

- `zram-generator`
- `ananicy-cpp`
- `cachyos-ananicy-rules`
- regulatory and system support pieces

and also enables services in its install script.

### Why it matters

This is not "just a settings package". It changes runtime behavior.

### Margine position

`Cherry-pick, do not install wholesale`

This package is valuable as a reference, but dangerous as a blind import,
because Margine already versions:

- power behavior
- boot and recovery behavior
- maintenance and update logic
- desktop/session behavior

Installing it directly would mix two owners of system policy.

The correct use is:

- inspect its behavior
- import specific ideas that fit Margine
- keep Margine as the policy owner

## `cachyos-firefox-settings`

### What it is

A Firefox settings package that:

- installs a default preference file
- installs enterprise policies
- installs `uBlock Origin`
- disables various Mozilla recommendation, telemetry, and sponsored surfaces

### Why it matters

This is a good example of a package that is useful as a reference even if you
do not want it to own your final browser policy.

### Margine position

`Cherry-pick`

Margine already versions browser behavior. So the right move is:

- inspect and borrow the good ideas
- keep the resulting policy under Margine control

## `cachyos-hooks`

### What it is

A collection of `libalpm` hooks and helper scripts.

It includes behaviors around:

- branding
- reboot-required signaling
- initramfs refresh helpers
- OS metadata maintenance

### Why it matters

Hooks are not decorative. They affect update semantics.

### Margine position

`Cherry-pick carefully`

Margine already has a custom update path, boot refresh path, UKI handling,
Secure Boot signing, and recovery generation. Importing foreign hooks wholesale
would be careless.

The correct stance is:

- inspect the hooks
- import only ideas that strengthen Margine's own flow

## `cachyos-hyprland-settings`

### What it is

A prebuilt Hyprland settings package with its own stack choices and visual
opinions.

### Why it matters

This package overlaps directly with Margine's strongest custom layer:

- Hyprland
- Waybar
- SwayNC
- Hyprlock
- helpers under `~/.local/bin`

### Margine position

`Reject`

This would create two competing desktop owners.

For `margine-cachyos`, desktop policy should remain fully controlled by the
Margine desktop layer.

## `cachyos-snapper-support`

### What it is

A Snapper support package with CachyOS templates.

### Why it matters

This is fine in a stock CachyOS setup, but Margine already implements a custom:

- Snapper layout
- pre-update snapshot policy
- Limine snapshot entry generation
- recovery operating model

### Margine position

`Reject`

This overlaps too heavily with Margine's boot and recovery design.

## `cachyos-calamares` and `cachyos-cli-installer-new`

### What they are

Installer frameworks for the live ISO / installation environment.

### Why they matter

They matter when building or shipping an installer ISO, not when reasoning
about the installed runtime.

### Margine position

`Use only for installer work`

Do not treat them as installed-system baseline packages.

## `cachyos-gaming-meta` and `cachyos-gaming-applications`

### What they are

Optional gaming bundles and dependencies.

### Why they matter

Useful for a gaming-oriented profile, but not part of a clean general-purpose
baseline.

### Margine position

`Optional future layer`

Reasonable for a dedicated gaming layer, not for the default personal runtime.

## `cachyos-micro-settings`, `cachyos-fish-config`, `cachyos-zsh-config`, `cachyos-wallpapers`

### What they are

Opinionated app/shell/branding additions.

### Why they matter

They are legitimate parts of the CachyOS experience, but they are not core
distribution mechanics.

### Margine position

- `cachyos-wallpapers`: optional, low risk
- `cachyos-fish-config`: reject unless fish becomes a first-class Margine shell
- `cachyos-zsh-config`: reject unless zsh becomes a first-class Margine shell
- `cachyos-micro-settings`: reject, low strategic value for the current
  Margine direction

## Recommended import matrix for `margine-cachyos` personal

### Adopt now

- `chwd`
- `cachyos-kernel-manager` as optional user-facing tooling
- `cachyos-hello` if welcome/onboarding value is desired

### Cherry-pick and re-own

- `cachyos-settings`
- `cachyos-firefox-settings`
- `cachyos-hooks`

### Keep out of the baseline

- `cachyos-hyprland-settings`
- `cachyos-snapper-support`
- `cachyos-packageinstaller`
- `cachyos-calamares`
- `cachyos-cli-installer-new`
- `cachyos-fish-config`
- `cachyos-zsh-config`
- `cachyos-micro-settings`

### Optional future layer

- `cachyos-gaming-meta`
- `cachyos-gaming-applications`
- `cachyos-wallpapers`

## The real lesson

Being "CachyOS-based" does not mean:

- importing every CachyOS-branded package

It means:

- keeping the parts that materially improve the product
- rejecting the parts that duplicate or fight Margine's own architecture

The personal product should be:

- genuinely Cachy-backed at kernel, repositories, and selected hardware/runtime
  tooling
- still clearly Margine in desktop behavior, update orchestration, recovery
  flow, and versioned policy

## Sources and references

- CachyOS live ISO package list:
  `https://github.com/CachyOS/CachyOS-Live-ISO/blob/master/archiso/packages_desktop.x86_64`
- CachyOS live ISO helper scripts:
  `https://github.com/CachyOS/CachyOS-Live-ISO`
- CachyOS Calamares online package groups:
  `https://github.com/CachyOS/cachyos-calamares/blob/master/src/modules/netinstall/netinstall.yaml`
- CachyOS Calamares dotfile/settings package logic:
  `https://github.com/CachyOS/cachyos-calamares/blob/master/src/modules/netinstall/PackageModel.cpp`
- CachyOS PKGBUILDs:
  `https://github.com/CachyOS/CachyOS-PKGBUILDS`
