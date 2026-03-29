# Come funziona il bootstrap di Secure Boot

## L'idea di fondo

Quando installi `Margine` su una macchina nuova, ci sono due momenti diversi:

1. il momento in cui insegni al firmware di quali chiavi fidarsi;
2. il momento in cui firmi davvero i file che il firmware dovrà avviare.

Questi due momenti sono collegati, ma non sono la stessa cosa.

## Primo momento: fiducia nel firmware

Con `sbctl` facciamo tre cose:

1. controlliamo lo stato attuale;
2. creiamo la gerarchia di chiavi;
3. enrolliamo le chiavi nel firmware.

La gerarchia è questa:

- `PK`
- `KEK`
- `db`

Non devi ricordare tutti i dettagli adesso.
Ti basta sapere che è la catena standard di `Secure Boot`.

## Perché serve Setup Mode

Il firmware non accetta nuove chiavi arbitrarie in qualsiasi momento.

Prima devi portarlo in `Setup Mode`.

In pratica, il flusso corretto è:

1. riavvio nel firmware;
2. sezione Secure Boot;
3. cancellazione delle chiavi correnti oppure almeno della `PK`;
4. ritorno in Linux;
5. esecuzione del bootstrap `sbctl`.

## Perché usiamo -m

`sbctl` raccomanda di includere i certificati Microsoft durante l'enrollment.

Questo non significa "delegare tutto a Microsoft".
Significa semplicemente evitare di rompere componenti firmware o Option ROM che
si aspettano anche quelle firme.

Quindi per `Margine v1` il default prudente è:

```bash
sbctl enroll-keys -m
```

## Perché non mettiamo subito le chiavi sbctl nel TPM

Perché in `Margine v1` il `TPM` ci serve già per una cosa molto importante:

- aiutare lo sblocco di `LUKS2`.

Se in questa fase mettiamo nel `TPM` anche il modello di storage delle chiavi
`sbctl`, aumentiamo la complessità senza un guadagno chiaro per la prima
versione.

Per questo partiamo con:

- chiavi `sbctl` come file;
- root cifrata con `LUKS2`;
- `TPM2` concentrato sul path di sblocco disco.

## Dove entra refresh-efi-trust

Una volta che il firmware si fida delle nostre chiavi, dobbiamo firmare davvero
i file di boot.

Lì entra in gioco:

- `refresh-efi-trust`

che fa:

1. hash di `limine.conf`;
2. `limine enroll-config`;
3. firma di `BOOTX64.EFI`;
4. firma delle `UKI`;
5. verifica finale.

## La regola mentale giusta

Il bootstrap di `Secure Boot` non è "aggiornare il sistema".

È "preparare il firmware a fidarsi del sistema".

Per questo non lo mettiamo dentro `update-all`.

## Come modificarlo in futuro

Le scelte modificabili sono:

- usare o meno `-m`;
- esportare o meno le chiavi;
- usare in futuro chiavi `TPM` per `sbctl`;
- aggiungere ulteriori certificati OEM o custom.

La cosa che non va confusa è la separazione dei momenti:

- prima si costruisce la fiducia;
- poi si firmano i file.
