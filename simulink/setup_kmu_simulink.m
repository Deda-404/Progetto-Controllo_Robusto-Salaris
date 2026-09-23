function model=setup_kmu_simulink(overrides)
%SETUP_KMU_SIMULINK Open Valerio-derived model with explicit artifact setup.
if nargin<1, overrides=struct; end
root=fileparts(fileparts(mfilename('fullpath')));
model='SEA_Kmu_integrated';
open_system(fullfile(root,'simulink/models',[model '.slx']));
setup_simulink_integration("Kmu",model,overrides);
end
