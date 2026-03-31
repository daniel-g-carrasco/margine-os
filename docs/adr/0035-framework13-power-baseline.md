# ADR 0035: Framework 13 AMD power baseline

## Stato

Accettato

## Contesto

Sul Framework 13 AMD ci interessano due obiettivi diversi:

- buona autonomia reale da laptop;
- resa colore prevedibile per un sistema orientato anche alla fotografia.

Nel runtime reale `Margine` ha gia' validato:

- `power-profiles-daemon` con `amd_pstate` e `platform_profile`;
- pannello interno a `2880x1920@120`;
- `amdgpu_panel_power` esposto da `power-profiles-daemon` come azione
  separata, con nota esplicita "may affect color quality";
- `battery_aware` gia' disponibile dentro `power-profiles-daemon`.

Questo cambia il quadro: non serve introdurre un secondo demone che riscriva
senza sosta il profilo CPU. Serve invece rendere esplicita una policy minima,
leggibile e persistente.

## Decisione

`Margine v1` adotta questa baseline power per Framework 13 AMD:

- `power-profiles-daemon` resta il motore ufficiale dei profili energetici;
- `battery_aware=true`;
- profilo base salvato: `balanced`;
- `amdgpu_panel_power=false`;
- `amdgpu_dpm=false`;
- il cambio `60/120Hz` del pannello interno viene trattato separatamente, con
  un servizio utente dedicato nel desktop layer;
- `VRR` e cambio esplicito del refresh rate non vengono confusi: il primo resta
  un supporto best-effort del monitor, il secondo e' lo strumento concreto per
  l'autonomia.

La policy viene versionata come stato iniziale di
`/var/lib/power-profiles-daemon/state.ini`.

## Conseguenze

Positive:

- il comportamento power non resta implicito nello stato locale della macchina;
- la mitigazione per il pannello AMD che puo' alterare i colori diventa parte
  del progetto;
- non introduciamo un watcher aggressivo che sovrascrive le scelte manuali
  dell'utente sui profili CPU.

Negative:

- la baseline si appoggia a `power-profiles-daemon`, quindi la persistenza e'
  modellata sul suo `state.ini`;
- se in futuro cambiera' il formato dello stato di `power-profiles-daemon`,
  questo layer andra' rivisto.

## Nota operativa

Sul sistema reale corrente `power-profiles-daemon` e' attivo e la policy risulta
gia' coerente, ma il servizio non e' ancora `enabled` al boot. Questo e'
un dettaglio della macchina corrente, non del bootstrap di `Margine`, che invece
abilita gia' il servizio di base.
