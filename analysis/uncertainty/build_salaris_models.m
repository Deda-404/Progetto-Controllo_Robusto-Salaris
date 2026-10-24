function models = build_salaris_models
%BUILD_SALARIS_MODELS Stessa meccanica e nominale, tre strutture dichiarate.
u=uncertainty_params_m4; p=actuator_params_nominal;
[mech,~,models.mechanicalInfo]=build_uncertain_mechanical_plant(u.selectedMechanicalRanges);
models.manualMechanical=build_manual_mechanical_lft;
s=tf('s'); H0=p.wn^2/(s^2+2*p.zeta*p.wn*s+p.wn^2);
tauMax=max(u.selectedActuatorRanges.UpperBound(u.selectedActuatorRanges.Parameter=="delay"));
% Residuo ADDITIVO al Pade: non si inverte il suo zero a parte reale positiva.
Wres=2*u.weightSafetyFactor*(tauMax*s/(.5+tauMax*s))^3;
models.actuator1=build_manual_parametric_actuator(1,Wres);
models.actuator2=build_manual_parametric_actuator(2,Wres);
B=append(models.actuator1.G,models.actuator2.G);
family=build_actuator_family(u); omega=family.frequencies;
H0w=reshape(freqresp(H0,omega),1,[]);
Dp0=(1-p.delay*1i*omega/2)./(1+p.delay*1i*omega/2);
res=reshape(abs(freqresp(Wres,omega)),1,[]);
envelope=zeros(1,numel(omega));
for j=1:height(family.metadata)
    f=family.metadata(j,:); jw=1i*omega;
    H=f.wn^2./(jw.^2+2*f.zeta*f.wn*jw+f.wn^2);
    Dp=(1-f.delay*jw/2)./(1+f.delay*jw/2);
    envelope=max(envelope,abs(H.*Dp./H0w-Dp0)+abs(H./H0w).*res);
end
base=s/(s+1/tauMax);
baseMag=reshape(abs(freqresp(base,omega)),1,[]);
sampleScale=u.weightSafetyFactor*max(envelope./baseMag);
% Maggiorazione analitica su TUTTO il box, non soltanto sui campioni.
range=u.selectedActuatorRanges; wmin=range.LowerBound(1); wmax=range.UpperBound(1);
zmin=range.LowerBound(2); zmax=range.UpperBound(2);
tmin=range.LowerBound(3); tmax=range.UpperBound(3); poleWeight=1/tauMax;
assert(zmin>0 && zmax<1 && wmin>zmax*p.wn/(2*p.zeta), ...
    'Salaris:BoundAssumptions','Riesaminare le maggiorazioni per i nuovi intervalli.');
alpha=max(abs([wmin wmax].^2/p.wn^2-1));
beta=max(abs(2*p.zeta/p.wn*[wmin wmax].^2-2*[zmin;zmax]*[wmin wmax]),[],'all');
boundR=1+(alpha+beta/(2*wmin))/zmin;
boundQR=hypot(alpha,beta/wmin)*max(1,poleWeight/wmin)/zmin;
boundQD=max(abs([tmin tmax]-p.delay))*max(poleWeight,2/tmin);
residualRatioBound=sqrt(12/(2.25^3));
scale=boundQR+boundQD+2*u.weightSafetyFactor*boundR*residualRatioBound;
WA=scale*base;
[G0,~]=build_nominal_actuator(p);
% Un solo blocco PIENO 2x2: ammette anche accoppiamenti fra gli attuatori.
A=G0*eye(2)+H0*WA*ultidyn('Dact_full',[2 2]);
Adiag=G0*eye(2)+H0*WA*blkdiag(ultidyn('Dact_diag1',[1 1]),ultidyn('Dact_diag2',[1 1]));
models.names=["A_full","A_diagonal","B_parametric"];
models.actuators={A,Adiag,B}; models.plants=cell(1,3);
root=fileparts(fileparts(fileparts(mfilename('fullpath'))));
m5=load(fullfile(root,'results/data/m5_performance_specs.mat'),'BdFull');
mechanical=uss(mech.A,[mech.B m5.BdFull(1:8,:)],mech.C,zeros(4,4));
mechanical.InputName={'tau1','tau2','d1','d2'};
mechanical.OutputName={'q1','q2','theta1','theta2'};
for j=1:3
    act=models.actuators{j}; act.InputName={'u1','u2'}; act.OutputName={'tau1','tau2'};
    models.plants{j}=connect(mechanical,act,{'u1','u2','d1','d2'}, ...
        {'q1','q2','theta1','theta2'});
end
models.WA=WA; models.Wres=Wres; models.H0=H0;
models.coverage=table(omega',envelope',reshape(abs(freqresp(WA,omega)),[],1), ...
    'VariableNames',{'Omega','EnvelopeB','WeightA'});
models.coverageClaim="B incluso in A_diagonal incluso in A_full: maggiorazione analitica triangolare, con peso comune";
models.weightBounds=struct('alpha',alpha,'beta',beta,'R',boundR,'QR',boundQR, ...
    'QD',boundQD,'residualRatioBound',residualRatioBound,'scale',scale,'sampleScale',sampleScale);
models.family=family.metadata;
end
