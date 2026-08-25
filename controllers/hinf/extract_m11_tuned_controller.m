function extracted = extract_m11_tuned_controller(tunedBlocks, structure)
%EXTRACT_M11_TUNED_CONTROLLER Convert tuned blocks to an auditable LTI K.

arguments
    tunedBlocks (1, 1) struct
    structure (1, 1) struct
end

blockValues = struct;
for index = 1:numel(structure.blockNames)
    name = char(structure.blockNames(index));
    assert(isfield(tunedBlocks, name), 'M11Extraction:MissingBlock', ...
        'hinfstruct info does not contain an expected tuned block.');
    blockValues.(name) = getValue(tunedBlocks.(name));
end

if structure.definition.Diagonal
    first = blockValues.(char(structure.blockNames(1)));
    second = blockValues.(char(structure.blockNames(2)));
    controller = ss(blkdiag(first, second));
else
    controller = ss(blockValues.(char(structure.blockNames(1))));
end

[A, B, C, D] = ssdata(controller);
assert(isequal(size(controller), [2, 2]) && ...
    all(isfinite(A), 'all') && all(isfinite(B), 'all') && ...
    all(isfinite(C), 'all') && all(isfinite(D), 'all'), ...
    'M11Extraction:InvalidController', ...
    'The extracted controller is not finite and 2-by-2.');

coefficients = struct;
if structure.id == "A1" || structure.id == "A2"
    for index = 1:2
        value = blockValues.(char(structure.blockNames(index)));
        [kp, ki, kd, tf] = piddata(value);
        coefficients.(sprintf('joint%d', index)) = struct( ...
            'Kp', kp, 'Ki', ki, 'Kd', kd, 'Tf', tf);
    end
end

extracted.controller = controller;
extracted.blockValues = blockValues;
extracted.coefficients = coefficients;
extracted.order = order(controller);
extracted.diagonal = structure.definition.Diagonal;
end
