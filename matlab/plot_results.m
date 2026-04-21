function plot_results(res_none, res_lpf, res_sbsfc, scenario_name, save_path)
% PLOT_RESULTS  Generate paper-style comparison plots
%
% Compares three control modes side by side:
%   res_none  - no control (open-loop)
%   res_lpf   - LPF-based control
%   res_sbsfc - full SBSFC

if nargin < 5
    save_path = '';
end

t = res_sbsfc.t;

%% Figure 1: Velocity tracking
figure('Position', [100 100 1200 900], 'Name', scenario_name);

subplot(3, 2, 1);
plot(t, res_sbsfc.v_ref, 'k--', 'LineWidth', 1); hold on;
plot(t, res_sbsfc.v_d, 'b-', 'LineWidth', 1.2);
if ~isempty(res_lpf)
    plot(t, res_lpf.v_d, 'r:', 'LineWidth', 1.2);
    legend('v_{ref}', 'SBSFC (shaped)', 'LPF', 'Location', 'best');
else
    legend('v_{ref}', 'SBSFC (shaped)', 'Location', 'best');
end
xlabel('Time [s]'); ylabel('Velocity [m/s]');
title('Reference Velocity'); grid on;

subplot(3, 2, 2);
plot(t, res_sbsfc.x_dot, 'b-', 'LineWidth', 1.2); hold on;
if ~isempty(res_lpf)
    plot(t, res_lpf.x_dot, 'r:', 'LineWidth', 1.2);
end
if ~isempty(res_none)
    plot(t, res_none.x_dot, 'k--', 'LineWidth', 0.8);
end
legend('SBSFC', 'LPF', 'No Control', 'Location', 'best');
xlabel('Time [s]'); ylabel('Velocity [m/s]');
title('Actual Velocity'); grid on;

%% Figure 2: Pitch angle |psi|
subplot(3, 2, 3);
plot(t, rad2deg(abs(res_sbsfc.psi)), 'b-', 'LineWidth', 1.2); hold on;
if ~isempty(res_lpf)
    plot(t, rad2deg(abs(res_lpf.psi)), 'r:', 'LineWidth', 1.2);
end
if ~isempty(res_none)
    plot(t, rad2deg(abs(res_none.psi)), 'k--', 'LineWidth', 0.8);
end
legend('SBSFC', 'LPF', 'No Control', 'Location', 'best');
xlabel('Time [s]'); ylabel('|\psi| [degree]');
title('Robot Pitch Angle'); grid on;

%% Figure 3: Pendulum swing angle |theta|  (KEY METRIC)
subplot(3, 2, 4);
plot(t, rad2deg(abs(res_sbsfc.theta)), 'b-', 'LineWidth', 1.2); hold on;
if ~isempty(res_lpf)
    plot(t, rad2deg(abs(res_lpf.theta)), 'r:', 'LineWidth', 1.2);
end
if ~isempty(res_none)
    plot(t, rad2deg(abs(res_none.theta)), 'k--', 'LineWidth', 0.8);
end
legend('SBSFC', 'LPF', 'No Control', 'Location', 'best');
xlabel('Time [s]'); ylabel('|\theta| [degree]');
title('Pendulum Swing Angle (Sloshing Indicator)'); grid on;

%% Figure 4: Pendulum angular velocity
subplot(3, 2, 5);
plot(t, rad2deg(abs(res_sbsfc.theta_dot)), 'b-', 'LineWidth', 1.2); hold on;
if ~isempty(res_lpf)
    plot(t, rad2deg(abs(res_lpf.theta_dot)), 'r:', 'LineWidth', 1.2);
end
if ~isempty(res_none)
    plot(t, rad2deg(abs(res_none.theta_dot)), 'k--', 'LineWidth', 0.8);
end
legend('SBSFC', 'LPF', 'No Control', 'Location', 'best');
xlabel('Time [s]'); ylabel('|\theta dot| [degree/s]');
title('Pendulum Angular Velocity'); grid on;

%% Figure 5: Control input
subplot(3, 2, 6);
plot(t, res_sbsfc.u_total, 'b-', 'LineWidth', 1); hold on;
if ~isempty(res_lpf)
    plot(t, res_lpf.u_total, 'r:', 'LineWidth', 1);
end
if ~isempty(res_sbsfc)
    plot(t, res_sbsfc.d_ext, 'm-', 'LineWidth', 0.8);
end
legend('SBSFC u_t', 'LPF u_t', 'Disturbance', 'Location', 'best');
xlabel('Time [s]'); ylabel('Acceleration [m/s^2]');
title('Control Input & Disturbance'); grid on;

sgtitle(sprintf('Scenario: %s', scenario_name), 'FontSize', 14, ...
        'FontWeight', 'bold');

%% Save figure
if ~isempty(save_path)
    saveas(gcf, save_path);
    fprintf('Figure saved to: %s\n', save_path);
end

end
