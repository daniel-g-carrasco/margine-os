# Products

`Margine` now distinguishes between:

- `product`: the deliverable you are building or maintaining;
- `flavor`: the manifest overlay used to resolve package and Flatpak layers.

Why both exist:

- the public repository only ships redistributable products;
- a future private repository can add personal products without forking the
  entire operational model;
- the same scripts can stay product-aware while still resolving package layers
  through the simpler flavor overlay tree.

Current public product:

- `margine-public`

Current public flavor overlays:

- `arch`
- `cachyos`

The public repository intentionally ships only one real product manifest today.
Additional products can be added in a private sister repository without
changing the public operational scripts.

Recommended private repository pattern:

1. keep this repository as `upstream`;
2. create a private repo such as `margine-os-personal`;
3. add new product manifests there, for example `margine-cachyos.toml`;
4. keep generic improvements flowing back here.

Typical product fields:

- `id`
- `name`
- `visibility`
- `redistributable`
- `base_distribution`
- `flavor`
- `kernel_package`
- `kernel_headers_package`
- `kernel_image` (optional; defaults to `/boot/vmlinuz-${kernel_package}`)
- `mkinitcpio_preset_name` (optional; defaults to `${kernel_package}`)
- `bootloader`
- `description`
- `extra_package_layers` (optional)
- `extra_provisioners` (optional)

`extra_package_layers` lets a product append additional manifest layers to the
default installation path without hardcoding product names into generic
scripts.

`extra_provisioners` lets a product request a tail step during
`bootstrap-in-chroot` for product-specific behavior, while keeping the shared
baseline scripts generic.
