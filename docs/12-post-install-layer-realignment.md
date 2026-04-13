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

## 4.1 Preferred VM repo-sync workflow

For an already-installed QEMU validation VM, this is the preferred operator
loop during development.

From the host:

```bash
rsync -a --delete --exclude build/ -e "ssh -p 2222" \
  /home/daniel/dev/margine-os-personal/ \
  daniel@127.0.0.1:/tmp/margine-os/

ssh -p 2222 daniel@127.0.0.1
```

Inside the VM:

```bash
sudo rsync -a --delete /tmp/margine-os/ /root/margine-os/
```

Then run the provisioner that matches the kind of change you made.

Use:

- `sudo /root/margine-os/scripts/install-from-manifests ...` when package
  manifests or layers changed
- `sudo /root/margine-os/scripts/provision-user-runtime-tools --username daniel`
  when runtime helpers, user services, or scripts in `~/.local/bin` changed
- `sudo /root/margine-os/scripts/provision-user-app-config --username daniel`
  when application configuration changed
- `sudo /root/margine-os/scripts/provision-hyprland-desktop --username daniel`
  when Hyprland, Waybar, SwayNC, Walker, wallpaper, or lock-screen payloads
  changed

This distinction matters.

For example:

- a `hyprlock` wrapper change is **not** just application config
- a Waybar or SwayNC CSS change is **not** just application config
- a new package in a manifest is **not** solved by re-running desktop payloads

So `provision-user-app-config` alone is correct only for the app-config slice.
It is not the generic answer for every repo sync.

## 4.2 Session refresh after repo sync

After re-applying the payloads, reload only what actually changed.

Typical commands:

```bash
systemctl --user daemon-reload
hyprctl reload
~/.config/waybar/launch.sh
~/.config/swaync/launch.sh
```

Examples:

- after `provision-user-runtime-tools`: run `systemctl --user daemon-reload`
- after `provision-hyprland-desktop`: run `hyprctl reload`
- after Waybar changes: relaunch Waybar
- after SwayNC changes: relaunch SwayNC
- after launcher `.desktop` changes: run `provision-user-app-config`
- after launcher helper-script changes: run `provision-hyprland-desktop`

For the dynamic lock-screen rollout specifically, the usual VM loop is:

```bash
sudo rsync -a --delete /tmp/margine-os/ /root/margine-os/
sudo /root/margine-os/scripts/provision-user-runtime-tools --username daniel
sudo /root/margine-os/scripts/provision-hyprland-desktop --username daniel
systemctl --user daemon-reload
hyprctl reload
```

For launcher ownership and design rules specifically, see:

- [`14-desktop-launchers.md`](14-desktop-launchers.md)

## 5. Discover available layers

To inspect the installable package blocks:

```bash
/root/margine-os/scripts/install-from-manifests --product margine-cachyos --flavor cachyos --list-layers
```

This is the intended operator interface for selective expansion.
It now shows both the default layers and any additional optional official
layers exposed by the current repository/product.

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
