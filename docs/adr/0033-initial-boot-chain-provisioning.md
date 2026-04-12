# ADR 0033 - Initial boot chain provisioning

## State

Accepted

## Problema

`Margine` already had:

- storage provisioning;
- bootstrap live ISO;
- bootstrap in chroot;
- generation `limine.conf`;
- deploy and refresh the trust chain for updates.

However, a fundamental piece was missing: the first provisioning of the boot chain
during the initial installation.

Without this step, the project could install the system but not
really close the `Limine + UKI` boot path.

## Decision

We introduce a dedicated provisioner:

- `provision-initial-boot-chain`

This script, executed in the chroot phase, must:

1. install baseline `mkinitcpio`;
2. render `/etc/kernel/cmdline` with the target's real UUIDs;
3. generate three `UKI`:
   - production
   - fallbacks
   - recovery
4. render `limine.conf`;
5. install `Limine` on `ESP`;
6. run `limine enroll-config`.

## Consequences

- the initial installation becomes truly bootable with `Limine`;
- end-to-end testing in VM finally makes sense;
- the `Secure Boot` part remains separate:
the initial bootstrap installs the boot chain, but doesn't force it yet
firmware key enrollment.
