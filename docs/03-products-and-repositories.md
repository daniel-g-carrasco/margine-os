# Products And Repositories

## Goal

`Margine` needs to support two parallel tracks:

- a public, redistributable project;
- a private, personal project that can adopt upstreams and policies that should
  not live in the public repository.

## Repository model

The recommended model is:

- public repository: `margine-os`
- private repository: `margine-os-personal`

The public repository remains the source of truth for:

- shared desktop UX;
- provisioning logic;
- validation logic;
- public documentation;
- redistributable products.

The private repository only adds:

- private product manifests;
- private overlays;
- upstream integrations that should not be redistributed from the public repo.

## Product model

A product manifest sits in `products/*.toml` and describes:

- what the deliverable is called;
- whether it is public or private;
- whether it is redistributable;
- which base distribution it targets;
- which flavor overlay resolves manifests;
- which kernel / bootloader policy it expects.

Operational scripts should accept `--product` and derive `flavor` from the
product unless the caller explicitly overrides it.

## Flavor model

Flavor overlays remain a package-resolution mechanism:

- `manifests/packages` and `manifests/flatpaks` are the shared baseline;
- `manifests/flavors/<name>` can replace individual layers when needed.

Flavors are intentionally smaller in scope than products.

## Practical workflow

1. implement generic changes in the public repository;
2. sync the private repository from the public one;
3. keep private-only upstream integrations in the private repository;
4. backport only the generic parts to the public repo.
