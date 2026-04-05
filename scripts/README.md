# Scripts

Questa cartella conterrà gli script operativi del progetto.

Categorie attese:

- bootstrap da live ISO;
- post-install;
- generazione configurazioni;
- verifica del sistema;
- manutenzione e aggiornamento.

Regola:

- script piccoli;
- idempotenti quando possibile;
- leggibili prima che "furbi".

Primo script operativo:

- `generate-limine-config`: renderizza `limine.conf` dal template versionato e
  dai dati macchina minimi.
- `update-all`: orchestratore del ciclo di update, con supporto `dry-run` e
  distinzione tra layer core e accessori.
- `deploy-boot-artifacts`: installa su `ESP` gli artefatti generati, con backup
  preventivo dei file sovrascritti.
- `refresh-efi-trust`: calcola l'hash di `limine.conf`, esegue
  `limine enroll-config` e firma la catena EFI con `sbctl`.
- `provision-secure-boot`: gestisce il bootstrap iniziale di `sbctl`,
  l'enrollment delle chiavi nel firmware e, opzionalmente, il primo refresh
  della trust chain EFI.
- `provision-system-user`: crea o riallinea l'utente amministrativo,
  installa il drop-in `sudoers` e inizializza le directory utente.
- `install-from-manifests`: installa i layer definiti nei manifest, separando
  repo ufficiali, AUR e Flatpak tramite flag espliciti.
- `provision-storage`: prepara disco, `LUKS2`, `Btrfs` e subvolumi dalla live ISO.
- `install-live-iso`: orchestra `provision-storage` e `bootstrap-live-iso`
  in una pipeline unica da live ISO.
- `install-live-iso-guided`: wrapper interattivo passo passo sopra
  `install-live-iso` e `bootstrap-live-iso`.
- `bootstrap-live-iso`: fase 1 del bootstrap, pensata per la live ISO Arch.
- `bootstrap-in-chroot`: fase 2 del bootstrap, pensata per il sistema target.
- `provision-initial-boot-chain`: chiude il bootstrap installando la boot
  chain iniziale `mkinitcpio + UKI + Limine` sul sistema target.
- `provision-boot-baseline`: installa i file di baseline del boot locale
  (`mkinitcpio`, `vconsole`, `plymouth`, splash UKI) prima della rigenerazione.
- `validate-printing-scanning-baseline`: verifica pacchetti, servizi,
  discovery, stampanti e scanner rispetto alla baseline `Margine`.
- `provision-virtualization-containers-baseline`: installa i file di baseline
  per `libvirt` e gli helper minimi lato virtualizzazione.
- `validate-runtime-baseline`: verifica power, resume, audio, rete, Bluetooth e
  tooling screenshot/recording sulla macchina reale.
- `validate-boot-recovery-baseline`: verifica stato reale di Secure Boot, UKI,
  bootloader e Snapper.
- `validate-virtualization-containers-baseline`: verifica supporto CPU/KVM,
  pacchetti e stato reale di `libvirt` e `podman`.
- `prepare-qemu-archiso-validation`: prepara una VM QEMU/OVMF con Arch ISO
  ufficiale e una guida per validare `Margine` in installazione reale.
