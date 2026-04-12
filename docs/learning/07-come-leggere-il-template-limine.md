# How to read the first Limine template

This note accompanies the file:

- [limine.conf.template](/home/daniel/dev/margine-os/files/esp/EFI/BOOT/limine.conf.template)

The purpose of the template is not to already be "finished".
The aim is to establish the right structure.

## 1. What's static

In the template there are parts that we want to keep stable:

- timeout;
- branding;
- entry `Produzione`;
- entry `Fallback`;
- `Recovery` section.

This is the part of the file that makes sense to version in Git.

## 2. What is variable instead

There are two types of data that we don't want to write by hand every time:

- machine identifiers, such as `UUID`;
- list of recovery/snapshot entries.

For this reason in the template you will find placeholders such as:

- `@ROOT_UUID@`
- `@LUKS_UUID@`

and markers like:

- `BEGIN MARGINE GENERATED RECOVERY ENTRIES`
- `END MARGINE GENERATED RECOVERY ENTRIES`

The lesson here is important:

- we version the structure;
- we generate the variable data.

## 3. Why there is a "Manual recovery" entry

It serves as a minimum baseline.

Even if the snapshot generator isn't ready yet, we already want to have:

- una `UKI` recovery;
- a recognizable recovery entries;
- a clear place to inject the command line.

This is a very healthy rule:

- first build a simple fallback;
- then build advanced automation.

## 4. Why we use `boot():/EFI/Linux`

Because the config file lives next to `Limine` on `ESP`, and `Limine`
documents that `boot():` points to the partition from which the config is read.

So:

- `Limine` is in `EFI/BOOT`;
- the `UKI` are in `EFI/Linux`;
- the config reaches them with clear and readable paths.

## 5. What is still missing

Three key pieces are still missing:

- the generator of the final file;
- the logic that discovers bootable snapshots;
- hooks that regenerate the file after updates or snapshot changes.

So this file is not the "last stop".
This is the first point where the boot strategy becomes concrete.
