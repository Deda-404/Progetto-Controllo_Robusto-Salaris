function [Cq, Dq, Cmeas, Dmeas] = sea_output_matrices
%SEA_OUTPUT_MATRICES Performance and candidate measurement selections.
%   State order is [q; qdot; theta; thetadot]. Cq selects q, while Cmeas
%   selects the four encoder positions [q; theta].

Cq = [eye(2), zeros(2, 6)];
Dq = zeros(2, 2);

Cmeas = [ ...
    eye(2), zeros(2, 6); ...
    zeros(2, 4), eye(2), zeros(2, 2)];
Dmeas = zeros(4, 2);
end
