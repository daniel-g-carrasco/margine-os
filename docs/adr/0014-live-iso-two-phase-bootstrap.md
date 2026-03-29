# ADR 0014 - Bootstrap da live ISO in due fasi

## Stato

Accettato

## Perché esiste questo ADR

Ora `Margine` ha già:

- manifest eseguibili;
- installer guidato dai manifest;
- pipeline boot/trust;
- bootstrap iniziale di `Secure Boot`.

Manca però il primo punto di ingresso reale da installazione pulita:

- il bootstrap da live ISO.

## Problema da risolvere

L'ambiente live ISO e il sistema target non sono la stessa cosa.

Se li trattiamo come un unico contesto, finiamo per mischiare:

- operazioni che devono avvenire su `/mnt`;
- operazioni che hanno senso solo dentro il sistema target;
- logica più difficile da capire e da testare.

## Decisione

Per `Margine v1`, il bootstrap installativo viene diviso in due fasi:

1. fase live ISO
2. fase in chroot

## Fase 1 - Live ISO

La fase live ISO si occupa solo di:

- verificare il target mountato;
- installare il primo set minimo di pacchetti con `pacstrap`;
- generare `fstab`;
- copiare la repo `margine-os` dentro il target;
- opzionalmente entrare nel chroot e passare il testimone alla fase 2.

## Fase 2 - Chroot

La fase in chroot si occupa di:

- configurazione base del sistema;
- installazione dei layer rimanenti guidata dai manifest;
- enable dei servizi fondamentali;
- preparazione del sistema per i passi successivi di boot e desktop.

## Regola del set minimo per pacstrap

Nella `v1`, `pacstrap` non installerà tutti i layer.

Installerà solo i layer minimi per portare il sistema in uno stato utile al
chroot:

1. `base-system`
2. `hardware-framework13-amd`
3. `security-and-recovery`

I layer desktop e applicativi resteranno alla fase 2.

## Regola di handoff

La fase 1 non deve duplicare la logica della fase 2.

Deve invece:

- copiare la repo;
- chiamare uno script dentro il target;
- passargli i parametri necessari.

## Regola di prudenza

Il bootstrap `v1` non fa ancora:

- partizionamento automatico;
- setup automatico LUKS/Btrfs;
- creazione utente finale;
- installazione completa del bootloader.

Quelle parti arriveranno dopo, a blocchi separati.

## Conseguenze pratiche

Questa scelta ci dà:

- uno script live ISO piccolo e leggibile;
- una fase chroot più testabile;
- meno assunzioni nascoste;
- una base buona per crescere senza rifare tutto.

## Per uno studente: la versione semplice

Pensa così:

- la live ISO prepara il tavolo;
- il chroot cucina davvero il sistema.

Se provi a fare tutto nella live ISO, il codice si sporca subito.
