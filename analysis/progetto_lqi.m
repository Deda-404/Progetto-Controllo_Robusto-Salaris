%% 1 - Confronto LQI M7, separato dal regolatore nominale M6
% LQI usa lo stato vero. Non e un LQG con osservatore integrale.
clearvars; clc; close all;
radice=fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(radice,'src')),genpath(fullfile(radice,'controllers')), ...
    genpath(fullfile(radice,'analysis')));
dati=fullfile(radice,'results','data');
m3=load(fullfile(dati,'m3_nominal_actuated_plant.mat'));
m5=load(fullfile(dati,'m5_performance_specs.mat'));
m6=load(fullfile(dati,'m6_lqg_no_integrator.mat'));
m7=load(fullfile(dati,'m7_augmented_cost_feasibility.mat'));

%% 2 - Errore e memoria: xi_dot=r-Cq*x, xi(0)=0
A=m3.Afull; B=m3.Bfull; Cq=m3.CfullQ; n=size(A,1);
Aaug=[A zeros(n,2);-Cq zeros(2)];
Baug=[B;zeros(2)]; Br=[zeros(n,2);eye(2)];
% x ha 14 stati, xi ne aggiunge 2, in rad*s: totale 16.
% Il prefiltro corregge il guadagno r->q; non integra l'errore da disturbo.

%% 3 - Costo: Q M6 invariata, Qi=wi/xiScale^2, R=rhoU/uScale^2
% Scegliamo il punto intermedio solo per il confronto illustrativo.
% Non e promosso a controllore finale: non soddisfa tutti i target M5.
indice=2; wi=m7.config.manualDesigns.Wi(indice);
rhoU=m7.config.manualDesigns.RhoU(indice);
xiScale=m5.spec.referenceAmplitude*m5.spec.settlingTimeTarget;
Qi=(wi/xiScale^2)*eye(2);
Qaug=blkdiag(m6.Q,Qi);
R=rhoU/m5.spec.uScale^2*eye(2);

