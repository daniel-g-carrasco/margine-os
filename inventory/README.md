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
