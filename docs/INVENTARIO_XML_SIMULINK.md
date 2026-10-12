# Inventario XML degli otto SLX

Controllo statico ZIP/XML del 12 ottobre 2026. Nessun SLX alterato. Le miniature sono contenute negli originali; non rappresentano una nuova esportazione o una simulazione.

## Hinf_linear_sim.slx

Release: {'version': '26.1.0.3312084', 'release': 'R2026a', 'description': 'Update 4', 'date': 'Jun 30 2026', 'checksum': '4132326121'}

SHA-256: `27b5132d581c2d220ef3d3c5cce1c66fb13f95a0c2f9c2a390127ecd1a1cda9d`

Configurazione: `{'SolverName': 'VariableStepAuto'}`

### Blocchi e parametri

- `Hinf_linear_sim/Constant1` (Constant): `{'Value': '[0 0]'}`
- `Hinf_linear_sim/Constant2` (Constant): `{'Value': '[0 0]'}`
- `Hinf_linear_sim/Constant3` (Constant): `{'Value': '[0 0]'}`
- `Hinf_linear_sim/Controller H-inf` (StateSpace): `{'A': 'Ak1', 'B': 'Bk1', 'C': 'Ck1', 'D': 'Dk1', 'InitialCondition': '0'}`
- `Hinf_linear_sim/Controller H-inf1` (StateSpace): `{'A': 'Ak2', 'B': 'Bk2', 'C': 'Ck2', 'D': 'Dk2', 'InitialCondition': '0'}`
- `Hinf_linear_sim/Demux` (Demux): `{}`
- `Hinf_linear_sim/Demux1` (Demux): `{}`
- `Hinf_linear_sim/Demux10` (Demux): `{'Outputs': '2'}`
- `Hinf_linear_sim/Demux11` (Demux): `{}`
- `Hinf_linear_sim/Demux12` (Demux): `{'Outputs': '2'}`
- `Hinf_linear_sim/Demux13` (Demux): `{}`
- `Hinf_linear_sim/Demux14` (Demux): `{}`
- `Hinf_linear_sim/Demux15` (Demux): `{}`
- `Hinf_linear_sim/Demux16` (Demux): `{'Outputs': '2'}`
- `Hinf_linear_sim/Demux3` (Demux): `{'Outputs': '2'}`
- `Hinf_linear_sim/Demux4` (Demux): `{'Outputs': '2'}`
- `Hinf_linear_sim/Demux5` (Demux): `{}`
- `Hinf_linear_sim/Demux6` (Demux): `{'Outputs': '2'}`
- `Hinf_linear_sim/Demux7` (Demux): `{}`
- `Hinf_linear_sim/Demux8` (Demux): `{'Outputs': '2'}`
- `Hinf_linear_sim/Demux9` (Demux): `{}`
- `Hinf_linear_sim/Disturbo di coppia` (Step): `{'Time': '[1 1]', 'InitialValue': '[0 0]', 'FinalValue': '[0.5 0]', 'SampleTime': '0'}`
- `Hinf_linear_sim/Disturbo di coppia1` (Step): `{'Time': '[1 1]', 'InitialValue': '[0 0]', 'FinalValue': '[0.5 0]', 'SampleTime': '0'}`
- `Hinf_linear_sim/Disturbo di coppia2` (Step): `{'Time': '[1 1]', 'InitialValue': '[0 0]', 'FinalValue': '[0.5 0]', 'SampleTime': '0'}`
- `Hinf_linear_sim/Mux` (Mux): `{'Inputs': '2', 'DisplayOption': 'bar'}`
- `Hinf_linear_sim/Mux1` (Mux): `{'DisplayOption': 'bar'}`
- `Hinf_linear_sim/Mux2` (Mux): `{'DisplayOption': 'bar'}`
- `Hinf_linear_sim/Mux3` (Mux): `{'DisplayOption': 'bar'}`
- `Hinf_linear_sim/Mux4` (Mux): `{'Inputs': '2', 'DisplayOption': 'bar'}`
- `Hinf_linear_sim/Mux5` (Mux): `{'DisplayOption': 'bar'}`
- `Hinf_linear_sim/Mux6` (Mux): `{'DisplayOption': 'bar'}`
- `Hinf_linear_sim/Mux7` (Mux): `{'Inputs': '2', 'DisplayOption': 'bar'}`
- `Hinf_linear_sim/Mux8` (Mux): `{'DisplayOption': 'bar'}`
- `Hinf_linear_sim/Rumore di processo link` (RandomNumber): `{'Mean': '[0 0]', 'Variance': '[0.01 0.01]', 'Seed': '20260826', 'SampleTime': '0.002'}`
- `Hinf_linear_sim/Rumore di processo link1` (RandomNumber): `{'Mean': '[0 0]', 'Variance': '[0.01 0.01]', 'Seed': '20260826', 'SampleTime': '0.002'}`
- `Hinf_linear_sim/Rumore di processo link2` (RandomNumber): `{'Mean': '[0 0]', 'Variance': '[0.01 0.01]', 'Seed': '20260826', 'SampleTime': '0.002'}`
- `Hinf_linear_sim/Rumore di processo u` (RandomNumber): `{'Mean': '[0 0]', 'Variance': '[0.01 0.01]', 'Seed': '20260826', 'SampleTime': '0.002'}`
- `Hinf_linear_sim/Rumore di processo u1` (RandomNumber): `{'Mean': '[0 0]', 'Variance': '[0.01 0.01]', 'Seed': '20260826', 'SampleTime': '0.002'}`
- `Hinf_linear_sim/Rumore di processo u2` (RandomNumber): `{'Mean': '[0 0]', 'Variance': '[0.01 0.01]', 'Seed': '20260826', 'SampleTime': '0.002'}`
- `Hinf_linear_sim/Rumori di misura` (RandomNumber): `{'Mean': '[0 0 0 0]', 'Variance': '[(0.05*pi/180)^2 (0.05*pi/180)^2 (0.05*pi/180)^2 (0.05*pi/180)^2]', 'Seed': '20260826', 'SampleTime': '0.002'}`
- `Hinf_linear_sim/Rumori di misura1` (RandomNumber): `{'Mean': '[0 0 0 0]', 'Variance': '[(0.05*pi/180)^2 (0.05*pi/180)^2 (0.05*pi/180)^2 (0.05*pi/180)^2]', 'Seed': '20260826', 'SampleTime': '0.002'}`
- `Hinf_linear_sim/Rumori di misura2` (RandomNumber): `{'Mean': '[0 0 0 0]', 'Variance': '[(0.05*pi/180)^2 (0.05*pi/180)^2 (0.05*pi/180)^2 (0.05*pi/180)^2]', 'Seed': '20260826', 'SampleTime': '0.002'}`
- `Hinf_linear_sim/State-Space` (StateSpace): `{'A': 'Aplant', 'B': 'Bplant', 'C': 'Cplant', 'D': 'Dplant', 'InitialCondition': 'x0plant'}`
- `Hinf_linear_sim/State-Space1` (StateSpace): `{'A': 'Aplant', 'B': 'Bplant', 'C': 'Cplant', 'D': 'Dplant', 'InitialCondition': 'x0plant'}`
- `Hinf_linear_sim/State-Space2` (StateSpace): `{'A': 'Aplant', 'B': 'Bplant', 'C': 'Cplant', 'D': 'Dplant', 'InitialCondition': 'x0plant'}`
- `Hinf_linear_sim/Sum` (Sum): `{'Inputs': '|+-'}`
- `Hinf_linear_sim/Sum1` (Sum): `{'NameLocation': 'top', 'Inputs': '|++'}`
- `Hinf_linear_sim/Sum2` (Sum): `{'NameLocation': 'top', 'Inputs': '|++'}`
- `Hinf_linear_sim/Sum3` (Sum): `{'NameLocation': 'top', 'Inputs': '|++'}`
- `Hinf_linear_sim/r1` (Step): `{'FinalValue': '5*pi/180', 'SampleTime': '0'}`
- `Hinf_linear_sim/r2` (Step): `{'FinalValue': '0', 'SampleTime': '0'}`

### Connessioni

- `Hinf_linear_sim/r2#out:1` → `Hinf_linear_sim/Mux#in:2`
- `Hinf_linear_sim/Sum#out:1` → `Hinf_linear_sim/Controller H-inf#in:1`
- `Hinf_linear_sim/Mux#out:1` → `Hinf_linear_sim/Mux4#in:1`
- `Hinf_linear_sim/Mux#out:1` → `Hinf_linear_sim/Mux7#in:1`
- `Hinf_linear_sim/Mux#out:1` → `Hinf_linear_sim/Sum#in:1`
- `Hinf_linear_sim/Mux#out:1` → `Hinf_linear_sim/Goto3#in:1`
- `Hinf_linear_sim/r1#out:1` → `Hinf_linear_sim/Mux#in:1`
- `Hinf_linear_sim/Disturbo di coppia#out:1` → `Hinf_linear_sim/Mux1#in:2`
- `Hinf_linear_sim/Rumore di processo u#out:1` → `Hinf_linear_sim/Mux1#in:4`
- `Hinf_linear_sim/Rumore di processo link#out:1` → `Hinf_linear_sim/Mux1#in:3`
- `Hinf_linear_sim/State-Space#out:1` → `Hinf_linear_sim/Goto1#in:1`
- `Hinf_linear_sim/State-Space#out:1` → `Hinf_linear_sim/Sum3#in:1`
- `Hinf_linear_sim/Sum3#out:1` → `Hinf_linear_sim/Goto2#in:1`
- `Hinf_linear_sim/Sum3#out:1` → `Hinf_linear_sim/Selector#in:1`
- `Hinf_linear_sim/Selector#out:1` → `Hinf_linear_sim/Sum#in:2`
- `Hinf_linear_sim/State-Space1#out:1` → `Hinf_linear_sim/Goto5#in:1`
- `Hinf_linear_sim/State-Space1#out:1` → `Hinf_linear_sim/Sum2#in:1`
- `Hinf_linear_sim/Rumore di processo u1#out:1` → `Hinf_linear_sim/Mux3#in:4`
- `Hinf_linear_sim/Disturbo di coppia1#out:1` → `Hinf_linear_sim/Mux3#in:2`
- `Hinf_linear_sim/Sum2#out:1` → `Hinf_linear_sim/Goto6#in:1`
- `Hinf_linear_sim/Sum2#out:1` → `Hinf_linear_sim/Selector1#in:1`
- `Hinf_linear_sim/Controller H-inf1#out:1` → `Hinf_linear_sim/Mux2#in:1`
- `Hinf_linear_sim/Controller H-inf1#out:1` → `Hinf_linear_sim/Mux3#in:1`
- `Hinf_linear_sim/Controller H-inf1#out:1` → `Hinf_linear_sim/Goto4#in:1`
- `Hinf_linear_sim/State-Space2#out:1` → `Hinf_linear_sim/Goto9#in:1`
- `Hinf_linear_sim/State-Space2#out:1` → `Hinf_linear_sim/Sum1#in:1`
- `Hinf_linear_sim/Rumore di processo link1#out:1` → `Hinf_linear_sim/Mux3#in:3`
- `Hinf_linear_sim/Sum1#out:1` → `Hinf_linear_sim/Selector2#in:1`
- `Hinf_linear_sim/Sum1#out:1` → `Hinf_linear_sim/Goto10#in:1`
- `Hinf_linear_sim/Mux7#out:1` → `Hinf_linear_sim/LTI System#in:1`
- `Hinf_linear_sim/Mux4#out:1` → `Hinf_linear_sim/Controller H-inf1#in:1`
- `Hinf_linear_sim/Selector1#out:1` → `Hinf_linear_sim/Mux4#in:2`
- `Hinf_linear_sim/Selector2#out:1` → `Hinf_linear_sim/Mux7#in:2`
- `Hinf_linear_sim/Demux#out:1` → `Hinf_linear_sim/Uscita ideale (1-DoF)#in:1`
- `Hinf_linear_sim/Demux#out:2` → `Hinf_linear_sim/Uscita ideale (1-DoF)#in:2`
- `Hinf_linear_sim/From1#out:1` → `Hinf_linear_sim/Demux#in:1`
- `Hinf_linear_sim/Mux2#out:1` → `Hinf_linear_sim/Manual Switch#in:1`
- `Hinf_linear_sim/Constant1#out:1` → `Hinf_linear_sim/Mux2#in:2`
- `Hinf_linear_sim/Constant1#out:1` → `Hinf_linear_sim/Mux2#in:4`
- `Hinf_linear_sim/Constant1#out:1` → `Hinf_linear_sim/Mux2#in:3`
- `Hinf_linear_sim/Mux3#out:1` → `Hinf_linear_sim/Manual Switch#in:2`
- `Hinf_linear_sim/Manual Switch#out:1` → `Hinf_linear_sim/State-Space1#in:1`
- `Hinf_linear_sim/Constant2#out:1` → `Hinf_linear_sim/Mux5#in:2`
- `Hinf_linear_sim/Constant2#out:1` → `Hinf_linear_sim/Mux5#in:4`
- `Hinf_linear_sim/Constant2#out:1` → `Hinf_linear_sim/Mux5#in:3`
- `Hinf_linear_sim/Mux5#out:1` → `Hinf_linear_sim/Manual Switch1#in:1`
- `Hinf_linear_sim/Controller H-inf#out:1` → `Hinf_linear_sim/Mux5#in:1`
- `Hinf_linear_sim/Controller H-inf#out:1` → `Hinf_linear_sim/Mux1#in:1`
- `Hinf_linear_sim/Controller H-inf#out:1` → `Hinf_linear_sim/Goto#in:1`
- `Hinf_linear_sim/Mux1#out:1` → `Hinf_linear_sim/Manual Switch1#in:2`
- `Hinf_linear_sim/Manual Switch1#out:1` → `Hinf_linear_sim/State-Space#in:1`
- `Hinf_linear_sim/Constant3#out:1` → `Hinf_linear_sim/Mux8#in:2`
- `Hinf_linear_sim/Constant3#out:1` → `Hinf_linear_sim/Mux8#in:4`
- `Hinf_linear_sim/Constant3#out:1` → `Hinf_linear_sim/Mux8#in:3`
- `Hinf_linear_sim/Mux8#out:1` → `Hinf_linear_sim/Manual Switch2#in:1`
- `Hinf_linear_sim/LTI System#out:1` → `Hinf_linear_sim/Mux8#in:1`
- `Hinf_linear_sim/LTI System#out:1` → `Hinf_linear_sim/Mux6#in:1`
- `Hinf_linear_sim/LTI System#out:1` → `Hinf_linear_sim/Goto8#in:1`
- `Hinf_linear_sim/Mux6#out:1` → `Hinf_linear_sim/Manual Switch2#in:2`
- `Hinf_linear_sim/Manual Switch2#out:1` → `Hinf_linear_sim/State-Space2#in:1`
- `Hinf_linear_sim/Disturbo di coppia2#out:1` → `Hinf_linear_sim/Mux6#in:2`
- `Hinf_linear_sim/Rumore di processo link2#out:1` → `Hinf_linear_sim/Mux6#in:3`
- `Hinf_linear_sim/Rumore di processo u2#out:1` → `Hinf_linear_sim/Mux6#in:4`
- `Hinf_linear_sim/From3#out:1` → `Hinf_linear_sim/Demux3#in:1`
- `Hinf_linear_sim/Demux3#out:1` → `Hinf_linear_sim/Uscita ideale (1-DoF)#in:5`
- `Hinf_linear_sim/Demux3#out:2` → `Hinf_linear_sim/Uscita ideale (1-DoF)#in:6`
- `Hinf_linear_sim/Demux#out:3` → `Hinf_linear_sim/Uscita ideale (1-DoF)#in:3`
- `Hinf_linear_sim/Demux#out:4` → `Hinf_linear_sim/Uscita ideale (1-DoF)#in:4`
- `Hinf_linear_sim/Demux6#out:2` → `Hinf_linear_sim/Uscita ideale (2-DoF)#in:6`
- `Hinf_linear_sim/From6#out:1` → `Hinf_linear_sim/Demux6#in:1`
- `Hinf_linear_sim/Demux5#out:4` → `Hinf_linear_sim/Uscita ideale (2-DoF)#in:4`
- `Hinf_linear_sim/Demux6#out:1` → `Hinf_linear_sim/Uscita ideale (2-DoF)#in:5`
- `Hinf_linear_sim/Demux5#out:1` → `Hinf_linear_sim/Uscita ideale (2-DoF)#in:1`
- `Hinf_linear_sim/Demux5#out:3` → `Hinf_linear_sim/Uscita ideale (2-DoF)#in:3`
- `Hinf_linear_sim/Demux5#out:2` → `Hinf_linear_sim/Uscita ideale (2-DoF)#in:2`
- `Hinf_linear_sim/From5#out:1` → `Hinf_linear_sim/Demux5#in:1`
- `Hinf_linear_sim/From7#out:1` → `Hinf_linear_sim/Demux7#in:1`
- `Hinf_linear_sim/Demux7#out:2` → `Hinf_linear_sim/Uscita ideale (PID)#in:2`
- `Hinf_linear_sim/Demux7#out:3` → `Hinf_linear_sim/Uscita ideale (PID)#in:3`
- `Hinf_linear_sim/Demux8#out:1` → `Hinf_linear_sim/Uscita ideale (PID)#in:5`
- `Hinf_linear_sim/Demux7#out:4` → `Hinf_linear_sim/Uscita ideale (PID)#in:4`
- `Hinf_linear_sim/From8#out:1` → `Hinf_linear_sim/Demux8#in:1`
- `Hinf_linear_sim/Demux8#out:2` → `Hinf_linear_sim/Uscita ideale (PID)#in:6`
- `Hinf_linear_sim/Demux7#out:1` → `Hinf_linear_sim/Uscita ideale (PID)#in:1`
- `Hinf_linear_sim/Demux1#out:3` → `Hinf_linear_sim/Uscita misurata (1-DoF)#in:3`
- `Hinf_linear_sim/Demux4#out:2` → `Hinf_linear_sim/Uscita misurata (1-DoF)#in:6`
- `Hinf_linear_sim/From4#out:1` → `Hinf_linear_sim/Demux4#in:1`
- `Hinf_linear_sim/Demux1#out:4` → `Hinf_linear_sim/Uscita misurata (1-DoF)#in:4`
- `Hinf_linear_sim/Demux4#out:1` → `Hinf_linear_sim/Uscita misurata (1-DoF)#in:5`
- `Hinf_linear_sim/From9#out:1` → `Hinf_linear_sim/Demux9#in:1`
- `Hinf_linear_sim/Demux9#out:3` → `Hinf_linear_sim/Uscita misurata (2-DoF)#in:3`
- `Hinf_linear_sim/Demux9#out:2` → `Hinf_linear_sim/Uscita misurata (2-DoF)#in:2`
- `Hinf_linear_sim/Demux9#out:4` → `Hinf_linear_sim/Uscita misurata (2-DoF)#in:4`
- `Hinf_linear_sim/Demux11#out:1` → `Hinf_linear_sim/Uscita misurata (PID)#in:1`
- `Hinf_linear_sim/Demux11#out:4` → `Hinf_linear_sim/Uscita misurata (PID)#in:4`
- `Hinf_linear_sim/Demux11#out:3` → `Hinf_linear_sim/Uscita misurata (PID)#in:3`
- `Hinf_linear_sim/Demux12#out:2` → `Hinf_linear_sim/Uscita misurata (PID)#in:6`
- `Hinf_linear_sim/Demux9#out:1` → `Hinf_linear_sim/Uscita misurata (2-DoF)#in:1`
- `Hinf_linear_sim/From12#out:1` → `Hinf_linear_sim/Demux12#in:1`
- `Hinf_linear_sim/Demux1#out:1` → `Hinf_linear_sim/Uscita misurata (1-DoF)#in:1`
- `Hinf_linear_sim/Demux10#out:1` → `Hinf_linear_sim/Uscita misurata (2-DoF)#in:5`
- `Hinf_linear_sim/From2#out:1` → `Hinf_linear_sim/Demux1#in:1`
- `Hinf_linear_sim/From10#out:1` → `Hinf_linear_sim/Demux10#in:1`
- `Hinf_linear_sim/Demux10#out:2` → `Hinf_linear_sim/Uscita misurata (2-DoF)#in:6`
- `Hinf_linear_sim/From11#out:1` → `Hinf_linear_sim/Demux11#in:1`
- `Hinf_linear_sim/Demux11#out:2` → `Hinf_linear_sim/Uscita misurata (PID)#in:2`
- `Hinf_linear_sim/Demux1#out:2` → `Hinf_linear_sim/Uscita misurata (1-DoF)#in:2`
- `Hinf_linear_sim/Demux12#out:1` → `Hinf_linear_sim/Uscita misurata (PID)#in:5`
- `Hinf_linear_sim/From13#out:1` → `Hinf_linear_sim/Demux13#in:1`
- `Hinf_linear_sim/Demux13#out:1` → `Hinf_linear_sim/Confronto uscite#in:1`
- `Hinf_linear_sim/From14#out:1` → `Hinf_linear_sim/Demux14#in:1`
- `Hinf_linear_sim/Demux14#out:1` → `Hinf_linear_sim/Confronto uscite#in:2`
- `Hinf_linear_sim/From15#out:1` → `Hinf_linear_sim/Demux15#in:1`
- `Hinf_linear_sim/Demux15#out:1` → `Hinf_linear_sim/Confronto uscite#in:3`
- `Hinf_linear_sim/From16#out:1` → `Hinf_linear_sim/Demux16#in:1`
- `Hinf_linear_sim/Demux16#out:1` → `Hinf_linear_sim/Confronto uscite#in:4`
- `Hinf_linear_sim/From#out:1` → `Hinf_linear_sim/Variabili di controllo#in:1`
- `Hinf_linear_sim/From18#out:1` → `Hinf_linear_sim/Variabili di controllo#in:3`
- `Hinf_linear_sim/From17#out:1` → `Hinf_linear_sim/Variabili di controllo#in:2`

