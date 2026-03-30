# Perché il color management va trattato come asset più stack

Nel color management ci sono due cose molto diverse.

## 1. Lo stack

Lo stack e' l'insieme degli strumenti:

- `darktable`
- `argyllcms`
- `displaycal`
- `colord`

Questi sono pacchetti, servizi e strumenti.

## 2. Gli asset

Gli asset sono i risultati del tuo lavoro:

- profili ICC;
- stili fotografici;
- eventuali preset ben riusciti.

Questi non sono "configurazione di sistema" in senso puro.
Sono oggetti preziosi prodotti dall'utente.

## Perché questa distinzione conta

Se li mischi, succede questo:

- copi log e database come se fossero importanti;
- non sai piu' quali profili erano quelli giusti;
- il repo smette di spiegare qualcosa.

Se li separi, ottieni:

- stack chiaro e riproducibile;
- asset selezionati e preservati;
- meno rumore.

## Esempio concreto

Nel tuo caso:

- `Darktable` e `ArgyllCMS` fanno parte dello stack;
- il profilo `FW13_140cd_D65_2.2_S.icc` e' un asset;
- i log `DisplayCAL` non sono un asset e non sono stack: sono rumore storico.

## La regola pratica

Nel dubbio:

- i pacchetti si reinstallano;
- i profili ICC buoni si preservano;
- i log si buttano.

