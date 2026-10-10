function captured=run_capture(scriptPath)
% Script clearvars resets this function workspace, then results are captured.
run(scriptPath);
names=who;
captured=struct;
for index=1:numel(names)
    name=names{index}; value=eval(name);
    if isa(value,'matlab.graphics.Graphics') || isa(value,'onCleanup'), continue; end
    captured.(name)=value;
end
end
