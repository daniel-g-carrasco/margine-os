# ADR 0028 - Browser e mail defaults

## Stato

Accettato

## Contesto

`Margine` ha gia' deciso il layer applicativo di base, ma restava da chiudere
in modo esplicito il blocco:

- browser di default;
- mail client di default;
- desktop IDs e MIME reali;
- rapporto tra `Thunderbird` ufficiale ed eventuale `ESR`.

Questa parte va fissata bene, perche' un sistema puo' anche avere i pacchetti
giusti ma restare incoerente nella pratica se:

- i link `mailto:` si aprono nel browser;
- il desktop file referenziato non esiste davvero;
- il progetto lascia ambigua la scelta tra `Thunderbird` e `Thunderbird ESR`.

## Decisione

Per `Margine v1` i default applicativi sono:

- `Firefox` come browser principale;
- `Thunderbird` ufficiale Arch come mail client principale.

I default vengono espressi tramite `mimeapps.list`, non tramite tool
interattivi o stato runtime della macchina sorgente.

## Scelte specifiche

### 1. Browser baseline

`Firefox` resta il browser baseline del progetto.

Motivo:

- e' nei repo ufficiali;
- e' gia' trattato con una baseline moderata via policy di sistema;
- e' coerente con l'obiettivo di avere un sistema riproducibile senza trascinare
  profili personali.

### 2. Mail baseline

`Thunderbird` entra come mail client baseline nella forma del pacchetto ufficiale
Arch.

Motivo:

- e' nei repo ufficiali;
- ha desktop file e integrazione MIME chiari;
- il profilo utente contiene posta, account, chiavi, indici e cache, quindi non
  va confuso con la baseline di sistema.

### 3. Thunderbird ESR

`Thunderbird ESR` NON entra nella baseline `v1`.

Motivo:

- al 2026-03-30 non risulta come pacchetto nei repo ufficiali Arch;
- il progetto privilegia repo ufficiali e riduce al minimo le eccezioni AUR.

Questo non significa che l'`ESR` sia vietato per sempre.
Significa solo che non diventa il default architetturale della `v1`.

Se in futuro la compatibilita' con estensioni o plugin lo rendera' davvero
necessario, verra' trattato come eccezione esplicita e motivata.

### 4. MIME e desktop IDs

La baseline usa i desktop IDs reali dei pacchetti:

- `firefox.desktop`
- `org.mozilla.Thunderbird.desktop`

Per `Thunderbird`, i MIME e handler principali che chiudiamo nella `v1` sono:

- `x-scheme-handler/mailto`
- `x-scheme-handler/mid`
- `x-scheme-handler/webcal`
- `x-scheme-handler/webcals`
- `message/rfc822`
- `text/calendar`
- `text/vcard`
- `text/x-vcard`

### 5. Profilo Thunderbird

Il profilo `~/.thunderbird` NON viene migrato nella `v1`.

Motivo:

- contiene dati personali, non baseline di sistema;
- e' materiale da backup o migrazione consapevole;
- copiarlo in automatico andrebbe contro il modello di migrazione selettiva.

### 6. Policy Thunderbird

`Margine v1` non aggiunge una policy `Thunderbird` separata.

Motivo:

- la baseline del pacchetto Arch e' gia' ragionevole;
- i punti che ci interessano davvero in questa fase sono il pacchetto corretto,
  i MIME/default e la non-migrazione cieca del profilo;
- introdurre una policy in piu' senza un'esigenza chiara aggiungerebbe solo
  complessita' al layer applicativo.

## Conseguenze

### Positive

- i link web e mail finiscono nelle applicazioni giuste;
- il progetto smette di avere ambiguita' tra `Thunderbird` e `ESR`;
- la baseline resta coerente con Arch ufficiale.

### Negative

- chi vuole `Thunderbird ESR` dovra' introdurlo piu' avanti come deviazione
  esplicita;
- il profilo mail personale resta fuori dall'installazione base.

## Per uno studente

Qui la regola e' semplice:

- una cosa e' scegliere un pacchetto;
- un'altra e' farlo diventare davvero il default del desktop;
- un'altra ancora e' non confondere l'app con i dati personali che contiene.

Per questo `Margine` chiude il blocco cosi':

- `Firefox` browser;
- `Thunderbird` mailer;
- `mimeapps.list` come fonte di verita';
- nessuna migrazione cieca del profilo mail.
