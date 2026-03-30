# 38 - Perche' senza boot chain iniziale non esiste un test end-to-end

Un test end-to-end serio significa:

1. partire dalla live ISO;
2. installare il sistema;
3. riavviare;
4. verificare che il boot avvenga davvero sul percorso target.

Se il progetto si ferma prima di:

- generare le `UKI`;
- scrivere `limine.conf`;
- installare `Limine` sulla `ESP`;

allora il test non e' end-to-end.

E' solo un bootstrap parziale.

Per questo `Margine` ha bisogno di un provisioner dedicato alla boot chain
iniziale: serve a trasformare la progettazione del boot in un'installazione
davvero avviabile.
