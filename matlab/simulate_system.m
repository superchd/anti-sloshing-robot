function results = simulate_system(v_ref, p, control_mode, disturbance)
% SIMULATE_SYSTEM  Run closed-loop simulation of serving robot + pendulum
%
% Inputs:
%   v_ref       - reference velocity profile (Nx1)
%   p           - parameters struct
%   control_mode - 'none', 'lpf', 'sbsfc', or any mode defined in controller.m
%   disturbance  - struct with fields .time, .force (external push)
%
% Outputs:
%   results - struct with time histories of all states and signals

if nargin < 4
    disturbance.time = [];
    disturbance.force = [];
end

%% Setup
dt = p.dt;
N  = length(v_ref);
t  = (0:N-1) * dt;

% Build plant model
[A, B] = build_state_space(p);

% Design LQT controller
[K, K_track] = design_lqt(A, B, p);

%% Apply input shaping if SBSFC mode
if strcmp(control_mode, 'sbsfc')
    v_d = input_shaping(v_ref, p);
else
    v_d = v_ref;
end

% If LPF mode, apply low-pass filter to reference
if strcmp(control_mode, 'lpf')
    fc = 1.5;  % raised closer to sloshing freq to make LPF limits visible
    [b_lpf, a_lpf] = butter(1, fc / (1/(2*dt)), 'low');
    v_d = filter(b_lpf, a_lpf, v_ref);
end

%% State initialization
q = zeros(4, 1);       % robot: [psi, psi_dot, x, x_dot]
pend = zeros(2, 1);    % pendulum: [theta, theta_dot]

%% Initialize controller state (persistent variables for controller.m)
ctrl_state.K       = K;
ctrl_state.K_track = K_track;
ctrl_state.A       = A;
ctrl_state.B       = B;
ctrl_state.xi      = zeros(4, 1);       % (legacy, unused)
ctrl_state.d_hat   = zeros(4, 1);       % (legacy, unused)
ctrl_state.d_hat_scalar = 0;            % scalar disturbance force estimate [N]
ctrl_state.q2_prev      = 0;            % previous psi_dot for derivative
ctrl_state.psi_L_prev     = 0;
ctrl_state.psi_L_filtered = 0;
ctrl_state.alpha_lpf = dt * p.lpf_cutoff * 2 * pi / (1 + dt * p.lpf_cutoff * 2 * pi);
ctrl_state.x_d_integral   = 0;

%% Preallocate output arrays
results.t         = t;
results.v_ref     = v_ref;
results.v_d       = v_d;
results.psi       = zeros(N, 1);
results.psi_dot   = zeros(N, 1);
results.x         = zeros(N, 1);
results.x_dot     = zeros(N, 1);
results.theta     = zeros(N, 1);
results.theta_dot = zeros(N, 1);
results.u_total   = zeros(N, 1);
results.d_ext     = zeros(N, 1);

%% Main simulation loop
for k = 1:N
    %% Compute external disturbance
    d_ext = 0;
    if ~isempty(disturbance.time)
        d_ext = interp1(disturbance.time, disturbance.force, t(k), ...
                        'linear', 0);
    end
    results.d_ext(k) = d_ext;

    %% Call controller
    [u_total, ctrl_state] = controller(q, pend, v_d(k), t(k), d_ext, p, ctrl_state, control_mode);

    %% Store results
    results.psi(k)       = q(1);
    results.psi_dot(k)   = q(2);
    results.x(k)         = q(3);
    results.x_dot(k)     = q(4);
    results.theta(k)     = pend(1);
    results.theta_dot(k) = pend(2);
    results.u_total(k)   = u_total;

    %% Propagate robot dynamics (Euler integration)
    d_vec = [0; d_ext / p.I_p; 0; d_ext / p.m];
    q_dot = A * q + B * u_total + d_vec;
    q = q + q_dot * dt;

    %% Propagate pendulum dynamics
    robot_accel = u_total + d_ext / p.m;
    theta     = pend(1);
    theta_dot = pend(2);

    theta_ddot = -(p.g / p.pend_l) * sin(theta) ...
                 - (p.pend_b / (p.pend_m * p.pend_l^2)) * theta_dot ...
                 + (1 / p.pend_l) * robot_accel * cos(theta);

    pend(1) = pend(1) + pend(2) * dt;
    pend(2) = pend(2) + theta_ddot * dt;
end

%% Summary metrics
results.theta_mean = mean(abs(results.theta));
results.theta_var  = var(results.theta);
results.theta_max  = max(abs(results.theta));
results.psi_mean   = mean(abs(results.psi));
results.psi_var    = var(results.psi);

fprintf('\n--- %s Results ---\n', upper(control_mode));
fprintf('  Pendulum |theta| : mean=%.4f deg, var=%.4f, max=%.4f deg\n', ...
    rad2deg(results.theta_mean), rad2deg(results.theta_var), ...
    rad2deg(results.theta_max));
fprintf('  Pitch |psi|      : mean=%.4f deg, var=%.4f\n', ...
    rad2deg(results.psi_mean), rad2deg(results.psi_var));

end
