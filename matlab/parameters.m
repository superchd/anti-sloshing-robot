function p = parameters()
% PARAMETERS  Shared robot and control parameters
% Based on: Choi et al., "Suppressing violent sloshing flow in food
% serving robots," Robotics and Autonomous Systems, 2024.

%% Robot physical parameters (Table 1, Section 5.1)
p.m_s = 38.0;           % mass of robot body [kg]
p.m   = 42.0;           % total mass (robot + load) [kg]
p.l   = 0.95;           % height of robot [m]
p.r   = 0.08;           % wheel radius [m]
p.g   = 9.81;           % gravity [m/s^2]
p.I_w = 2.1504;         % yaw inertia moment [kg*m^2]
p.I_p = 13.7102;        % pitch inertia moment [kg*m^2]

%% Pendulum parameters (represents liquid sloshing)
p.pend_l = 0.15;        % pendulum length [m]
p.pend_m = 0.5;         % pendulum mass [kg]
p.pend_b = 0.001;       % pendulum damping [N*m*s/rad]

%% Sloshing model parameters
% MUST match the actual pendulum simulation, not the paper's experimental
% values (paper used a real liquid; we simulate a simple pendulum).
p.omega_f = sqrt(p.g / p.pend_l);          % = 8.085 rad/s for l=0.15
p.delta   = p.pend_b / (2 * p.pend_m * p.pend_l^2 * p.omega_f);  % = 0.055
% Paper values (for reference only): omega_f=9.922, delta=0.5

%% LQT control parameters (Section 5.1)
p.Q = diag([500, 50, 1, 1]);    % heavy penalty on tilt for realistic psi
p.R = 0.1;                       % input weighting

%% DOB parameter (Section 4.5)
p.eta = 10.0;           % DOB low-pass filter bandwidth [rad/s]
                        % Higher = faster response but more noise

%% Auxiliary compensator (Section 4.4)
p.K_c = 0.001;          % compensator gain

%% LPF cutoff for auxiliary compensator derivative
p.lpf_cutoff = 5.0;     % [Hz]

%% Simulation settings
p.dt = 0.001;           % time step [s]
p.T  = 30;              % default simulation duration [s]

end
