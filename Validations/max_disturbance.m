clc; clear all;

init

%% 1. Orbital Parameters
e         = 0.0011;         % Eccentricity
i_deg     = 97.75;              % Inclination [deg]
i_rad     = deg2rad(i_deg);     % Inclination [rad]
LTDN      = NaN;                % Local Time on Descending Node [hr]

V     = sqrt(mu_earth / R);       % Nominal circular orbital speed [m/s]

%% 2. Spacecraft Inertia & Geometry
delta_I     = max([Ix, Iy, Iz]) - min([Ix, Iy, Iz]);
As          = 0.03;                 % Max cross-sectional area [m^2]

%% 4. Maximum Disturbance Torques [N*m]
T_aero_max = 0.5 * rho * (V^2) * As * CD * offset;
T_mag_max  = Ds * B_max;
T_gg_max   = (3 * mu_earth / (2 * R^3)) * delta_I;
T_srp_max  = Ps * As * (1 + q) * offset;

%% 5. Display Summary
torques = [T_aero_max, T_mag_max, T_gg_max, T_srp_max];
labels  = {'Aerodynamic Drag', 'Magnetic Field', 'Gravity Gradient', 'Solar Radiation Pressure'};
[sorted_T, idx] = sort(torques, 'descend');

for k = 1:numel(torques)
    fprintf('%d. %-26s : %.4e N*m\n', k, labels{idx(k)}, sorted_T(k));
end