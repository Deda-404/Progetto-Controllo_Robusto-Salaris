function [A, B, info] = finite_difference_jacobian(rhsFunction, x0, u0, step)
%FINITE_DIFFERENCE_JACOBIAN Centered numerical Jacobian of an RHS function.
%   RHSFUNCTION must accept (x,u). STEP is the absolute centered-difference
%   displacement applied independently to every state and input component.

assert(isa(rhsFunction, 'function_handle'), ...
    'finite_difference_jacobian:InvalidFunction', ...
    'The RHS must be supplied as a function handle.');
assert(isscalar(step) && isfinite(step) && step > 0, ...
    'finite_difference_jacobian:InvalidStep', ...
    'The finite-difference step must be a positive finite scalar.');

x0 = x0(:);
u0 = u0(:);
f0 = rhsFunction(x0, u0);
A = zeros(numel(f0), numel(x0));
B = zeros(numel(f0), numel(u0));

for index = 1:numel(x0)
    displacement = zeros(size(x0));
    displacement(index) = step;
    forward = rhsFunction(x0 + displacement, u0);
    backward = rhsFunction(x0 - displacement, u0);
    A(:, index) = (forward - backward) / (2 * step);
end

for index = 1:numel(u0)
    displacement = zeros(size(u0));
    displacement(index) = step;
    forward = rhsFunction(x0, u0 + displacement);
    backward = rhsFunction(x0, u0 - displacement);
    B(:, index) = (forward - backward) / (2 * step);
end

info.step = step;
info.method = 'centered finite differences';
info.functionEvaluations = 2 * (numel(x0) + numel(u0));
end
