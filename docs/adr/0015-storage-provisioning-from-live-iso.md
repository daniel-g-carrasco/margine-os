# ADR 0015 - Provisioning storage da live ISO

## Stato

Accettato

## Perché esiste questo ADR

Con ADR 0014 abbiamo separato:

- fase live ISO
- fase chroot

Mancava però il passo ancora precedente:

- preparare davvero lo storage target.

## Problema da risolvere

Per installare `Margine` da zero servono operazioni molto delicate:

- creare la tabella GPT;
- creare la `ESP`;
- preparare `LUKS2`;
- creare il filesystem `Btrfs`;
- creare i subvolumi;
- montare il layout target in modo coerente con il progetto.

Se questo passaggio resta manuale o implicito, il bootstrap resta incompleto.

## Decisione

Per `Margine v1`, il provisioning storage sarà gestito da uno script separato
da eseguire dalla live ISO.

Lo script deve:

1. operare su un disco esplicitamente indicato;
2. richiedere una conferma distruttiva esplicita;
3. creare `GPT + ESP + LUKS2 + Btrfs`;
4. creare i subvolumi leggendo il manifest del progetto;
5. montare il target pronto per il bootstrap live ISO.

## Regola di distruttività

Lo script è distruttivo per design.

Per questo, in `Margine v1`, non parte mai senza un flag esplicito di conferma.

Non sono ammessi:

- autodetect del disco;
- "best guess" sul target corretto;
- esecuzione silenziosa su device non confermati.

## Regola partizioni

Lo schema adottato è quello già deciso da ADR 0003:

- partizione 1: `ESP` FAT32 da `4 GiB`
- partizione 2: resto del disco in `LUKS2`

## Regola filesystem

Dentro `LUKS2` si crea un solo filesystem `Btrfs`.

I subvolumi vengono creati leggendo `manifests/storage-subvolumes.txt`.

Questo evita che lo script e il documento architetturale divergano.

## Regola mount

Il target finale viene montato così:

- `@` su `/`
- altri subvolumi sui rispettivi mountpoint
- `ESP` su `/boot`

Le mount options di base sono coerenti con ADR 0003:

- `rw`
- `relatime`
- `compress=zstd:3`
- `ssd`

## Regola di ambito

In `Margine v1`, questo script non fa ancora:

- enrollment `TPM2`
- installazione del bootloader
- configurazione finale di `crypttab`
- partizionamento avanzato o multi-disk
- ibernazione

Fa una cosa sola:

- prepara bene il disco per il bootstrap successivo.

## Conseguenze pratiche

Questa scelta ci dà:

- uno storage path ripetibile;
- coerenza tra ADR, manifest e script;
- meno rischio di errori manuali;
- una base forte per l'installazione completa.

## Per uno studente: la versione semplice

Pensa così:

- prima prepari il terreno;
- poi costruisci la casa.

Lo storage provisioning è il momento in cui prepari il terreno.
