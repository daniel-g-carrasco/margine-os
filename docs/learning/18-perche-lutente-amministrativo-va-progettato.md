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

Per `Margine v1` non usiamo né la baseline minima assoluta né il copia-incolla
cieco della macchina corrente.

Scegliamo invece una baseline da workstation personale:

- `wheel` per l'amministrazione;
- `video` e `render` per GPU, ROCm e OpenCL;
- `kvm` e `libvirt` perché il progetto vuole essere pronto anche per VM e
  container;
- `colord` perché `Margine` nasce con un orientamento forte verso fotografia e
  gestione colore.

La regola didattica non cambia:

- ogni gruppo deve avere un motivo chiaro;
- se un gruppo entra di default, va scritto e spiegato.

Per questo `audio` resta fuori:

- sul sistema reale di partenza non è richiesto per far funzionare PipeWire;
- oggi l'accesso ai device audio passa normalmente da ACL dinamiche.

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

Un buon utente amministrativo non nasce da privilegi buttati a caso.

Nasce da una baseline intenzionale, spiegata e adatta allo scopo della
macchina.
