# Inventario

Questa cartella non servirà a clonare la macchina corrente.
Servirà a capire:

- cosa esiste oggi;
- cosa vale la pena tenere;
- cosa eliminare;
- cosa riscrivere meglio.

Il criterio non è "è installato quindi lo porto".
Il criterio è "serve davvero al nuovo sistema?".

La sottocartella `settings/` distingue:

- file `home` gia' approvati per la migrazione;
- file `system` gia' approvati per la migrazione;
- file di sistema che richiedono ancora review prima di diventare target.

La sottocartella `apps/` raccoglie invece le decisioni applicative:

- cosa entra davvero come configurazione;
- cosa resta solo dato personale;
- cosa va tradotto in template invece che copiato.

Questo vale anche per strumenti "di sistema" come `Timeshift`, quando la
decisione utile e' piu' applicativa che infrastrutturale.

Qui possono entrare anche validazioni reali di sottosistemi specifici, quando
servono a confermare che una scelta architetturale del progetto corrisponde
davvero all'hardware e al workflow usati.

La sottocartella `runtime/` raccoglie invece:

- audit dei sottosistemi reali della macchina corrente;
- gap tra macchina attuale e baseline `Margine`;
- risultati di validazioni ripetibili guidate dagli script del progetto.
