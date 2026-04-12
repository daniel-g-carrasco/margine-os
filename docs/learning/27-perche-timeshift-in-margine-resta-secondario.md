# Why Timeshift in Margin remains secondary

It might seem strange:

- we install `Timeshift`;
- but we don't make it the main driver.

The reason is simple: serious projects must distinguish between:

- tool available;
- architecturally central instrument.

## Who really commands rollback

In `Margine` the serious rollback goes through:

- `Snapper`
- `Btrfs`
- `Limine`
- `UKI`

This is the path we are designing and validating.

## Why not force Timeshift

The official documentation of `Timeshift` is clear:

- Btrfs mode only supports Ubuntu-style layouts with `@` and `@home`.

We have chosen a richer layout.

So forcing `Timeshift` as if nothing had happened would mean:

- ignore a declared limit;
- create wrong expectations;
- risk a less understandable system.

## So why keep it?

Because it can still be useful:

- as a manual tool;
- as a family utility;
- as an optional extra, not as the heart of the system.

## The lesson

A good project does not use all tools at the same level.
It puts them in hierarchy.

In `Margine`:

- `Snapper` is the rollback engine;
- `Timeshift` is a prudent accessory.