### Callback InitFcn

```matlab




%% INITFCN - Pianta LQGI lineare a 14 stati con 8 ingressi

% Individua la root del progetto partendo da progetto_lqgi.m
projectFile = which('progetto_lqgi.m');

assert(~isempty(projectFile), ...
    ['progetto_lqgi.m non trovato. Eseguire prima lo script ' ...
    'e verificare il MATLAB path.']);

projectRoot = fileparts(fileparts(projectFile));
dataDir = fullfile(projectRoot, 'results', 'data');

% File prodotti dagli script di validazione M3 e M5
m3File = fullfile(dataDir, 'm3_nominal_actuated_plant.mat');
m5File = fullfile(dataDir, 'm5_performance_specs.mat');

% Verifica che i dati della pianta esistano
assert(isfile(m3File), ...
    'Manca m3_nominal_actuated_plant.mat. Eseguire la validazione M3.');

% Se M5 non e' ancora stato generato, costruisce BdFull
if ~isfile(m5File)
    addpath(genpath(fullfile(projectRoot, 'src')));
    addpath(genpath(fullfile(projectRoot, 'analysis')));
    validate_m5_performance_specs;
end

assert(isfile(m5File), ...
    'Manca m5_performance_specs.mat dopo la validazione M5.');

% Carica le matrici necessarie
m3 = load(m3File, 'Afull', 'Bfull', 'CfullMeas');
m5 = load(m5File, 'BdFull');

Aplant = m3.Afull;
Bfull = m3.Bfull;
BdFull = m5.BdFull;
Cplant = m3.CfullMeas;

% Controlli sulle dimensioni delle matrici
assert(isequal(size(Aplant), [14 14]));
assert(isequal(size(Bfull), [14 2]));
assert(isequal(size(BdFull), [14 2]));
assert(isequal(size(Cplant), [4 14]));

% Ordine degli ingressi:
% 1-2: comando u
% 3-4: disturbo deterministico d lato link
% 5-6: rumore di processo w_link
% 7-8: rumore di processo w_u lato ingresso

Bplant = [Bfull, BdFull, BdFull, Bfull];

% Nessuna trasmissione diretta dagli ingressi alle misure
Dplant = zeros(4, 8);

% Condizione iniziale del modello linearizzato in deviazioni
x0plant = zeros(14, 1);

% Pubblica le variabili nel Base Workspace per i blocchi Simulink
assignin('base', 'Aplant', Aplant);
assignin('base', 'Bplant', Bplant);
assignin('base', 'Cplant', Cplant);
assignin('base', 'Dplant', Dplant);
assignin('base', 'x0plant', x0plant);

% Mantiene disponibili anche le matrici originali
assignin('base', 'Afull', Aplant);
assignin('base', 'Bfull', Bfull);
assignin('base', 'BdFull', BdFull);
assignin('base', 'CfullMeas', Cplant);

fprintf(['InitFcn LQGI: Aplant %dx%d, Bplant %dx%d, ' ...
    'Cplant %dx%d, Dplant %dx%d.\\n'], ...
    size(Aplant,1), size(Aplant,2), ...
    size(Bplant,1), size(Bplant,2), ...
    size(Cplant,1), size(Cplant,2), ...
    size(Dplant,1), size(Dplant,2));
```
## Hinf_nonlinear_sim.slx

Release: {'version': '26.1.0.3312084', 'release': 'R2026a', 'description': 'Update 4', 'date': 'Jun 30 2026', 'checksum': '4132326121'}

SHA-256: `a8ddab01bf44e80597943b80c12667b1f9b6bb28fdc21a95cb69ee540e8e354c`

Configurazione: `{'SolverName': 'VariableStepAuto'}`

### Blocchi e parametri

- `Hinf_nonlinear_sim/Actuators/u` (Inport): `{}`
- `Hinf_nonlinear_sim/Actuators/Demux` (Demux): `{'Outputs': '2'}`
- `Hinf_nonlinear_sim/Actuators/Mux` (Mux): `{'Inputs': '2', 'DisplayOption': 'bar'}`
- `Hinf_nonlinear_sim/Actuators/tau` (Outport): `{}`
- `Hinf_nonlinear_sim/Actuators1/u` (Inport): `{}`
- `Hinf_nonlinear_sim/Actuators1/Demux` (Demux): `{'Outputs': '2'}`
- `Hinf_nonlinear_sim/Actuators1/Mux` (Mux): `{'Inputs': '2', 'DisplayOption': 'bar'}`
- `Hinf_nonlinear_sim/Actuators1/tau` (Outport): `{}`
- `Hinf_nonlinear_sim/Actuators2/u` (Inport): `{}`
- `Hinf_nonlinear_sim/Actuators2/Demux` (Demux): `{'Outputs': '2'}`
- `Hinf_nonlinear_sim/Actuators2/Mux` (Mux): `{'Inputs': '2', 'DisplayOption': 'bar'}`
- `Hinf_nonlinear_sim/Actuators2/tau` (Outport): `{}`
- `Hinf_nonlinear_sim/Constant` (Constant): `{'Value': 'taubar'}`
- `Hinf_nonlinear_sim/Constant1` (Constant): `{'Value': 'taubar'}`
- `Hinf_nonlinear_sim/Constant2` (Constant): `{'Value': 'xbar'}`
- `Hinf_nonlinear_sim/Constant3` (Constant): `{'Value': 'taubar'}`
- `Hinf_nonlinear_sim/Constant4` (Constant): `{'Value': 'xbar'}`
- `Hinf_nonlinear_sim/Constant5` (Constant): `{'Value': 'xbar'}`
- `Hinf_nonlinear_sim/Constant6` (Constant): `{'BlockMirror': 'on', 'NameLocation': 'top', 'Value': '[0 0]'}`
- `Hinf_nonlinear_sim/Constant7` (Constant): `{'BlockMirror': 'on', 'NameLocation': 'top', 'Value': '[0 0]'}`
- `Hinf_nonlinear_sim/Constant8` (Constant): `{'BlockMirror': 'on', 'NameLocation': 'top', 'Value': '[0 0]'}`
- `Hinf_nonlinear_sim/Controller H-inf (1-DoF)` (StateSpace): `{'A': 'Ak1', 'B': 'Bk1', 'C': 'Ck1', 'D': 'Dk1', 'InitialCondition': '0'}`
- `Hinf_nonlinear_sim/Controller H-inf (2-DoF)` (StateSpace): `{'A': 'Ak2', 'B': 'Bk2', 'C': 'Ck2', 'D': 'Dk2', 'InitialCondition': '0'}`
- `Hinf_nonlinear_sim/Demux` (Demux): `{}`
- `Hinf_nonlinear_sim/Demux1` (Demux): `{}`
- `Hinf_nonlinear_sim/Demux10` (Demux): `{'Outputs': '2'}`
- `Hinf_nonlinear_sim/Demux11` (Demux): `{}`
- `Hinf_nonlinear_sim/Demux12` (Demux): `{'Outputs': '2'}`
- `Hinf_nonlinear_sim/Demux13` (Demux): `{}`
- `Hinf_nonlinear_sim/Demux14` (Demux): `{}`
- `Hinf_nonlinear_sim/Demux15` (Demux): `{}`
- `Hinf_nonlinear_sim/Demux16` (Demux): `{'Outputs': '2'}`
- `Hinf_nonlinear_sim/Demux3` (Demux): `{'Outputs': '2'}`
- `Hinf_nonlinear_sim/Demux4` (Demux): `{'Outputs': '2'}`
- `Hinf_nonlinear_sim/Demux5` (Demux): `{}`
- `Hinf_nonlinear_sim/Demux6` (Demux): `{'Outputs': '2'}`
- `Hinf_nonlinear_sim/Demux7` (Demux): `{}`
- `Hinf_nonlinear_sim/Demux8` (Demux): `{'Outputs': '2'}`
- `Hinf_nonlinear_sim/Demux9` (Demux): `{}`
- `Hinf_nonlinear_sim/Disturbi di coppia` (Step): `{'Time': '[1 1]', 'InitialValue': '[0 0]', 'FinalValue': '[0.5 0]', 'SampleTime': '0'}`
- `Hinf_nonlinear_sim/Disturbi di coppia1` (Step): `{'Time': '[1 1]', 'InitialValue': '[0 0]', 'FinalValue': '[0.5 0]', 'SampleTime': '0'}`
- `Hinf_nonlinear_sim/Disturbi di coppia2` (Step): `{'Time': '[1 1]', 'InitialValue': '[0 0]', 'FinalValue': '[0.5 0]', 'SampleTime': '0'}`
- `Hinf_nonlinear_sim/Integrator` (Integrator): `{'InitialCondition': 'xbar'}`
- `Hinf_nonlinear_sim/Integrator1` (Integrator): `{'InitialCondition': 'xbar'}`
- `Hinf_nonlinear_sim/Integrator2` (Integrator): `{'InitialCondition': 'xbar'}`
- `Hinf_nonlinear_sim/Mux` (Mux): `{'Inputs': '2', 'DisplayOption': 'bar'}`
- `Hinf_nonlinear_sim/Mux1` (Mux): `{'Inputs': '2', 'DisplayOption': 'bar'}`
- `Hinf_nonlinear_sim/Mux2` (Mux): `{'Inputs': '2', 'DisplayOption': 'bar'}`
- `Hinf_nonlinear_sim/Non linear plant/x` (Inport): `{}`
- `Hinf_nonlinear_sim/Non linear plant/tau` (Inport): `{'Port': '2'}`
- `Hinf_nonlinear_sim/Non linear plant/d` (Inport): `{'Port': '3'}`
- `Hinf_nonlinear_sim/Non linear plant/MATLAB Function/x` (Inport): `{}`
- `Hinf_nonlinear_sim/Non linear plant/MATLAB Function/tau` (Inport): `{'Port': '2'}`
- `Hinf_nonlinear_sim/Non linear plant/MATLAB Function/d` (Inport): `{'Port': '3'}`
- `Hinf_nonlinear_sim/Non linear plant/MATLAB Function/p` (Inport): `{'Port': '4'}`
- `Hinf_nonlinear_sim/Non linear plant/MATLAB Function/ Demux ` (Demux): `{'Outputs': '1'}`
- `Hinf_nonlinear_sim/Non linear plant/MATLAB Function/xdot` (Outport): `{}`
- `Hinf_nonlinear_sim/Non linear plant/MATLAB Function1/ Demux ` (Demux): `{'Outputs': '1'}`
- `Hinf_nonlinear_sim/Non linear plant/MATLAB Function1/p` (Outport): `{}`
- `Hinf_nonlinear_sim/Non linear plant/xdot` (Outport): `{}`
- `Hinf_nonlinear_sim/Non linear plant1/x` (Inport): `{}`
- `Hinf_nonlinear_sim/Non linear plant1/tau` (Inport): `{'Port': '2'}`
- `Hinf_nonlinear_sim/Non linear plant1/d` (Inport): `{'Port': '3'}`
- `Hinf_nonlinear_sim/Non linear plant1/MATLAB Function/x` (Inport): `{}`
- `Hinf_nonlinear_sim/Non linear plant1/MATLAB Function/tau` (Inport): `{'Port': '2'}`
- `Hinf_nonlinear_sim/Non linear plant1/MATLAB Function/d` (Inport): `{'Port': '3'}`
- `Hinf_nonlinear_sim/Non linear plant1/MATLAB Function/p` (Inport): `{'Port': '4'}`
- `Hinf_nonlinear_sim/Non linear plant1/MATLAB Function/ Demux ` (Demux): `{'Outputs': '1'}`
- `Hinf_nonlinear_sim/Non linear plant1/MATLAB Function/xdot` (Outport): `{}`
- `Hinf_nonlinear_sim/Non linear plant1/MATLAB Function1/ Demux ` (Demux): `{'Outputs': '1'}`
- `Hinf_nonlinear_sim/Non linear plant1/MATLAB Function1/p` (Outport): `{}`
- `Hinf_nonlinear_sim/Non linear plant1/xdot` (Outport): `{}`
- `Hinf_nonlinear_sim/Non linear plant2/x` (Inport): `{}`
- `Hinf_nonlinear_sim/Non linear plant2/tau` (Inport): `{'Port': '2'}`
- `Hinf_nonlinear_sim/Non linear plant2/d` (Inport): `{'Port': '3'}`
- `Hinf_nonlinear_sim/Non linear plant2/MATLAB Function/x` (Inport): `{}`
- `Hinf_nonlinear_sim/Non linear plant2/MATLAB Function/tau` (Inport): `{'Port': '2'}`
- `Hinf_nonlinear_sim/Non linear plant2/MATLAB Function/d` (Inport): `{'Port': '3'}`
- `Hinf_nonlinear_sim/Non linear plant2/MATLAB Function/p` (Inport): `{'Port': '4'}`
- `Hinf_nonlinear_sim/Non linear plant2/MATLAB Function/ Demux ` (Demux): `{'Outputs': '1'}`
- `Hinf_nonlinear_sim/Non linear plant2/MATLAB Function/xdot` (Outport): `{}`
- `Hinf_nonlinear_sim/Non linear plant2/MATLAB Function1/ Demux ` (Demux): `{'Outputs': '1'}`
- `Hinf_nonlinear_sim/Non linear plant2/MATLAB Function1/p` (Outport): `{}`
- `Hinf_nonlinear_sim/Non linear plant2/xdot` (Outport): `{}`
- `Hinf_nonlinear_sim/Rumore di processo link` (RandomNumber): `{'Mean': '[0 0]', 'Variance': '[0.01 0.01]', 'Seed': '20260826', 'SampleTime': '0.002'}`
- `Hinf_nonlinear_sim/Rumore di processo link1` (RandomNumber): `{'Mean': '[0 0]', 'Variance': '[0.01 0.01]', 'Seed': '20260826', 'SampleTime': '0.002'}`
- `Hinf_nonlinear_sim/Rumore di processo link2` (RandomNumber): `{'Mean': '[0 0]', 'Variance': '[0.01 0.01]', 'Seed': '20260826', 'SampleTime': '0.002'}`
- `Hinf_nonlinear_sim/Rumore di processo u1` (RandomNumber): `{'Mean': '[0 0]', 'Variance': '[0.01 0.01]', 'Seed': '20260826', 'SampleTime': '0.002'}`
- `Hinf_nonlinear_sim/Rumore di processo u2` (RandomNumber): `{'Mean': '[0 0]', 'Variance': '[0.01 0.01]', 'Seed': '20260826', 'SampleTime': '0.002'}`
- `Hinf_nonlinear_sim/Rumore di processo u3` (RandomNumber): `{'Mean': '[0 0]', 'Variance': '[0.01 0.01]', 'Seed': '20260826', 'SampleTime': '0.002'}`
- `Hinf_nonlinear_sim/Rumori di misura1` (RandomNumber): `{'Mean': '[0 0 0 0]', 'Variance': '[(0.05*pi/180)^2 (0.05*pi/180)^2 (0.05*pi/180)^2 (0.05*pi/180)^2]', 'Seed': '20260826', 'SampleTime': '0.002'}`
- `Hinf_nonlinear_sim/Rumori di misura2` (RandomNumber): `{'Mean': '[0 0 0 0]', 'Variance': '[(0.05*pi/180)^2 (0.05*pi/180)^2 (0.05*pi/180)^2 (0.05*pi/180)^2]', 'Seed': '20260826', 'SampleTime': '0.002'}`
- `Hinf_nonlinear_sim/Rumori di misura3` (RandomNumber): `{'Mean': '[0 0 0 0]', 'Variance': '[(0.05*pi/180)^2 (0.05*pi/180)^2 (0.05*pi/180)^2 (0.05*pi/180)^2]', 'Seed': '20260826', 'SampleTime': '0.002'}`
- `Hinf_nonlinear_sim/Sum` (Sum): `{'Inputs': '|+-'}`
- `Hinf_nonlinear_sim/Sum10` (Sum): `{'Inputs': '|++'}`
- `Hinf_nonlinear_sim/Sum11` (Sum): `{'Inputs': '|++'}`
- `Hinf_nonlinear_sim/Sum13` (Sum): `{'Inputs': '|++'}`
- `Hinf_nonlinear_sim/Sum14` (Sum): `{'Inputs': '|++'}`
- `Hinf_nonlinear_sim/Sum15` (Sum): `{'Inputs': '++|'}`
- `Hinf_nonlinear_sim/Sum16` (Sum): `{'Inputs': '|+-'}`
- `Hinf_nonlinear_sim/Sum17` (Sum): `{'NameLocation': 'top', 'Inputs': '|++'}`
- `Hinf_nonlinear_sim/Sum2` (Sum): `{'Inputs': '++|'}`
- `Hinf_nonlinear_sim/Sum3` (Sum): `{'Inputs': '|+-'}`
- `Hinf_nonlinear_sim/Sum4` (Sum): `{'Inputs': '++|'}`
- `Hinf_nonlinear_sim/Sum5` (Sum): `{'Inputs': '|+-'}`
- `Hinf_nonlinear_sim/Sum6` (Sum): `{'NameLocation': 'top', 'Inputs': '|++'}`
- `Hinf_nonlinear_sim/Sum7` (Sum): `{'Inputs': '|++'}`
- `Hinf_nonlinear_sim/Sum8` (Sum): `{'Inputs': '|++'}`
- `Hinf_nonlinear_sim/Sum9` (Sum): `{'NameLocation': 'top', 'Inputs': '|++'}`
- `Hinf_nonlinear_sim/r1` (Step): `{'FinalValue': '5*pi/180', 'SampleTime': '0'}`
- `Hinf_nonlinear_sim/r2` (Step): `{'FinalValue': '0', 'SampleTime': '0'}`

### Connessioni

