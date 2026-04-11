# Visione del progetto

## Obiettivo

Ottenere da una installazione Arch pulita un sistema equivalente a quello
desiderato, non a quello casualmente accumulato nel tempo.

Il sistema dovrà essere:

- riproducibile;
- stabile;
- veloce;
- ben documentato;
- didattico;
- facile da modificare a mano in futuro.

## Idea guida

Questo progetto non vuole creare "una ISO da hacker". Vuole creare un sistema
che Daniel capisce davvero.

Per questo:

- ogni sottosistema avrà note didattiche;
- ogni decisione importante avrà un ADR;
- ogni fase avrà criteri di completamento;
- ogni automazione dovrà restare leggibile.

## Identità tecnica

- Base: `Arch Linux`
- Desktop principale: `Hyprland`
- Macchina target: `Framework Laptop 13 AMD`
- Filesystem: `Btrfs`
- Cifratura: `LUKS2`
- Sicurezza target: `Secure Boot` sotto nostre chiavi + `TPM2` per sblocco
  automatico `LUKS` sul path di boot normale
- Focus: fotografia, stabilità, rollback, manutenzione chiara

## Nota sullo stato attuale

L'architettura desiderata è:

- `LUKS2` sempre presente
- `Secure Boot` bootstrapato dopo l'installazione
- `TPM2` enrollato dopo che il path di boot firmato è già stabile

Quindi:

- il target non è "Secure Boot o TPM2"
- il target è `Secure Boot + LUKS2 + TPM2`
- ma il rollout corretto è graduale e post-install, non tutto in un unico passo

## Cosa non faremo

- Non copieremo tutte le app correnti senza filtro.
- Non useremo AUR come base del sistema.
- Non confonderemo "funziona adesso" con "è una buona scelta architetturale".
- Non introdurremo troppi layer di astrazione al primo giro.

## Nome

- Nome umano del sistema: `Margine`
- Nome tecnico del repository: `margine-os`

Motivo: `Margine` ha personalità. `margine-os` è più pratico per git, package
namespace e naming dei file.
