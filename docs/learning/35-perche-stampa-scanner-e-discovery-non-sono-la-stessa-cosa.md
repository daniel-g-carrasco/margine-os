# Perche' stampa, scanner e discovery non sono la stessa cosa

Molte persone pensano che basti dire:

- "mi serve la stampante"

oppure:

- "mi serve lo scanner"

In realta' ci sono piu' pezzi diversi.

## I quattro livelli veri

Quando parli di stampante o scanner, in pratica stai mettendo insieme:

1. il motore di stampa
2. il motore di scansione
3. la discovery in rete locale
4. l'interfaccia che usi davvero

## Esempio lato stampa

Per stampare bene con dispositivi moderni, in `Margine` i ruoli sono questi:

- `CUPS` = motore di stampa
- `Avahi + nss-mdns` = discovery e risoluzione in rete locale
- `ipp-usb` = ponte per i dispositivi USB moderni che parlano IPP
- `system-config-printer` = interfaccia di gestione

## Esempio lato scanner

Per gli scanner la logica e' simile:

- `SANE` = backend generale
- `sane-airscan` = supporto pratico ai dispositivi `eSCL/WSD`
- `simple-scan` = interfaccia semplice per l'utente

## Perche' la discovery conta

Un errore comune e' installare `cups` e poi chiedersi perche' la stampante di
rete o lo scanner di rete non compaiono bene.

Spesso manca proprio il livello discovery:

- `Avahi`
- `nss-mdns`

## La scelta di Margine

`Margine v1` sceglie una baseline `driverless-first`.

Questo vuol dire:

- prima standard moderni e pacchetti ufficiali;
- poi eventuali driver speciali solo se un caso reale lo richiede.
