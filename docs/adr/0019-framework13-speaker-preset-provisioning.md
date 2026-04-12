# ADR 0019 - Provisioning audio Framework 13 con EasyEffects

## State

Accepted

## Problem to solve

`Margine` wants to have a sensible audio baseline for `Framework Laptop 13`,
but without imposing bad behavior on different hardware.

With EasyEffects the classic risk is this:

- copy to preset;
- do not versione the convolver auxiliary files;
- force the preset globally on any output;
- break headphones, HDMI or incompatible machines.

## Decision

For `Margine v1` we adopt this strategy:

- the official preset `fw13-easy-effects` is versioned in the repository;
- the IR actually required by the preset is also versioned;
- provisioning occurs only if the machine is `Framework Laptop 13`
via DMI;
- the autoload is generated at runtime for the route of the internal speakers;
- on different hardware provisioning goes into no-op.

## Because resolution happens at runtime

The actual name of the PipeWire sink is not a design constant to write to
chroot.

Instead, you need to find out when the user audio session actually exists.

This is why we separate two times:

1. bootstrap in chroot:
   - copy presets;
   - IR copy;
   - install user service;
2. first start of the session:
   - detects the internal sink;
   - generate the correct autoload file;
   - start EasyEffects in service mode.

## What is versioned

- `files/home/.local/share/easyeffects/output/fw13-easy-effects.json`
- `files/home/.local/share/easyeffects/irs/IR_22ms_27dB_5t_15s_0c.irs`
- `files/home/.local/bin/margine-framework-audio-service`
- `files/home/.config/systemd/user/margine-framework-audio.service`

## Guardrail espliciti

- no application on non-`Framework` machines;
- no global presets on non-internal outputs;
- no dependency on legacy audio groups;
- no dependency on temporary paths of the source machine.

## Practical consequences

This choice gives us:

- really playable preset;
- good default behavior on target laptop;
- clean fallback to "no special behavior" on different hardware.