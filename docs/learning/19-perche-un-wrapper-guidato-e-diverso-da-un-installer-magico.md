# Perché un wrapper guidato è diverso da un installer magico

## Il punto importante

Un installer guidato non deve nascondere il sistema.

Deve renderlo più leggibile.

## La trappola da evitare

La trappola classica è questa:

- un'interfaccia comoda;
- tanta logica implicita;
- poca comprensibilità reale.

Alla prima anomalia, l'utente non sa più dove mettere mano.

## La scelta di Margine

Il wrapper guidato di `Margine` fa una cosa più onesta:

- ti chiede i parametri in ordine;
- ti mostra un riepilogo;
- poi chiama gli script reali del progetto.

Quindi il "wizard" non sostituisce l'architettura.

La attraversa.

## Perché è didatticamente migliore

Perché domani potrai:

- usare il wizard;
- oppure saltarlo e chiamare direttamente gli script sottostanti.

Questo è il segno di un buon design:

- comodità per oggi;
- comprensibilità per domani.

## La regola mentale da ricordare

Se un wrapper guidato ti impedisce di capire cosa succede, è troppo opaco.

Se ti accompagna senza nasconderti i pezzi, è fatto bene.
