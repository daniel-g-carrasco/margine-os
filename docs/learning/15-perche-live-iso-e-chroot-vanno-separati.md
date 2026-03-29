# Perché live ISO e chroot vanno separati

## Il problema

Quando installi Arch da live ISO, stai lavorando in due mondi diversi:

1. il sistema temporaneo della chiavetta;
2. il sistema vero che stai costruendo sotto `/mnt`.

Se ti dimentichi questa distinzione, inizi a scrivere script confusi.

## Primo mondo: la live ISO

Qui hai strumenti utili per installare:

- `pacstrap`
- `genfstab`
- `arch-chroot`

Ma non stai ancora "dentro" il sistema finale.

## Secondo mondo: il sistema target

Dopo `pacstrap`, dentro `/mnt` esiste già un sistema Arch di base.

A quel punto ha senso entrarci con `arch-chroot` e lavorare lì come se fosse la
macchina vera.

## Che cosa non va fatto

Non è una buona idea scrivere uno script unico gigantesco che:

- monta;
- installa;
- genera `fstab`;
- entra nel chroot;
- configura locale;
- crea utenti;
- installa desktop;
- prepara bootloader;
- firma Secure Boot.

Quel tipo di script diventa presto fragile e opaco.

## La divisione giusta

La divisione didatticamente corretta è:

- fase 1: preparazione del target dalla live ISO;
- fase 2: configurazione del target dall'interno del target.

## Perché pacstrap non deve fare tutto

`pacstrap` serve a creare il sistema base.

Non è il posto giusto per tutta la logica del progetto.

Se lo usi bene:

- installa il minimo necessario;
- ti porta a un chroot utile;
- da lì continui in modo più pulito.

## Come si collega a Margine

In `Margine` questo significa:

- `bootstrap-live-iso` prepara il target;
- `bootstrap-in-chroot` continua il lavoro;
- `install-from-manifests` installa i layer ufficiali e opzionali.

## La regola mentale da ricordare

La live ISO prepara.
Il chroot configura.

Se uno script inizia a confondere questi due ruoli, sta diventando più brutto
di quanto dovrebbe.