- `Hinf_nonlinear_sim/Actuators/Actuator 2#out:1` → `Hinf_nonlinear_sim/Actuators/Mux#in:2`
- `Hinf_nonlinear_sim/Actuators/Demux#out:2` → `Hinf_nonlinear_sim/Actuators/Actuator 2#in:1`
- `Hinf_nonlinear_sim/Actuators/u#out:1` → `Hinf_nonlinear_sim/Actuators/Demux#in:1`
- `Hinf_nonlinear_sim/Actuators/Demux#out:1` → `Hinf_nonlinear_sim/Actuators/Actuator 1#in:1`
- `Hinf_nonlinear_sim/Actuators/Mux#out:1` → `Hinf_nonlinear_sim/Actuators/tau#in:1`
- `Hinf_nonlinear_sim/Actuators/Actuator 1#out:1` → `Hinf_nonlinear_sim/Actuators/Mux#in:1`
- `Hinf_nonlinear_sim/Actuators1/Actuator 2#out:1` → `Hinf_nonlinear_sim/Actuators1/Mux#in:2`
- `Hinf_nonlinear_sim/Actuators1/Demux#out:2` → `Hinf_nonlinear_sim/Actuators1/Actuator 2#in:1`
- `Hinf_nonlinear_sim/Actuators1/u#out:1` → `Hinf_nonlinear_sim/Actuators1/Demux#in:1`
- `Hinf_nonlinear_sim/Actuators1/Demux#out:1` → `Hinf_nonlinear_sim/Actuators1/Actuator 1#in:1`
- `Hinf_nonlinear_sim/Actuators1/Mux#out:1` → `Hinf_nonlinear_sim/Actuators1/tau#in:1`
- `Hinf_nonlinear_sim/Actuators1/Actuator 1#out:1` → `Hinf_nonlinear_sim/Actuators1/Mux#in:1`
- `Hinf_nonlinear_sim/Actuators2/Actuator 2#out:1` → `Hinf_nonlinear_sim/Actuators2/Mux#in:2`
- `Hinf_nonlinear_sim/Actuators2/Demux#out:2` → `Hinf_nonlinear_sim/Actuators2/Actuator 2#in:1`
- `Hinf_nonlinear_sim/Actuators2/u#out:1` → `Hinf_nonlinear_sim/Actuators2/Demux#in:1`
- `Hinf_nonlinear_sim/Actuators2/Demux#out:1` → `Hinf_nonlinear_sim/Actuators2/Actuator 1#in:1`
- `Hinf_nonlinear_sim/Actuators2/Mux#out:1` → `Hinf_nonlinear_sim/Actuators2/tau#in:1`
- `Hinf_nonlinear_sim/Actuators2/Actuator 1#out:1` → `Hinf_nonlinear_sim/Actuators2/Mux#in:1`
- `Hinf_nonlinear_sim/Non linear plant/MATLAB Function/x#out:1` → `Hinf_nonlinear_sim/Non linear plant/MATLAB Function/ SFunction #in:1`
- `Hinf_nonlinear_sim/Non linear plant/MATLAB Function/tau#out:1` → `Hinf_nonlinear_sim/Non linear plant/MATLAB Function/ SFunction #in:2`
- `Hinf_nonlinear_sim/Non linear plant/MATLAB Function/d#out:1` → `Hinf_nonlinear_sim/Non linear plant/MATLAB Function/ SFunction #in:3`
- `Hinf_nonlinear_sim/Non linear plant/MATLAB Function/p#out:1` → `Hinf_nonlinear_sim/Non linear plant/MATLAB Function/ SFunction #in:4`
- `Hinf_nonlinear_sim/Non linear plant/MATLAB Function/ SFunction #out:2` → `Hinf_nonlinear_sim/Non linear plant/MATLAB Function/xdot#in:1`
- `Hinf_nonlinear_sim/Non linear plant/MATLAB Function/ Demux #out:1` → `Hinf_nonlinear_sim/Non linear plant/MATLAB Function/ Terminator #in:1`
- `Hinf_nonlinear_sim/Non linear plant/MATLAB Function/ SFunction #out:1` → `Hinf_nonlinear_sim/Non linear plant/MATLAB Function/ Demux #in:1`
- `Hinf_nonlinear_sim/Non linear plant/MATLAB Function1/ SFunction #out:2` → `Hinf_nonlinear_sim/Non linear plant/MATLAB Function1/p#in:1`
- `Hinf_nonlinear_sim/Non linear plant/MATLAB Function1/ Ground #out:1` → `Hinf_nonlinear_sim/Non linear plant/MATLAB Function1/ SFunction #in:1`
- `Hinf_nonlinear_sim/Non linear plant/MATLAB Function1/ Demux #out:1` → `Hinf_nonlinear_sim/Non linear plant/MATLAB Function1/ Terminator #in:1`
- `Hinf_nonlinear_sim/Non linear plant/MATLAB Function1/ SFunction #out:1` → `Hinf_nonlinear_sim/Non linear plant/MATLAB Function1/ Demux #in:1`
- `Hinf_nonlinear_sim/Non linear plant/x#out:1` → `Hinf_nonlinear_sim/Non linear plant/MATLAB Function#in:1`
- `Hinf_nonlinear_sim/Non linear plant/tau#out:1` → `Hinf_nonlinear_sim/Non linear plant/MATLAB Function#in:2`
- `Hinf_nonlinear_sim/Non linear plant/MATLAB Function#out:1` → `Hinf_nonlinear_sim/Non linear plant/xdot#in:1`
- `Hinf_nonlinear_sim/Non linear plant/MATLAB Function1#out:1` → `Hinf_nonlinear_sim/Non linear plant/MATLAB Function#in:4`
- `Hinf_nonlinear_sim/Non linear plant/d#out:1` → `Hinf_nonlinear_sim/Non linear plant/MATLAB Function#in:3`
- `Hinf_nonlinear_sim/Non linear plant1/MATLAB Function/x#out:1` → `Hinf_nonlinear_sim/Non linear plant1/MATLAB Function/ SFunction #in:1`
- `Hinf_nonlinear_sim/Non linear plant1/MATLAB Function/tau#out:1` → `Hinf_nonlinear_sim/Non linear plant1/MATLAB Function/ SFunction #in:2`
- `Hinf_nonlinear_sim/Non linear plant1/MATLAB Function/d#out:1` → `Hinf_nonlinear_sim/Non linear plant1/MATLAB Function/ SFunction #in:3`
- `Hinf_nonlinear_sim/Non linear plant1/MATLAB Function/p#out:1` → `Hinf_nonlinear_sim/Non linear plant1/MATLAB Function/ SFunction #in:4`
- `Hinf_nonlinear_sim/Non linear plant1/MATLAB Function/ SFunction #out:2` → `Hinf_nonlinear_sim/Non linear plant1/MATLAB Function/xdot#in:1`
- `Hinf_nonlinear_sim/Non linear plant1/MATLAB Function/ Demux #out:1` → `Hinf_nonlinear_sim/Non linear plant1/MATLAB Function/ Terminator #in:1`
- `Hinf_nonlinear_sim/Non linear plant1/MATLAB Function/ SFunction #out:1` → `Hinf_nonlinear_sim/Non linear plant1/MATLAB Function/ Demux #in:1`
- `Hinf_nonlinear_sim/Non linear plant1/MATLAB Function1/ SFunction #out:2` → `Hinf_nonlinear_sim/Non linear plant1/MATLAB Function1/p#in:1`
- `Hinf_nonlinear_sim/Non linear plant1/MATLAB Function1/ Ground #out:1` → `Hinf_nonlinear_sim/Non linear plant1/MATLAB Function1/ SFunction #in:1`
- `Hinf_nonlinear_sim/Non linear plant1/MATLAB Function1/ Demux #out:1` → `Hinf_nonlinear_sim/Non linear plant1/MATLAB Function1/ Terminator #in:1`
- `Hinf_nonlinear_sim/Non linear plant1/MATLAB Function1/ SFunction #out:1` → `Hinf_nonlinear_sim/Non linear plant1/MATLAB Function1/ Demux #in:1`
- `Hinf_nonlinear_sim/Non linear plant1/x#out:1` → `Hinf_nonlinear_sim/Non linear plant1/MATLAB Function#in:1`
- `Hinf_nonlinear_sim/Non linear plant1/tau#out:1` → `Hinf_nonlinear_sim/Non linear plant1/MATLAB Function#in:2`
- `Hinf_nonlinear_sim/Non linear plant1/MATLAB Function#out:1` → `Hinf_nonlinear_sim/Non linear plant1/xdot#in:1`
- `Hinf_nonlinear_sim/Non linear plant1/MATLAB Function1#out:1` → `Hinf_nonlinear_sim/Non linear plant1/MATLAB Function#in:4`
- `Hinf_nonlinear_sim/Non linear plant1/d#out:1` → `Hinf_nonlinear_sim/Non linear plant1/MATLAB Function#in:3`
- `Hinf_nonlinear_sim/Non linear plant2/MATLAB Function/x#out:1` → `Hinf_nonlinear_sim/Non linear plant2/MATLAB Function/ SFunction #in:1`
- `Hinf_nonlinear_sim/Non linear plant2/MATLAB Function/tau#out:1` → `Hinf_nonlinear_sim/Non linear plant2/MATLAB Function/ SFunction #in:2`
- `Hinf_nonlinear_sim/Non linear plant2/MATLAB Function/d#out:1` → `Hinf_nonlinear_sim/Non linear plant2/MATLAB Function/ SFunction #in:3`
- `Hinf_nonlinear_sim/Non linear plant2/MATLAB Function/p#out:1` → `Hinf_nonlinear_sim/Non linear plant2/MATLAB Function/ SFunction #in:4`
- `Hinf_nonlinear_sim/Non linear plant2/MATLAB Function/ SFunction #out:2` → `Hinf_nonlinear_sim/Non linear plant2/MATLAB Function/xdot#in:1`
- `Hinf_nonlinear_sim/Non linear plant2/MATLAB Function/ Demux #out:1` → `Hinf_nonlinear_sim/Non linear plant2/MATLAB Function/ Terminator #in:1`
- `Hinf_nonlinear_sim/Non linear plant2/MATLAB Function/ SFunction #out:1` → `Hinf_nonlinear_sim/Non linear plant2/MATLAB Function/ Demux #in:1`
- `Hinf_nonlinear_sim/Non linear plant2/MATLAB Function1/ SFunction #out:2` → `Hinf_nonlinear_sim/Non linear plant2/MATLAB Function1/p#in:1`
- `Hinf_nonlinear_sim/Non linear plant2/MATLAB Function1/ Ground #out:1` → `Hinf_nonlinear_sim/Non linear plant2/MATLAB Function1/ SFunction #in:1`
- `Hinf_nonlinear_sim/Non linear plant2/MATLAB Function1/ Demux #out:1` → `Hinf_nonlinear_sim/Non linear plant2/MATLAB Function1/ Terminator #in:1`
- `Hinf_nonlinear_sim/Non linear plant2/MATLAB Function1/ SFunction #out:1` → `Hinf_nonlinear_sim/Non linear plant2/MATLAB Function1/ Demux #in:1`
- `Hinf_nonlinear_sim/Non linear plant2/x#out:1` → `Hinf_nonlinear_sim/Non linear plant2/MATLAB Function#in:1`
- `Hinf_nonlinear_sim/Non linear plant2/tau#out:1` → `Hinf_nonlinear_sim/Non linear plant2/MATLAB Function#in:2`
- `Hinf_nonlinear_sim/Non linear plant2/MATLAB Function#out:1` → `Hinf_nonlinear_sim/Non linear plant2/xdot#in:1`
- `Hinf_nonlinear_sim/Non linear plant2/MATLAB Function1#out:1` → `Hinf_nonlinear_sim/Non linear plant2/MATLAB Function#in:4`
- `Hinf_nonlinear_sim/Non linear plant2/d#out:1` → `Hinf_nonlinear_sim/Non linear plant2/MATLAB Function#in:3`
- `Hinf_nonlinear_sim/Demux10#out:1` → `Hinf_nonlinear_sim/Uscita misurata (2-DoF)#in:5`
- `Hinf_nonlinear_sim/Demux8#out:1` → `Hinf_nonlinear_sim/Uscita ideale (PID)#in:5`
- `Hinf_nonlinear_sim/Demux8#out:2` → `Hinf_nonlinear_sim/Uscita ideale (PID)#in:6`
- `Hinf_nonlinear_sim/Demux9#out:4` → `Hinf_nonlinear_sim/Uscita misurata (2-DoF)#in:4`
- `Hinf_nonlinear_sim/Demux4#out:1` → `Hinf_nonlinear_sim/Uscita misurata (1-DoF)#in:5`
- `Hinf_nonlinear_sim/From18#out:1` → `Hinf_nonlinear_sim/Variabili di controllo#in:3`
- `Hinf_nonlinear_sim/Demux15#out:1` → `Hinf_nonlinear_sim/Confronto uscite#in:3`
- `Hinf_nonlinear_sim/r1#out:1` → `Hinf_nonlinear_sim/Mux#in:1`
- `Hinf_nonlinear_sim/Demux3#out:2` → `Hinf_nonlinear_sim/Uscita ideale (1-DoF)#in:6`
- `Hinf_nonlinear_sim/Selector#out:1` → `Hinf_nonlinear_sim/Sum#in:2`
- `Hinf_nonlinear_sim/Demux7#out:3` → `Hinf_nonlinear_sim/Uscita ideale (PID)#in:3`
- `Hinf_nonlinear_sim/Demux5#out:3` → `Hinf_nonlinear_sim/Uscita ideale (2-DoF)#in:3`
- `Hinf_nonlinear_sim/Demux5#out:2` → `Hinf_nonlinear_sim/Uscita ideale (2-DoF)#in:2`
- `Hinf_nonlinear_sim/Demux11#out:3` → `Hinf_nonlinear_sim/Uscita misurata (PID)#in:3`
- `Hinf_nonlinear_sim/Demux7#out:4` → `Hinf_nonlinear_sim/Uscita ideale (PID)#in:4`
- `Hinf_nonlinear_sim/Demux1#out:2` → `Hinf_nonlinear_sim/Uscita misurata (1-DoF)#in:2`
- `Hinf_nonlinear_sim/Demux1#out:1` → `Hinf_nonlinear_sim/Uscita misurata (1-DoF)#in:1`
- `Hinf_nonlinear_sim/From10#out:1` → `Hinf_nonlinear_sim/Demux10#in:1`
- `Hinf_nonlinear_sim/From2#out:1` → `Hinf_nonlinear_sim/Demux1#in:1`
- `Hinf_nonlinear_sim/From16#out:1` → `Hinf_nonlinear_sim/Demux16#in:1`
- `Hinf_nonlinear_sim/From15#out:1` → `Hinf_nonlinear_sim/Demux15#in:1`
- `Hinf_nonlinear_sim/Demux9#out:2` → `Hinf_nonlinear_sim/Uscita misurata (2-DoF)#in:2`
- `Hinf_nonlinear_sim/Controller H-inf (1-DoF)#out:1` → `Hinf_nonlinear_sim/Sum8#in:1`
- `Hinf_nonlinear_sim/Controller H-inf (1-DoF)#out:1` → `Hinf_nonlinear_sim/Goto#in:1`
- `Hinf_nonlinear_sim/Demux11#out:4` → `Hinf_nonlinear_sim/Uscita misurata (PID)#in:4`
- `Hinf_nonlinear_sim/From#out:1` → `Hinf_nonlinear_sim/Variabili di controllo#in:1`
- `Hinf_nonlinear_sim/Demux#out:3` → `Hinf_nonlinear_sim/Uscita ideale (1-DoF)#in:3`
- `Hinf_nonlinear_sim/Demux11#out:1` → `Hinf_nonlinear_sim/Uscita misurata (PID)#in:1`
- `Hinf_nonlinear_sim/From3#out:1` → `Hinf_nonlinear_sim/Demux3#in:1`
- `Hinf_nonlinear_sim/Demux7#out:2` → `Hinf_nonlinear_sim/Uscita ideale (PID)#in:2`
- `Hinf_nonlinear_sim/Demux#out:2` → `Hinf_nonlinear_sim/Uscita ideale (1-DoF)#in:2`
- `Hinf_nonlinear_sim/Demux9#out:3` → `Hinf_nonlinear_sim/Uscita misurata (2-DoF)#in:3`
- `Hinf_nonlinear_sim/From5#out:1` → `Hinf_nonlinear_sim/Demux5#in:1`
- `Hinf_nonlinear_sim/From9#out:1` → `Hinf_nonlinear_sim/Demux9#in:1`
- `Hinf_nonlinear_sim/Demux14#out:1` → `Hinf_nonlinear_sim/Confronto uscite#in:2`
- `Hinf_nonlinear_sim/From1#out:1` → `Hinf_nonlinear_sim/Demux#in:1`
- `Hinf_nonlinear_sim/From7#out:1` → `Hinf_nonlinear_sim/Demux7#in:1`
- `Hinf_nonlinear_sim/Demux5#out:4` → `Hinf_nonlinear_sim/Uscita ideale (2-DoF)#in:4`
- `Hinf_nonlinear_sim/Demux#out:1` → `Hinf_nonlinear_sim/Uscita ideale (1-DoF)#in:1`
- `Hinf_nonlinear_sim/r2#out:1` → `Hinf_nonlinear_sim/Mux#in:2`
- `Hinf_nonlinear_sim/Demux6#out:1` → `Hinf_nonlinear_sim/Uscita ideale (2-DoF)#in:5`
- `Hinf_nonlinear_sim/Demux3#out:1` → `Hinf_nonlinear_sim/Uscita ideale (1-DoF)#in:5`
- `Hinf_nonlinear_sim/Demux4#out:2` → `Hinf_nonlinear_sim/Uscita misurata (1-DoF)#in:6`
- `Hinf_nonlinear_sim/From12#out:1` → `Hinf_nonlinear_sim/Demux12#in:1`
- `Hinf_nonlinear_sim/From6#out:1` → `Hinf_nonlinear_sim/Demux6#in:1`
- `Hinf_nonlinear_sim/From8#out:1` → `Hinf_nonlinear_sim/Demux8#in:1`
- `Hinf_nonlinear_sim/Demux9#out:1` → `Hinf_nonlinear_sim/Uscita misurata (2-DoF)#in:1`
- `Hinf_nonlinear_sim/Mux#out:1` → `Hinf_nonlinear_sim/Mux2#in:1`
- `Hinf_nonlinear_sim/Mux#out:1` → `Hinf_nonlinear_sim/Mux1#in:1`
- `Hinf_nonlinear_sim/Mux#out:1` → `Hinf_nonlinear_sim/Goto3#in:1`
- `Hinf_nonlinear_sim/Mux#out:1` → `Hinf_nonlinear_sim/Sum#in:1`
- `Hinf_nonlinear_sim/Demux1#out:3` → `Hinf_nonlinear_sim/Uscita misurata (1-DoF)#in:3`
- `Hinf_nonlinear_sim/Sum#out:1` → `Hinf_nonlinear_sim/Controller H-inf (1-DoF)#in:1`
- `Hinf_nonlinear_sim/Demux13#out:1` → `Hinf_nonlinear_sim/Confronto uscite#in:1`
- `Hinf_nonlinear_sim/Demux6#out:2` → `Hinf_nonlinear_sim/Uscita ideale (2-DoF)#in:6`
- `Hinf_nonlinear_sim/From14#out:1` → `Hinf_nonlinear_sim/Demux14#in:1`
- `Hinf_nonlinear_sim/Demux16#out:1` → `Hinf_nonlinear_sim/Confronto uscite#in:4`
- `Hinf_nonlinear_sim/Demux#out:4` → `Hinf_nonlinear_sim/Uscita ideale (1-DoF)#in:4`
- `Hinf_nonlinear_sim/From4#out:1` → `Hinf_nonlinear_sim/Demux4#in:1`
- `Hinf_nonlinear_sim/From13#out:1` → `Hinf_nonlinear_sim/Demux13#in:1`
- `Hinf_nonlinear_sim/Demux12#out:1` → `Hinf_nonlinear_sim/Uscita misurata (PID)#in:5`
- `Hinf_nonlinear_sim/From11#out:1` → `Hinf_nonlinear_sim/Demux11#in:1`
- `Hinf_nonlinear_sim/Demux7#out:1` → `Hinf_nonlinear_sim/Uscita ideale (PID)#in:1`
- `Hinf_nonlinear_sim/Demux5#out:1` → `Hinf_nonlinear_sim/Uscita ideale (2-DoF)#in:1`
- `Hinf_nonlinear_sim/Demux10#out:2` → `Hinf_nonlinear_sim/Uscita misurata (2-DoF)#in:6`
- `Hinf_nonlinear_sim/Demux1#out:4` → `Hinf_nonlinear_sim/Uscita misurata (1-DoF)#in:4`
- `Hinf_nonlinear_sim/Demux11#out:2` → `Hinf_nonlinear_sim/Uscita misurata (PID)#in:2`
- `Hinf_nonlinear_sim/Demux12#out:2` → `Hinf_nonlinear_sim/Uscita misurata (PID)#in:6`
- `Hinf_nonlinear_sim/From17#out:1` → `Hinf_nonlinear_sim/Variabili di controllo#in:2`
- `Hinf_nonlinear_sim/Actuators#out:1` → `Hinf_nonlinear_sim/Sum4#in:2`
- `Hinf_nonlinear_sim/Disturbi di coppia#out:1` → `Hinf_nonlinear_sim/Sum7#in:1`
- `Hinf_nonlinear_sim/Sum4#out:1` → `Hinf_nonlinear_sim/Non linear plant#in:2`
- `Hinf_nonlinear_sim/Constant#out:1` → `Hinf_nonlinear_sim/Sum4#in:1`
- `Hinf_nonlinear_sim/Selettore#out:1` → `Hinf_nonlinear_sim/Sum6#in:1`
- `Hinf_nonlinear_sim/Selettore#out:1` → `Hinf_nonlinear_sim/Goto11#in:1`
- `Hinf_nonlinear_sim/Constant4#out:1` → `Hinf_nonlinear_sim/Sum5#in:2`
- `Hinf_nonlinear_sim/Integrator#out:1` → `Hinf_nonlinear_sim/Non linear plant#in:1`
- `Hinf_nonlinear_sim/Integrator#out:1` → `Hinf_nonlinear_sim/Sum5#in:1`
- `Hinf_nonlinear_sim/Sum5#out:1` → `Hinf_nonlinear_sim/Selettore#in:1`
- `Hinf_nonlinear_sim/Sum8#out:1` → `Hinf_nonlinear_sim/Actuators#in:1`
- `Hinf_nonlinear_sim/Non linear plant#out:1` → `Hinf_nonlinear_sim/Integrator#in:1`
- `Hinf_nonlinear_sim/Sum6#out:1` → `Hinf_nonlinear_sim/Goto2#in:1`
- `Hinf_nonlinear_sim/Sum6#out:1` → `Hinf_nonlinear_sim/Selector#in:1`
- `Hinf_nonlinear_sim/Rumore di processo link#out:1` → `Hinf_nonlinear_sim/Sum7#in:2`
- `Hinf_nonlinear_sim/Sum9#out:1` → `Hinf_nonlinear_sim/Goto5#in:1`
- `Hinf_nonlinear_sim/Sum9#out:1` → `Hinf_nonlinear_sim/Selector1#in:1`
- `Hinf_nonlinear_sim/Controller H-inf (2-DoF)#out:1` → `Hinf_nonlinear_sim/Sum11#in:1`
- `Hinf_nonlinear_sim/Controller H-inf (2-DoF)#out:1` → `Hinf_nonlinear_sim/Goto1#in:1`
- `Hinf_nonlinear_sim/Selector1#out:1` → `Hinf_nonlinear_sim/Mux1#in:2`
- `Hinf_nonlinear_sim/Rumore di processo link1#out:1` → `Hinf_nonlinear_sim/Sum10#in:2`
- `Hinf_nonlinear_sim/Sum11#out:1` → `Hinf_nonlinear_sim/Actuators1#in:1`
- `Hinf_nonlinear_sim/Non linear plant1#out:1` → `Hinf_nonlinear_sim/Integrator1#in:1`
- `Hinf_nonlinear_sim/Sum3#out:1` → `Hinf_nonlinear_sim/Selettore1#in:1`
- `Hinf_nonlinear_sim/Selettore1#out:1` → `Hinf_nonlinear_sim/Sum9#in:1`
- `Hinf_nonlinear_sim/Selettore1#out:1` → `Hinf_nonlinear_sim/Goto4#in:1`
- `Hinf_nonlinear_sim/Constant2#out:1` → `Hinf_nonlinear_sim/Sum3#in:2`
- `Hinf_nonlinear_sim/Sum2#out:1` → `Hinf_nonlinear_sim/Non linear plant1#in:2`
- `Hinf_nonlinear_sim/Integrator1#out:1` → `Hinf_nonlinear_sim/Non linear plant1#in:1`
- `Hinf_nonlinear_sim/Integrator1#out:1` → `Hinf_nonlinear_sim/Sum3#in:1`
- `Hinf_nonlinear_sim/Actuators1#out:1` → `Hinf_nonlinear_sim/Sum2#in:2`
- `Hinf_nonlinear_sim/Constant1#out:1` → `Hinf_nonlinear_sim/Sum2#in:1`
- `Hinf_nonlinear_sim/Disturbi di coppia1#out:1` → `Hinf_nonlinear_sim/Sum10#in:1`
- `Hinf_nonlinear_sim/Constant3#out:1` → `Hinf_nonlinear_sim/Sum15#in:1`
- `Hinf_nonlinear_sim/Actuators2#out:1` → `Hinf_nonlinear_sim/Sum15#in:2`
- `Hinf_nonlinear_sim/Disturbi di coppia2#out:1` → `Hinf_nonlinear_sim/Sum13#in:1`
- `Hinf_nonlinear_sim/Selettore2#out:1` → `Hinf_nonlinear_sim/Sum17#in:1`
- `Hinf_nonlinear_sim/Selettore2#out:1` → `Hinf_nonlinear_sim/Goto7#in:1`
- `Hinf_nonlinear_sim/Sum15#out:1` → `Hinf_nonlinear_sim/Non linear plant2#in:2`
- `Hinf_nonlinear_sim/Constant5#out:1` → `Hinf_nonlinear_sim/Sum16#in:2`
- `Hinf_nonlinear_sim/Mux2#out:1` → `Hinf_nonlinear_sim/Controller H-inf (PID struct)1#in:1`
- `Hinf_nonlinear_sim/Sum16#out:1` → `Hinf_nonlinear_sim/Selettore2#in:1`
- `Hinf_nonlinear_sim/Controller H-inf (PID struct)1#out:1` → `Hinf_nonlinear_sim/Sum14#in:1`
- `Hinf_nonlinear_sim/Controller H-inf (PID struct)1#out:1` → `Hinf_nonlinear_sim/Goto6#in:1`
- `Hinf_nonlinear_sim/Selector2#out:1` → `Hinf_nonlinear_sim/Mux2#in:2`
- `Hinf_nonlinear_sim/Rumore di processo link2#out:1` → `Hinf_nonlinear_sim/Sum13#in:2`
- `Hinf_nonlinear_sim/Sum14#out:1` → `Hinf_nonlinear_sim/Actuators2#in:1`
- `Hinf_nonlinear_sim/Sum17#out:1` → `Hinf_nonlinear_sim/Goto8#in:1`
- `Hinf_nonlinear_sim/Sum17#out:1` → `Hinf_nonlinear_sim/Selector2#in:1`
- `Hinf_nonlinear_sim/Non linear plant2#out:1` → `Hinf_nonlinear_sim/Integrator2#in:1`
- `Hinf_nonlinear_sim/Integrator2#out:1` → `Hinf_nonlinear_sim/Non linear plant2#in:1`
- `Hinf_nonlinear_sim/Integrator2#out:1` → `Hinf_nonlinear_sim/Sum16#in:1`
- `Hinf_nonlinear_sim/Mux1#out:1` → `Hinf_nonlinear_sim/Controller H-inf (2-DoF)#in:1`
- `Hinf_nonlinear_sim/Manual Switch#out:1` → `Hinf_nonlinear_sim/Non linear plant#in:3`
- `Hinf_nonlinear_sim/Sum7#out:1` → `Hinf_nonlinear_sim/Manual Switch#in:1`
- `Hinf_nonlinear_sim/Constant8#out:1` → `Hinf_nonlinear_sim/Manual Switch#in:2`
- `Hinf_nonlinear_sim/Manual Switch1#out:1` → `Hinf_nonlinear_sim/Non linear plant1#in:3`
- `Hinf_nonlinear_sim/Sum10#out:1` → `Hinf_nonlinear_sim/Manual Switch1#in:1`
- `Hinf_nonlinear_sim/Constant6#out:1` → `Hinf_nonlinear_sim/Manual Switch1#in:2`
- `Hinf_nonlinear_sim/Manual Switch2#out:1` → `Hinf_nonlinear_sim/Non linear plant2#in:3`
- `Hinf_nonlinear_sim/Sum13#out:1` → `Hinf_nonlinear_sim/Manual Switch2#in:1`
- `Hinf_nonlinear_sim/Constant7#out:1` → `Hinf_nonlinear_sim/Manual Switch2#in:2`
- `Hinf_nonlinear_sim/Rumori di misura1#out:1` → `Hinf_nonlinear_sim/Sum9#in:2`
- `Hinf_nonlinear_sim/Rumore di processo u1#out:1` → `Hinf_nonlinear_sim/Sum11#in:2`
- `Hinf_nonlinear_sim/Rumore di processo u3#out:1` → `Hinf_nonlinear_sim/Sum8#in:2`
- `Hinf_nonlinear_sim/Rumori di misura3#out:1` → `Hinf_nonlinear_sim/Sum6#in:2`
- `Hinf_nonlinear_sim/Rumore di processo u2#out:1` → `Hinf_nonlinear_sim/Sum14#in:2`
- `Hinf_nonlinear_sim/Rumori di misura2#out:1` → `Hinf_nonlinear_sim/Sum17#in:2`

