%% Generate Results Summary for Presentation
%  Compares LPF vs SBSFC across all scenarios
%  Produces: bar chart, overlay plots, and prints a comparison table
%  Just click "Run" in MATLAB.

clear; close all; clc;
p = parameters();

%% Run all scenarios
scenario_ids   = [1, 2, 4];
scenario_names = {};
theta_mean_lpf   = [];
theta_mean_sbsfc = [];
theta_max_lpf    = [];
theta_max_sbsfc  = [];
psi_mean_lpf     = [];
psi_mean_sbsfc   = [];

for i = 1:length(scenario_ids)
    [v_ref, dist, name] = scenarios(scenario_ids(i), p);
    scenario_names{i} = name;

    res_lpf   = simulate_system(v_ref, p, 'lpf',   dist);
    res_sbsfc = simulate_system(v_ref, p, 'sbsfc', dist);

    theta_mean_lpf(i)   = rad2deg(res_lpf.theta_mean);
    theta_mean_sbsfc(i) = rad2deg(res_sbsfc.theta_mean);
    theta_max_lpf(i)    = rad2deg(res_lpf.theta_max);
    theta_max_sbsfc(i)  = rad2deg(res_sbsfc.theta_max);
    psi_mean_lpf(i)     = rad2deg(res_lpf.psi_mean);
    psi_mean_sbsfc(i)   = rad2deg(res_sbsfc.psi_mean);

    % Store results for overlay plot
    all_res_lpf{i}   = res_lpf;
    all_res_sbsfc{i} = res_sbsfc;
end

%% ══════════════════════════════════════════════════════════════════════════
%  FIGURE 1: Bar Chart — Mean Sloshing Angle Comparison
%% ══════════════════════════════════════════════════════════════════════════
fig1 = figure('Position', [50 100 900 500], 'Color', 'w');

% Short names for x-axis
short_names = {'Sudden Start', 'Speed Bumps', 'External Push'};

bar_data = [theta_mean_lpf; theta_mean_sbsfc]';
b = bar(bar_data, 'grouped');
b(1).FaceColor = [0.85 0.40 0.35];  % LPF = red
b(2).FaceColor = [0.25 0.70 0.40];  % SBSFC = green

set(gca, 'XTickLabel', short_names, 'FontSize', 12);
ylabel('Mean |\theta| [deg]', 'FontSize', 13);
title('Sloshing Comparison:  LPF  vs  SBSFC', 'FontSize', 16, 'FontWeight', 'bold');
legend({'LPF Only', 'SBSFC'}, 'FontSize', 12, 'Location', 'northwest');
grid on;

% Add percentage reduction labels on top of bars
for i = 1:length(scenario_ids)
    reduction = (1 - theta_mean_sbsfc(i) / theta_mean_lpf(i)) * 100;
    x_pos = i + 0.15;
    y_pos = max(theta_mean_lpf(i), theta_mean_sbsfc(i)) + 0.05;
    text(x_pos, y_pos, sprintf('-%.0f%%', reduction), ...
        'FontSize', 12, 'FontWeight', 'bold', 'Color', [0.1 0.5 0.2], ...
        'HorizontalAlignment', 'center');
end

saveas(fig1, fullfile('..', 'results', 'bar_chart_comparison.png'));
fprintf('\nSaved: results/bar_chart_comparison.png\n');

%% ══════════════════════════════════════════════════════════════════════════
%  FIGURE 2: Bar Chart — Peak Sloshing Angle
%% ══════════════════════════════════════════════════════════════════════════
fig2 = figure('Position', [50 100 900 500], 'Color', 'w');

bar_data2 = [theta_max_lpf; theta_max_sbsfc]';
b2 = bar(bar_data2, 'grouped');
b2(1).FaceColor = [0.85 0.40 0.35];
b2(2).FaceColor = [0.25 0.70 0.40];

set(gca, 'XTickLabel', short_names, 'FontSize', 12);
ylabel('Peak |\theta| [deg]', 'FontSize', 13);
title('Peak Sloshing:  LPF  vs  SBSFC', 'FontSize', 16, 'FontWeight', 'bold');
legend({'LPF Only', 'SBSFC'}, 'FontSize', 12, 'Location', 'northwest');
grid on;

