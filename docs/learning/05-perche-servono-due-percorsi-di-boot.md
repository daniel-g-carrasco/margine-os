# Because you need two boot paths

This note explains a choice that may seem strange at first glance:

- why not just use one boot path for everything?

The short answer is:

- because daily boot and recovery have different goals.

## 1. Normal boot wants stability

In everyday booting we are especially interested in this:

- that it always works;
- that it is repeatable;
- that `TPM2` is not fragile;
- that updates break as little as possible.

For this reason the `prod` path uses a `UKI` with embedded command line.

The lesson here is simple:

- fewer variable parameters in normal boot means less fragility.

## 2. Recovery requires flexibility

Recovery, however, wants something different:

- being able to choose what to boot;
- being able to point to a specific snapshot;
- being able to go into maintenance without having to rebuild half the chain.

This is why the `recovery` path uses a separate, more flexible, `UKI` to which
`Limine` passes the command line.

The lesson is:

- recovery does not have to be optimized for daily comfort;
- it needs to be optimized to give you back control.

## 3. The technical conflict to be understood well

With `systemd-stub`, if the `UKI` contains a `.cmdline` and `Secure Boot` is
active, command line overrides are ignored.

This is great for normal booting.
But for snapshots it's inconvenient, because every snapshot might want to boot with:

- `rootflags=subvol=...`

different.

So it's not a taste issue.
It is really a conflict between two needs:

- normal boot stability;
- variability of recovery.

## 4. The mental error to avoid

The classic mistake is wanting to force a single solution for everything.

This often leads to one of two results:

- or the normal boot becomes more fragile than it should;
- or recovery becomes too rigid to be truly useful.

The `Margine` project avoids this error like this:

- two different routes;
- a single coherent architecture.

## 5. Why does the TPM stay on the prod path

`TPM2` is very convenient when the boot path is stable.

In fact, in the `prod` path the sensible initial PCRs are:

- `7`
- `11`

This works well because the `UKI` is stable and the content is defined.

In the `recovery` path, however, the command line can change.
So expecting the exact same comfort `TPM2` there too would be more
fragile than useful.

The important lesson is:

- not all conveniences have to apply to all routes.

## 6. Because this design is more mature

It is more mature because it distinguishes:

- route optimized for frequency of use;
- optimized path for error recovery.

This is a very general rule of architecture:

- the normal path and the emergency path do not necessarily have to be identical;
- they must both be clear.

## 7. The final rule to remember

If one day you ask yourself:

- "why don't we simplify everything to a single boot path?"

the right answer is:

- because simplifying badly means confusing two different problems.

A good design doesn't try to have "fewer pieces" in the abstract.
Try to have:

- distinct pieces;
- clear responsibilities;
- human recovery when it's really needed.
