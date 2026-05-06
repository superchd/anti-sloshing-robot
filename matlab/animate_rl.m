%% ANIMATE_RL  Visualize the trained RL policy on a chosen scenario.
%
%   Loads results/rl_agent_final.mat, rolls the SAC actor out on the
%   selected scenario, and feeds the trajectory to animate_2d().
%
%   Usage:
%       animate_rl                  % Scenario 1 (default), 5x speed
%       animate_rl(2)               % Scenario 2, 5x speed
%       animate_rl(3, 1.0)          % Scenario 3, real-time
%
%   Controls in the figure:  Pause / Resume,  Restart,  Speed slider.

function animate_rl(scenario_id, speed_factor)

if nargin < 1, scenario_id  = 1; end
if nargin < 2, speed_factor = 5; end

%% Load trained agent
S = load('../results/rl_agent_final.mat');
agent = S.agent;
fprintf('Loaded RL agent from results/rl_agent_final.mat\n');

%% Build scenario
p = parameters();
[v_ref, dist, scenario_name] = scenarios(scenario_id, p);
fprintf('Scenario %d: %s\n', scenario_id, scenario_name);

%% Roll out the trained policy
fprintf('Rolling out RL policy...\n');
res = rollout_rl(agent, v_ref, dist, p);

%% Animate
animate_2d(res, sprintf('RL Controller — %s', scenario_name), speed_factor);

end


%% --- helper: roll out trained policy on the scenario -------------------
function res = rollout_rl(agent, v_ref, dist, p)
N = length(v_ref);
s = zeros(6,1);
substeps = 10;
[A, B] = build_state_space(p);

res.t       = (0:N-1)' * p.dt;
res.v_ref   = v_ref;
res.psi     = zeros(N,1); res.psi_dot   = zeros(N,1);
res.x       = zeros(N,1); res.x_dot     = zeros(N,1);
res.theta   = zeros(N,1); res.theta_dot = zeros(N,1);
res.u_total = zeros(N,1);
res.d_ext   = dist(:);
res.v_d     = v_ref;

k = 1;
while k <= N
    obs = [s; v_ref(k)];
    u   = cell2mat(getAction(agent, {obs}));
    u   = max(-4, min(4, u(1)));

    for i = 1:substeps
        if k > N, break; end
        res.psi(k)     = s(1); res.psi_dot(k)   = s(2);
        res.x(k)       = s(3); res.x_dot(k)     = s(4);
        res.theta(k)   = s(5); res.theta_dot(k) = s(6);
        res.u_total(k) = u;
        d_k            = dist(min(k, length(dist)));
        s              = plant_step(s, u, p, d_k, A, B);
        k              = k + 1;
    end
end
end
