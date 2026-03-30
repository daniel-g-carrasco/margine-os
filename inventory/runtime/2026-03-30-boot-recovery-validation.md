# Validazione boot e recovery reale - 2026-03-30

## Scope

Questa review verifica:

- Secure Boot
- UKI
- bootloader reale corrente
- stato reale di `Snapper`

## Risultati principali

### Secure Boot / TPM2 / UKI

Risultati osservati:

- `Secure Boot`: attivo
- `TPM2`: presente
- `Measured UKI`: presente
- `sbctl`: installato

Conclusione:

- il lato trust-chain moderno della macchina attuale e' reale, non teorico.

### Bootloader reale

Risultato osservato:

- la macchina attuale avvia con `systemd-boot`, non con `Limine`

Conclusione:

- questo e' un gap esplicito rispetto all'architettura target di `Margine`;
- il progetto deve quindi continuare a trattare `Limine-first` come obiettivo
  da validare, non come stato gia' raggiunto sulla macchina reale.

### Snapper / Recovery

Risultati osservati:

- `snapper` e' installato
- `/.snapshots` esiste
- ma non risultano config reali
- non risultano snapshot `root`
- `snapper-timeline.timer`: disabilitato
- `snapper-cleanup.timer`: disabilitato

Conclusione:

- la macchina attuale non e' ancora una buona prova del modello recovery di
  `Margine`;
- proprio per questo il progetto fa bene a versionare in modo esplicito
  `Snapper`, `snap-pac` e il flusso `update-all`.
