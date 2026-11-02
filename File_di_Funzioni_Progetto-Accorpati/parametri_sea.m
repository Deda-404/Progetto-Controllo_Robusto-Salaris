function p=parametri_sea
%PARAMETRI_SEA Unica configurazione del percorso didattico corrente.
p.cartella=fileparts(mfilename('fullpath'));
p.dati=fullfile(p.cartella,'dati'); p.risultati=fullfile(p.cartella,'risultati');
if ~isfolder(p.risultati),mkdir(p.risultati);end
p.modalita=string(getenv('SEA_MODALITA'));
if p.modalita=="",p.modalita="rapida";end
assert(ismember(p.modalita,["rapida","completa"]),'SEA:Modo','Usare rapida o completa.');
p.figure=true; p.seed=20261101; p.campioni=10;
p.mEE=.2; p.rmEE=.50; p.masseCandidate=[.1 .2 .3];
p.ritardiCandidati=[.10 .20 .30];
p.wn=40; p.zeta=.8; p.ritardo=.015;
p.rwn=.10; p.rzeta=.10; p.rritardo=.20; % Ipotesi, non tolleranze misurate.
p.omega=logspace(-3,4,601); p.omegaMu=logspace(-2,4,121);
p.tempo=(0:.002:12)'; p.rasTempo=(0:.02:15)';
p.tempoRumore=(0:.002:4)';
p.rasRaggi=deg2rad([5 15 30]); p.rasDirezioni=(0:4)'*2*pi/5;
p.rasPosTol=deg2rad(.5); p.rasVelTol=deg2rad(.5);
p.timeout=30; p.limiteNumerico=1e8;
p.rasUTol=.05; p.sogliaPosizione=4*pi; p.sogliaVelocita=1000;
p.dkIterazioni=3; p.dkFit=[2 1]; p.pidAvvii=2;
p.tolNominale=1e-8; p.marginePeso=1.02; p.eccessoPesoMax=1.6;
p.omegaW1=2; p.As=.15; p.Ms=3; p.ku=.003; p.omegaU=80; p.alpha=6; p.omegaM=3;
p.rAmp=deg2rad(5); p.dAmp=.5; p.sigmaY=deg2rad(.05);
% A: stabilita e soglie normalizzate <1, imposte dalla matematica.
% B: target scelti dagli studenti; nessun cambiamento delle definizioni RS/RP.
p.Ts=2; p.Mp=15; p.ess=.05; p.cross=.25;
p.specificheCandidate=[.8 10 .05 .25;1.5 15 .05 .25;2 15 .05 .25];
% C: coppia, picco/RMS del rumore e recupero sono diagnostici senza dati hardware.
p.recuperoTol=deg2rad(.5); % Diagnostica, non soglia di robustezza.
p.firma=[2 p.mEE p.rmEE p.wn p.zeta p.ritardo p.rwn p.rzeta p.rritardo ...
    p.omegaW1 p.As p.Ms p.ku p.omegaU p.alpha p.omegaM p.seed ...
    p.campioni p.dkIterazioni p.dkFit p.pidAvvii p.Ts p.Mp p.ess p.cross ...
    p.rAmp p.dAmp p.sigmaY p.tempo(end) p.rasTempo(end) p.rasRaggi ...
    p.rasPosTol p.rasVelTol p.rasUTol p.timeout];
assert(license('test','Control_Toolbox'),'SEA:Toolbox','Manca Control System Toolbox.');
assert(license('test','Robust_Toolbox'),'SEA:Toolbox','Manca Robust Control Toolbox.');
end
