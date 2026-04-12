# Why terminal tooling deserves a dedicated layer

When you build your own system, there is a very common mistake:

- think that terminal tools are \"implied\"

Actually I'm not.

Tra:

- a system that only has basic Arch;
- and a system designed to really work;

the difference often lies right here.

## Simple example

`tmux`, `ripgrep`, `fd`, `jq`, `htop`, `radeontop`, `opencode`.

None of these are \"ornamental\".
They define how you work, search, debug, and administer the machine.

## Because it's not enough to say \"there's a basis\"

Some commands already come with Arch.

But if you leave them implicit:

- the repo no longer explains the target system;
- you no longer know which tools you consider truly essential;
- bootstrap becomes less readable.

## Choosing Margin

For this reason `Margine` keeps separate:

- basis of the system;
- graphical desktop;
- terminal tooling and administration.

## What's in it for you

When you reopen the repo in months, you will immediately understand:

- what tools are used to work;
- which ones are needed for the desktop;
- which are only incidental dependencies.