# How to review personal profiles app-by-app

This is the procedure to follow every time you want to understand if the profile of
an application goes:

- versioned;
- excluded;
- or revised at a later time.

## Step 1: Find where the app actually saves data

Don't stop at `~/.config`.

Always check also:

- `~/.local/share`
- `~/.mozilla`
- `~/.thunderbird`
- dedicated hidden directories like `~/.koofr`

Because many applications keep the real profile out of `~/.config`.

## Step 2: Distinguish config from state

The right question is not:

- \"Do I need this app?\"

The right question is:

- \"Does this file explain a useful preference or does it just contain local state?\"

Local status signals:

- cache;
- log;
- sqlite database;
- lockfiles;
- window geometry;
- recent sessions;
- tokens;
- keys;
- machine-specific paths.

## Step 3: Choose one of three outcomes

For each app you must arrive at one of these three outcomes:

### A. Versiona

Use it when the content is:

- readable;
- portable;
- educational;
- useful on a new installation.

### B. Don't migrate

Use it when the content is:

- personal;
- secret;
- volatile;
- generated;
- too tied to the current machine.

### C. Review later

Usalo quando:

- the structure is promising;
- but today there is still no clean subset to extract.

## Step 4: If versioned, versioned only the right subset

An entire directory is almost never versioned.

Usually a subset is versioned, for example:

- styles;
- templates;
- presets;
- a single reasoned config file.

## Step 5: Update the three right places in the repo

When a decision is closed, always update:

1. the app inventory/review;
2. the `home-approved.txt` allowlist if something actually enters;
3. the relevant provisioner, if the file really needs to be installed.

## Step 6: Don't confuse backup and baseline

Something can be very important to you and still not get into it
`Margine`.

Esempio:

- the `Thunderbird` profile is precious;
- but it is not system baseline.

So:

- you make it part of your personal backup/migration strategy;
- not in the reproducible baseline of the system.

## Final rule

If a profile makes you say:

- \"I really need this stuff\"

you haven't decided anything yet.

You still need to figure out if:

- it's configuration;
- it is personal data;
- or it's noise.