# ADR 0042: Local Package Overrides

## Status
Accepted.

## Context
Some Margine defaults need local package sources or small local package patches:
currently the patched Walker scroll behavior. Building those packages inside a
graphical live ISO is fragile: it can trigger build dependency churn,
partial-upgrade conflicts, memory pressure and non-reproducible failures before
the installed system even boots.

## Decision
Margine supports two paths:

- preferred release path: prebuild local override packages into
  `local-pacman-repo/` before installation and let `install-from-manifests`
  consume them as normal pacman packages;
- fallback install path: install a first-boot timer that builds local overrides
  from the installed system after the login path is available.

The first-boot path is intentionally best-effort. It logs to
`/var/log/margine/firstboot-local-overrides.log`, records state below
`/var/lib/margine/local-overrides/`, and does not retry automatically on every
boot. A failure must not block greetd, Hyprland or the Fuzzel launcher fallback.
During manifest installation, local override packages are installed immediately
only when a matching prebuilt package exists in `local-pacman-repo/`; otherwise
they are deferred to this first-boot path.

Manual retry is explicit:

```bash
sudo margine-build-local-overrides --retry --strict
```

## Consequences
The live ISO no longer performs AUR builds or full system upgrades just to get a
patched launcher. A clean install remains usable with Fuzzel even when the
Walker override cannot be built immediately. Release builds can still provide a
fully patched Walker from the start by shipping a prebuilt local package repo.
