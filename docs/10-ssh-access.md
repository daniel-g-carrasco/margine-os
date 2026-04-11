# SSH Access

`Margine` installs the `openssh` package and an SSH baseline, but it does **not**
expose `sshd` automatically.

That is intentional:

- the package is present
- the config baseline is present
- the firewall baseline is present
- the server still stays off until the operator enables it

So the direct answer is:

- yes, in the current implementation you must enable SSH from inside the target
  system before connecting to it
- once enabled, you can connect from the host or from another machine normally

See also [adr/0030-remote-access-and-firewall-baseline.md](/home/daniel/dev/margine-os/docs/adr/0030-remote-access-and-firewall-baseline.md).

## 1. Enable SSH on Margine

Run this inside the installed `Margine` system:

```bash
sudo margine-enable-ssh-server
```

What this does:

- enables and starts `sshd.service`
- opens SSH in the firewall with `ufw limit 22/tcp`

Verify:

```bash
systemctl status sshd --no-pager
ufw status
ss -ltnp | grep ':22'
```

## 2. Disable SSH again

If you no longer want to expose the machine:

```bash
sudo margine-disable-ssh-server
```

That:

- stops and disables `sshd.service`
- removes the SSH firewall rule when present

## 3. Connecting to a QEMU validation VM

The current QEMU harness forwards:

- host `127.0.0.1:2222`
- guest `:22`

So, after enabling SSH inside the VM, connect from the host with:

```bash
ssh -p 2222 daniel@127.0.0.1
```

If the VM was recreated and you get the classic host-key mismatch warning, clean
the old host key first:

```bash
ssh-keygen -R '[127.0.0.1]:2222'
```

Then connect again:

```bash
ssh -p 2222 daniel@127.0.0.1
```

## 4. Connecting to a real machine

After enabling SSH on the target machine:

```bash
ssh daniel@<machine-ip-or-hostname>
```

Examples:

```bash
ssh daniel@192.168.1.50
ssh daniel@margine-laptop
```

## 5. Post-install validation for SSH

The minimal check set is:

```bash
systemctl status sshd --no-pager
ufw status
ss -ltnp | grep ':22'
```

And from the client side:

```bash
ssh -v -p 2222 daniel@127.0.0.1
```

for the QEMU VM, or:

```bash
ssh -v daniel@<machine-ip-or-hostname>
```

for real hardware.

## 6. Operational model

The intended operator model is:

1. install `Margine`
2. validate the desktop and boot baseline
3. enable SSH only when it is actually needed
4. disable it again when the remote access window is over

This keeps the workstation practical without making inbound exposure the default.
