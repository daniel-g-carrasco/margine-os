# Because the boot chain must be validated, not just assembled

This note explains the meaning of ADR 0004.

When you read these words in a row:

- `Limine`
- `UKI`
- `Secure Boot`
- `TPM2`
- `LUKS2`
- `Snapper`

you risk making a very common mental mistake:

- thinking that it is enough to "put the pieces together".

It's not enough.

## 1. A chain is only as strong as its most fragile point

Such a system has at least three simultaneous objectives:

- avviare bene;
- proteggere bene;
- recuperare bene.

If one fails, the project gets worse even if the other two seem strong.

Esempio:

- if booting is convenient but `Secure Boot` is improvised, security is weak;
- if security is strong but updates always break `TPM2`, maintenance is
bad;
- if the recovery is theoretical but no one dares to use it, it is not real recovery.

## 2. Why we start from UKI

A `UKI` is useful because it puts in a single signable object:

- kernel
- initramfs
- command line

The important lesson is this:

- fewer critical files scattered across the boot path means less ambiguity.

If you sign a unique object, the trust chain becomes more readable.

## 3. Why we care so much about the built-in command line

The kernel command line is not a decorative detail.
It can change the behavior of the system in a real way.

If you leave it too loose:

- the chain of trust becomes more complicated;
- PCRs become more delicate;
- boot repeatability worsens.

For this reason, in the first validation, the healthy choice is:

- command line embedded in `UKI`.

Not because it's the only possible way.
Because it's the most disciplined way to start.

## 4. Why `TPM2` should not be tied to PCR at random

There is a very important lesson here.

TPM is not "magic that unlocks the disk".
The TPM unlocks the disk only if the measured state of the machine matches
what you have decided to consider valid.

So the problem is not:

- "uso TPM sì o no?"

The real problem is:

- "What do I tie the TPM to?"

For `Margine v1`, the sensible starting point is:

- `PCR 7`
- `PCR 11`

Why:

- `PCR 7` follows the status of `Secure Boot` and certificates;
- `PCR 11` follows the contents of `UKI`.

Instead starting immediately with PCR like `0` or `2` would be more fragile, because there
firmware and hardware components that change during the process are more easily entered
real life of the car.

## 5. Because the recovery key comes before the TPM

This is a rule of technical maturity:

- first prepare the human fallback;
- then add convenient automation.

Correct order:

1. administrative passphrase
2. recovery key
3. TPM2

If you reverse this order, you are building convenience before security
operational.

## 6. Why bootable snapshots are a real architectural test

Bootable snapshots are not decoration.

They are the point where they meet:

- filesystem
- bootloader
- recovery policy
- trust in the system

If they malfunction, `Limine` loses much of the reason we have it
choice.

This is why in the project we will never say:

- "more or less the snapshots are there"

Instead we will say:

- they really boot;
- you know how to recognize what you have booted;
- you know how to go back without panic.

## 7. Why we validate by gate

Validating by gate means not confusing problems.

Esempio:

- if `TPM2` fails, we also don't want to wonder if the problem is `Snapper`;
- if `Secure Boot` fails, we still don't want to have three kernels in between, two
  boot path e addon vari.

Each gate isolates a clear question.

This is the real reason why a complex project remains readable.

## 8. The take-home lesson

Assembling many advanced pieces does not mean having an advanced architecture.

You really have an architecture when you can answer these questions well:

- What are we trusting?
- What are we measuring?
- what happens after an update?
- How do I get back if something breaks?

If you can answer these four questions, then you are already thinking from
designer and not just as a user.
