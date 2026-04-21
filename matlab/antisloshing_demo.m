%% Anti-Sloshing Control for a Food-Serving Robot
% This example designs a Self-Balancing Slosh-Free Controller (SBSFC) to
% suppress liquid sloshing in a wheeled food-serving robot.
%
% Based on: Choi et al., "Suppressing violent sloshing flow in food serving
% robots," Robotics and Autonomous Systems 179 (2024) 104728.
%
% MECE 6397 — University of Houston

%% Robot and Sloshing Assembly
% The plant consists of two coupled subsystems:
%
% *Robot body* — a wheeled self-balancing platform modeled as an inverted
% pendulum on wheels. The state vector is:
%   q = [psi; psi_dot; x; x_dot]
% where _psi_ is the pitch angle and _x_ is the horizontal position.
% The control input _u_ is the longitudinal acceleration command (m/s^2).
%
% *Liquid sloshing* — approximated as a nonlinear pendulum hanging
% downward from the tray:
%   theta_ddot = -(g/l)*sin(theta) + (1/l)*u*cos(theta) - b*theta_dot/(m*l^2)
%
% *Key difference from the classical cart-pole problem:*
%
% * Cart-pole: pole points UPWARD — unstable equilibrium, goal is to
%   stabilize theta at 0.
%
% * Serving robot: sloshing pendulum hangs DOWNWARD — stable equilibrium,
%   gravity is a restoring force. Goal is to MINIMIZE theta excitation.
%
% * The two subsystems are loosely coupled (0.5 kg liquid vs 42 kg robot).
%   Robot motion excites sloshing, but sloshing does not affect robot body.

clear; close all; clc;
p = parameters();
fprintf('Robot total mass:      %.1f kg\n', p.m);
fprintf('Pendulum (sloshing) length: %.3f m\n', p.pend_l);
fprintf('Sloshing natural frequency: %.3f rad/s  (%.3f Hz)\n', ...
    p.omega_f, p.omega_f/(2*pi));

%% System Equations — Robot Body (Linear)
% The robot body dynamics are linearized around the upright equilibrium
% (psi = 0) using the Lagrangian formulation from Choi et al. Eq. 1:
%
%   q_dot = A*q + B*u + d
%
% where d = [0; dF/I_p; 0; dF/m] captures external disturbances dF
% (bumps, pushes).
[A, B] = build_state_space(p);

fprintf('\nA matrix:\n'); disp(A);
fprintf('B matrix:\n'); disp(B);

%% Plant Stability Analysis
% Examine the open-loop poles of the linearized robot body.
ev = eig(A);
fprintf('Open-loop eigenvalues:\n');
for i = 1:length(ev)
    if real(ev(i)) > 0
        fprintf('  lambda_%d = %+.4f  <-- UNSTABLE\n', i, ev(i));
    else
        fprintf('  lambda_%d = %+.4f\n', i, ev(i));
    end
end

%%
% The positive real eigenvalue confirms the robot body is open-loop
% unstable — it will tip over without active control, just like an
% inverted pendulum.  Active pitch stabilization is mandatory.

%% Control Objectives
% Assume the following initial conditions:
%
% * Robot is stationary at x = 0.
% * Pitch angle psi = 0 (upright).
% * Sloshing angle theta = 0 (liquid at rest).
%
% Control objectives:
%
% # Track a velocity reference v_ref(t) within a reasonable rise time.
% # Keep pitch deviation |psi| small during acceleration.
% # Minimize sloshing angle |theta| throughout motion.
% # Recover quickly after external disturbances (bumps, pushes).

%% Control Structure — SBSFC
% The SBSFC (Self-Balancing Slosh-Free Controller) uses four layers:
%
% * *Input Shaping* — Pre-filters v_ref to avoid exciting the sloshing
%   natural frequency (omega_f = 9.922 rad/s). This is equivalent to
%   what the MPC prediction horizon achieves in the cart-pole example,
%   but done explicitly.
%
% * *LQT (Linear Quadratic Tracking)* — State feedback controller that
%   tracks the shaped velocity reference while maintaining pitch stability.
%   Weights: Q = diag(5, 5, 0.1, 0.1), R = 0.01.
%
% * *DOB (Disturbance Observer)* — Estimates and cancels external
%   forces in real time (floor bumps, collisions).
%
% * *Auxiliary Compensator* — Small bang-bang term that damps residual
%   pitch oscillation after disturbances.
%
% u_total = u_lqt + u_dob + u_aux

[K, K_track] = design_lqt(A, B, p);
fprintf('\nLQT feedback gain K:\n  [%.4f  %.4f  %.4f  %.4f]\n', K);

%% Check Closed-Loop Stability
A_cl = A + B*K;
ev_cl = eig(A_cl);
fprintf('\nClosed-loop eigenvalues:\n');
for i = 1:length(ev_cl)
    fprintf('  lambda_%d = %+.4f + %+.4fi\n', i, real(ev_cl(i)), imag(ev_cl(i)));
