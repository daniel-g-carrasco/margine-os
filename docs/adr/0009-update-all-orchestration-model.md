# ADR 0009 - Modello di orchestrazione di update-all

## Stato

Accettato

## Perché esiste questo ADR

Ora che il progetto ha già definito:

- boot path
- snapshot policy
- generazione `limine.conf`
- strategia `UKI`

serve decidere come questi pezzi vengono eseguiti in pratica durante un update.

In altre parole:

- `update-all` deve restare uno script comodo;
- ma deve anche diventare il percorso canonico di manutenzione di `Margine`.

## Problema da risolvere

Uno script di update troppo semplice diventa presto insufficiente.

Per esempio:

- aggiorna i pacchetti, ma dimentica il boot path;
- aggiorna il boot path, ma non verifica `Secure Boot`;
- aggiorna componenti opzionali, ma non distingue i fallimenti critici da quelli
  accessori.

Serve quindi una pipeline esplicita.

## Decisione

Per `Margine v1`, `update-all` sarà l'orchestratore canonico del ciclo di
manutenzione del sistema.

Non sostituisce:

- `pacman`
- `snapper`
- `snap-pac`

Li coordina.

## Ordine delle fasi

L'ordine corretto della pipeline è questo:

1. update pacchetti Arch (`pacman`)
2. update AUR, se presente
3. update Flatpak, se presente
4. update firmware (`fwupd`), se presente
5. rigenerazione artefatti di boot
6. verifiche finali

## Ruolo delle singole fasi

### 1. Pacman

Questa è la fase più importante.

Qui:

- `snap-pac` crea gli snapshot pre/post del root;
- il sistema riceve gli update dei repo ufficiali;
- vengono aggiornati i componenti più sensibili del sistema.

Questa fase è sempre critica.

### 2. AUR

È una fase secondaria rispetto al core del sistema.

La `v1` del progetto resta:

- official-repos first;
- AUR solo per eccezioni esplicite.

Quindi l'AUR va gestito come layer accessorio, non come cuore della pipeline.

### 3. Flatpak

Flatpak non è parte del core architetturale del boot path.
Va trattato come strato opzionale.

### 4. fwupd

Il firmware è importante, ma non deve impedire l'aggiornamento ordinario del
sistema operativo quando non c'è nulla da fare o quando il dispositivo non è
supportato.

### 5. Artefatti di boot

Questa fase è il valore aggiunto vero di `Margine`.

Qui vanno orchestrati:

- `mkinitcpio -P`
- rendering di `limine.conf`
- in futuro: deploy su `ESP`
- in futuro: `limine enroll-config`
- in futuro: firma/refresh completi

### 6. Verifiche finali

Le verifiche finali devono dare all'utente una risposta semplice:

- il sistema è stato aggiornato;
- il boot path è coerente;
- la trust chain non mostra rotture evidenti.

## Politica di errore

Per la `v1`, distinguiamo tra errori hard e soft.

### Errori hard

Sono errori che devono fermare lo script.

Esempi:

- fallimento di `pacman`
- fallimento della rigenerazione `UKI`
- fallimento del rendering `limine.conf`

### Errori soft

Sono errori che vanno segnalati ma non devono per forza rendere inutilizzabile
il ciclo di update.

Esempi:

- fallimento AUR
- fallimento Flatpak
- assenza o fallimento `fwupd`

## Prima implementazione pratica

La prima implementazione versionata di `update-all` dovrà essere:

- leggibile;
- supportare `--dry-run`;
- supportare skip di layer opzionali;
- supportare input espliciti per il rendering di `limine.conf`.

Non dovrà ancora pretendere di:

- deployare tutto sulla `ESP`;
- completare tutta la firma EFI finale;
- fare discovery automatica completa degli snapshot.

Quelle parti arriveranno in passi successivi.

## Conseguenze pratiche

Questo modello ci dà una proprietà importante:

- il progetto ha già un flusso canonico di manutenzione;
- ma lo implementa per strati, senza fingere che tutto sia già chiuso.

## Per uno studente: la versione semplice

Se lo spieghiamo in modo diretto:

- `update-all` non è "un alias più simpatico di pacman";
- è il punto in cui Arch, snapshot, boot path e verifiche si incontrano.

La sua funzione non è fare magia.
È imporre ordine.
