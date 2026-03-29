# Perché serve un orchestratore sopra gli script

## Il punto importante

Separare gli script è giusto.

Ma chiedere all'utente di fare a mano tutta l'orchestrazione non è sempre una
virtù.

## Il rischio opposto

Se mettiamo tutto in un solo mega-script:

- il codice diventa più confuso;
- i test diventano peggiori;
- il riuso dei pezzi diminuisce;
- i bug fanno più danni.

## Il compromesso corretto

Il compromesso buono è questo:

- script piccoli con responsabilità chiare;
- uno script top-level che li orchestra.

Questa è una struttura molto comune nei sistemi ben progettati.

## Applicato a Margine

Nel nostro caso:

- `provision-storage` prepara il disco;
- `bootstrap-live-iso` prepara il sistema base;
- `bootstrap-in-chroot` completa la fase successiva.

Lo script `install-live-iso` non deve reinventare quei passi.

Deve solo chiamarli nel giusto ordine.

## Perché è didatticamente migliore

Perché puoi studiare il sistema a due livelli:

1. il dettaglio dei singoli script;
2. il flusso completo di installazione.

Se un giorno vorrai cambiare qualcosa, saprai dove mettere le mani:

- nel mattone giusto, se cambi un comportamento locale;
- nell'orchestratore, se cambi il flusso.

## La regola mentale da ricordare

Un buon orchestratore collega bene i pezzi.

Non li ingloba.
