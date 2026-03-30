# ADR 0025 - Entry recovery di Limine generate da snapshot Snapper

## Stato

Accettato

## Contesto

Il progetto aveva gia':

- `Snapper`;
- `Limine`;
- `UKI` separate per produzione, fallback e recovery;
- un template `limine.conf`.

Mancava ancora il punto decisivo:

- trasformare gli snapshot `Snapper` in entry realmente bootabili nel menu.

## Decisione

`Margine v1` genera automaticamente, durante il flusso `update-all`, un blocco
di entry `Limine` a partire dagli snapshot del config `Snapper` root.

Le entry snapshot:

- puntano alla `UKI` di recovery;
- bootano lo snapshot come root Btrfs specificando `rootflags=subvol=...`;
- usano `systemd.unit=multi-user.target`;
- partono in `ro`, non in `rw`.

## Motivazione

### Perché usare la recovery UKI

Per uno snapshot bootabile ci interessa prima di tutto:

- ispezionare;
- recuperare;
- fare rollback consapevole.

La `UKI` di recovery e' piu' adatta di quella di produzione per questo scopo.

### Perché `ro`

Uno snapshot `Snapper` standard nasce per essere trattato come punto di
riferimento sicuro.

Bootarlo in `ro` riduce il rischio di:

- trasformarlo accidentalmente in un ambiente mutabile;
- confondere "ispezione" con "sistema tornato operativo".

## Regola importante

Uno snapshot bootabile NON equivale automaticamente a rollback completo.

Resta vero quanto gia' deciso:

- la `ESP` non e' dentro Btrfs snapshot;
- dopo un rollback la pipeline di boot puo' dover essere riallineata;
- lo snapshot bootabile serve a recuperare e decidere, non a fare magia.

## Comportamento atteso

Nel menu `Limine` restano:

- `Produzione`
- `Fallback`
- `Recovery manuale`

in piu' compaiono:

- le ultime entry snapshot generate da `Snapper`.

## Conseguenze

### Positive

- il recovery diventa davvero visibile al boot;
- il percorso e' coerente con la direzione `Limine-first`;
- `update-all` puo' rigenerare il menu in modo deterministico.

### Negative

- il rollback completo non e' ancora automatico;
- la presenza delle entry dipende da uno stato sano di `Snapper`.

## Per uno studente

Il punto chiave e' questo:

- `Snapper` conserva stati del root;
- `Limine` li espone come punti di ingresso;
- tu puoi bootare uno snapshot e usarlo per capire o ripristinare;
- ma la coerenza finale del boot path resta responsabilita' della pipeline di
  `Margine`.

