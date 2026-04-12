# ADR 0012 - Bootstrap di Secure Boot con sbctl

## State

Accepted

## Why this ADR exists

So far we have defined:

- how to generate `limine.conf`;
- how to deploy the artifacts on the `ESP`;
- how to enroll the Limine config and sign the EFI chain.

However, one fundamental point was missing:

- how do you actually initialize `Secure Boot` on a new machine.

## Problem to solve

`update-all` is not the right place to create keys or enroll them in firmware.

Those operations:

- they are rare;
- they can require `Setup Mode` in the firmware;
- have a risk profile different from normal system updates.

We therefore need a separate, explicit and didactic flow.

## Decision

For `Margine v1`, `Secure Boot` bootstrapping is handled with `sbctl` in a
path separated by `update-all`.

The canonical sequence is:

1. check UEFI status and `Setup Mode`;
2. create keys with `sbctl create-keys`, if missing;
3. enroll keys with `sbctl enroll-keys -m`;
4. refresh the EFI trust chain;
5. restart;
6. check `sbctl status`.

Before the firmware phase, the recommended path becomes:

1. export of the currently enrolled public keys;
2. inspection of the EFI tracks present on the `ESP`;
3. only afterwards, enter the firmware and move to `Setup Mode`.

## Setup Mode rule

Bootstrap should not attempt to bypass the firmware.

If the machine is not in `Setup Mode`, provisioning must stop and ask
to the user:

- reboot into firmware;
- enter the Secure Boot menu;
- delete at least `PK` or in any case bring the machine to `Setup Mode`.

In `Margine v1` we don't use aggressive options like `--yolo`.

## Microsoft rule

Per l'enrollment usiamo di default:

```bash
sbctl enroll-keys -m -f
```

Reason:

- `sbctl` recommends including Microsoft certificates to reduce risk
related to vendor-signed Option ROMs and firmware.
- builtin `db/KEK` firmware certificates help reduce the risk of
break existing OEM or dual-boot chains.

For advanced cases, `sbctl` also exposes `--append` and `--custom`, but in
`Margine` do not become the default: they remain tools to be used only when yes
it already knows which other custom keys must survive.

## Rule keys

In `Margine v1`, `sbctl` keys remain the default type `file`.

Reasons:

- root is already encrypted with `LUKS2`;
- the model is easier to understand and debug;
- we don't want to immediately intertwine two different uses of `TPM`:
  - unlock `LUKS2`;
  - `Secure Boot` key protection.

The `TPM` keys of `sbctl` remain a possible future experiment, not the basis
of the `v1`.

## Regola export

The export of private keys is not automatic.

If the user wants to export them, he must do so explicitly and consciously.

Reason:

- exporting `Secure Boot` keys is a sensitive operation;
- we don't want to generate extra copies without a clear decision.

## Separation of roles

For `Margine` the correct division becomes:

- `provision-secure-boot-preflight`: export current public keys e
inspection `ESP`;
- `provision-secure-boot`: initial bootstrap of keys and enrollment;
- `refresh-efi-trust`: refresh della catena EFI già deployata;
- `update-all`: routine system maintenance.

## Practical consequences

This choice gives us:

- a readable bootstrap;
- less risk of mixing ordinary updates and firmware operations;
- a clearer recovery path if something goes wrong;
- a solid teaching base.

## For a student: the simple version

Think of `Secure Boot` as two different problems:

1. who decides who to trust;
2. which files are actually signed.

`sbctl create-keys` and `sbctl enroll-keys` solve the first problem.

`refresh-efi-trust` solves the second.

This is why the two flows must remain separate.
