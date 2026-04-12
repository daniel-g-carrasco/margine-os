# ADR 0031 - Print and Scan Baseline

## State

Accepted

## Context

`Margine` must handle well:

- modern network printers;
- modern USB multifunctions;
- network scanners or integrated into `IPP/eSCL` devices;
- simple management without immediately introducing vendor-specific drivers.

You therefore need to decide:

- which stack to use for printing;
- which stack to use for scanners;
- how to manage local discovery and naming;
- which tools to offer for daily management.

## Decision

For `Margine v1` we adopt a `driverless-first` baseline:

- `CUPS` per la stampa;
- `cups-filters` and `ghostscript` as practical conversion support;
- `Avahi + nss-mdns` for discovery and resolution `mDNS/DNS-SD`;
- `ipp-usb` for modern USB devices that expose `IPP over USB`;
- `SANE` per il layer scanner;
- `sane-airscan` for modern `eSCL/WSD` scanners and MFPs;
- `system-config-printer` as the main printer management tool;
- `simple-scan` as a simple scanner frontend.

## Why this choice

The criterion is consistent with the rest of the project:

- prefer open and widespread standards;
- prefer official Arch packages;
- avoid vendor-specific stacks until they are really needed;
- separate engine, discovery and interface.

### Print side

Here the pieces are:

- `CUPS` as print scheduler;
- `Avahi` to discover queues and devices on the network;
- `ipp-usb` to talk `IPP` even to modern USB devices.

This basis covers well the most common case today:

- `IPP Everywhere`
- AirPrint
- Mopria

### Scanner side

Here the pieces are:

- `SANE` as general backend;
- `sane-airscan` for modern, multifunctional network devices.

## Discovery locale

To make local discovery work well with `Avahi`, `Margine` updates the
linea `hosts:` di `/etc/nsswitch.conf` per includere `mdns_minimal
[NOTFOUND=return]`, without overwriting the entire file.

## Daily management

For `Margine v1` the recommended path is:

- `system-config-printer` to add and modify printers;
- `simple-scan` for basic scanning;
- `http://localhost:631` as a supporting CUPS interface, not as a method
primary.

## Services enabled

The baseline enables:

- `cups.socket`
- `avahi-daemon.service`
- `avahi-daemon.socket`
- `ipp-usb.service`

## What doesn't make it into v1

For now they do not enter the baseline:

- vendor-specific drivers for older printers;
- proprietary scanner backends;
- advanced server-side sharing of scanners (`saned`);
- pre-configured print queues for specific models.

## Consequences

### Positive

- simple, modern and reproducible baseline;
- good coverage for modern printers/scanners;
- management consistent with the rest of the GTK/Wayland system.

### Negative

- some older devices may require extra packages;
- the `driverless-first` path does not cover all existing hardware.

## For a student

The lesson here is this:

- printing doesn't just mean installing `cups`;
- scanning doesn't just mean installing `simple-scan`;
- discovery, backend and interface are three different levels.
