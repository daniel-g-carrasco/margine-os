# 2026-05-10 root-on-ZFS rollback canary validation

## Context

QEMU validation was run against the Margine Personal root-on-ZFS VM after the
`update-all` rollback path started creating clone-specific rollback UKIs and
Limine rollback entries.

The test goal was to prove more than "the rollback entry boots":

- root dataset mutations after `update-all` must disappear in the rollback boot;
- root dataset deletions after `update-all` must be restored in the rollback
  boot;
- root dataset files created after `update-all` must not exist in the rollback
  boot;
- `/home` and `/games` canaries created after `update-all` must persist because
  they are dedicated datasets outside the root rollback transaction;
- returning to Primary must boot `rpool/ROOT/default` again.

## Result

PASS.

The active rollback boot validated successfully for:

```text
rpool/ROOT/margine-pre-update-20260510-214928
```

The canary helper reported:

```text
rollback canary validation: OK
root canaries reverted to pre-update state
/home canary persisted across rollback
/games canary persisted across rollback
```

After rebooting back to Primary, collected logs showed:

```text
/ -> rpool/ROOT/default
rpool bootfs -> rpool/ROOT/default
validate-root-zfs-target --mode boot-chain -> OK
validate-zfs-rollback-boot-environment --mode published -> OK
systemctl --failed -> 0 loaded units listed
```

The canary cleanup phase was later run from Primary and completed:

```text
rollback canary cleanup: OK
removed from active root: /etc/margine/zfs-rollback-canary
removed from /home dataset: /home/danielitivov/.local/state/margine/zfs-rollback-canary
removed from /games dataset: /games/.margine-zfs-rollback-canary
```

## Known Caveats

The VM host-health root report still fails when `sbctl` is present but Secure
Boot keys are not initialized. That is expected for this validation VM and is not
a rollback failure.

The user-session log still shows early `xdg-desktop-portal-gtk` and Walker
startup warnings around display readiness. Those are session orchestration issues
and were not introduced by the ZFS rollback path.

Three rollback boot environments were present after repeated validation runs.
Automatic pruning is intentionally not enabled inside `update-all`. Retention is
handled by `prune-zfs-rollback-boot-environments`, which is an explicit
operator command: it prints a read-only plan by default and requires `--destroy`
before deleting rollback clones and their source snapshots.

## Follow-Up

- Keep the newest known-good rollback environment until the next successful
  primary boot is validated.
- Keep automatic pruning out of `update-all` until retention policy has more
  field validation.
