# Why TPM2 auto-unlock and autologin to `hyprlock` can be a good laptop architecture

## The short answer

Yes, it can be a good architecture.

But only if it is described honestly.

This is **not**:

`TPM2 unlock + normal graphical login`

It is:

`measured boot releases the disk automatically -> the user session starts -> the human authentication boundary is hyprlock`

That distinction matters.

## What each layer is actually doing

When people describe this kind of machine, they often mix together several
different security properties.

They should be separated.

- `Secure Boot` protects the firmware-to-bootloader-to-kernel trust path.
- `UKI` gives a tighter and more measurable boot artifact.
- `LUKS2` protects data at rest.
- `TPM2` can release the `LUKS` secret if the machine boots in an expected state.
- `autologin` skips pre-session human authentication.
- `hyprlock` becomes the first human-facing authentication boundary.

So the real model is:

- machine integrity is checked first;
- disk unlock is granted automatically if integrity looks correct;
- user presence is checked only at the lock screen.

## Why this can be a strong design

For a personal laptop, this model has real advantages.

### 1. It removes redundant friction

If the machine is single-user, encrypted, and used many times a day, repeatedly
typing:

1. a boot passphrase;
2. then a desktop password;

is often just duplicated friction.

`TPM2` lets the machine handle integrity-based disk unlock.
`hyprlock` keeps the human interaction at the point where the user actually
enters the graphical environment.

### 2. It creates a cleaner UX

The path:

`boot -> greetd -> autologin -> Hyprland -> hyprlock`

feels more coherent than:

`boot -> decrypt -> greetd/GDM -> login -> Hyprland -> lock`

This matters more on a daily personal machine than on a shared workstation.

### 3. It aligns the boundary with actual usage

On a personal laptop, the most common question is not:

> "Should the machine be allowed to boot at all?"

It is:

> "Should the person in front of the already booted machine be allowed into my session?"

That makes a session lock a valid primary human-auth boundary, provided it is
implemented reliably.

### 4. It keeps recovery separate

If the architecture also keeps:

- a recovery key or passphrase;
- a fallback greeter path such as `tuigreet`;
- a documented recovery boot path;

then convenience on the normal path does not mean loss of recoverability.

## What you are explicitly giving up

This architecture is not free.

It changes the trust boundary in a very concrete way.

### 1. Human authentication no longer happens before session creation

With `tuigreet-only`, the user is authenticated before the session starts.

With `autologin -> hyprlock`, the session exists first and is then locked.

That means:

- user processes may start earlier;
- user services may already exist;
- the security boundary moves from the greeter to the lock screen.

This is acceptable only if that shift is intentional.

### 2. The lock screen becomes a critical security component

If `hyprlock` fails to start, starts too late, or can be bypassed in practice,
the whole model weakens immediately.

In this architecture, the lock screen is not cosmetic.
It is part of the security design.

### 3. This is not a good universal default for all machines

It is a good fit for:

- a personal laptop;
- one primary user;
- full-disk encryption;
- a machine that stays mostly in the owner's custody.

It is a worse fit for:

- shared systems;
- multi-user workstations;
- stricter corporate or regulated environments;
- systems where pre-session authentication must be mandatory by policy.

## The most important technical caveat: TPM2 can be excellent or fragile

The best part of the model is also the part that can go wrong fastest.

`TPM2 auto-unlock` is only a good design if the sealing policy is sustainable.

A naive approach:

- seal directly to current PCR values;
- bind too aggressively to changing measurements;
- forget that kernel and UKI updates change those measurements;

turns the architecture into a trap.

Then every update becomes:

- "why did auto-unlock stop working?"
- "why am I suddenly back to recovery?"
- "why do I need to reenroll again?"

So the rule is simple:

`TPM2 auto-unlock` is good only if update behavior is part of the design.

In practice this means:

- `Secure Boot` must be stable first;
- PCR choices must be deliberate, not copied blindly;
- the recovery secret must remain available;
- the update pipeline must explain what happens after boot-chain changes.

