# Perché il desktop non è solo una cartella di dotfiles

Molti pensano che "riprodurre il desktop" significhi:

- copiare `~/.config`;
- incrociare le dita;
- sperare che tutto riparta.

Questa non è architettura. È archeologia.

## Cos'è davvero un desktop layer

Un desktop layer è l'insieme di:

- pacchetti installati;
- file di configurazione;
- piccoli script di supporto;
- regole di avvio della sessione.

Se manca uno di questi pezzi, il desktop non è davvero riproducibile.

## Perché `Margine` lo tratta come un layer separato

Perché il desktop ha esigenze diverse dal sistema base.

Il sistema base deve sapere:

- come fare boot;
- come montare il disco;
- come creare l'utente.

Il desktop deve sapere:

- come parte la sessione;
- quale launcher usare;
- come si mostra la barra;
- come si gestiscono screenshot, notifiche e lockscreen.

Mescolare tutto nello stesso contenitore rende il progetto più difficile da
capire e più fragile da mantenere.

## La lezione importante

Un buon progetto non copia la tua home.

Seleziona:

- cosa è davvero baseline;
- cosa è solo stato locale;
- cosa è personale e non deve entrare nel repository.

Per questo `Margine` versiona il desktop, ma non i tuoi wallpaper privati, non
la cache, non i database runtime e non i lock file.
