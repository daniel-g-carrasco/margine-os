# Validazione runtime reale - 2026-03-30

## Scope

Questa review copre:

- power management
- resume/suspend
- fingerprint
- audio
- rete/VPN/Bluetooth
- screenshot/recording

## Risultati principali

### Power

Stato osservato:

- profilo `power-profiles-daemon`: `balanced`
- monitor interno: `2880x1920@120Hz`
- `amd_pstate`: `active`
- `amdgpu abmlevel`: `-1`
- batteria durante il check: circa `18.3 W` di drain a `72%`

Conclusione:

- il sistema funziona, ma non e' ancora in una forma "ottimizzata laptop" lato
  autonomia;
- il refresh a `120Hz` su batteria e' il candidato piu' evidente a tuning
  futuro;
- l'ABM non e' ancora trasformato in una policy esplicita di progetto.

### Suspend / Resume / Fingerprint

Risultati osservati:

- `hypridle` e `hyprlock` sono cablati;
- il hook `/etc/systemd/system-sleep/fprintd-reset` e' presente;
- nei log compaiono ancora errori `fprintd` al momento del suspend:
  `Cannot run while suspended`;
- dopo il resume, pero', `NetworkManager` torna su correttamente e il hook
  riporta `fprintd` in uno stato utilizzabile.

Conclusione:

- la mitigazione c'e' ed e' sensata;
- il problema di fondo esiste davvero e giustifica il hook;
- resta utile un test manuale lungo per confermare il comportamento di
  `hyprlock` dopo molte ore di idle.

### Audio

Risultati osservati:

- `pipewire`, `pipewire-pulse` e `wireplumber` sono attivi;
- `Easy Effects` e' in uso sul sink analogico interno `Ryzen HD Audio Controller`;
- il preset audio sul Framework e' quindi attivo nel workflow reale.

Nota:

- il servizio utente `easyeffects.service` non e' attivo come unit,
  ma il processo applicativo e' in esecuzione.

Conclusione:

- il blocco audio e' sano;
- in `Margine` conviene continuare a distinguere bene tra preset/provisioning e
  "app sempre lanciata".

### Rete, VPN e Bluetooth

Risultati osservati:

- `NetworkManager + iwd` funzionano bene nel caso reale;
- il Wi-Fi si riaggancia da solo dopo resume;
- `Bluetooth` e' acceso e il controller riprende dal suspend;
- nessuna VPN era attiva durante il check.

Conclusione:

- il baseline rete/Bluetooth e' sostanzialmente buono;
- il punto VPN va validato quando ci sono profili attivi reali, non solo a
  livello di menu.

### Screenshot e Recording

Risultati osservati:

- i bind `Print`, `Shift+Print`, `Ctrl+Print`, `Super+Print`,
  `Super+Shift+Print` sono presenti;
- gli helper locali per screenshot, annotazione e recording esistono tutti;
- non risultavano processi zombie del workflow al momento del check.

Conclusione:

- il blocco screenshot/recording e' gia' in una forma abbastanza sana da
  essere portato in `Margine` senza grandi dubbi.
