# Perché uno snapshot bootabile non è un rollback completo

Vedere uno snapshot nel menu di boot e' molto potente.

Ma e' facile farsi ingannare e pensare:

- "allora il sistema puo' sempre tornare indietro da solo".

Non e' cosi'.

## Cosa fa davvero uno snapshot bootabile

Ti permette di:

- avviare uno stato precedente del root filesystem;
- ispezionarlo;
- capire cosa si e' rotto;
- usare quello stato come base per un rollback consapevole.

Questo e' tantissimo, ma non e' tutto.

## Cosa NON fa da solo

Non riallinea automaticamente:

- la `ESP`;
- le firme EFI;
- le `UKI`;
- lo stato esterno a Btrfs;
- eventuali side effect di aggiornamenti firmware o pacchetti.

Quindi uno snapshot bootabile e':

- un ottimo punto di recupero;
- non una bacchetta magica.

## Perché in Margine usiamo la recovery UKI

Quando booti uno snapshot da menu, il tuo obiettivo non dovrebbe essere:

- "continuare come se nulla fosse".

Dovrebbe essere:

- "entrare in un ambiente leggibile e sicuro per capire il problema".

Per questo `Margine` usa la `UKI` di recovery e monta lo snapshot in `ro`.

## La regola semplice

Uno snapshot bootabile serve a recuperare bene.
Il rollback completo richiede ancora una pipeline coerente.

