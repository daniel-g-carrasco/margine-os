# ADR 0039 - Rollout staged di Secure Boot e TPM2

## Stato

Accettato

## Contesto

`Margine` vuole arrivare a questo risultato operativo:

- boot normale firmato e verificato con `Secure Boot`;
- root cifrata con `LUKS2`;
- sblocco automatico del path di boot normale tramite `TPM2`;
- path di recovery separato, piu' esplicito e tollerante verso fallback umani.

Il problema e' che questi obiettivi non possono essere compressi in un singolo
passaggio "magico" dell'installer senza aumentare troppo il rischio di:

- sealing TPM2 sui PCR sbagliati;
- enrollment `sbctl` lanciato senza preflight serio;
- rottura di dual boot o catene OEM gia' esistenti;
- stato installato ambiguo, difficile da debuggare.

## Decisione

Per `Margine`, `Secure Boot` e `TPM2` non vengono trattati come una singola
feature monolitica di installazione.

Il rollout corretto viene invece spezzato in fasi:

1. installazione base del sistema;
2. validazione post-install di boot, desktop e update path;
3. preflight `Secure Boot`;
4. bootstrap `sbctl` con macchina in `Setup Mode`;
5. primo reboot di validazione Secure Boot;
6. staging TPM2 (`crypttab.initramfs` + UKI finali);
7. reboot manuale sul path finale;
8. enrollment TPM2 contro lo stato PCR finale;
9. reboot finale e validazione auto-unlock.

## Regola Secure Boot

Il bootstrap `Secure Boot` deve essere preceduto da un preflight esplicito.

Quindi:

- `provision-secure-boot-preflight` esporta le chiavi pubbliche attualmente
  enrollate;
- ispeziona i binari EFI presenti sulla `ESP`;
- lascia un marker persistente sul sistema;
- `provision-secure-boot` rifiuta di procedere se quel marker manca, salvo
  override esplicito.

Questo non elimina tutti i rischi, ma riduce il caso piu' banale e piu'
pericoloso: l'utente che entra in `Setup Mode` e lancia subito l'enrollment
senza avere nemmeno salvato lo stato precedente.

## Regola chiavi firmware e dual boot

Il default prudente resta:

```bash
sbctl enroll-keys -m -f
```

Motivo:

- `-m` aiuta a non rompere Windows e componenti firmati Microsoft;
- `-f` aiuta a non perdere catene OEM builtin del firmware.

Ma questo NON equivale a preservare automaticamente qualunque altra Linux che
usi proprie chiavi custom.

Quindi la policy architetturale e':

- proteggere bene il caso Windows/OEM;
- non promettere la preservazione automatica di chiavi custom terze;
- richiedere valutazione esplicita per host con Secure Boot gia' personalizzato.

## Regola TPM2

Il rollout TPM2 corretto non parte prima che `Secure Boot` sia gia' stabile.

La policy iniziale e':

- enrollment contro `PCR 7+11`;
- pretesa di `Secure Boot` gia' attivo e fuori da `Setup Mode`;
- primo passaggio di staging senza sealing;
- un reboot manuale sul path finale;
- solo dopo, sealing TPM2 vero con `systemd-cryptenroll`.

Questo approccio e' piu' lento, ma molto meno fragile.

## Regola QEMU

La validazione TPM2 in VM non e' considerata reale senza vTPM.

Quindi il harness QEMU deve:

- usare `swtpm` quando disponibile;
- esporre un TPM virtuale al guest;
- dichiarare esplicitamente quando il test TPM2 e' reale e quando invece no.

## Conseguenze

Questa decisione comporta:

- piu' passaggi operativi;
- meno ambiguita';
- documentazione piu' lunga ma piu' onesta;
- migliore separazione tra "installazione riuscita" e "boot security completa".

In pratica:

- l'installer non deve fingersi piu' completo di quanto sia davvero;
- la security di boot deve essere trattata come rollout guidato;
- i controlli post-install devono includere esplicitamente `Secure Boot`,
  `TPM2`, `vTPM` in QEMU, e il caso SSH per debug remoto.
