function comparison = plot_lqri_revision
%PLOT_LQRI_REVISION Confronto nominale LQG/LQRI e tabelle da dati eseguiti.
%   Nessuna sintesi: riusa i risultati M7. M6 e simulato agli stessi tempi,
%   con gli stessi riferimenti, disturbi, rumore nullo e stati iniziali nulli.
root=fileparts(fileparts(fileparts(mfilename('fullpath'))));
data=fullfile(root,'results','data');
m5=load(fullfile(data,'m5_performance_specs.mat'));
m6=load(fullfile(data,'m6_lqg_no_integrator.mat'));
m7=load(fullfile(data,'m7_augmented_cost_feasibility.mat'));
j=m7.config.illustrativeIndex; design=m7.designs{j}; ev=m7.evaluations{j};
time=ev.disturbanceTime; trackingTime=ev.referenceTime;
disturbanceOutput=cell(2,2); trackingOutput=cell(2,2);
rows=zeros(4,9); trackingRows=zeros(4,7);
systems={m6.lqgClosedLoop,ev.closedLoop};
for controller=1:2
    % DC risolto dalla chiusura completa, senza interpretare il campione
    % finale della simulazione come un limite asintotico esatto.
    dc=dcgain(systems{controller});
    for joint=1:2
        input=zeros(numel(time),8); input(:,joint+2)=m5.spec.disturbanceTorqueAmplitude;
        refInput=zeros(numel(trackingTime),8); refInput(:,joint)=m5.spec.referenceAmplitude;
        if controller==1
            yd=lsim(systems{controller},input,time);
            yr=lsim(systems{controller},refInput,trackingTime);
        else
            yd=ev.disturbanceOutput{joint}; yr=ev.referenceOutput{joint};
        end
        disturbanceOutput{controller,joint}=yd;
        trackingOutput{controller,joint}=yr;
        idx=2*(controller-1)+joint;
        finalQ=dc(1:2,joint+2)*m5.spec.disturbanceTorqueAmplitude;
        rows(idx,:)=[controller,joint,finalQ',yd(end,1:2), ...
            max(abs(yd(:,5:6)),[],'all'),sqrt(mean(yd(:,5:6).^2,'all')), ...
            max(abs(yd(:,1:2)),[],'all')];
        target=refInput(end,1:2);
        trackingRows(idx,:)=[controller,joint, ...
            (dc(1:2,1:2)*target'-target')', ...
            max(abs(yr(:,5:6)),[],'all'),max(abs(yr(end,1:2)-target)), ...
            max(abs(yr(:,1:2)),[],'all')];
    end
end
metriche=array2table(rows,'VariableNames',{'ControllerId','DisturbanceJoint', ...
    'OffsetQ1Rad','OffsetQ2Rad','Q1At8sRad','Q2At8sRad', ...
    'PeakControlNm','RmsControlNm','PeakQRad'});
trackingMetrics=array2table(trackingRows,'VariableNames',{'ControllerId','ReferenceJoint', ...
    'ErrorDcQ1Rad','ErrorDcQ2Rad','PeakControlNm','FinalErrorRad','PeakQRad'});
comparison=design;
comparison.metriche=metriche; comparison.trackingMetrics=trackingMetrics;
comparison.tempo=time; comparison.trackingTime=trackingTime;
comparison.uscite=disturbanceOutput; comparison.trackingOutput=trackingOutput;
comparison.L=m6.L; comparison.Qn=m6.Qn; comparison.Rn=m6.Rn;
comparison.closedLoop=ev.closedLoop; comparison.fullPoles=ev.fullPoles;
comparison.separationResidual=ev.separationResidual;
comparison.architecture=m7.validationMetrics.architecture;
save(fullfile(data,'m7_disturbance_comparison.mat'),'-struct','comparison','-v7');
writetable(metriche,fullfile(data,'m7_disturbance_comparison.csv'));
writetable(trackingMetrics,fullfile(data,'m7_lqri_tracking_comparison.csv'));

% Le due figure di disturbo usano scale comuni e la stessa legenda.
names=["m7_lqg_lqri_constant_disturbance.png","m7_lqg_lqri_disturbance_control.png"];
for kind=1:2
    f=figure('Visible','off','Color','white','Position',[100,100,1050,580]);
    tiledlayout(2,2,'TileSpacing','compact','Padding','compact');
    for joint=1:2
        for channel=1:2
            nexttile(2*(channel-1)+joint); hold on;
            for controller=1:2
                y=disturbanceOutput{controller,joint};
                if kind==1, value=rad2deg(y(:,channel));
                else, value=y(:,channel+4); end
                plot(time,value,'LineWidth',1.4);
            end
            yline(0,':k','HandleVisibility','off'); grid on;
            xlabel('Tempo [s]');
            if kind==1, ylabel(sprintf('Delta q_%d [deg]',channel));
            else, ylabel(sprintf('u_%d [N m]',channel)); end
            title(sprintf('d_%d=0.5 N m; r=0',joint));
            legend('LQG M6','LQRI M7','Location','best');
        end
    end
    localSaveFigure(f,names(kind),root);
