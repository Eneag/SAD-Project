clear; clc; close all

%% Orbit and geometry
mu_earth = 398600.435507;
R_earth = 6371.2;
Altitude = 575;
R = R_earth + Altitude;          % semi-major axis [km]
n = sqrt(mu_earth/R^3);
e = 0.001;
RAAN = 0;
w = 0;
i_inc = deg2rad(97.7);
n_earth = 7.292115e-5;

R3_W = [cos(RAAN) -sin(RAAN) 0; sin(RAAN) cos(RAAN) 0; 0 0 1];
R1_i = [1 0 0; 0 cos(i_inc) -sin(i_inc); 0 sin(i_inc) cos(i_inc)];
R3_w = [cos(w) -sin(w) 0; sin(w) cos(w) 0; 0 0 1];
R_PQW_to_N = R3_W*R1_i*R3_w;

Lx = 0.10; Ly = 0.10; Lz = 0.30;
configPanels = 'parallel';
if strcmp(configPanels,'parallel')
    py = 0.10; pz = 0.30;
else
    py = 0.30; pz = 0.10;
end
d_panel = Ly/2 + py/2;
A_panel = py*pz;
N_surf = [1 0 0; 0 1 0; 0 0 1; -1 0 0; 0 -1 0; 0 0 -1; ...
          1 0 0; -1 0 0; 1 0 0; -1 0 0];
A_surf = [Ly*Lz; Lx*Lz; Lx*Ly; Ly*Lz; Lx*Lz; Lx*Ly; ...
          A_panel; A_panel; A_panel; A_panel];
R_CP_geom = [Lx/2 0 0; 0 Ly/2 0; 0 0 Lz/2; ...
            -Lx/2 0 0; 0 -Ly/2 0; 0 0 -Lz/2; ...
             0 d_panel 0; 0 d_panel 0; 0 -d_panel 0; 0 -d_panel 0]';

rho = 1.315e-13; % kg/m^3
CD = 2.2;
r_CM = [0.002;0;0.001]; % m

model = 'AirDragValidation';
load_system(model)

rho0 = rho; CD0 = CD; e0 = e;
n_earth0 = n_earth; Q0 = R_PQW_to_N; r_CM0 = r_CM;
atol = 1e-15; rtol = 1e-4;

%% Analytical tests: circular equatorial orbit, no Earth rotation
e = 0;
n_earth = 0;
R_PQW_to_N = eye(3);
theta_in = 0;
r_N_in = [R;0;0];
A_BN_in = eye(3);

% Velocity along +Y, drag along -Y
F = 0.5*rho0*CD0*(sqrt(mu_earth/R)*1e3)^2*Lx*Lz;
tau_Y = F*[-r_CM0(3);0;r_CM0(1)];

names = {'Zero density','Zero CoM offset','Velocity along Y', ...
         'Double density','Double CD','Reverse CoM offset'};
rhos = rho0*[0 1 1 2 1 1];
CDs = CD0*[1 1 1 1 2 1];
CMs = [r_CM0 zeros(3,1) r_CM0 r_CM0 r_CM0 -r_CM0];
expected = [zeros(3,2) tau_Y 2*tau_Y 2*tau_Y -tau_Y];
actual = zeros(3,length(names));
passed = false(1,length(names));

fprintf('Analytical tests\n')
for k = 1:length(names)
    rho = rhos(k);
    CD = CDs(k);
    r_CM = CMs(:,k);
    r_CM_mat = repmat(r_CM,1,10);
    actual(:,k) = run_drag(model);
    err = norm(actual(:,k)-expected(:,k));
    passed(k) = err <= atol + rtol*norm(expected(:,k));
    fprintf('%-22s error = %.3e Nm   pass = %d\n',names{k},err,passed(k))
end

