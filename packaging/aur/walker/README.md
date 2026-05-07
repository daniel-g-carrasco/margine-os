# Walker local AUR override

Margine carries a local Walker patch because upstream Walker uses a GTK
`GtkGridView` inside a `GtkScrolledWindow`. On some Wayland/touchpad stacks this
can keep smooth scroll motion active while Walker also calls `scroll_to()` on
selection changes, producing visible duplicated or jumping rows.

The local patch intercepts result-list scroll events and turns them into
discrete selection changes. This makes Walker behave closer to keyboard-first
launchers such as rofi: the wheel/touchpad changes the selected row instead of
physically scrolling the GTK container.

Runtime tuning:
- `MARGINE_WALKER_SCROLL_STEP` controls how much wheel/touchpad delta must be
  accumulated before the selected result moves by one row.
- The patched Walker build defaults to `12.0`.
- Margine exports this from `MARGINE_THEME_WALKER_SCROLL_STEP` in
  `~/.config/margine/theme.env` through the launcher wrapper.

Files:
- `0001-discrete-result-list-scroll.patch`: source patch applied to Walker.

`scripts/install-aur-packages` wires this source patch into the current AUR
`PKGBUILD` at build time. Do not carry a static `PKGBUILD.aur.patch` here:
upstream AUR checksums and line numbers move, so a static PKGBUILD diff is too
fragile for unattended installs.

`scripts/update-all` rebuilds local AUR overrides after helper updates so the
patched package is not silently replaced by the upstream build.

For live installs, prefer prebuilding Walker on the host:

```bash
sudo ./scripts/build-local-package-repo --product margine-public --flavor arch
```

The generated `local-pacman-repo/` directory is intentionally ignored by Git but
is copied by the installer source sync. During bootstrap,
`scripts/install-from-manifests` installs matching prebuilt package files from
that local repo before falling back to AUR builds. This keeps the live ISO from
compiling Walker or upgrading its temporary package set.
