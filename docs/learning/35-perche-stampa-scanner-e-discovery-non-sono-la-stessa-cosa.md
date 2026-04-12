# Because printing, scanning and discovery are not the same thing

Many people think that it is enough to say:

- "I need the printer"

or:

- "I need the scanner"

In reality there are more different pieces.

## The four true levels

When you talk about a printer or scanner, you are basically putting together:

1. the print engine
2. the scan engine
3. local network discovery
4. the interface you actually use

## Example of print side

To print well with modern devices, in `Margine` the roles are these:

- `CUPS` = print engine
- `Avahi + nss-mdns` = discovery and resolution in the local network
- `ipp-usb` = bridge to modern USB devices that speak IPP
- `system-config-printer` = management interface

## Example of scanner side

For scanners the logic is similar:

- `SANE` = general backend
- `sane-airscan` = practical support for `eSCL/WSD` devices
- `simple-scan` = simple interface for the user

## Why discovery matters

A common mistake is installing `cups` and then wondering why the printer
network or network scanner does not appear well.

The discovery level is often missing:

- `Avahi`
- `nss-mdns`

## Choosing Margin

`Margine v1` chooses a baseline `driverless-first`.

This means:

- first modern standards and official packages;
- then any special drivers only if a real case requires it.