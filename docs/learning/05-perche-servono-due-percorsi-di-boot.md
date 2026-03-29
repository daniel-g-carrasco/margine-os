# Perché servono due percorsi di boot

Questa nota spiega una scelta che a prima vista può sembrare strana:

- perché non usare un solo percorso di boot per tutto?

La risposta breve è:

- perché il boot quotidiano e la recovery hanno obiettivi diversi.

## 1. Il boot normale vuole stabilità

Nel boot di tutti i giorni ci interessa soprattutto questo:

- che funzioni sempre;
- che sia ripetibile;
- che `TPM2` non sia fragile;
- che gli aggiornamenti rompano il meno possibile.

Per questo il percorso `prod` usa una `UKI` con command line incorporata.

La lezione qui è semplice:

- meno parametri variabili nel boot normale significa meno fragilità.

## 2. La recovery vuole flessibilità

La recovery, invece, vuole una cosa diversa:

- poter scegliere cosa bootare;
- poter puntare a uno snapshot specifico;
- poter entrare in manutenzione senza dover ricostruire mezza catena.

Per questo il percorso `recovery` usa una `UKI` separata, più flessibile, a cui
`Limine` passa la command line.

La lezione è:

- la recovery non deve essere ottimizzata per il comfort quotidiano;
- deve essere ottimizzata per restituirti controllo.

## 3. Il conflitto tecnico da capire bene

Con `systemd-stub`, se la `UKI` contiene una `.cmdline` e `Secure Boot` è
attivo, gli override della command line vengono ignorati.

Questo è ottimo per il boot normale.
Ma per gli snapshot è scomodo, perché ogni snapshot potrebbe voler bootare con:

- `rootflags=subvol=...`

diverso.

Quindi non è un problema di gusto.
È proprio un conflitto tra due esigenze:

- stabilità del boot normale;
- variabilità della recovery.

## 4. L'errore mentale da evitare

L'errore classico è voler forzare una sola soluzione per tutto.

Questo porta spesso a uno di due risultati:

- o il boot normale diventa più fragile del dovuto;
- o la recovery diventa troppo rigida per essere davvero utile.

Il progetto `Margine` evita questo errore così:

- due percorsi diversi;
- una sola architettura coerente.

## 5. Perché il TPM resta sul percorso prod

`TPM2` è comodissimo quando il boot path è stabile.

Infatti nel percorso `prod` le PCR iniziali sensate sono:

- `7`
- `11`

Questo funziona bene perché la `UKI` è stabile e il contenuto è definito.

Nel percorso `recovery`, invece, la command line può cambiare.
Quindi pretendere lo stesso identico comfort `TPM2` anche lì sarebbe più
fragile che utile.

La lezione importante è:

- non tutte le comodità devono valere in tutti i percorsi.

## 6. Perché questo design è più maturo

È più maturo perché distingue:

- percorso ottimizzato per la frequenza d'uso;
- percorso ottimizzato per il recupero da errore.

Questa è una regola molto generale di architettura:

- il path normale e il path di emergenza non devono per forza essere identici;
- devono essere entrambi chiari.

## 7. La regola finale da ricordare

Se un giorno ti chiedi:

- "perché non semplifichiamo tutto a un unico boot path?"

la risposta giusta è:

- perché semplificare male significa confondere due problemi diversi.

Un buon progetto non cerca di avere "meno pezzi" in astratto.
Cerca di avere:

- pezzi distinti;
- responsabilità chiare;
- recovery umana quando serve davvero.
