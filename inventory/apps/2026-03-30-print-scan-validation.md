# Validazione stampa e scanner sul sistema reale - 2026-03-30

## Obiettivo

Verificare se la baseline `driverless-first` scelta per `Margine` corrisponde
davvero a un caso reale della macchina attuale, invece di restare solo una
scelta teorica.

## Hardware osservato

- multifunzione `Brother MFC-L2860DWE`

## Risultati

### Stampa

La stampante configurata nel sistema reale e':

- `Brother_MFC_L2860DWE`
- URI CUPS: `ipp://192.168.2.50/ipp/print`

Questo conferma che il caso reale di stampa usa gia' `IPP`, quindi e'
perfettamente allineato a una baseline `driverless-first`.

### Discovery IPP

Con una probe `ippfind` e' comparso anche un annuncio locale:

- `ipp://BRW749779AFD5AD.local:631/ipp/print`

Questo conferma che `mDNS/DNS-SD` e' rilevante davvero per questo dispositivo.

### Scanner

`scanimage -L` ha rilevato:

- `device 'escl:https://192.168.2.50:443' is a Brother MFC-L2860DWE platen,adf scanner`

Questo conferma che lo scanner del dispositivo e' esposto via `eSCL`, quindi
il caso reale resta pienamente coerente con un approccio driverless moderno.

Nota importante: sul sistema attuale, al momento della validazione,
`sane-airscan` non risulta installato. Lo scanner viene comunque rilevato
tramite il backend `escl` incluso nel pacchetto `sane`.

Questo non indebolisce la scelta di `Margine`: al contrario, mostra che il
target hardware reale rientra davvero nella famiglia di dispositivi moderni
basati su standard aperti. In `Margine`, `sane-airscan` resta esplicito come
baseline per rendere questo supporto piu' chiaro e robusto.

Nel sistema reale compare anche:

- `device 'v4l:/dev/video0' is a Noname Laptop Webcam Module (2nd Gen): virtual device`

Questo non e' il target del layer scanner documentale, ma non e' un problema.

## Servizi osservati

Nel sistema reale risultano:

- `cups.socket`: attivo e abilitato
- `avahi-daemon.service`: attivo e abilitato
- `avahi-daemon.socket`: attivo e abilitato
- `ipp-usb.service`: abilitato ma inattivo

L'ultimo punto e' coerente: non c'e' un dispositivo `IPP over USB` attualmente
in uso, ma il supporto resta utile come baseline per hardware futuro.

## Differenza utile tra macchina attuale e target Margine

Nel sistema reale, al momento della validazione, `/etc/nsswitch.conf` non
contiene ancora `mdns` nella linea `hosts:`.

Questo significa che `Margine` non sta copiando semplicemente il sistema
attuale: sta anche migliorando la baseline lato discovery locale.

## Conclusione

La baseline `Margine v1` per stampa e scanner e' confermata da un caso reale:

- `CUPS + Avahi + ipp-usb` lato stampa
- `SANE + sane-airscan` lato scanner
- `system-config-printer` come gestione stampanti
- `simple-scan` come frontend scanner

Non emergono, da questo caso, motivi per introdurre subito driver
vendor-specifici nella `v1`.
