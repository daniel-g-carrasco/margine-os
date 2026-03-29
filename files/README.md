# Files

Questa cartella conterrà i file da installare nel sistema target.

Struttura prevista:

- `etc/` per file destinati a `/etc`
- `usr/` per file destinati a `/usr`
- `home/` per file utente da distribuire nella home
- `esp/` per file destinati alla EFI System Partition

Esempi già presenti:

- `etc/snap-pac.ini`
- `etc/snapper/configs/root`
- `etc/sudoers.d/10-margine-wheel`
- `home/.local/share/easyeffects/output/fw13-easy-effects.json`
- `home/.config/systemd/user/margine-framework-audio.service`

Nota:

- i file sotto `home/` sono file utente versionati che il provisioning copia
  nella home target solo quando hanno davvero senso per quel profilo hardware o
  workflow.

Regola:

- nessun file qui dentro deve essere "misterioso";
- ogni file importante deve essere spiegato da un ADR, da una nota didattica,
  oppure da commenti locali chiari.
