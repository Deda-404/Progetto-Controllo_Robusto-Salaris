function tests = test_hinf_targeted_revision
tests=functiontests(localfunctions);
end
function setupOnce(t)
root=fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(root,'controllers')));
folder=fullfile(root,'results','data','hinf_targeted_revision');
d=load(fullfile(folder,'study.mat')); t.TestData.study=d.study;
d=load(fullfile(folder,'fixed_campaign.mat')); t.TestData.fixed=d.campaign;
d=load(fullfile(folder,'extension_2dof.mat')); t.TestData.ext=d.extension;
t.TestData.m3=load(fullfile(root,'results','data','m3_nominal_actuated_plant.mat'));
t.TestData.m5=load(fullfile(root,'results','data','m5_performance_specs.mat'));
end
function testLowerBoundRejectsBeforeSolver(t)
s=t.TestData.study;
verifyGreaterThan(t,s.baseline.bound.value,1);
rejected=s.cases(cellfun(@(x) x.bound.reject,s.cases));
verifyNotEmpty(t,rejected);
for i=1:numel(rejected)
    verifyEqual(t,rejected{i}.status,"LOWER_BOUND_REJECTED");
    verifyFalse(t,isfield(rejected{i},'Kmix'));
end
verifyLessThanOrEqual(t,max(cellfun(@(x) x.stage,s.cases)),2);
end
function testAllFullOrderIdentities(t)
s=t.TestData.study;
for i=1:numel(s.cases)
    r=s.cases{i};
    if r.bound.reject, continue; end
    verifyEqual(t,r.status,"SYNTHESIZED",r.error);
    verifyLessThan(t,r.gammaRelativeError,s.config.gammaTolerance);
    verifyLessThan(t,r.mapError,s.config.mapTolerance);
    verifyLessThan(t,r.plantError,s.config.mapTolerance);
    verifyLessThan(t,r.normRelativeError,s.config.gammaTolerance);
    verifyLessThanOrEqual(t,r.bound.value,min(r.gammaMix,r.gammaHinf)+1e-6);
end
end
function testInternalStabilityAndIndependentNorm(t)
s=t.TestData.study; r=s.cases{s.selected};
verifyLessThan(t,max(real(eig(r.hinf.Acl))),-s.config.stabilityTolerance);
verifyLessThan(t,r.gammaHinf,1); verifyLessThan(t,r.gammaMix,1);
verifyLessThan(t,norm(r.hinf.weighted,inf),1);
verifyEqual(t,size(r.hinf.Acl,1),14+order(r.Khinf));
verifyEqual(t,order(r.Khinf),18);
end
function testTrackingAndPhysicalDisturbance(t)
s=t.TestData.study; r=s.cases{s.selected};
m3=t.TestData.m3; m5=t.TestData.m5;
Gd=ss(m3.Afull,m5.BdFull,m3.CfullQ,zeros(2));
actual=freqresp(r.hinf.disturbance(1:2,:),s.config.omega);
expected=freqresp(r.hinf.S*Gd,s.config.omega);
verifyLessThan(t,max(abs(actual-expected),[],'all'),1e-6);
verifyEqual(t,m5.spec.referenceAmplitude,deg2rad(5),'AbsTol',1e-12);
[v,~]=hinf_revision_tracking(r.hinf.reference,m5.spec,s.config);
verifyEqual(t,v,r.hinf.metrics,'AbsTol',1e-10);
verifyFalse(t,r.hinf.m5Temporal);
verifyFalse(t,r.hinf.revisedTemporal);
verifyTrue(t,r.hinf.nominalPerformance);
end
function testFixedOrderSeedsAndValidation(t)
s=t.TestData.study; f=t.TestData.fixed;
verifyEqual(t,numel(f.families),6);
passing=[];
for i=1:numel(f.families)
    family=f.families{i};
    verifyEqual(t,numel(family.runs),11);
    verifyEqual(t,family.seed,s.config.seed+i-1);
    verifyEqual(t,family.config.randomStart,10);
    for j=1:numel(family.runs)
        r=family.runs{j};
        if r.performancePass
            verifyLessThan(t,max(real(eig(r.evaluation.Acl))),-1e-8);
            verifyLessThan(t,norm(r.evaluation.weighted,inf),1);
            verifyLessThan(t,r.objectiveRelativeError,5e-3);
            passing(end+1)=r.order; %#ok<AGROW>
        end
    end
end
verifyEqual(t,min(passing),6);
end
function testTwoDofHasSeparatePerformance(t)
s=t.TestData.study; r=s.cases{s.selected}; e=t.TestData.ext;
verifyTrue(t,e.stable);
verifyEqual(t,dcgain(e.reference(1:2,:)),eye(2),'AbsTol',1e-8);
verifyEqual(t,e.disturbance.A,r.hinf.disturbance.A,'AbsTol',0);
verifyGreaterThan(t,e.trackingNorm,1);
verifyTrue(t,e.revisedTemporal); verifyFalse(t,e.m5Temporal);
verifyLessThan(t,e.feedbackGamma,1);
verifyEqual(t,size(e.reference.A,1),size(r.hinf.Acl,1)+order(e.F));
end
function testWeightAsymptotesAndUnchangedM5(t)
s=t.TestData.study; r=s.cases{s.selected}; p=r.parameters;
verifyEqual(t,dcgain(r.W1),eye(2)/p(2),'AbsTol',1e-12);
verifyEqual(t,dcgain(r.W2),p(4)*eye(2),'AbsTol',1e-12);
verifyEqual(t,ss(r.W1).D,eye(2)/p(3),'AbsTol',1e-12);
verifyEqual(t,ss(r.W2).D,p(4)*s.config.alpha*eye(2),'AbsTol',1e-12);
verifyEqual(t,t.TestData.m5.spec.steadyStateTrackingTarget,.05);
verifyEqual(t,t.TestData.m5.spec.controlWeightGain,.05);
verifyEqual(t,s.config.revised.steadyErrorRelative,.20);
end
