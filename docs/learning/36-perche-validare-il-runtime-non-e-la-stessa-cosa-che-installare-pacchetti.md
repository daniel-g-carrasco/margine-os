# Because validating the runtime is not the same as installing packages

When a project grows, it is easy to fall into this illusion:

- "if the package is in the manifest, then the subsystem is fine"

It is not true.

## Three different levels

For each subsystem you have at least three levels:

1. package installed
2. active service or configuration
3. real behavior on the hardware

## Simple example

You can have:

- `fprintd` installed
- the resume hook present
- and still find real errors during suspension

Or:

- `snapper` installed
- `/.snapshots` mounted
- but no real config or useful snapshots

## The Margin rule

For this reason `Margine` wants to be:

- bootstrap script;
- both runtime validation scripts.

The installation scripts say:

- what should be there

The validation scripts say:

- what is really working

## For a student

Installing and validating are two different phases.

If you mix them up, you build systems that look complete in the files, but yeah
they break as soon as you actually use them.