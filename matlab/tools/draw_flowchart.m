%% DRAW_FLOWCHART  System architecture flowchart for the serving robot project
clear; close all; clc;

figure('Position', [50 50 1200 800], 'Color', 'w');
hold on; axis off;
xlim([0 24]); ylim([0 16]);

%% ===== Helper: draw box =====
% box_params: [x_center, y_center, width, height]
draw_box = @(x, y, w, h, face_c, edge_c, lw) ...
    fill([x-w/2 x+w/2 x+w/2 x-w/2], [y-h/2 y-h/2 y+h/2 y+h/2], ...
         face_c, 'EdgeColor', edge_c, 'LineWidth', lw);

%% ===== Title =====
text(12, 15.3, 'System Architecture: Anti-Sloshing Serving Robot', ...
     'FontSize', 16, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');

%% ===== ROW 1: Inputs =====
% Scenario / Reference
draw_box(3, 13, 3.8, 1.8, [0.9 0.95 1.0], [0.3 0.5 0.8], 2);
text(3, 13.4, 'Scenario', 'FontSize', 12, 'FontWeight', 'bold', ...
     'HorizontalAlignment', 'center');
text(3, 12.8, '(scenarios.m)', 'FontSize', 9, 'Color', [0.4 0.4 0.4], ...
     'HorizontalAlignment', 'center');
text(3, 12.3, 'v_{ref}, disturbances', 'FontSize', 9, ...
     'HorizontalAlignment', 'center', 'Interpreter', 'tex', ...
     'Color', [0.3 0.5 0.8]);

%% ===== ROW 2: Input Shaping =====
draw_box(3, 10.2, 3.8, 1.5, [0.95 0.95 0.85], [0.6 0.5 0.2], 2);
text(3, 10.6, 'Input Shaping', 'FontSize', 12, 'FontWeight', 'bold', ...
     'HorizontalAlignment', 'center');
text(3, 10.0, '(input\_shaping.m)', 'FontSize', 9, 'Color', [0.4 0.4 0.4], ...
     'HorizontalAlignment', 'center');
text(3, 9.6, 'v_{ref} \rightarrow v_d', 'FontSize', 10, ...
     'HorizontalAlignment', 'center', 'Interpreter', 'tex', ...
     'Color', [0.6 0.5 0.2]);

% Arrow: Scenario -> Input Shaping
annotation('arrow', [3/24 3/24], [12.1/16 11.0/16], 'LineWidth', 2, ...
           'Color', [0.3 0.3 0.3]);

%% ===== ROW 3: Controller (MAIN - highlighted) =====
draw_box(3, 7.2, 3.8, 2.4, [0.85 0.92 1.0], [0.1 0.3 0.8], 3);
% Blue highlight border
draw_box(3, 7.2, 4.0, 2.6, 'none', [0.1 0.3 0.8], 3);

text(3, 8.0, 'Controller', 'FontSize', 14, 'FontWeight', 'bold', ...
     'HorizontalAlignment', 'center', 'Color', [0.1 0.2 0.7]);
text(3, 7.4, '(controller.m)', 'FontSize', 9, 'Color', [0.4 0.4 0.4], ...
     'HorizontalAlignment', 'center');
text(3, 6.7, 'SBSFC / LPF / RL', 'FontSize', 10, 'FontWeight', 'bold', ...
     'HorizontalAlignment', 'center', 'Color', [0.1 0.3 0.8]);
text(3, 6.2, 'Teammate edits this', 'FontSize', 8, ...
     'HorizontalAlignment', 'center', 'Color', [0.8 0.2 0.2], ...
     'FontAngle', 'italic');

% Arrow: Input Shaping -> Controller
annotation('arrow', [3/24 3/24], [9.45/16 8.45/16], 'LineWidth', 2, ...
           'Color', [0.3 0.3 0.3]);
text(4.2, 9.0, 'v_d', 'FontSize', 10, 'FontWeight', 'bold', ...
     'Color', [0.3 0.3 0.3], 'Interpreter', 'tex');

%% ===== ROW 3 (right): Controller sub-blocks =====
% LQT
draw_box(9, 8.5, 2.5, 1.0, [0.92 0.92 0.98], [0.5 0.5 0.7], 1.5);
text(9, 8.7, 'LQT', 'FontSize', 10, 'FontWeight', 'bold', ...
     'HorizontalAlignment', 'center');
text(9, 8.2, 'u = Kq - K_{tr}q_d', 'FontSize', 8, ...
     'HorizontalAlignment', 'center', 'Interpreter', 'tex');

% DOB
draw_box(9, 7.2, 2.5, 1.0, [0.92 0.92 0.98], [0.5 0.5 0.7], 1.5);
text(9, 7.4, 'DOB', 'FontSize', 10, 'FontWeight', 'bold', ...
     'HorizontalAlignment', 'center');
text(9, 6.9, 'disturbance est.', 'FontSize', 8, ...
     'HorizontalAlignment', 'center', 'Color', [0.4 0.4 0.4]);

% Auxiliary Compensator
draw_box(9, 5.9, 2.5, 1.0, [0.92 0.92 0.98], [0.5 0.5 0.7], 1.5);
text(9, 6.1, 'Auxiliary', 'FontSize', 10, 'FontWeight', 'bold', ...
     'HorizontalAlignment', 'center');
text(9, 5.65, 'K_c sgn(d\psi^L/dt)', 'FontSize', 8, ...
     'HorizontalAlignment', 'center', 'Interpreter', 'tex');

% Brace connecting sub-blocks to Controller
plot([5.1 5.8], [8.5 8.5], '-', 'Color', [0.5 0.5 0.7], 'LineWidth', 1.5);
plot([5.1 5.8], [7.2 7.2], '-', 'Color', [0.5 0.5 0.7], 'LineWidth', 1.5);
plot([5.1 5.8], [5.9 5.9], '-', 'Color', [0.5 0.5 0.7], 'LineWidth', 1.5);
text(6.5, 7.2, 'SBSFC', 'FontSize', 9, 'FontWeight', 'bold', ...
     'Color', [0.5 0.5 0.7], 'Rotation', 90, 'HorizontalAlignment', 'center');

% Sum block
text(11, 7.2, '\Sigma', 'FontSize', 18, 'FontWeight', 'bold', ...
     'HorizontalAlignment', 'center', 'Interpreter', 'tex');
plot([10.3 10.7], [8.5 7.4], '-', 'Color', [0.5 0.5 0.5], 'LineWidth', 1);
plot([10.3 10.7], [7.2 7.2], '-', 'Color', [0.5 0.5 0.5], 'LineWidth', 1);
plot([10.3 10.7], [5.9 7.0], '-', 'Color', [0.5 0.5 0.5], 'LineWidth', 1);

%% ===== ROW 4: Plant =====
draw_box(15, 7.2, 4.5, 2.8, [0.95 0.90 0.85], [0.6 0.3 0.1], 2);
text(15, 8.2, 'Plant', 'FontSize', 14, 'FontWeight', 'bold', ...
     'HorizontalAlignment', 'center');
text(15, 7.6, '(simulate\_system.m)', 'FontSize', 9, 'Color', [0.4 0.4 0.4], ...
     'HorizontalAlignment', 'center');

% Sub-labels inside plant
text(15, 7.0, 'Robot Dynamics', 'FontSize', 9, 'FontWeight', 'bold', ...
     'HorizontalAlignment', 'center');
text(15, 6.6, 'q = Aq + Bu + d', 'FontSize', 9, ...
     'HorizontalAlignment', 'center', 'Interpreter', 'tex');
text(15, 6.1, 'Pendulum Dynamics', 'FontSize', 9, 'FontWeight', 'bold', ...
     'HorizontalAlignment', 'center', 'Color', [0.9 0.4 0.0]);

% Arrow: Controller -> Plant (u_total)
annotation('arrow', [11.5/24 12.7/24], [7.2/16 7.2/16], 'LineWidth', 2.5, ...
           'Color', [0.1 0.3 0.8]);
text(12.1, 7.6, 'u_{total}', 'FontSize', 11, 'FontWeight', 'bold', ...
     'Color', [0.1 0.3 0.8], 'Interpreter', 'tex');

%% ===== Disturbance input to Plant =====
draw_box(15, 10.5, 3.5, 1.2, [1.0 0.92 0.92], [0.8 0.2 0.2], 1.5);
text(15, 10.7, 'Disturbances', 'FontSize', 11, 'FontWeight', 'bold', ...
     'HorizontalAlignment', 'center', 'Color', [0.7 0.1 0.1]);
text(15, 10.2, 'bumps, push, terrain', 'FontSize', 8, ...
     'HorizontalAlignment', 'center', 'Color', [0.5 0.3 0.3]);

% Arrow: Disturbance -> Plant
annotation('arrow', [15/24 15/24], [9.9/16 8.65/16], 'LineWidth', 2, ...
           'Color', [0.8 0.2 0.2]);
text(15.5, 9.3, 'd_{ext}', 'FontSize', 10, 'FontWeight', 'bold', ...
     'Color', [0.8 0.2 0.2], 'Interpreter', 'tex');

%% ===== Feedback arrow: Plant -> Controller =====
% Plant output down
annotation('arrow', [15/24 15/24], [5.8/16 4.5/16], 'LineWidth', 2, ...
           'Color', [0.3 0.3 0.3]);
% Horizontal left
annotation('line', [3/24 15/24], [4.5/16 4.5/16], 'LineWidth', 2, ...
           'Color', [0.3 0.3 0.3]);
% Up to Controller
annotation('arrow', [3/24 3/24], [4.5/16 5.95/16], 'LineWidth', 2, ...
           'Color', [0.3 0.3 0.3]);

% Feedback labels
text(9, 4.1, 'Feedback:  q = [\psi, \psi, x, x]     pend = [\theta, \theta]', ...
     'FontSize', 9, 'HorizontalAlignment', 'center', 'Interpreter', 'tex', ...
     'Color', [0.4 0.4 0.4]);
text(5.4, 4.1+0.27, '.', 'FontSize', 12, 'FontWeight', 'bold', 'Color', [0.4 0.4 0.4]);
text(8.2, 4.1+0.27, '.', 'FontSize', 12, 'FontWeight', 'bold', 'Color', [0.4 0.4 0.4]);
text(13.0, 4.1+0.27, '.', 'FontSize', 12, 'FontWeight', 'bold', 'Color', [0.4 0.4 0.4]);

%% ===== ROW 5: Outputs =====
% Results / Plotting
draw_box(21, 8.5, 3.0, 1.3, [0.88 0.95 0.88], [0.2 0.6 0.2], 1.5);
text(21, 8.7, 'Scopes', 'FontSize', 11, 'FontWeight', 'bold', ...
     'HorizontalAlignment', 'center', 'Color', [0.1 0.5 0.1]);
text(21, 8.2, '\psi, \theta, v, u', 'FontSize', 10, ...
     'HorizontalAlignment', 'center', 'Interpreter', 'tex');

draw_box(21, 6.8, 3.0, 1.3, [0.88 0.95 0.88], [0.2 0.6 0.2], 1.5);
text(21, 7.1, 'Results', 'FontSize', 11, 'FontWeight', 'bold', ...
     'HorizontalAlignment', 'center', 'Color', [0.1 0.5 0.1]);
text(21, 6.6, 'plot, table, animation', 'FontSize', 8, ...
     'HorizontalAlignment', 'center', 'Color', [0.4 0.4 0.4]);

% Arrow: Plant -> Outputs
annotation('arrow', [17.3/24 19.4/24], [8.0/16 8.5/16], 'LineWidth', 1.5, ...
           'Color', [0.2 0.6 0.2]);
annotation('arrow', [17.3/24 19.4/24], [7.0/16 6.8/16], 'LineWidth', 1.5, ...
           'Color', [0.2 0.6 0.2]);

text(18.3, 8.6, 'states', 'FontSize', 8, 'Color', [0.2 0.6 0.2]);

%% ===== File mapping legend =====
draw_box(21, 3.0, 4.5, 3.5, [0.97 0.97 0.97], [0.7 0.7 0.7], 1);
text(21, 4.4, 'File Mapping', 'FontSize', 11, 'FontWeight', 'bold', ...
     'HorizontalAlignment', 'center');
files = {
    'parameters.m        - physical constants'
    'scenarios.m           - velocity + disturbance'
    'input\_shaping.m     - reference smoothing'
    'controller.m          - control law'
    'simulate\_system.m  - plant + loop'
    'plot\_results.m       - comparison plots'
    'animate\_2d.m        - 2D animation'
};
for i = 1:length(files)
    text(19.0, 4.4 - 0.45*i, files{i}, 'FontSize', 7.5, ...
         'FontName', 'Courier', 'Color', [0.3 0.3 0.3]);
end

%% ===== Mode switch annotation =====
draw_box(3, 2.2, 3.8, 1.2, [1.0 1.0 0.85], [0.7 0.6 0.2], 1.5);
text(3, 2.5, 'Mode Switch', 'FontSize', 10, 'FontWeight', 'bold', ...
     'HorizontalAlignment', 'center');
text(3, 2.0, 'none / lpf / sbsfc / rl', 'FontSize', 9, ...
     'HorizontalAlignment', 'center', 'Color', [0.5 0.4 0.1]);

annotation('arrow', [3/24 3/24], [2.85/16 4.3/16], 'LineWidth', 1.5, ...
           'Color', [0.7 0.6 0.2], 'LineStyle', '--');

fprintf('Flowchart drawn.\n');
fprintf('Save with: saveas(gcf, ''../results/system_flowchart.png'')\n');
