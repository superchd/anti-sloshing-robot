%% MAKE_TABLE3  Reproduce Choi et al. Table 3:
%   Comparison of pendulum swing angles with and without SBSFC,
%   averaged over multiple runs (scenarios).
%
% Outputs:
%   - formatted table in the command window
%   - results/table3.txt  (plain-text copy)
%   - results/table3.csv  (machine-readable)

clear; close all; clc;

p = parameters();

scenarios_to_run = 1;           % Scenario 1 only (sudden start/stop)
n_runs = length(scenarios_to_run);

abs_mean_sbsfc = zeros(n_runs, 1);
var_sbsfc      = zeros(n_runs, 1);
abs_mean_lpf   = zeros(n_runs, 1);
var_lpf        = zeros(n_runs, 1);

fprintf('\nRunning %d scenarios × 2 modes = %d simulations...\n\n', ...
        n_runs, 2*n_runs);

for i = 1:n_runs
    sid = scenarios_to_run(i);
    [v_ref, dist, ~] = scenarios(sid, p);

    res_sbsfc = simulate_system(v_ref, p, 'sbsfc', dist);
    res_lpf   = simulate_system(v_ref, p, 'lpf',   dist);

    abs_mean_sbsfc(i) = rad2deg(mean(abs(res_sbsfc.theta)));
    var_sbsfc(i)      = rad2deg(std(res_sbsfc.theta))^2;   % deg^2
    abs_mean_lpf(i)   = rad2deg(mean(abs(res_lpf.theta)));
    var_lpf(i)        = rad2deg(std(res_lpf.theta))^2;
end

mean_theta_sbsfc = mean(abs_mean_sbsfc);
mean_theta_lpf   = mean(abs_mean_lpf);
var_theta_sbsfc  = mean(var_sbsfc);
var_theta_lpf    = mean(var_lpf);

%% Print table
header = sprintf('\n%s\n', repmat('═', 1, 62));
line   = sprintf('%s\n',   repmat('─', 1, 62));

out = {};
out{end+1} = header;
out{end+1} = sprintf('  Table 3.  Comparison of pendulum swing angles\n');
out{end+1} = sprintf('            with and without SBSFC.\n');
out{end+1} = header;
out{end+1} = sprintf('  %-28s  %14s  %14s\n', 'Value', 'With SBSFC', 'Without SBSFC');
out{end+1} = line;
out{end+1} = sprintf('  %-28s  %14.4f  %14.4f\n', ...
                    'Mean ( |θ| [degree] )', mean_theta_sbsfc, mean_theta_lpf);
out{end+1} = sprintf('  %-28s  %14.4f  %14.4f\n', ...
                    'Variance ( θ [degree²] )', var_theta_sbsfc, var_theta_lpf);
out{end+1} = line;
if n_runs == 1
    out{end+1} = sprintf('  *Results from Scenario %d only.\n', scenarios_to_run(1));
else
    out{end+1} = sprintf('  *All results are averaged over %d runs.\n', n_runs);
end
out{end+1} = header;
out{end+1} = sprintf('\n  Reduction: Mean  = %.1f%% ,  Variance = %.1f%%\n\n', ...
            (1 - mean_theta_sbsfc/mean_theta_lpf)*100, ...
            (1 - var_theta_sbsfc  /var_theta_lpf  )*100);

fprintf('%s', out{:});

%% Save plain-text copy
if ~exist('../results', 'dir'), mkdir('../results'); end
fid = fopen('../results/table3.txt', 'w');
for i = 1:length(out), fprintf(fid, '%s', out{i}); end
fclose(fid);

%% Save CSV
fid = fopen('../results/table3.csv', 'w');
fprintf(fid, 'Value,With SBSFC,Without SBSFC\n');
fprintf(fid, 'Mean |theta| [deg],%.6f,%.6f\n', mean_theta_sbsfc, mean_theta_lpf);
fprintf(fid, 'Variance theta [deg^2],%.6f,%.6f\n', var_theta_sbsfc, var_theta_lpf);
fclose(fid);

fprintf('Saved: ../results/table3.txt\n');
fprintf('Saved: ../results/table3.csv\n');

%% Render table as a figure (paper-style)
fig = figure('Position', [200 200 720 320], 'Color', 'w', ...
             'Name', 'Table 3');
ax = axes('Position', [0 0 1 1]); axis off; hold on;
xlim([0 1]); ylim([0 1]);

% Top border (thin double line feel)
plot([0.04 0.96], [0.88 0.88], 'k-', 'LineWidth', 1.2);
plot([0.04 0.96], [0.885 0.885], 'k-', 'LineWidth', 0.6);

% "Table 3" label
text(0.04, 0.955, 'Table 3', 'FontSize', 16, 'FontWeight', 'bold', ...
     'FontName', 'Times New Roman');

% Caption
text(0.04, 0.915, 'Comparison of pendulum swing angles with and without SBSFC.', ...
     'FontSize', 12, 'FontName', 'Times New Roman');

% Column headers
text(0.07, 0.83, 'Value',          'FontSize', 12, 'FontName', 'Times New Roman');
text(0.54, 0.83, 'With SBSFC',     'FontSize', 12, 'FontName', 'Times New Roman');
text(0.80, 0.83, 'Without SBSFC',  'FontSize', 12, 'FontName', 'Times New Roman');

% Header bottom line
plot([0.04 0.96], [0.78 0.78], 'k-', 'LineWidth', 0.8);

% Row 1: Mean
text(0.07, 0.68, 'Mean ( |\theta| [degree] )', ...
     'FontSize', 12, 'FontName', 'Times New Roman');
text(0.57, 0.68, sprintf('%.4f', mean_theta_sbsfc), ...
     'FontSize', 12, 'FontName', 'Times New Roman');
text(0.83, 0.68, sprintf('%.4f', mean_theta_lpf), ...
     'FontSize', 12, 'FontName', 'Times New Roman');

% Row 2: Variance
text(0.07, 0.55, 'Variance ( \theta [degree] )', ...
     'FontSize', 12, 'FontName', 'Times New Roman');
text(0.57, 0.55, sprintf('%.4f', var_theta_sbsfc), ...
     'FontSize', 12, 'FontName', 'Times New Roman');
text(0.83, 0.55, sprintf('%.4f', var_theta_lpf), ...
     'FontSize', 12, 'FontName', 'Times New Roman');

% Bottom border
plot([0.04 0.96], [0.43 0.43], 'k-', 'LineWidth', 0.8);

% Footnote
if n_runs == 1
    footnote_str = sprintf('*Results from Scenario %d only.', scenarios_to_run(1));
else
    footnote_str = sprintf('*All results are averaged over %d runs.', n_runs);
end
text(0.04, 0.34, footnote_str, ...
     'FontSize', 11, 'FontName', 'Times New Roman', 'FontAngle', 'italic');

% Reduction annotation (below paper layout)
text(0.04, 0.18, ...
    sprintf('Reduction:   Mean = %.1f%%    Variance = %.1f%%', ...
            (1 - mean_theta_sbsfc/mean_theta_lpf)*100, ...
            (1 - var_theta_sbsfc  /var_theta_lpf  )*100), ...
    'FontSize', 12, 'FontName', 'Times New Roman', ...
    'FontWeight', 'bold', 'Color', [0 0.5 0]);

% Save as PNG
saveas(fig, '../results/table3.png');
fprintf('Saved: ../results/table3.png\n');
