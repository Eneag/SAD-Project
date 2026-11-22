clc
clear all
init

mdl = 'DynKynValidation';
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

%% ANGLES

angles = out.angles;

figure()
plot(t,rad2deg(angles));
title("Angles");
legend('\phi','\theta','\psi')

%% ANGULAR VELOCITY

w = squeeze(out.w_vector)';

figure()
tiledlayout(2,1);
nexttile;
plot3( w(1,:), w(2,:), w(3,:), '-' ) 
xlabel('Wx [1/s]'); ylabel('Wy [1/s]'); zlabel('Wz [1/s]');
title('W');
hold on;
axis equal;
grid on;

% Extract current limits to ensure the lines span the entire plot area
x_lims = xlim;
y_lims = ylim;
z_lims = zlim;

% Plot the 3 dark axes intersecting at the origin
plot3(x_lims, [0 0], [0 0], 'k', 'LineWidth', 1.5); % X-axis
plot3([0 0], y_lims, [0 0], 'k', 'LineWidth', 1.5); % Y-axis
plot3([0 0], [0 0], [0, z_lims(1,2)], 'k', 'LineWidth', 1.5); % Z-axis

nexttile;
plot(out.tout,w(1,:),out.tout,w(2,:),out.tout,w(3,:));
legend("\omega_x", "\omega_y", "\omega_z");
title('\omega over time');


%% model validation: e and h constant


kineticEnergy = 0.5 * sum(w .* (I * w), 1);
relativeErrorKineticEnergy = (kineticEnergy(1)-kineticEnergy)./kineticEnergy(1);
angularMomentumNorm = vecnorm(I * w,2,1);
relativeErrorMomentum = (angularMomentumNorm(1)-angularMomentumNorm)./angularMomentumNorm(1);

figure
tiledlayout(3,1)
nexttile;
plot(out.tout, relativeErrorKineticEnergy, 'LineWidth', 1.2);
xlabel('Time [s]');
title('K_{energy} error');
grid on;

nexttile;
plot(out.tout, relativeErrorMomentum, 'LineWidth', 1.2);
xlabel('Time [s]');
title('h error');
grid on;

%% model validation: difference from simmetric analityc case

lambda = (Iz-Ix)/Ix * wz0;
wx_a = wx0 * cos(lambda*out.tout) - wy0 * sin(lambda * out.tout);
wy_a = wx0 * sin(lambda*out.tout) + wy0 * cos(lambda * out.tout);
wz_a = wz0 * ones(size(out.tout));

% nexttile;
% plot3( wx_a, wy_a, wz_a, '-' ) 
% xlabel('Wx_a [km]'); ylabel('Wy_a [km]'); zlabel('Wz_a [km]');
% title('W_a');
% hold on;
% axis equal;
% grid on;

nexttile;
title('Relative error wrt analityical simmetric case');
ex = (w(1,:)-wx_a') ./ wx_a';
ey = (w(2,:)-wy_a') ./ wy_a';
ez = (w(3,:)-wz_a') ./ wz_a';
plot(out.tout,ex, out.tout,ey, out.tout,ez);
legend("error_x", "error_y", "error_z");