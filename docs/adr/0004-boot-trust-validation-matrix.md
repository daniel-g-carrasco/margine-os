# ADR 0004 - Validation matrix for boot, trust chain and recovery

## State

Accepted

## Why this ADR exists

ADR 0002 and 0003 chose an ambitious direction:

- `Limine`
- `UKI`
- `Secure Boot`
- `LUKS2`
- `TPM2`
- `Btrfs`
- `Snapper`

This combination is interesting, but should not be treated as a collage of
feature.

Such a system is only valid if three things hold together:

- the chain of trust;
- la recovery;
- maintenance after updates.

For this reason `Margine` adopts an explicit validation matrix.

## Problem to solve

Boot architectures often fail in one of these ways:

- they only work on paper;
- they are safe but too fragile to updates;
- they do recovery badly;
- they do recovery well but break the trust chain;
- they depend on manual steps that are too opaque.

Our goal is not to "enable features".
It is to demonstrate that the chosen combination is sustainable.

## Decision

Per `Margine v1`, la catena `Limine + UKI + Secure Boot + TPM2 + Snapper` sarà
considered successful only if it passes five gates.

## Gate 1 - Reliable and bootable UKIs

### Hypothesis to be validated

`Limine` must be able to reliably launch a tool-generated `UKI`
standard di Arch.

### Operational choice

Let's start with the most linear solution:

- generating `UKI` via `mkinitcpio`
- a single "prod" kernel line in the first validation
- kernel command line embedded in `UKI`

### Why this choice

- `mkinitcpio` on Arch already supports `UKI`;
- embedding the command line in `UKI` reduces ambiguity;
- fewer variables in the first round means more serious validation.

### Evidenze richieste

- the `UKI` is generated in a repeatable way;
- `Limine` shows it and starts it;
- the system boots normally without "scattered" boot files;
- the actual command line is the expected one.

### Failure condition

The gate fails if:

- la generazione `UKI` dipende da workaround opachi;
- `Limine` does not handle it stably;
- boot entry depends on non-repeatable manual manipulations.

## Gate 2 - Secure Boot under our control

### Hypothesis to be validated

We can use `Secure Boot` without delegating trust to a chain that doesn't
let's actually check.

### Operational choice

We adopt:

- our keys managed with `sbctl`
- signature of `UKI`
- firma dei binari EFI di `Limine`
- maintenance of Microsoft certificates if needed for firmware or Option ROM

We do not adopt in `v1`:

- `shim`
- `MOK`

unless real needs emerged from the tests.

### Why this choice

- `sbctl` is the natural handler on Arch;
- keeping control over the keys is a project requirement;
- avoiding `shim/MOK` in `v1` reduces cost-free complexity.

### Evidenze richieste

- `sbctl status` shows `Secure Boot` active;
- `sbctl verify` confirms expected files signed;
- the system launches `Limine` and the signed `UKI` without degrading the UX;
- after a real reboot the machine remains in policy-consistent mode.

### Failure condition

The gate fails if:

- binary signature cannot be clearly automated;
- updating `Limine` or `UKI` requires steps that are too fragile;
- to make everything work we need to introduce a more complex chain of
the one we wanted to avoid.

## Gate 3 - TPM2 useful, not fragile

### Hypothesis to be validated

`TPM2` should improve the disk unlocking experience, without transforming every
update in a trap.

### Operational choice

Enrollment order:

1. administrative passphrase
2. recovery key
3. unlock `TPM2`

Recommended initial policy:

- PCR `7+11`

We do not include in the `v1`, unless proven necessary:

- PCR `0`
- PCR `2`
- PCR `12`

### Why this choice

Dal manuale di `systemd-cryptenroll`:

- `PCR 7` reflects status and certificates of `Secure Boot`
- `PCR 11` reflects the contents of `UKI`

The same manual warns that PCRs like `0` and `2` are often too fragile for
the updates. Furthermore, if the command line remains embedded in the `UKI`,
we have no reason to start with `PCR 12` right away.

### Evidenze richieste

- normal boot with unlock via `TPM2`;
- correct unlock failure if the trust chain changes significantly;
- successful unlock with recovery key when `TPM2` can't unseale;
- understandable re-enrollment procedure after major updates.

### Failure condition

The gate fails if:

- normal updates break unseal too often;
- human recovery is ambiguous or incomplete;
- the PCR policy is too fragile for a real laptop.

## Gate 4 - Really bootable snapshots

### Hypothesis to be validated

Snapshots of `Snapper` must be bootable via `Limine` in this way
consistent with our recovery model.

### Operational choice

Recovery via snapshot must demonstrate at least three things:

- boot a known root snapshot;
- clear recognition of the booted state;
- documented restore or rollback procedure.

Bootable snapshots are a recovery feature, not the normal path
boot.

### Why this choice

This is where the real reason why we chose `Limine` comes into play.
If snapshots don't become truly bootable, we're absorbing complexity
without taking the main advantage.

### Evidenze richieste

- creation of pre-update and post-update snapshots;
- presence of understandable recovery entries;
- successful boot into a known snapshot;
- verifies that the system inside the snapshot really matches the state
expected;
- explainable return to current system or rollback procedure.

### Failure condition

The gate fails if:

- snapshot entries are too fragile;
- the procedure requires dangerous manual interventions on `/boot`;
- the recovery is nice to look at but not very reliable.

## Gate 5 - Sustainable Updates

### Hypothesis to be validated

The complete chain must survive ordinary updates, not just the
day zero.

### Operational choice

Every major update must be able to pass through this pipeline:

1. snapshot pre
2. update packages
3. regeneration `UKI`
4. resigning of EFI binaries
5. refresh boot/recovery entries
6. post snapshot
7. verification reboot

### Evidenze richieste

- at least one successful end-to-end kernel update;
- no essential passages left "by heart";
- `Secure Boot` status still valid after update;
- `TPM2` still consistent or documented and rapid recovery;
- recovery snapshots still usable.

### Failure condition

The gate fails if:

- the system is reliable only before the first kernel update;
- maintenance requires too much manual work;
- recovery and trust chain diverge after updates.

## Final acceptance criterion

The `Limine-first` architecture remains accepted only if all five gates
passano.

If a structural gate fails, the architectural fallback remains the same
defined:

- `systemd-boot`
- `UKI`
- `Secure Boot`
- `LUKS2`
- `TPM2`
- `Btrfs`
- `Snapper`

## Practical consequences

This ADR imposes discipline on us:

- no "feeling" activations;
- no untested security;
- no recovery only theoretical;
- each subsystem will have to produce verifiable evidence.

## For a student: the simple version

The question is not:

- "Can we turn everything on?"

The right question is:

- "this chain continues to work well even after errors, updates and
  recovery?"

This matrix is ​​for exactly this:

- first we prove that the design holds up;
- then we transform it into installer and automation.

## References

- `systemd-cryptenroll(1)`:
  man locale
- `systemd-stub(7)`:
  man locale
- `mkinitcpio(8)`:
  man locale
- `sbctl(8)`:
  https://man.archlinux.org/man/sbctl.8.en
- `limine` Arch package:
  output locale di `pacman -Si limine`
- Limine, official repository:
  https://github.com/limine-bootloader/limine
