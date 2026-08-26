function [controllers, audits] = load_m16_frozen_controllers( ...
    projectRoot, config)
%LOAD_M16_FROZEN_CONTROLLERS Load M6, M10 and M13 without reconstruction.

arguments
    projectRoot (1, 1) string
    config (1, 1) struct = monte_carlo_specs_m16
end

sources = cell(3, 1);
for index = 1:3
    sources{index} = load(fullfile(projectRoot, ...
        config.controllerSources(index)));
end

frozenSystems = {sources{1}.Klqg, sources{2}.Khinf, sources{3}.Kmu};
architectures = ["REFERENCE_PLUS_Q_THETA"; "Q_ONLY_ERROR"; ...
    "Q_ONLY_ERROR"];
measurementCounts = [4; 2; 2];
controllerTemplate = struct('id', "", 'K', [], 'order', 0, ...
    'architecture', "", 'measurementCount', 0, 'sourceArtifact', "");
auditTemplate = struct('id', "", 'sourceArtifact', "", ...
    'sourceIdentity', false, 'inputCount', 0, 'outputCount', 0, ...
    'order', 0, 'A', [], 'B', [], 'C', [], 'D', [], ...
    'allFinite', false, 'matrixSignature', [], ...
    'bestIteration', NaN, 'bestIterationIdentity', false);
controllers = repmat(controllerTemplate, 3, 1);
audits = repmat(auditTemplate, 3, 1);
for index = 1:3
    K = ss(frozenSystems{index});
    [A, B, C, D] = ssdata(K);
    controllers(index).id = config.controllerIDs(index);
    controllers(index).K = K;
    controllers(index).order = order(K);
    controllers(index).architecture = architectures(index);
    controllers(index).measurementCount = measurementCounts(index);
    controllers(index).sourceArtifact = config.controllerSources(index);
    audits(index).id = config.controllerIDs(index);
    audits(index).sourceArtifact = config.controllerSources(index);
    audits(index).sourceIdentity = isequaln(K, ss(frozenSystems{index}));
    audits(index).inputCount = size(K, 2);
    audits(index).outputCount = size(K, 1);
    audits(index).order = order(K);
    audits(index).A = A;
    audits(index).B = B;
    audits(index).C = C;
    audits(index).D = D;
    audits(index).allFinite = all(isfinite([A(:); B(:); C(:); D(:)]));
    audits(index).matrixSignature = [norm(A, 'fro'), norm(B, 'fro'), ...
        norm(C, 'fro'), norm(D, 'fro'), sum(A, 'all'), ...
        sum(B, 'all'), sum(C, 'all'), sum(D, 'all')];
    audits(index).bestIteration = NaN;
    audits(index).bestIterationIdentity = true;
end

audits(3).bestIteration = sources{3}.history.bestIteration;
audits(3).bestIterationIdentity = isequaln(controllers(3).K, ...
    ss(sources{3}.rawInfo(audits(3).bestIteration).K));

assert(isequal([audits.order].', config.expectedControllerOrders), ...
    'M16:ControllerOrder', 'A frozen controller has an unexpected order.');
assert(all([audits.sourceIdentity]) && all([audits.allFinite]) && ...
    audits(3).bestIterationIdentity, 'M16:ControllerIdentity', ...
    'A frozen controller failed its identity audit.');
assert(isequal(size(controllers(1).K), [2, 6]) && ...
    isequal(size(controllers(2).K), [2, 2]) && ...
    isequal(size(controllers(3).K), [2, 2]), ...
    'M16:ControllerDimensions', ...
    'Frozen controller input/output dimensions are inconsistent.');
end
