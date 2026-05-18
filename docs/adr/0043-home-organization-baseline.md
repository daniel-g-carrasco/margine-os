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

It does not move existing personal data. Empty legacy XDG directories such as
`~/Documents`, `~/Downloads`, `~/Pictures` or their Italian localized names may
be removed after the new XDG mapping has been written. Non-empty legacy
directories are preserved for an explicit user-reviewed migration.

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

The GTK/Nautilus bookmark set is intentionally compact and mirrors the host
baseline:

```text
~/data/personal              Documents
~/data/inbox/10-downloads    Downloads
~/data/media/photos          Pictures
~/data/media/audio           Music
~/data/media/video           Videos
~/data/shared                Shared
~/data/projects              Projects
~/dev                        Development
~/scratch                    Scratch
```

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

Screenshot tooling writes to `~/data/media/captures/screenshots` by default.
Screen recordings write to `~/data/media/captures/screen-recordings` by
default.

LibreOffice, VLC, and recent-file stores can retain historical paths. Those
records are application history, not storage policy.

## Folder icons

Margine OS uses GIO metadata for folder icons and only points to icons already
present in installed icon themes.

The home-organization icon policy is intentionally stricter than normal icon
lookup. It prefers `Adwaita-yellow` scalable SVG folder icons before consulting
the active icon theme. If a semantic folder icon is not present in
`Adwaita-yellow`, the resolver falls back to the generic yellow `folder.svg`
before trying any blue-prone fallback theme.

The remaining fallback themes are only a last resort for systems that do not
ship `Adwaita-yellow`:

```text
MoreWaita
Adwaita
AdwaitaLegacy
hicolor
```

The resolver must not pin raster folder icons such as 16x16 PNG assets into GIO
metadata. This keeps Nautilus from upscaling low-resolution blue folders in icon
view. The policy still avoids custom SVG assets and keeps the template rule that
`folder-earth` represents `~/data`, `folder-globe` represents community, and
blue-prone icons such as `folder-cloud`, `folder-docker`, and `folder-recent`
are not first choices.

The top-level semantic mappings intentionally mirror the validated host
reference: `~/data/library` uses `folder-books`, `~/data/work` uses
`folder-work`, `~/data/media` uses `folder-camera`, and
`~/data/library/software` uses `folder-appimage`. Validation checks these exact
rules so the baseline cannot silently fall back to generic document or remote
folder icons.

Provisioning tries to set GIO metadata during install. Because GIO metadata is
per-user session state, `margine-apply-desktop-defaults` also refreshes folder
icons from the graphical session at login.

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
- empty legacy XDG folders disappear, but non-empty legacy folders remain for
  manual review;
- GIO folder icon metadata may need to be rerun from an active graphical session.
