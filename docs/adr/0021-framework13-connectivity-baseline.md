# ADR 0021 - Baseline di connettività per `Framework Laptop 13 AMD`

## Stato

Accettato

## Problema

`Margine` aveva già un layer pacchetti per la connettività, ma mancavano ancora
le configurazioni versionate che trasformano quei pacchetti in un comportamento
coerente e riproducibile.

Nel caso reale di `Margine`, il target è un `Framework Laptop 13 AMD 7040` con
chip Wi-Fi `MediaTek MT7922`, pilotato dal modulo kernel `mt7921e`.

Serve quindi decidere:

- chi orchestra davvero rete e VPN;
- quale backend Wi-Fi usare;
- come gestire regulatory domain e tool TUI;
- quanto tuning driver introdurre nella `v1`.

## Decisione

Per `Margine v1` la baseline di connettività è:

- `NetworkManager` come orchestratore principale;
- `iwd` come backend Wi-Fi di `NetworkManager`;
- `OpenVPN` e `WireGuard` gestiti come profili `NetworkManager`;
- `impala` come TUI Wi-Fi;
- `bluetui` come TUI Bluetooth;
- regulatory domain Wi-Fi versionato e applicato tramite `cfg80211`;
- nessun tuning aggressivo del modulo `mt7921e` nella `v1`.

## Perché questa scelta

Il punto qui è separare i ruoli:

- `NetworkManager` è il cervello di sistema per stato rete, VPN e integrazione
  col desktop;
- `iwd` è il motore Wi-Fi;
- `impala` e `bluetui` sono interfacce terminal-first coerenti col workflow
  utente.

Questa combinazione è più pragmatica del solo `iwd`, ma molto più allineata
all'uso reale della macchina: Wi-Fi quotidiano, VPN `OpenVPN`/`WireGuard` e
integrazione con `waybar`.

## Regulatory domain

`Margine` versiona un drop-in `modprobe.d` per `cfg80211` con un codice paese
esplicito.

Nella baseline italiana il valore è `IT`, ma il bootstrap lo tratta come
parametro e può renderizzare un codice diverso.

Questa scelta evita di lasciare il regulatory domain implicito o assente.

## Perché non forziamo tuning su `mt7921e`

Sul `Framework 13 AMD` esistono discussioni ricorrenti su power saving e
stabilità del modulo MediaTek, ma per `Margine v1` la regola è:

- niente patch del driver "per sentito dire";
- niente override di `disable_aspm` o `disable_clc` senza una validazione
  riproducibile;
- prima si parte da backend corretto, regulatory domain corretto e firmware
  standard.

Se in futuro emergerà un tuning davvero necessario, entrerà con un ADR
dedicato, non come "piccola magia" nascosta.

## Implementazione v1

`Margine` versiona:

- `/etc/NetworkManager/conf.d/10-wifi-backend.conf`
- `/etc/iwd/main.conf`
- `/etc/modprobe.d/cfg80211-regdom.conf`
- un provisioner dedicato per installare questi file

Il bootstrap `chroot` richiama questo provisioner prima del layer desktop.

## Conseguenze pratiche

Questa decisione dà a `Margine`:

- una baseline rete/VPN/Bluetooth esplicita;
- coerenza con il target `Framework 13 AMD`;
- meno configurazione "accidentale" presa dalla macchina attuale;
- un punto unico dove cambiare backend Wi-Fi o regulatory domain.

## Per uno studente: la versione semplice

Qui il trucco è non confondere i livelli.

- `NetworkManager` decide *lo stato della rete del sistema*.
- `iwd` parla *con la scheda Wi-Fi*.
- `impala` e `bluetui` sono solo *le interfacce comode*.

Quando questi livelli sono chiari, la configurazione smette di essere una
raccolta di tentativi e diventa architettura.
