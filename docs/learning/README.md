# Teaching notes

This folder will be used to explain the subsystems "as to a student".

Planned topics:

- bootloader, UEFI and Secure Boot
- TPM2 and LUKS unlock
- Btrfs and subvolumes
- comparison between current layout and target layout
- validation of the boot chain
- separation between normal boot and recovery
- integration model with Arch rolling
- reading the Limine template
- operation of the Limine generator
- snapshot policy and recovery limits
- update-all orchestrator reasoning
- safe deployment on the ESP
- Limine config enrollment and EFI signing
- Secure Boot initial bootstrap
- snapshots and rollbacks
- pacman, hooks, and maintenance
- Hyprland and desktop components
- portal, polkit and user session
- AMD graphics stack
- audio on Framework 13
- selective migration of configurations
- versioned application configuration
- Bootable snapshots and rollback limits
- pre-update snapshots and granular snapshots
- color management and photography on Linux
- ICC on Hyprland: app-first versus compositor-first
- browser and mailer: package, default and personal data
- app-by-app review of personal profiles
- terminal tooling and administration as a dedicated layer
- difference between SSH package, service and firewall
- printing, scanning and network discovery
- runtime validation of the system
- virtualization and containers as a separate baseline
- Initial boot chain as a prerequisite for end-to-end testing
- installation validation in VM before real iron
- separation between `VRR`, refresh rate and power profile on the laptop
- import the Hyprland environment into the `systemd --user` manager
- TPM2 auto-unlock plus `autologin -> hyprlock` as a laptop trust model
- what CachyOS adds beyond kernel and repositories
- DaVinci Resolve on Linux: graphics, compute, and compatibility requirements
- gaming stack layering and the `split_lock_mitigate` tradeoff
- ZFS migration strategy: why data-layer adoption and root-on-ZFS must be split
- ZFS non-root dataset layout and local snapshot policy
- ZFS tooling choice on Arch for Margine
- full VM validation of `Margine CachyOS` with `ZFS` non-root and gaming stack

Rule:
- each note must explain the "what", the "why" and the "how to change it".
