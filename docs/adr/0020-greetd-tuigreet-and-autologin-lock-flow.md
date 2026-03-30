# ADR 0020 - `greetd + tuigreet` con autologin iniziale e lock immediato

## Stato

Accettato

## Perché esiste questo ADR

Fino a qui `Margine` aveva lasciato aperta la scelta del login path finale:

- `greetd`
- TTY puro
- altro display manager

Nel frattempo, l'uso reale della macchina ha chiarito una preferenza forte:

- niente `GDM`;
- niente doppio passaggio login manager + lockscreen con estetiche diverse;
- esperienza coerente con `Hyprland` e `hyprlock`.

## Problema da risolvere

Vogliamo una UX semplice e uniforme, ma senza trasformare il bootstrap in una
catena fragile o troppo "magica".

Serve quindi decidere:

1. chi avvia la sessione;
2. se esiste ancora un greeter fallback;
3. come si concilia l'autologin con la lockscreen.

## Decisione

Per `Margine v1` il percorso scelto è:

- `greetd` come login manager minimale;
- `tuigreet` come greeter fallback;
- `initial_session` di `greetd` configurata per avviare automaticamente
  l'utente principale nella sessione `Hyprland`;
- `hyprlock` lanciato immediatamente all'avvio della sessione grafica.

In pratica:

`boot -> greetd -> autologin iniziale -> Hyprland -> hyprlock`

Se la sessione termina o l'utente effettua logout, il fallback torna a:

`greetd -> tuigreet`

## Perché non TTY puro

TTY puro è più semplice come teoria, ma peggiore come UX per il target reale
di `Margine`:

- laptop personale;
- reinstallabile;
- orientato a uso quotidiano;
- con attenzione all'estetica e alla coerenza.

Con `greetd` otteniamo:

- gestione pulita della sessione;
- fallback leggibile;
- niente dipendenza da display manager pesanti;
- migliore allineamento con `Hyprland`.

## Perché non `GDM`

`GDM` risolve il login, ma trascina con sé un mondo GNOME che `Margine` non
vuole usare come infrastruttura principale.

Inoltre la combinazione:

`GDM -> login -> Hyprland -> hyprlock`

duplica il momento di accesso e rompe l'uniformità visiva.

## Chiarimento importante: autologin e lockscreen non sono la stessa cosa

Questa scelta è intenzionale, ma va capita bene:

- `tuigreet` autentica *prima* della sessione;
- `autologin + hyprlock` entra nella sessione e poi la blocca subito.

Per un laptop personale cifrato e single-user, questo compromesso è
accettabile e desiderabile.

Per una macchina multiutente o con policy più rigide, non sarebbe la scelta
giusta.

## Implementazione v1

`Margine` versiona:

- un template di `/etc/greetd/config.toml`;
- un provisioner che lo renderizza con l'utente principale;
- enable di `greetd.service`.

La configurazione usa:

- `default_session = tuigreet`
- `initial_session = /usr/bin/start-hyprland`

## Conseguenze pratiche

Questa decisione dà a `Margine`:

- un login path moderno ma minimale;
- una UX coerente con `Hyprland`;
- un fallback pulito dopo logout;
- una separazione netta dal mondo GNOME.

## Per uno studente: la versione semplice

Qui il punto non è "come faccio a entrare nel desktop?".

Il punto è: "chi controlla l'ingresso alla sessione, e con che esperienza?".

`greetd` è il portiere.
`tuigreet` è il banco reception di riserva.
`hyprlock` è la porta interna che vedi davvero ogni giorno.
