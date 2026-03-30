# ADR 0030 - Baseline accesso remoto e firewall

## Stato

Accettato

## Contesto

`Margine` deve essere una workstation pratica anche per:

- collegarsi ad altri server;
- offrire accesso remoto quando serve;
- non nascere con porte esposte in modo casuale.

Questo richiede di distinguere bene quattro cose:

- pacchetto `openssh`;
- servizio `sshd`;
- firewall;
- apertura effettiva della porta SSH.

## Decisione

Per `Margine v1` adottiamo:

- `openssh` come baseline;
- `ufw` come firewall baseline;
- `sshd` configurato ma non aperto automaticamente verso l'esterno;
- helper semplici per abilitare o disabilitare il server SSH quando serve.

## Perche' UFW

Per `Margine v1`, `ufw` ha un vantaggio chiaro:

- e' piu' semplice e didattico di `nftables` puro;
- e' sufficiente per un laptop personale e una workstation single-user;
- consente una baseline leggibile senza nascondere troppo cosa succede.

`nftables` resta piu' nativo e piu' flessibile, ma per la `v1` non ci serve
quella complessita'.

## Scelte specifiche

### 1. Policy firewall

La baseline `ufw` e':

- `deny incoming`
- `allow outgoing`
- `deny routed`

Questo significa:

- la macchina esce liberamente;
- non espone servizi in ingresso per default.

### 2. SSH server

`openssh` e' presente sia per il client sia per il server.

Pero' `sshd` non viene considerato "pubblico" in automatico.

Il progetto installa:

- un piccolo drop-in `sshd_config.d`;
- un helper per attivare il server;
- un helper per disattivarlo.

### 3. Apertura porta SSH

La porta SSH non viene aperta di default nel firewall.

Quando l'utente decide di voler davvero esporre la macchina via SSH, usa:

- `margine-enable-ssh-server`

Questo:

- abilita `sshd.service`;
- apre la porta con `ufw limit 22/tcp`.

Per tornare indietro:

- `margine-disable-ssh-server`

### 4. Hardening minimo di SSH

La baseline aggiunge solo un hardening piccolo e non intrusivo:

- `PermitRootLogin no`
- `X11Forwarding no`
- `UseDNS no`

Non imponiamo nella `v1` un modello key-only rigido, per non rompere
immediatamente l'usabilita' del server su una macchina personale.

## Conseguenze

### Positive

- il sistema nasce con accesso remoto pronto ma non esposto a caso;
- il firewall ha una policy semplice e leggibile;
- l'utente puo' attivare SSH in un comando, senza dover reinventare tutto.

### Negative

- `ufw` non e' la soluzione piu' "pura" possibile;
- la policy SSH resta volutamente prudente e non massimamente restrittiva.

## Per uno studente

La regola da imparare e' questa:

- installare un server non significa doverlo esporre subito;
- avere un firewall non significa bloccare tutto alla cieca;
- la baseline buona e' quella che separa pacchetto, servizio e apertura porta.
