# Because the audio preset must be resolved at runtime

## The important point

An audio preset doesn't live in a vacuum.

To work well it must know:

- what hardware it is running on;
- which output it should hook to;
- which accessory files are really needed.

## The classic mistake

The typical error is this:

- copy the preset to home;
- hope that the device name is identical everywhere;
- apply it globally to everything.

This shortcut seems convenient, but it's fragile.

## Choosing Margin

`Margine` divides the problem in two:

1. release everything that is stable:
   - presets;
   - IR of the convolver;
   - user service;
2. solves at runtime everything that depends on the real machine:
   - vendor and model;
   - internal audio sink;
   - speaker route.

## Because it is educationally better

Because it teaches you a useful rule in many contexts:

- static files go to Git;
- dynamic facts must be detected when they really exist.

This applies to audio, but also to network, disks, monitors and boot entries.

## The mental rule to remember

Don't hardcode into installation what the system can best discover
right time.