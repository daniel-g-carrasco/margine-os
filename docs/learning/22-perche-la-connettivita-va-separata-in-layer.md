# Because connectivity must be separated into layers

When setting up network, Wi-Fi, VPN and Bluetooth it's easy to get confused, because
all these pieces seem "the same thing".

In reality they are not.

## The three levels to understand

### 1. Orchestration

This is the level that decides:

- what connections exist;
- which profile is active;
- how VPN, DNS and network status integrate.

In `Margine`, this level is `NetworkManager`.

### 2. Backend hardware o protocollo

This is the layer that really talks to the device or protocol:

- `iwd` for Wi-Fi;
- `bluez` for Bluetooth;
- kernel/user-space tools for `WireGuard`.

This level does not have to decide the entire policy of the system.

### 3. User interface

This is the level you see:

- `impala`;
- `bluetui`;
- the VPN menu in `waybar`.

These tools are important, but should not be mistaken for the
"engine" of the system.

## Because it's useful to think like this

If one day you change the interface, you don't have to throw away the architecture.

Esempio:

- you can replace `impala` with another TUI;
- but `NetworkManager + iwd` can remain intact.

This is exactly why `Margine` doesn't want a setup
random "taken from the machine that works today", but a decomposable system and
readable.

## The rule of thumb

When adding a piece to connectivity, always ask yourself:

- is it the brain?
- is it the engine?
- or is it just the interface?

If you don't know the answer, you're still mixing layers.