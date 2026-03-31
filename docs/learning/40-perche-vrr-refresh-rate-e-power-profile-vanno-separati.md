# Perche' VRR, refresh rate e power profile vanno separati

Ci sono tre leve diverse, e mischiarle porta a decisioni confuse.

## 1. Power profile

Il power profile decide come il sistema si comporta lato CPU, firmware e
platform profile.

Nel nostro caso il motore giusto e':

- `power-profiles-daemon`

Lui gestisce cose come:

- `balanced`
- `power-saver`
- `performance`

Questo livello non dice automaticamente a quanti Hz deve stare il pannello.

## 2. Panel power savings / ABM

Sul Framework 13 AMD, `power-profiles-daemon` espone un'azione separata:

- `amdgpu_panel_power`

Il fatto importante e' che il daemon stesso la descrive come qualcosa che puo'
"affect color quality". Per un sistema fotografico, questo basta a giustificare
una baseline prudente: tenere quell'azione disabilitata.

Questa non e' la stessa cosa di scegliere `balanced` o `power-saver`.

## 3. Refresh rate del pannello

Il refresh rate e' un'altra leva ancora.

Dire:

- `60Hz su batteria`
- `120Hz su alimentazione`

non significa "cambiare power profile". Significa cambiare il modo del monitor.

Questa leva e' utile perche' produce un effetto prevedibile sul consumo del
pannello, mentre il profilo energetico da solo non garantisce quel risultato.

## 4. VRR

`VRR` significa Variable Refresh Rate / Adaptive Sync.

E' utile per fluidita' e tearing in scenari compatibili, ma non sostituisce il
passaggio esplicito da `120Hz` a `60Hz`.

Quindi:

- `VRR` non e' il risparmio energetico principale;
- il cambio esplicito `60/120Hz` resta la leva concreta per il laptop;
- il power profile resta un altro livello ancora.

## Decisione pratica di Margine

Per questo `Margine` separa i tre strati:

- `power-profiles-daemon` come motore dei profili energetici;
- `amdgpu_panel_power=false` come baseline prudente per il pannello AMD;
- servizio utente separato per cambiare `60/120Hz`;
- `VRR` solo come supporto opzionale del compositor.
