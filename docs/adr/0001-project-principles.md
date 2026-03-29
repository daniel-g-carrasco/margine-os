# ADR 0001 - Principi fondativi del progetto

## Stato

Accettato

## Contesto

Il progetto nasce da una macchina Arch già usata e modificata nel tempo.
Esiste quindi un rischio alto di:

- replicare errori storici;
- portarsi dietro pacchetti inutili;
- perdere la logica delle scelte;
- dipendere da configurazioni non capite.

## Decisione

Si adottano questi principi:

1. `Allowlist first`
   Si replica solo ciò che viene approvato esplicitamente.

2. `Documentation is part of the product`
   Documentazione, ADR e note didattiche non sono extra opzionali.

3. `Official repos first`
   AUR è eccezione, non regola.

4. `Didactic over clever`
   Meglio script semplici e leggibili che automazioni troppo smart.

5. `Git before complexity`
   Tutto deve essere tracciato e versionato.

6. `One decision at a time`
   Le grandi scelte architetturali vanno prese in ordine, non tutte insieme.

## Conseguenze

- Il progetto crescerà a fasi.
- Ogni fase avrà deliverable chiari.
- Le configurazioni finali dovranno poter essere modificate a mano da Daniel.
- Le scelte tecniche verranno spiegate come a uno studente.
