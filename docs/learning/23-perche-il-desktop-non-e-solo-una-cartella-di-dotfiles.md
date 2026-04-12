# Because the desktop is not just a folder of dotfiles

Many people think that "render the desktop" means:

- copy `~/.config`;
- cross your fingers;
- hope that everything starts again.

This is not architecture. It's archaeology.

## What a desktop layer really is

A desktop layer is the set of:

- installed packages;
- configuration file;
- small support scripts;
- session start rules.

If one of these pieces is missing, the desktop is truly unplayable.

## Because `Margine` treats it as a separate layer

Because the desktop has different needs from the basic system.

The basic system must know:

- how to boot;
- how to mount the disk;
- how to create the user.

The desktop needs to know:

- how the session starts;
- which launcher to use;
- how the bar is shown;
- how to manage screenshots, notifications and lockscreen.

Mixing everything in the same container makes the project more difficult
understand and more fragile to maintain.

## The important lesson

A good project doesn't copy your home.

Select:

- what baseline really is;
- what is only local state;
- what is personal and should not enter the repository.

This is why `Margine` versions the desktop, but not your private wallpapers
the cache, not the runtime databases and not the lock files.