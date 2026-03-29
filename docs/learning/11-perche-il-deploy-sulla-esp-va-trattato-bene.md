# Perché il deploy sulla ESP va trattato bene

Questa nota accompagna:

- [deploy-boot-artifacts](/home/daniel/dev/margine-os/scripts/deploy-boot-artifacts)

La lezione importante è questa:

- generare un file e installarlo in `/etc` non è la stessa cosa che scriverlo
  sulla `ESP`.

## 1. Perché la ESP è diversa

La `ESP` è diversa perché:

- è critica per l'avvio;
- è fuori dagli snapshot root;
- spesso contiene già file di altri boot path;
- non è il posto giusto per fare editing improvvisato.

Per questo nel progetto `Margine` la trattiamo come area di deploy, non come
area di lavoro.

## 2. Perché prima generiamo e poi copiamo

Questa separazione ti dà due vantaggi grossi:

- puoi verificare il file prima di copiarlo;
- puoi ripetere il deploy senza dover ricostruire la logica a mano.

La regola pratica è:

- build fuori dalla `ESP`
- deploy sulla `ESP`

## 3. Perché facciamo backup prima di sovrascrivere

Perché il deploy del boot path è un'operazione delicata.

Se sbagli un file in `/etc`, spesso puoi ancora rientrare e correggere.
Se sbagli un file di boot, la correzione può essere molto più scomoda.

Quindi il backup prima della sovrascrittura non è paranoia.
È igiene.

## 4. Perché non cancelliamo tutto automaticamente

Questo è un altro punto da imparare bene.

Molti script diventano pericolosi perché vogliono essere "puliti" troppo presto:

- vedono file in più;
- li cancellano;
- poi scopri che uno di quei file serviva a un percorso di recovery o a una
  situazione che non avevi considerato.

Nella `v1` preferiamo:

- copiare bene;
- capire bene;
- pulire solo più avanti, con regole più forti.

## 5. La regola finale da ricordare

Se un giorno devi spiegare a qualcuno come trattare il boot path, la frase
giusta è questa:

- la `ESP` non si "edita";
- la `ESP` si deploya.