for i = 1:length(scenario_ids)
    reduction = (1 - theta_max_sbsfc(i) / theta_max_lpf(i)) * 100;
    x_pos = i + 0.15;
    y_pos = max(theta_max_lpf(i), theta_max_sbsfc(i)) + 0.2;
    text(x_pos, y_pos, sprintf('-%.0f%%', reduction), ...
        'FontSize', 12, 'FontWeight', 'bold', 'Color', [0.1 0.5 0.2], ...
        'HorizontalAlignment', 'center');
end

saveas(fig2, fullfile('..', 'results', 'bar_chart_peak.png'));
fprintf('Saved: results/bar_chart_peak.png\n');

%% ══════════════════════════════════════════════════════════════════════════
%  FIGURE 3: Time-series overlay for each scenario
%% ══════════════════════════════════════════════════════════════════════════
fig3 = figure('Position', [50 50 1200 700], 'Color', 'w');

for i = 1:length(scenario_ids)
    subplot(length(scenario_ids), 1, i);
    hold on; grid on;

    t = all_res_lpf{i}.t;

    % Shaded area showing LPF sloshing envelope
    fill([t, fliplr(t)], ...
         [rad2deg(abs(all_res_lpf{i}.theta))', zeros(1, length(t))], ...
         [1.0 0.85 0.85], 'EdgeColor', 'none', 'FaceAlpha', 0.5);

    % LPF line
    plot(t, rad2deg(abs(all_res_lpf{i}.theta)), '-', ...
        'Color', [0.85 0.35 0.30], 'LineWidth', 2);

    % SBSFC line
    plot(t, rad2deg(abs(all_res_sbsfc{i}.theta)), '-', ...
        'Color', [0.20 0.65 0.35], 'LineWidth', 2.5);

    ylabel('|\theta| [deg]', 'FontSize', 11);
    title(short_names{i}, 'FontSize', 13, 'FontWeight', 'bold');

    if i == 1
        legend({'LPF envelope', 'LPF Only', 'SBSFC'}, ...
            'FontSize', 10, 'Location', 'northeast');
    end
    if i == length(scenario_ids)
        xlabel('Time [s]', 'FontSize', 11);
    end

    % Add reduction text
    reduction = (1 - theta_mean_sbsfc(i) / theta_mean_lpf(i)) * 100;
    yl = ylim;
    text(t(end)*0.75, yl(2)*0.8, ...
        sprintf('SBSFC reduces sloshing by %.0f%%', reduction), ...
        'FontSize', 12, 'FontWeight', 'bold', 'Color', [0.1 0.5 0.2], ...
        'BackgroundColor', [0.9 1.0 0.9], 'EdgeColor', [0.3 0.7 0.3], ...
        'Margin', 4);
end

sgtitle('Sloshing Angle Over Time:  LPF (red)  vs  SBSFC (green)', ...
    'FontSize', 15, 'FontWeight', 'bold');

saveas(fig3, fullfile('..', 'results', 'time_series_comparison.png'));
fprintf('Saved: results/time_series_comparison.png\n');

%% ══════════════════════════════════════════════════════════════════════════
%  Print comparison table
%% ══════════════════════════════════════════════════════════════════════════
fprintf('\n');
fprintf('╔════════════════════════════════════════════════════════════════════╗\n');
fprintf('║            SBSFC vs LPF — Sloshing Reduction Summary            ║\n');
fprintf('╠═══════════════════╦══════════╦══════════╦════════════════════════╣\n');
fprintf('║     Scenario      ║   LPF    ║  SBSFC   ║     Reduction         ║\n');
fprintf('╠═══════════════════╬══════════╬══════════╬════════════════════════╣\n');

for i = 1:length(scenario_ids)
    reduction_mean = (1 - theta_mean_sbsfc(i) / theta_mean_lpf(i)) * 100;
    reduction_peak = (1 - theta_max_sbsfc(i) / theta_max_lpf(i)) * 100;
    fprintf('║ %-17s ║ %6.2f°  ║ %6.2f°  ║ mean: -%4.0f%%  peak: -%3.0f%% ║\n', ...
        short_names{i}, theta_mean_lpf(i), theta_mean_sbsfc(i), ...
        reduction_mean, reduction_peak);
end

fprintf('╚═══════════════════╩══════════╩══════════╩════════════════════════╝\n');
fprintf('\nAll figures saved to ../results/\n');
fprintf('Use these in your PPT:\n');
fprintf('  - bar_chart_comparison.png  (mean sloshing bar chart)\n');
fprintf('  - bar_chart_peak.png        (peak sloshing bar chart)\n');
fprintf('  - time_series_comparison.png (θ over time, all scenarios)\n');
