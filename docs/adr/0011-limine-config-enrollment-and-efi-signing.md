# ADR 0011 - Limine config enrollment and EFI chain signing

## State

Accepted

## Why this ADR exists

With ADR 0010 we defined how the artifacts arrive on the `ESP`.

However, the last piece of the trust chain was missing:

- how to protect `limine.conf`;
- when modifying `BOOTX64.EFI`;
- when you actually sign the EFI chain;
- how does it all connect to `update-all`.

## Problem to solve

With `Limine`, the EFI binary signature alone is not enough to protect the
configuration.

In fact, the official Limine documentation recommends:

- to calculate the `BLAKE2B` of `limine.conf`;
- to embed it in the EFI binary with `limine enroll-config`;
- then sign the resulting binary with Secure Boot.

If you sign `BOOTX64.EFI` before `enroll-config`, the signature is invalidated.

## Decision

For `Margine v1`, the EFI trust chain refresh follows this sequence:

1. boot artifacts are generated out of `ESP`;
2. deploy on `ESP`;
3. reinstall the unsigned `Limine` binary on the final EFI path;
4. the `BLAKE2B` of the `limine.conf` already deployed is calculated;
5. si esegue `limine enroll-config` sul `BOOTX64.EFI` già deployato;
6. the resulting `BOOTX64.EFI` is signed with `sbctl`;
7. the `UKI` present on the `ESP` are also signed with `sbctl`;
8. you run `sbctl verify` as a final check.

## Fundamental rule

Config enrollment and signing must occur on the final artifacts
present on the `ESP`, not on the staging copies.

Reason:

- `limine enroll-config` modifies the EFI binary in-place;
- the valid signature must match the file actually booted from
  firmware.

## Sequence rule

The correct order is:

1. deploy;
2. reinstall del loader Limine unsigned;
3. enrollment del digest config;
4. firma;
5. verify.

It is not allowed to reverse `enroll-config` and `sbctl sign`.
It is not even allowed to re-roll a loader that has already undergone mutations
above without first reinstalling the source unsigned binary.

## Return rule

Whenever `limine.conf` changes, the `BOOTX64.EFI` must be:

1. reinstalled from the unsigned reference copy;
2. reenrolled con il nuovo hash;
3. re-signed.

This is not a quirk of `Margine`.
It is a property of the `Limine` security model.

## Role of sbctl

In `Margine v1`, `sbctl` gestisce:

- creation of keys;
- key enrollment in the firmware;
- firma dei binari EFI;
- signed chain verification.

Key creation/enrollment is not part of the ordinary update cycle.
Signature and verification, however, yes.

## Integration with update-all

`update-all` can also orchestrate the trust chain refresh, but only afterwards
il deploy su `ESP`.

The division of roles therefore becomes:

- `generate-limine-config`: produce `limine.conf`;
- `deploy-boot-artifacts`: copy the artifacts to `ESP`;
- `refresh-efi-trust`: enroll the config and sign the EFI chain;
- `update-all`: orchestrate the correct order even on the already installed system.

This applies to both the manual path and the ordinary maintenance path.

If `update-all` or `refresh-efi-trust` skip reinstalling the unsigned loader
before `enroll-config`, the concrete risk is the classic `incorrect digest`
in `sbctl verify` on the active Limine loader.

## Practical consequences

This choice gives us:

- a readable trust chain;
- an explicit relationship between deployed config and signed binary;
- a repeatable process after each kernel or bootloader update;
- less room for manual errors.

## For a student: the simple version

Pensa così:

- `limine.conf` is as important as the bootloader;
- `Limine` checks this config by its hash;
- that hash is written into `BOOTX64.EFI`;
- then the file changes;
- therefore the signature must be done afterwards.

The mental rule to remember is:

`deploy -> reinstall unsigned loader -> enroll-config -> sign -> verify`
