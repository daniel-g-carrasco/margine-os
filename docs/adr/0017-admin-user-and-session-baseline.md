# ADR 0017 - Utente amministrativo e baseline sessione

## Stato

Accettato

## Perché esiste questo ADR

Fino a questo punto il bootstrap di `Margine` arrivava a:

- storage pronto;
- sistema base installato;
- servizi principali abilitati.

Mancava però una cosa fondamentale:

- un utente amministrativo davvero usabile.

## Problema da risolvere

Un sistema non è davvero pronto se si ferma a:

- `root`;
- pacchetti installati;
- hostname e locale configurati.

Serve anche:

- un utente amministrativo;
- `sudo` configurato bene;
- gruppi scelti in modo ragionato;
- prime directory utente coerenti.

## Decisione

Per `Margine v1` introduciamo:

- il pacchetto `sudo` nella base;
- un template versionato per `/etc/sudoers.d/10-margine-wheel`;
- uno script dedicato `scripts/provision-system-user`;
- integrazione del provisioning utente dentro `bootstrap-in-chroot`.

## Regola amministrativa

L'utente creato da questo flow è un utente amministrativo moderno:

- appartiene a `wheel`;
- usa `sudo` con password;
- non riceve `NOPASSWD` di default.

## Regola gruppi

La baseline non copia i gruppi dell'utente corrente alla cieca.

In `Margine v1` la baseline amministrativa è:

- `wheel`
- `video`
- `render`
- `kvm`
- `libvirt`
- `colord`

Più eventuali gruppi espliciti passati via argomento.

Motivazione:

- `wheel` serve all'amministrazione via `sudo`;
- `video` e `render` coprono la baseline workstation per GPU e stack
  AMD/ROCm/OpenCL;
- `kvm` e `libvirt` evitano che il primo uso di VM e virtualizzazione cada su
  problemi di permessi inutili;
- `colord` è coerente con un profilo macchina orientato anche a fotografia e
  gestione colore.

`audio` non entra di default:

- sulla macchina di riferimento il sottosistema audio funziona già tramite ACL
  moderne su `/dev/snd`;
- aggiungerlo senza necessità reale allargherebbe la baseline senza un guadagno
  concreto.

Non entrano comunque di default gruppi storici come `network` o `storage`,
perché qui non aggiungono un vantaggio chiaro.

## Regola password

Lo script accetta opzionalmente un hash password.

Se l'hash non viene fornito:

- l'utente viene creato comunque;
- ma resta necessario un `passwd` manuale prima del login normale.

Questa scelta evita di obbligare il progetto a trattare password in chiaro.

## Regola sessione

In questo ADR chiudiamo solo la baseline minima:

- utente;
- `sudo`;
- `xdg-user-dirs`;
- servizi base di sistema.

Il login path finale viene invece chiuso da ADR successivi:

- `greetd`;
- `tuigreet` come fallback;
- autologin iniziale dell'utente principale;
- `hyprlock` come lockscreen immediata all'ingresso sessione.

## Conseguenze pratiche

Questa scelta ci dà:

- un bootstrap che produce davvero un sistema amministrabile;
- una baseline più pulita e moderna;
- meno accoppiamento tra provisioning utente e login path finale;
- una base coerente su cui agganciare il provisioning della sessione.

## Per uno studente: la versione semplice

Un sistema installato non è ancora un sistema pronto.

Diventa pronto quando puoi:

- entrare con il tuo utente;
- usare `sudo`;
- avere una home coerente;
- partire da regole semplici e comprensibili.