### Callback InitFcn

```matlab
actuator = actuator_params_nominal();
[Gact, info] = build_nominal_actuator(actuator);

% Parametri del robot
p = sea_params_nominal();
Simulink.Bus.createObject(p);

% Equilibrio desiderato
qbar = [pi/2; 0];

% Calcolo stato e coppia di equilibrio
[xbar, taubar, info] = sea_static_equilibrium(qbar, p);


```

### Funzione incorporata: simulink/stateflow/chart_10.xml

```matlab
function p = sea_params_nominal
%SEA_PARAMS_NOMINAL Nominal mechanical parameters of the 2R SEA robot.
%   P = SEA_PARAMS_NOMINAL returns the values stated by the official
%   assignment. Matrices follow the joint order [joint 1; joint 2].

p.m1 = 1.0;                   % kg
p.m2 = 0.8;                   % kg
p.l1 = 0.4;                   % m
p.l2 = 0.3;                   % m
p.Jm = diag([0.01, 0.01]);    % kg*m^2
p.Bm = diag([0.02, 0.02]);    % N*m*s/rad
p.Ks = diag([50, 40]);        % N*m/rad
p.g = 9.81;                   % m/s^2
end

```

### Funzione incorporata: simulink/stateflow/chart_16.xml

```matlab
function xdot = sea_nonlinear_rhs_with_link_disturbance(x, tau, d, p)
%SEA_NONLINEAR_RHS_WITH_LINK_DISTURBANCE SEA dynamics with link torque D.
%   TAU remains the motor-side input; D is an external link-side joint
%   torque entering with positive sign in the link equation.

assert(numel(x) == 8, ...
    'sea_nonlinear_rhs_with_link_disturbance:InvalidState', ...
    'The state must contain exactly eight elements.');
assert(numel(tau) == 2 && numel(d) == 2, ...
    'sea_nonlinear_rhs_with_link_disturbance:InvalidInput', ...
    'Both tau and d must contain exactly two elements.');
x = reshape(x, 8, 1);
tau = reshape(tau, 2, 1);
d = reshape(d, 2, 1);

q = x(1:2);
qdot = x(3:4);
theta = x(5:6);
thetadot = x(7:8);
M = sea_link_inertia(q, p);
C = sea_coriolis(q, qdot, p);
G = sea_gravity(q, p);
tauElastic = sea_elastic_torque(q, theta, p);

qddot = M \ (tauElastic + d - C * qdot - G);
thetaddot = p.Jm \ (tau - p.Bm * thetadot - tauElastic);
xdot = [qdot; qddot; thetadot; thetaddot];
end

```

### Funzione incorporata: simulink/stateflow/chart_26.xml

```matlab
function xdot = sea_nonlinear_rhs_with_link_disturbance(x, tau, d, p)
%SEA_NONLINEAR_RHS_WITH_LINK_DISTURBANCE SEA dynamics with link torque D.
%   TAU remains the motor-side input; D is an external link-side joint
%   torque entering with positive sign in the link equation.

assert(numel(x) == 8, ...
    'sea_nonlinear_rhs_with_link_disturbance:InvalidState', ...
    'The state must contain exactly eight elements.');
assert(numel(tau) == 2 && numel(d) == 2, ...
    'sea_nonlinear_rhs_with_link_disturbance:InvalidInput', ...
    'Both tau and d must contain exactly two elements.');
x = reshape(x, 8, 1);
tau = reshape(tau, 2, 1);
d = reshape(d, 2, 1);

q = x(1:2);
qdot = x(3:4);
theta = x(5:6);
thetadot = x(7:8);
M = sea_link_inertia(q, p);
C = sea_coriolis(q, qdot, p);
G = sea_gravity(q, p);
tauElastic = sea_elastic_torque(q, theta, p);

qddot = M \ (tauElastic + d - C * qdot - G);
thetaddot = p.Jm \ (tau - p.Bm * thetadot - tauElastic);
xdot = [qdot; qddot; thetadot; thetaddot];
end

```

### Funzione incorporata: simulink/stateflow/chart_36.xml

```matlab
function p = sea_params_nominal
%SEA_PARAMS_NOMINAL Nominal mechanical parameters of the 2R SEA robot.
%   P = SEA_PARAMS_NOMINAL returns the values stated by the official
%   assignment. Matrices follow the joint order [joint 1; joint 2].

p.m1 = 1.0;                   % kg
p.m2 = 0.8;                   % kg
p.l1 = 0.4;                   % m
p.l2 = 0.3;                   % m
p.Jm = diag([0.01, 0.01]);    % kg*m^2
p.Bm = diag([0.02, 0.02]);    % N*m*s/rad
p.Ks = diag([50, 40]);        % N*m/rad
p.g = 9.81;                   % m/s^2
end

```

### Funzione incorporata: simulink/stateflow/chart_42.xml

```matlab
function xdot = sea_nonlinear_rhs_with_link_disturbance(x, tau, d, p)
%SEA_NONLINEAR_RHS_WITH_LINK_DISTURBANCE SEA dynamics with link torque D.
%   TAU remains the motor-side input; D is an external link-side joint
%   torque entering with positive sign in the link equation.

assert(numel(x) == 8, ...
    'sea_nonlinear_rhs_with_link_disturbance:InvalidState', ...
    'The state must contain exactly eight elements.');
assert(numel(tau) == 2 && numel(d) == 2, ...
    'sea_nonlinear_rhs_with_link_disturbance:InvalidInput', ...
    'Both tau and d must contain exactly two elements.');
x = reshape(x, 8, 1);
tau = reshape(tau, 2, 1);
d = reshape(d, 2, 1);

q = x(1:2);
qdot = x(3:4);
theta = x(5:6);
thetadot = x(7:8);
M = sea_link_inertia(q, p);
C = sea_coriolis(q, qdot, p);
G = sea_gravity(q, p);
tauElastic = sea_elastic_torque(q, theta, p);

qddot = M \ (tauElastic + d - C * qdot - G);
thetaddot = p.Jm \ (tau - p.Bm * thetadot - tauElastic);
xdot = [qdot; qddot; thetadot; thetaddot];
end

```

### Funzione incorporata: simulink/stateflow/chart_52.xml

```matlab
function p = sea_params_nominal
%SEA_PARAMS_NOMINAL Nominal mechanical parameters of the 2R SEA robot.
%   P = SEA_PARAMS_NOMINAL returns the values stated by the official
%   assignment. Matrices follow the joint order [joint 1; joint 2].

p.m1 = 1.0;                   % kg
p.m2 = 0.8;                   % kg
p.l1 = 0.4;                   % m
p.l2 = 0.3;                   % m
p.Jm = diag([0.01, 0.01]);    % kg*m^2
p.Bm = diag([0.02, 0.02]);    % N*m*s/rad
p.Ks = diag([50, 40]);        % N*m/rad
p.g = 9.81;                   % m/s^2
end

```
## LQG_linear_sim.slx

Release: {'version': '26.1.0.3312084', 'release': 'R2026a', 'description': 'Update 4', 'date': 'Jun 30 2026', 'checksum': '4132326121'}

SHA-256: `eb01cb8e66b919301181c647c931d9ffbaf48dac3b0fc5eb8d8df87da36f1ea9`

Configurazione: `{'SolverName': 'VariableStepAuto'}`

### Blocchi e parametri

- `LQG_linear_sim/Demux` (Demux): `{}`
- `LQG_linear_sim/Demux1` (Demux): `{}`
- `LQG_linear_sim/Demux2` (Demux): `{'Outputs': '2'}`
- `LQG_linear_sim/Demux3` (Demux): `{'Outputs': '2'}`
- `LQG_linear_sim/Demux4` (Demux): `{'Outputs': '2'}`
- `LQG_linear_sim/Disturbo di coppia` (Step): `{'Time': '[1 1]', 'InitialValue': '[0 0]', 'FinalValue': '[0.5 0]', 'SampleTime': '0'}`
- `LQG_linear_sim/Gain` (Gain): `{'Gain': 'K', 'Multiplication': 'Matrix(K*u)'}`
- `LQG_linear_sim/Gain1` (Gain): `{'Gain': 'Nr', 'Multiplication': 'Matrix(K*u)'}`
- `LQG_linear_sim/Kalman filter/u` (Inport): `{}`
- `LQG_linear_sim/Kalman filter/y` (Inport): `{'Port': '2'}`
- `LQG_linear_sim/Kalman filter/Add` (Sum): `{'IconShape': 'rectangular', 'Inputs': '+++'}`
- `LQG_linear_sim/Kalman filter/Gain` (Gain): `{'Gain': 'A', 'Multiplication': 'Matrix(K*u)'}`
- `LQG_linear_sim/Kalman filter/Gain1` (Gain): `{'BlockMirror': 'on', 'Gain': 'C', 'Multiplication': 'Matrix(K*u)'}`
- `LQG_linear_sim/Kalman filter/Gain2` (Gain): `{'Gain': 'B', 'Multiplication': 'Matrix(K*u)'}`
- `LQG_linear_sim/Kalman filter/Gain3` (Gain): `{'Gain': 'L', 'Multiplication': 'Matrix(K*u)'}`
- `LQG_linear_sim/Kalman filter/Integrator` (Integrator): `{}`
- `LQG_linear_sim/Kalman filter/Sum` (Sum): `{'Inputs': '|+-'}`
- `LQG_linear_sim/Kalman filter/xhat` (Outport): `{}`
- `LQG_linear_sim/Modello linearizzato` (StateSpace): `{'A': 'Aplant', 'B': 'Bplant', 'C': 'Cplant', 'D': 'Dplant', 'InitialCondition': 'x0plant'}`
- `LQG_linear_sim/Mux` (Mux): `{'Inputs': '2', 'DisplayOption': 'bar'}`
- `LQG_linear_sim/Mux1` (Mux): `{'DisplayOption': 'bar'}`
- `LQG_linear_sim/Rumore di processo link` (RandomNumber): `{'Mean': '[0 0]', 'Variance': '[0.01 0.01]', 'Seed': '20260826', 'SampleTime': '0.002'}`
- `LQG_linear_sim/Rumore di processo u` (RandomNumber): `{'Mean': '[0 0]', 'Variance': '[0.01 0.01]', 'Seed': '20260826', 'SampleTime': '0.002'}`
- `LQG_linear_sim/Rumori di misura` (RandomNumber): `{'BlockMirror': 'on', 'Mean': '[0 0 0 0]', 'Variance': '[(0.05*pi/180)^2 (0.05*pi/180)^2 (0.05*pi/180)^2 (0.05*pi/180)^2]', 'Seed': '20260826', 'SampleTime': '0.002'}`
- `LQG_linear_sim/Sum` (Sum): `{'Inputs': '|+-'}`
- `LQG_linear_sim/Sum3` (Sum): `{'BlockMirror': 'on', 'Inputs': '|++'}`
- `LQG_linear_sim/r1` (Step): `{'FinalValue': '5*pi/180', 'SampleTime': '0'}`
- `LQG_linear_sim/r2` (Step): `{'FinalValue': '0', 'SampleTime': '0'}`

### Connessioni

- `LQG_linear_sim/Kalman filter/u#out:1` → `LQG_linear_sim/Kalman filter/Gain2#in:1`
- `LQG_linear_sim/Kalman filter/y#out:1` → `LQG_linear_sim/Kalman filter/Sum#in:1`
- `LQG_linear_sim/Kalman filter/Gain1#out:1` → `LQG_linear_sim/Kalman filter/Sum#in:2`
- `LQG_linear_sim/Kalman filter/Sum#out:1` → `LQG_linear_sim/Kalman filter/Gain3#in:1`
- `LQG_linear_sim/Kalman filter/Gain3#out:1` → `LQG_linear_sim/Kalman filter/Add#in:2`
- `LQG_linear_sim/Kalman filter/Gain2#out:1` → `LQG_linear_sim/Kalman filter/Add#in:1`
- `LQG_linear_sim/Kalman filter/Gain#out:1` → `LQG_linear_sim/Kalman filter/Add#in:3`
- `LQG_linear_sim/Kalman filter/Add#out:1` → `LQG_linear_sim/Kalman filter/Integrator#in:1`
- `LQG_linear_sim/Kalman filter/Integrator#out:1` → `LQG_linear_sim/Kalman filter/Gain#in:1`
- `LQG_linear_sim/Kalman filter/Integrator#out:1` → `LQG_linear_sim/Kalman filter/Gain1#in:1`
- `LQG_linear_sim/Kalman filter/Integrator#out:1` → `LQG_linear_sim/Kalman filter/xhat#in:1`
- `LQG_linear_sim/Demux#out:4` → `LQG_linear_sim/Uscita ideale#in:4`
- `LQG_linear_sim/Demux2#out:1` → `LQG_linear_sim/Variabile di controllo#in:1`
- `LQG_linear_sim/Demux1#out:1` → `LQG_linear_sim/Uscita misurata#in:1`
- `LQG_linear_sim/r2#out:1` → `LQG_linear_sim/Mux#in:2`
- `LQG_linear_sim/Demux1#out:4` → `LQG_linear_sim/Uscita misurata#in:4`
- `LQG_linear_sim/From3#out:1` → `LQG_linear_sim/Demux3#in:1`
- `LQG_linear_sim/Demux1#out:3` → `LQG_linear_sim/Uscita misurata#in:3`
- `LQG_linear_sim/From#out:1` → `LQG_linear_sim/Demux2#in:1`
- `LQG_linear_sim/From2#out:1` → `LQG_linear_sim/Demux1#in:1`
- `LQG_linear_sim/Demux3#out:1` → `LQG_linear_sim/Uscita ideale#in:5`
- `LQG_linear_sim/Demux#out:1` → `LQG_linear_sim/Uscita ideale#in:1`
- `LQG_linear_sim/Demux4#out:1` → `LQG_linear_sim/Uscita misurata#in:5`
- `LQG_linear_sim/Demux1#out:2` → `LQG_linear_sim/Uscita misurata#in:2`
- `LQG_linear_sim/Modello linearizzato#out:1` → `LQG_linear_sim/Sum3#in:1`
- `LQG_linear_sim/Modello linearizzato#out:1` → `LQG_linear_sim/Goto1#in:1`
- `LQG_linear_sim/Sum3#out:1` → `LQG_linear_sim/Goto2#in:1`
- `LQG_linear_sim/Sum3#out:1` → `LQG_linear_sim/Kalman filter#in:2`
- `LQG_linear_sim/r1#out:1` → `LQG_linear_sim/Mux#in:1`
- `LQG_linear_sim/Gain1#out:1` → `LQG_linear_sim/Sum#in:1`
- `LQG_linear_sim/From1#out:1` → `LQG_linear_sim/Demux#in:1`
- `LQG_linear_sim/Demux2#out:2` → `LQG_linear_sim/Variabile di controllo#in:2`
- `LQG_linear_sim/Demux#out:2` → `LQG_linear_sim/Uscita ideale#in:2`
- `LQG_linear_sim/Demux#out:3` → `LQG_linear_sim/Uscita ideale#in:3`
- `LQG_linear_sim/Demux3#out:2` → `LQG_linear_sim/Uscita ideale#in:6`
- `LQG_linear_sim/Sum#out:1` → `LQG_linear_sim/Mux1#in:1`
- `LQG_linear_sim/Sum#out:1` → `LQG_linear_sim/Goto#in:1`
- `LQG_linear_sim/Sum#out:1` → `LQG_linear_sim/Kalman filter#in:1`
- `LQG_linear_sim/Demux4#out:2` → `LQG_linear_sim/Uscita misurata#in:6`
- `LQG_linear_sim/Mux#out:1` → `LQG_linear_sim/Goto3#in:1`
- `LQG_linear_sim/Mux#out:1` → `LQG_linear_sim/Gain1#in:1`
- `LQG_linear_sim/From4#out:1` → `LQG_linear_sim/Demux4#in:1`
- `LQG_linear_sim/Kalman filter#out:1` → `LQG_linear_sim/Gain#in:1`
- `LQG_linear_sim/Gain#out:1` → `LQG_linear_sim/Sum#in:2`
- `LQG_linear_sim/Rumore di processo u#out:1` → `LQG_linear_sim/Mux1#in:4`
- `LQG_linear_sim/Disturbo di coppia#out:1` → `LQG_linear_sim/Mux1#in:2`
- `LQG_linear_sim/Rumore di processo link#out:1` → `LQG_linear_sim/Mux1#in:3`
- `LQG_linear_sim/Mux1#out:1` → `LQG_linear_sim/Modello linearizzato#in:1`
- `LQG_linear_sim/Rumori di misura#out:1` → `LQG_linear_sim/Sum3#in:2`

### Callback InitFcn

