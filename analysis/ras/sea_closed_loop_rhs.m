function dz = sea_closed_loop_rhs(z, modello)
%SEA_CLOSED_LOOP_RHS Dinamica nominale completa nelle deviazioni.
% z=[x_meccanica(8);x_attuatore(6);x_controllore]. Il controllore
% riceve Cy*x: [q;theta] per LQG, -q per Hinf/Kmu (r=0).
% Nessun riferimento, disturbo, rumore o saturatore nella RAS.
arguments
    z (:,1) double
    modello (1,1) struct
end
x = z(1:14);
xc = z(15:end);
misura = modello.Cy*x;
u = modello.Cc*xc + modello.Dc*misura;
tau = modello.Cact*x(9:14) + modello.Dact*u;
dm = sea_nonlinear_rhs(modello.xbar + x(1:8), ...
    modello.taubar + tau, modello.parametri) - modello.residuoEquilibrio;
da = modello.Aact*x(9:14) + modello.Bact*u;
dc = modello.Ac*xc + modello.Bc*misura;
dz = [dm;da;dc];
end
