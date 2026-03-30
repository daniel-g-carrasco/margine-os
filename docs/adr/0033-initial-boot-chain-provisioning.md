# ADR 0033 - Provisioning iniziale della boot chain

## Stato

Accettato

## Problema

`Margine` aveva gia':

- storage provisioning;
- bootstrap live ISO;
- bootstrap in chroot;
- generazione `limine.conf`;
- deploy e refresh della trust chain per gli aggiornamenti.

Mancava pero' un pezzo fondamentale: il primo provisioning della boot chain
durante l'installazione iniziale.

Senza questo passaggio, il progetto poteva installare il sistema ma non
chiudere davvero il boot path `Limine + UKI`.

## Decisione

Introduciamo un provisioner dedicato:

- `provision-initial-boot-chain`

Questo script, eseguito nella fase chroot, deve:

1. installare la baseline `mkinitcpio`;
2. renderizzare `/etc/kernel/cmdline` con gli UUID reali del target;
3. generare tre `UKI`:
   - produzione
   - fallback
   - recovery
4. renderizzare `limine.conf`;
5. installare `Limine` sulla `ESP`;
6. eseguire `limine enroll-config`.

## Conseguenze

- l'installazione iniziale diventa davvero bootabile con `Limine`;
- i test end-to-end in VM diventano finalmente sensati;
- la parte `Secure Boot` resta separata:
  il bootstrap iniziale installa la boot chain, ma non forza ancora
  l'enrollment delle chiavi firmware.
