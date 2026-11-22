clc
clear all
init

mdl = 'SAD_PROJECT';
load_system(mdl);

simIn = Simulink.SimulationInput(mdl);
simIn = simIn.setModelParameter( ...
    'Solver', 'ode5', ...
    'SolverType', 'Fixed-step', ...
    'FixedStep', num2str(dt_step), ...
    'StopTime', num2str(t_stop) ...
    );

out = sim(simIn);

t = out.tout;


