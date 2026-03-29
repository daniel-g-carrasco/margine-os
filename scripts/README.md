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
