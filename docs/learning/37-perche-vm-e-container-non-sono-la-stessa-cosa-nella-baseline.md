# Because VMs and containers are not the same thing in the baseline

Very often it is said:

- "I need virtualization"

but within this sentence you are mixing two different worlds:

- virtual machines
- containers

## VM

Le VM usano un hypervisor.

In the case of `Margine`:

- `KVM`
- `QEMU`
- `libvirt`
- `virt-manager`

Here the focus is:

- complete guests
- virtual firmware
- virtual disks
- virtual network
- Virtual TPM if needed

## Container

Containers use the host's kernel.

In the case of `Margine`:

- `podman`

Here the focus is:

- isolated processes
- OCI images
- lighter flow
- less overhead than a full VM

## Why separate them

If you treat them as "the same thing", you make two mistakes:

1. You underestimate how much a desktop VM really needs
2. You unnecessarily complicate the container path

For this reason `Margine` keeps a single area baseline, but with clear roles:

- `libvirt/qemu` per le VM
- `podman` for containers

## For a student

The simple rule is this:

- if you want another complete OS, think in terms of VMs
- if you want an isolated environment that uses your kernel, think in terms of containers