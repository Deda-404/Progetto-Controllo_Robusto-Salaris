function salaris_check_comparison
%SALARIS_CHECK_COMPARISON Controllo numerico delle inclusioni fra famiglie.
root=fileparts(fileparts(fileparts(mfilename('fullpath'))));
folder=fullfile(root,'results/data/salaris_revision');
tab=readtable(fullfile(folder,'comparison.csv'),'TextType','string');
tab.NestingConsistent=true(height(tab),1);
for name=unique(tab.Controller)'
    index=find(tab.Controller==name);
    % Ordine per costruzione: A_full, A_diagonal, B_parametric.
    for j=1:2
        broad=index(j); narrow=index(j+1);
        if tab.RSLower(broad)>tab.RSUpper(narrow)*(1+1e-6)
            tab.NestingConsistent([broad narrow])=false;
            tab.RSOutcome([broad narrow])="NUMERICAL_INCONCLUSIVE_NESTING";
            tab.RPOutcome([broad narrow])="NUMERICAL_INCONCLUSIVE_NESTING";
        end
    end
end
% Quando NP fallisce, il margine RP e esattamente zero gia al nominale.
tab.RPLower(~tab.NP)=0; tab.RPUpper(~tab.NP)=0;
tab.RPOutcome(~tab.NP)="FAIL_NOMINAL_PERFORMANCE";
writetable(tab,fullfile(folder,'comparison.csv'));
fprintf('Controllo inclusioni: %d righe con margini quantitativi inconclusivi.\n',sum(~tab.NestingConsistent));
end
