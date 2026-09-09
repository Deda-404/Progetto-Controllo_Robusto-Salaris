classdef test_didactic_entry_points < matlab.unittest.TestCase
    %TEST_DIDACTIC_ENTRY_POINTS Struttura didattica e risultati eseguiti.
    properties
        Root
    end
    methods (TestClassSetup)
        function carica(testCase)
            testCase.Root=fileparts(fileparts(mfilename('fullpath')));
            addpath(genpath(fullfile(testCase.Root,'analysis')));
        end
    end
    methods (Test)
        function treScriptSeparati(testCase)
            nomi=["modellazione_linearizzazione_controllo.m","progetto_lqg.m","progetto_hinf.m"];
            testCase.verifyTrue(all(isfile(fullfile(testCase.Root,'analysis',nomi))));
            testCase.verifyFalse(isfile(fullfile(testCase.Root,'analysis','progetto_lqg_hinf.m')));
        end
        function modellazioneCopreTemi(testCase)
            s=string(fileread(fullfile(testCase.Root,'analysis','modellazione_linearizzazione_controllo.m')));
            testCase.verifyTrue(all(contains(s,["Punto di equilibrio","Linearizzazione analitica", ...
                "Incertezze parametriche","Incertezza dinamica","Specifiche di progetto","Pesi sulla sensibilita"])));
        end
        function lqgCalcoliVisibili(testCase)
            s=string(fileread(fullfile(testCase.Root,'analysis','progetto_lqg.m')));
            testCase.verifyTrue(all(contains(s,["lqr(","lqe(","lyap(","Riccati", ...
                "principio di separazione","nBisezioni=12","rhoCertificato"])));
            testCase.verifyFalse(contains(s,'validate_m10_hinfsyn'));
        end
        function hinfCalcoliVisibili(testCase)
            s=string(fileread(fullfile(testCase.Root,'analysis','progetto_hinf.m')));
            testCase.verifyTrue(all(contains(s,["connect(","hinfsyn(","lyap(", ...
                "ricalcolaSintesi=false","rhoCertificato","nBisezioni=12"])));
            testCase.verifyFalse(contains(s,'design_lqr_m6'));
        end
        function confrontoEmpiricoSeparato(testCase)
            s=string(fileread(fullfile(testCase.Root,'analysis','ras','build_common_ras_comparison.m')));
            testCase.verifyTrue(all(contains(s,["commonRasFields","EmpiricalFraction"])));
            testCase.verifyTrue(contains(s,'certifiedRegion','IgnoreCase',true));
        end
        function lqgCongelato(testCase)
            d=load(fullfile(testCase.Root,'results','data','didactic_lqg_calculations.mat'));
            m=load(fullfile(testCase.Root,'results','data','m6_lqg_no_integrator.mat'));
            testCase.verifyEqual(d.K,m.K,'AbsTol',1e-8);
            testCase.verifyEqual(d.L,m.L,'AbsTol',1e-8);
            testCase.verifyEqual(d.Q,m.Q,'AbsTol',1e-10);
            testCase.verifyEqual(d.R,m.R,'AbsTol',1e-12);
        end
        function traiettorieComplete(testCase)
            d=load(fullfile(testCase.Root,'results','data','lyapunov_trajectories.mat'));
            testCase.verifyEqual(height(d.tabella),48);
            testCase.verifyTrue(all(isfinite(d.tabella{:,4:7}),'all'));
        end
        function traiettorieDecrescentiEntroArrotondamento(testCase)
            d=load(fullfile(testCase.Root,'results','data','lyapunov_trajectories.mat'));
            % Margine molto maggiore del roundoff vicino all'equilibrio.
            testCase.verifyLessThan(max(d.tabella.maxIncrementoRelativo),1e-8);
            testCase.verifyLessThan(max(d.tabella.maxVdotRelativa),1e-8);
        end
        function traiettorieConvergonoInOttoSecondi(testCase)
            d=load(fullfile(testCase.Root,'results','data','lyapunov_trajectories.mat'));
            % Diagnostica finita, non definizione della regione certificata.
            testCase.verifyLessThan(max(d.tabella.rapportoFinaleV),1e-3);
        end
        function stileBiancoNeroIdempotente(testCase)
            f=figure('Visible','off');
            testCase.addTeardown(@() close(f));
            ax=axes(f); p=plot(ax,[0 1],[2 3],'DisplayName','curva');
            xlabel(ax,'tempo'); ylabel(ax,'uscita'); title(ax,'titolo');
            lg=legend(ax,'show'); dati=p.YData;
            set_scientific_figure_style(f);
            set_scientific_figure_style(f);
            testCase.verifyEqual(f.Color,[1 1 1],'AbsTol',0);
            testCase.verifyEqual([ax.XColor;ax.YColor;ax.Title.Color;lg.TextColor],zeros(4,3),'AbsTol',0);
            testCase.verifyEqual(p.YData,dati,'AbsTol',0);
        end
    end
end
