function [InitialObservation, LoggedSignals] = rl_reset()
% RL_RESET  Episode reset with domain randomization.
%
% Returns:
%   InitialObservation - 7x1 observation vector
%   LoggedSignals      - episode state carried between steps

    p = parameters();

    % --- Domain randomization (the key to generalization) ---
    % Pendulum length -> changes omega_f in [~7.0, ~9.0] rad/s
    p.pend_l   = 0.15 * (0.85 + 0.30 * rand());
    p.omega_f  = sqrt(p.g / p.pend_l);

    % Pendulum damping (liquid viscosity / fill level proxy)
    p.pend_b   = 0.001 * (0.5 + 1.5 * rand());

    % Total mass (fill level)
    p.m        = 42.0 * (0.90 + 0.20 * rand());

    % Small initial perturbation so agent sees varied starts
    psi0     = 0.02 * (2*rand()-1);
    psi_dot0 = 0.05 * (2*rand()-1);
    theta0   = 0.05 * (2*rand()-1);

    s = [psi0; psi_dot0; 0; 0; theta0; 0];

    % --- Reference velocity profile (random step sequence) ---
    %   Train on randomized short step profiles; evaluate on full scenarios.
    T_ep    = 10.0;               % episode length [s]
    N       = round(T_ep / p.dt);
    v_ref   = zeros(N, 1);
    t_on    = 1.0 + 3.0 * rand();        % random on-time
    t_off   = t_on + 3.0 + 3.0 * rand(); % random off-time
    v_amp   = 0.3 + 0.6 * rand();        % random amplitude [0.3, 0.9] m/s
    idx_on  = round(t_on  / p.dt);
    idx_off = min(round(t_off / p.dt), N);
    v_ref(idx_on:idx_off) = v_amp;

    % --- Pre-compute state-space (once per episode, not every step) ---
    [A, B] = build_state_space(p);

    % --- Package ---
    LoggedSignals.A       = A;
    LoggedSignals.B       = B;
    LoggedSignals.p       = p;
    LoggedSignals.s       = s;
    LoggedSignals.v_ref   = v_ref;
    LoggedSignals.k       = 1;       % current step index (physics steps)
    LoggedSignals.N       = N;
    LoggedSignals.last_u  = 0;

    InitialObservation = build_obs(s, v_ref(1));
end


function obs = build_obs(s, v_ref_now)
    obs = [s; v_ref_now];
end
