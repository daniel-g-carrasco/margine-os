# Come ragiona il provisioning storage

## Il punto importante

Partizionare e formattare un disco non è "installare pacchetti".

È la parte più distruttiva e meno reversibile del bootstrap.

Per questo la trattiamo come uno script dedicato, separato dal resto.

## La sequenza logica

Il ragionamento corretto è:

1. scegliere il disco giusto;
2. cancellare la struttura precedente;
3. creare la nuova tabella GPT;
4. creare `ESP` e partizione cifrata;
5. inizializzare `LUKS2`;
6. aprire il mapping;
7. creare `Btrfs`;
8. creare i subvolumi;
9. montare tutto nel layout finale.

## Perché usiamo un manifest per i subvolumi

Per evitare che il progetto abbia due verità diverse:

- una nei documenti;
- una nello script.

Con il manifest:

- l'architettura dice quali subvolumi devono esistere;
- lo script li crea leggendo quella fonte.

## Perché il target finale è già montato

Perché il passo successivo, `bootstrap-live-iso`, ha bisogno di un target
pronto.

L'idea è questa:

- lo script storage ti lascia `/mnt` in stato coerente;
- poi il bootstrap può fare `pacstrap`, `fstab` e handoff al chroot.

## Perché lo script deve essere paranoico

Perché qui un errore non è un warning.
È perdita dati.

Quindi la paranoia è giusta:

- disco esplicito;
- conferma distruttiva esplicita;
- niente autodetect creativo.

## La regola mentale da ricordare

Se uno script storage ti sembra troppo comodo, probabilmente è troppo
pericoloso.

Qui vogliamo uno script leggibile, severo e prevedibile.
