# Perché autologin e `hyprlock` non sono la stessa cosa

Quando si progetta l'accesso a un sistema grafico, è facile pensare:

> "Se tanto poi compare `hyprlock`, allora è uguale a fare login nel greeter."

Non è vero.

## Due modelli diversi

### Modello A

`greetd -> tuigreet -> autenticazione -> sessione`

Qui l'utente viene autenticato *prima* che la sessione parta.

### Modello B

`greetd -> autologin -> Hyprland -> hyprlock`

Qui la sessione parte subito, ma viene bloccata immediatamente dalla
lockscreen.

## Perché allora scegliere il modello B?

Perché il progetto `Margine` è pensato, almeno nella `v1`, per:

- un laptop personale;
- un solo utente principale;
- disco cifrato;
- priorità alta alla coerenza estetica e operativa.

In questo contesto, il modello B offre:

- una UX più uniforme;
- un solo linguaggio visivo;
- meno dipendenza da un display manager "ingombrante".

## Cosa si perde

Il modello B non va descritto come se fosse identico al modello A.

Si perde:

- una separazione più rigida tra fase di boot e fase di sessione;
- un confine di autenticazione più classico;
- una semantica più adatta a macchine condivise.

## Perché allora mantenere anche `tuigreet`

Perché serve un fallback pulito.

`greetd` ha due concetti:

- `default_session`: il greeter normale;
- `initial_session`: la sessione iniziale lanciata una volta per boot.

Questo permette di avere entrambe le cose:

- autologin iniziale per l'utente principale;
- `tuigreet` disponibile dopo logout o quando l'autologin non è il percorso
  giusto.

## La lezione vera

Quando configuri un login path non stai solo scegliendo "un programma che apre
il desktop".

Stai scegliendo:

- dove avviene l'autenticazione;
- quanta fiducia dai al contesto della macchina;
- quale esperienza vuoi rendere normale;
- quale fallback vuoi lasciare quando qualcosa cambia.

Per `Margine`, la scelta è: macchina personale, sessione coerente, fallback
pulito.
