# Because a bootable snapshot is not a full rollback

Seeing a snapshot in the boot menu is very powerful.

But it's easy to be fooled and think:

- "then the system can always go back on its own".

It's not like that.

## What a bootable snapshot really does

It allows you to:

- boot to a previous state of the root filesystem;
- inspect it;
- understand what broke;
- use that state as the basis for conscious rollback.

This is a lot, but it's not all.

## What he does NOT do alone

Does not automatically realign:

- the `ESP`;
- EFI signatures;
- the `UKI`;
- the state external to Btrfs;
- any side effects of firmware or package updates.

So a bootable snapshot is:

- an excellent recovery point;
- not a magic wand.

## Why in Margin we use UKI recovery

When booting a snapshot from the menu, your goal should not be:

- "continue as if nothing had happened".

It should be:

- "enter a readable and safe environment to understand the problem".

For this `Margine` uses the recovery `UKI` and mounts the snapshot in `ro`.

## The simple rule

A bootable snapshot serves to recover well.
Full rollback still requires a consistent pipeline.

