%% RUN_ANIMATION  Run a scenario and show 2D animation
%
% The robot moves at normal speed, then suddenly stops.
% Watch the pendulum (liquid) slosh!
%
% Usage: Just run this script in MATLAB.

clear; close all; clc;

%% Settings,
scenario_id  = 1;        % 1 = Sudden start and stop
control_mode = 'sbsfc';  % 'none', 'lpf', or 'sbsfc'
speed_factor = 3;        % 3x real-time (lower = slower animation)

%% Run simulation
p = parameters();
[v_ref, dist, scenario_name] = scenarios(scenario_id, p);
results = simulate_system(v_ref, p, control_mode, dist);

%% Animate
label = sprintf('%s  [%s]', scenario_name, upper(control_mode));
animate_2d(results, label, speed_factor);