end
assert(all(real(ev_cl) < 0), 'Closed-loop system is not stable!');
fprintf('All eigenvalues have negative real parts — system is STABLE.\n');

%% Scenario 1: Sudden Start and Stop
% A step velocity command: 0 → 0.5 m/s at t=2s, stop at t=15s.
% No external disturbance.
% This tests baseline sloshing suppression during acceleration/deceleration.

[v_ref, dist, sc_name] = scenarios(1, p);

fprintf('\nRunning Scenario 1: %s\n', sc_name);
fprintf('  Simulation: %.0f s at dt=%.4f s (%d steps)\n', p.T, p.dt, length(v_ref));

res_none  = simulate_system(v_ref, p, 'none',  dist);
res_lpf   = simulate_system(v_ref, p, 'lpf',   dist);
res_sbsfc = simulate_system(v_ref, p, 'sbsfc', dist);

%%
% Compare performance:
print_comparison_table(res_none, res_lpf, res_sbsfc, sc_name);

%%
% Plot state trajectories:
plot_results(res_none, res_lpf, res_sbsfc, sc_name, ...
    fullfile('..','results','demo_scenario1.png'));

%% Scenario 2: Speed Bump (Impulse Disturbance)
% The robot moves at constant 0.4 m/s and crosses three speed bumps
% (15 N impulse, 0.1 s each) at t = 5, 12, 20 s.
% This tests disturbance rejection — analogous to the "nudge" test in
% the MathWorks cart-pole example.

[v_ref2, dist2, sc_name2] = scenarios(2, p);

fprintf('\nRunning Scenario 2: %s\n', sc_name2);

res_none2  = simulate_system(v_ref2, p, 'none',  dist2);
res_lpf2   = simulate_system(v_ref2, p, 'lpf',   dist2);
res_sbsfc2 = simulate_system(v_ref2, p, 'sbsfc', dist2);

%%
print_comparison_table(res_none2, res_lpf2, res_sbsfc2, sc_name2);

%%
plot_results(res_none2, res_lpf2, res_sbsfc2, sc_name2, ...
    fullfile('..','results','demo_scenario2.png'));

%% Scenario 4: External Push During Motion
% A lateral push of 10 N is applied for 3 seconds while the robot moves.
% This is the most realistic disturbance scenario.

[v_ref4, dist4, sc_name4] = scenarios(4, p);

fprintf('\nRunning Scenario 4: %s\n', sc_name4);

res_none4  = simulate_system(v_ref4, p, 'none',  dist4);
res_lpf4   = simulate_system(v_ref4, p, 'lpf',   dist4);
res_sbsfc4 = simulate_system(v_ref4, p, 'sbsfc', dist4);

%%
print_comparison_table(res_none4, res_lpf4, res_sbsfc4, sc_name4);

%%
plot_results(res_none4, res_lpf4, res_sbsfc4, sc_name4, ...
    fullfile('..','results','demo_scenario4.png'));

%% Summary: SBSFC Sloshing Reduction Across Scenarios
fprintf('\n========== SBSFC Summary ==========\n');
fprintf('%-35s  %8s  %8s  %8s\n', 'Scenario', 'No Ctrl', 'LPF', 'SBSFC');
fprintf('%s\n', repmat('-', 1, 65));

results_all = {
    sc_name,  res_none,  res_lpf,  res_sbsfc;
    sc_name2, res_none2, res_lpf2, res_sbsfc2;
    sc_name4, res_none4, res_lpf4, res_sbsfc4;
};

for i = 1:size(results_all, 1)
    fprintf('%-35s  %7.3f°  %7.3f°  %7.3f°\n', ...
        results_all{i,1}(1:min(35,end)), ...
        rad2deg(results_all{i,2}.theta_mean), ...
        rad2deg(results_all{i,3}.theta_mean), ...
        rad2deg(results_all{i,4}.theta_mean));
end
fprintf('%s\n', repmat('=', 1, 65));

%% Discussion
% The SBSFC achieves significant sloshing reduction compared to no control
% and LPF, by explicitly addressing the sloshing dynamics through its
% four control layers.
%
% *Limitations of SBSFC (same as MPC limitations in cart-pole example):*
%
% # Designed for 1D (straight-line) motion only.
%   Turning scenarios introduce centripetal acceleration in the lateral
%   direction, which SBSFC cannot handle (no roll dynamics model).
%
% # Input shaping assumes fixed sloshing frequency (omega_f = 9.922 rad/s).
%   If the liquid fill level changes, omega_f changes and the shaper
%   becomes detuned.
%
% # DOB assumes a scalar disturbance model; real robots see
%   multi-axis forces.
%
% *Next step — Reinforcement Learning:*
%
% A DDPG or TD3 agent can learn to handle multi-axis disturbances
% (turning + bumps) without explicit knowledge of sloshing frequency,
% providing a more robust solution than SBSFC for complex scenarios.
% This is the key novelty of this project over prior work.

fprintf('\nDone. Results saved to ../results/\n');
fprintf('To publish this report: publish(''antisloshing_demo.m'', ''html'')\n');