```matlab
actuator = actuator_params_nominal();
[Gact, info] = build_nominal_actuator(actuator);

% Parametri del robot
p = sea_params_nominal();
Simulink.Bus.createObject(p);

% Equilibrio desiderato
qbar = [pi/2; 0];

% Calcolo stato e coppia di equilibrio
[xbar, taubar, info] = sea_static_equilibrium(qbar, p);



%% INITFCN - Pianta LQGI lineare a 14 stati con 8 ingressi

% Individua la root del progetto partendo da progetto_lqgi.m
projectFile = which('progetto_lqgi.m');

assert(~isempty(projectFile), ...
    ['progetto_lqgi.m non trovato. Eseguire prima lo script ' ...
    'e verificare il MATLAB path.']);

projectRoot = fileparts(fileparts(projectFile));
dataDir = fullfile(projectRoot, 'results', 'data');

% File prodotti dagli script di validazione M3 e M5
m3File = fullfile(dataDir, 'm3_nominal_actuated_plant.mat');
m5File = fullfile(dataDir, 'm5_performance_specs.mat');

% Verifica che i dati della pianta esistano
assert(isfile(m3File), ...
    'Manca m3_nominal_actuated_plant.mat. Eseguire la validazione M3.');

% Se M5 non e' ancora stato generato, costruisce BdFull
if ~isfile(m5File)
    addpath(genpath(fullfile(projectRoot, 'src')));
    addpath(genpath(fullfile(projectRoot, 'analysis')));
    validate_m5_performance_specs;
end

assert(isfile(m5File), ...
    'Manca m5_performance_specs.mat dopo la validazione M5.');

% Carica le matrici necessarie
m3 = load(m3File, 'Afull', 'Bfull', 'CfullMeas');
m5 = load(m5File, 'BdFull');

Aplant = m3.Afull;
Bfull = m3.Bfull;
BdFull = m5.BdFull;
Cplant = m3.CfullMeas;

% Controlli sulle dimensioni delle matrici
assert(isequal(size(Aplant), [14 14]));
assert(isequal(size(Bfull), [14 2]));
assert(isequal(size(BdFull), [14 2]));
assert(isequal(size(Cplant), [4 14]));

% Ordine degli ingressi:
% 1-2: comando u
% 3-4: disturbo deterministico d lato link
% 5-6: rumore di processo w_link
% 7-8: rumore di processo w_u lato ingresso

Bplant = [Bfull, BdFull, BdFull, Bfull];

% Nessuna trasmissione diretta dagli ingressi alle misure
Dplant = zeros(4, 8);

% Condizione iniziale del modello linearizzato in deviazioni
x0plant = zeros(14, 1);

% Pubblica le variabili nel Base Workspace per i blocchi Simulink
assignin('base', 'Aplant', Aplant);
assignin('base', 'Bplant', Bplant);
assignin('base', 'Cplant', Cplant);
assignin('base', 'Dplant', Dplant);
assignin('base', 'x0plant', x0plant);

% Mantiene disponibili anche le matrici originali
assignin('base', 'Afull', Aplant);
assignin('base', 'Bfull', Bfull);
assignin('base', 'BdFull', BdFull);
assignin('base', 'CfullMeas', Cplant);

fprintf(['InitFcn LQGI: Aplant %dx%d, Bplant %dx%d, ' ...
    'Cplant %dx%d, Dplant %dx%d.\\n'], ...
    size(Aplant,1), size(Aplant,2), ...
    size(Bplant,1), size(Bplant,2), ...
    size(Cplant,1), size(Cplant,2), ...
    size(Dplant,1), size(Dplant,2));
```
## LQG_nonlinear_sim.slx

Release: {'version': '26.1.0.3312084', 'release': 'R2026a', 'description': 'Update 4', 'date': 'Jun 30 2026', 'checksum': '4132326121'}

SHA-256: `d628ed44dbba7bc6248340c0d1d94600e38b8f09984ff228b8201cf5bcbb0ff9`

Configurazione: `{'StopTime': '4', 'AbsTol': '9.9999999999999995e-08', 'MaxStep': '0.0050000000000000001', 'RelTol': '1.0000000000000001e-05', 'SolverName': 'ode23t'}`

### Blocchi e parametri

- `LQG_nonlinear_sim/Actuators1/u` (Inport): `{}`
- `LQG_nonlinear_sim/Actuators1/Demux` (Demux): `{'Outputs': '2'}`
- `LQG_nonlinear_sim/Actuators1/Mux` (Mux): `{'Inputs': '2', 'DisplayOption': 'bar'}`
- `LQG_nonlinear_sim/Actuators1/tau` (Outport): `{}`
- `LQG_nonlinear_sim/Constant2` (Constant): `{'Value': 'taubar'}`
- `LQG_nonlinear_sim/Constant3` (Constant): `{'Value': 'xbar'}`
- `LQG_nonlinear_sim/Demux` (Demux): `{}`
- `LQG_nonlinear_sim/Demux1` (Demux): `{}`
- `LQG_nonlinear_sim/Demux2` (Demux): `{'Outputs': '2'}`
- `LQG_nonlinear_sim/Demux3` (Demux): `{'Outputs': '2'}`
- `LQG_nonlinear_sim/Demux4` (Demux): `{'Outputs': '2'}`
- `LQG_nonlinear_sim/Disturbi di coppia` (Step): `{'Time': '[1 1]', 'InitialValue': '[0 0]', 'FinalValue': '[0.5 0]', 'SampleTime': '0'}`
- `LQG_nonlinear_sim/Gain2` (Gain): `{'Gain': 'K', 'Multiplication': 'Matrix(K*u)'}`
- `LQG_nonlinear_sim/Gain3` (Gain): `{'Gain': 'Nr', 'Multiplication': 'Matrix(K*u)'}`
- `LQG_nonlinear_sim/Integrator1` (Integrator): `{'InitialCondition': 'xbar'}`
- `LQG_nonlinear_sim/Kalman filter1/u` (Inport): `{}`
- `LQG_nonlinear_sim/Kalman filter1/y` (Inport): `{'Port': '2'}`
- `LQG_nonlinear_sim/Kalman filter1/Add` (Sum): `{'IconShape': 'rectangular', 'Inputs': '+++'}`
- `LQG_nonlinear_sim/Kalman filter1/Gain` (Gain): `{'Gain': 'A', 'Multiplication': 'Matrix(K*u)'}`
- `LQG_nonlinear_sim/Kalman filter1/Gain1` (Gain): `{'BlockMirror': 'on', 'Gain': 'C', 'Multiplication': 'Matrix(K*u)'}`
- `LQG_nonlinear_sim/Kalman filter1/Gain2` (Gain): `{'Gain': 'B', 'Multiplication': 'Matrix(K*u)'}`
- `LQG_nonlinear_sim/Kalman filter1/Gain3` (Gain): `{'Gain': 'L', 'Multiplication': 'Matrix(K*u)'}`
- `LQG_nonlinear_sim/Kalman filter1/Integrator` (Integrator): `{}`
- `LQG_nonlinear_sim/Kalman filter1/Sum` (Sum): `{'Inputs': '|+-'}`
- `LQG_nonlinear_sim/Kalman filter1/xhat` (Outport): `{}`
- `LQG_nonlinear_sim/Mux1` (Mux): `{'Inputs': '2', 'DisplayOption': 'bar'}`
- `LQG_nonlinear_sim/Non linear plant1/x` (Inport): `{}`
- `LQG_nonlinear_sim/Non linear plant1/tau` (Inport): `{'Port': '2'}`
- `LQG_nonlinear_sim/Non linear plant1/d` (Inport): `{'Port': '3'}`
- `LQG_nonlinear_sim/Non linear plant1/MATLAB Function/x` (Inport): `{}`
- `LQG_nonlinear_sim/Non linear plant1/MATLAB Function/tau` (Inport): `{'Port': '2'}`
- `LQG_nonlinear_sim/Non linear plant1/MATLAB Function/d` (Inport): `{'Port': '3'}`
- `LQG_nonlinear_sim/Non linear plant1/MATLAB Function/p` (Inport): `{'Port': '4'}`
- `LQG_nonlinear_sim/Non linear plant1/MATLAB Function/ Demux ` (Demux): `{'Outputs': '1'}`
- `LQG_nonlinear_sim/Non linear plant1/MATLAB Function/xdot` (Outport): `{}`
- `LQG_nonlinear_sim/Non linear plant1/MATLAB Function1/ Demux ` (Demux): `{'Outputs': '1'}`
- `LQG_nonlinear_sim/Non linear plant1/MATLAB Function1/p` (Outport): `{}`
- `LQG_nonlinear_sim/Non linear plant1/xdot` (Outport): `{}`
- `LQG_nonlinear_sim/Rumore di processo link` (RandomNumber): `{'Mean': '[0 0]', 'Variance': '[0.01 0.01]', 'Seed': '20260826', 'SampleTime': '0.002'}`
- `LQG_nonlinear_sim/Rumore di processo u` (RandomNumber): `{'Mean': '[0 0]', 'Variance': '[0.01 0.01]', 'Seed': '20260826', 'SampleTime': '0.002'}`
- `LQG_nonlinear_sim/Rumori di misura1` (RandomNumber): `{'Mean': '[0 0 0 0]', 'Variance': '[(0.05*pi/180)^2 (0.05*pi/180)^2 (0.05*pi/180)^2 (0.05*pi/180)^2]', 'Seed': '20260826', 'SampleTime': '0.002'}`
- `LQG_nonlinear_sim/Sum10` (Sum): `{'Inputs': '|++'}`
- `LQG_nonlinear_sim/Sum4` (Sum): `{'Inputs': '|+-'}`
- `LQG_nonlinear_sim/Sum5` (Sum): `{'Inputs': '++|'}`
- `LQG_nonlinear_sim/Sum6` (Sum): `{'Inputs': '|+-'}`
- `LQG_nonlinear_sim/Sum7` (Sum): `{'NameLocation': 'top', 'Inputs': '|++'}`
- `LQG_nonlinear_sim/Sum9` (Sum): `{'Inputs': '|++'}`
- `LQG_nonlinear_sim/r1 (q1)` (Step): `{'FinalValue': '5*pi/180', 'SampleTime': '0'}`
- `LQG_nonlinear_sim/r2 (q2)` (Step): `{'FinalValue': '0', 'SampleTime': '0'}`

### Connessioni

- `LQG_nonlinear_sim/Actuators1/Actuator 2#out:1` → `LQG_nonlinear_sim/Actuators1/Mux#in:2`
- `LQG_nonlinear_sim/Actuators1/Demux#out:2` → `LQG_nonlinear_sim/Actuators1/Actuator 2#in:1`
- `LQG_nonlinear_sim/Actuators1/u#out:1` → `LQG_nonlinear_sim/Actuators1/Demux#in:1`
- `LQG_nonlinear_sim/Actuators1/Demux#out:1` → `LQG_nonlinear_sim/Actuators1/Actuator 1#in:1`
- `LQG_nonlinear_sim/Actuators1/Mux#out:1` → `LQG_nonlinear_sim/Actuators1/tau#in:1`
- `LQG_nonlinear_sim/Actuators1/Actuator 1#out:1` → `LQG_nonlinear_sim/Actuators1/Mux#in:1`
- `LQG_nonlinear_sim/Kalman filter1/u#out:1` → `LQG_nonlinear_sim/Kalman filter1/Gain2#in:1`
- `LQG_nonlinear_sim/Kalman filter1/y#out:1` → `LQG_nonlinear_sim/Kalman filter1/Sum#in:1`
- `LQG_nonlinear_sim/Kalman filter1/Gain1#out:1` → `LQG_nonlinear_sim/Kalman filter1/Sum#in:2`
- `LQG_nonlinear_sim/Kalman filter1/Sum#out:1` → `LQG_nonlinear_sim/Kalman filter1/Gain3#in:1`
- `LQG_nonlinear_sim/Kalman filter1/Gain3#out:1` → `LQG_nonlinear_sim/Kalman filter1/Add#in:2`
- `LQG_nonlinear_sim/Kalman filter1/Gain2#out:1` → `LQG_nonlinear_sim/Kalman filter1/Add#in:1`
- `LQG_nonlinear_sim/Kalman filter1/Gain#out:1` → `LQG_nonlinear_sim/Kalman filter1/Add#in:3`
- `LQG_nonlinear_sim/Kalman filter1/Add#out:1` → `LQG_nonlinear_sim/Kalman filter1/Integrator#in:1`
- `LQG_nonlinear_sim/Kalman filter1/Integrator#out:1` → `LQG_nonlinear_sim/Kalman filter1/Gain#in:1`
- `LQG_nonlinear_sim/Kalman filter1/Integrator#out:1` → `LQG_nonlinear_sim/Kalman filter1/Gain1#in:1`
- `LQG_nonlinear_sim/Kalman filter1/Integrator#out:1` → `LQG_nonlinear_sim/Kalman filter1/xhat#in:1`
- `LQG_nonlinear_sim/Non linear plant1/MATLAB Function/x#out:1` → `LQG_nonlinear_sim/Non linear plant1/MATLAB Function/ SFunction #in:1`
- `LQG_nonlinear_sim/Non linear plant1/MATLAB Function/tau#out:1` → `LQG_nonlinear_sim/Non linear plant1/MATLAB Function/ SFunction #in:2`
- `LQG_nonlinear_sim/Non linear plant1/MATLAB Function/d#out:1` → `LQG_nonlinear_sim/Non linear plant1/MATLAB Function/ SFunction #in:3`
- `LQG_nonlinear_sim/Non linear plant1/MATLAB Function/p#out:1` → `LQG_nonlinear_sim/Non linear plant1/MATLAB Function/ SFunction #in:4`
- `LQG_nonlinear_sim/Non linear plant1/MATLAB Function/ SFunction #out:2` → `LQG_nonlinear_sim/Non linear plant1/MATLAB Function/xdot#in:1`
- `LQG_nonlinear_sim/Non linear plant1/MATLAB Function/ Demux #out:1` → `LQG_nonlinear_sim/Non linear plant1/MATLAB Function/ Terminator #in:1`
- `LQG_nonlinear_sim/Non linear plant1/MATLAB Function/ SFunction #out:1` → `LQG_nonlinear_sim/Non linear plant1/MATLAB Function/ Demux #in:1`
- `LQG_nonlinear_sim/Non linear plant1/MATLAB Function1/ SFunction #out:2` → `LQG_nonlinear_sim/Non linear plant1/MATLAB Function1/p#in:1`
- `LQG_nonlinear_sim/Non linear plant1/MATLAB Function1/ Ground #out:1` → `LQG_nonlinear_sim/Non linear plant1/MATLAB Function1/ SFunction #in:1`
- `LQG_nonlinear_sim/Non linear plant1/MATLAB Function1/ Demux #out:1` → `LQG_nonlinear_sim/Non linear plant1/MATLAB Function1/ Terminator #in:1`
- `LQG_nonlinear_sim/Non linear plant1/MATLAB Function1/ SFunction #out:1` → `LQG_nonlinear_sim/Non linear plant1/MATLAB Function1/ Demux #in:1`
- `LQG_nonlinear_sim/Non linear plant1/x#out:1` → `LQG_nonlinear_sim/Non linear plant1/MATLAB Function#in:1`
- `LQG_nonlinear_sim/Non linear plant1/tau#out:1` → `LQG_nonlinear_sim/Non linear plant1/MATLAB Function#in:2`
- `LQG_nonlinear_sim/Non linear plant1/MATLAB Function#out:1` → `LQG_nonlinear_sim/Non linear plant1/xdot#in:1`
- `LQG_nonlinear_sim/Non linear plant1/MATLAB Function1#out:1` → `LQG_nonlinear_sim/Non linear plant1/MATLAB Function#in:4`
- `LQG_nonlinear_sim/Non linear plant1/d#out:1` → `LQG_nonlinear_sim/Non linear plant1/MATLAB Function#in:3`
- `LQG_nonlinear_sim/Demux#out:1` → `LQG_nonlinear_sim/Uscita ideale#in:1`
- `LQG_nonlinear_sim/Demux#out:2` → `LQG_nonlinear_sim/Uscita ideale#in:2`
- `LQG_nonlinear_sim/Demux#out:3` → `LQG_nonlinear_sim/Uscita ideale#in:3`
- `LQG_nonlinear_sim/Demux#out:4` → `LQG_nonlinear_sim/Uscita ideale#in:4`
- `LQG_nonlinear_sim/Demux1#out:2` → `LQG_nonlinear_sim/Uscita misurata#in:2`
- `LQG_nonlinear_sim/Demux1#out:4` → `LQG_nonlinear_sim/Uscita misurata#in:4`
- `LQG_nonlinear_sim/Demux1#out:1` → `LQG_nonlinear_sim/Uscita misurata#in:1`
- `LQG_nonlinear_sim/Demux1#out:3` → `LQG_nonlinear_sim/Uscita misurata#in:3`
- `LQG_nonlinear_sim/Demux2#out:1` → `LQG_nonlinear_sim/Variabile di controllo#in:1`
- `LQG_nonlinear_sim/Demux2#out:2` → `LQG_nonlinear_sim/Variabile di controllo#in:2`
- `LQG_nonlinear_sim/From#out:1` → `LQG_nonlinear_sim/Demux2#in:1`
- `LQG_nonlinear_sim/From1#out:1` → `LQG_nonlinear_sim/Demux#in:1`
- `LQG_nonlinear_sim/From2#out:1` → `LQG_nonlinear_sim/Demux1#in:1`
- `LQG_nonlinear_sim/From3#out:1` → `LQG_nonlinear_sim/Demux3#in:1`
- `LQG_nonlinear_sim/From4#out:1` → `LQG_nonlinear_sim/Demux4#in:1`
- `LQG_nonlinear_sim/Demux3#out:1` → `LQG_nonlinear_sim/Uscita ideale#in:5`
- `LQG_nonlinear_sim/Demux3#out:2` → `LQG_nonlinear_sim/Uscita ideale#in:6`
- `LQG_nonlinear_sim/Demux4#out:1` → `LQG_nonlinear_sim/Uscita misurata#in:5`
- `LQG_nonlinear_sim/Demux4#out:2` → `LQG_nonlinear_sim/Uscita misurata#in:6`
- `LQG_nonlinear_sim/Rumore di processo link#out:1` → `LQG_nonlinear_sim/Sum9#in:2`
- `LQG_nonlinear_sim/Constant3#out:1` → `LQG_nonlinear_sim/Sum6#in:2`
- `LQG_nonlinear_sim/Integrator1#out:1` → `LQG_nonlinear_sim/Non linear plant1#in:1`
- `LQG_nonlinear_sim/Integrator1#out:1` → `LQG_nonlinear_sim/Sum6#in:1`
- `LQG_nonlinear_sim/r1 (q1)#out:1` → `LQG_nonlinear_sim/Mux1#in:1`
- `LQG_nonlinear_sim/Sum7#out:1` → `LQG_nonlinear_sim/Goto6#in:1`
- `LQG_nonlinear_sim/Sum7#out:1` → `LQG_nonlinear_sim/Kalman filter1#in:2`
- `LQG_nonlinear_sim/Sum10#out:1` → `LQG_nonlinear_sim/Actuators1#in:1`
- `LQG_nonlinear_sim/Actuators1#out:1` → `LQG_nonlinear_sim/Sum5#in:2`
- `LQG_nonlinear_sim/Selettore1#out:1` → `LQG_nonlinear_sim/Sum7#in:1`
- `LQG_nonlinear_sim/Selettore1#out:1` → `LQG_nonlinear_sim/Goto5#in:1`
- `LQG_nonlinear_sim/Gain2#out:1` → `LQG_nonlinear_sim/Sum4#in:2`
- `LQG_nonlinear_sim/Kalman filter1#out:1` → `LQG_nonlinear_sim/Gain2#in:1`
- `LQG_nonlinear_sim/Sum5#out:1` → `LQG_nonlinear_sim/Non linear plant1#in:2`
- `LQG_nonlinear_sim/Sum9#out:1` → `LQG_nonlinear_sim/Non linear plant1#in:3`
- `LQG_nonlinear_sim/r2 (q2)#out:1` → `LQG_nonlinear_sim/Mux1#in:2`
- `LQG_nonlinear_sim/Non linear plant1#out:1` → `LQG_nonlinear_sim/Integrator1#in:1`
- `LQG_nonlinear_sim/Sum6#out:1` → `LQG_nonlinear_sim/Selettore1#in:1`
- `LQG_nonlinear_sim/Mux1#out:1` → `LQG_nonlinear_sim/Gain3#in:1`
- `LQG_nonlinear_sim/Mux1#out:1` → `LQG_nonlinear_sim/Goto7#in:1`
- `LQG_nonlinear_sim/Disturbi di coppia#out:1` → `LQG_nonlinear_sim/Sum9#in:1`
- `LQG_nonlinear_sim/Constant2#out:1` → `LQG_nonlinear_sim/Sum5#in:1`
- `LQG_nonlinear_sim/Gain3#out:1` → `LQG_nonlinear_sim/Sum4#in:1`
- `LQG_nonlinear_sim/Sum4#out:1` → `LQG_nonlinear_sim/Kalman filter1#in:1`
- `LQG_nonlinear_sim/Sum4#out:1` → `LQG_nonlinear_sim/Goto4#in:1`
- `LQG_nonlinear_sim/Sum4#out:1` → `LQG_nonlinear_sim/Sum10#in:1`
- `LQG_nonlinear_sim/Rumore di processo u#out:1` → `LQG_nonlinear_sim/Sum10#in:2`
- `LQG_nonlinear_sim/Rumori di misura1#out:1` → `LQG_nonlinear_sim/Sum7#in:2`

### Callback InitFcn

```matlab
actuator = actuator_params_nominal();
[Gact, info] = build_nominal_actuator(actuator);

% Parametri del robot
p = sea_params_nominal();
Simulink.Bus.createObject(p);

% Equilibrio desiderato
qbar = [pi/2; 0];

% Calcolo stato e coppia di equilibrio
[xbar, taubar, info] = sea_static_equilibrium(qbar, p);
```

