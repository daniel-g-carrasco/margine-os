# Why Margine doesn't "fork" Arch

This note answers a very natural doubt:

- if we build a personal distro, we have to update it every time Arch
update anything?

The correct answer, as we are designing `Margine`, is:

- no, not in that sense.

## 1. Two different levels

To understand the project well you must separate two levels.

### Level 1: Arch

Arch fornisce:

- packages;
- il kernel;
- `systemd`;
- rolling updates;
- the basic tools.

### Level 2: Margin

`Margine` fornisce:

- selecting the right packages;
- the configurations;
- scripts;
- the hooks;
- documentation;
- the recovery and maintenance logic.

The important lesson is this:

- `Margine` does not replace Arch;
- `Margine` organizza Arch.

## 2. Why this model is better for us

If we did a true frozen fork of Arch, we would:

- follow each update much more closely;
- manage your own builds and packages;
- greatly increase the complexity of the project.

This is not consistent with our goals.

We want:

- a strong and reproducible personal system;
- do not become a generalist mini-distribution.

## 3. What happens when you do a fresh installation

When you install `Margine` from scratch, this will happen:

1. start from a clean Arch base;
2. `pacman` takes the packages available at that moment;
3. our scripts reconstruct the `Margine` shape on top of those packages.

So you won't install:

- "an old frozen photograph of the system"

Instead you will install:

- "today's updated form of Margin over Arch".

## 4. What happens when you upgrade the already installed system

Here the rule is even simpler.

Updating a `Margine` system will, in general, mean:

- update packages;
- regenerate artifacts that depend on the boot path;
- verify that snapshots and signatures are consistent.

It doesn't mean:

- rewrite the `margine-os` repo every time.

## 5. When the repo needs to be changed instead

The repo must be changed when the project changes, not every time a project changes
package.

Esempi veri:

- change the name of a package we use;
- change the path of `Limine`;
- change the behavior of `mkinitcpio`;
- we decide on a new policy `TPM2`;
- we replace an application.

This is a distinction that needs to be understood very well:

- updating the system is routine maintenance;
- updating the repo is architectural maintenance.

## 6. Where is `update-all` located?

`update-all` will not be "the place where packages live".

Rather, he will be the conductor of operations such as:

- pre-update snapshot;
- `pacman -Syu`;
- regeneration `UKI`;
- firma;
- verifiche;
- post-update snapshot.

This is a healthy distinction.

Un buon script orchestra.
It does not pretend to be the system repository.

## 7. The mental rule to remember

If one day you get confused, remember this phrase:

- Arch provides the components.
- Margin defines the system.

If you keep these two ideas well separated, the whole project becomes much more
readable.
