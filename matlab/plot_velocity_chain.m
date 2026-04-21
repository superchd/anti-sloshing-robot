%% PLOT_VELOCITY_CHAIN  Visualize v_ref → v_d → x_dot → x_ddot for LPF and SBSFC
%
% Three stacked panels:
%   Panel 1: LPF mode   — v_ref (blue dotted), v_d (orange), x_dot (green)
%   Panel 2: SBSFC mode — same signals
%   Panel 3: Acceleration overlay — LPF x_ddot vs SBSFC x_ddot on SAME axis
%            This is where the difference becomes obvious — the liquid feels
%            acceleration, not velocity.
%
% Optional: Panel 4 shows FFT magnitude of x_ddot with a vertical line at
%           the sloshing natural frequency ω_f.

clear; close all; clc;

p = parameters();
scenario_id = 1;
[v_ref, dist, scenario_name] = scenarios(scenario_id, p);

res_lpf   = simulate_system(v_ref, p, 'lpf',   dist);
res_sbsfc = simulate_system(v_ref, p, 'sbsfc', dist);

t  = res_lpf.t(:);
dt = p.dt;

% Numerical acceleration (backward difference)
accel_lpf   = [0; diff(res_lpf.x_dot)   / dt];
accel_sbsfc = [0; diff(res_sbsfc.x_dot) / dt];

%% Figure layout
fig = figure('Position', [100 40 1150 900], 'Color', 'w', ...
             'Name', ['Velocity chain — ' scenario_name]);

c_ref  = [0.15 0.35 0.85];   % blue
c_vd   = [0.95 0.55 0.10];   % orange
c_xdot = [0.15 0.65 0.25];   % green
c_lpf  = [0.85 0.25 0.25];   % red  (LPF accel)
c_sbs  = [0.15 0.45 0.85];   % blue (SBSFC accel)

% ── Panel 1: LPF velocity chain ─────────────────────────────
ax1 = subplot(4, 1, 1);
hold on; grid on; box on;
h1 = plot(t, res_lpf.v_ref, ':', 'Color', c_ref,  'LineWidth', 1.8);
h2 = plot(t, res_lpf.v_d,   '-', 'Color', c_vd,   'LineWidth', 1.8);
h3 = plot(t, res_lpf.x_dot, '-', 'Color', c_xdot, 'LineWidth', 1.8);
ylabel('Velocity [m/s]', 'FontSize', 10);
title('LPF mode  —  velocity chain', 'FontSize', 12, 'FontWeight', 'bold', ...
      'Color', [0.6 0.2 0.2]);
legend([h1 h2 h3], ...
       {'v_{ref}', 'v_d  (LPF output)', '\itdx/dt\rm'}, ...
       'Location', 'eastoutside', 'FontSize', 9);
xlim([0 t(end)]);
ylim([-0.2 0.9]);

% ── Panel 2: SBSFC velocity chain ───────────────────────────
ax2 = subplot(4, 1, 2);
hold on; grid on; box on;
h1 = plot(t, res_sbsfc.v_ref, ':', 'Color', c_ref,  'LineWidth', 1.8);
h2 = plot(t, res_sbsfc.v_d,   '-', 'Color', c_vd,   'LineWidth', 1.8);
h3 = plot(t, res_sbsfc.x_dot, '-', 'Color', c_xdot, 'LineWidth', 1.8);
ylabel('Velocity [m/s]', 'FontSize', 10);
title('SBSFC mode  —  velocity chain', 'FontSize', 12, 'FontWeight', 'bold', ...
      'Color', [0.15 0.4 0.75]);
legend([h1 h2 h3], ...
       {'v_{ref}', 'v_d  (SBSFC output)', '\itdx/dt\rm'}, ...
       'Location', 'eastoutside', 'FontSize', 9);
xlim([0 t(end)]);
ylim([-0.2 0.9]);

% ── Panel 3: Acceleration overlay (the key insight) ─────────
ax3 = subplot(4, 1, 3);
hold on; grid on; box on;
h1 = plot(t, accel_lpf,   '-', 'Color', c_lpf, 'LineWidth', 1.6);
h2 = plot(t, accel_sbsfc, '-', 'Color', c_sbs, 'LineWidth', 1.6);
xlabel('Time [s]', 'FontSize', 10);
ylabel('\itd^2x/dt^2\rm  [m/s^2]', 'FontSize', 10);
title('Acceleration  —  what the liquid actually feels', ...
      'FontSize', 12, 'FontWeight', 'bold', 'Color', [0.3 0.15 0.5]);
legend([h1 h2], ...
       {sprintf('LPF   (peak |a| = %.2f m/s^2)',  max(abs(accel_lpf))), ...
        sprintf('SBSFC (peak |a| = %.2f m/s^2)',  max(abs(accel_sbsfc)))}, ...
       'Location', 'eastoutside', 'FontSize', 9);
xlim([0 t(end)]);
yl = max(abs([accel_lpf; accel_sbsfc])) * 1.2;
ylim([-yl yl]);

% Annotate the sharp LPF spikes
text(8.3, max(abs(accel_lpf))*0.85, '← sharp spike at each step', ...
     'Color', c_lpf, 'FontSize', 10, 'FontWeight', 'bold');

% ── Panel 4: FFT of acceleration (spectral view) ────────────
ax4 = subplot(4, 1, 4);
hold on; grid on; box on;

% FFT
N = length(accel_lpf);
f = (0:N-1) / (N*dt);        % frequency [Hz]
half = 1:floor(N/2);
F_lpf   = abs(fft(accel_lpf))   / N;
F_sbsfc = abs(fft(accel_sbsfc)) / N;

f_max_show = 5;   % Hz
mask = (f(half) <= f_max_show);

h1 = plot(f(half(mask)), F_lpf(half(mask)),   '-', 'Color', c_lpf, 'LineWidth', 1.8);
h2 = plot(f(half(mask)), F_sbsfc(half(mask)), '-', 'Color', c_sbs, 'LineWidth', 1.8);

% Vertical line at sloshing frequency
omega_f_Hz = p.omega_f / (2*pi);
yL = ylim;
h3 = plot([omega_f_Hz omega_f_Hz], yL, '--', ...
          'Color', [0.6 0.1 0.6], 'LineWidth', 2);
text(omega_f_Hz + 0.05, yL(2)*0.85, ...
     sprintf(' \\omega_f/2\\pi = %.2f Hz', omega_f_Hz), ...
     'Color', [0.6 0.1 0.6], 'FontSize', 11, 'FontWeight', 'bold');

xlabel('Frequency [Hz]', 'FontSize', 10);
ylabel('|FFT(\itd^2x/dt^2\rm)|', 'FontSize', 10);
title('Spectrum  —  SBSFC has a hole exactly at the liquid''s resonant frequency', ...
      'FontSize', 12, 'FontWeight', 'bold', 'Color', [0.3 0.15 0.5]);
legend([h1 h2 h3], {'LPF', 'SBSFC', 'sloshing resonance \omega_f'}, ...
       'Location', 'eastoutside', 'FontSize', 9);
xlim([0 f_max_show]);

linkaxes([ax1 ax2 ax3], 'x');

sgtitle(sprintf('Scenario %d: %s  —  why theta differs even when velocity looks similar', ...
        scenario_id, scenario_name), ...
        'FontSize', 13, 'FontWeight', 'bold');

%% Save
if ~exist('../results', 'dir'), mkdir('../results'); end
saveas(fig, '../results/velocity_chain.png');
fprintf('Saved: ../results/velocity_chain.png\n');
