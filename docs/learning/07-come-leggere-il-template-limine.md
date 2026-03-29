# Come leggere il primo template di Limine

Questa nota accompagna il file:

- [limine.conf.template](/home/daniel/dev/margine-os/files/esp/EFI/BOOT/limine.conf.template)

Lo scopo del template non è essere già "finito".
Lo scopo è fissare la struttura giusta.

## 1. Cosa c'è di statico

Nel template ci sono parti che vogliamo tenere stabili:

- timeout;
- branding;
- entry `Produzione`;
- entry `Fallback`;
- sezione `Recovery`.

Questa è la parte del file che ha senso versionare in Git.

## 2. Cosa invece è variabile

Ci sono due tipi di dati che non vogliamo scrivere a mano ogni volta:

- identificativi macchina, come `UUID`;
- elenco delle entry recovery/snapshot.

Per questo nel template trovi placeholder come:

- `@ROOT_UUID@`
- `@LUKS_UUID@`

e dei marker come:

- `BEGIN MARGINE GENERATED RECOVERY ENTRIES`
- `END MARGINE GENERATED RECOVERY ENTRIES`

La lezione qui è importante:

- versioniamo la struttura;
- generiamo i dati variabili.

## 3. Perché esiste una entry "Recovery manuale"

Serve come baseline minima.

Anche se il generatore snapshot non fosse ancora pronto, vogliamo già avere:

- una `UKI` recovery;
- una entry recovery riconoscibile;
- un posto chiaro dove iniettare la command line.

Questa è una regola molto sana:

- prima costruisci un fallback semplice;
- poi costruisci l'automazione avanzata.

## 4. Perché usiamo `boot():/EFI/Linux`

Perché il config file vive accanto a `Limine` sulla `ESP`, e `Limine`
documenta che `boot():` punta alla partizione da cui viene letto il config.

Quindi:

- `Limine` sta in `EFI/BOOT`;
- le `UKI` stanno in `EFI/Linux`;
- il config le raggiunge con path chiari e leggibili.

## 5. Cosa manca ancora

Mancano ancora tre pezzi fondamentali:

- il generatore del file finale;
- la logica che scopre gli snapshot bootabili;
- gli hook che rigenerano il file dopo update o cambi di snapshot.

Quindi questo file non è "l'ultima tappa".
È il primo punto in cui la strategia di boot diventa concreta.
