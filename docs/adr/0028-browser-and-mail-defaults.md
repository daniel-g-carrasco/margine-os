# ADR 0028 - Browser e mail defaults

## State

Accepted

## Context

`Margine` has already decided on the basic application layer, but it remained to be closed
the block explicitly:

- browser di default;
- mail client di default;
- desktop IDs e MIME reali;
- relationship between the official `Thunderbird` and any `ESR`.

This part must be fixed well, because a system can also have packages
right but remain inconsistent in practice if:

- `mailto:` links open in the browser;
- the referenced desktop file does not really exist;
- the project leaves the choice between `Thunderbird` and `Thunderbird ESR` ambiguous.

## Decision

For `Margine v1` the application defaults are:

- `Firefox` as main browser;
- `Thunderbird` official Arch as main email client.

Defaults are expressed via `mimeapps.list`, not via tools
interactive or runtime state of the source machine.

## Specific choices

### 1. Browser baseline

`Firefox` remains the project's baseline browser.

Reason:

- it is in the official repositories;
- it is already treated with a moderate baseline via system policy;
- It is consistent with the goal of having a system that is reproducible without dragging
personal profiles.

### 2. Mail baseline

`Thunderbird` enters as a baseline mail client in the form of the official package
Arch.

Reason:

- it is in the official repositories;
- has clear desktop file and MIME integration;
- the user profile contains mail, accounts, keys, indexes and cache, so no
should be confused with the system baseline.

### 3. Thunderbird ESR

`Thunderbird ESR` DOES NOT enter the `v1` baseline.

Reason:

- as of 2026-03-30 it is not listed as a package in the official Arch repositories;
- the project favors official repos and minimizes AUR exceptions.

This doesn't mean that `ESR` is banned forever.
It just means that it doesn't become the architectural default of `v1`.

If in the future the compatibility with extensions or plugins will really make it
necessary, it will be treated as an explicit and motivated exception.

### 4. MIME e desktop IDs

The baseline uses the real desktop IDs of the packages:

- `firefox.desktop`
- `org.mozilla.Thunderbird.desktop`

For `Thunderbird`, the main MIMEs and handlers that we close in `v1` are:

- `x-scheme-handler/mailto`
- `x-scheme-handler/mid`
- `x-scheme-handler/webcal`
- `x-scheme-handler/webcals`
- `message/rfc822`
- `text/calendar`
- `text/vcard`
- `text/x-vcard`

### 5. Profilo Thunderbird

The `~/.thunderbird` profile is NOT migrated to `v1`.

Reason:

- contains personal data, not system baselines;
- it is material for backup or conscious migration;
- copying it automatically would go against the selective migration model.

### 6. Policy Thunderbird

`Margine v1` does not add a separate `Thunderbird` policy.

Reason:

- the baseline of the Arch package is already reasonable;
- the points that really interest us at this stage are the correct package,
MIME/default and blind profile non-migration;
- introducing one more policy without a clear need would only add
complexity at the application layer.

## Consequences

### Positive

- web and email links end up in the right applications;
- the project stops having ambiguities between `Thunderbird` and `ESR`;
- the baseline remains consistent with the official Arch.

### Negative

- those who want `Thunderbird ESR` will have to introduce it later as a deviation
  explicit;
- the personal email profile remains outside the basic installation.

## For a student

Here the rule is simple:

- It's one thing to choose a package;
- it's another to actually make it the desktop default;
- yet another is not to confuse the app with the personal data it contains.

For this reason `Margine` closes the block like this:

- `Firefox` browser;
- `Thunderbird` mailer;
- `mimeapps.list` as a source of truth;
- no blind migration of the email profile.
