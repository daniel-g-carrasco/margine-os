# Host Sync Workflow

When the host machine is the source of truth for the desktop baseline, do not
assume that a fix applied live was also versioned.

Use this workflow before every push:

1. Apply and verify the fix on the host.
2. Copy the fix into the repo payload under `files/home/...` or the relevant system payload path.
3. Run `scripts/check-host-baseline-sync`.
4. Run `scripts/check-shell-and-manifests`.
5. Push only after both pass.

The local `pre-push` hook can enforce this automatically:

```bash
scripts/install-git-hooks
```

Notes:

- `scripts/check-host-baseline-sync` checks only the files listed in `inventory/host-sync.manifest`.
- Keep that manifest focused on the portable desktop baseline, not application state or per-machine data.
- This guardrail is local by design. CI cannot compare against the workstation state.
