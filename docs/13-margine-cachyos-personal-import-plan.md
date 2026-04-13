# Margine-CachyOS Personal Import Plan

## Goal

Turn the CachyOS research into a concrete implementation path for
`margine-cachyos` without breaking the architectural boundaries that already
make Margine maintainable.

The target is **not**:

- cloning stock CachyOS
- installing every CachyOS-branded package
- creating a second owner for desktop, recovery, or update logic

The target **is**:

- keeping CachyOS where it adds real value
- keeping Margine as the owner of policy and user experience
- making the private product more Cachy-native in a controlled way

## Current state

Today `margine-cachyos` already uses CachyOS at these levels:

- `cachyos` repositories
- `cachyos` keyring and mirrorlists
- `linux-cachyos`
- `linux-cachyos-headers`
- Cachy-aware validation paths
- product-aware `extra_package_layers`
- product-aware `extra_provisioners`
- a private low-risk package layer for:
  - `chwd`
  - `cachyos-hello`
  - `cachyos-kernel-manager`

That already gives the personal product a real Cachy base.

What it does **not** yet adopt in a structured way:

- selected runtime behavior from `cachyos-settings`
- selected browser policy ideas from `cachyos-firefox-settings`
- selected update/runtime ideas from `cachyos-hooks`

The current `extra_provisioners` hook exists and is versioned, but remains a
scaffold until the first curated behavior cherry-picks are ready.

Validator coverage now also understands product-specific `extra_package_layers`
and can fail when those packages drift from the installed personal product.

## Hard architectural rule

`Margine` must keep a single owner for each of these domains:

- desktop UX
- browser policy
- update orchestration
- boot chain
- recovery behavior
- snapshot model

That means:

- if a CachyOS package overlaps one of those domains, import ideas selectively
- do **not** install the package wholesale unless Margine is ready to delegate
  that ownership

## Decision matrix

| Component | Role in CachyOS | Margine position | Why |
| --- | --- | --- | --- |
| `chwd` | hardware-aware driver/package logic | Adopt | real hardware value, low ownership conflict |
| `cachyos-kernel-manager` | optional GUI kernel tooling | Adopt as optional | useful in a personal Cachy product, not core policy |
| `cachyos-hello` | welcome/onboarding app | Adopt or rebrand | low-risk convenience layer |
| `cachyos-settings` | runtime/system behavior bundle | Cherry-pick | valuable ideas, but too much policy ownership |
| `cachyos-firefox-settings` | browser policy bundle | Cherry-pick | useful reference, but Margine must own browser policy |
| `cachyos-hooks` | package-manager hooks | Cherry-pick carefully | overlaps update and boot flows |
| `cachyos-hyprland-settings` | desktop layer | Reject | conflicts with Margine desktop ownership |
| `cachyos-snapper-support` | Snapper templates | Reject | conflicts with Margine recovery model |
| `cachyos-packageinstaller` | GUI package installer | Reject for now | duplicates manifest/layer model |
| `cachyos-calamares` | installer framework | Installer-only | belongs to ISO/install environment |
| `cachyos-cli-installer-new` | installer framework | Installer-only | belongs to ISO/install environment |
| `cachyos-gaming-meta` | gaming dependency bundle | Optional future layer | useful, but not baseline |
| `cachyos-gaming-applications` | gaming apps bundle | Optional future layer | useful, but not baseline |
| `cachyos-wallpapers` | wallpapers | Optional future layer | harmless, not core |
| `cachyos-fish-config` | fish config | Reject | not aligned with current shell policy |
| `cachyos-zsh-config` | zsh config | Reject | not aligned with current shell policy |
| `cachyos-micro-settings` | micro editor config | Reject | low strategic value |

## Implementation model

### 1. Public repo vs private repo ownership

#### Public repo should own

- generic script support for product-aware Cachy extras
- generic validation support
- generic documentation
- any reusable rollout mechanism that is not private by nature

#### Private repo should own

- `products/margine-cachyos.toml`
- product-specific activation of Cachy extras
- private layer choices
- private release defaults

This keeps the public repository clean while still allowing the personal
product to become more opinionated.

### 2. Package layer strategy

The current manifest model matters:

- shared package layers live in `manifests/packages/*.txt`
- flavor overrides live in `manifests/flavors/<flavor>/packages/*.txt`
- `bootstrap-in-chroot` installs a fixed `phase2_layers` list
- `install-from-manifests` has a fixed `default_layers` list

This creates a current limitation:

- flavor overrides can replace a layer file
- but the product model does **not** yet carry product-specific extra layer
  selection

That means the clean implementation path is **not**:

- stuffing private Cachy additions into random shared layers

The clean path is:

1. add product-aware layer selection support
2. then place private Cachy extras in an explicit layer

### 3. Proposed schema extension

Add product-level support for explicit extra layers.

Recommended future fields in `products/*.toml`:

- `extra_package_layers`
- `extra_provisioners`

Example direction:

```toml
extra_package_layers = ["cachyos-personal-extras"]
extra_provisioners = ["provision-cachyos-personal-baseline"]
```

This avoids hardcoding private product behavior inside generic scripts.

### 4. Proposed layer split

Introduce one explicit optional layer for the personal Cachy product:

- `cachyos-personal-extras`

This layer should carry only packages that are:

