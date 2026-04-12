# ADR 0034 - QEMU Harness for installation validation

## State

Accepted

## Problema

Serious validation of `Margine` should not be done on the real laptop first.

First you need an environment that allows you to test:

- live ISO Arch;
- blank disk;
- firmware UEFI;
- risk-free reboot;
- complete installation cycle -> first boot.

## Decision

We introduce a validation harness based on:

- `QEMU`
- `OVMF`
- Official Arch ISO

The aim is not to replace the real iron test, but to become the first gate
mandatory before touching the actual laptop.

## Consequences

- bootstrap regressions become more visible;
- initial testing remains repeatable;
- the risk on the real system is greatly reduced.