### Funzione incorporata: simulink/stateflow/chart_10.xml

```matlab
function xdot = sea_nonlinear_rhs_with_link_disturbance(x, tau, d, p)
%SEA_NONLINEAR_RHS_WITH_LINK_DISTURBANCE SEA dynamics with link torque D.
%   TAU remains the motor-side input; D is an external link-side joint
%   torque entering with positive sign in the link equation.

assert(numel(x) == 8, ...
    'sea_nonlinear_rhs_with_link_disturbance:InvalidState', ...
    'The state must contain exactly eight elements.');
assert(numel(tau) == 2 && numel(d) == 2, ...
    'sea_nonlinear_rhs_with_link_disturbance:InvalidInput', ...
    'Both tau and d must contain exactly two elements.');
x = reshape(x, 8, 1);
tau = reshape(tau, 2, 1);
d = reshape(d, 2, 1);

q = x(1:2);
qdot = x(3:4);
theta = x(5:6);
thetadot = x(7:8);
M = sea_link_inertia(q, p);
C = sea_coriolis(q, qdot, p);
G = sea_gravity(q, p);
tauElastic = sea_elastic_torque(q, theta, p);

qddot = M \ (tauElastic + d - C * qdot - G);
thetaddot = p.Jm \ (tau - p.Bm * thetadot - tauElastic);
xdot = [qdot; qddot; thetadot; thetaddot];
end

```

### Funzione incorporata: simulink/stateflow/chart_20.xml

```matlab
function p = sea_params_nominal
%SEA_PARAMS_NOMINAL Nominal mechanical parameters of the 2R SEA robot.
%   P = SEA_PARAMS_NOMINAL returns the values stated by the official
%   assignment. Matrices follow the joint order [joint 1; joint 2].

p.m1 = 1.0;                   % kg
p.m2 = 0.8;                   % kg
p.l1 = 0.4;                   % m
p.l2 = 0.3;                   % m
p.Jm = diag([0.01, 0.01]);    % kg*m^2
p.Bm = diag([0.02, 0.02]);    % N*m*s/rad
p.Ks = diag([50, 40]);        % N*m/rad
p.g = 9.81;                   % m/s^2
end

```
## LQGI_linear_sim.slx

Release: {'version': '26.1.0.3312084', 'release': 'R2026a', 'description': 'Update 4', 'date': 'Jun 30 2026', 'checksum': '4132326121'}

SHA-256: `6c8248318c57d30853d345992dbf0d0e18256ca019c99a89107bd5729fa374dc`

Configurazione: `{'SolverName': 'VariableStepAuto'}`

### Blocchi e parametri

- `LQGI_linear_sim/Demux` (Demux): `{}`
- `LQGI_linear_sim/Demux1` (Demux): `{}`
- `LQGI_linear_sim/Demux2` (Demux): `{'Outputs': '2'}`
- `LQGI_linear_sim/Demux3` (Demux): `{'Outputs': '2'}`
- `LQGI_linear_sim/Demux4` (Demux): `{'Outputs': '2'}`
- `LQGI_linear_sim/Disturbo di coppia` (Step): `{'Time': '[1 1]', 'InitialValue': '[0 0]', 'FinalValue': '[0.5 0]', 'SampleTime': '0'}`
- `LQGI_linear_sim/Gain` (Gain): `{'Gain': 'Kx', 'Multiplication': 'Matrix(K*u)'}`
- `LQGI_linear_sim/Gain1` (Gain): `{'Gain': 'Ki', 'Multiplication': 'Matrix(K*u)'}`
- `LQGI_linear_sim/Integrator1` (Integrator): `{}`
- `LQGI_linear_sim/Kalman filter/u` (Inport): `{}`
- `LQGI_linear_sim/Kalman filter/y_mis` (Inport): `{'Port': '2'}`
- `LQGI_linear_sim/Kalman filter/Add` (Sum): `{'IconShape': 'rectangular', 'Inputs': '+++'}`
- `LQGI_linear_sim/Kalman filter/Gain` (Gain): `{'Gain': 'A', 'Multiplication': 'Matrix(K*u)'}`
- `LQGI_linear_sim/Kalman filter/Gain1` (Gain): `{'BlockMirror': 'on', 'Gain': 'C', 'Multiplication': 'Matrix(K*u)'}`
- `LQGI_linear_sim/Kalman filter/Gain2` (Gain): `{'Gain': 'B', 'Multiplication': 'Matrix(K*u)'}`
- `LQGI_linear_sim/Kalman filter/Gain3` (Gain): `{'Gain': 'L', 'Multiplication': 'Matrix(K*u)'}`
- `LQGI_linear_sim/Kalman filter/Integrator` (Integrator): `{}`
- `LQGI_linear_sim/Kalman filter/Sum` (Sum): `{'Inputs': '|+-'}`
- `LQGI_linear_sim/Kalman filter/xhat` (Outport): `{}`
- `LQGI_linear_sim/Modello linearizzato` (StateSpace): `{'A': 'Aplant', 'B': 'Bplant', 'C': 'Cplant', 'D': 'Dplant', 'InitialCondition': 'x0plant'}`
- `LQGI_linear_sim/Mux` (Mux): `{'Inputs': '2', 'DisplayOption': 'bar'}`
- `LQGI_linear_sim/Mux1` (Mux): `{'DisplayOption': 'bar'}`
- `LQGI_linear_sim/Rumore di processo link` (RandomNumber): `{'Mean': '[0 0]', 'Variance': '[0.01 0.01]', 'Seed': '20260826', 'SampleTime': '0.002'}`
- `LQGI_linear_sim/Rumore di processo u` (RandomNumber): `{'Mean': '[0 0]', 'Variance': '[0.01 0.01]', 'Seed': '20260826', 'SampleTime': '0.002'}`
- `LQGI_linear_sim/Rumori di misura` (RandomNumber): `{'Mean': '[0 0 0 0]', 'Variance': '[(0.05*pi/180)^2 (0.05*pi/180)^2 (0.05*pi/180)^2 (0.05*pi/180)^2]', 'Seed': '20260826', 'SampleTime': '0.002'}`
- `LQGI_linear_sim/Sum` (Sum): `{'Inputs': '|--'}`
- `LQGI_linear_sim/Sum3` (Sum): `{'NameLocation': 'top', 'Inputs': '|++'}`
- `LQGI_linear_sim/Sum5` (Sum): `{'Inputs': '-+|'}`
- `LQGI_linear_sim/r1 (q1)` (Step): `{'FinalValue': '5*pi/180', 'SampleTime': '0'}`
- `LQGI_linear_sim/r2 (q2)` (Step): `{'FinalValue': '0', 'SampleTime': '0'}`

### Connessioni

- `LQGI_linear_sim/Kalman filter/u#out:1` → `LQGI_linear_sim/Kalman filter/Gain2#in:1`
- `LQGI_linear_sim/Kalman filter/y_mis#out:1` → `LQGI_linear_sim/Kalman filter/Sum#in:1`
- `LQGI_linear_sim/Kalman filter/Gain1#out:1` → `LQGI_linear_sim/Kalman filter/Sum#in:2`
- `LQGI_linear_sim/Kalman filter/Sum#out:1` → `LQGI_linear_sim/Kalman filter/Gain3#in:1`
- `LQGI_linear_sim/Kalman filter/Gain3#out:1` → `LQGI_linear_sim/Kalman filter/Add#in:2`
- `LQGI_linear_sim/Kalman filter/Gain2#out:1` → `LQGI_linear_sim/Kalman filter/Add#in:1`
- `LQGI_linear_sim/Kalman filter/Gain#out:1` → `LQGI_linear_sim/Kalman filter/Add#in:3`
- `LQGI_linear_sim/Kalman filter/Add#out:1` → `LQGI_linear_sim/Kalman filter/Integrator#in:1`
- `LQGI_linear_sim/Kalman filter/Integrator#out:1` → `LQGI_linear_sim/Kalman filter/Gain#in:1`
- `LQGI_linear_sim/Kalman filter/Integrator#out:1` → `LQGI_linear_sim/Kalman filter/Gain1#in:1`
- `LQGI_linear_sim/Kalman filter/Integrator#out:1` → `LQGI_linear_sim/Kalman filter/xhat#in:1`
- `LQGI_linear_sim/Gain1#out:1` → `LQGI_linear_sim/Sum#in:1`
- `LQGI_linear_sim/Demux#out:1` → `LQGI_linear_sim/Uscita ideale#in:1`
- `LQGI_linear_sim/From4#out:1` → `LQGI_linear_sim/Demux4#in:1`
- `LQGI_linear_sim/Demux#out:2` → `LQGI_linear_sim/Uscita ideale#in:2`
- `LQGI_linear_sim/Mux#out:1` → `LQGI_linear_sim/Goto3#in:1`
- `LQGI_linear_sim/Mux#out:1` → `LQGI_linear_sim/Sum5#in:2`
- `LQGI_linear_sim/From#out:1` → `LQGI_linear_sim/Demux2#in:1`
- `LQGI_linear_sim/From1#out:1` → `LQGI_linear_sim/Demux#in:1`
- `LQGI_linear_sim/Demux1#out:3` → `LQGI_linear_sim/Uscita misurata#in:3`
- `LQGI_linear_sim/Sum3#out:1` → `LQGI_linear_sim/Selettore1#in:1`
- `LQGI_linear_sim/Sum3#out:1` → `LQGI_linear_sim/Kalman filter#in:2`
- `LQGI_linear_sim/Sum3#out:1` → `LQGI_linear_sim/Goto2#in:1`
- `LQGI_linear_sim/Demux4#out:2` → `LQGI_linear_sim/Uscita misurata#in:6`
- `LQGI_linear_sim/Demux4#out:1` → `LQGI_linear_sim/Uscita misurata#in:5`
- `LQGI_linear_sim/Sum#out:1` → `LQGI_linear_sim/Kalman filter#in:1`
- `LQGI_linear_sim/Sum#out:1` → `LQGI_linear_sim/Goto#in:1`
- `LQGI_linear_sim/Sum#out:1` → `LQGI_linear_sim/Mux1#in:1`
- `LQGI_linear_sim/Demux2#out:1` → `LQGI_linear_sim/Variabile di controllo#in:1`
- `LQGI_linear_sim/From2#out:1` → `LQGI_linear_sim/Demux1#in:1`
- `LQGI_linear_sim/Demux#out:3` → `LQGI_linear_sim/Uscita ideale#in:3`
- `LQGI_linear_sim/Integrator1#out:1` → `LQGI_linear_sim/Gain1#in:1`
- `LQGI_linear_sim/r2 (q2)#out:1` → `LQGI_linear_sim/Mux#in:2`
- `LQGI_linear_sim/Gain#out:1` → `LQGI_linear_sim/Sum#in:2`
- `LQGI_linear_sim/Demux#out:4` → `LQGI_linear_sim/Uscita ideale#in:4`
- `LQGI_linear_sim/Selettore1#out:1` → `LQGI_linear_sim/Sum5#in:1`
- `LQGI_linear_sim/Demux1#out:2` → `LQGI_linear_sim/Uscita misurata#in:2`
- `LQGI_linear_sim/Demux2#out:2` → `LQGI_linear_sim/Variabile di controllo#in:2`
- `LQGI_linear_sim/Demux3#out:1` → `LQGI_linear_sim/Uscita ideale#in:5`
- `LQGI_linear_sim/Demux1#out:1` → `LQGI_linear_sim/Uscita misurata#in:1`
- `LQGI_linear_sim/Sum5#out:1` → `LQGI_linear_sim/Integrator1#in:1`
- `LQGI_linear_sim/r1 (q1)#out:1` → `LQGI_linear_sim/Mux#in:1`
- `LQGI_linear_sim/Demux3#out:2` → `LQGI_linear_sim/Uscita ideale#in:6`
- `LQGI_linear_sim/From3#out:1` → `LQGI_linear_sim/Demux3#in:1`
- `LQGI_linear_sim/Demux1#out:4` → `LQGI_linear_sim/Uscita misurata#in:4`
- `LQGI_linear_sim/Kalman filter#out:1` → `LQGI_linear_sim/Gain#in:1`
- `LQGI_linear_sim/Modello linearizzato#out:1` → `LQGI_linear_sim/Goto1#in:1`
- `LQGI_linear_sim/Modello linearizzato#out:1` → `LQGI_linear_sim/Sum3#in:1`
- `LQGI_linear_sim/Mux1#out:1` → `LQGI_linear_sim/Modello linearizzato#in:1`
- `LQGI_linear_sim/Rumori di misura#out:1` → `LQGI_linear_sim/Sum3#in:2`
- `LQGI_linear_sim/Disturbo di coppia#out:1` → `LQGI_linear_sim/Mux1#in:2`
- `LQGI_linear_sim/Rumore di processo link#out:1` → `LQGI_linear_sim/Mux1#in:3`
- `LQGI_linear_sim/Rumore di processo u#out:1` → `LQGI_linear_sim/Mux1#in:4`

### Callback InitFcn

```matlab
actuator = actuator_params_nominal();
[Gact, info] = build_nominal_actuator(actuator);

% Parametri del robot
p = sea_params_nominal();
Simulink.Bus.createObject(p);

% Equilibrio desiderato
qbar = [pi/2; 0];

% Calcolo stato e coppia di equilibrio
[xbar, taubar, info] = sea_static_equilibrium(qbar, p);



%% INITFCN - Pianta LQGI lineare a 14 stati con 8 ingressi

% Individua la root del progetto partendo da progetto_lqgi.m
projectFile = which('progetto_lqgi.m');

assert(~isempty(projectFile), ...
    ['progetto_lqgi.m non trovato. Eseguire prima lo script ' ...
    'e verificare il MATLAB path.']);

projectRoot = fileparts(fileparts(projectFile));
dataDir = fullfile(projectRoot, 'results', 'data');

% File prodotti dagli script di validazione M3 e M5
m3File = fullfile(dataDir, 'm3_nominal_actuated_plant.mat');
m5File = fullfile(dataDir, 'm5_performance_specs.mat');

% Verifica che i dati della pianta esistano
assert(isfile(m3File), ...
    'Manca m3_nominal_actuated_plant.mat. Eseguire la validazione M3.');

% Se M5 non e' ancora stato generato, costruisce BdFull
if ~isfile(m5File)
    addpath(genpath(fullfile(projectRoot, 'src')));
    addpath(genpath(fullfile(projectRoot, 'analysis')));
    validate_m5_performance_specs;
end

assert(isfile(m5File), ...
    'Manca m5_performance_specs.mat dopo la validazione M5.');

% Carica le matrici necessarie
m3 = load(m3File, 'Afull', 'Bfull', 'CfullMeas');
m5 = load(m5File, 'BdFull');

Aplant = m3.Afull;
Bfull = m3.Bfull;
BdFull = m5.BdFull;
Cplant = m3.CfullMeas;

% Controlli sulle dimensioni delle matrici
assert(isequal(size(Aplant), [14 14]));
assert(isequal(size(Bfull), [14 2]));
assert(isequal(size(BdFull), [14 2]));
assert(isequal(size(Cplant), [4 14]));

% Ordine degli ingressi:
% 1-2: comando u
% 3-4: disturbo deterministico d lato link
% 5-6: rumore di processo w_link
% 7-8: rumore di processo w_u lato ingresso

Bplant = [Bfull, BdFull, BdFull, Bfull];

% Nessuna trasmissione diretta dagli ingressi alle misure
Dplant = zeros(4, 8);

% Condizione iniziale del modello linearizzato in deviazioni
x0plant = zeros(14, 1);

% Pubblica le variabili nel Base Workspace per i blocchi Simulink
assignin('base', 'Aplant', Aplant);
assignin('base', 'Bplant', Bplant);
assignin('base', 'Cplant', Cplant);
assignin('base', 'Dplant', Dplant);
assignin('base', 'x0plant', x0plant);

% Mantiene disponibili anche le matrici originali
assignin('base', 'Afull', Aplant);
assignin('base', 'Bfull', Bfull);
assignin('base', 'BdFull', BdFull);
assignin('base', 'CfullMeas', Cplant);

fprintf(['InitFcn LQGI: Aplant %dx%d, Bplant %dx%d, ' ...
    'Cplant %dx%d, Dplant %dx%d.\\n'], ...
    size(Aplant,1), size(Aplant,2), ...
    size(Bplant,1), size(Bplant,2), ...
    size(Cplant,1), size(Cplant,2), ...
    size(Dplant,1), size(Dplant,2));
```
## LQGI_nonlinear_sim.slx

Release: {'version': '26.1.0.3312084', 'release': 'R2026a', 'description': 'Update 4', 'date': 'Jun 30 2026', 'checksum': '4132326121'}

SHA-256: `c1ceef864070be2afc5ae0dba9b3481f80c9378c05555e47f3d17f2a3152bcfe`

Configurazione: `{'SolverName': 'VariableStepAuto'}`

### Blocchi e parametri

- `LQGI_nonlinear_sim/Actuators/u` (Inport): `{}`
- `LQGI_nonlinear_sim/Actuators/Demux` (Demux): `{'Outputs': '2'}`
- `LQGI_nonlinear_sim/Actuators/Mux` (Mux): `{'Inputs': '2', 'DisplayOption': 'bar'}`
- `LQGI_nonlinear_sim/Actuators/tau` (Outport): `{}`
- `LQGI_nonlinear_sim/Constant` (Constant): `{'Value': 'taubar'}`
- `LQGI_nonlinear_sim/Constant1` (Constant): `{'Value': 'xbar'}`
- `LQGI_nonlinear_sim/Demux` (Demux): `{}`
- `LQGI_nonlinear_sim/Demux1` (Demux): `{}`
- `LQGI_nonlinear_sim/Demux2` (Demux): `{'Outputs': '2'}`
- `LQGI_nonlinear_sim/Demux3` (Demux): `{'Outputs': '2'}`
- `LQGI_nonlinear_sim/Demux4` (Demux): `{'Outputs': '2'}`
- `LQGI_nonlinear_sim/Disturbi di coppia` (Step): `{'Time': '[1 1]', 'InitialValue': '[0 0]', 'FinalValue': '[0.5 0]', 'SampleTime': '0'}`
- `LQGI_nonlinear_sim/Gain` (Gain): `{'Gain': 'Kx', 'Multiplication': 'Matrix(K*u)'}`
- `LQGI_nonlinear_sim/Gain1` (Gain): `{'Gain': 'Ki', 'Multiplication': 'Matrix(K*u)'}`
- `LQGI_nonlinear_sim/Integrator` (Integrator): `{'InitialCondition': 'xbar'}`
- `LQGI_nonlinear_sim/Integrator1` (Integrator): `{}`
- `LQGI_nonlinear_sim/Kalman filter/u` (Inport): `{}`
- `LQGI_nonlinear_sim/Kalman filter/y` (Inport): `{'Port': '2'}`
- `LQGI_nonlinear_sim/Kalman filter/Add` (Sum): `{'IconShape': 'rectangular', 'Inputs': '+++'}`
- `LQGI_nonlinear_sim/Kalman filter/Gain` (Gain): `{'Gain': 'A', 'Multiplication': 'Matrix(K*u)'}`
- `LQGI_nonlinear_sim/Kalman filter/Gain1` (Gain): `{'BlockMirror': 'on', 'Gain': 'C', 'Multiplication': 'Matrix(K*u)'}`
- `LQGI_nonlinear_sim/Kalman filter/Gain2` (Gain): `{'Gain': 'B', 'Multiplication': 'Matrix(K*u)'}`
- `LQGI_nonlinear_sim/Kalman filter/Gain3` (Gain): `{'Gain': 'L', 'Multiplication': 'Matrix(K*u)'}`
- `LQGI_nonlinear_sim/Kalman filter/Integrator` (Integrator): `{}`
- `LQGI_nonlinear_sim/Kalman filter/Sum` (Sum): `{'Inputs': '|+-'}`
- `LQGI_nonlinear_sim/Kalman filter/xhat` (Outport): `{}`
- `LQGI_nonlinear_sim/Mux` (Mux): `{'Inputs': '2', 'DisplayOption': 'bar'}`
- `LQGI_nonlinear_sim/Non linear plant/x` (Inport): `{}`
- `LQGI_nonlinear_sim/Non linear plant/tau` (Inport): `{'Port': '2'}`
- `LQGI_nonlinear_sim/Non linear plant/d` (Inport): `{'Port': '3'}`
- `LQGI_nonlinear_sim/Non linear plant/MATLAB Function/x` (Inport): `{}`
- `LQGI_nonlinear_sim/Non linear plant/MATLAB Function/tau` (Inport): `{'Port': '2'}`
- `LQGI_nonlinear_sim/Non linear plant/MATLAB Function/d` (Inport): `{'Port': '3'}`
- `LQGI_nonlinear_sim/Non linear plant/MATLAB Function/p` (Inport): `{'Port': '4'}`
- `LQGI_nonlinear_sim/Non linear plant/MATLAB Function/ Demux ` (Demux): `{'Outputs': '1'}`
- `LQGI_nonlinear_sim/Non linear plant/MATLAB Function/xdot` (Outport): `{}`
- `LQGI_nonlinear_sim/Non linear plant/MATLAB Function1/ Demux ` (Demux): `{'Outputs': '1'}`
- `LQGI_nonlinear_sim/Non linear plant/MATLAB Function1/p` (Outport): `{}`
- `LQGI_nonlinear_sim/Non linear plant/xdot` (Outport): `{}`
- `LQGI_nonlinear_sim/Rumore di processo link` (RandomNumber): `{'Mean': '[0 0]', 'Variance': '[0.01 0.01]', 'Seed': '20260826', 'SampleTime': '0.002'}`
- `LQGI_nonlinear_sim/Rumore di processo u` (RandomNumber): `{'Mean': '[0 0]', 'Variance': '[0.01 0.01]', 'Seed': '20260826', 'SampleTime': '0.002'}`
- `LQGI_nonlinear_sim/Rumori di misura` (RandomNumber): `{'Mean': '[0 0 0 0]', 'Variance': '[(0.05*pi/180)^2 (0.05*pi/180)^2 (0.05*pi/180)^2 (0.05*pi/180)^2]', 'Seed': '20260826', 'SampleTime': '0.002'}`
- `LQGI_nonlinear_sim/Sum` (Sum): `{'Inputs': '|--'}`
- `LQGI_nonlinear_sim/Sum1` (Sum): `{'Inputs': '++|'}`
- `LQGI_nonlinear_sim/Sum2` (Sum): `{'Inputs': '|+-'}`
- `LQGI_nonlinear_sim/Sum3` (Sum): `{'NameLocation': 'top', 'Inputs': '|++'}`
- `LQGI_nonlinear_sim/Sum5` (Sum): `{'Inputs': '-+|'}`
- `LQGI_nonlinear_sim/Sum6` (Sum): `{'Inputs': '|++'}`
- `LQGI_nonlinear_sim/Sum7` (Sum): `{'Inputs': '|++'}`
- `LQGI_nonlinear_sim/r1 (q1)` (Step): `{'FinalValue': '5*pi/180', 'SampleTime': '0'}`
- `LQGI_nonlinear_sim/r2 (q2)` (Step): `{'FinalValue': '0', 'SampleTime': '0'}`

