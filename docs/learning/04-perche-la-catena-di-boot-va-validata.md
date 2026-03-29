# Perché la catena di boot va validata, non solo assemblata

Questa nota spiega il senso dell'ADR 0004.

Quando si leggono in fila queste parole:

- `Limine`
- `UKI`
- `Secure Boot`
- `TPM2`
- `LUKS2`
- `Snapper`

si rischia di fare un errore mentale molto comune:

- pensare che basti "mettere insieme i pezzi".

Non basta.

## 1. Una catena è forte quanto il suo punto più fragile

Un sistema del genere ha almeno tre obiettivi contemporanei:

- avviare bene;
- proteggere bene;
- recuperare bene.

Se ne fallisce uno, il progetto peggiora anche se gli altri due sembrano forti.

Esempio:

- se il boot è comodo ma `Secure Boot` è improvvisato, la sicurezza è debole;
- se la sicurezza è forte ma gli update rompono sempre `TPM2`, la manutenzione è
  cattiva;
- se la recovery è teorica ma nessuno osa usarla, non è vera recovery.

## 2. Perché partiamo da UKI

Una `UKI` è utile perché mette in un solo oggetto firmabile:

- kernel
- initramfs
- command line

La lezione importante è questa:

- meno file critici sparsi nel boot path significa meno ambiguità.

Se firmi un oggetto unico, la trust chain diventa più leggibile.

## 3. Perché ci interessa così tanto la command line incorporata

La kernel command line non è un dettaglio decorativo.
Può cambiare il comportamento del sistema in modo reale.

Se la lasci troppo libera:

- la catena di fiducia si complica;
- i PCR diventano più delicati;
- la ripetibilità del boot peggiora.

Per questo, nella prima validazione, la scelta sana è:

- command line incorporata nella `UKI`.

Non perché sia l'unico modo possibile.
Perché è il modo più disciplinato da cui partire.

## 4. Perché `TPM2` non va legato a PCR a caso

Qui c'è una lezione molto importante.

Il TPM non è "magia che sblocca il disco".
Il TPM sblocca il disco solo se lo stato misurato della macchina corrisponde a
quello che hai deciso di considerare valido.

Quindi il problema non è:

- "uso TPM sì o no?"

Il problema vero è:

- "a cosa lego il TPM?"

Per `Margine v1`, la partenza sensata è:

- `PCR 7`
- `PCR 11`

Perché:

- `PCR 7` segue lo stato di `Secure Boot` e dei certificati;
- `PCR 11` segue il contenuto della `UKI`.

Invece partire subito con PCR come `0` o `2` sarebbe più fragile, perché lì
entrano più facilmente firmware e componenti hardware che cambiano durante la
vita reale della macchina.

## 5. Perché la recovery key viene prima del TPM

Questa è una regola di maturità tecnica:

- prima prepari il fallback umano;
- poi aggiungi l'automazione comoda.

Ordine corretto:

1. passphrase amministrativa
2. recovery key
3. TPM2

Se inverti questo ordine, stai costruendo comodità prima della sicurezza
operativa.

## 6. Perché gli snapshot bootabili sono un vero test architetturale

Gli snapshot bootabili non sono una decorazione.

Sono il punto in cui si incontrano:

- filesystem
- bootloader
- politica di recovery
- fiducia nel sistema

Se funzionano male, `Limine` perde gran parte del motivo per cui lo abbiamo
scelto.

Per questo nel progetto non diremo mai:

- "più o meno gli snapshot ci sono"

Diremo invece:

- si bootano davvero;
- sai riconoscere cosa hai bootato;
- sai tornare indietro senza panico.

## 7. Perché validiamo per gate

Validare per gate significa non confondere i problemi.

Esempio:

- se fallisce `TPM2`, non vogliamo chiederci anche se il problema sia `Snapper`;
- se fallisce `Secure Boot`, non vogliamo ancora avere in mezzo tre kernel, due
  boot path e addon vari.

Ogni gate isola una domanda chiara.

Questa è la vera ragione per cui un progetto complesso resta leggibile.

## 8. La lezione da portare a casa

Montare tanti pezzi avanzati non significa avere un'architettura avanzata.

Hai davvero un'architettura quando puoi rispondere bene a queste domande:

- cosa stiamo fidando?
- cosa stiamo misurando?
- cosa succede dopo un update?
- come rientro se qualcosa si rompe?

Se sai rispondere a queste quattro domande, allora stai già ragionando da
progettista e non solo da utente.
