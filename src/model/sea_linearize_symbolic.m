function [A, B, info] = sea_linearize_symbolic(xbar, taubar, p)
%SEA_LINEARIZE_SYMBOLIC Symbolic Jacobians of the validated M1 RHS.
%   A and B are returned as double matrices evaluated at XBAR, TAUBAR.

assert(numel(xbar) == 8, 'sea_linearize_symbolic:InvalidState', ...
    'The operating state must contain exactly eight elements.');
assert(numel(taubar) == 2, 'sea_linearize_symbolic:InvalidInput', ...
    'The operating input must contain exactly two elements.');
xbar = reshape(xbar, 8, 1);
taubar = reshape(taubar, 2, 1);

xSymbolic = sym('x', [8, 1], 'real');
tauSymbolic = sym('tau', [2, 1], 'real');
fSymbolic = sea_nonlinear_rhs(xSymbolic, tauSymbolic, p);

ASymbolic = jacobian(fSymbolic, xSymbolic);
BSymbolic = jacobian(fSymbolic, tauSymbolic);
substitutionVariables = [xSymbolic; tauSymbolic];
operatingPoint = [xbar; taubar];

A = double(subs(ASymbolic, substitutionVariables, operatingPoint));
B = double(subs(BSymbolic, substitutionVariables, operatingPoint));

info.stateSymbols = xSymbolic;
info.inputSymbols = tauSymbolic;
info.fSymbolic = fSymbolic;
info.ASymbolic = ASymbolic;
info.BSymbolic = BSymbolic;
end
