# Because SSH package, service and firewall are not the same thing

This is a point that often creates confusion.

Many think:

- \"I installed OpenSSH, so the server is already exposed\"

or:

- \"I have a firewall, so I can ignore the service\"

These are two wrong ideas.

## The four true levels

There are four distinct levels here:

1. the `openssh` package
2. the `sshd` service
3. the firewall
4. the rule that really opens the door

## Simple example

You can have:

- `openssh` installed
- `sshd` off
- `ufw` active
- no open doors

In this case the machine:

- can use SSH client to log out;
- does not accept incoming SSH connections.

## Choosing Margin

`Margine` uses exactly this separation:

- the package is there;
- the firewall is there;
- the server is enabled when it is really needed.

## Because it's a good choice

For a personal laptop it's better like this:

- don't forget the server open on random networks;
- you don't have to reinstall or reconfigure everything when you need SSH;
- you really understand the difference between presence of the software and exposure of the
  service.