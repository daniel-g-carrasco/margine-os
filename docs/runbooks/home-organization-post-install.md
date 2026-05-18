# Home organization post-install

Margine OS provisions the home layout through:

```bash
sudo /usr/local/lib/margine/scripts/provision-home-organization --username "$USER"
```

From a repository checkout, use:

```bash
sudo ./scripts/provision-home-organization --username "$USER"
```

The provisioner creates:

- `~/data`
- `~/dev`
- `~/scratch`
- XDG user dirs under `~/.config/user-dirs.dirs`
- GTK 3 and GTK 4 bookmarks
- GIO folder icon metadata
- managed `00-readme.md` notes for key folders
- `~/.config/margine/home-organization/backup-exclude.example`

It does not move existing files from `~/Downloads`, `~/Documents`,
`~/Pictures`, Italian legacy folders, or any other personal path.

After writing the XDG mapping, the helper may remove empty legacy XDG folders
left behind by `xdg-user-dirs-update`, including localized names such as
`~/Documenti`, `~/Scaricati`, `~/Immagini`, and `~/Scrivania`. Non-empty legacy
folders are left in place for manual migration.

The expected GTK/Nautilus bookmarks are intentionally compact:

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

## Validation

Repository validation:

```bash
./scripts/validate-home-organization-baseline
```

Host audit:

```bash
~/.local/bin/margine-home-audit-application-paths
```

The audit checks the active XDG file, GTK bookmarks, and common application
configuration locations for legacy path references. Findings in
`recently-used.xbel`, LibreOffice history, VLC history, or similar files can be
only historical state.

## Application paths

Existing Firefox, Floorp, Librewolf, Waterfox, and Thunderbird profiles can be
updated with:

```bash
~/.local/bin/margine-home-configure-app-paths --apply
```

This writes a managed block to profile `user.js` files so browser downloads and
Thunderbird attachment saves use:

```text
~/data/inbox/10-downloads
```

Chromium-based browsers are left to settings or deployment policy.

Download clients should use:

```text
complete:   ~/data/inbox/10-downloads
incomplete: ~/scratch/downloads
```

darktable should use:

```text
library root: ~/data/media/photos
local RAW:    ~/data/media/photos/raw
```

Do not edit darktable SQLite databases while darktable is running. Back them up
before manual database changes.

Desktop capture tooling uses dedicated media capture paths:

```text
screenshots:       ~/data/media/captures/screenshots
screen recordings: ~/data/media/captures/screen-recordings
```

## Folder icons

Folder icons are set with:

```bash
~/.local/bin/margine-home-configure-folder-icons --apply
```

The script resolves `folder-*` icon names from installed themes and writes GIO
`metadata::custom-icon` values. It does not generate icons.

For Margine's managed home layout, the resolver prefers `Adwaita-yellow`
scalable SVG folder icons. If a semantic icon is missing there, it falls back to
the generic yellow folder before trying blue-prone fallback themes. It must not
write 16x16 PNG folder icons into metadata, because Nautilus will upscale them
poorly in icon view.

The baseline keeps the host-reference semantic icons for the visible roots:
`~/data/library` is `folder-books`, `~/data/work` is `folder-work`,
`~/data/media` is `folder-camera`, and `~/data/library/software` is
`folder-appimage`.

If provisioning ran in a chroot or non-graphical environment and GIO metadata
was not available, rerun the command from the user's graphical session.
`margine-apply-desktop-defaults` also refreshes this metadata at graphical
login so first-boot sessions recover from chroot-only provisioning.

## Manual migration

Move existing personal data only after review. A safe migration normally means:

- compare old and new paths;
- copy first, verify, then remove old files later;
- keep `~/scratch` outside normal backups;
- decide whether `~/data/media/photos/raw` belongs in the main backup job or in
  a dedicated photo backup plan.
