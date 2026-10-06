function linear=evaluate_lqgi_noise(result,m3,m5)
%EVALUATE_LQGI_NOISE Chiusura completa lineare con gli stessi campioni ZOH NL.
% Stato [x;xi;xhat]: il processo ignoto entra solo nella pianta reale.
base=result.linear.closedLoop;
Bw=[m5.BdFull,m3.Bfull;zeros(16,4)];
system=ss(base.A,[base.B,Bw],base.C,zeros(8,12));
discrete=c2d(system,result.config.simulation.inputTimeStep,'zoh');
linear=cell(3,1);
for k=1:3
    v=result.noise{k}.simulation;
    input=[v.reference,v.disturbance,v.measurementNoise,v.processNoise];
    [y,t,z]=lsim(discrete,input,v.time);
    u=y(:,5:6);error=v.reference-y(:,1:2);
    linear{k}=struct('time',t,'output',y,'state',z, ...
        'peakU',max(abs(u),[],'all'),'rmsU',sqrt(mean(u.^2,'all')), ...
        'rmsErrorTrue',sqrt(mean(error.^2,'all')), ...
        'maximumQDifferenceNonlinear',max(abs(y(:,1:2)- ...
            (v.xMechanical(:,1:2)-m3.xbar(1:2)')),[],'all'));
end
end
