# Manifests

Qui andranno le liste curate dei componenti da installare.

Regola:
- manifest piccoli;
- nomi espliciti;
- niente dump indiscriminati da `pacman -Qqe`.

Stato attuale della macchina di partenza:

- `230` pacchetti espliciti installati;
- solo una parte entrerà davvero in `Margine`.

Approccio:

- i manifest devono descrivere il sistema target;
- non devono fotografare la macchina attuale;
- i casi ambigui vanno parcheggiati in note separate finché non sono chiari.

Struttura iniziale:

- `packages/base-system.txt`
- `packages/hardware-framework13-amd.txt`
- `packages/connectivity-stack.txt`
- `packages/security-and-recovery.txt`
- `packages/coding-system-tools.txt`
- `packages/virtualization-containers-stack.txt`
- `packages/hyprland-core.txt`
- `packages/toolkit-gtk-qt.txt`
- `packages/printing-scanning-stack.txt`
- `packages/desktop-integration.txt`
- `packages/apps-core.txt`
- `packages/apps-photo-audio-video.txt`
- `packages/fonts.txt`
- `packages/aur-exceptions.txt`
- `packages/open-questions.md`
- `flatpaks/apps.txt`
- `storage-subvolumes.txt`
