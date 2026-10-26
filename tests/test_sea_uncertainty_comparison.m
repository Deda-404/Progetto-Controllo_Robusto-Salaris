classdef test_sea_uncertainty_comparison < matlab.unittest.TestCase
    % Independent construction, fixed-controller evidence and baseline regression.
    properties
        Root
        Current
        Baseline
        Results
    end
    methods (TestClassSetup)
        function buildAndLoad(t)
            t.Root=fileparts(fileparts(mfilename('fullpath')));
            t.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(t.Root,'tests/didactic_refactor')));
            t.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(t.Root,'analysis/uncertainty')));
            t.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(t.Root,'src'),'IncludingSubfolders',true));
            old=rng; t.addTeardown(@()rng(old));
            script='File_di_Funzioni_Progetto-Accorpati/progetto_mu.m';
            [status,before]=system(sprintf('git -C "%s" show 0ed5611fdbb9c46475543f87eba68d9799b07bc5:%s',t.Root,script));
            t.assertEqual(status,0,'The audited baseline commit must be available.');
            current=fileread(fullfile(t.Root,script));
            t.Baseline=runVariant(t.Root,before,false);
            t.Current=runVariant(t.Root,current,true);
            t.verifyEqual(rng,old);
            data=load(fullfile(t.Root,'results/data/sea_incertezze_conservativa/comparison.mat'),'r');
            t.Results=data.r;
        end
    end
    methods (Test)
        function mechanicalLFT(t)
            r=t.Current.risultatiConfrontoIncertezze;
            t.verifySize(r.mechanicalLFT,[5 7]);
            t.verifySize(r.mechanicalDelta,[3 3]);
            t.verifyLessThan(max(r.mechanicalErrors),1e-10);
            t.verifyEqual(size(r.mechanicalProbes,1),32);
        end
        function actuatorLFT(t)
            r=t.Current.risultatiConfrontoIncertezze;
            t.verifySize(r.actuatorLFTs{1},[6 6]);
            t.verifySize(r.actuatorDeltas{1},[5 5]);
            t.verifyLessThan(max(r.actuatorErrors,[],'all'),1e-10);
            t.verifyEqual(r.actuatorDeltas{1}(1,1),r.actuatorDeltas{1}(2,2));
            t.verifyEqual(r.checks.deltaSizes,{[5 5],[13 13]});
            blocks=r.checks.blocksB;
            t.verifyEqual([blocks(contains(string({blocks.Name}),'dw')).Occurrences],[2 2]);
        end
        function commonNominalAndConnections(t)
            r=t.Current.risultatiConfrontoIncertezze;
            w=logspace(-4,5,1001);
            old=freqresp(t.Current.P.NominalValue,w);
            a=freqresp(r.P{1}.NominalValue,w); b=freqresp(r.P{2}.NominalValue,w);
            t.verifyLessThan(max(abs(a-old),[],'all')/max(abs(old),[],'all'),1e-10);
            t.verifyLessThan(max(abs(b-old),[],'all')/max(abs(old),[],'all'),1e-10);
            t.verifySize(r.P{2},[8 6]);
        end
        function analyticWeights(t)
            f=fit_actuator_uncertainty_weight([],uncertainty_params_m4,"additiveComparison");
            filters={f.WA,f.WR,f.WH,f.WT,f.Hbar};
            t.verifyTrue(all(cellfun(@isstable,filters)));
            t.verifyTrue(all(cellfun(@isproper,filters)));
            t.verifyLessThan(f.factorRelativeError,1e-10);
            t.verifyLessThanOrEqual(max(real(zero(f.WA))),1e-10);
            t.verifyEqual(dcgain(f.WA),0,'AbsTol',1e-12);
            t.verifyEqual(dcgain(f.WR),0,'AbsTol',1e-12);
            t.verifyEqual(sum(abs(zero(f.WR))<1e-10),3);
        end
        function physicalSamplesAndDelayLimits(t)
            r=t.Current.risultatiConfrontoIncertezze;
            x=logspace(-7,8,3001); f=r.weights;
            analytic=min(2,x.^3/12)./(f.kappa*(x./sqrt(1+x.^2)).^3);
            t.verifyLessThanOrEqual(max(analytic),1+1e-12);
            t.verifyLessThanOrEqual(r.checks.sampledResidualRatio,1);
            t.verifyLessThanOrEqual(r.checks.sampledConcentratedRatio,1);
            t.verifyGreaterThan(r.checks.mechanicalWellPosedMinimum,0);
            t.verifyGreaterThan(r.checks.delayWellPosedMinimum,0);
            t.verifyGreaterThan(r.checks.padeRHPZero,0);
            t.verifyGreaterThan(abs(r.checks.multiplicativeResidue),1);
        end
        function historicalExecutionUnchanged(t)
            names={'Khinf','Kmu','Ga','WI','physicalNom','P','CLhinf','CLmu','W1','W2','Mo', ...
                'storico','storiaDK','obiettivoMu','confronto','tracking','comandi','analisi','muGriglia','risultati'};
            actual=cellfun(@(n)t.Current.(n),names,'UniformOutput',false);
            expected=cellfun(@(n)t.Baseline.(n),names,'UniformOutput',false);
            t.verifyEqual(actual,expected);
        end
        function fixedControllerResults(t)
            r=t.Results; c=r.comparison;
            t.verifyEqual(height(c),6); t.verifyTrue(all(c.NS & c.NP));
            t.verifyEqual(c.NominalNorm(1:2:end),c.NominalNorm(2:2:end),'AbsTol',1e-6);
            t.verifyEqual(c{1:2:end,14:15},c{2:2:end,14:15},'AbsTol',1e-6);
            t.verifyEqual(string(c.RS),["FAIL";"FAIL";"FAIL";"PASS";"FAIL";"PASS"]);
            t.verifyLessThan(max(cellfun(@(a)a.nominalLFTError,r.audits),[],'all'),1e-8);
            t.verifyTrue(all(cellfun(@(a)a.RS.LowerBound<=a.RS.UpperBound,r.audits),'all'));
        end
        function criticalDynamicPerturbationsAdmissible(t)
            checks=cellfun(@auditDynamicWitnesses,t.Results.audits,'UniformOutput',false);
            checks=vertcat(checks{:});
            t.verifyTrue(all(checks(:,1)));
            t.verifyLessThanOrEqual(max(checks(:,2)),1+1e-5);
        end
        function invalidPerformanceIntervalNotCertified(t)
            a=t.Results.audits{1,2};
            t.verifyGreaterThan(a.RP.LowerBound,a.RP.UpperBound);
            t.verifyEqual(a.RPBoundsOutcome,"INCONCLUSIVE_NUMERICAL");
            t.verifyEqual(a.RPOutcome,"FAIL_FROM_RS; MARGIN_INVALID");
            t.verifyEqual(string(t.Results.comparison.RP([4 6])),["PASS";"PASS"]);
        end
    end
