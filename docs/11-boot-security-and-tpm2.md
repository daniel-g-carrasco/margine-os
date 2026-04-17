# Boot Security Rollout: Secure Boot, LUKS, and TPM2

This document describes two different things that must not be confused:

- the target architecture `Margine` wants
- the safe rollout order that should be used on a real installed system

## 1. Target architecture

The target architecture is:

- `LUKS2` for the root disk
- `Btrfs` + `Snapper` for rollback and recovery
- `Limine` + `UKI` for the boot path
- `Secure Boot` controlled by our own keys with `sbctl`
- automatic `LUKS` unlock with `TPM2` on the normal production boot path
- explicit human fallback for recovery and snapshot boot paths

Important:

- the production path should be the convenient path
- the recovery path should be the robust path
- they are not required to have the same ergonomics

That means:

- normal boot should eventually auto-unlock with `TPM2`
- recovery should still tolerate manual unlock via passphrase or recovery key

## 2. Current implementation status

What is already versioned:

- `LUKS2` installation
- `UKI + Limine` boot chain
- post-install `sbctl` bootstrap tooling
- post-install staged `TPM2` tooling with `systemd-cryptenroll`
- installed-system trust refresh through `update-all`

What is still true:

- the installer does **not** do Secure Boot bootstrap automatically
- the installer does **not** do TPM2 enrollment automatically
- the safest TPM2 rollout is currently a post-install, two-step process
- QEMU validates TPM2 end-to-end only when the host provides `swtpm`

What is already validated on the real installed host path:

- `update-all` creates a dedicated pre-update snapshot
- rebuilds the `UKI` chain
- rewrites the active `limine.conf`
- reinstalls the unsigned `Limine` EFI binary before `enroll-config`
- reenrolls the config digest into the active loader
- re-signs the active loader
- re-signs the `Memtest86+` EFI payload when it is installed
- reaches a clean `sbctl verify`

## 3. Why Secure Boot must happen before TPM2 enrollment

This is the most important safety rule.

The recommended production PCR policy is:

- `PCR 7+11`

Why:

- `PCR 7` follows Secure Boot state and enrolled certificates
- `PCR 11` follows the unified kernel image payload measured by `systemd-stub`

Practical consequence:

- if you enroll TPM2 **before** Secure Boot is finalized, then later changing
  Secure Boot state or keys changes `PCR 7`
- if you enroll TPM2 **before** rebuilding/signing the final production UKI,
  then changing the UKI changes `PCR 11`
- if TPM2 is already enrolled against a `PCR 7` policy and you later disable
  Secure Boot in firmware, the normal production boot is expected to ask for
  the manual `LUKS` password again until Secure Boot is re-enabled or TPM2 is
  re-enrolled against a different PCR policy

So the safe order is:

1. finish Secure Boot bootstrap
2. boot the signed production UKI successfully
3. prepare the TPM2-aware initramfs/UKI
4. reboot once manually
5. only then enroll TPM2 against the current final boot state

## 4. Safe Secure Boot rollout

### Step 1: validate the base installation first

Do not bootstrap Secure Boot on an installation that has not yet passed the
basic post-install validation:

- [05-post-install-validation.md](/home/daniel/dev/margine-os/docs/05-post-install-validation.md)

### Step 2: export the current enrolled public keys and inspect the ESP

On the installed system, before touching firmware:

```bash
sudo /usr/local/lib/margine/scripts/provision-secure-boot-preflight --esp-path /boot
```

This gives you:

- the current `sbctl status`
- an export of the currently enrolled public keys
- a list of EFI binaries currently present on the ESP
- a recorded preflight stamp that `provision-secure-boot` expects by default

### Step 3: enter firmware and move Secure Boot into Setup Mode

On real hardware:

1. reboot into UEFI firmware setup
2. go to the Secure Boot section
3. move the machine into `Setup Mode`, usually by clearing the current `PK`
4. save and reboot back into `Margine`

Do not continue until firmware is actually in `Setup Mode`.

### Step 4: bootstrap Secure Boot from Margine

Back in the installed system:

```bash
sudo /usr/local/lib/margine/scripts/provision-secure-boot --esp-path /boot
```

If you skipped the preflight helper entirely, `provision-secure-boot` now
refuses by default. The only supported bypass is `--no-preflight-check`, and it
should be treated as an expert escape hatch.

Current default safety behavior:

- keeps Microsoft certificates
- keeps firmware builtin `db/KEK` certificates
- refreshes `limine.conf` enrollment and EFI signing after key enrollment
- signs `Memtest86+` too when the diagnostics payload is present on the ESP

That is deliberate. It reduces the risk of breaking:

- Windows boot paths
- vendor-signed firmware components
- Option ROM dependent hardware paths

