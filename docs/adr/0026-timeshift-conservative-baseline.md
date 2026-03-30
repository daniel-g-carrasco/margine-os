# ADR 0026 - Baseline conservativa di Timeshift in Margine

## Stato

Accettato

## Contesto

`Margine` installa anche `Timeshift`, ma l'architettura del progetto e'
costruita intorno a:

- `Btrfs`
- `Snapper`
- `Limine`
- `UKI`

Questo significa che `Timeshift` non puo' essere trattato come motore
principale del rollback senza creare ambiguita'.

In piu' c'e' un vincolo importante: la documentazione ufficiale di `Timeshift`
indica che il supporto Btrfs e' limitato ai layout di tipo Ubuntu con soli
subvolumi `@` e `@home`.

`Margine` invece usa un layout piu' ricco, con ulteriori subvolumi dedicati.

## Decisione

Per `Margine v1` adottiamo una baseline conservativa:

- `Timeshift` resta installato;
- viene versionato un `default.json` pulito e senza UUID macchina-specifici;
- `btrfs_mode` resta disabilitato nei default;
- gli snapshot automatici `Timeshift` restano disabilitati di default;
- la scelta del backup device resta esplicita e successiva all'installazione.

## Motivazione

### 1. Evitare configurazioni ufficialmente non supportate

Non vogliamo preconfigurare `Timeshift` in una modalita' che la documentazione
ufficiale dichiara fuori supporto per layout Btrfs diversi da `@/@home`.

### 2. Evitare doppio motore automatico di rollback

Se `Snapper` e' il motore principale per:

- snapshot di sistema;
- recovery da update;
- entry bootabili via `Limine`;

allora `Timeshift` non deve fare finta di essere la stessa cosa.

### 3. Tenere Timeshift come strumento complementare

`Timeshift` puo' restare utile come strumento:

- manuale;
- di familiarita' per l'utente;
- eventualmente orientato a `rsync` su target separato.

## Conseguenze

### Positive

- niente UUID ereditati dalla macchina sorgente;
- niente preconfigurazione fragile o fuorviante;
- coerenza chiara: `Snapper` prima, `Timeshift` come extra.

### Negative

- `Timeshift` non parte subito come sistema di snapshot automatici;
- l'utente dovra' scegliere in seguito il backup device se vorra' usarlo.

## Per uno studente

Qui il punto didattico e' importante:

- installare un pacchetto non significa doverlo rendere il pezzo centrale del
  progetto;
- se un tool ha limiti strutturali rispetto alla tua architettura, e' meglio
  usarlo in modo prudente che forzarlo.

