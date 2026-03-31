# Note didattiche

Questa cartella servirà a spiegare i sottosistemi "come a uno studente".

Argomenti previsti:

- bootloader, UEFI e Secure Boot
- TPM2 e sblocco LUKS
- Btrfs e subvolumi
- confronto tra layout attuale e layout target
- validazione della catena di boot
- separazione tra boot normale e recovery
- modello di integrazione con Arch rolling
- lettura del template Limine
- funzionamento del generatore Limine
- policy snapshot e limiti della recovery
- ragionamento dell'orchestratore update-all
- deploy sicuro sulla ESP
- enrollment della config Limine e firma EFI
- bootstrap iniziale di Secure Boot
- snapshot e rollback
- pacman, hook e manutenzione
- Hyprland e componenti del desktop
- portal, polkit e sessione utente
- stack grafico AMD
- audio su Framework 13
- migrazione selettiva delle configurazioni
- configurazione applicativa versionata
- snapshot bootabili e limiti del rollback
- snapshot pre-update e snapshot granulari
- color management e fotografia su Linux
- ICC su Hyprland: app-first contro compositor-first
- browser e mailer: pacchetto, default e dati personali
- review app-per-app dei profili personali
- tooling da terminale e amministrazione come layer dedicato
- differenza tra pacchetto SSH, servizio e firewall
- stampa, scanner e discovery di rete
- validazione runtime del sistema
- virtualizzazione e container come baseline separata
- boot chain iniziale come prerequisito del test end-to-end
- validazione installativa in VM prima del ferro vero
- separazione tra `VRR`, refresh rate e power profile sul laptop
- import dell'ambiente Hyprland nel manager `systemd --user`

Regola:
- ogni nota deve spiegare il "cosa", il "perché" e il "come modificarlo".
