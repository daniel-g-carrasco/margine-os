# ADR 0019 - Provisioning audio Framework 13 con EasyEffects

## Stato

Accettato

## Problema da risolvere

`Margine` vuole avere una baseline audio sensata per `Framework Laptop 13`,
ma senza imporre comportamenti sbagliati su hardware diverso.

Con EasyEffects il rischio classico è questo:

- copiare un preset;
- non versionare i file ausiliari del convolver;
- forzare il preset in modo globale su qualsiasi output;
- rompere cuffie, HDMI o macchine non compatibili.

## Decisione

Per `Margine v1` adottiamo questa strategia:

- il preset ufficiale `fw13-easy-effects` viene versionato nel repository;
- viene versionato anche l'IR realmente richiesto dal preset;
- il provisioning avviene solo se la macchina risulta `Framework Laptop 13`
  tramite DMI;
- l'autoload viene generato a runtime per il route degli altoparlanti interni;
- su hardware diverso il provisioning va in no-op.

## Perché la risoluzione avviene a runtime

Il nome reale del sink PipeWire non è una costante progettuale da scrivere in
chroot.

Serve invece scoprirlo quando esiste davvero la sessione audio utente.

Per questo separiamo due tempi:

1. bootstrap in chroot:
   - copia preset;
   - copia IR;
   - installa servizio utente;
2. primo avvio della sessione:
   - rileva il sink interno;
   - genera il file autoload corretto;
   - avvia EasyEffects in service mode.

## Cosa viene versionato

- `files/home/.local/share/easyeffects/output/fw13-easy-effects.json`
- `files/home/.local/share/easyeffects/irs/IR_22ms_27dB_5t_15s_0c.irs`
- `files/home/.local/bin/margine-framework-audio-service`
- `files/home/.config/systemd/user/margine-framework-audio.service`

## Guardrail espliciti

- niente applicazione su macchine non `Framework`;
- niente preset globale su output non interni;
- niente dipendenza da gruppi audio legacy;
- niente dipendenza da path temporanei della macchina sorgente.

## Conseguenze pratiche

Questa scelta ci dà:

- preset riproducibile davvero;
- comportamento di default buono sul laptop target;
- fallback pulito a "nessun comportamento speciale" su hardware diverso.
