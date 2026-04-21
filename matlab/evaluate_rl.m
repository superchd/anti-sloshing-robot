%% EVALUATE_RL  Run trained policy on Scenario 1 and compare vs SBSFC / LPF.

clear; close all; clc;

%% Load trained agent
S = load('../results/rl_agent_final.mat');
agent = S.agent;

p = parameters();

%% Reference: Scenario 1 (sudden start / stop)
scenario_id = 1;
[v_ref, dist, scenario_name] = scenarios(scenario_id, p);

%% Classical baselines
res_sbsfc = simulate_system(v_ref, p, 'sbsfc', dist);
res_lpf   = simulate_system(v_ref, p, 'lpf',   dist);

%% RL rollout
res_rl = rollout_rl(agent, v_ref, p);

%% Metrics
M = @(r) [rad2deg(mean(abs(r.theta))), rad2deg(std(r.theta))^2, ...
          rad2deg(max(abs(r.theta)))];

m_rl    = M(res_rl);
m_sbsfc = M(res_sbsfc);
m_lpf   = M(res_lpf);

fprintf('\n=========== Scenario 1 comparison ===========\n');
fprintf('%-10s | %10s | %10s | %10s\n', ...
        'Method', 'mean|θ|°', 'var θ°²', 'max|θ|°');
fprintf('-----------+------------+------------+-----------\n');
fprintf('%-10s | %10.4f | %10.4f | %10.4f\n', 'RL',    m_rl);
fprintf('%-10s | %10.4f | %10.4f | %10.4f\n', 'SBSFC', m_sbsfc);
fprintf('%-10s | %10.4f | %10.4f | %10.4f\n', 'LPF',   m_lpf);

%% Plot
t = res_rl.t;
figure('Position', [100 100 1000 550], 'Color', 'w');

subplot(3,1,1); hold on; grid on; box on;
plot(t, rad2deg(res_lpf.theta),   'r-', 'LineWidth', 1.4);
plot(t, rad2deg(res_sbsfc.theta), 'b-', 'LineWidth', 1.4);
plot(t, rad2deg(res_rl.theta),    'g-', 'LineWidth', 1.6);
ylabel('\theta [deg]'); legend('LPF','SBSFC','RL','Location','best');
title(['Scenario 1: ' scenario_name]);

subplot(3,1,2); hold on; grid on; box on;
plot(t, res_lpf.x_dot,   'r-', 'LineWidth', 1.2);
plot(t, res_sbsfc.x_dot, 'b-', 'LineWidth', 1.2);
plot(t, res_rl.x_dot,    'g-', 'LineWidth', 1.4);
plot(t, v_ref,           'k:', 'LineWidth', 1.2);
ylabel('dx/dt [m/s]'); legend('LPF','SBSFC','RL','v_{ref}');

subplot(3,1,3); hold on; grid on; box on;
plot(t, rad2deg(res_lpf.psi),   'r-');
plot(t, rad2deg(res_sbsfc.psi), 'b-');
plot(t, rad2deg(res_rl.psi),    'g-', 'LineWidth', 1.4);
ylabel('\psi [deg]'); xlabel('t [s]'); legend('LPF','SBSFC','RL');

if ~exist('../results','dir'), mkdir('../results'); end
saveas(gcf, '../results/rl_vs_sbsfc.png');
fprintf('Saved: ../results/rl_vs_sbsfc.png\n');


%% --- helper: roll out trained policy on fixed v_ref -----------------
function res = rollout_rl(agent, v_ref, p)
    N = length(v_ref);
    s = zeros(6,1);
    substeps = 10;
    [A, B] = build_state_space(p);

    res.t = (0:N-1)' * p.dt;
    res.v_ref = v_ref;
    res.psi = zeros(N,1); res.psi_dot = zeros(N,1);
    res.x = zeros(N,1);   res.x_dot   = zeros(N,1);
    res.theta = zeros(N,1); res.theta_dot = zeros(N,1);
    res.u_total = zeros(N,1);
    res.d_ext = zeros(N,1);  res.v_d = v_ref;

    k = 1;
    while k <= N
        obs = [s; v_ref(k)];
        u   = cell2mat(getAction(agent, {obs}));
        u   = max(-4, min(4, u(1)));

        for i = 1:substeps
            if k > N, break; end
            res.psi(k)=s(1); res.psi_dot(k)=s(2);
            res.x(k)=s(3);   res.x_dot(k)=s(4);
            res.theta(k)=s(5); res.theta_dot(k)=s(6);
            res.u_total(k)=u;
            s = plant_step(s, u, p, 0, A, B);
            k = k + 1;
        end
    end
end
