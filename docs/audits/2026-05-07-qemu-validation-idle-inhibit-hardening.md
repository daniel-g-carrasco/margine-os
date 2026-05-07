# QEMU Validation Idle Inhibit Hardening

Date: 2026-05-07

## Finding

The QEMU validation idle/suspend inhibitor existed, but it was wired as a
manual follow-up after SSH setup. That ordering was wrong: when the guest idled
or suspended first, QEMU host forwarding could still accept TCP while `sshd`
failed to complete the SSH banner or key exchange, so the host-side inhibitor
could no longer be started.

The previous collector also tested only whether TCP port `2222` accepted a
connection. That reported a false-positive "SSH is reachable" state when the
QEMU forwarder was open but the guest SSH daemon was not completing a real SSH
handshake.

## Fix

- `enable-qemu-validation-ssh` now starts the idle/suspend inhibitor immediately
  from a temporary copy under `/tmp`, before host-side log collection depends on
  SSH.
- `enable-qemu-validation-inhibit` re-execs itself from `/tmp` when it is
  invoked from a QEMU 9p mount, avoiding direct long-running execution from the
  shared repository mount.
- Root-on-ZFS QEMU bootstrap accepts `--qemu-validation-inhibit`, which installs
  and enables a validation-only first-boot systemd inhibitor in the target.
- Host-side SSH helpers now wait for a real SSH handshake, not just an open TCP
  port.

## Policy

The inhibitor is validation-only. It must not be enabled for real hardware
installs. Disable it after VM evidence collection with:

```bash
./scripts/enable-qemu-validation-inhibit-over-ssh --user USERNAME --disable --prompt-sudo
```
