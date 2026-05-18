# ADR 0043 - Home organization baseline

## State

Accepted

## Context

Margine OS needs a reproducible user home model that stays useful after the
installation, survives reinstalls, and does not turn application defaults into
the storage architecture.

The public `home-organization-template` repository is the source of truth for
the model adopted here.

## Decision

Margine OS adopts three first-level user roots:

- `~/data`: durable files that are meaningful to a person;
- `~/dev`: source repositories and development sandboxes;
- `~/scratch`: temporary, cache-like, exchange, and disposable work.

Provisioning creates the directory structure, XDG user dirs, GTK/Nautilus
bookmarks, folder icon metadata, folder notes, application path hints, and a
backup exclusion example.

It does not move existing personal data.

## XDG mapping

The default user dirs are:

```text
Downloads -> ~/data/inbox/10-downloads
Documents -> ~/data/personal
Pictures  -> ~/data/media/photos
Music     -> ~/data/media/audio
Videos    -> ~/data/media/video
Templates -> ~/data/templates
Public    -> ~/data/shared
Projects  -> ~/data/projects
```

The desktop is intentionally mapped to `$HOME/` rather than becoming another
storage location.

## Application integration

Margine OS provides `margine-home-configure-app-paths`.

The script updates existing Gecko browser profiles and Thunderbird profiles with
a managed `user.js` block pointing downloads and attachment saves to
`~/data/inbox/10-downloads`.

The script intentionally does not:

- create new browser profiles;
- rewrite Chromium state databases;
- edit darktable SQLite databases;
- move old files from legacy paths.

For Chromium-based browsers, the baseline is documentation or explicit policy
when a deployment needs it.

For darktable, local photo work should use `~/data/media/photos` and RAW files
should use `~/data/media/photos/raw` when they are meant to be durable. Database
changes require darktable to be closed and the database to be backed up first.

Screenshot tooling writes to `~/data/media/photos/screenshots` by default.
Screen recordings write to `~/data/media/video/screen-recordings` by default.

LibreOffice, VLC, and recent-file stores can retain historical paths. Those
records are application history, not storage policy.

## Folder icons

Margine OS uses GIO metadata for folder icons and only points to icons already
present in installed icon themes.

Resolution order starts with the active icon theme and its inherited themes,
then falls back through:

```text
Adwaita-yellow
MoreWaita
Adwaita
AdwaitaLegacy
hicolor
```

This keeps the system portable and avoids custom SVG assets. It also keeps the
template rule that `folder-earth` represents `~/data`, `folder-globe` represents
community, and blue-prone icons such as `folder-cloud`, `folder-docker`, and
`folder-recent` are not first choices.

## Backup policy

The example policy excludes:

- `~/scratch`;
- common caches and rebuildable package state;
- temporary mobile and download staging;
- raw temporary secrets under `data/technology/00-admin/security`;
- raw temporary secrets under `data/technology/00-admin/licenses/raw-secrets`.

`~/data/media/photos/raw` is documented as an optional exclusion only when RAW
files are covered by a dedicated backup plan.

## Consequences

Positive:

- new installations get a stable, script-friendly home structure;
- application defaults point to durable locations without migrating private data;
- Nautilus and GTK pickers expose the intended roots immediately;
- backup scope is easier to reason about.

Tradeoffs:

- existing personal files still require explicit migration;
- some application history will keep old paths until the user clears it;
- GIO folder icon metadata may need to be rerun from an active graphical session.
