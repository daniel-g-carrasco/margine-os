# Why browsers and mailers should be closed with real defaults

On the Linux desktop it is not enough to install a browser and an email client.

You also need to tell the system:

- who opens web links;
- who opens the links `mailto:`;
- who opens calendars or email files.

## The typical problem

Many systems seem \"fine\", but then:

- `http` opens the right app;
- `mailto` opens the wrong one;
- the desktop file written in the config doesn't even really exist.

In that case the system is not obviously broken.
It's worse: it's inconsistent.

## Choosing Margin

`Margine v1` closes this point explicitly:

- `Firefox` is the browser;
- `Thunderbird` is the mailer;
- `mimeapps.list` is the place where we set the decision.

## Why it's not enough to say \"I use Thunderbird\"

Saying \"I use Thunderbird\" isn't enough.

You also need to use your real desktop ID.

On Arch today the package installs:

- `org.mozilla.Thunderbird.desktop`

not a hypothetical:

- `thunderbird.desktop`

If you get this detail wrong, the repo looks correct but the real system doesn't.

## Why don't we migrate the email profile

The `Thunderbird` profile contains:

- accounts;
- local emails;
- indexes;
- keys;
- cache;
- personal status.

This is not system baseline.
It is user assets.

So:

- the package is installed;
- the default is fixed;
- the profile is only migrated consciously, not automatically.