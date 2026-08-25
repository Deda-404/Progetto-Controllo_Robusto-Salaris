function model = build_m12_uncertain_generalized_plant( ...
    GuncQ, W1, W2, controller, config)
%BUILD_M12_UNCERTAIN_GENERALIZED_PLANT Build Punc with one shared plant.

arguments
    GuncQ uss
    W1 {mustBeA(W1, {'ss', 'tf', 'zpk'})}
    W2 {mustBeA(W2, {'ss', 'tf', 'zpk'})}
    controller {mustBeA(controller, {'ss', 'tf', 'zpk'})}
    config (1, 1) struct = mu_analysis_specs_m12
end

assert(isequal(size(GuncQ), [2, 2]) && ...
    isequal(size(W1), [2, 2]) && isequal(size(W2), [2, 2]) && ...
    isequal(size(controller), [2, 2]), ...
    'M12GeneralizedPlant:Dimensions', ...
    'GuncQ, W1, W2 and K must all be 2-by-2.');

GuncQ.InputName = {'u(1)'; 'u(2)'};
GuncQ.OutputName = {'q(1)'; 'q(2)'};
W1 = ss(W1);
W1.InputName = {'e(1)'; 'e(2)'};
W1.OutputName = {'z1(1)'; 'z1(2)'};
W2 = ss(W2);
W2.InputName = {'u(1)'; 'u(2)'};
W2.OutputName = {'z2(1)'; 'z2(2)'};
errorSum = sumblk('e = r - q', 2);

inputNames = {'r(1)', 'r(2)', 'u(1)', 'u(2)'};
outputNames = {'z1(1)', 'z1(2)', 'z2(1)', 'z2(2)', ...
    'e(1)', 'e(2)'};
Punc = connect(GuncQ, W1, W2, errorSum, inputNames, outputNames);
TzwUnc = lft(Punc, ss(controller));

assert(isequal(size(Punc), [6, 4]) && ...
    isequal(size(TzwUnc), [4, 2]), ...
    'M12GeneralizedPlant:Interconnection', ...
    'Punc or Tzw_unc has an unexpected dimension.');

model.Punc = Punc;
model.TzwUnc = TzwUnc;
model.inputNames = string(Punc.InputName);
model.outputNames = string(Punc.OutputName);
model.singleSharedPlantConstruction = true;
model.formula = "[W1,-W1*GuncQ;0,W2;I,-GuncQ]";
model.gammaTarget = config.gammaTarget;
end
