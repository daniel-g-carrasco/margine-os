# Why color management should be treated as a multi-stack asset

In color management there are two very different things.

## 1. Lo stack

The stack is the set of tools:

- `darktable`
- `argyllcms`
- `displaycal`
- `colord`

These are packages, services and tools.

## 2. The assets

Assets are the results of your work:

- ICC profiles;
- photographic styles;
- any successful presets.

These are not "system configuration" in the pure sense.
They are precious objects produced by the user.

## Why this distinction matters

If you mix them, this happens:

- copy logs and databases as if they were important;
- you no longer know which profiles were the right ones;
- the repo stops explaining anything.

Se li separi, ottieni:

- clear and reproducible stack;
- selected and preserved assets;
- less noise.

## Esempio concreto

In your case:

- `Darktable` and `ArgyllCMS` are part of the stack;
- the `FW13_140cd_D65_2.2_S.icc` profile is an asset;
- `DisplayCAL` logs are not an asset and are not stacks: they are historical noise.

## The rule of thumb

When in doubt:

- the packages are reinstalled;
- good ICC profiles are preserved;
- the logs are thrown away.

