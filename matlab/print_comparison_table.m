function print_comparison_table(res_none, res_lpf, res_sbsfc, scenario_name)
% PRINT_COMPARISON_TABLE  Print performance metrics (like Tables 2-6 in paper)

fprintf('\n========================================================\n');
fprintf('  Performance Comparison: %s\n', scenario_name);
fprintf('========================================================\n');
fprintf('%-25s %12s %12s %12s\n', 'Metric', 'No Control', 'LPF', 'SBSFC');
fprintf('--------------------------------------------------------\n');

% Pendulum metrics
fprintf('%-25s %12.4f %12.4f %12.4f\n', '|theta| mean [deg]', ...
    rad2deg(res_none.theta_mean), rad2deg(res_lpf.theta_mean), ...
    rad2deg(res_sbsfc.theta_mean));

fprintf('%-25s %12.4f %12.4f %12.4f\n', 'theta var [deg^2]', ...
    rad2deg(res_none.theta_var), rad2deg(res_lpf.theta_var), ...
    rad2deg(res_sbsfc.theta_var));

fprintf('%-25s %12.4f %12.4f %12.4f\n', '|theta| max [deg]', ...
    rad2deg(res_none.theta_max), rad2deg(res_lpf.theta_max), ...
    rad2deg(res_sbsfc.theta_max));

% Robot pitch metrics
fprintf('%-25s %12.4f %12.4f %12.4f\n', '|psi| mean [deg]', ...
    rad2deg(res_none.psi_mean), rad2deg(res_lpf.psi_mean), ...
    rad2deg(res_sbsfc.psi_mean));

fprintf('%-25s %12.4f %12.4f %12.4f\n', 'psi var [deg^2]', ...
    rad2deg(res_none.psi_var), rad2deg(res_lpf.psi_var), ...
    rad2deg(res_sbsfc.psi_var));

% Improvement percentages
fprintf('--------------------------------------------------------\n');
fprintf('SBSFC improvement over LPF:\n');
fprintf('  Pendulum swing reduction: %.1f%%\n', ...
    (1 - res_sbsfc.theta_mean / res_lpf.theta_mean) * 100);
fprintf('  Pitch angle reduction:    %.1f%%\n', ...
    (1 - res_sbsfc.psi_mean / res_lpf.psi_mean) * 100);
fprintf('========================================================\n\n');

end
