# Validazione virtualizzazione e container - 2026-03-30

## Scope

Questa review verifica:

- supporto hardware a virtualizzazione
- pacchetti reali presenti
- stato runtime di `libvirt`
- stato container baseline

## Risultati principali

### Supporto hardware

Risultati osservati:

- estensioni CPU: `svm`
- moduli kernel: `kvm_amd`, `kvm`

Conclusione:

- la macchina reale e' pronta per `KVM`.

### Pacchetti presenti

Risultati osservati:

- presenti: `libvirt`, `qemu-base`, `qemu-desktop`, `edk2-ovmf`
- assenti: `virt-manager`, `podman`, `swtpm`, `virt-viewer`

Conclusione:

- il sottosistema esiste solo a meta': la base `QEMU/libvirt` c'e', ma manca
  ancora una baseline workstation coerente.

### Runtime

Risultati osservati:

- `libvirtd.service`: disabilitato
- nessuna rete `virsh` definita o attiva durante il check
- `/var/lib/libvirt` esiste ma senza workload reali

Conclusione:

- questo e' il caso classico di sottosistema "quasi pronto" ma non ancora
  chiuso davvero.

## Decisione progettuale

Per questo `Margine` introduce un layer dedicato:

- `libvirt`
- `qemu-desktop`
- `virt-manager`
- `virt-viewer`
- `edk2-ovmf`
- `dnsmasq`
- `swtpm`
- `podman`
