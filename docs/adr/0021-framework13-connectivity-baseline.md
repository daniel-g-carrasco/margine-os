# ADR 0021 - Connectivity Baseline for `Framework Laptop 13 AMD`

## State

Accepted

## Problema

`Margine` already had a packet layer for connectivity, but they were still missing
the versioned configurations that turn those packages into behavior
consistent and reproducible.

In the real case of `Margine`, the target is a `Framework Laptop 13 AMD 7040` with
Wi-Fi chip `MediaTek MT7922`, driven by the kernel module `mt7921e`.

You therefore need to decide:

- who really orchestrates the network and VPN;
- which Wi-Fi backend to use;
- how to manage regulatory domain and TUI tools;
- how much tuning driver to introduce in `v1`.

## Decision

For `Margine v1` the connectivity baseline is:

- `NetworkManager` as primary orchestrator;
- `iwd` as Wi-Fi backend of `NetworkManager`;
- `OpenVPN` and `WireGuard` managed as `NetworkManager` profiles;
- `impala` as TUI Wi-Fi;
- `bluetui` as TUI Bluetooth;
- Wi-Fi regulatory domain versioned and enforced via `cfg80211`;
- no aggressive tuning of the `mt7921e` module in the `v1`.

## Why this choice

The point here is to separate the roles:

- `NetworkManager` is the system brain for network status, VPN and integration
  col desktop;
- `iwd` is the Wi-Fi engine;
- `impala` e `bluetui` sono interfacce terminal-first coerenti col workflow
user.

This combination is more pragmatic than `iwd` alone, but much more aligned
to actual machine use: daily Wi-Fi, VPN `OpenVPN`/`WireGuard` e
integration with `waybar`.

## Regulatory domain

`Margine` releases a `modprobe.d` drop-in for `cfg80211` with a country code
explicit.

In the Italian baseline the value is `IT`, but the bootstrap treats it as
parameter and can render different code.

This choice avoids leaving the regulatory domain implicit or absent.

## Why don't we force tuning on `mt7921e`

On `Framework 13 AMD` there are recurring discussions on power saving and
stability of the MediaTek module, but for `Margine v1` the rule is:

- no "hearsay" driver patches;
- no overriding of `disable_aspm` or `disable_clc` without validation
  riproducibile;
- first we start with the correct backend, correct regulatory domain and firmware
  standard.

If a truly necessary tuning emerges in the future, it will come in with an ADR
dedicated, not as a hidden "little magic".

## Implementation v1

`Margine` version:

- `/etc/NetworkManager/conf.d/10-wifi-backend.conf`
- `/etc/iwd/main.conf`
- `/etc/modprobe.d/cfg80211-regdom.conf`
- a dedicated provisioner to install these files

The `chroot` bootstrap calls this provisioner before the desktop layer.

## Practical consequences

This decision gives `Margine`:

- an explicit network/VPN/Bluetooth baseline;
- consistency with the target `Framework 13 AMD`;
- less "accidental" configuration taken from the current machine;
- a single point to change Wi-Fi backend or regulatory domain.

## For a student: the simple version

The trick here is not to confuse the levels.

- `NetworkManager` decides *the network status of the system*.
- `iwd` talks *to the Wi-Fi card*.
- `impala` and `bluetui` are just *the convenient* interfaces.

When these levels are clear, the configuration ceases to be one
collection of attempts and it becomes architecture.
