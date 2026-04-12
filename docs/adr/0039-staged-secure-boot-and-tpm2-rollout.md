# ADR 0039 - Rollout staged di Secure Boot e TPM2

## State

Accepted

## Context

`Margine` wants to achieve this operational result:

- normal boot signed and verified with `Secure Boot`;
- root encrypted with `LUKS2`;
- automatic unlocking of the normal boot path via `TPM2`;
- separate recovery path, more explicit and tolerant of human fallbacks.

The problem is that these objectives cannot be compressed into a single one
"magic" step of the installer without excessively increasing the risk of:

- TPM2 sealing on wrong PCRs;
- enrollment `sbctl` launched without serious preflight;
- breakage of existing dual boots or OEM chains;
- ambiguous installed state, difficult to debug.

## Decision

For `Margine`, `Secure Boot` and `TPM2` are not treated as a single
monolithic installation feature.

The correct rollout is instead broken into phases:

1. basic system installation;
2. post-install validation of boot, desktop and update path;
3. preflight `Secure Boot`;
4. bootstrap `sbctl` with machine in `Setup Mode`;
5. first Secure Boot validation reboot;
6. TPM2 staging (`crypttab.initramfs` + final UKI);
7. manual reboot on the final path;
8. TPM2 enrollment versus final PCR status;
9. final reboot and auto-unlock validation.

## Current implementation status

What is already closed and versioned today:

- bootstrap `Secure Boot` post-install separated from the installer;
- refresh EFI trust chain with `refresh-efi-trust`;
- ordinary maintenance via `update-all` on the system already installed;
- reinstall unsigned `Limine` loader before `enroll-config`;
- resigning the active loader after `enroll-config`;
- final check with `sbctl verify`.

What remains deliberately staged:

- automatic enrollment `TPM2` not inside the installer;
- sealing only after reboot on the correct final path;
- end-to-end validation in VM only with `swtpm`.

## Regola Secure Boot

The `Secure Boot` bootstrap must be preceded by an explicit preflight.

So:

- `provision-secure-boot-preflight` exports public keys currently
  enroll;
- inspect the EFI rails present on the `ESP`;
- leaves a persistent marker on the system;
- `provision-secure-boot` refuses to proceed if that marker is missing, save
  explicit override.

This does not eliminate all risks, but it makes the case more trivial and more
dangerous: the user who enters `Setup Mode` and immediately launches the enrollment
without even having saved the previous state.

## Adjust firmware and dual boot keys

The prudent default remains:

```bash
sbctl enroll-keys -m -f
```

Reason:

- `-m` helps not to break Windows and Microsoft-branded components;
- `-f` helps not to lose firmware builtin OEM chains.

But this is NOT the same as automatically preserving any other Linux that
use your own custom keys.

So the architectural policy is:

- protect Windows/OEM case well;
- do not promise automatic preservation of third-party custom keys;
- request explicit evaluation for hosts with already customized Secure Boot.

## TPM2 rule

The correct TPM2 rollout does not start before `Secure Boot` is already stable.

The initial policy is:

- enrollment contro `PCR 7+11`;
- claim of `Secure Boot` already active and outside of `Setup Mode`;
- first staging pass without sealing;
- un reboot manuale sul path finale;
- only after that, sealing true TPM2 with `systemd-cryptenroll`.

This approach is slower, but much less fragile.

## QEMU rule

TPM2 validation in VM is not considered real without vTPM.

So the QEMU harness must:

- use `swtpm` when available;
- esporre un TPM virtuale al guest;
- explicitly declare when the TPM2 test is real and when it is not.

## Consequences

This decision involves:

- more operational steps;
- meno ambiguita';
- longer but more honest documentation;
- better separation between "installation successful" and "boot security complete".

In practice:

- the installer must not pretend to be more complete than it really is;
- boot security must be treated as a guided rollout;
- post-install checks must explicitly include `Secure Boot`,
`TPM2`, `vTPM` in QEMU, and the SSH case for remote debugging.
- the installed maintenance path (`update-all`) is part of the surface
security and must remain aligned to the same sequence of the trust chain.