If this is not true, the architecture is elegant on paper and brittle in real
life.

## Threat model where this architecture makes sense

This design is coherent when the assumptions are these:

- the disk must stay unreadable at rest if removed from the machine;
- the normal boot path should be fast and mostly hands-off;
- the machine itself is trusted when it measures into an expected boot state;
- the real human-auth point is the graphical lock screen;
- the owner values both security and low daily friction.

Under that model, the chain is reasonable:

1. firmware and measured boot validate platform state;
2. `TPM2` releases disk unlock only for the expected path;
3. the system boots into the normal user environment;
4. `hyprlock` asks for the human factor.

That is a coherent laptop story.

## Threat model where this architecture is not enough

This model is weaker if you care about any of these conditions:

- the machine may be booted by other people before you see it again;
- you require user authentication before *any* user session exists;
- you are protecting against more hostile physical-access scenarios;
- you want stronger guarantees against pre-session service startup;
- you need a more traditional or auditable access boundary.

In those cases, a stricter model is better:

`TPM2 auto-unlock -> greetd/tuigreet authentication -> session start`

That keeps the disk convenience benefit, but moves the human-auth boundary back
before session creation.

## What this means for fingerprints

Fingerprint authentication does not change the architecture by itself.

It only changes *how* the human factor is collected.

If the machine does:

`TPM2 auto-unlock -> autologin -> hyprlock with fingerprint`

then the fingerprint is part of the lock-screen boundary.

If the machine does:

`TPM2 auto-unlock -> tuigreet with fingerprint -> session`

then the fingerprint is part of the greeter boundary.

Those are not equivalent.

The important question is not "password or fingerprint?"

It is:

> "At which point does human authentication happen?"

## Recommended position for Margine

For `Margine Personal`, this is a reasonable target architecture:

- `Secure Boot` active;
- `LUKS2` root;
- `TPM2` for normal-path auto-unlock;
- `greetd` as minimal session entry point;
- `autologin -> hyprlock` as the default daily path;
- `tuigreet` kept as an explicit fallback path;
- password or recovery secret always preserved.

Why this recommendation is defensible:

- it matches the single-user laptop goal;
- it gives a coherent graphical flow;
- it keeps a recovery path;
- it does not pretend that `TPM2` is the same thing as human authentication.

For a redistributable general-purpose flavor, however, this should be treated as
either:

- a clearly documented laptop-first default;
- or an opt-in security/UX profile.

It should not be presented as the only universally correct login model.

## The operational requirements

If `Margine` adopts this architecture seriously, these requirements follow.

### Boot side

- `Secure Boot` must be validated before `TPM2` enrollment.
- The measured boot path must be documented.
- Recovery secrets must exist before enabling `TPM2` auto-unlock.

### Session side

- `hyprlock` must start immediately and reliably.
- Password fallback must remain valid even when fingerprint is enabled.
- Suspend/resume must not break the fingerprint daemon path silently.

### Maintenance side

- update procedures must account for boot-chain changes;
- documentation must say when reenrollment or reprovisioning is required;
- validation must cover both the normal path and the recovery path.

## The real lesson

This architecture is good if you describe it with the right sentence.

Not:

> "The TPM logs me in automatically."

Not:

> "Hyprlock is just a nicer greeter."

But:

> "The machine proves enough integrity to unlock the disk automatically, then the user proves identity at the session lock boundary."

That sentence is technically honest.

And for a personal, encrypted, single-user laptop, it is also a good design.

## How to change the architecture later

There are three clean directions for future changes.

### Stricter

Keep `TPM2` auto-unlock, but remove autologin and authenticate in `tuigreet`.

### More convenient

Keep autologin and `hyprlock`, but improve reliability of fingerprint and
resume handling.

### More defensive

Keep both paths:

- default `autologin -> hyprlock` for the owner;
- explicit `tuigreet-only` mode for debugging, travel, or stricter contexts.

That is often the most pragmatic long-term model.