- truly Cachy-specific
- meaningful to the installed runtime
- not already represented by the shared Margine baseline

Initial candidate packages:

- `chwd`
- `cachyos-hello`
- `cachyos-kernel-manager`

This layer should live:

- in the private repo if it remains private-only
- in the public repo only if the mechanism is generic and the layer is harmless
  to expose publicly

### 5. Proposed provisioner split

Do **not** treat all Cachy imports as package-only work.

Create a dedicated provisioner:

- `scripts/provision-cachyos-personal-baseline`

Its job should be to own only the selectively adopted behavior, for example:

- applying chosen `cachyos-settings` ideas
- applying chosen Firefox defaults inspired by `cachyos-firefox-settings`
- wiring optional welcome or kernel-manager launchers if needed

It should **not** own:

- Hyprland desktop configuration
- bootloader generation
- Snapper recovery logic
- update-all orchestration

## Exact files likely to change

### Generic/public-capable changes

- `scripts/lib/product-manifests.sh`
- `scripts/install-from-manifests`
- `scripts/bootstrap-in-chroot`
- `products/README.md`
- `docs/03-products-and-repositories.md`
- `docs/04-private-repo-bootstrap.md`
- validators:
  - `scripts/validate-runtime-baseline`
  - `scripts/validate-boot-recovery-baseline`
  - `scripts/validate-host-health`

### Private product files

- `products/margine-cachyos.toml`
- private package layer file for Cachy extras
- private documentation for rollout and validation

### Cherry-pick targets

- browser policy files under `files/etc/firefox/...`
- optional new provisioner under `scripts/`
- optional launcher desktop entries or welcome autostart integration

## Rollout phases

### Phase 1. Product-aware extra-layer support

#### Deliverable

Allow a product manifest to request extra package layers cleanly.

#### Why first

Without this, every future private addition becomes a hack.

#### Success criteria

- no special-casing of `margine-cachyos` inside unrelated scripts
- product-controlled layer selection works in both bootstrap and
  `install-from-manifests`

### Phase 2. Adopt the low-risk Cachy extras

#### Deliverable

Install:

- `chwd`
- `cachyos-hello`
- `cachyos-kernel-manager`

through the new explicit product layer.

#### Success criteria

- clean install on `margine-cachyos`
- no effect on `margine-public`
- validators can confirm package presence only where expected

### Phase 3. Cherry-pick Firefox policy ideas

#### Deliverable

Inspect `cachyos-firefox-settings` and import only the useful policy ideas into
Margine-owned Firefox policy files.

Likely targets:

- `uBlock Origin` installation
- Mozilla recommendation suppression
- sponsored content suppression
- tracking/telemetry reductions if they do not conflict with Margine goals

#### Success criteria

- Firefox policy remains owned by Margine
- no dependency on the foreign Cachy package for policy behavior

### Phase 4. Cherry-pick selected system behavior

#### Deliverable

Review `cachyos-settings` and selectively import only behaviors that fit
Margine.

Candidates to evaluate explicitly:

- `zram-generator`
- `ananicy-cpp`
- `cachyos-ananicy-rules`
- wireless regulatory helpers

#### Success criteria

- each imported behavior has an explicit Margine owner
- imported behavior is validated and documented
- no silent service-enabling from foreign install scripts

### Phase 5. Hook review

#### Deliverable

Review `cachyos-hooks` and port only ideas that reinforce the Margine update
and maintenance model.

#### Success criteria

- no duplicate hook owners
- no conflict with `update-all`, UKI rebuilds, Limine refresh, or Secure Boot
  signing

### Phase 6. Explicit non-goals

These should remain out of scope unless the architecture changes:

- `cachyos-hyprland-settings`
- `cachyos-snapper-support`
- `cachyos-packageinstaller`
- installer frameworks as installed-system baseline

## Validation checklist for the rollout

After each phase, validate:

- package presence for the private product only
- service enablement state
- no desktop regression
- no update-all regression
- no Snapper/Limine regression
- no Firefox policy ownership confusion

The validators should gain explicit checks for:

- `chwd`
- `cachyos-hello`
- `cachyos-kernel-manager`
- any adopted `zram` / `ananicy` behavior

## What should not happen

This rollout is wrong if it results in:

- two owners of browser policy
- two owners of desktop configuration
- two owners of recovery policy
- package imports that are only justified by branding
- silent private hacks embedded into generic public scripts

## Recommended next implementation order

1. implement product-level extra layer support
2. add `cachyos-personal-extras`
3. adopt `chwd`, `cachyos-hello`, `cachyos-kernel-manager`
4. add validator coverage
5. cherry-pick Firefox policy ideas
6. cherry-pick selected `cachyos-settings` behavior
7. review `cachyos-hooks`

## Relationship with DaVinci Resolve

This plan deliberately does **not** include DaVinci Resolve support.

Reason:

- Resolve is a separate vendor/runtime problem
- it should become its own optional, validation-heavy layer later

That keeps the personal Cachy product evolution clean:

- first make it more Cachy-native
- later decide whether to make it Resolve-capable

## Final position

The correct end state for `margine-cachyos` personal is:

- clearly Cachy-backed at kernel, repositories, selected hardware/runtime
  tooling, and some user-facing conveniences
- still clearly Margine-owned in desktop UX, browser policy, update flow, boot
  flow, and recovery model
