# Because Limine must be "enrolled" before being signed

## The problem in one sentence

`limine enroll-config` modifies the `BOOTX64.EFI` binary.

If you sign first and edit later, the signature no longer corresponds to the content
of the file.

## What enroll-config actually does

The command:

```bash
limine enroll-config <bootloader.efi> <blake2b-di-limine.conf>
```

writes the `BLAKE2B` hash of the file into the Limine EFI binary
`limine.conf`.

This serves to do one specific thing:

- prevent someone from modifying `limine.conf` without Limine realizing it.

## Because it's not enough to just sign the bootloader

If you just sign `BOOTX64.EFI`, but leave the config free to change, you still have
un punto debole:

- the firmware trusts the binary;
- however, the binary could read an altered config.

The `enroll-config` mechanism closes this very hole.

## The correct order

The correct order is:

1. copy `BOOTX64.EFI` to `ESP`;
2. copy `limine.conf` to `ESP`;
3. calculate the hash of that `limine.conf`;
4. run `limine enroll-config` on the already deployed `BOOTX64.EFI`;
5. sign the resulting `BOOTX64.EFI`;
6. firmare le `UKI`;
7. verify everything with `sbctl verify`.

## Because we use the file on the ESP and not the staging one

Why the firmware doesn't boot the staging file.
Boot the file to `ESP`.

So the chain of trust must be built on the final file, not on one
intermediate copy.

## The rule of thumb to remember

When `limine.conf` changes, it is not enough to copy the file.

Devi anche:

1. update hash inside `BOOTX64.EFI`;
2. rifirmare `BOOTX64.EFI`.

## How it relates to Margin

In `Margine` this becomes an explicit stream:

- `deploy-boot-artifacts` installs files;
- `refresh-efi-trust` allinea hash e signatures;
- `update-all` orchestrates everything.

## If you want to change behavior in the future

The real levers are these:

- the path of the `BOOTX64.EFI`;
- the path of the `limine.conf`;
- quali `UKI` firmare;
- whether the trust chain refresh is automatic or manual.

What should not be changed lightly is the logical order:

`deploy -> enroll-config -> sign -> verify`
