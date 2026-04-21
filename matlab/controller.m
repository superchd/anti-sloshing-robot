function [u_total, ctrl_state] = controller(q, pend, v_d_k, t_k, d_ext, p, ctrl_state, control_mode)
% CONTROLLER  Compute control input for the serving robot
%
% This file is the interface for all control methods.
% Teammate: implement your controller here.
%
% ========== INPUTS ==========
%   q           - robot state [psi; psi_dot; x; x_dot]  (4x1)
%   pend        - pendulum state [theta; theta_dot]      (2x1)
%   v_d_k       - desired velocity at this time step     (scalar)
%   t_k         - current time [s]                       (scalar)
%   d_ext       - external disturbance force [N]         (scalar)
%   p           - parameters struct (from parameters.m)
%   ctrl_state  - persistent controller state (struct, you can add fields)
%   control_mode - string: 'none', 'lpf', 'sbsfc', 'rl', etc.
%
% ========== OUTPUTS ==========
%   u_total     - total acceleration command [m/s^2]     (scalar)
%   ctrl_state  - updated controller state (pass back for next step)
%
% ========== AVAILABLE STATES ==========
%   q(1) = psi       : robot pitch angle [rad]
%   q(2) = psi_dot   : robot pitch angular velocity [rad/s]
%   q(3) = x         : robot position [m]
%   q(4) = x_dot     : robot velocity [m/s]
%   pend(1) = theta     : pendulum angle (sloshing) [rad]
%   pend(2) = theta_dot : pendulum angular velocity [rad/s]
%
% ========== HOW TO ADD A NEW CONTROLLER ==========
%   1. Add a new case in the switch block below
%   2. Use ctrl_state to store any persistent variables
%   3. Return u_total (scalar acceleration command)

% Build desired state
q_d = [0; 0; ctrl_state.x_d_integral; v_d_k];

switch control_mode

    case 'none'
        % No control
        u_total = 0;

    case 'lpf'
        % LQT control only (reference filtered externally)
        u_total = ctrl_state.K * q - ctrl_state.K_track * q_d;

    case 'sbsfc'
        % Full SBSFC: LQT + Auxiliary Compensator + DOB

        % LQT (Eq. 3)
        u_lqt = ctrl_state.K * q - ctrl_state.K_track * q_d;

        % Auxiliary compensator (Eq. 4)
        psi_L = q(1) * 0.8;
        dpsi_L = (psi_L - ctrl_state.psi_L_prev) / p.dt;
        ctrl_state.psi_L_prev = psi_L;
        ctrl_state.psi_L_filtered = ctrl_state.alpha_lpf * dpsi_L + ...
            (1 - ctrl_state.alpha_lpf) * ctrl_state.psi_L_filtered;
        u_aux = p.K_c * sign(ctrl_state.psi_L_filtered);

        % DOB (scalar disturbance estimator)
        % The disturbance enters as: d_vec = [0; dF/I_p; 0; dF/m]
        % NOT through B. So we estimate the scalar force dF, not a 4-vector.
        %
        % From psi_dot equation: psi_ddot = A(2,:)*q + B(2)*u + dF/I_p
        % So: dF = I_p * (psi_ddot_actual - A(2,:)*q - B(2)*u)
        %
        % We estimate psi_ddot from the state derivative:
        q_dot_est = ctrl_state.A * q + ctrl_state.B * u_lqt;
        residual  = (q(2) - ctrl_state.q2_prev) / p.dt - q_dot_est(2);
        ctrl_state.q2_prev = q(2);

        % Low-pass filter the disturbance estimate (avoid noise amplification)
        alpha_dob = p.eta * p.dt / (1 + p.eta * p.dt);
        ctrl_state.d_hat_scalar = (1 - alpha_dob) * ctrl_state.d_hat_scalar ...
                                  + alpha_dob * (p.I_p * residual);

        % Compensate: cancel disturbance's effect on acceleration
        u_dob = -ctrl_state.d_hat_scalar / p.m;
        u_dob = max(min(u_dob, 5), -5);

        u_total = u_lqt + u_aux + u_dob;

    % ============================================================
    %  ADD YOUR CONTROLLER BELOW
    % ============================================================

    % case 'rl'
    %     % Reinforcement Learning controller
    %     % observation = [q; pend; v_d_k; d_ext];  % example
    %     % u_total = rl_agent(observation);
    %     u_total = 0;  % placeholder

    % case 'mpc'
    %     % Model Predictive Control
    %     u_total = 0;  % placeholder

    % case 'pid'
    %     % PID controller
    %     u_total = 0;  % placeholder

    otherwise
        error('Unknown control_mode: %s', control_mode);
end

% Update position integral for next step
ctrl_state.x_d_integral = ctrl_state.x_d_integral + v_d_k * p.dt;

end
