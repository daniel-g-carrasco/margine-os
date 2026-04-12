# Teaching notes

This folder will be used to explain the subsystems "as to a student".

Planned topics:

- bootloader, UEFI e Secure Boot
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
- deploy sicuro sulla ESP
- Limine config enrollment and EFI signing
- Secure Boot initial bootstrap
- snapshots and rollbacks
- pacman, hook e manutenzione
- Hyprland and desktop components
- portal, polkit and user session
- AMD graphics stack
- audio su Framework 13
- selective migration of configurations
- versioned application configuration
- Bootable snapshots and rollback limits
- pre-update snapshots and granular snapshots
- color management e fotografia su Linux
- ICC su Hyprland: app-first contro compositor-first
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

Rule:
- each note must explain the "what", the "why" and the "how to change it".
