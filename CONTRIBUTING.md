# Contributing

Thanks for contributing to `Margine`.

## Public repository boundary

This repository is the **public** side of the project.

That means contributions here should stay:

- redistributable;
- reviewable;
- useful outside the author's private machine;
- free from private credentials, private assets, and private-only upstream assumptions.

## What belongs here

- shared provisioning logic
- validation logic
- public documentation
- public product manifests
- flavor overlays that remain safe to publish
- desktop and boot UX that belongs to the public baseline

## What should stay out

- secrets or machine-specific credentials
- private-only product manifests
- private repo URLs or unpublished distribution remotes
- changes that only make sense for the future personal CachyOS-based build

## Change style

- keep scripts readable and explicit;
- prefer small, auditable changes over clever compact ones;
- update docs when behavior changes;
- preserve rollback and recovery assumptions;
- avoid introducing long-lived divergence for the same concern.

## Validation expectations

Before opening a pull request:

- run `bash -n` on touched shell scripts;
- dry-run provisioning scripts when possible;
- describe which product and flavor the change targets;
- call out redistributability concerns explicitly if they exist.
