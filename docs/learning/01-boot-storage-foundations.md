# Boot, encryption and snapshot: educational explanation

This note does not decide the architecture.
The official decision is in ADR 0002.

This note helps you understand the concepts calmly.

## 1. What is booting

When you press the power button, the computer still knows nothing about Linux.

The sequence, in a simplified way, is:

1. UEFI firmware starts;
2. l'UEFI cerca un bootloader;
3. il bootloader avvia il kernel;
4. the kernel brings the system up to the root filesystem;
5. the user space starts from there.

If this chain is confused, the system becomes fragile.
This is why the first rule of `Margine` is: readable boot chain.

## 2. Why `Limine`

`Limine` is not a modified version of `systemd-boot`.
It's a different bootloader, with different priorities.

It matters to us because:

- gives us a stronger recovery UX;
- lends itself well to bootable snapshots;
- goes well with the idea of ​​testing and recovering quickly;
- makes the boot menu an operational tool, not just a technical detail.

Translated from student to student:

- `systemd-boot` is more linear;
- `Limine` is more oriented towards recovery and boot management
request.

We're choosing `Limine` not because it's "cooler", but because it responds
better to a real project requirement.

## 3. What is a `UKI`

`UKI` means `Unified Kernel Image`.

In practice it is an image that puts together, in a more orderly way:

- kernel;
- initramfs;
- cmdline;
- metadati utili al boot.

Why we like it:

- it is easier to sign;
- it is easier to reason with;
- reduces startup clutter.

## 4. Why `Secure Boot`

`Secure Boot` is not used to "make a scene".
It is used to control what is allowed to leave.

We want to keep it, but not at the cost of inventing a fragile chain.

Therefore, in the case of `Limine`, the point is not just to "enable it".
The point is to verify that the entire chain is really under control.

In practice:

- it's not enough for the boot to "start";
- it must also be clear what is being signed;
- it must also be clear what happens when something changes.

## 5. Why `LUKS2`

`LUKS2` is the disk encryption container.

In practical terms it means:

- if someone physically takes the turned off laptop, the data is not readable
  banalmente;
- protection does not depend only on session login.

It is the serious basis for talking about data security.

## 6. Why `TPM2`

`TPM2` is a hardware chip that can store cryptographic material.

In our case we are interested in unlocking the disk in a more convenient way, but without
give up on a recovery plan.

Key Point:

- `TPM2` does not replace responsibility;
- `TPM2` adds controlled convenience.

This is why in `Margine` we will never use only the TPM:

- there will also be a recovery key;
- there will also be an emergency passphrase;
- everything will be documented.

## 7. Why `Btrfs`

`Btrfs` interests us for three reasons:

- snapshots;
- subvolumes;
- operational flexibility.

For a personal system that you want to upgrade, break, understand and restore,
this is very useful.

## 8. Why `Snapper`

`Snapper` is not the filesystem.
It is the tool that helps to manage snapshots well on `Btrfs`.

We choose it as a basis because:

- it is aligned with the type of project we are building;
- is more consistent with a strict Arch system;
- it lends itself well to a thought-out, not improvised, strategy.

## 9. Why not `systemd-boot` in v1

`systemd-boot` is not wrong.
In fact, it's very clean.

If we chose just based on the simplicity of the boot stack, probably
vincerebbe lui.

But the project expressed a stronger requirement:

- simple recovery;
- bootable snapshots;
- ability to go back in a very concrete way.

This is why in `v1` we don't choose the most minimal bootloader.
We choose the bootloader that promises the most convincing recovery, provided
validate it well.

## 10. What we really need to validate

The `Limine-first` choice is serious only if we verify four things:

1. `Limine` starts `UKI` reliably.
2. `Secure Boot` remains under our control.
3. `TPM2` with `LUKS2` has a clear recovery path.
4. `Snapper` snapshots are truly bootable and restoreable.

This is an important lesson:

- good architecture is not chosen just by intuition;
- you choose, then it happens.

## 11. The take-home lesson

The important thing is not to memorize the names.

The important thing is to understand the criterion:

- we choose the piece that best solves the real problem;
- let's not confuse "simpler internally" with "more useful operationally";
- every feature must be explainable;
- each level must be able to be edited by hand;
- every convenience must have a recovery plan.