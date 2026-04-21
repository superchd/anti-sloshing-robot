%% MAIN_SIMULATION  Run all scenarios and compare control methods
%
% Self-Balancing Slosh-Free Control (SBSFC) Simulation
% Based on: Choi et al., "Suppressing violent sloshing flow in food
% serving robots," Robotics and Autonomous Systems, 2024.
%
% This script:
%   1. Loads parameters
%   2. Runs 5 scenarios x 3 control modes = 15 simulations
%   3. Generates comparison plots and performance tables
%
% Usage: Simply run this script in MATLAB.

clear; close all; clc;

%% Load parameters
p = parameters();
fprintf('=== SBSFC Simulation ===\n\n');

%% Select which scenarios to run (1-5, or 'all')
scenarios_to_run = [1, 2, 3, 4, 5];

%% Run each scenario
for s = scenarios_to_run
    fprintf('\n--- Running Scenario %d ---\n', s);

    % Generate scenario
    [v_ref, dist, scenario_name] = scenarios(s, p);

    % Run three control modes
    fprintf('\n[1/3] No control...\n');
    res_none  = simulate_system(v_ref, p, 'none', dist);

    fprintf('\n[2/3] LPF control...\n');
    res_lpf   = simulate_system(v_ref, p, 'lpf', dist);

    fprintf('\n[3/3] SBSFC...\n');
    res_sbsfc = simulate_system(v_ref, p, 'sbsfc', dist);

    % Print comparison table
    print_comparison_table(res_none, res_lpf, res_sbsfc, scenario_name);

    % Plot results
    save_file = fullfile('..', 'results', sprintf('scenario_%d.png', s));
    plot_results(res_none, res_lpf, res_sbsfc, scenario_name, save_file);
end

fprintf('\n=== All scenarios complete! ===\n');
fprintf('Figures saved to: ../results/\n');
