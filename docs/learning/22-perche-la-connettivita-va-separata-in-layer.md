# Perché la connettività va separata in layer

Quando configuri rete, Wi-Fi, VPN e Bluetooth è facile fare confusione, perché
tutti questi pezzi sembrano "la stessa cosa".

In realtà non lo sono.

## I tre livelli da capire

### 1. Orchestrazione

Questo è il livello che decide:

- quali connessioni esistono;
- quale profilo è attivo;
- come si integrano VPN, DNS e stato rete.

In `Margine`, questo livello è `NetworkManager`.

### 2. Backend hardware o protocollo

Questo è il livello che parla davvero con il dispositivo o col protocollo:

- `iwd` per il Wi-Fi;
- `bluez` per il Bluetooth;
- strumenti kernel/user-space per `WireGuard`.

Questo livello non deve per forza decidere l'intera politica del sistema.

### 3. Interfaccia utente

Questo è il livello che tu vedi:

- `impala`;
- `bluetui`;
- il menu VPN in `waybar`.

Questi strumenti sono importanti, ma non devono essere scambiati per il
"motore" del sistema.

## Perché è utile pensarla così

Se un giorno cambi l'interfaccia, non devi buttare via l'architettura.

Esempio:

- puoi sostituire `impala` con un altro TUI;
- ma `NetworkManager + iwd` può restare intatto.

Questo è esattamente il motivo per cui `Margine` non vuole una configurazione
casuale "presa dalla macchina che oggi funziona", ma un sistema scomponibile e
leggibile.

## La regola pratica

Quando aggiungi un pezzo alla connettività, chiediti sempre:

- è il cervello?
- è il motore?
- o è solo l'interfaccia?

Se non sai rispondere, stai ancora mescolando i layer.