figure
bar(1:length(names),[expected(:,:) ; actual(:,:)]')
set(gca,'XTick',1:length(names),'XTickLabel',names)
xtickangle(25)
ylabel('Torque [Nm]')
legend('Ref X','Ref Y','Ref Z','Sim X','Sim Y','Sim Z')
grid on

%% Density sweep
CD = CD0; r_CM = r_CM0;
r_CM_mat = repmat(r_CM,1,10);
factor = 0:0.5:3;
tau_rho = zeros(size(factor));
for k = 1:length(factor)
    rho = rho0*factor(k);
    tau_rho(k) = norm(run_drag(model));
end
rho_ref = factor*norm(tau_Y);
rho_err = abs(tau_rho-rho_ref);
fprintf('Density sweep passed: %d/%d\n', ...
    sum(rho_err <= atol + rtol*rho_ref),length(factor))

figure
plot(factor,factor*norm(tau_Y),'k-',factor,tau_rho,'ro')
xlabel('Density / nominal density')
ylabel('Torque magnitude [Nm]')
legend('Analytical','Simulink','Location','best')
grid on

%% Nominal orbit: ideal dawn-dusk sun pointing
rho = rho0; CD = CD0; e = e0;
n_earth = n_earth0; R_PQW_to_N = Q0;
r_CM = r_CM0;
r_CM_mat = repmat(r_CM,1,10);

% Body X points along the orbit normal; body Y along PQW X
xB = R_PQW_to_N(:,3);
yB = R_PQW_to_N(:,1);
zB = cross(xB,yB);
A_BN_in = [xB'; yB'; zB'];

p = R*(1-e^2);
theta_deg = 0:5:360;
tau_ref = zeros(3,length(theta_deg));
tau_sim = tau_ref;

for k = 1:length(theta_deg)
    theta_in = deg2rad(theta_deg(k));
    r = p/(1+e*cos(theta_in));
    r_N_in = R_PQW_to_N*[r*cos(theta_in); r*sin(theta_in); 0];

    v_N = R_PQW_to_N*sqrt(mu_earth/p)* ...
          [-sin(theta_in); e+cos(theta_in); 0];
    v_rel = 1e3*A_BN_in*(v_N-cross([0;0;n_earth],r_N_in));
    v = norm(v_rel);
    u = v_rel/v;

    for j = 1:10
        A_eff = A_surf(j)*max(0,N_surf(j,:)*u);
        F_drag = -0.5*rho*CD*v^2*A_eff*u;
        tau_ref(:,k) = tau_ref(:,k)+cross(R_CP_geom(:,j)-r_CM,F_drag);
    end
    tau_sim(:,k) = run_drag(model);
end

err = vecnorm(tau_sim-tau_ref);
ref_norm = vecnorm(tau_ref);
limit = atol + rtol*ref_norm;
valid = ref_norm > atol;
rel_err = nan(size(err));
rel_err(valid) = 100*err(valid)./ref_norm(valid);

fprintf('\nFull orbit verification\n')
fprintf('Max absolute error: %.3e Nm\n',max(err))
if any(valid)
    fprintf('Max relative error: %.3e %%\n',max(rel_err(valid)))
end
fprintf('Orbit points passed: %d/%d\n',sum(err <= limit),length(err))
fprintf('All analytical tests passed: %d\n',all(passed))

figure
labels = {'T_x [Nm]','T_y [Nm]','T_z [Nm]'};
for j = 1:3
    subplot(3,1,j)
    plot(theta_deg,tau_ref(j,:),'k-',theta_deg,tau_sim(j,:),'r.')
    ylabel(labels{j})
    xlim([0 360]); grid on
    if j == 1
        legend('MATLAB','Simulink','Location','best')
    end
end
xlabel('True anomaly [deg]')

figure
plot(theta_deg,err,'b-',theta_deg,limit,'k--')
xlabel('True anomaly [deg]')
ylabel('Absolute error [Nm]')
legend('Error','Tolerance','Location','best')
xlim([0 360]); grid on

%% Air drag torque validation

rho = rho0;
CD = CD0;
e = e0;
n_earth = n_earth0;
R_PQW_to_N = Q0;
r_CM = r_CM0;
r_CM_mat = repmat(r_CM,1,10);

theta_in = deg2rad(45);

% Orbital position and velocity
p = R*(1-e^2);
r = p/(1+e*cos(theta_in));

r_N_in = R_PQW_to_N*[r*cos(theta_in); r*sin(theta_in); 0];

v_N = R_PQW_to_N*sqrt(mu_earth/p)* ...
    [-sin(theta_in); e+cos(theta_in); 0];

% Relative velocity in body frame [m/s]
v_rel = 1e3*A_BN_in*(v_N-cross([0;0;n_earth],r_N_in));
v = norm(v_rel);
u = v_rel/v;

% Analytical torque
tau_analytical = zeros(3,1);

for j = 1:10
    A_eff = A_surf(j)*max(0,N_surf(j,:)*u);
    F = -0.5*rho*CD*v^2*A_eff*u;
    tau_analytical = tau_analytical + cross(R_CP_geom(:,j)-r_CM,F);
end

% Simulink torque
tau_simulink = run_drag(model);

% Results
fprintf('\nAir drag torque [Nm]\n')
fprintf('Analytical: [% .4e  % .4e  % .4e]\n',tau_analytical)
fprintf('Simulink:   [% .4e  % .4e  % .4e]\n',tau_simulink)

%% Simulink output at the last time sample
function tau = run_drag(model)
    out = sim(model,'StopTime','1','ReturnWorkspaceOutputs','on');
    ts = out.tau_out;
    tau = squeeze(getdatasamples(ts,numel(ts.Time)));
    tau = tau(:);
    assert(numel(tau)==3 && all(isfinite(tau)), 'Invalid torque output')
end
