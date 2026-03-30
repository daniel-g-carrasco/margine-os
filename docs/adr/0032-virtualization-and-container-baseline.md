# ADR 0032 - Baseline virtualizzazione e container

## Stato

Accettato

## Contesto

`Margine` ha gia' preparato storage, gruppi utente e subvolumi per:

- VM `KVM/QEMU`;
- `libvirt`;
- workload container rootful e rootless.

Pero' fino ad ora mancava una baseline pacchetti e runtime coerente. Questo
lasciava un buco tra architettura storage e utilizzo reale.

## Decisione

Per `Margine v1` adottiamo:

- `libvirt`
- `qemu-desktop`
- `virt-manager`
- `virt-viewer`
- `edk2-ovmf`
- `dnsmasq`
- `swtpm`
- `podman`

In piu':

- installiamo un drop-in `libvirtd.conf.d` per usare il gruppo `libvirt`;
- impostiamo `qemu:///system` come URI predefinito;
- forniamo un helper per abilitare la rete `default` di `libvirt`.

## Perche' questa scelta

Il criterio e' semplice:

- per le VM serve un percorso immediato e leggibile;
- per i container serve una baseline moderna, non Docker-first;
- la macchina e' una workstation personale, quindi `virt-manager` ha senso.

## Cosa non entra nella v1

Non entrano ancora:

- Docker come baseline;
- Kubernetes locali;
- orchestrazione multi-host;
- tuning avanzato di rete bridge custom.

## Conseguenze

### Positive

- il progetto torna coerente con i subvolumi gia' previsti;
- la macchina e' pronta per VM desktop e container OCI senza rework;
- la distinzione tra VM e container resta chiara.

### Negative

- e' un layer in piu' nella baseline;
- `libvirtd` entra tra i servizi di sistema da validare davvero.

## Per uno studente

La lezione qui e' questa:

- preparare storage per le VM non basta;
- mettere l'utente nel gruppo `libvirt` non basta;
- finche' non esistono pacchetti, runtime e check ripetibili, non hai una
  baseline: hai solo intenzioni.
