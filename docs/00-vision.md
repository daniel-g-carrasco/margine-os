# Vision of the project

## Objective

Obtain from a clean Arch installation a system equivalent to that
desired, not that casually accumulated over time.

The system must be:

- reproducible;
- stable;
- fast;
- well documented;
- educational;
- easy to edit by hand in the future.

## Guiding idea

This project does not want to create "a hacker ISO". He wants to create a system
that Daniel really understands.

Because of this:

- each subsystem will have teaching notes;
- every important decision will have an ADR;
- each phase will have completion criteria;
- each automation must remain legible.

## Technical identity

- Base: `Arch Linux`
- Primary Desktop: `Hyprland`
- Target machine: `Framework Laptop 13 AMD`
- Filesystem: `Btrfs`
- Encryption: `LUKS2`
- Target security: `Secure Boot` under our keys + `TPM2` for unlocking
automatic `LUKS` on the normal boot path
- Focus: photography, stability, rollback, clear maintenance

## Current status note

The desired architecture is:

- `LUKS2` always present
- `Secure Boot` bootstrapped after installation
- `TPM2` enrolled after the signed boot path is already stable

So:

- the target is not "Secure Boot or TPM2"
- the target is `Secure Boot + LUKS2 + TPM2`
- but the correct rollout is gradual and post-install, not all in one step

## What we won't do

- We will not copy all current apps without filter.
- We will not use AUR as the basis of the system.
- Let's not confuse "it works now" with "it's a good architectural choice."
- We won't introduce too many abstraction layers in the first round.

## Name

- Human System Name: `Margine`
- Repository technical name: `margine-os`

Reason: `Margine` has personality. `margine-os` is more convenient for git, package
namespace and file naming.