end
% Tracking e comandi sono mostrati insieme, per entrambi i gradini.
f=figure('Visible','off','Color','white','Position',[100,100,1150,840]);
tiledlayout(3,2,'TileSpacing','compact','Padding','compact');
for joint=1:2
    nexttile(joint); hold on;
    for controller=1:2
        y=trackingOutput{controller,joint};
        plot(trackingTime,rad2deg(y(:,joint)),'LineWidth',1.4);
    end
    yline(rad2deg(m5.spec.referenceAmplitude),'--k','Riferimento');
    xlabel('Tempo [s]'); ylabel(sprintf('Delta q_%d [deg]',joint)); grid on;
    title(sprintf('r_%d=5 deg; altro riferimento nullo',joint));
    legend('LQG M6','LQRI M7','Riferimento','Location','best');
    nexttile(joint+2); hold on;
    for controller=1:2
        y=trackingOutput{controller,joint};
        plot(trackingTime,y(:,5:6),'LineWidth',1.2);
    end
    xlabel('Tempo [s]'); ylabel('Comando [N m]'); grid on;
    legend('M6 u_1','M6 u_2','M7 u_1','M7 u_2','Location','best');
    nexttile(joint+4);
    plot(trackingTime,trackingOutput{2,joint}(:,7:8),'LineWidth',1.3);
    xlabel('Tempo [s]'); ylabel('Integrale xi [rad s]'); grid on;
    legend('xi_1','xi_2','Location','best');
end
localSaveFigure(f,'m7_lqri_reference_tracking.png',root);
localWriteTables(root,comparison,m7);
disp(metriche);
end

function localSaveFigure(f,name,root)
% Stile scientifico comune e copia identica dell'asset nella relazione.
set_scientific_figure_style(f);
path=fullfile(root,'results','figures',name);
exportgraphics(f,path,'Resolution',180); close(f);
copyfile(path,fullfile(root,'report','figures',name));
end

function localWriteTables(root,c,m7)
% Matrici arrotondate soltanto per il PDF; i MAT conservano doppia precisione.
path=fullfile(root,'report','generated','lqri_revision_results.tex');
f=fopen(path,'w'); assert(f~=-1,'M7LQRI:Write','Impossibile scrivere la tabella.');
cleanup=onCleanup(@() fclose(f));
fprintf(f,'%% Generato da plot_lqri_revision.m; dati della chiusura reale.\n');
fprintf(f,'\\[w_i=%.5g,\\quad Q_i=%.7g I_2,\\quad R=\\tfrac{1}{9}I_2.\\]\n',c.wi,c.Qi(1,1));
fprintf(f,'\\[K_x=[K_{x,a}\\ K_{x,b}].\\]\n{\\small\n');
localMatrix(f,'K_{x,a}',c.Kx(:,1:7)); localMatrix(f,'K_{x,b}',c.Kx(:,8:14));
localMatrix(f,'K_i',c.Ki); fprintf(f,'}\n');
fprintf(f,['Residuo relativo CARE: $\\num{%.8g}$; residuo del guadagno: ' ...
    '$\\num{%.8g}$; residuo della trasformazione di separazione: $\\num{%.8g}$.\n'], ...
    c.careRelativeResidual,c.gainResidual,c.separationResidual);
fprintf(f,'Parte reale dominante della chiusura completa: $\\num{%.9g}$ s$^{-1}$.\n',max(real(c.fullPoles)));
% Il paragrafo numerico precede le tabelle flottanti e resta indiviso.
fprintf(f,['Il massimo residuo LQRI a 8 s nei due esperimenti vale $\\num{%.8g}$ rad; ' ...
    'non coincide con il valore asintotico.\\par\n'],max(abs(c.metriche{3:4,5:6}),[],'all'));
fprintf(f,'\\begin{table}[htbp]\\centering\\small\n\\begin{tabular}{rrrrr}\\toprule\n');
fprintf(f,'$w_i$ & $\\|K_i\\|_2$ & $T_s$ [s] & OS [\\%%] & picco $u$ [N m] \\\\\n\\midrule\n');
for k=1:3
    t=m7.manualComparisonTable(k,:);
    fprintf(f,'%.4g & %.5g & %s & %.5g & %.5g \\\\\n', ...
        t.Wi,norm(m7.designs{k}.Ki,2),localNumber(t.WorstSettlingTime),t.WorstOvershoot,t.PeakControl);
end
fprintf(f,['\\bottomrule\\end{tabular}\\caption{LQRI: tre valori di $w_i$ a $Q$ e $R=(1/9)I_2$ fissi. ' ...
    'Gradini di 5 gradi, 8 s; $\\infty$ indica mancato assestamento entro 8 s.}\\label{tab:lqri-wi}\\end{table}\n']);
fprintf(f,'\\begin{table}[htbp]\\centering\\small\n\\begin{tabular}{llrrrr}\\toprule\n');
fprintf(f,'Controllo & Disturbo & $q_1(\\infty)$ & $q_2(\\infty)$ & picco $u$ & RMS $u$ \\\\\n\\midrule\n');
for k=1:4
    t=c.metriche(k,:); names=["LQG","LQRI"];
    fprintf(f,'%s & $d_%d$ & %.6g & %.6g & %.6g & %.6g \\\\\n', ...
        names(t.ControllerId),t.DisturbanceJoint,t.OffsetQ1Rad,t.OffsetQ2Rad,t.PeakControlNm,t.RmsControlNm);
end
fprintf(f,['\\bottomrule\\end{tabular}\\caption{Disturbi separati da 0.5 N m; posizioni DC in rad, ' ...
    'coppie in N m. Picco e RMS su entrambi i comandi negli stessi 8 s.}\\label{tab:lqri-disturbi}\\end{table}\n']);
end

function localMatrix(f,name,M)
% Due blocchi 2x7 mantengono il guadagno completo leggibile nel PDF.
fprintf(f,'\\[%s=\\begin{bmatrix}\n',name);
for row=1:size(M,1)
    fprintf(f,'%s \\\\\n',strjoin(compose('%.6g',M(row,:)),' & '));
end
fprintf(f,'\\end{bmatrix}.\\]\n');
end

function s=localNumber(x)
% Il mancato assestamento non viene sostituito da un numero finito.
if isinf(x), s='$\infty$'; else, s=sprintf('%.5g',x); end
end
