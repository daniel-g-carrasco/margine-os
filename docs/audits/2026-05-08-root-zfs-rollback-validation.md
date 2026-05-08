# 2026-05-08 - Root-on-ZFS rollback boot validation

## Scope

This audit records the first successful validation that a Margine
`margine-cachyos` root-on-ZFS VM can boot a pre-update rollback entry generated
by `update-all`.

## Evidence

The QEMU validation log set is:

```text
build/qemu-root-zfs-validation-logs/20260508-141825/
```

The user log shows that the running kernel command line selected the rollback
clone directly:

```text
root=ZFS=rpool/ROOT/margine-pre-update-20260508-000843
```

The same log shows `/` mounted from that clone:

```text
/  rpool/ROOT/margine-pre-update-20260508-000843  zfs
```

The root log shows the pool still has the primary bootfs:

```text
rpool bootfs rpool/ROOT/default
```

That is expected. Limine rollback entries select the clone through the kernel
command line rather than by changing the pool `bootfs`.

## Finding

The installed validator still treated `rpool/ROOT/default` as the only valid
mounted root in boot-chain mode. That is correct for the primary entry but wrong
for a selected rollback boot environment. The validator therefore reported:

```text
target root source mismatch: expected rpool/ROOT/default, got rpool/ROOT/margine-pre-update-20260508-000843
```

The system was booted from the intended rollback clone; the validator logic was
too narrow.

## Correction

`validate-root-zfs-target` now accepts an active mounted root dataset that is a
marked rollback boot environment when all of these are true:

```text
target-root is /
mode is boot-chain
mounted dataset is below the same rpool/ROOT parent
org.margine:bootenv=pre-update
origin points to rpool/ROOT/default@margine-pre-update-...
/proc/cmdline contains root=ZFS=<mounted rollback dataset>
```

The collector now records clone origins and Margine boot-environment properties
in the ZFS dataset section so later log reviews can validate the full rollback
shape without requiring an additional SSH pass.

## Documentation

The lifecycle is documented in:

```text
docs/runbooks/root-on-zfs-update-rollback.md
```

Current explicit limits remain:

- no automatic rollback clone pruning;
- no automatic root snapshot pruning;
- no clone promotion workflow;
- no multi-dataset transaction across `/home`, `/games`, VM/container datasets
  or the ESP.
