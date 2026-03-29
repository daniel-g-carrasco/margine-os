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
