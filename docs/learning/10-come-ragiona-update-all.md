# How update-all thinks

This note accompanies:

- [update-all](/home/daniel/dev/margine-os/scripts/update-all)

The right question is not:

- "What commands does it run?"

The right question is:

- "in what order do you think?"

## 1. Why order matters

In a system like `Margine`, upgrading isn't just about downloading packages.

Updating also means:

- preservare la recovery;
- rigenerare il boot path;
- verify that the trust chain does not break.

This is why `update-all` needs phases, not a random list of
commands.

## 2. What is core and what is accessory

For `Margine v1` the core is:

- `pacman`
- `mkinitcpio`
- generation `limine.conf`
- final checks

The accessory layers are:

- AUR
- Flatpak
- `fwupd`

This doesn't mean they are useless.
It means that they do not have the same architectural weight as the core.

## 3. Because some mistakes have to stop everything

If `pacman` fails, or regeneration of the boot part fails, it has no
meaning to continue as if nothing had happened.

That's a hard mistake.

However, if an accessory layer, such as `Flatpak`, fails, the base system can
however, it has been updated correctly.

That's a soft error.

This distinction is very important to learn:

- not all failures have the same weight.

## 4. Why we support dry-run

`--dry-run` serves a very precise thing:

- see the flow before actually running it.

It is useful for three reasons:

- teaching;
- debugging;
- trust in the process.

An important script that you cannot calmly inspect before launching is
a script that educates you badly.

## 5. Because he doesn't do everything yet

The first version of `update-all` does not close all final EFI pipeline.

This is intentional.

The project rule is:

- first let's make the model clear;
- then we complete the automation.

An incomplete but readable script is better than an apparently script
"completo" ma opaco.

## 6. The final rule to remember

`update-all` is not a place where complexity hides.

It is a place where complexity is brought to order.
