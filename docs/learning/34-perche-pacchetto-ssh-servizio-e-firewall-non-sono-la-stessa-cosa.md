# Perche' pacchetto SSH, servizio e firewall non sono la stessa cosa

Questo e' un punto che crea spesso confusione.

Molti pensano:

- \"ho installato OpenSSH, quindi il server e' gia' esposto\"

oppure:

- \"ho un firewall, quindi posso ignorare il servizio\"

Sono due idee sbagliate.

## I quattro livelli veri

Qui ci sono quattro livelli distinti:

1. il pacchetto `openssh`
2. il servizio `sshd`
3. il firewall
4. la regola che apre davvero la porta

## Esempio semplice

Puoi avere:

- `openssh` installato
- `sshd` spento
- `ufw` attivo
- nessuna porta aperta

In questo caso la macchina:

- puo' usare il client SSH per uscire;
- non accetta connessioni SSH in ingresso.

## La scelta di Margine

`Margine` usa proprio questa separazione:

- il pacchetto c'e';
- il firewall c'e';
- il server si abilita quando serve davvero.

## Perche' e' una scelta buona

Per un laptop personale e' meglio cosi':

- non ti dimentichi il server aperto su reti casuali;
- non devi reinstallare o riconfigurare tutto quando ti serve SSH;
- capisci davvero la differenza tra presenza del software ed esposizione del
  servizio.
