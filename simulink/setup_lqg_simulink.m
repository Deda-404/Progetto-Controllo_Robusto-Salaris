function model=setup_lqg_simulink(overrides)
%SETUP_LQG_SIMULINK Open Valerio-derived model with explicit artifact setup.
if nargin<1, overrides=struct; end
root=fileparts(fileparts(mfilename('fullpath')));
model='SEA_LQG_integrated';
open_system(fullfile(root,'simulink/models',[model '.slx']));
setup_simulink_integration("LQG",model,overrides);
end
