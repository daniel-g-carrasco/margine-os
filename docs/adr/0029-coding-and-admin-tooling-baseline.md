# ADR 0029 - Baseline tooling for coding and administration

## State

Accepted

## Context

`Margine` is not just a graphical desktop.
It must also be born as a practical machine for:

- daily coding;
- system inspection;
- debugging leggero;
- terminal-first work.

Leave these tools implicit within `base` or dispersed among other layers
it would make the project less readable.

## Decision

`Margine v1` introduce un layer dedicato:

- `coding-system-tools`

This layer collects workstation tooling for terminal and administration,
separandolo da:

- system basis;
- desktop Hyprland;
- user applications.

## Baseline content

The layer includes, among others:

- `tmux`
- `opencode`
- `htop`
- `btop`
- `radeontop`
- `ripgrep`
- `fd`
- `jq`
- `tree`
- `curl`
- `grep`
- `less`
- `openssh`
- `rsync`
- `strace`
- `lsof`

## Specific choices

### 1. Kitty remains the baseline terminal

`kitty` does not fit into this layer.

Reason:

- fa parte del desktop baseline;
- it is not an auxiliary tool, but the standard session terminal.

### 2. Opencode enters the official repositories

Since `opencode` is currently available in the official Arch repositories, it is not available
treated as an AUR exception.

### 3. Basic commands already present

Some tools are already ported by Arch itself or by dependencies
ampie.

However, we make them explicit when they are part of the experience we want
ensure, so the manifest actually describes the target system.

### 4. Ghostty exits the perimeter

`Ghostty` does not fit into the `v1` baseline.

Reason:

- the baseline terminal is already `kitty`;
- keeping two terminals as default would increase noise and duplication.

## Consequences

### Positive

- the project clearly declares its workstation equipment;
- useful tools for coding and administration do not remain implicit;
- the layer remains easy to extend.

### Negative

- the number of explicit packets increases;
- some utilities are redundant compared to what Arch already brings with it
  se'.

## For a student

The rule here is simple:

- not everything that exists in the system deserves a layer;
- but what defines your way of working does.

This is why `Margine` separates:

- the basis of the system;
- il desktop;
- terminal tooling.
