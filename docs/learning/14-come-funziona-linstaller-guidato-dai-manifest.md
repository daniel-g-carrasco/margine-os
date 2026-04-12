# How the manifest-driven installer works

## The key idea

Manifests are the truth about the contents of the system.

The installation script is not the source of the policy.
It's just the engine that executes that policy.

## Why it matters

If the package list is inside a giant script, two things happen:

- it becomes difficult to understand what you are installing;
- it becomes difficult to change a choice without touching logic.

Separating `dati` and `logica` is the correct way.

In this case:

- the `dati` are the manifests;
- the `logica` is the script that reads them.

## The three different worlds

In `Margine` we distinguish three worlds:

1. official Arch repo
2. AUR
3. Flatpak

They all look like "software to install", but they are not the same thing.

This is why the script doesn't treat them all the same.

## What the default path does

The normal route installs only the official layers, in the order decided by
project.

This is the important point:

- the default must be the strongest and most supportable path.

## Because AUR and Flatpak are not by default

Because they are two conscious choices:

- AUR increases the maintenance surface;
- Flatpak adds another ecosystem.

They are not "wrong".
They just don't have to go into the basic bootstrap without you deciding to.

## Why dry-run is needed

`dry-run` allows you to see:

- which layers are you installing;
- which packets will be passed to `pacman`;
- if you are going to include AUR or Flatpak.

Educationally it is very useful because it makes you read the plan before executing it.

## How to edit it well

If you want to change the target system:

- edit manifests.

If you want to change the behavior of the installer:

- edit the script.

This distinction is fundamental.

## The right mental rule

If you find yourself wanting to modify a package inside the script, you probably are
touching the wrong place.