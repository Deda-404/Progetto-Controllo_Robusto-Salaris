function physical=hinf_final_uncertain(m4,BdFull)
%HINF_FINAL_UNCERTAIN Stessa meccanica M4, coppia link fisica M5.
% ssdata(uss) restituisce matrici nominali: usare le proprieta incerte.
mech=m4.GmechUncQ; act=m4.uncertainPlantInfo.GactuatorsUncertain;
Am=mech.A; Bm=mech.B; Cm=mech.C; Dm=mech.D;
assert(~any(Dm,'all')); nm=size(Am,1);
mechanical=uss(Am,[Bm BdFull(1:nm,:)],Cm,zeros(2,4));
mechanical.InputName={'tau1','tau2','d1','d2'}; mechanical.OutputName={'q1','q2'};
act.InputName={'u1','u2'}; act.OutputName={'tau1','tau2'};
% Conservare l'oggetto dinamico: act.A/B/C/D sono solo la parte nominale.
physical=connect(mechanical,act,{'u1','u2','d1','d2'},{'q1','q2'});
assert(isequal(sort(string(fieldnames(physical.Uncertainty))), ...
    sort(["Delta_act1";"Delta_act2";"Jm1";"k1";"k2"])));
end
