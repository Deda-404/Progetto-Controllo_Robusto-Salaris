function tidy_simulink_integration(model)
%TIDY_SIMULINK_INTEGRATION Place only corrected/new blocks outside original core.
a=get_param([model '/Actuators'],'Position'); x=a(1); y=a(2);
set_param([model '/Sum1'],'Position',[x-40 y+33 x-20 y+53]);
set_param([model '/Constant'],'Position',[x-85 y+115 x-45 y+145]);
set_param([model '/Actuator deviations'],'Position',[x+20 1140 x+95 1170]);
set_param([model '/Actuator state logging'],'Position',[x+170 1140 x+190 1160]);
if (contains(model,'Hinf') || contains(model,'Kmu')) && getSimulinkBlockHandle([model '/Sum'])~=-1
 set_param([model '/Sum'],'Name','Reference and measured q');
end
end
