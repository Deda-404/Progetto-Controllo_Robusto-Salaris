function compact_simulink_evidence
%COMPACT_SIMULINK_EVIDENCE Retain uniform samples, omit redundant logsout copies.
root=fileparts(fileparts(mfilename('fullpath'))); folder=fullfile(root,'results/data/simulink_integration');
files=[dir(fullfile(folder,'*_runs.mat'));dir(fullfile(folder,'*_disturbance.mat'))];
for k=1:numel(files)
 path=fullfile(files(k).folder,files(k).name); a=load(path); f=fieldnames(a);
 for j=1:numel(f)
  v=a.(f{j});
  if iscell(v)
   for n=1:numel(v), if isfield(v{n},'logs'), v{n}=rmfield(v{n},'logs'); end; end
  elseif isstruct(v) && isfield(v,'logs'),v=rmfield(v,'logs');
  end
  a.(f{j})=v;
 end
 save(path,'-struct','a','-v7');
end
end
