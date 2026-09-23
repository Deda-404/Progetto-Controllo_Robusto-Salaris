function model=setup_lqri_simulink(overrides)
%SETUP_LQRI_SIMULINK Open Valerio-derived model with explicit artifact setup.
if nargin<1, overrides=struct; end
root=fileparts(fileparts(mfilename('fullpath')));
model='SEA_LQRI_integrated';
open_system(fullfile(root,'simulink/models',[model '.slx']));
setup_simulink_integration("LQRI",model,overrides);
end
