# How Secure Boot bootstrap works

## The basic idea

When you install `Margine` on a new machine, there are two different times:

1. the moment you teach the firmware which keys to trust;
2. the moment you actually sign the files that the firmware will have to boot.

These two moments are connected, but they are not the same thing.

## First moment: trust in the firmware

Con `sbctl` facciamo tre cose:

1. we check the current status;
2. we create the key hierarchy;
3. we enroll the keys in the firmware.

The hierarchy is this:

- `PK`
- `KEK`
- `db`

You don't have to remember all the details now.
All you need to know is that it's the standard `Secure Boot` chain.

## Why Setup Mode is needed

The firmware does not accept new arbitrary keys at any time.

You need to get it to `Setup Mode` first.

In practice, the correct flow is:

1. reboot into firmware;
2. Secure Boot section;
3. deletion of the current keys or at least the `PK`;
4. return to Linux;
5. running the `sbctl` bootstrap.

## Why do we use -m

`sbctl` recommends including Microsoft certificates during enrollment.

This doesn't mean "delegate everything to Microsoft."
It simply means avoiding breaking firmware or Option ROM components that
they also expect those signatures.

So for `Margine v1` the conservative default is:

```bash
sbctl enroll-keys -m
```

## Why don't we put the sbctl keys in the TPM right away

Because in `Margine v1` we already need `TPM` for a very important thing:

- help unlock `LUKS2`.

If at this stage we also put the key storage model in the `TPM`
`sbctl`, we increase the complexity without a clear gain for the former
version.

For this reason we start with:

- keys `sbctl` as file;
- root encrypted with `LUKS2`;
- `TPM2` focused on the disk unlock path.

## Dove entra refresh-efi-trust

Once the firmware trusts our keys, we have to actually sign
the boot files.

That's where it comes into play:

- `refresh-efi-trust`

which does:

1. hash di `limine.conf`;
2. `limine enroll-config`;
3. signature of `BOOTX64.EFI`;
4. signature of `UKI`;
5. final check.

## The right mental rule

`Secure Boot` bootstrapping is not "updating the system".

It's "preparing the firmware to trust the system".

This is why we don't put it in `update-all`.

## How to change it in the future

The editable choices are:

- usare o meno `-m`;
- export the keys or not;
- use `TPM` keys for `sbctl` in the future;
- add additional OEM or custom certificates.

The thing that should not be confused is the separation of moments:

- trust is built first;
- then you sign the files.
