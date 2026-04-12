# ADR 0017 - Administrative user and session baseline

## State

Accepted

## Why this ADR exists

Up to this point the `Margine` bootstrap went as far as:

- storage ready;
- basic system installed;
- main services enabled.

However, one fundamental thing was missing:

- a really usable administrative user.

## Problem to solve

A system is not truly ready if it stops at:

- `root`;
- installed packages;
- hostname and locale configured.

Also needed:

- an administrative user;
- `sudo` configured well;
- groups chosen in a reasoned way;
- first consistent user directories.

## Decision

Per `Margine v1` introduciamo:

- the `sudo` package in the base;
- a versioned template for `/etc/sudoers.d/10-margine-wheel`;
- a dedicated script `scripts/provision-system-user`;
- integration of user provisioning into `bootstrap-in-chroot`.

## Administrative rule

The user created by this flow is a modern administrative user:

- belongs to `wheel`;
- use `sudo` with password;
- does not receive `NOPASSWD` by default.

## Rule groups

The baseline does not copy the current user's groups blindly.

In `Margine v1` the administrative baseline is:

- `wheel`
- `video`
- `render`
- `kvm`
- `libvirt`
- `colord`

Plus any explicit groups passed via topic.

Reason:

- `wheel` is used for administration via `sudo`;
- `video` and `render` cover the workstation baseline for GPU and stack
  AMD/ROCm/OpenCL;
- `kvm` and `libvirt` prevent the first use of VMs and virtualization from falling on
unnecessary permission issues;
- `colord` is consistent with a camera profile also oriented towards photography and
color management.

`audio` does not enter by default:

- on the reference machine the audio subsystem already works via ACL
  moderne su `/dev/snd`;
- adding it without real need would broaden the baseline without a gain
concrete.

However, historical groups such as `network` or `storage` do not enter by default,
because they don't add a clear benefit here.

## Adjust password

The script optionally accepts a password hash.

If the hash is not provided:

- the user is created anyway;
- but a manual `passwd` is still required before normal login.

This choice avoids forcing the project to deal with plaintext passwords.

## Session rule

In this ADR we only close the minimum baseline:

- user;
- `sudo`;
- `xdg-user-dirs`;
- basic system services.

The final login path is instead closed by subsequent ADRs:

- `greetd`;
- `tuigreet` as fallback;
- initial main user autologin;
- `hyprlock` as immediate lockscreen upon session entry.

## Practical consequences

This choice gives us:

- a bootstrap that actually produces an administrable system;
- a cleaner and more modern baseline;
- less coupling between user provisioning and final login path;
- a consistent basis on which to hook session provisioning.

## For a student: the simple version

An installed system is not yet a ready system.

Get ready when you can:

- log in with your user;
- use `sudo`;
- have a coherent home;
- start from simple and understandable rules.
