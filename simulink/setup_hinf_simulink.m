function model=setup_hinf_simulink(overrides)
%SETUP_HINF_SIMULINK Open Valerio-derived model with explicit artifact setup.
if nargin<1, overrides=struct; end
root=fileparts(fileparts(mfilename('fullpath')));
model='SEA_Hinf_integrated';
open_system(fullfile(root,'simulink/models',[model '.slx']));
setup_simulink_integration("Hinf",model,overrides);
end
