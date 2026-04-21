function [v_ref, dist, scenario_name] = scenarios(scenario_id, p)
% SCENARIOS  Generate reference velocity profiles and disturbances
%
% Scenario IDs:
%   1 - Sudden start and stop (step command)
%   2 - Speed bump / threshold crossing (impulse disturbance)
%   3 - Repeated acceleration/deceleration
%   4 - External push while moving
%   5 - Rough terrain (random disturbances)

N = round(p.T / p.dt);
t = (0:N-1) * p.dt;

dist.time  = t;
dist.force = zeros(1, N);

switch scenario_id

    case 1
        %% Scenario 1: Sudden start and stop
        scenario_name = 'Sudden Start and Stop';
        v_ref = zeros(N, 1);
        % Start at t=2s, stop at t=15s, start again at t=20s, stop at t=28s
        v_ref(t >= 2 & t < 8)   = 0.6;   % 0.6 m/s forward (sharp launch)
        v_ref(t >= 20 & t < 28) = 0.3;   % 0.3 m/s forward

    case 2
        %% Scenario 2: Speed bump / threshold crossing
        scenario_name = 'Threshold Crossing (Speed Bump)';
        v_ref = 0.4 * ones(N, 1);
        v_ref(t < 2) = 0;  % start after 2s

        % Impulse disturbances simulating bumps
        bump_times = [5, 12, 20];  % times of bumps [s]
        bump_width = 0.1;          % bump duration [s]
        bump_force = 15;           % bump force magnitude [N]

        for i = 1:length(bump_times)
            bump_mask = (t >= bump_times(i)) & ...
                        (t < bump_times(i) + bump_width);
            dist.force(bump_mask) = bump_force;
        end

    case 3
        %% Scenario 3: Repeated acceleration/deceleration
        scenario_name = 'Repeated Accel/Decel (Delivery Path)';
        v_ref = zeros(N, 1);
        % Simulate a delivery path with multiple speed changes
        v_ref(t >= 2  & t < 5)  = 0.5;
        v_ref(t >= 5  & t < 7)  = 0.2;   % slow down
        v_ref(t >= 7  & t < 10) = 0.6;   % speed up
        v_ref(t >= 10 & t < 12) = 0.0;   % stop (obstacle)
        v_ref(t >= 12 & t < 15) = 0.4;   % resume
        v_ref(t >= 15 & t < 18) = 0.7;   % fast section
        v_ref(t >= 18 & t < 22) = 0.3;   % approach destination
        v_ref(t >= 22 & t < 25) = 0.1;   % final approach
        v_ref(t >= 25)          = 0.0;   % stop at destination

    case 4
        %% Scenario 4: External push while moving
        scenario_name = 'External Push During Motion';
        v_ref = 0.4 * ones(N, 1);
        v_ref(t < 2) = 0;

        % Push events
        % Push 1: strong push at t=5s (like a person bumping)
        push1 = (t >= 5) & (t < 8);
        dist.force(push1) = 10;

        % Push 2: release at t=8s
        % Push 3: another push at t=15s
        push3 = (t >= 15) & (t < 18);
        dist.force(push3) = -8;  % push from opposite direction

        % Push 4: quick tap at t=23s
        push4 = (t >= 23) & (t < 23.5);
        dist.force(push4) = 20;

    case 5
        %% Scenario 5: Rough terrain (random vibrations)
        scenario_name = 'Rough Terrain (Random Disturbances)';
        v_ref = 0.3 * ones(N, 1);
        v_ref(t < 2) = 0;
        v_ref(t > 25) = 0;

        % Random terrain disturbance (band-limited noise)
        rng(42);  % reproducible
        noise = randn(1, N) * 3;
        % Band-limit to 1-10 Hz
        [b_bp, a_bp] = butter(2, [1, 10] / (1/(2*p.dt)), 'bandpass');
        dist.force = filter(b_bp, a_bp, noise);
        % Only active when robot is moving
        dist.force(t < 3 | t > 26) = 0;

    otherwise
        error('Unknown scenario ID: %d', scenario_id);
end

fprintf('Scenario %d: %s (T=%.1fs, N=%d steps)\n', ...
    scenario_id, scenario_name, p.T, N);

end
