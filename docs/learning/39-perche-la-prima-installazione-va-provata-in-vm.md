#39 - Why the first installation should be tried in VM

When building a system like `Margine`, the first mistake to avoid is:

"Everything looks right in the files, so I'll try it on the real laptop now."

It's an error because:

- disk provisioning is destructive;
- UEFI boot chain can break silently;
- a real live ISO introduces variables that `dry-run` don't cover.

The VM is used for exactly this:

- reduce the risk;
- repeat the test;
- see if the bootstrap really comes on the first boot.

The rule of thumb is:

1. first VM;
2. poi hardware reale.
