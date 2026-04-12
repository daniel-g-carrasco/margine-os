# ADR 0032 - Virtualization and container baseline

## State

Accepted

## Context

`Margine` has already prepared storage, user groups and subvolumes for:

- VM `KVM/QEMU`;
- `libvirt`;
- workload container rootful e rootless.

But until now, a coherent package baseline and runtime was missing. This
it left a gap between storage architecture and actual usage.

## Decision

For `Margine v1` we adopt:

- `libvirt`
- `qemu-desktop`
- `virt-manager`
- `virt-viewer`
- `edk2-ovmf`
- `dnsmasq`
- `swtpm`
- `podman`

In more:

- we install a `libvirtd.conf.d` drop-in to use the `libvirt` group;
- we set `qemu:///system` as the default URI;
- we provide a helper to enable `libvirtd` correctly, initializing
first the secret key required by libvirt;
- the `default` network of `libvirt` is then autostarted by that
same helper when 

## Why this choice

The criterion is simple:

- for VMs you need an immediate and readable path;
- for containers you need a modern baseline, not Docker-first;
- the machine is a personal workstation, so `virt-manager` makes sense.

## What doesn't make it into v1

They don't enter yet:

- Docker as baseline;
- Kubernetes locali;
- multi-host orchestration;
- Advanced custom bridge network tuning.

## Consequences

### Positive

- the project becomes consistent with the subvolumes already foreseen;
- the machine is ready for desktop VMs and OCI containers without rework;
- the distinction between VM and container remains clear.

### Negative

- it is an extra layer in the baseline;
- `libvirtd` can no longer be treated as an "always on" service of the first
boot, because current releases of libvirt require an initial state
consistent for credentials.

## For a student

The lesson here is this:

- preparing storage for VMs is not enough;
- putting the user in the `libvirt` group is not enough;
- until packages, bootstrap helpers, and repeatable checks exist, you don't have a
baseline: you only have intentions.
