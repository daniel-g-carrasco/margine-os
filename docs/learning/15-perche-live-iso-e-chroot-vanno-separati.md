# Because live ISO and chroot must be separated

## Il problema

When you install Arch from live ISO, you are working in two different worlds:

1. the temporary key system;
2. the actual system you are building under `/mnt`.

If you forget this distinction, you start writing confusing scripts.

## First world: the live ISO

Here you have useful tools to install:

- `pacstrap`
- `genfstab`
- `arch-chroot`

But you are not yet "in" the final system.

## Second world: the target system

After `pacstrap`, a basic Arch system already exists inside `/mnt`.

At that point it makes sense to enter it with `arch-chroot` and work there as if it were there
real car.

## What should not be done

It's not a good idea to write a giant single script that:

- mount;
- install;
- generate `fstab`;
- enter the chroot;
- configure local;
- create users;
- install desktop;
- prepare bootloader;
- Secure Boot signature.

That kind of script quickly becomes brittle and opaque.

## The right division

The didactically correct division is:

- phase 1: preparation of the target from the live ISO;
- phase 2: configuration of the target from inside the target.

## Because pacstrap doesn't have to do everything

`pacstrap` is used to create the basic system.

Not the right place for all the logic of the project.

If you use it well:

- install the minimum necessary;
- takes you to a useful chroot;
- from there you continue more cleanly.

## How it relates to Margin

In `Margine` this means:

- `bootstrap-live-iso` prepares the target;
- `bootstrap-in-chroot` continues the work;
- `install-from-manifests` installs the official and optional layers.

## The mental rule to remember

The live ISO prepares.
The chroot configures.

If a script starts confusing these two roles, it's getting uglier
than it should.