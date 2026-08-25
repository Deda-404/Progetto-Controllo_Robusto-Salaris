function config = hinfstruct_specs_m11
%HINFSTRUCT_SPECS_M11 Frozen finite campaign for structured H-infinity.

config = hinf_specs_m10;
config.hinfstructEnabled = true;
config.campaignSeed = 20260827;
config.totalStartsPerArchitecture = 5;
config.randomStartsPerArchitecture = 4;
config.useParallel = false;
config.hinfstructDisplay = 'off';
config.hinfstructMaxIter = 300;
config.hinfstructTargetGain = 0;
config.hinfstructTolGain = 1e-3;

config.generalizedPlantIdentityTolerance = 1e-10;
config.lowerBoundRelativeTolerance = 1e-4;
config.objectiveRelativeTolerance = 5e-3;
config.controllerDiagonalTolerance = 1e-10;
config.paretoTolerance = 1e-8;
config.maxControllerOrder = 6;

config.weightRetuningEnabled = false;
config.twoDegreeOfFreedomEnabled = false;
config.prefilterEnabled = false;
config.robustAnalysisEnabled = false;
config.m12Enabled = false;

ID = ["A0"; "A1"; "A2"; "A3"; "A4"; "A5"];
Type = [ ...
    "Full MIMO static gain"; ...
    "Decentralized PI"; ...
    "Decentralized PIDF"; ...
    "Full MIMO tunableSS order 2"; ...
    "Full MIMO tunableSS order 4"; ...
    "Full MIMO tunableSS order 6"];
NominalOrder = [0; 2; 4; 2; 4; 6];
ParameterCount = [4; 4; 8; 16; 36; 64];
Diagonal = [false; true; true; false; false; false];
FullMIMO = [true; false; false; true; true; true];
API = ["tunableGain"; "tunablePID-PI"; "tunablePID-PID"; ...
    "tunableSS"; "tunableSS"; "tunableSS"];
config.architectures = table(ID, Type, NominalOrder, ParameterCount, ...
    Diagonal, FullMIMO, API);
config.architectureSeeds = config.campaignSeed + ...
    (0:height(config.architectures) - 1).';
end
