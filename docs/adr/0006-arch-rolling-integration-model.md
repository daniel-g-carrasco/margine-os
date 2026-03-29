# ADR 0006 - Modello di integrazione con Arch rolling

## Stato

Accettato

## Perché esiste questo ADR

Una domanda importante è emersa presto:

- `Margine` va aggiornato ogni volta che Arch o il kernel vengono aggiornati?

Se questa domanda resta implicita, il progetto rischia di essere interpretato in
due modi sbagliati:

- come una distro congelata da ricostruire ad ogni update;
- oppure come una raccolta di dotfiles scollegata dalla realtà del rolling
  release.

Nessuna delle due interpretazioni è corretta.

## Problema da risolvere

`Margine` vuole essere:

- riproducibile;
- didattico;
- mantenibile;
- compatibile con Arch rolling.

Questo significa che dobbiamo distinguere chiaramente:

- chi fornisce i pacchetti;
- chi definisce l'assemblaggio del sistema;
- quando va aggiornata la repo `margine-os`;
- quando basta aggiornare il sistema installato.

## Decisione

`Margine` NON è un fork congelato di Arch.

`Margine` è un layer di assemblaggio e manutenzione sopra Arch rolling, composto
da:

- manifest di pacchetti;
- file di configurazione;
- script di bootstrap e post-install;
- hook di manutenzione;
- documentazione e ADR.

## Cosa significa in pratica

### Installazione

Da una base Arch pulita:

- `pacman` installa i pacchetti più aggiornati disponibili in quel momento nei
  repo ufficiali;
- i nostri script applicano sopra quei pacchetti la forma `Margine`.

Quindi la repo `margine-os` non serve a "fornire pacchetti Arch".
Serve a definire come quei pacchetti vengono combinati.

### Aggiornamento ordinario del sistema

Un sistema `Margine` già installato si aggiorna come una normale Arch:

- update dei pacchetti;
- rigenerazione artefatti locali necessari;
- snapshot e recovery secondo la policy del progetto.

Non serve modificare la repo `margine-os` a ogni aggiornamento ordinario.

### Quando invece va aggiornata la repo

La repo `margine-os` va aggiornata quando cambia uno di questi strati:

- nome o disponibilità di un pacchetto;
- path o formato di un file gestito dal progetto;
- comportamento di strumenti chiave, come `mkinitcpio`, `sbctl`, `Limine`,
  `systemd-cryptenroll`;
- policy del progetto;
- scelta di un nuovo componente;
- script di installazione o manutenzione.

In altre parole:

- Arch cambia continuamente;
- `Margine` cambia solo quando deve adattare o migliorare la sua architettura.

## Regola di compatibilità

Per la `v1`, `Margine` seguirà questa regola semplice:

- supportiamo lo stato corrente dei repo ufficiali Arch;
- non promettiamo compatibilità con snapshot arbitrari e remoti del passato.

Questo è coerente con un progetto basato su Arch rolling.

## Conseguenze pratiche

### Vantaggi

- non dobbiamo "rilasciare una distro" ad ogni update Arch;
- possiamo installare sempre da pacchetti aggiornati;
- la manutenzione resta concentrata su ciò che controlliamo davvero;
- il progetto resta piccolo e leggibile.

### Costi

- dobbiamo tenere d'occhio i cambiamenti upstream che impattano la nostra
  automazione;
- ogni tanto un ADR o uno script andranno aggiornati;
- il progetto deve essere testato contro l'Arch attuale, non solo scritto bene.

## Rapporto con `update-all`

Lo script `update-all` non diventa un package manager alternativo.

Il suo ruolo corretto sarà:

- orchestrare update, snapshot, rigenerazione `UKI`, firme e verifiche;
- non sostituire la fonte dei pacchetti.

La fonte dei pacchetti resta:

- `pacman` per i repo ufficiali;
- AUR solo dove esplicitamente ammesso dal progetto.

## Per uno studente: la versione semplice

Se lo spieghiamo nel modo più diretto possibile:

- Arch fornisce i mattoni;
- `Margine` decide come montarli;
- quando Arch aggiorna un mattone, di solito basta aggiornare il sistema;
- tocchiamo la repo `margine-os` solo quando cambia il modo in cui montiamo i
  mattoni.

Questa è la differenza tra:

- una distro congelata;
- e un framework riproducibile sopra una rolling release.
