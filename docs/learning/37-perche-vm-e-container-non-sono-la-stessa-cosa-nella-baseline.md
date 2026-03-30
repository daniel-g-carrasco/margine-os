# Perche' VM e container non sono la stessa cosa nella baseline

Molto spesso si dice:

- "mi serve la virtualizzazione"

ma dentro questa frase stai mescolando due mondi diversi:

- macchine virtuali
- container

## VM

Le VM usano un hypervisor.

Nel caso di `Margine`:

- `KVM`
- `QEMU`
- `libvirt`
- `virt-manager`

Qui il focus e':

- guest completi
- firmware virtuale
- dischi virtuali
- rete virtuale
- TPM virtuale se serve

## Container

I container usano il kernel dell'host.

Nel caso di `Margine`:

- `podman`

Qui il focus e':

- processi isolati
- immagini OCI
- flusso piu' leggero
- meno overhead di una VM completa

## Perche' separarli

Se li tratti come "la stessa cosa", fai due errori:

1. sottovaluti quanto serve davvero a una VM desktop
2. complichi inutilmente il percorso container

Per questo `Margine` tiene una baseline unica di area, ma con ruoli chiari:

- `libvirt/qemu` per le VM
- `podman` per i container

## Per uno studente

La regola semplice e' questa:

- se vuoi un altro sistema operativo completo, pensi in termini di VM
- se vuoi un ambiente isolato che usa il tuo kernel, pensi in termini di container
