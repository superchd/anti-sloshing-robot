function [Observation, Reward, IsDone, LoggedSignals] = rl_step(Action, LoggedSignals)
% RL_STEP  Advance the env by one RL decision (multiple physics substeps).
%
% Action: scalar x_ddot command in [-u_max, u_max]
% Observation: 7x1 [psi, psi_dot, x, x_dot, theta, theta_dot, v_ref]

    p       = LoggedSignals.p;
    s       = LoggedSignals.s;
    v_ref   = LoggedSignals.v_ref;
    k       = LoggedSignals.k;
    N       = LoggedSignals.N;
    A       = LoggedSignals.A;
    B       = LoggedSignals.B;

    u_max     = 4.0;                          % [m/s^2] action clamp
    u         = max(-u_max, min(u_max, Action(1)));
    substeps  = 10;                           % RL at 100 Hz, physics at 1 kHz

    % --- Run N_sub physics substeps with the same action ---
    psi_pen = 0; theta_pen = 0; track_pen = 0;
    for i = 1:substeps
        if k > N, break; end
        s = plant_step(s, u, p, 0, A, B);
        psi_pen   = psi_pen   + s(1)^2;
        theta_pen = theta_pen + s(5)^2;
        track_pen = track_pen + (s(4) - v_ref(k))^2;
        k = k + 1;
    end

    % --- Reward (smaller is better -> negated) ---
    %   weights chosen so theta (slosh) dominates, balance is hard constraint
    a_theta   = 50.0;
    a_psi     = 20.0;
    a_track   =  2.0;
    a_du      =  0.05;
    du        = u - LoggedSignals.last_u;

    Reward = - (a_theta * theta_pen ...
              + a_psi   * psi_pen ...
              + a_track * track_pen ...
              + a_du    * du^2);

    % --- Termination: robot fell over ---
    IsDone = false;
    if abs(s(1)) > 0.35              % |psi| > 20 deg
        IsDone = true;
        Reward = Reward - 100;       % big penalty for falling
    end
    if k > N
        IsDone = true;
    end

    LoggedSignals.s      = s;
    LoggedSignals.k      = k;
    LoggedSignals.last_u = u;

    v_ref_now = v_ref(min(k, N));
    Observation = [s; v_ref_now];
end
