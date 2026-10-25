# Interfacce per i futuri modelli Simulink

La nuova integrazione è NOT RUN: gli SLX definitivi saranno forniti dagli
studenti. Nessun modello esistente viene alterato o assunto definitivo.

`dati/interfacce_simulink.mat` contiene `impianto` e otto record `interfacce`:
LQG, LQGI, Hinf1, Hinf2, PID, Kmu, Mu_A, Mu_B. Ogni record fornisce Ak, Bk,
Ck, Dk, x0, ordine degli ingressi e uscite. È una singola realizzazione:
non duplicare gli stati separando riferimento e misura in due State-Space.

    xc_dot = Ak*xc + Bk*[r;ymis]
    u      = Ck*xc + Dk*[r;ymis]

| Famiglia | Ingressi in ordine | Uscite | Stati del controllore |
|---|---|---|---:|
| LQG | r1,r2,q1_mis,q2_mis,theta1_mis,theta2_mis | u1,u2 | 14 |
| LQGI | stesso ordine LQG | u1,u2 | 16 |
| Hinf1 | r1,r2,q1_mis,q2_mis | u1,u2 | 18 |
| Hinf2 | stesso ordine Hinf1 | u1,u2 | 22 |
| PID | stesso ordine Hinf1 | u1,u2 | 4 |
| Kmu | stesso ordine Hinf1 | u1,u2 | 78 |
| Mu_A | stesso ordine Hinf1 | u1,u2 | 88 |
| Mu_B | stesso ordine Hinf1 | u1,u2 | 32 |

Riferimenti e posizioni sono deviazioni in rad dall'equilibrio
qbar=[pi/2;0]. Le misure motore sono deviazioni da theta_bar; il rumore
encoder si somma prima dell'ingresso del controllore. K comprende già i
segni: non aggiungere un meno davanti al feedback robusto. LQGI integra
r-q_mis, non r-q vero. Le due coordinate integrali hanno unità rad*s.

L'uscita u è comando di coppia in N m, **prima** dei drive. Il drive
produce tau, coppia applicata al rotore; non applicare u direttamente al
link. Il disturbo d in N m è applicato ai link, senza attraversare il drive.
L'uscita di prestazione è q; i quattro encoder sono [q;theta].

`impianto.A`, `.Bu`, `.Bd`, `.C`, `.Cq` descrivono la pianta nominale
completa, con stato [dq;qdot;dtheta;thetadot;xa], rispettivamente
2+2+2+2+6 coordinate. Le prime otto sono fisiche; xa sono coordinate di
realizzazione del drive, non altri angoli. `impianto.act` contiene le
matrici dei drive usate nella simulazione. `xbar` e `taubar` sono le
grandezze assolute di equilibrio per il modello non lineare.

Esempio di preparazione esterna, da adattare ai nomi dei nuovi SLX:

```matlab
load(fullfile('dati','interfacce_simulink.mat'),'impianto','interfacce');
c=interfacce(2); % LQGI
Ak=c.Ak; Bk=c.Bk; Ck=c.Ck; Dk=c.Dk; x0k=c.x0;
Aplant=impianto.A;
Bplant=[impianto.Bu impianto.Bd]; % [u1,u2,d1,d2]
Cplant=impianto.C; Dplant=zeros(4,4); x0plant=zeros(14,1);
```

Per tracking/disturbo gli stati iniziali sono nulli in deviazione.
Nella sezione RAS: dq è il punto scelto, dtheta=dq, velocità nulle,
xa=0, xc=0, r=d=v=0. Il non lineare usa xbar più la deviazione meccanica;
il lineare usa direttamente la deviazione. Per altre condizioni iniziali
occorre indicare esplicitamente tutti gli stati.

Non sono documentati limiti hardware, saturazioni o anti-windup. Gli SLX
futuri dovranno essere controllati e simulati realmente prima di dichiarare
nuova validazione. I margini S1 riguardano il modello lineare incerto e
non certificano automaticamente i nuovi diagrammi o l'hardware.
