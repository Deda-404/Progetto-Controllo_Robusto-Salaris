function c = hinf_revision_config
%HINF_REVISION_CONFIG Target dichiarati prima della campagna, separati da M5.
c.version = 1;
c.omega = logspace(-4,4,2401);
c.time = (0:0.002:12)';
c.alpha = 6;
% Dodici casi accoppiati: quattro profili W1 e tre profili W2.
% Non e il prodotto cartesiano di tutti i singoli parametri suggeriti.
c.initialW1 = [4 .20 4; 5 .15 3; 6 .10 3; 8 .08 2.5];
c.initialW2 = [.03 80; .04 60; .05 50];
% Unico ampliamento consentito: piu autorita di comando e tracking lento.
% Il corner W1 non e la banda del loop stabilizzante.
c.extendedW1 = [2 .20 4; 3 .20 4; 4 .20 4];
c.extendedW2 = [.003 80; .005 80; .01 80];
c.revised = struct('settlingTime',2,'overshootPercent',20, ...
    'steadyErrorRelative',.20,'crossCoupling',.25);
c.randomStart = 10;
c.seed = 20260917;
c.maxIter = 300;
c.gammaTolerance = 2e-3;
c.mapTolerance = 1e-5;
c.stabilityTolerance = 1e-8;
end
