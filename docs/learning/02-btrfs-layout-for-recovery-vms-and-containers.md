# Perché questo layout Btrfs è fatto bene

Questa nota spiega il senso del layout scelto nell'ADR 0003.

Non vuole solo dire "metti questi subvolumi".
Vuole farti capire il criterio.

## 1. La domanda giusta

Quando progetti un layout Btrfs, la domanda non è:

- "quanti subvolumi riesco a creare?"

La domanda giusta è:

- "cosa voglio che uno snapshot del sistema contenga davvero?"

Se la risposta è confusa, il layout sarà confuso.

## 2. Due categorie diverse

Nel progetto `Margine` distinguiamo due grandi famiglie di dati.

### Stato del sistema

È ciò che vuoi poter rollbackare come blocco unico:

- `/etc`
- `/usr`
- `/opt`
- database pacman
- parte strutturale di `/var`

Questo vive nel root snapshot.

### Dati ad alta mutazione

È ciò che non vuoi che sporchi gli snapshot:

- cache
- log
- tmp persistenti
- home utente
- foto e dataset grandi
- dischi VM
- storage container

Questo va separato.

## 3. Perché `@home` è separato

Perché i rollback di sistema e i dati utente non sono la stessa cosa.

Se rompi il sistema, vuoi tornare indietro sul sistema.
Non vuoi automaticamente trattare la tua home come parte dello stesso snapshot.

## 4. Perché `@var_log`, `@var_cache` e `@var_tmp`

Perché sono luoghi rumorosi.

Se li lasci dentro il root snapshot:

- gli snapshot crescono male;
- il rollback è più sporco;
- il rapporto segnale/rumore peggiora.

## 5. Perché `@data`

`/data` serve come spazio user-managed per dataset pesanti o longevi.

Nel nostro caso può diventare il posto giusto per:

- foto e archivi;
- materiale di lavoro grande;
- immagini disco utente;
- export, backup locali, staging.

Questo ti evita di trasformare `/home` in un blob gigante poco leggibile.

## 6. Perché separare VM e container

Le VM e i container fanno una cosa molto semplice:

- scrivono tanto;
- cambiano spesso;
- diventano grandi;
- inquinano in fretta gli snapshot.

Per questo li separiamo:

- `/var/lib/libvirt`
- `/var/lib/machines`
- `/var/lib/containers`

Non perché "fa enterprise".
Ma perché è il modo giusto di impedire che il sistema operativo e i workload si
trascinino a vicenda.

## 7. Perché `NOCOW` solo in punti precisi

`NOCOW` non è un potenziamento magico.
È uno strumento specifico.

Ha senso su:

- immagini disco delle VM

Ha meno senso come martello totale su:

- tutto lo storage container

Questa è una lezione importante:

- ottimizzare bene non vuol dire disattivare feature a caso;
- ottimizzare bene vuol dire capire dove il comportamento cambia davvero.

## 8. Perché non separiamo `/opt`

Perché lì vivono anche file installati dai pacchetti.

Se rollbacki il sistema ma lasci `/opt` fuori, rischi di creare disallineamento
tra:

- package database
- stato reale del filesystem

Questo è un classico esempio di "separazione sbagliata".

## 9. Perché non separiamo `/var/lib/pacman`

Perché il database dei pacchetti deve seguire il sistema.

Se fai rollback di root ma il database pacman resta avanti o indietro rispetto
allo snapshot, ottieni un sistema difficile da ragionare.

## 10. Perché `compress=zstd:3`

Perché ci dà un buon compromesso:

- compressione utile;
- costo CPU ragionevole;
- beneficio reale su laptop moderno.

Non stiamo cercando la mount option più aggressiva del mondo.
Stiamo cercando quella più sensata.

## 11. Perché `fstrim.timer`

Perché sui dischi SSD è una scelta pulita e prevedibile.

In generale, in questo progetto preferiamo:

- meccanismi chiari;
- meno "micro-tuning" dentro `fstab`;
- più comportamento facile da spiegare.

## 12. La lezione da portarsi a casa

Un layout Btrfs fatto bene non nasce dal gusto personale.

Nasce da una domanda semplice:

- quali dati devono fare rollback insieme?

Tutto il resto viene dopo.