end

function out=runVariant(root,source,comparison)
folder=fullfile(root,'tmp/sea_conservativa/tests'); if ~isfolder(folder),mkdir(folder);end
source=strrep(source,'ricalcolaAnalisi=true;','ricalcolaAnalisi=false;');
source=strrep(source,'mostraFigure=true;','mostraFigure=false;');
source=strrep(source,'analizzaConfrontoIncertezze=true;','analizzaConfrontoIncertezze=false;');
if comparison,source=strrep(source,'confrontaIncertezze=false;','confrontaIncertezze=true;');end
source=strrep(source,"fileparts(mfilename('fullpath'))", "'"+string(fullfile(root,'File_di_Funzioni_Progetto-Accorpati'))+"'");
file=fullfile(folder,sprintf('comparison_variant_%d.m',comparison));
fid=fopen(file,'w','n','UTF-8'); fwrite(fid,source,'char'); fclose(fid);
out=run_capture(file);
end

function rows=auditDynamicWitnesses(a)
rows=zeros(0,2); names=fieldnames(a.CL.Uncertainty);
for k=1:numel(names)
    name=names{k}; block=a.CL.Uncertainty.(name);
    if ~isa(block,'ultidyn'),continue;end
    rs=a.rsWorst.(name); rp=a.rpWorst.(name);
    stable=isstable(rs) && isproper(rs) && isstable(rp) && isproper(rp);
    rows(end+1,:)=[stable,norm(rs,inf)/a.RS.UpperBound]; %#ok<AGROW>
end
end
