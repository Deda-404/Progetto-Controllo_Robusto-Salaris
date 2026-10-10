function [K,prove,parametri] = seleziona_pid_hinf(info,Kt,physical,P,W1,W2,Mo,cfg)
% Ogni info(k) e un avvio: si estraggono i blocchi di QUELL'avvio.
n=numel(info); norma=inf(n,1); valida=false(n,1); candidati=cell(n,1);
obiettivo=reshape([info.Objective],[],1);
for j=1:n
    if ~isfinite(obiettivo(j)), continue; end
    Kg=Kt; names=fieldnames(info(j).TunedBlocks);
    for b=1:numel(names)
        Kg=setBlockValue(Kg,names{b},getValue(info(j).TunedBlocks.(names{b})));
    end
    candidati{j}=ss(getValue(Kg));
    e=valuta_avvio_hinf(physical,candidati{j},W1,W2,Mo,cfg,"2DOF");
    norma(j)=e.norma;
    valida(j)=e.stabile && erroreMappe(lft(P,candidati{j}),e.pesato,cfg.omega)<cfg.tolMappe ...
        && abs(obiettivo(j)-norma(j))<.01*max(1,obiettivo(j));
end
ammessi=find(valida);
assert(~isempty(ammessi),'HinfTre:PID','Nessun avvio PID valido.');
[~,ix]=min(obiettivo(ammessi)); best=ammessi(ix);
selezionata=false(n,1); selezionata(best)=true;
prove=table((1:n)',obiettivo,norma,valida,selezionata, ...
    'VariableNames',{'Avvio','Obiettivo','Norma','Valida','Selezionata'});
K=candidati{best};
parametri=parametri_pid_hinf(info(best).TunedBlocks);
end

function err=erroreMappe(prima,seconda,omega)
err=max(abs(freqresp(prima,omega)-freqresp(seconda,omega)),[],'all');
end
