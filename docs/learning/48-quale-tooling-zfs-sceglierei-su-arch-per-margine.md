# Quale tooling ZFS sceglierei su Arch per Margine

## Obiettivo

Dopo aver separato:

- `ZFS` come data layer non-root
- `root-on-ZFS` come progetto boot/recovery separato

serve una scelta pragmatica sul tooling.

La domanda corretta non e`:

- "qual e` il setup ZFS piu` figo?"

La domanda corretta e`:

- "qual e` il setup ZFS piu` coerente con Arch rolling e con il perimetro
  non-root che stiamo introducendo?"

## La scelta che farei oggi

Per il primo layer `ZFS` non-root su `Margine` sceglierei:

- `zfs-dkms`
- `zfs-utils`
- `sanoid`

E non sceglierei ancora:

- `zfsbootmenu`
- `zrepl`
- package kernel-specific `zfs-linux*`
- repo esterni aggiuntivi come parte della baseline normale

## Perche' `zfs-dkms`

Su Arch, `OpenZFS` non fa parte del kernel tree standard.

Per il primo giro non-root, `zfs-dkms` e` la scelta piu` flessibile perche':

- non ci obbliga ancora a cambiare kernel di sistema
- si appoggia al kernel attuale tramite `DKMS`
- isola l'esperimento ZFS dal boot root

Questo non significa che `DKMS` sia magico.

Significa solo che, per un perimetro **non-root**, e` il compromesso piu`
ragionevole tra:

- adozione rapida
- basso coupling architetturale
- reversibilita`

Se il modulo ZFS non costruisce dopo un update, il risultato e` grave per i
dataset `ZFS`, ma non blocca il boot del sistema root `Btrfs`.

Per un primo ciclo questo e` esattamente il tipo di rischio che vogliamo:

- confinato
- esplicito
- non distruttivo della boot chain

## Perche' non sceglierei ancora `zfs-linux` o `zfs-linux-lts`

I package kernel-specific hanno senso quando il progetto ZFS entra piu` dentro
il boot path oppure quando si vuole tenere piu` stretto il coupling tra:

- kernel
- modulo ZFS

Per `Margine` oggi non e` ancora il momento.

Nel primo giro:

- la root non e` su ZFS
- non vogliamo cambiare kernel policy
- non vogliamo riscrivere l'aggiornamento di sistema attorno a ZFS

Quindi introdurre subito package kernel-specific complicherebbe la baseline
senza dare il vantaggio che ci serve subito.

## Perche' `zfs-utils`

Qui non c'e` molto da discutere.

Se usi `ZFS`, ti servono le utilities utente:

- `zpool`
- `zfs`
- `zdb`
- `zed`
- mount/import helpers

Quindi `zfs-utils` e` parte obbligatoria del layer.

## Perche' `sanoid`

Per il primo ciclo ci serve un sostituto di `Snapper` **solo** per i dataset
`ZFS`.

Il primo problema reale da risolvere e`:

- snapshot automatici locali
- retention leggibile
- pruning automatico

`sanoid` fa esattamente questo bene.

`zrepl` invece porta da subito un modello piu` ricco:

- replica
- pruning sender/receiver
- orchestrazione push/pull

Ma quello non e` il primo bisogno operativo.

Quindi:

- `sanoid` prima
- `zrepl` solo se e quando serve davvero replica

## Perche' non sceglierei ancora `zrepl`

`zrepl` non e` sbagliato.

Semplicemente e` troppo presto.

Nel primo giro:

- non stiamo ancora facendo backup remoto di baseline
- non abbiamo ancora provato abbastanza bene il restore locale
- non vogliamo aggiungere un demone e un modello di pruning piu` ricco del
  necessario

La regola qui deve restare:

- prima snapshot locale
- poi restore locale
- solo dopo replica

## Perche' non introdurrei ancora `ZFSBootMenu`

`ZFSBootMenu` ha senso quando il progetto e` davvero:

- `root-on-ZFS`
- boot environments ZFS
- recovery model nativo ZFS

Non ha senso nel primo layer non-root.

Introdurlo adesso sarebbe un errore di livello architetturale:

- complicherebbe il boot senza che il root lo richieda
- mischierebbe due progetti separati

## Perche' non introdurrei un repo esterno come baseline normale

Su Arch esistono due strade comuni:

- AUR
- repo esterni dedicati a ZFS

Per `Margine` oggi sceglierei AUR nel primo giro, perche':

- il perimetro e` opzionale
- il layer non-root e` esplorativo
- vogliamo rendere la scelta esplicita, non invisibile

Un repo esterno kernel-coupled potrebbe essere una scelta futura per
`root-on-ZFS`, ma non e` necessario per il primo layer non-root.

## Implicazioni operative reali

Questa scelta implica alcune regole.

### 1. `ZFS` non entra nel default install path

Il layer deve restare opzionale.

### 2. `linux-headers` devono gia` esistere

`zfs-dkms` senza headers non e` una baseline difendibile.

Fortunatamente `Margine` oggi ha gia` una cultura forte di kernel headers
installati.

### 3. Va documentato il failure mode

Se un update rompe `DKMS`, il rischio operativo deve essere dichiarato bene:

- il sistema puo` continuare a bootare
- ma i dataset `ZFS` possono risultare non importabili finche' il modulo non
  torna coerente

Questo e` molto diverso dal rischio di un `root-on-ZFS`.

## Cosa versionerei subito

Per rendere questo primo ciclo concreto, versionerei:

- un layer AUR `zfs-non-root-stack`
- una mappa dataset `ZFS`
- una baseline `sanoid.conf`
- un helper per snapshot `pre-update` dei dataset `ZFS`

Tutto questo senza ancora:

- cambiare l'installer root
- modificare `Limine`
- introdurre `ZFSBootMenu`

## Decisione tecnica preliminare

Per `Margine` oggi:

- `zfs-dkms + zfs-utils + sanoid` e` la scelta corretta per iniziare
- `zfsbootmenu` e `zrepl` restano fuori dal primo ciclo

Questa non e` la decisione finale su `root-on-ZFS`.

E` solo la decisione corretta per evitare che l'adozione iniziale di `ZFS`
diventi subito un progetto boot/recovery troppo grande.

## Riferimenti

- AUR `zfs-dkms`:
  https://aur.archlinux.org/packages/zfs-dkms
- AUR `zfs-utils`:
  https://aur.archlinux.org/packages/zfs-utils
- AUR `sanoid`:
  https://aur.archlinux.org/packages/sanoid
- AUR `zfsbootmenu`:
  https://aur.archlinux.org/packages/zfsbootmenu
- Sanoid upstream:
  https://github.com/jimsalterjrs/sanoid
- OpenZFS release notes:
  https://github.com/openzfs/zfs/releases
