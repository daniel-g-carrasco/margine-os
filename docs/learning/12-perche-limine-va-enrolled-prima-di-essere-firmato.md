# Perché Limine va "enrolled" prima di essere firmato

## Il problema in una frase

`limine enroll-config` modifica il binario `BOOTX64.EFI`.

Se tu firmi prima e modifichi dopo, la firma non corrisponde più al contenuto
del file.

## Che cosa fa davvero enroll-config

Il comando:

```bash
limine enroll-config <bootloader.efi> <blake2b-di-limine.conf>
```

scrive dentro il binario EFI di Limine l'hash `BLAKE2B` del file
`limine.conf`.

Questo serve a fare una cosa precisa:

- impedire che qualcuno modifichi `limine.conf` senza che Limine se ne accorga.

## Perché non basta firmare solo il bootloader

Se firmi solo `BOOTX64.EFI`, ma lasci la config libera di cambiare, hai ancora
un punto debole:

- il firmware si fida del binario;
- il binario però potrebbe leggere una config alterata.

Il meccanismo di `enroll-config` chiude proprio questo buco.

## L'ordine corretto

L'ordine corretto è:

1. copiare `BOOTX64.EFI` sulla `ESP`;
2. copiare `limine.conf` sulla `ESP`;
3. calcolare l'hash di quel `limine.conf`;
4. eseguire `limine enroll-config` sul `BOOTX64.EFI` già deployato;
5. firmare il `BOOTX64.EFI` risultante;
6. firmare le `UKI`;
7. verificare tutto con `sbctl verify`.

## Perché usiamo il file sulla ESP e non quello di staging

Perché il firmware non boota il file di staging.
Boota il file sulla `ESP`.

Quindi la catena di fiducia deve essere costruita sul file finale, non su una
copia intermedia.

## La regola pratica da ricordare

Quando cambia `limine.conf`, non basta ricopiare il file.

Devi anche:

1. aggiornare l'hash dentro `BOOTX64.EFI`;
2. rifirmare `BOOTX64.EFI`.

## Come si collega a Margine

In `Margine` questo diventa un flusso esplicito:

- `deploy-boot-artifacts` installa i file;
- `refresh-efi-trust` allinea hash e firme;
- `update-all` orchestra il tutto.

## Se vuoi modificare il comportamento in futuro

Le leve vere sono queste:

- il path del `BOOTX64.EFI`;
- il path del `limine.conf`;
- quali `UKI` firmare;
- se il refresh della trust chain è automatico o manuale.

Quello che non va cambiato alla leggera è l'ordine logico:

`deploy -> enroll-config -> sign -> verify`
