# Post-Install Layer Realignment

`Margine` does not force all package decisions to happen only during the first
installation.

One of the project strengths is that the system remains **manifest-driven even
after first boot**.

That means you can:

- realign an installed machine with the repository state;
- add missing package layers later;
- re-apply desktop and application payloads after syncing the repo;
- recover from drift without reinstalling the whole system.

## 1. Core idea

The canonical tool is:

```bash
sudo /root/margine-os/scripts/install-from-manifests --product NAME --flavor NAME --layer LAYER
```

This works on an already-installed system too.

It is not limited to the live ISO bootstrap flow.

## 2. Typical use cases

Use this when:

- a VM was installed before new layers or packages were added to the repo;
- a machine is missing application packages introduced later;
- you want to install only specific blocks instead of re-running the full installer;
- you want to re-converge the machine toward the versioned manifests.

## 3. Example: realign an installed private CachyOS VM

```bash
sudo /root/margine-os/scripts/install-from-manifests \
  --product margine-cachyos \
  --flavor cachyos \
  --layer base-system \
  --layer apps-core \
  --layer apps-photo-audio-video \
  --layer fonts
```

This is useful when the VM was installed before newer commits added or changed:

- `chromium`
- `loupe`
- `gnome-text-editor`
- `cachyos-settings`
- updated font baseline

## 4. Re-apply versioned user payloads

Package layers and user configuration payloads are separate on purpose.

After changing package layers or syncing a newer repo snapshot, you may also
need to re-apply the user payloads:

```bash
sudo /root/margine-os/scripts/provision-hyprland-desktop --username daniel
sudo /root/margine-os/scripts/provision-user-app-config --username daniel
```

This re-installs:

- Hyprland / Waybar / Walker / SwayNC payload files
- application configuration payloads
- Firefox policy baseline
- wallpaper and desktop helpers

## 5. Discover available layers

To inspect the installable package blocks:

```bash
/root/margine-os/scripts/install-from-manifests --product margine-cachyos --flavor cachyos --list-layers
```

This is the intended operator interface for selective expansion.

## 6. Recommended safe workflow

On an already-installed system:

1. sync the repository into the machine
2. install the missing official layers with `install-from-manifests`
3. re-apply desktop and application payloads if needed
4. reload the session or reboot
5. run the post-install validation checklist

## 7. Scope limits

This mechanism is excellent for:

- package layers
- desktop payloads
- application payloads
- convergence after repository changes

It is not the right tool for:

- destructive storage changes;
- bootloader migration across incompatible layouts;
- firmware-side Secure Boot operations.

Those remain separate operational steps.