### Step 5: reboot and validate Secure Boot

After the first reboot:

```bash
sudo sbctl status
sudo sbctl verify
```

You want:

- `Secure Boot: enabled`
- no missing-file signing surprises on the active EFI chain

The operator invariant to remember is:

`deploy -> reinstall unsigned loader -> enroll-config -> sign -> verify`

## 5. Safe TPM2 rollout

### Step 1: only start after Secure Boot is already good

Do not enroll TPM2 first.

### Step 2: run the staged TPM2 provisioning script

On the installed system:

```bash
sudo /usr/local/lib/margine/scripts/provision-tpm2-auto-unlock
```

What the first run does:

- writes `/etc/crypttab.initramfs`
- rebuilds the production and recovery UKIs
- re-signs the EFI chain when `sbctl` is already bootstraped
- stores a pending marker
- stops and asks for one reboot

### Step 3: reboot once and unlock manually

After that first run:

1. reboot
2. select the normal production boot entry
3. unlock `LUKS` manually one last time
4. reach the installed system normally

This boot is necessary so that the machine is running the final intended UKI and
PCR state before TPM2 sealing happens.

### Step 4: rerun the same command

Then run the same command again:

```bash
sudo /usr/local/lib/margine/scripts/provision-tpm2-auto-unlock
```

On the second run, the script:

- checks the pending marker
- ensures a recovery key exists
- enrolls TPM2 against the current boot state
- removes the pending marker

### Step 5: reboot and verify automatic unlock

Reboot again.

Expected behavior on the normal production path:

- `Limine` entry selected
- no manual `LUKS` password prompt

Important caveat:

- if your TPM2 policy includes `PCR 7`, this expectation depends on Secure Boot
  staying enabled
- disabling Secure Boot later does not mean TPM2 enrollment is lost, but it
  does intentionally invalidate the measured boot state and falls back to the
  manual `LUKS` password prompt
- system reaches the desktop directly

Expected behavior on recovery paths:

- manual unlock may still be required
- that is acceptable and intentional

## 6. Dual-boot and existing-system safety notes

This is the minimum operator discipline required.

### Keep these safety rules

- do not remove Microsoft certificates when Windows is present
- do not skip firmware builtin certificates unless you already know your
  firmware/OEM chain is safe without them
- do not delete old EFI files or boot entries before verifying the first clean
  Secure Boot reboot
- keep a live USB available
- keep firmware boot-menu access available

### What Margine now does to reduce risk

- `provision-secure-boot-preflight` exports the currently enrolled public keys
- `provision-secure-boot` defaults to Microsoft certificates
- `provision-secure-boot` defaults to firmware builtin `db/KEK`
- TPM2 rollout is staged, instead of sealing against the wrong pre-reboot PCR
  state

### What Margine still cannot guarantee

No script can fully guarantee that arbitrary third-party EFI payloads will still
boot after a custom-key Secure Boot migration.

That depends on:

- what those EFI binaries are signed with
- whether Microsoft and/or OEM certificates are needed
- whether the firmware has vendor quirks

So the repository can reduce risk, but not abolish it.

In particular:

- Windows and common OEM chains are the main protected case
- another Linux installation already relying on its own custom Secure Boot key
  still requires an explicit migration plan

For that advanced case, `sbctl` does expose mechanisms such as `--append` and
`--custom`, but `Margine` does not automate them. They are powerful enough to
matter, and dangerous enough that they should stay an operator decision.

## 7. QEMU and vTPM

The QEMU harness can attach a vTPM automatically when the host has `swtpm`
installed. Without `swtpm`, TPM2 validation remains unavailable in the VM.

So:

- boot/install/update validation in VM is useful now
- Secure Boot bootstrap flow can still be validated conceptually
- TPM2 end-to-end validation in VM is available only when `swtpm` is present on
  the host

## 8. Suggested validation commands

After Secure Boot:

```bash
sudo sbctl status
sudo sbctl verify
```

After TPM2 stage or enrollment:

```bash
sudo /usr/local/lib/margine/scripts/validate-tpm2-auto-unlock
```

Manual outcome to confirm:

- production boot unlocks automatically
- recovery boot still remains usable with manual credentials

## 9. References used for this design

- `systemd-cryptenroll(1)`:
  https://www.freedesktop.org/software/systemd/man/latest/systemd-cryptenroll.html
- `crypttab(5)`:
  https://www.freedesktop.org/software/systemd/man/latest/crypttab.html
- `systemd-cryptsetup-generator(8)`:
  https://www.freedesktop.org/software/systemd/man/latest/systemd-cryptsetup-generator.html
- `sbctl(8)`:
  https://man.archlinux.org/man/sbctl.8.en
- `sbctl` project:
  https://github.com/Foxboron/sbctl
