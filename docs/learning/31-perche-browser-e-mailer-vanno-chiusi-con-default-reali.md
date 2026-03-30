# Perche' browser e mailer vanno chiusi con default reali

Nel desktop Linux non basta installare un browser e un client mail.

Devi anche dire al sistema:

- chi apre i link web;
- chi apre i link `mailto:`;
- chi apre i calendari o i file email.

## Il problema tipico

Molti sistemi sembrano \"a posto\", ma poi:

- `http` apre l'app giusta;
- `mailto` apre quella sbagliata;
- il desktop file scritto nella config non esiste neppure davvero.

In quel caso il sistema non e' rotto in modo evidente.
E' peggio: e' incoerente.

## La scelta di Margine

`Margine v1` chiude questo punto in modo esplicito:

- `Firefox` e' il browser;
- `Thunderbird` e' il mailer;
- `mimeapps.list` e' il posto dove fissiamo la decisione.

## Perche' non basta dire \"uso Thunderbird\"

Dire \"uso Thunderbird\" non basta.

Bisogna anche usare il suo desktop ID reale.

Su Arch oggi il pacchetto installa:

- `org.mozilla.Thunderbird.desktop`

non un ipotetico:

- `thunderbird.desktop`

Se sbagli questo dettaglio, il repo sembra corretto ma il sistema reale no.

## Perche' non migriamo il profilo mail

Il profilo `Thunderbird` contiene:

- account;
- mail locali;
- indici;
- chiavi;
- cache;
- stato personale.

Questa non e' baseline di sistema.
E' patrimonio utente.

Quindi:

- il pacchetto si installa;
- il default si fissa;
- il profilo si migra solo in modo consapevole, non automaticamente.
