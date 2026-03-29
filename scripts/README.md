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
