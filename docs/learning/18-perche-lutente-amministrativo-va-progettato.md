# Because the administrative user must be designed

## The important point

Creating a user isn't just throwing `useradd`.

Stai decidendo:

- how you will manage the machine;
- how readable the configuration will be;
- how easy it will be to understand permissions over time.

## The classic mistake

The classic mistake is this:

- add the user to many groups "for security";
- no longer knowing why those groups exist;
- find yourself with permissions that are too broad.

## Choosing Margin

For `Margine v1` we use neither absolute minimum baseline nor copy-paste
blind of the current machine.

Instead, let's choose a personal workstation baseline:

- `wheel` for administration;
- `video` and `render` for GPU, ROCm and OpenCL;
- `kvm` and `libvirt` because the project also wants to be ready for VM e
  containers;
- `colord` because `Margine` was born with a strong orientation towards photography and
  color management.

The teaching rule does not change:

- each group must have a clear reason;
- if a group enters by default, it must be written and explained.

This is why `audio` remains out:

- on the real starting system it is not required to make PipeWire work;
- today access to audio devices normally passes through dynamic ACLs.

## Because we use a versioned sudoers file

Because `sudo` is part of the operational architecture.

If you leave it implicit, one day you will no longer remember:

- if the behavior was stock;
- if you have modified it;
- where you changed it.

With a versioned file, the rule is clear and traceable.

## Because the password hash is optional

Because a reproducible installer shouldn't push you to write passwords in
clear within commands or documents.

The hash is a reasonable technical compromise:

- automation when needed;
- no plaintext password in the repo.

## The mental rule to remember

A good administrative user is not born from privileges thrown away at random.

It arises from an intentional, explained and fit-for-purpose baseline
machine.