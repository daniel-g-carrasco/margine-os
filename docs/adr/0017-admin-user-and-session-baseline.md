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

Più eventuali gruppi espliciti passati via argomento.

Motivazione:

- `wheel` serve all'amministrazione via `sudo`;
- `video` e `render` sono una baseline sensata per il profilo AMD/ROCm/OpenCL
  di `Margine`.

Non entrano di default:

- `audio`
- `kvm`
- `libvirt`
- `colord`
- gruppi storici come `network` o `storage`

perché richiedono una giustificazione più specifica di layer o workflow.

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

Non chiudiamo ancora:

- display manager finale;
- autologin;
- scelta definitiva tra `greetd`, TTY o altro.

## Conseguenze pratiche

Questa scelta ci dà:

- un bootstrap che produce davvero un sistema amministrabile;
- una baseline più pulita e moderna;
- meno accoppiamento tra provisioning utente e scelta del login manager.

## Per uno studente: la versione semplice

Un sistema installato non è ancora un sistema pronto.

Diventa pronto quando puoi:

- entrare con il tuo utente;
- usare `sudo`;
- avere una home coerente;
- partire da regole semplici e comprensibili.