%% 4 - Riccati e guadagni: Ki non viene scelto a mano
[Kaug,Pa,poli]=lqr(Aaug,Baug,Qaug,R);
Kx=Kaug(:,1:n); Ki=Kaug(:,n+1:n+2);
residuoARE=norm(Aaug'*Pa+Pa*Aaug-Pa*Baug*(R\(Baug'*Pa))+Qaug,'fro');
erroreK=norm(Kaug-R\(Baug'*Pa),'fro');
assert(norm(Kaug-m7.designs{indice}.Kaug,'fro')<1e-8);
assert(norm(Qaug-m7.designs{indice}.Qaug,'fro')<1e-10);
assert(residuoARE/max(1,norm(Qaug,'fro'))<1e-7 && erroreK<1e-8);
assert(all(real(poli)<0));
rangoZero=rank([-Aaug Baug]);
rangoRosenbrock=rank([A B;Cq zeros(2)]);
assert(rangoZero==16 && rangoRosenbrock==16);
% Il costruttore originale controlla anche PBH ai poli non stabili.
assert(m7.designs{indice}.structural.isStabilizable);
disp('Kx ='); disp(Kx); disp('Ki ='); disp(Ki);
disp(m7.manualComparisonTable);

%% 5 - Chiusura implementata: u=-Kx*x-Ki*xi+Nff*r
% Nff e ricalcolato da Kx: non si riusa il prefiltro M6.
[Nff,infoFF]=build_lqi_reference_feedforward(m3,Kx,m7.config);
Acl=[A-B*Kx -B*Ki;-Cq zeros(2)];
Bcl=[B*Nff m5.BdFull;eye(2) zeros(2)];
Ccl=[Cq zeros(2);-Kx -Ki];
Dcl=[zeros(2,4);Nff zeros(2)];
lqi=ss(Acl,Bcl,Ccl,Dcl);
assert(infoFF.wellConditioned);
assert(norm(lqi-m7.evaluations{indice}.closedLoop([1:2 5:6],:),inf)<1e-8);
% LQI ha 16 stati chiusi; LQG ne ha 28 (14 pianta + 14 osservatore).
lqg=m6.lqgClosedLoop([1:2 5:6],1:4);

%% 6 - Stessa prova: r=0, d=0.5 N*m da t=0, nessun rumore, x0=0
tempo=(0:m7.config.simulationTimeStep:m7.config.disturbanceHorizon)';
sistemi={lqg,lqi}; nomi=["LQG senza integratore";"LQI con azione integrale"];
uscite=cell(2,2); righe=zeros(4,9); riga=0;
for controllo=1:2
    guadagnoDC=dcgain(sistemi{controllo}(:,3:4));
    for giunto=1:2
        ingressi=zeros(numel(tempo),4);
        ingressi(:,giunto+2)=m5.spec.disturbanceTorqueAmplitude;
        y=lsim(sistemi{controllo},ingressi,tempo);
        uscite{controllo,giunto}=y;
        qFinale=guadagnoDC(1:2,giunto)*m5.spec.disturbanceTorqueAmplitude;
        riga=riga+1;
        righe(riga,:)=[controllo giunto qFinale' y(end,1:2) ...
            max(abs(y(:,3:4)),[],'all') sqrt(mean(y(:,3:4).^2,'all')) ...
            max(abs(y(:,1:2)),[],'all')];
    end
end
metriche=array2table(righe,'VariableNames',{'ControllerId','DisturbanceJoint', ...
    'OffsetQ1Rad','OffsetQ2Rad','Q1At8sRad','Q2At8sRad', ...
    'PeakControlNm','RmsControlNm','PeakQRad'});
assert(max(abs(metriche{3:4,3:4}),[],'all')<1e-9);
assert(max(abs(metriche{1:2,3:4}),[],'all')>1e-4);
assert(all(isfinite(metriche{:,:}),'all'));
disp(metriche);

%% 7 - Il solo wi: tre verifiche a rhoU=16, senza selezione o retuning M7
% Nella baseline varia anche R. Qui isoliamo l'effetto di wi a Q,R fissi.
wiDiagnostici=[0.1;1;4]; normeKi=zeros(3,1); poliDominanti=zeros(3,1);
for k=1:3
    Qdiagnostico=blkdiag(m6.Q,wiDiagnostici(k)/xiScale^2*eye(2));
    [Kd,~,pd]=lqr(Aaug,Baug,Qdiagnostico,16/m5.spec.uScale^2*eye(2));
    normeKi(k)=norm(Kd(:,15:16),2);
    poliDominanti(k)=max(real(pd));
end
sensibilitaWi=table(wiDiagnostici,normeKi,poliDominanti);
disp(sensibilitaWi);
% Le norme crescono in queste prove; non e un teorema di monotonia MIMO.

%% 8 - Due figure leggibili: posizioni e coppie, senza scale alterate
nomiFigure=["m7_lqg_lqi_constant_disturbance.png";"m7_lqg_lqi_disturbance_control.png"];
for tipo=1:2
    f=figure('Visible','off','Color','white','Position',[100 100 1150 650]);
    tiledlayout(2,2,'TileSpacing','compact','Padding','compact');
    for giunto=1:2
        for canale=1:2
            nexttile((canale-1)*2+giunto); hold on;
            for controllo=1:2
                y=uscite{controllo,giunto};
                if tipo==1
                    curva=rad2deg(y(:,canale));
                else
                    curva=y(:,canale+2);
                end
                plot(tempo,curva,'LineWidth',1.5,'DisplayName',nomi(controllo));
            end
            yline(0,':k','HandleVisibility','off');
            grid on; box on; xlabel('Tempo [s]');
            if tipo==1, ylabel(sprintf('Delta q_%d [deg]',canale));
            else, ylabel(sprintf('u_%d [N m]',canale)); end
            title(sprintf('d_%d = 0.5 N m, altro disturbo nullo',giunto));
            legend('Location','best');
        end
    end
    set_scientific_figure_style(f);
    exportgraphics(f,fullfile(radice,'results','figures',nomiFigure(tipo)),'Resolution',180);
    close(f);
    copyfile(fullfile(radice,'results','figures',nomiFigure(tipo)), ...
        fullfile(radice,'report','figures',nomiFigure(tipo)));
end

%% 9 - Dati del confronto: nessun artifact M6/M7 sostituito
save(fullfile(dati,'m7_disturbance_comparison.mat'),'wi','rhoU','xiScale','Qi', ...
    'Aaug','Baug','Br','Qaug','R','Pa','Kaug','Kx','Ki','Nff','poli', ...
    'residuoARE','erroreK','rangoZero','rangoRosenbrock','tempo','uscite', ...
    'metriche','sensibilitaWi','indice','nomi','-v7');
writetable(metriche,fullfile(dati,'m7_disturbance_comparison.csv'));
fprintf('Confronto illustrativo: wi=%g, rhoU=%g. M7 resta PARTIAL.\n',wi,rhoU);
