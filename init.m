
%% Constants
G = 6.6743e-20; %km^3*kg^-1*s^-2
M_earth = 5.97*10^24; %Kg
mu_earth = 398600.435507; %Km^3/s^2
R_earth = 6371.2; %Km
n_earth = 7.292115e-5; %rad/s


%% Orbit

Altitude = 575; %km
R = R_earth + Altitude; %km

%% Simulation parameters
T_orb  = 2 * pi * sqrt(a^3 / mu_earth);   % Orbital period [s]
t_stop = 560 %1.05 * T_orb;                    % Just above 1 full orbit
dt_step = 0.1;



%% Dynamics
Ix = 0.044; %kg*m^2
Iy = 0.022;
Iz = 0.017;

I = diag([Ix, Iy, Iz]);
I_inv = inv(I);

wx0 = 0.1; %rad/s
wy0 = 0.01;
wz0 = 0.01;

wB0 =[wx0 wy0 wz0];


Ir = 0; %internal spin = 0
w0r = 0;
hr = [0; 0; Ir*w0r];


% starting Euler angles
phi0 = deg2rad(10); 
theta0 = deg2rad(0);
xi0 = deg2rad(0);
angles0 = [phi0, theta0, xi0];


%A_LN0 = diag([1, 1, 1]);
%A_BN0 = A_LN0;

%n = sqrt(G*Me/R^3);
%wL = [0; 0; n];

%% ENVIRONMENT

