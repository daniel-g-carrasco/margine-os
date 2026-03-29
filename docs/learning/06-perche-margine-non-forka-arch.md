# Perché Margine non "forka" Arch

Questa nota risponde a un dubbio molto naturale:

- se costruiamo una distro personale, dobbiamo aggiornarla ogni volta che Arch
  aggiorna qualcosa?

La risposta corretta, per come stiamo progettando `Margine`, è:

- no, non in quel senso.

## 1. Due livelli diversi

Per capire bene il progetto devi separare due livelli.

### Livello 1: Arch

Arch fornisce:

- i pacchetti;
- il kernel;
- `systemd`;
- gli aggiornamenti rolling;
- gli strumenti base.

### Livello 2: Margine

`Margine` fornisce:

- la selezione dei pacchetti giusti;
- le configurazioni;
- gli script;
- gli hook;
- la documentazione;
- la logica di recovery e manutenzione.

La lezione importante è questa:

- `Margine` non sostituisce Arch;
- `Margine` organizza Arch.

## 2. Perché questo modello è migliore per noi

Se facessimo un vero fork congelato di Arch, dovremmo:

- inseguire ogni update molto più da vicino;
- gestire build e pacchetti in proprio;
- alzare di molto la complessità del progetto.

Questo non è coerente con i nostri obiettivi.

Noi vogliamo:

- un sistema personale forte e riproducibile;
- non diventare una mini-distribuzione generalista.

## 3. Cosa succede quando fai una installazione nuova

Quando installerai `Margine` da zero, succederà questo:

1. parti da una base Arch pulita;
2. `pacman` prende i pacchetti disponibili in quel momento;
3. i nostri script ricostruiscono la forma `Margine` sopra quei pacchetti.

Quindi non installerai:

- "una vecchia fotografia congelata del sistema"

Installerai invece:

- "la forma aggiornata di Margine sopra l'Arch di oggi".

## 4. Cosa succede quando aggiorni il sistema già installato

Qui la regola è ancora più semplice.

Aggiornare un sistema `Margine` significherà, in generale:

- aggiornare i pacchetti;
- rigenerare gli artefatti che dipendono dal boot path;
- verificare che snapshot e firme siano coerenti.

Non significa:

- riscrivere ogni volta la repo `margine-os`.

## 5. Quando invece va cambiata la repo

La repo va cambiata quando cambia il progetto, non ogni volta che cambia un
pacchetto.

Esempi veri:

- cambia il nome di un pacchetto che usiamo;
- cambia il path di `Limine`;
- cambia il comportamento di `mkinitcpio`;
- decidiamo una nuova policy `TPM2`;
- sostituiamo un'applicazione.

Questa è una distinzione da capire molto bene:

- aggiornare il sistema è manutenzione ordinaria;
- aggiornare la repo è manutenzione architetturale.

## 6. Dove si colloca `update-all`

`update-all` non sarà "il posto dove vivono i pacchetti".

Sarà piuttosto il direttore d'orchestra di operazioni come:

- snapshot pre-update;
- `pacman -Syu`;
- rigenerazione `UKI`;
- firma;
- verifiche;
- snapshot post-update.

Questa è una distinzione sana.

Un buon script orchestra.
Non finge di essere il repository del sistema.

## 7. La regola mentale da ricordare

Se un giorno ti confondi, ricordati questa frase:

- Arch fornisce i componenti.
- Margine definisce il sistema.

Se tieni separate bene queste due idee, tutto il progetto diventa molto più
leggibile.
