function summary=export_lqgi_validation(result,root,ras)
%EXPORT_LQGI_VALIDATION Figure e tabelle da esperimenti eseguiti, nessun tuning.
if nargin<3,ras=[];end
m3=load(fullfile(root,'results/data/m3_nominal_actuated_plant.mat'));
folder=fullfile(root,'report/figures/lqgi'); if ~isfolder(folder),mkdir(folder);end
colors=[.08 .30 .55;.80 .35 .10];
f=figure('Visible','off','Color','w','Position',[50 50 1150 710]);
tiledlayout(2,2,'TileSpacing','compact','Padding','compact');
for j=1:2
    k=find(cellfun(@(x)x.joint==j && x.amplitudeDeg==5,result.tracking),1);
    v=result.tracking{k}.simulation; q=rad2deg(v.xMechanical(:,1:2)-m3.xbar(1:2)');
    nexttile(j);hold on;
    plot(v.time,q(:,j),'Color',colors(1,:),'LineWidth',1.8);
    plot(v.time,q(:,3-j),'--','Color',colors(2,:),'LineWidth',1.5);
    linear=result.linear.referenceOutput{j};
    plot(result.linear.referenceTime,rad2deg(linear(:,j)),':k','LineWidth',1.2);
    yline(5,'-.','Riferimento','HandleVisibility','off');grid on;
    xlabel('Tempo [s]');ylabel('Deviazione articolare [deg]');title(sprintf('LQGI: r_%d=5 deg',j));
    legend(sprintf('NL q_%d',j),sprintf('NL q_%d',3-j),'Lineare, giunto comandato','Location','southeast');
    nexttile(j+2);hold on;
    plot(v.time,v.controlDelta(:,1),'Color',colors(1,:),'LineWidth',1.7);
    plot(v.time,v.controlDelta(:,2),'--','Color',colors(2,:),'LineWidth',1.5);
    xlabel('Tempo [s]');ylabel('Comando incrementale [N m]');grid on;legend('u_1','u_2','Location','best');
end
localSave(f,'tracking_linear_nonlinear.png',folder,root);
f=figure('Visible','off','Color','w','Position',[50 50 1150 710]);tiledlayout(2,2,'TileSpacing','compact','Padding','compact');
for j=1:2
    k=find(cellfun(@(x)x.joint==j && x.amplitudeNm==.5,result.disturbance),1);
    v=result.disturbance{k}.simulation;
    nexttile(j);hold on;
    plot(v.time,rad2deg(v.xMechanical(:,1:2)-m3.xbar(1:2)'), 'LineWidth',1.6);
    grid on;xlabel('Tempo [s]');ylabel('Deviazione articolare [deg]');title(sprintf('LQGI: r=0, d_%d=0.5 N m',j));legend('q_1','q_2');
    nexttile(j+2);plot(v.time,v.controlDelta,'LineWidth',1.6);grid on;
    xlabel('Tempo [s]');ylabel('Comando incrementale [N m]');legend('u_1','u_2');
end
localSave(f,'disturbance_nonlinear.png',folder,root);
f=figure('Visible','off','Color','w','Position',[50 50 1100 370]);tiledlayout(1,2,'TileSpacing','compact','Padding','compact');
for j=1:2
    k=find(cellfun(@(x)x.joint==j && x.amplitudeNm==.5,result.disturbance),1);
    v=result.disturbance{k}.simulation;nexttile;hold on;
    plot(v.time,rad2deg(v.xMechanical(:,1)-m3.xbar(1)),'Color',colors(1,:),'LineWidth',1.8);
    plot(v.time,rad2deg(v.xMechanical(:,2)-m3.xbar(2)),'--','Color',colors(2,:),'LineWidth',1.7);
    grid on;xlabel('Tempo [s]');ylabel('Delta q [deg]');title(sprintf('d_%d=0.5 N m; r=0',j));legend('q_1','q_2');
end
localSave(f,'disturbance_for_slides.png',folder,root);
f=figure('Visible','off','Color','w','Position',[50 50 1100 640]);tiledlayout(2,1,'TileSpacing','compact');
v=result.noise{2}.simulation; clean=result.noise{1}.simulation;
nexttile;plot(v.time,rad2deg(v.error),'LineWidth',1);grid on;
xlabel('Tempo [s]');ylabel('Errore misurato r-q_{mis} [deg]');legend('e_1','e_2');title('LQGI: quattro encoder indipendenti, r_1=5 deg');
nexttile;plot(v.time,v.controlDelta-clean.controlDelta,'LineWidth',1);grid on;
xlabel('Tempo [s]');ylabel('Incremento di comando da rumore [N m]');legend('Delta u_1','Delta u_2');
localSave(f,'encoder_noise.png',folder,root);
tracking=cellfun(@(x)[x.amplitudeDeg,x.joint,x.metrics],result.tracking,'UniformOutput',false);
disturbance=cellfun(@(x)[x.amplitudeNm,x.joint,x.metrics],result.disturbance,'UniformOutput',false);
noise=cellfun(@(x)[x.experiment,x.peakU,x.rmsU,x.rmsErrorTrue,x.rmsErrorMeasured],result.noise,'UniformOutput',false);
summary=struct('architecture',"u=-Kx*xhat-Ki*xi; xi_dot=r-q_measured", ...
    'controllerOrder',16,'closedLoopOrder',30,'tracking',vertcat(tracking{:}), ...
    'disturbance',vertcat(disturbance{:}),'noise',vertcat(noise{:}), ...
    'equilibriumError',result.equilibriumError,'noiseRepeatError',result.noiseRepeatError, ...
    'noiseSeed',result.noiseSeed,'noiseSampleTime',result.noiseSampleTime, ...
    'maxRealPole',max(real(result.linear.fullPoles)),'saturationEnabled',false);
summary.linearTrackingRmsUNm=cellfun(@(y)sqrt(mean(y(:,5:6).^2,'all')),result.linear.referenceOutput);
if isfield(result,'linearNoise')
    summary.linearNoise=cellfun(@(x)[x.peakU,x.rmsU,x.rmsErrorTrue,x.maximumQDifferenceNonlinear],result.linearNoise,'UniformOutput',false);
end
if ~isempty(ras)
    summary.ras=ras.metrics;
    f=figure('Visible','off','Color','w','Position',[50 50 850 650]);hold on;
    points=ras.allPoints;yes=points.Convergent;
    scatter(points.Dq1Deg(yes),points.Dq2Deg(yes),20,colors(1,:),'filled');
    scatter(points.Dq1Deg(~yes),points.Dq2Deg(~yes),25,colors(2,:),'x');
    b=ras.boundary;plot([b.Dq1Deg;b.Dq1Deg(1)],[b.Dq2Deg;b.Dq2Deg(1)],'k-','LineWidth',1.4);
    axis equal;grid on;xlim([-60 60]);ylim([-60 60]);
    xlabel('Condizione iniziale Delta q_1 [deg]');ylabel('Condizione iniziale Delta q_2 [deg]');
    legend('Convergenti','Non convergenti entro il protocollo','Frontiera radiale stimata','Location','best');
    title('LQGI: sezione empirica, xhat(0)=xi(0)=0, senza saturazioni');
    localSave(f,'ras_empirical.png',folder,root);
end
path=fullfile(root,'results/data/lqgi_validation/summary.json');
fid=fopen(path,'w');assert(fid~=-1);cleanup=onCleanup(@()fclose(fid));fprintf(fid,'%s',jsonencode(summary,PrettyPrint=true));clear cleanup
fid=fopen(fullfile(root,'report/generated/lqgi_validation_results.tex'),'w');assert(fid~=-1);cleanup=onCleanup(@()fclose(fid));
fprintf(fid,'%% Generato da export_lqgi_validation.m, validation.mat e ras.mat.\n');
fprintf(fid,'\\begin{table}[htbp]\\centering\\small\n\\begin{tabular}{rrrrrr}\\toprule\n');
fprintf(fid,'Gradino [deg] & giunto & $T_s$ [s] & OS [\\%%] & picco $u$ [N m] & RMS $u$ [N m] \\\\\n\\midrule\n');
for k=1:numel(result.tracking)
    x=result.tracking{k};v=x.metrics;
    fprintf(fid,'%.4g & %d & %.5g & %.5g & %.5g & %.5g \\\\\n',x.amplitudeDeg,x.joint,v(1),v(2),v(5),v(6));
end
fprintf(fid,'\\bottomrule\\end{tabular}\\caption{LQGI sulle equazioni non lineari SEA: 8 s, stati incrementali iniziali nulli, rumore nullo. $T_s$ usa la media della coda come riferimento finale; non e un limite DC analitico.}\\label{tab:lqgi-nl}\\end{table}\n');
fprintf(fid,'\\begin{table}[htbp]\\centering\\small\n\\begin{tabular}{lrrr}\\toprule\n');
fprintf(fid,'Prova di 4 s & picco $u$ [N m] & RMS $u$ [N m] & RMS errore fisico [rad] \\\\\n\\midrule\n');
labels=["senza rumore","quattro encoder","encoder e processo"];
for k=1:3,x=result.noise{k};fprintf(fid,'%s & %.5g & %.5g & %.5g \\\\\n',labels(k),x.peakU,x.rmsU,x.rmsErrorTrue);end
fprintf(fid,'\\bottomrule\\end{tabular}\\caption{LQGI: stesso riferimento e stesso Kalman; campioni gaussiani ZOH a 2 ms, seed %d. RMS sul transitorio completo, non soltanto rumore a regime.}\\label{tab:lqgi-noise}\\end{table}\n',result.noiseSeed);
fprintf(fid,'\\par\\noindent\\begin{minipage}{\\linewidth}Errore massimo della prova di equilibrio: $\\num{%.6g}$ rad; ripetibilita del comando rumoroso: $\\num{%.6g}$ N m.\\end{minipage}\\par\n',result.equilibriumError,result.noiseRepeatError);
if ~isempty(ras)
    x=ras.metrics;
    fprintf(fid,'Nella sezione RAS convergono %d/%d punti distinti; raggi risolti minimo $\\num{%.6g}$ e massimo $\\num{%.6g}$ gradi. Il comando massimo nei casi convergenti e $\\num{%.6g}$ N m. Sono state eseguite %d integrazioni, incluse %d estensioni temporali.\n',x.numberConvergent,x.numberUniquePoints,x.minimumRadiusDeg,x.maximumRadiusDeg,x.maximumConvergentControlNm,x.numberSimulations,x.extendedHorizonCount);
end
end
function localSave(f,name,folder,root)
set_scientific_figure_style(f);exportgraphics(f,fullfile(folder,name),'Resolution',210);close(f);
out=fullfile(root,'results/figures/lqgi');if ~isfolder(out),mkdir(out);end
copyfile(fullfile(folder,name),fullfile(out,name));
end
