# Perché l'utente amministrativo va progettato

## Il punto importante

Creare un utente non è solo lanciare `useradd`.

Stai decidendo:

- come amministrerai la macchina;
- quanto sarà leggibile la configurazione;
- quanto sarà facile capire i permessi nel tempo.

## L'errore classico

L'errore classico è questo:

- aggiungere l'utente a molti gruppi "per sicurezza";
- non sapere più perché quei gruppi esistono;
- ritrovarsi con permessi troppo larghi.

## La scelta di Margine

Per `Margine v1` partiamo da una regola severa:

- l'utente amministrativo sta in `wheel`;
- il profilo grafico AMD/OpenCL aggiunge `video` e `render`;
- gli altri gruppi entrano solo se giustificati.

Questo significa anche saper dire dei no:

- `audio` non entra di default;
- `kvm` non entra di default;
- `libvirt` non entra di default;
- `colord` non entra di default.

Questo è più didattico e più pulito.

## Perché usiamo un file sudoers versionato

Perché `sudo` è parte dell'architettura operativa.

Se lo lasci implicito, un giorno non ricorderai più:

- se il comportamento era stock;
- se lo hai modificato;
- dove l'hai modificato.

Con un file versionato, la regola è chiara e tracciabile.

## Perché l'hash password è opzionale

Perché un installer riproducibile non deve spingerti a scrivere password in
chiaro dentro i comandi o nei documenti.

L'hash è un compromesso tecnico ragionevole:

- automazione quando serve;
- nessuna password in chiaro nella repo.

## La regola mentale da ricordare

Un buon utente amministrativo non nasce da privilegi accumulati.

Nasce da una baseline minima, chiara e intenzionale.
