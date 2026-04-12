# ADR 0030 - Remote access and firewall baseline

## State

Accepted

## Context

`Margine` must also be a practical workstation for:

- connect to other servers;
- offer remote access when needed;
- Don't be born with haphazardly exposed doors.

This requires distinguishing four things:

- package `openssh`;
- service `sshd`;
- firewall;
- effective opening of the SSH port.

## Decision

For `Margine v1` we adopt:

- `openssh` as baseline;
- `ufw` as baseline firewall;
- `sshd` configured but not automatically opened to the outside;
- Simple helpers to enable or disable the SSH server when needed.

## Because UFW

For `Margine v1`, `ufw` has a clear advantage:

- it is simpler and more didactic than pure `nftables`;
- it is sufficient for a personal laptop and a single-user workstation;
- allows for a readable baseline without hiding too much what's going on.

`nftables` remains more native and more flexible, but for `v1` we don't need it
that complexity.

## Specific choices

### 1. Policy firewall

The baseline `ufw` is:

- `deny incoming`
- `allow outgoing`
- `deny routed`

This means:

- the car comes out freely;
- does not expose incoming services by default.

### 2. SSH server

`openssh` is present for both the client and the server.

However, `sshd` is not automatically considered "public".

The project installs:

- a small drop-in `sshd_config.d`;
- a helper to activate the server;
- a helper to disable it.

### 3. Apertura porta SSH

The SSH port is not opened by default in the firewall.

When the user decides they really want to expose the machine via SSH, use:

- `margine-enable-ssh-server`

This:

- enable `sshd.service`;
- apre la porta con `ufw limit 22/tcp`.

Per tornare indietro:

- `margine-disable-ssh-server`

### 4. Hardening minimo di SSH

The baseline adds only a small, non-intrusive hardening:

- `PermitRootLogin no`
- `X11Forwarding no`
- `UseDNS no`

We do not impose a rigid key-only model in `v1`, so as not to break it
immediately the usability of the server on a personal machine.

## Consequences

### Positive

- the system is born with remote access ready but not exposed at random;
- the firewall has a simple and readable policy;
- the user can enable SSH in one command, without having to reinvent everything.

### Negative

- `ufw` is not the most "pure" solution possible;
- the SSH policy remains deliberately prudent and not extremely restrictive.

## For a student

The rule to learn is this:

- installing a server does not mean having to expose it immediately;
- having a firewall doesn't mean blocking everything blindly;
- the good baseline is the one that separates package, service and door opening.
