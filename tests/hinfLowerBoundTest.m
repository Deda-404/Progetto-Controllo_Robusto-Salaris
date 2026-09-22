classdef hinfLowerBoundTest < matlab.unittest.TestCase
    methods (TestClassSetup)
        function sourcePath(t)
            root=fileparts(fileparts(mfilename('fullpath')));
            t.applyFixture(matlab.unittest.fixtures.PathFixture( ...
                fullfile(root,'controllers','hinf')));
        end
    end
    methods (Test)
        function sisoKnown(t)
            b=hinf_revision_lower_bound(ss(2),ss(3),ss(4),[.1 1 10]);
            t.verifyEqual(b.curve,ones(1,3)*12/sqrt(52),'AbsTol',1e-12);
        end
        function diagonalWeakDirection(t)
            b=hinf_revision_lower_bound(ss(diag([10 .1])),ss(2*eye(2)),ss(.5*eye(2)),1);
            t.verifyEqual(b.value,1/sqrt(.25+.04),'AbsTol',1e-12);
            t.verifyGreaterThan(b.value,1/sqrt(.25+400));
        end
        function nonDiagonalMimo(t)
            G=[1 3;-2 4]; a=2; b=.7;
            X=(a^2*(G'*G)+b^2*eye(2))\(a^2*G');
            stack=[a*(eye(2)-G*X);b*X];
            bound=hinf_revision_lower_bound(ss(G),ss(a*eye(2)),ss(b*eye(2)),1);
            t.verifyEqual(bound.value,norm(stack,2),'AbsTol',1e-12);
            t.verifyGreaterThanOrEqual(norm([a*(eye(2)-G);b*eye(2)],2),bound.value);
        end
        function almostSingular(t)
            U=[1 1;-1 1]/sqrt(2); G=U*diag([2 1e-12]);
            b=hinf_revision_lower_bound(ss(G),ss(3*eye(2)),ss(.5*eye(2)),1);
            t.verifyEqual(b.value,3,'AbsTol',1e-12);
        end
        function rankDeficient(t)
            b=hinf_revision_lower_bound(ss([1 2;2 4]),ss(3*eye(2)),ss(.5*eye(2)),1);
            t.verifyEqual(b.value,3,'AbsTol',1e-12);
        end
        function rejectsNonScalarWeights(t)
            t.verifyError(@() hinf_revision_lower_bound(ss(eye(2)),ss(diag([1 2])), ...
                ss(eye(2)),1),'HinfBound:ScalarWeights');
        end
        function sampledSupremumIsNotCertificate(t)
            G=tf(1,[1 1]);
            low=hinf_revision_lower_bound(G,tf(2),tf(1),.01);
            high=hinf_revision_lower_bound(G,tf(2),tf(1),[.01 100]);
            t.verifyFalse(low.reject);
            t.verifyTrue(high.reject);
            t.verifyGreaterThan(high.value,low.value);
        end
    end
end
