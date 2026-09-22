function risultati = run_hinf_final_lyapunov(makeFigures)
%VALIDATE_LYAPUNOV_RAS Lyapunov nominale per LQG, Hinf e Kmu congelati.
% Distingue: limite analitico sufficiente; livello numerico campionato;
% traiettorie empiriche M8/M15. Non modifica controllori o pesi.
arguments
    makeFigures (1,1) logical = false
end
root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
cartella = fullfile(root,'results','data');
m3 = load(fullfile(cartella,'m3_nominal_actuated_plant.mat'));
folder=fullfile(cartella,'hinf_final_coherent');
a=load(fullfile(folder,'selected_full_order.mat')); kh=a.selected.K;
a=load(fullfile(folder,'m13.mat')); km=a.synthesis.K;
controllori={kh(:,3:4),km(:,3:4)};
nomi=["HinfFinal";"MuFinal"];
% Parametri numerici pubblici, non di tuning dei controllori.
config = struct('seed',20260908,'randomDirections',512, ...
    'validationDirections',2048,'planeDirections',72, ...
    'radialFractions',[0.25;0.5;0.75;1], ...
    'levels',49,'bisections',12,'negativeMargin',0.05, ...
    'angleLimitDeg',60,'levelSafetyFactor',0.8);
statoRng = rng; ripristinaRng = onCleanup(@() rng(statoRng));
risultati = cell(2,1);
for k=1:2
    [Ac,Bc,Cc,Dc] = ssdata(controllori{k});
    Cy = m3.CfullQ;

    A = m3.Afull; B = m3.Bfull;
    Acl = [A+B*Dc*Cy,B*Cc;Bc*Cy,Ac];
    n = size(Acl,1);
    assert(max(real(eig(Acl)))<0,'Lyapunov:Unstable','Acl non Hurwitz.');
    QL = eye(n);
    P = lyap(Acl',QL); P = (P+P')/2;
    try
        limite = lyapunov_cubic_bound(Acl,P,m3);
    catch err
        risultati{k}=struct('name',nomi(k),'Acl',Acl,'QL',QL,'P',P, ...
            'config',config,'validationPassed',false,'rhoNumerical',NaN, ...
            'bound',struct('rhoCertified',NaN,'lambdaMinP',min(eig(P)), ...
                'residualNorm',norm(Acl'*P+P*Acl+eye(n),2)), ...
            'status',"NUMERICAL_GATE_FAILED",'error',string(getReport(err,'extended','hyperlinks','off')));
        fprintf('%s: Lyapunov numerical gate FAIL, eigmin(P)=%g residual=%g\n', ...
            nomi(k),risultati{k}.bound.lambdaMinP,risultati{k}.bound.residualNorm);
        save(fullfile(folder,'lyapunov_study.mat'),'risultati','config','-v7');
        continue
    end
    [Aa,Ba,Ca,Da] = ssdata(m3.GactuatorsMimo);
    modello = struct('Ac',Ac,'Bc',Bc,'Cc',Cc,'Dc',Dc,'Cy',Cy, ...
        'Aact',Aa,'Bact',Ba,'Cact',Ca,'Dact',Da, ...
        'xbar',m3.xbar,'taubar',m3.taubar,'parametri',m3.mechanicalParams, ...
        'residuoEquilibrio',sea_nonlinear_rhs(m3.xbar,m3.taubar,m3.mechanicalParams));
    % Sezione, NON proiezione: z=J*dq, dtheta=dq, resto nullo.
    J = zeros(n,2); J(1:2,:)=eye(2); J(5:6,:)=eye(2);
    H = J'*P*J;
    rng(config.seed+k+1,'twister');
    angoli = (0:config.planeDirections-1)*2*pi/config.planeDirections;
    direzioniPiano=chol(P)*J*[cos(angoli);sin(angoli)];
    direzioni = [eye(n),-eye(n),randn(n,config.randomDirections),direzioniPiano];
    direzioni = direzioni./vecnorm(direzioni);
    inversaP = P\eye(n);
    rhoMax = deg2rad(config.angleLimitDeg)^2 / ...
        max(diag(inversaP([1,2,5,6],[1,2,5,6])));
    livelli = logspace(log10(limite.rhoCertified),log10(rhoMax),config.levels);
    massimi = NaN(size(livelli)); ultimo=0; primoFallimento=NaN;
    for j=1:numel(livelli)
        rapporti = lyapunov_sample_ratios(livelli(j),direzioni, ...
            config.radialFractions,P,modello);
        massimi(j)=max(rapporti,[],'all');
        if massimi(j)>=-config.negativeMargin
            primoFallimento=j; break
        end
        ultimo=j;
    end
    assert(ultimo>0,'Lyapunov:NoSampleLevel','Fallimento anche al livello interno.');
    basso=livelli(ultimo);
    if isfinite(primoFallimento)
        alto=livelli(primoFallimento);
        for j=1:config.bisections
            medio=sqrt(basso*alto);
            rapporti=lyapunov_sample_ratios(medio,direzioni, ...
                config.radialFractions,P,modello);
            if max(rapporti,[],'all') < -config.negativeMargin
                basso=medio;
            else
                alto=medio;
            end
        end
    end
    rhoNumerico=config.levelSafetyFactor*basso;
    ricerca=lyapunov_sample_ratios(rhoNumerico,direzioni, ...
        config.radialFractions,P,modello);
    rng(config.seed+100+k+1,'twister');
    verifica=randn(n,config.validationDirections);
    verifica=verifica./vecnorm(verifica);
    controllo=lyapunov_sample_ratios(rhoNumerico,verifica, ...
        config.radialFractions,P,modello);
    % Lo stato della verifica indipendente viene conservato anche se FAIL.
    risultati{k}=struct('name',nomi(k),'Acl',Acl,'QL',QL,'P',P, ...
        'model',modello,'bound',limite,'J',J,'sectionP',H, ...
        'config',config,'rhoNumerical',rhoNumerico,'rhoSearchMaximum',rhoMax, ...
        'searchLevels',livelli,'searchMaxRatios',massimi, ...
        'firstFailedLevelIndex',primoFallimento, ...
        'searchPointCount',numel(ricerca), ...
        'validationPointCount',numel(controllo), ...
        'maxSearchRatio',max(ricerca,[],'all'), ...
        'maxValidationRatio',max(controllo,[],'all'), ...
        'validationPassed',all(controllo < -config.negativeMargin,'all'), ...
        'coordinateMaxAbs',sqrt(rhoNumerico*diag(inversaP)), ...
        'certificationScope',"ANALYTIC_SUFFICIENT_BOUND_NOMINAL_MODEL_DOUBLE_PRECISION", ...
        'samplingScope',"FINITE_POINTS_NOT_A_CERTIFICATE");
    fprintf('%s: n=%d, eigP=[%.4g,%.4g], residuo=%.3g, rho interno=%.4g, numerico=%.4g, Vdot/||z||^2 verifica=%.4g\n', ...
        nomi(k),n,limite.lambdaMinP,limite.lambdaMaxP,limite.residualNorm, ...
        limite.rhoCertified,rhoNumerico,max(controllo,[],'all'));
end
save(fullfile(folder,'lyapunov_study.mat'),'risultati','config','-v7');
assert(~makeFigures,'Usare le figure della revisione, senza sovrascrivere la baseline.');
end