### Connessioni

- `LQGI_nonlinear_sim/Actuators/Actuator 2#out:1` → `LQGI_nonlinear_sim/Actuators/Mux#in:2`
- `LQGI_nonlinear_sim/Actuators/Demux#out:2` → `LQGI_nonlinear_sim/Actuators/Actuator 2#in:1`
- `LQGI_nonlinear_sim/Actuators/u#out:1` → `LQGI_nonlinear_sim/Actuators/Demux#in:1`
- `LQGI_nonlinear_sim/Actuators/Demux#out:1` → `LQGI_nonlinear_sim/Actuators/Actuator 1#in:1`
- `LQGI_nonlinear_sim/Actuators/Mux#out:1` → `LQGI_nonlinear_sim/Actuators/tau#in:1`
- `LQGI_nonlinear_sim/Actuators/Actuator 1#out:1` → `LQGI_nonlinear_sim/Actuators/Mux#in:1`
- `LQGI_nonlinear_sim/Kalman filter/u#out:1` → `LQGI_nonlinear_sim/Kalman filter/Gain2#in:1`
- `LQGI_nonlinear_sim/Kalman filter/y#out:1` → `LQGI_nonlinear_sim/Kalman filter/Sum#in:1`
- `LQGI_nonlinear_sim/Kalman filter/Gain1#out:1` → `LQGI_nonlinear_sim/Kalman filter/Sum#in:2`
- `LQGI_nonlinear_sim/Kalman filter/Sum#out:1` → `LQGI_nonlinear_sim/Kalman filter/Gain3#in:1`
- `LQGI_nonlinear_sim/Kalman filter/Gain3#out:1` → `LQGI_nonlinear_sim/Kalman filter/Add#in:2`
- `LQGI_nonlinear_sim/Kalman filter/Gain2#out:1` → `LQGI_nonlinear_sim/Kalman filter/Add#in:1`
- `LQGI_nonlinear_sim/Kalman filter/Gain#out:1` → `LQGI_nonlinear_sim/Kalman filter/Add#in:3`
- `LQGI_nonlinear_sim/Kalman filter/Add#out:1` → `LQGI_nonlinear_sim/Kalman filter/Integrator#in:1`
- `LQGI_nonlinear_sim/Kalman filter/Integrator#out:1` → `LQGI_nonlinear_sim/Kalman filter/Gain#in:1`
- `LQGI_nonlinear_sim/Kalman filter/Integrator#out:1` → `LQGI_nonlinear_sim/Kalman filter/Gain1#in:1`
- `LQGI_nonlinear_sim/Kalman filter/Integrator#out:1` → `LQGI_nonlinear_sim/Kalman filter/xhat#in:1`
- `LQGI_nonlinear_sim/Non linear plant/MATLAB Function/x#out:1` → `LQGI_nonlinear_sim/Non linear plant/MATLAB Function/ SFunction #in:1`
- `LQGI_nonlinear_sim/Non linear plant/MATLAB Function/tau#out:1` → `LQGI_nonlinear_sim/Non linear plant/MATLAB Function/ SFunction #in:2`
- `LQGI_nonlinear_sim/Non linear plant/MATLAB Function/d#out:1` → `LQGI_nonlinear_sim/Non linear plant/MATLAB Function/ SFunction #in:3`
- `LQGI_nonlinear_sim/Non linear plant/MATLAB Function/p#out:1` → `LQGI_nonlinear_sim/Non linear plant/MATLAB Function/ SFunction #in:4`
- `LQGI_nonlinear_sim/Non linear plant/MATLAB Function/ SFunction #out:2` → `LQGI_nonlinear_sim/Non linear plant/MATLAB Function/xdot#in:1`
- `LQGI_nonlinear_sim/Non linear plant/MATLAB Function/ Demux #out:1` → `LQGI_nonlinear_sim/Non linear plant/MATLAB Function/ Terminator #in:1`
- `LQGI_nonlinear_sim/Non linear plant/MATLAB Function/ SFunction #out:1` → `LQGI_nonlinear_sim/Non linear plant/MATLAB Function/ Demux #in:1`
- `LQGI_nonlinear_sim/Non linear plant/MATLAB Function1/ SFunction #out:2` → `LQGI_nonlinear_sim/Non linear plant/MATLAB Function1/p#in:1`
- `LQGI_nonlinear_sim/Non linear plant/MATLAB Function1/ Ground #out:1` → `LQGI_nonlinear_sim/Non linear plant/MATLAB Function1/ SFunction #in:1`
- `LQGI_nonlinear_sim/Non linear plant/MATLAB Function1/ Demux #out:1` → `LQGI_nonlinear_sim/Non linear plant/MATLAB Function1/ Terminator #in:1`
- `LQGI_nonlinear_sim/Non linear plant/MATLAB Function1/ SFunction #out:1` → `LQGI_nonlinear_sim/Non linear plant/MATLAB Function1/ Demux #in:1`
- `LQGI_nonlinear_sim/Non linear plant/x#out:1` → `LQGI_nonlinear_sim/Non linear plant/MATLAB Function#in:1`
- `LQGI_nonlinear_sim/Non linear plant/tau#out:1` → `LQGI_nonlinear_sim/Non linear plant/MATLAB Function#in:2`
- `LQGI_nonlinear_sim/Non linear plant/MATLAB Function#out:1` → `LQGI_nonlinear_sim/Non linear plant/xdot#in:1`
- `LQGI_nonlinear_sim/Non linear plant/MATLAB Function1#out:1` → `LQGI_nonlinear_sim/Non linear plant/MATLAB Function#in:4`
- `LQGI_nonlinear_sim/Non linear plant/d#out:1` → `LQGI_nonlinear_sim/Non linear plant/MATLAB Function#in:3`
- `LQGI_nonlinear_sim/Demux#out:1` → `LQGI_nonlinear_sim/Uscita ideale#in:1`
- `LQGI_nonlinear_sim/Demux#out:3` → `LQGI_nonlinear_sim/Uscita ideale#in:3`
- `LQGI_nonlinear_sim/Non linear plant#out:1` → `LQGI_nonlinear_sim/Integrator#in:1`
- `LQGI_nonlinear_sim/Demux1#out:1` → `LQGI_nonlinear_sim/Uscita misurata#in:1`
- `LQGI_nonlinear_sim/Demux1#out:2` → `LQGI_nonlinear_sim/Uscita misurata#in:2`
- `LQGI_nonlinear_sim/Demux1#out:4` → `LQGI_nonlinear_sim/Uscita misurata#in:4`
- `LQGI_nonlinear_sim/Demux2#out:1` → `LQGI_nonlinear_sim/Variabile di controllo#in:1`
- `LQGI_nonlinear_sim/Demux#out:2` → `LQGI_nonlinear_sim/Uscita ideale#in:2`
- `LQGI_nonlinear_sim/Rumori di misura#out:1` → `LQGI_nonlinear_sim/Sum3#in:2`
- `LQGI_nonlinear_sim/Gain#out:1` → `LQGI_nonlinear_sim/Sum#in:2`
- `LQGI_nonlinear_sim/r1 (q1)#out:1` → `LQGI_nonlinear_sim/Mux#in:1`
- `LQGI_nonlinear_sim/Integrator#out:1` → `LQGI_nonlinear_sim/Non linear plant#in:1`
- `LQGI_nonlinear_sim/Integrator#out:1` → `LQGI_nonlinear_sim/Sum2#in:1`
- `LQGI_nonlinear_sim/Kalman filter#out:1` → `LQGI_nonlinear_sim/Gain#in:1`
- `LQGI_nonlinear_sim/Demux2#out:2` → `LQGI_nonlinear_sim/Variabile di controllo#in:2`
- `LQGI_nonlinear_sim/Demux#out:4` → `LQGI_nonlinear_sim/Uscita ideale#in:4`
- `LQGI_nonlinear_sim/Sum2#out:1` → `LQGI_nonlinear_sim/Selettore#in:1`
- `LQGI_nonlinear_sim/Sum1#out:1` → `LQGI_nonlinear_sim/Non linear plant#in:2`
- `LQGI_nonlinear_sim/r2 (q2)#out:1` → `LQGI_nonlinear_sim/Mux#in:2`
- `LQGI_nonlinear_sim/Demux1#out:3` → `LQGI_nonlinear_sim/Uscita misurata#in:3`
- `LQGI_nonlinear_sim/Sum#out:1` → `LQGI_nonlinear_sim/Kalman filter#in:1`
- `LQGI_nonlinear_sim/Sum#out:1` → `LQGI_nonlinear_sim/Goto#in:1`
- `LQGI_nonlinear_sim/Sum#out:1` → `LQGI_nonlinear_sim/Sum7#in:1`
- `LQGI_nonlinear_sim/Gain1#out:1` → `LQGI_nonlinear_sim/Sum#in:1`
- `LQGI_nonlinear_sim/Constant1#out:1` → `LQGI_nonlinear_sim/Sum2#in:2`
- `LQGI_nonlinear_sim/Sum5#out:1` → `LQGI_nonlinear_sim/Integrator1#in:1`
- `LQGI_nonlinear_sim/Integrator1#out:1` → `LQGI_nonlinear_sim/Gain1#in:1`
- `LQGI_nonlinear_sim/Mux#out:1` → `LQGI_nonlinear_sim/Goto3#in:1`
- `LQGI_nonlinear_sim/Mux#out:1` → `LQGI_nonlinear_sim/Sum5#in:2`
- `LQGI_nonlinear_sim/Selettore1#out:1` → `LQGI_nonlinear_sim/Sum5#in:1`
- `LQGI_nonlinear_sim/From#out:1` → `LQGI_nonlinear_sim/Demux2#in:1`
- `LQGI_nonlinear_sim/From1#out:1` → `LQGI_nonlinear_sim/Demux#in:1`
- `LQGI_nonlinear_sim/From2#out:1` → `LQGI_nonlinear_sim/Demux1#in:1`
- `LQGI_nonlinear_sim/Demux3#out:1` → `LQGI_nonlinear_sim/Uscita ideale#in:5`
- `LQGI_nonlinear_sim/Demux3#out:2` → `LQGI_nonlinear_sim/Uscita ideale#in:6`
- `LQGI_nonlinear_sim/From3#out:1` → `LQGI_nonlinear_sim/Demux3#in:1`
- `LQGI_nonlinear_sim/Demux4#out:2` → `LQGI_nonlinear_sim/Uscita misurata#in:6`
- `LQGI_nonlinear_sim/Demux4#out:1` → `LQGI_nonlinear_sim/Uscita misurata#in:5`
- `LQGI_nonlinear_sim/From4#out:1` → `LQGI_nonlinear_sim/Demux4#in:1`
- `LQGI_nonlinear_sim/Selettore#out:1` → `LQGI_nonlinear_sim/Sum3#in:1`
- `LQGI_nonlinear_sim/Selettore#out:1` → `LQGI_nonlinear_sim/Goto1#in:1`
- `LQGI_nonlinear_sim/Sum3#out:1` → `LQGI_nonlinear_sim/Goto2#in:1`
- `LQGI_nonlinear_sim/Sum3#out:1` → `LQGI_nonlinear_sim/Kalman filter#in:2`
- `LQGI_nonlinear_sim/Sum3#out:1` → `LQGI_nonlinear_sim/Selettore1#in:1`
- `LQGI_nonlinear_sim/Rumore di processo link#out:1` → `LQGI_nonlinear_sim/Sum6#in:2`
- `LQGI_nonlinear_sim/Rumore di processo u#out:1` → `LQGI_nonlinear_sim/Sum7#in:2`
- `LQGI_nonlinear_sim/Sum6#out:1` → `LQGI_nonlinear_sim/Non linear plant#in:3`
- `LQGI_nonlinear_sim/Disturbi di coppia#out:1` → `LQGI_nonlinear_sim/Sum6#in:1`
- `LQGI_nonlinear_sim/Sum7#out:1` → `LQGI_nonlinear_sim/Actuators#in:1`
- `LQGI_nonlinear_sim/Constant#out:1` → `LQGI_nonlinear_sim/Sum1#in:1`
- `LQGI_nonlinear_sim/Actuators#out:1` → `LQGI_nonlinear_sim/Sum1#in:2`

### Callback InitFcn

```matlab
actuator = actuator_params_nominal();
[Gact, info] = build_nominal_actuator(actuator);

% Parametri del robot
p = sea_params_nominal();
Simulink.Bus.createObject(p);

% Equilibrio desiderato
qbar = [pi/2; 0];

% Calcolo stato e coppia di equilibrio
[xbar, taubar, info] = sea_static_equilibrium(qbar, p);
```

### Funzione incorporata: simulink/stateflow/chart_10.xml

```matlab
function p = sea_params_nominal
%SEA_PARAMS_NOMINAL Nominal mechanical parameters of the 2R SEA robot.
%   P = SEA_PARAMS_NOMINAL returns the values stated by the official
%   assignment. Matrices follow the joint order [joint 1; joint 2].

p.m1 = 1.0;                   % kg
p.m2 = 0.8;                   % kg
p.l1 = 0.4;                   % m
p.l2 = 0.3;                   % m
p.Jm = diag([0.01, 0.01]);    % kg*m^2
p.Bm = diag([0.02, 0.02]);    % N*m*s/rad
p.Ks = diag([50, 40]);        % N*m/rad
p.g = 9.81;                   % m/s^2
end

```

### Funzione incorporata: simulink/stateflow/chart_16.xml

```matlab
function xdot = sea_nonlinear_rhs_with_link_disturbance(x, tau, d, p)
%SEA_NONLINEAR_RHS_WITH_LINK_DISTURBANCE SEA dynamics with link torque D.
%   TAU remains the motor-side input; D is an external link-side joint
%   torque entering with positive sign in the link equation.

assert(numel(x) == 8, ...
    'sea_nonlinear_rhs_with_link_disturbance:InvalidState', ...
    'The state must contain exactly eight elements.');
assert(numel(tau) == 2 && numel(d) == 2, ...
    'sea_nonlinear_rhs_with_link_disturbance:InvalidInput', ...
    'Both tau and d must contain exactly two elements.');
x = reshape(x, 8, 1);
tau = reshape(tau, 2, 1);
d = reshape(d, 2, 1);

q = x(1:2);
qdot = x(3:4);
theta = x(5:6);
thetadot = x(7:8);
M = sea_link_inertia(q, p);
C = sea_coriolis(q, qdot, p);
G = sea_gravity(q, p);
tauElastic = sea_elastic_torque(q, theta, p);

qddot = M \ (tauElastic + d - C * qdot - G);
thetaddot = p.Jm \ (tau - p.Bm * thetadot - tauElastic);
xdot = [qdot; qddot; thetadot; thetaddot];
end

```
## mu_linear_sim.slx

Release: {'version': '26.1.0.3312084', 'release': 'R2026a', 'description': 'Update 4', 'date': 'Jun 30 2026', 'checksum': '4132326121'}

SHA-256: `9d60a5b211c989f2c3324b47e6c218fc470d834d5633481c0d3c927c6eee078b`

Configurazione: `{'SolverName': 'VariableStepAuto'}`

### Blocchi e parametri

- `mu_linear_sim/Constant1` (Constant): `{'Value': '[0 0]'}`
- `mu_linear_sim/Demux` (Demux): `{}`
- `mu_linear_sim/Demux1` (Demux): `{}`
- `mu_linear_sim/Demux2` (Demux): `{'Outputs': '2'}`
- `mu_linear_sim/Demux3` (Demux): `{'Outputs': '2'}`
- `mu_linear_sim/Demux4` (Demux): `{'Outputs': '2'}`
- `mu_linear_sim/Disturbo di coppia` (Step): `{'Time': '[1 1]', 'InitialValue': '[0 0]', 'FinalValue': '[0.5 0]', 'SampleTime': '0'}`
- `mu_linear_sim/Linear plant` (StateSpace): `{'A': 'Aplant', 'B': 'Bplant', 'C': 'Cplant', 'D': 'Dplant', 'InitialCondition': 'x0plant'}`
- `mu_linear_sim/Mux` (Mux): `{'Inputs': '2', 'DisplayOption': 'bar'}`
- `mu_linear_sim/Mux2` (Mux): `{'DisplayOption': 'bar'}`
- `mu_linear_sim/Mux3` (Mux): `{'DisplayOption': 'bar'}`
- `mu_linear_sim/Mux4` (Mux): `{'Inputs': '2', 'DisplayOption': 'bar'}`
- `mu_linear_sim/Rumore di processo link` (RandomNumber): `{'Mean': '[0 0]', 'Variance': '[0.01 0.01]', 'Seed': '20260826', 'SampleTime': '0.002'}`
- `mu_linear_sim/Rumore di processo u` (RandomNumber): `{'Mean': '[0 0]', 'Variance': '[0.01 0.01]', 'Seed': '20260826', 'SampleTime': '0.002'}`
- `mu_linear_sim/Rumori di misura` (RandomNumber): `{'Mean': '[0 0 0 0]', 'Variance': '[(0.05*pi/180)^2 (0.05*pi/180)^2 (0.05*pi/180)^2 (0.05*pi/180)^2]', 'Seed': '20260826', 'SampleTime': '0.002'}`
- `mu_linear_sim/Sum2` (Sum): `{'NameLocation': 'top', 'Inputs': '|++'}`
- `mu_linear_sim/r1` (Step): `{'FinalValue': '5*pi/180', 'SampleTime': '0'}`
- `mu_linear_sim/r2` (Step): `{'FinalValue': '0', 'SampleTime': '0'}`

### Connessioni

- `mu_linear_sim/Mux#out:1` → `mu_linear_sim/Mux4#in:1`
- `mu_linear_sim/Mux#out:1` → `mu_linear_sim/Goto3#in:1`
- `mu_linear_sim/Constant1#out:1` → `mu_linear_sim/Mux2#in:2`
- `mu_linear_sim/Constant1#out:1` → `mu_linear_sim/Mux2#in:4`
- `mu_linear_sim/Constant1#out:1` → `mu_linear_sim/Mux2#in:3`
- `mu_linear_sim/Rumore di processo link#out:1` → `mu_linear_sim/Mux3#in:3`
- `mu_linear_sim/r2#out:1` → `mu_linear_sim/Mux#in:2`
- `mu_linear_sim/Disturbo di coppia#out:1` → `mu_linear_sim/Mux3#in:2`
- `mu_linear_sim/Manual Switch#out:1` → `mu_linear_sim/Linear plant#in:1`
- `mu_linear_sim/Mux4#out:1` → `mu_linear_sim/Controllori mu#in:1`
- `mu_linear_sim/Rumore di processo u#out:1` → `mu_linear_sim/Mux3#in:4`
- `mu_linear_sim/Sum2#out:1` → `mu_linear_sim/Goto6#in:1`
- `mu_linear_sim/Sum2#out:1` → `mu_linear_sim/Selector1#in:1`
- `mu_linear_sim/r1#out:1` → `mu_linear_sim/Mux#in:1`
- `mu_linear_sim/Mux2#out:1` → `mu_linear_sim/Manual Switch#in:1`
- `mu_linear_sim/Linear plant#out:1` → `mu_linear_sim/Goto5#in:1`
- `mu_linear_sim/Linear plant#out:1` → `mu_linear_sim/Sum2#in:1`
- `mu_linear_sim/Mux3#out:1` → `mu_linear_sim/Manual Switch#in:2`
- `mu_linear_sim/Selector1#out:1` → `mu_linear_sim/Mux4#in:2`
- `mu_linear_sim/Controllori mu#out:1` → `mu_linear_sim/Mux2#in:1`
- `mu_linear_sim/Controllori mu#out:1` → `mu_linear_sim/Mux3#in:1`
- `mu_linear_sim/Controllori mu#out:1` → `mu_linear_sim/Goto4#in:1`
- `mu_linear_sim/From2#out:1` → `mu_linear_sim/Demux1#in:1`
- `mu_linear_sim/Demux4#out:2` → `mu_linear_sim/Uscita misurata#in:6`
- `mu_linear_sim/Demux1#out:4` → `mu_linear_sim/Uscita misurata#in:4`
- `mu_linear_sim/From3#out:1` → `mu_linear_sim/Demux3#in:1`
- `mu_linear_sim/Demux1#out:2` → `mu_linear_sim/Uscita misurata#in:2`
- `mu_linear_sim/Demux4#out:1` → `mu_linear_sim/Uscita misurata#in:5`
- `mu_linear_sim/From4#out:1` → `mu_linear_sim/Demux4#in:1`
- `mu_linear_sim/Demux#out:3` → `mu_linear_sim/Uscita ideale#in:3`
- `mu_linear_sim/Demux#out:4` → `mu_linear_sim/Uscita ideale#in:4`
- `mu_linear_sim/From1#out:1` → `mu_linear_sim/Demux#in:1`
- `mu_linear_sim/Demux#out:1` → `mu_linear_sim/Uscita ideale#in:1`
- `mu_linear_sim/Demux#out:2` → `mu_linear_sim/Uscita ideale#in:2`
- `mu_linear_sim/Demux2#out:1` → `mu_linear_sim/Variabile di controllo#in:1`
- `mu_linear_sim/Demux3#out:2` → `mu_linear_sim/Uscita ideale#in:6`
- `mu_linear_sim/Demux1#out:3` → `mu_linear_sim/Uscita misurata#in:3`
- `mu_linear_sim/Demux3#out:1` → `mu_linear_sim/Uscita ideale#in:5`
- `mu_linear_sim/Demux2#out:2` → `mu_linear_sim/Variabile di controllo#in:2`
- `mu_linear_sim/From#out:1` → `mu_linear_sim/Demux2#in:1`
- `mu_linear_sim/Demux1#out:1` → `mu_linear_sim/Uscita misurata#in:1`
- `mu_linear_sim/Rumori di misura#out:1` → `mu_linear_sim/Sum2#in:2`

