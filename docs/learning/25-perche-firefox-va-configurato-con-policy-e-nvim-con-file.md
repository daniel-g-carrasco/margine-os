# Perché Firefox va configurato con policy e Neovim con file

Non tutte le applicazioni espongono la configurazione nello stesso modo.

## Firefox

`Firefox` ha due mondi distinti:

- il profilo utente completo;
- le policy di sistema.

Il profilo utente contiene troppo:

- cronologia;
- estensioni;
- stato locale;
- database interni;
- preferenze miste a dati personali.

Per un sistema riproducibile e didattico, e' una base pessima.

Le policy invece servono proprio a definire:

- il comportamento base desiderato;
- alcune regole da applicare sempre;
- un baseline chiaro tra installazioni diverse.

Per questo in `Margine` `Firefox` viene trattato con policy.

## Neovim / LazyVim

Qui la situazione e' l'opposto.

La configurazione di `Neovim` e':

- testuale;
- modulare;
- leggibile;
- relativamente piccola;
- davvero rappresentativa del workflow.

Quindi ha molto senso versionarla come file normali.

## La lezione generale

La domanda non e':

- "dove salvo i file?"

La domanda giusta e':

- "qual e' il meccanismo di configurazione piu' pulito per questa applicazione?"

Per `Firefox`:

- policy.

Per `Neovim`:

- file di configurazione.

