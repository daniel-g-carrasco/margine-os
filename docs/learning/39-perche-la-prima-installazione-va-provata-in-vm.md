# 39 - Perche' la prima installazione va provata in VM

Quando costruisci un sistema come `Margine`, il primo errore da evitare e':

"sembra tutto giusto nei file, quindi provo subito sul laptop vero".

E' un errore perche':

- il provisioning disco e' distruttivo;
- la boot chain UEFI puo' rompersi in modo silenzioso;
- una live ISO reale introduce variabili che i `dry-run` non coprono.

La VM serve proprio a questo:

- ridurre il rischio;
- ripetere il test;
- vedere se il bootstrap arriva davvero al primo boot.

La regola pratica e':

1. prima VM;
2. poi hardware reale.