### Callback InitFcn

```matlab




%% INITFCN - Pianta LQGI lineare a 14 stati con 8 ingressi

% Individua la root del progetto partendo da progetto_lqgi.m
projectFile = which('progetto_lqgi.m');

assert(~isempty(projectFile), ...
    ['progetto_lqgi.m non trovato. Eseguire prima lo script ' ...
    'e verificare il MATLAB path.']);

projectRoot = fileparts(fileparts(projectFile));
dataDir = fullfile(projectRoot, 'results', 'data');

% File prodotti dagli script di validazione M3 e M5
m3File = fullfile(dataDir, 'm3_nominal_actuated_plant.mat');
m5File = fullfile(dataDir, 'm5_performance_specs.mat');

% Verifica che i dati della pianta esistano
assert(isfile(m3File), ...
    'Manca m3_nominal_actuated_plant.mat. Eseguire la validazione M3.');

% Se M5 non e' ancora stato generato, costruisce BdFull
if ~isfile(m5File)
    addpath(genpath(fullfile(projectRoot, 'src')));
    addpath(genpath(fullfile(projectRoot, 'analysis')));
    validate_m5_performance_specs;
end

assert(isfile(m5File), ...
    'Manca m5_performance_specs.mat dopo la validazione M5.');

% Carica le matrici necessarie
m3 = load(m3File, 'Afull', 'Bfull', 'CfullMeas');
m5 = load(m5File, 'BdFull');

Aplant = m3.Afull;
Bfull = m3.Bfull;
BdFull = m5.BdFull;
Cplant = m3.CfullMeas;

% Controlli sulle dimensioni delle matrici
assert(isequal(size(Aplant), [14 14]));
assert(isequal(size(Bfull), [14 2]));
assert(isequal(size(BdFull), [14 2]));
assert(isequal(size(Cplant), [4 14]));

% Ordine degli ingressi:
% 1-2: comando u
% 3-4: disturbo deterministico d lato link
% 5-6: rumore di processo w_link
% 7-8: rumore di processo w_u lato ingresso

Bplant = [Bfull, BdFull, BdFull, Bfull];

% Nessuna trasmissione diretta dagli ingressi alle misure
Dplant = zeros(4, 8);

% Condizione iniziale del modello linearizzato in deviazioni
x0plant = zeros(14, 1);

% Pubblica le variabili nel Base Workspace per i blocchi Simulink
assignin('base', 'Aplant', Aplant);
assignin('base', 'Bplant', Bplant);
assignin('base', 'Cplant', Cplant);
assignin('base', 'Dplant', Dplant);
assignin('base', 'x0plant', x0plant);

% Mantiene disponibili anche le matrici originali
assignin('base', 'Afull', Aplant);
assignin('base', 'Bfull', Bfull);
assignin('base', 'BdFull', BdFull);
assignin('base', 'CfullMeas', Cplant);

fprintf(['InitFcn LQGI: Aplant %dx%d, Bplant %dx%d, ' ...
    'Cplant %dx%d, Dplant %dx%d.\\n'], ...
    size(Aplant,1), size(Aplant,2), ...
    size(Bplant,1), size(Bplant,2), ...
    size(Cplant,1), size(Cplant,2), ...
    size(Dplant,1), size(Dplant,2));
```
## mu_nonlinear_sim.slx

Release: {'version': '26.1.0.3312084', 'release': 'R2026a', 'description': 'Update 4', 'date': 'Jun 30 2026', 'checksum': '4132326121'}

SHA-256: `2c4043bc805fbddeff1357b6de5a02073f11729bfdb33007c98de71bbacb12de`

Configurazione: `{'SolverName': 'VariableStepAuto'}`

### Blocchi e parametri

- `mu_nonlinear_sim/Actuators1/u` (Inport): `{}`
- `mu_nonlinear_sim/Actuators1/Demux` (Demux): `{'Outputs': '2'}`
- `mu_nonlinear_sim/Actuators1/Mux` (Mux): `{'Inputs': '2', 'DisplayOption': 'bar'}`
- `mu_nonlinear_sim/Actuators1/tau` (Outport): `{}`
- `mu_nonlinear_sim/Constant1` (Constant): `{'Value': 'taubar'}`
- `mu_nonlinear_sim/Constant2` (Constant): `{'Value': 'xbar'}`
- `mu_nonlinear_sim/Constant6` (Constant): `{'BlockMirror': 'on', 'NameLocation': 'top', 'Value': '[0 0]'}`
- `mu_nonlinear_sim/Demux` (Demux): `{}`
- `mu_nonlinear_sim/Demux1` (Demux): `{}`
- `mu_nonlinear_sim/Demux2` (Demux): `{'Outputs': '2'}`
- `mu_nonlinear_sim/Demux3` (Demux): `{'Outputs': '2'}`
- `mu_nonlinear_sim/Demux4` (Demux): `{'Outputs': '2'}`
- `mu_nonlinear_sim/Disturbi di coppia1` (Step): `{'Time': '[1 1]', 'InitialValue': '[0 0]', 'FinalValue': '[0.5 0]', 'SampleTime': '0'}`
- `mu_nonlinear_sim/Integrator1` (Integrator): `{'InitialCondition': 'xbar'}`
- `mu_nonlinear_sim/Mux` (Mux): `{'Inputs': '2', 'DisplayOption': 'bar'}`
- `mu_nonlinear_sim/Mux1` (Mux): `{'Inputs': '2', 'DisplayOption': 'bar'}`
- `mu_nonlinear_sim/Non linear plant1/x` (Inport): `{}`
- `mu_nonlinear_sim/Non linear plant1/tau` (Inport): `{'Port': '2'}`
- `mu_nonlinear_sim/Non linear plant1/d` (Inport): `{'Port': '3'}`
- `mu_nonlinear_sim/Non linear plant1/MATLAB Function/x` (Inport): `{}`
- `mu_nonlinear_sim/Non linear plant1/MATLAB Function/tau` (Inport): `{'Port': '2'}`
- `mu_nonlinear_sim/Non linear plant1/MATLAB Function/d` (Inport): `{'Port': '3'}`
- `mu_nonlinear_sim/Non linear plant1/MATLAB Function/p` (Inport): `{'Port': '4'}`
- `mu_nonlinear_sim/Non linear plant1/MATLAB Function/ Demux ` (Demux): `{'Outputs': '1'}`
- `mu_nonlinear_sim/Non linear plant1/MATLAB Function/xdot` (Outport): `{}`
- `mu_nonlinear_sim/Non linear plant1/MATLAB Function1/ Demux ` (Demux): `{'Outputs': '1'}`
- `mu_nonlinear_sim/Non linear plant1/MATLAB Function1/p` (Outport): `{}`
- `mu_nonlinear_sim/Non linear plant1/xdot` (Outport): `{}`
- `mu_nonlinear_sim/Rumore di processo link1` (RandomNumber): `{'Mean': '[0 0]', 'Variance': '[0.01 0.01]', 'Seed': '20260826', 'SampleTime': '0.002'}`
- `mu_nonlinear_sim/Rumore di processo u1` (RandomNumber): `{'Mean': '[0 0]', 'Variance': '[0.01 0.01]', 'Seed': '20260826', 'SampleTime': '0.002'}`
- `mu_nonlinear_sim/Rumori di misura1` (RandomNumber): `{'Mean': '[0 0 0 0]', 'Variance': '[(0.05*pi/180)^2 (0.05*pi/180)^2 (0.05*pi/180)^2 (0.05*pi/180)^2]', 'Seed': '20260826', 'SampleTime': '0.002'}`
- `mu_nonlinear_sim/Sum10` (Sum): `{'Inputs': '|++'}`
- `mu_nonlinear_sim/Sum11` (Sum): `{'Inputs': '|++'}`
- `mu_nonlinear_sim/Sum2` (Sum): `{'Inputs': '++|'}`
- `mu_nonlinear_sim/Sum3` (Sum): `{'Inputs': '|+-'}`
- `mu_nonlinear_sim/Sum9` (Sum): `{'NameLocation': 'top', 'Inputs': '|++'}`
- `mu_nonlinear_sim/r1` (Step): `{'FinalValue': '5*pi/180', 'SampleTime': '0'}`
- `mu_nonlinear_sim/r2` (Step): `{'FinalValue': '0', 'SampleTime': '0'}`

### Connessioni

- `mu_nonlinear_sim/Actuators1/Actuator 2#out:1` → `mu_nonlinear_sim/Actuators1/Mux#in:2`
- `mu_nonlinear_sim/Actuators1/Demux#out:2` → `mu_nonlinear_sim/Actuators1/Actuator 2#in:1`
- `mu_nonlinear_sim/Actuators1/u#out:1` → `mu_nonlinear_sim/Actuators1/Demux#in:1`
- `mu_nonlinear_sim/Actuators1/Demux#out:1` → `mu_nonlinear_sim/Actuators1/Actuator 1#in:1`
- `mu_nonlinear_sim/Actuators1/Mux#out:1` → `mu_nonlinear_sim/Actuators1/tau#in:1`
- `mu_nonlinear_sim/Actuators1/Actuator 1#out:1` → `mu_nonlinear_sim/Actuators1/Mux#in:1`
- `mu_nonlinear_sim/Non linear plant1/MATLAB Function/x#out:1` → `mu_nonlinear_sim/Non linear plant1/MATLAB Function/ SFunction #in:1`
- `mu_nonlinear_sim/Non linear plant1/MATLAB Function/tau#out:1` → `mu_nonlinear_sim/Non linear plant1/MATLAB Function/ SFunction #in:2`
- `mu_nonlinear_sim/Non linear plant1/MATLAB Function/d#out:1` → `mu_nonlinear_sim/Non linear plant1/MATLAB Function/ SFunction #in:3`
- `mu_nonlinear_sim/Non linear plant1/MATLAB Function/p#out:1` → `mu_nonlinear_sim/Non linear plant1/MATLAB Function/ SFunction #in:4`
- `mu_nonlinear_sim/Non linear plant1/MATLAB Function/ SFunction #out:2` → `mu_nonlinear_sim/Non linear plant1/MATLAB Function/xdot#in:1`
- `mu_nonlinear_sim/Non linear plant1/MATLAB Function/ Demux #out:1` → `mu_nonlinear_sim/Non linear plant1/MATLAB Function/ Terminator #in:1`
- `mu_nonlinear_sim/Non linear plant1/MATLAB Function/ SFunction #out:1` → `mu_nonlinear_sim/Non linear plant1/MATLAB Function/ Demux #in:1`
- `mu_nonlinear_sim/Non linear plant1/MATLAB Function1/ SFunction #out:2` → `mu_nonlinear_sim/Non linear plant1/MATLAB Function1/p#in:1`
- `mu_nonlinear_sim/Non linear plant1/MATLAB Function1/ Ground #out:1` → `mu_nonlinear_sim/Non linear plant1/MATLAB Function1/ SFunction #in:1`
- `mu_nonlinear_sim/Non linear plant1/MATLAB Function1/ Demux #out:1` → `mu_nonlinear_sim/Non linear plant1/MATLAB Function1/ Terminator #in:1`
- `mu_nonlinear_sim/Non linear plant1/MATLAB Function1/ SFunction #out:1` → `mu_nonlinear_sim/Non linear plant1/MATLAB Function1/ Demux #in:1`
- `mu_nonlinear_sim/Non linear plant1/x#out:1` → `mu_nonlinear_sim/Non linear plant1/MATLAB Function#in:1`
- `mu_nonlinear_sim/Non linear plant1/tau#out:1` → `mu_nonlinear_sim/Non linear plant1/MATLAB Function#in:2`
- `mu_nonlinear_sim/Non linear plant1/MATLAB Function#out:1` → `mu_nonlinear_sim/Non linear plant1/xdot#in:1`
- `mu_nonlinear_sim/Non linear plant1/MATLAB Function1#out:1` → `mu_nonlinear_sim/Non linear plant1/MATLAB Function#in:4`
- `mu_nonlinear_sim/Non linear plant1/d#out:1` → `mu_nonlinear_sim/Non linear plant1/MATLAB Function#in:3`
- `mu_nonlinear_sim/Manual Switch1#out:1` → `mu_nonlinear_sim/Non linear plant1#in:3`
- `mu_nonlinear_sim/Selector1#out:1` → `mu_nonlinear_sim/Mux1#in:2`
- `mu_nonlinear_sim/r2#out:1` → `mu_nonlinear_sim/Mux#in:2`
- `mu_nonlinear_sim/Sum9#out:1` → `mu_nonlinear_sim/Goto5#in:1`
- `mu_nonlinear_sim/Sum9#out:1` → `mu_nonlinear_sim/Selector1#in:1`
- `mu_nonlinear_sim/r1#out:1` → `mu_nonlinear_sim/Mux#in:1`
- `mu_nonlinear_sim/Integrator1#out:1` → `mu_nonlinear_sim/Non linear plant1#in:1`
- `mu_nonlinear_sim/Integrator1#out:1` → `mu_nonlinear_sim/Sum3#in:1`
- `mu_nonlinear_sim/Constant2#out:1` → `mu_nonlinear_sim/Sum3#in:2`
- `mu_nonlinear_sim/Sum3#out:1` → `mu_nonlinear_sim/Selettore1#in:1`
- `mu_nonlinear_sim/Sum10#out:1` → `mu_nonlinear_sim/Manual Switch1#in:1`
- `mu_nonlinear_sim/Constant1#out:1` → `mu_nonlinear_sim/Sum2#in:1`
- `mu_nonlinear_sim/Sum2#out:1` → `mu_nonlinear_sim/Non linear plant1#in:2`
- `mu_nonlinear_sim/Constant6#out:1` → `mu_nonlinear_sim/Manual Switch1#in:2`
- `mu_nonlinear_sim/Sum11#out:1` → `mu_nonlinear_sim/Actuators1#in:1`
- `mu_nonlinear_sim/Mux#out:1` → `mu_nonlinear_sim/Mux1#in:1`
- `mu_nonlinear_sim/Mux#out:1` → `mu_nonlinear_sim/Goto3#in:1`
- `mu_nonlinear_sim/Actuators1#out:1` → `mu_nonlinear_sim/Sum2#in:2`
- `mu_nonlinear_sim/Rumore di processo u1#out:1` → `mu_nonlinear_sim/Sum11#in:2`
- `mu_nonlinear_sim/LTI System#out:1` → `mu_nonlinear_sim/Sum11#in:1`
- `mu_nonlinear_sim/LTI System#out:1` → `mu_nonlinear_sim/Goto1#in:1`
- `mu_nonlinear_sim/Selettore1#out:1` → `mu_nonlinear_sim/Sum9#in:1`
- `mu_nonlinear_sim/Selettore1#out:1` → `mu_nonlinear_sim/Goto4#in:1`
- `mu_nonlinear_sim/Rumore di processo link1#out:1` → `mu_nonlinear_sim/Sum10#in:2`
- `mu_nonlinear_sim/Disturbi di coppia1#out:1` → `mu_nonlinear_sim/Sum10#in:1`
- `mu_nonlinear_sim/Mux1#out:1` → `mu_nonlinear_sim/LTI System#in:1`
- `mu_nonlinear_sim/Non linear plant1#out:1` → `mu_nonlinear_sim/Integrator1#in:1`
- `mu_nonlinear_sim/From2#out:1` → `mu_nonlinear_sim/Demux1#in:1`
- `mu_nonlinear_sim/Demux4#out:2` → `mu_nonlinear_sim/Uscita misurata#in:6`
- `mu_nonlinear_sim/Demux1#out:4` → `mu_nonlinear_sim/Uscita misurata#in:4`
- `mu_nonlinear_sim/From3#out:1` → `mu_nonlinear_sim/Demux3#in:1`
- `mu_nonlinear_sim/Demux1#out:2` → `mu_nonlinear_sim/Uscita misurata#in:2`
- `mu_nonlinear_sim/Demux4#out:1` → `mu_nonlinear_sim/Uscita misurata#in:5`
- `mu_nonlinear_sim/From4#out:1` → `mu_nonlinear_sim/Demux4#in:1`
- `mu_nonlinear_sim/Demux#out:3` → `mu_nonlinear_sim/Uscita ideale#in:3`
- `mu_nonlinear_sim/Demux#out:4` → `mu_nonlinear_sim/Uscita ideale#in:4`
- `mu_nonlinear_sim/From1#out:1` → `mu_nonlinear_sim/Demux#in:1`
- `mu_nonlinear_sim/Demux#out:1` → `mu_nonlinear_sim/Uscita ideale#in:1`
- `mu_nonlinear_sim/Demux#out:2` → `mu_nonlinear_sim/Uscita ideale#in:2`
- `mu_nonlinear_sim/Demux2#out:1` → `mu_nonlinear_sim/Variabile di controllo#in:1`
- `mu_nonlinear_sim/Demux3#out:2` → `mu_nonlinear_sim/Uscita ideale#in:6`
- `mu_nonlinear_sim/Demux1#out:3` → `mu_nonlinear_sim/Uscita misurata#in:3`
- `mu_nonlinear_sim/Demux3#out:1` → `mu_nonlinear_sim/Uscita ideale#in:5`
- `mu_nonlinear_sim/Demux2#out:2` → `mu_nonlinear_sim/Variabile di controllo#in:2`
- `mu_nonlinear_sim/From#out:1` → `mu_nonlinear_sim/Demux2#in:1`
- `mu_nonlinear_sim/Demux1#out:1` → `mu_nonlinear_sim/Uscita misurata#in:1`
- `mu_nonlinear_sim/Rumori di misura1#out:1` → `mu_nonlinear_sim/Sum9#in:2`

### Callback InitFcn

```matlab
actuator = actuator_params_nominal();
[Gact, info] = build_nominal_actuator(actuator);

% Parametri del robot
p = sea_params_nominal();
Simulink.Bus.createObject(p);

% Equilibrio desiderato
qbar = [pi/2; 0];

% Calcolo stato e coppia di equilibrio
[xbar, taubar, info] = sea_static_equilibrium(qbar, p);


```

### Funzione incorporata: simulink/stateflow/chart_10.xml

```matlab
function xdot = sea_nonlinear_rhs_with_link_disturbance(x, tau, d, p)
%SEA_NONLINEAR_RHS_WITH_LINK_DISTURBANCE SEA dynamics with link torque D.
%   TAU remains the motor-side input; D is an external link-side joint
%   torque entering with positive sign in the link equation.

assert(numel(x) == 8, ...
    'sea_nonlinear_rhs_with_link_disturbance:InvalidState', ...
    'The state must contain exactly eight elements.');
assert(numel(tau) == 2 && numel(d) == 2, ...
    'sea_nonlinear_rhs_with_link_disturbance:InvalidInput', ...
    'Both tau and d must contain exactly two elements.');
x = reshape(x, 8, 1);
tau = reshape(tau, 2, 1);
d = reshape(d, 2, 1);

q = x(1:2);
qdot = x(3:4);
theta = x(5:6);
thetadot = x(7:8);
M = sea_link_inertia(q, p);
C = sea_coriolis(q, qdot, p);
G = sea_gravity(q, p);
tauElastic = sea_elastic_torque(q, theta, p);

qddot = M \ (tauElastic + d - C * qdot - G);
thetaddot = p.Jm \ (tau - p.Bm * thetadot - tauElastic);
xdot = [qdot; qddot; thetadot; thetaddot];
end

```

### Funzione incorporata: simulink/stateflow/chart_20.xml

```matlab
function p = sea_params_nominal
%SEA_PARAMS_NOMINAL Nominal mechanical parameters of the 2R SEA robot.
%   P = SEA_PARAMS_NOMINAL returns the values stated by the official
%   assignment. Matrices follow the joint order [joint 1; joint 2].

p.m1 = 1.0;                   % kg
p.m2 = 0.8;                   % kg
p.l1 = 0.4;                   % m
p.l2 = 0.3;                   % m
p.Jm = diag([0.01, 0.01]);    % kg*m^2
p.Bm = diag([0.02, 0.02]);    % N*m*s/rad
p.Ks = diag([50, 40]);        % N*m/rad
p.g = 9.81;                   % m/s^2
end

```
