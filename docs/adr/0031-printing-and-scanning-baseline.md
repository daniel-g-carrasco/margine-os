# ADR 0031 - Baseline stampa e scanner

## Stato

Accettato

## Contesto

`Margine` deve gestire bene:

- stampanti di rete moderne;
- multifunzione USB moderne;
- scanner di rete o integrati in dispositivi `IPP/eSCL`;
- gestione semplice senza introdurre subito driver vendor-specifici.

Serve quindi decidere:

- quale stack usare per la stampa;
- quale stack usare per gli scanner;
- come gestire discovery e naming locale;
- quali strumenti offrire per la gestione quotidiana.

## Decisione

Per `Margine v1` adottiamo una baseline `driverless-first`:

- `CUPS` per la stampa;
- `cups-filters` e `ghostscript` come supporto pratico di conversione;
- `Avahi + nss-mdns` per discovery e risoluzione `mDNS/DNS-SD`;
- `ipp-usb` per i dispositivi USB moderni che espongono `IPP over USB`;
- `SANE` per il layer scanner;
- `sane-airscan` per scanner `eSCL/WSD` e multifunzione moderni;
- `system-config-printer` come strumento principale di gestione stampanti;
- `simple-scan` come frontend scanner semplice.

## Perche' questa scelta

Il criterio e' coerente col resto del progetto:

- preferire standard aperti e diffusi;
- preferire pacchetti ufficiali Arch;
- evitare stack vendor-specifici finche' non servono davvero;
- separare motore, discovery e interfaccia.

### Lato stampa

Qui i pezzi sono:

- `CUPS` come scheduler di stampa;
- `Avahi` per scoprire code e dispositivi in rete;
- `ipp-usb` per parlare `IPP` anche a dispositivi USB moderni.

Questa base copre bene il caso piu' comune di oggi:

- `IPP Everywhere`
- AirPrint
- Mopria

### Lato scanner

Qui i pezzi sono:

- `SANE` come backend generale;
- `sane-airscan` per dispositivi di rete moderni e multifunzione.

## Discovery locale

Per far funzionare bene la discovery locale con `Avahi`, `Margine` aggiorna la
linea `hosts:` di `/etc/nsswitch.conf` per includere `mdns_minimal
[NOTFOUND=return]`, senza sovrascrivere l'intero file.

## Gestione quotidiana

Per `Margine v1` il percorso consigliato e':

- `system-config-printer` per aggiungere e modificare stampanti;
- `simple-scan` per la scansione di base;
- `http://localhost:631` come interfaccia CUPS di supporto, non come metodo
  primario.

## Servizi abilitati

La baseline abilita:

- `cups.socket`
- `avahi-daemon.service`
- `avahi-daemon.socket`
- `ipp-usb.service`

## Cosa non entra nella v1

Per ora non entrano nella baseline:

- driver vendor-specifici per vecchie stampanti;
- backend scanner proprietari;
- condivisione server-side avanzata di scanner (`saned`);
- code di stampa preconfigurate per modelli specifici.

## Conseguenze

### Positive

- baseline semplice, moderna e riproducibile;
- buona copertura per stampanti/scanner moderni;
- gestione coerente con il resto del sistema GTK/Wayland.

### Negative

- alcuni dispositivi vecchi potrebbero richiedere pacchetti extra;
- il path `driverless-first` non copre tutto il parco hardware esistente.

## Per uno studente

La lezione qui e' questa:

- stampare non significa solo installare `cups`;
- scansionare non significa solo installare `simple-scan`;
- discovery, backend e interfaccia sono tre livelli diversi.
