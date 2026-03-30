# ADR 0024 - Layer versionato delle configurazioni applicative

## Stato

Accettato

## Contesto

Dopo il layer di base, la connettivita' e il desktop, serve decidere come
gestire le applicazioni quotidiane.

Non tutte vanno trattate allo stesso modo:

- alcune si portano quasi pari pari;
- altre e' meglio gestirle con policy;
- altre ancora restano oggetto di review futura.

## Decisione

Per `Margine v1` il layer applicativo versionato include:

- `Neovim` / `LazyVim` come configurazione utente versionata;
- `Kitty` come configurazione utente versionata;
- `mimeapps.list` pulito e normalizzato;
- `user-dirs.*` come baseline italiana;
- `update-all` installato globalmente in `/usr/local/bin/update-all`;
- `update-all-launcher` come piccolo wrapper utente;
- `Firefox` configurato tramite policy di sistema, non tramite profilo copiato.

## Scelte specifiche

### Firefox

`Firefox` viene configurato con `/etc/firefox/policies/policies.json`.

La baseline e' volutamente moderata:

- disabilitazione telemetry;
- disabilitazione studies;
- rimozione Pocket;
- niente prompt sul browser predefinito;
- home semplificata senza elementi sponsorizzati.

Questa e' una baseline "enforced ma non troppo":

- definisce il comportamento base;
- non blocca il browser in modo aziendale;
- non pretende di sostituire la personalizzazione utente.

### Neovim

`LazyVim` entra come configurazione esplicita versionata.

Motivo:

- e' testuale;
- e' leggibile;
- e' davvero parte del workflow quotidiano;
- e' facile da modificare e capire.

### Kitty

`Kitty` viene trattato come config semplice, leggibile e riproducibile.

### MIME e user dirs

Vengono normalizzati, non copiati alla cieca:

- niente `userapp-*` generati;
- niente riferimenti stantii a browser passati;
- default coerenti col sistema target.

## Conseguenze

### Positive

- il comportamento applicativo basilare e' riproducibile;
- il nuovo sistema parte gia' con default sensati;
- le configurazioni piu' personali restano comunque modificabili.

### Negative

- alcune preferenze del browser non verranno replicate 1:1;
- l'import delle estensioni o del profilo Firefox resta fuori dalla `v1`.

## Per uno studente

Qui la regola e' semplice:

- se una configurazione e' chiara e portabile, la versioniamo;
- se un'applicazione ha uno strumento di policy migliore del profilo grezzo,
  usiamo quello;
- se una cosa e' rumorosa o opaca, la rinviamo.

