# Because Firefox must be configured with policies and Neovim with files

Not all applications expose the configuration in the same way.

## Firefox

`Firefox` has two distinct worlds:

- the complete user profile;
- system policies.

The user profile contains too much:

- chronology;
- extensions;
- local state;
- internal databases;
- preferences mixed with personal data.

For a reproducible and didactic system, this is a terrible basis.

The policies, on the other hand, serve precisely to define:

- the desired basic behavior;
- some rules to always apply;
- a clear baseline between different installations.

This is why in `Margine` `Firefox` is treated with policy.

## Neovim / LazyVim

Here the situation is the opposite.

The configuration of `Neovim` is:

- textual;
- modular;
- readable;
- relatively small;
- truly representative of the workflow.

So it makes a lot of sense to version them as regular files.

## The general lesson

The question is not:

- "where do I save the files?"

The right question is:

- "what is the cleanest configuration mechanism for this application?"

Per `Firefox`:

- policy.

Per `Neovim`:

- configuration file.

