# Perché il preset audio va risolto a runtime

## Il punto importante

Un preset audio non vive nel vuoto.

Per funzionare bene deve sapere:

- su quale hardware sta girando;
- su quale output deve agganciarsi;
- quali file accessori servono davvero.

## L'errore classico

L'errore tipico è questo:

- copiare il preset in home;
- sperare che il nome del device sia identico ovunque;
- applicarlo globalmente a tutto.

Questa scorciatoia sembra comoda, ma è fragile.

## La scelta di Margine

`Margine` divide il problema in due:

1. versiona tutto ciò che è stabile:
   - preset;
   - IR del convolver;
   - servizio utente;
2. risolve a runtime tutto ciò che dipende dalla macchina reale:
   - vendor e modello;
   - sink audio interno;
   - route degli altoparlanti.

## Perché è didatticamente migliore

Perché ti insegna una regola utile in tanti contesti:

- i file statici vanno in Git;
- i fatti dinamici vanno rilevati quando esistono davvero.

Questo vale per l'audio, ma anche per rete, dischi, monitor e boot entries.

## La regola mentale da ricordare

Non hardcodare in installazione ciò che il sistema può scoprire meglio al
momento giusto.
