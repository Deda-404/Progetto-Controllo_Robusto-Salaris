function m8_nonlinear_sea_sfun(block)
%M8_NONLINEAR_SEA_SFUN Level-2 S-function for the validated M1 equations.
%   Inputs are motor torque tau and physical link disturbance d. The eight
%   continuous states are [q;qdot;theta;thetadot] in absolute coordinates.

setup(block);
end

function setup(block)
block.NumDialogPrms = 1;
block.DialogPrmsTunable = {'Tunable'};
block.NumInputPorts = 2;
block.NumOutputPorts = 1;
block.NumContStates = 8;
block.SetPreCompPortInfoToDefaults;

block.InputPort(1).Dimensions = 2;
block.InputPort(1).DirectFeedthrough = false;
block.InputPort(2).Dimensions = 2;
block.InputPort(2).DirectFeedthrough = false;
block.OutputPort(1).Dimensions = 8;
block.SampleTimes = [0, 0];
block.SimStateCompliance = 'DefaultSimState';

block.RegBlockMethod('CheckParameters', @checkParameters);
block.RegBlockMethod('InitializeConditions', @initializeConditions);
block.RegBlockMethod('Outputs', @outputs);
block.RegBlockMethod('Derivatives', @derivatives);
end

function checkParameters(block)
initialState = block.DialogPrm(1).Data;
assert(isnumeric(initialState) && isequal(size(initialState), [8, 1]) && ...
    all(isfinite(initialState)), 'M8SFun:InvalidInitialState', ...
    'The nonlinear SEA initial state must be a finite 8-by-1 vector.');
end

function initializeConditions(block)
block.ContStates.Data = block.DialogPrm(1).Data;
end

function outputs(block)
block.OutputPort(1).Data = block.ContStates.Data;
end

function derivatives(block)
p = sea_params_nominal;
block.Derivatives.Data = sea_nonlinear_rhs_with_link_disturbance( ...
    block.ContStates.Data, block.InputPort(1).Data, ...
    block.InputPort(2).Data, p);
end
