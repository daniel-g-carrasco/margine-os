# Why a guided wrapper is different from a magic installer

## The important point

An installer wizard doesn't have to hide your system.

It needs to make it more readable.

## The trap to avoid

The classic trap is this:

- a convenient interface;
- lots of implicit logic;
- little real comprehensibility.

At the first anomaly, the user no longer knows where to turn.

## Choosing Margin

The `Margine` wrapper wizard does a more honest thing:

- asks you for the parameters in order;
- shows you a summary;
- then call the actual project scripts.

So the "wizard" does not replace the architecture.

He crosses it.

## Because it is educationally better

Because tomorrow you will be able to:

- use the wizard;
- or skip it and call the scripts below directly.

This is the sign of good design:

- convenience for today;
- understandability for tomorrow.

## The mental rule to remember

If a guided wrapper prevents you from understanding what's happening, it's too opaque.

If it accompanies you without hiding the pieces, it's done well.