# How we think about provisioning storage

## The important point

Partitioning and formatting a disk is not "installing packages".

It is the most destructive and least reversible part of the bootstrap.

This is why we treat it as a dedicated script, separate from the rest.

## La sequenza logica

The correct reasoning is:

1. choose the right disk;
2. delete the previous structure;
3. create the new GPT table;
4. create `ESP` and encrypted partition;
5. initialize `LUKS2`;
6. open the mapping;
7. create `Btrfs`;
8. create the subvolumes;
9. assemble everything into the final layout.

## Why do we use a manifest for subvolumes

To avoid the project having two different truths:

- one in the documents;
- one in the script.

Con il manifest:

- the architecture says which subvolumes must exist;
- the script creates them by reading that source.

## Because the final target is already mounted

Because the next step, `bootstrap-live-iso`, needs a target
ready.

The idea is this:

- the storage script leaves you `/mnt` in a consistent state;
- then the bootstrap can do `pacstrap`, `fstab` and handoff to the chroot.

## Because the script must be paranoid

Because here an error is not a warning.
It's data loss.

So the paranoia is right:

- explicit record;
- explicit destructive confirmation;
- no creative autodetect.

## The mental rule to remember

If a storage script seems too convenient, it's probably too much
dangerous.

Here we want a readable, strict and predictable script.