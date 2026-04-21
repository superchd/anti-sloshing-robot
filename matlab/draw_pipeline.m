function draw_pipeline()
%% DRAW_PIPELINE  Project pipeline diagram (MathWorks-style workflow)
% Creates a visual overview of the anti-sloshing serving robot project
% so anyone seeing the project for the first time can understand the flow.
close all;

fig = figure('Position', [30 30 1500 900], 'Color', 'w', 'Name', ...
    'Project Pipeline: Anti-Sloshing Serving Robot');
hold on; axis off; axis equal;
xlim([-1 31]); ylim([-1 19]);

%% ===== Color palette =====
c_blue      = [0.15 0.40 0.75];
c_blue_bg   = [0.90 0.94 1.00];
c_green     = [0.10 0.55 0.25];
c_green_bg  = [0.90 0.97 0.92];
c_orange    = [0.85 0.45 0.10];
c_orange_bg = [1.00 0.95 0.88];
c_red       = [0.75 0.15 0.15];
c_red_bg    = [1.00 0.92 0.92];
c_purple    = [0.50 0.20 0.70];
c_purple_bg = [0.95 0.90 1.00];
c_gray      = [0.45 0.45 0.45];
c_gray_bg   = [0.96 0.96 0.96];
c_teal      = [0.10 0.50 0.55];
c_teal_bg   = [0.88 0.96 0.97];

%% ========================================================================
%%  TITLE
%% ========================================================================
text(15, 18.2, 'Integrated Pipeline: Anti-Sloshing Control for Food-Serving Robots', ...
    'FontSize', 17, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
    'Color', [0.15 0.15 0.15]);
text(15, 17.5, 'Classical Control (SBSFC) vs Reinforcement Learning  |  MECE 6397 Course Project', ...
    'FontSize', 11, 'HorizontalAlignment', 'center', 'Color', c_gray);

%% ========================================================================
%%  STAGE 1: Problem & Physical Model  (left column)
%% ========================================================================
dashed_rbox(3.5, 12.5, 6.5, 8.5, c_blue, 1.8);
text(3.5, 16.5, 'Problem & Modeling', 'FontSize', 13, 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'center', 'Color', c_blue);

% Robot model box
rbox(3.5, 14.8, 5.5, 2.0, c_blue_bg, c_blue, 1.5);
text(3.5, 15.3, 'Serving Robot', 'FontSize', 11, 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'center', 'Color', c_blue);
text(3.5, 14.7, 'Wheeled inverted pendulum', 'FontSize', 9, ...
    'HorizontalAlignment', 'center', 'Color', c_gray);
text(3.5, 14.2, 'q = [\psi, \psi, x, x]', 'FontSize', 9, ...
    'HorizontalAlignment', 'center', 'Interpreter', 'tex', 'Color', c_blue);
text(2.55, 14.47, '.', 'FontSize', 11, 'FontWeight', 'bold', 'Color', c_blue);
text(3.75, 14.47, '.', 'FontSize', 11, 'FontWeight', 'bold', 'Color', c_blue);

% Sloshing proxy box
rbox(3.5, 12.3, 5.5, 2.0, c_orange_bg, c_orange, 1.5);
text(3.5, 12.9, 'Liquid Sloshing Proxy', 'FontSize', 11, 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'center', 'Color', c_orange);
text(3.5, 12.3, 'Nonlinear pendulum on tray', 'FontSize', 9, ...
    'HorizontalAlignment', 'center', 'Color', c_gray);
text(3.5, 11.7, '\theta = -(g/l)sin\theta + (a/l)cos\theta', ...
    'FontSize', 9, 'HorizontalAlignment', 'center', ...
    'Interpreter', 'tex', 'Color', c_orange);

% Parameters box
rbox(3.5, 9.8, 5.5, 1.6, c_gray_bg, c_gray, 1.2);
text(3.5, 10.2, 'Parameters', 'FontSize', 10, 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'center', 'Color', [0.3 0.3 0.3]);
text(3.5, 9.6, 'parameters.m  |  serving\_robot.urdf', 'FontSize', 8, ...
    'HorizontalAlignment', 'center', 'Color', c_gray);

%% ========================================================================
%%  STAGE 2: Control Design  (center-top, two tracks)
%% ========================================================================
dashed_rbox(14, 14.5, 10.5, 4.5, c_teal, 1.8);
text(14, 16.5, 'Control Design', 'FontSize', 13, 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'center', 'Color', c_teal);

% Track A: Classical SBSFC
rbox(10.8, 14.8, 4.5, 1.6, c_teal_bg, c_teal, 1.5);
text(10.8, 15.2, 'Classical: SBSFC', 'FontSize', 10, 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'center', 'Color', c_teal);
text(10.8, 14.5, 'Input Shaping + LQT + DOB', 'FontSize', 8, ...
    'HorizontalAlignment', 'center', 'Color', c_gray);

rbox(9.5,  12.8, 2.0, 0.9, [0.94 0.98 0.98], c_teal, 1.0);
text(9.5,  12.8, 'Input Shaping', 'FontSize', 7.5, 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'center');
rbox(11.5, 12.8, 1.5, 0.9, [0.94 0.98 0.98], c_teal, 1.0);
text(11.5, 12.8, 'LQT', 'FontSize', 7.5, 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'center');
rbox(13.2, 12.8, 1.5, 0.9, [0.94 0.98 0.98], c_teal, 1.0);
text(13.2, 12.8, 'DOB', 'FontSize', 7.5, 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'center');
rbox(14.9, 12.8, 1.5, 0.9, [0.94 0.98 0.98], c_teal, 1.0);
text(14.9, 12.8, 'Aux', 'FontSize', 7.5, 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'center');

% Track B: RL
rbox(17.7, 14.8, 4.0, 1.6, c_purple_bg, c_purple, 1.5);
text(17.7, 15.2, 'RL: DDPG / TD3', 'FontSize', 10, 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'center', 'Color', c_purple);
text(17.7, 14.5, 'Learn policy from reward', 'FontSize', 8, ...
    'HorizontalAlignment', 'center', 'Color', c_gray);
rbox(16.8, 12.8, 1.8, 0.9, [0.96 0.93 1.0], c_purple, 1.0);
text(16.8, 12.8, 'Environment', 'FontSize', 7.5, 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'center');
rbox(18.8, 12.8, 1.8, 0.9, [0.96 0.93 1.0], c_purple, 1.0);
text(18.8, 12.8, 'Agent', 'FontSize', 7.5, 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'center');

% vs label
text(14.2, 15.5, 'vs', 'FontSize', 12, 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'center', 'Color', [0.6 0.6 0.6], 'FontAngle', 'italic');

% Arrow: Model -> Control Design
annotation('arrow', [6.8/31 8.3/31], [14.8/19 14.8/19], ...
    'LineWidth', 2.5, 'Color', c_blue, 'HeadWidth', 10, 'HeadLength', 8);
text(7.1, 15.3, 'A, B matrices', 'FontSize', 8, 'Color', c_blue, 'FontWeight', 'bold');

%% ========================================================================
%%  STAGE 3: Simulation Engine
%% ========================================================================
dashed_rbox(14, 9.5, 10.5, 4.0, c_green, 1.8);
text(14, 11.3, 'Simulation Engine', 'FontSize', 13, 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'center', 'Color', c_green);

rbox(10.5, 9.8, 3.5, 1.5, c_green_bg, c_green, 1.5);
text(10.5, 10.2, 'Test Scenarios', 'FontSize', 10, 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'center', 'Color', c_green);
text(10.5, 9.5, '5 disturbance profiles', 'FontSize', 8, ...
    'HorizontalAlignment', 'center', 'Color', c_gray);

rbox(14.5, 9.8, 3.5, 1.5, c_green_bg, c_green, 1.5);
text(14.5, 10.2, 'Closed-Loop Sim', 'FontSize', 10, 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'center', 'Color', c_green);
text(14.5, 9.5, 'simulate\_system.m', 'FontSize', 8, ...
    'HorizontalAlignment', 'center', 'Color', c_gray);

rbox(18.2, 9.8, 3.0, 1.5, [1.0 1.0 0.88], [0.65 0.55 0.15], 1.5);
text(18.2, 10.3, 'Mode Select', 'FontSize', 10, 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'center', 'Color', [0.55 0.45 0.05]);
text(18.2, 9.6, 'none | lpf | sbsfc | rl', 'FontSize', 8, ...
    'HorizontalAlignment', 'center', 'Color', c_gray);

% Internal arrow: Scenarios -> Sim
annotation('arrow', [12.3/31 12.6/31], [9.8/19 9.8/19], ...
    'LineWidth', 1.5, 'Color', c_green, 'HeadWidth', 8, 'HeadLength', 6);

% Arrow: Control Design -> Simulation
annotation('arrow', [14/31 14/31], [12.1/19 11.5/19], ...
    'LineWidth', 2.5, 'Color', c_teal, 'HeadWidth', 10, 'HeadLength', 8);
text(14.5, 11.8, 'u(q)', 'FontSize', 9, 'FontWeight', 'bold', ...
    'Color', c_teal, 'Interpreter', 'tex');

% Arrow: Model -> Simulation (plant dynamics)
annotation('arrow', [6.8/31 8.3/31], [9.8/19 9.8/19], ...
    'LineWidth', 1.8, 'Color', c_gray, 'HeadWidth', 8, 'HeadLength', 6);
text(7.0, 10.3, 'Plant model', 'FontSize', 8, 'Color', c_gray, 'FontWeight', 'bold');

%% ========================================================================
%%  STAGE 4: Analysis & Results  (right column)
%% ========================================================================
dashed_rbox(25, 12.5, 6.0, 8.5, c_red, 1.8);
text(25, 16.5, 'Analysis & Results', 'FontSize', 13, 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'center', 'Color', c_red);

rbox(25, 14.8, 5.0, 1.6, c_red_bg, c_red, 1.5);
text(25, 15.2, 'Performance Metrics', 'FontSize', 10, 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'center', 'Color', c_red);
text(25, 14.5, '|\theta|_{mean}, |\theta|_{max}, |\psi|, energy', ...
    'FontSize', 8, 'HorizontalAlignment', 'center', ...
    'Interpreter', 'tex', 'Color', c_gray);

rbox(25, 12.8, 5.0, 1.3, c_red_bg, c_red, 1.5);
text(25, 13.1, 'Comparison Plots', 'FontSize', 10, 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'center', 'Color', c_red);
text(25, 12.6, 'plot\_results.m', 'FontSize', 8, ...
    'HorizontalAlignment', 'center', 'Color', c_gray);

rbox(25, 11.1, 5.0, 1.3, c_red_bg, c_red, 1.5);
text(25, 11.4, '2D Animation', 'FontSize', 10, 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'center', 'Color', c_red);
text(25, 10.9, 'animate\_2d.m', 'FontSize', 8, ...
    'HorizontalAlignment', 'center', 'Color', c_gray);

rbox(25, 9.5, 5.0, 1.5, [1.0 0.98 0.90], [0.6 0.5 0.1], 2.0);
text(25, 9.9, 'Conclusion', 'FontSize', 11, 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'center', 'Color', [0.5 0.4 0.0]);
text(25, 9.3, 'SBSFC vs RL: which wins?', 'FontSize', 9, ...
    'HorizontalAlignment', 'center', 'Color', c_gray, 'FontAngle', 'italic');

% Arrow: Simulation -> Analysis
annotation('arrow', [19.8/31 22/31], [12.5/19 12.5/19], ...
    'LineWidth', 2.5, 'Color', c_green, 'HeadWidth', 10, 'HeadLength', 8);
text(20.3, 13.0, 'Results', 'FontSize', 9, 'FontWeight', 'bold', 'Color', c_green);

%% ========================================================================
%%  BOTTOM: Disturbance Scenarios Strip
%% ========================================================================
dashed_rbox(15, 5.5, 28, 3.5, [0.5 0.5 0.5], 1.2);
text(15, 7.0, 'Disturbance Scenarios (scenarios.m)', 'FontSize', 12, ...
    'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Color', [0.35 0.35 0.35]);

scenarios_x    = [3, 8.5, 14, 19.5, 25];
scenario_names = {'Sudden Start/Stop', 'Speed Bumps', 'Accel/Decel', ...
                  'External Push', 'Rough Terrain'};
scenario_icons = {'v_{ref} = step', 'impulse F', 'repeated ramp', ...
                  'F_{push} pulse', 'random F(t)'};
for i = 1:5
    rbox(scenarios_x(i), 5.3, 4.2, 1.6, [0.97 0.97 0.97], [0.6 0.6 0.6], 1.2);
    text(scenarios_x(i), 5.7, scenario_names{i}, 'FontSize', 8.5, ...
        'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    text(scenarios_x(i), 5.0, scenario_icons{i}, 'FontSize', 7.5, ...
        'HorizontalAlignment', 'center', 'Interpreter', 'tex', 'Color', c_gray);
end

% Arrow: Scenarios strip -> Simulation
annotation('arrow', [14/31 14/31], [7.3/19 7.7/19], ...
    'LineWidth', 1.5, 'Color', [0.5 0.5 0.5], 'HeadWidth', 8, 'HeadLength', 6);

%% ========================================================================
%%  TOOLS BANNER (top-right)
%% ========================================================================
rbox(25, 17.7, 6.0, 0.8, [0.95 0.95 0.95], [0.7 0.7 0.7], 1.0, 0.5);
text(25, 17.7, 'MATLAB  |  Simulink  |  RL Toolbox', ...
    'FontSize', 9, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
    'Color', c_gray);

%% ========================================================================
%%  NOVEL CONTRIBUTION CALLOUT
%% ========================================================================
rbox(3.5, 5.3, 5.5, 1.6, [1.0 0.95 0.90], c_orange, 2.0);
text(3.5, 5.7, 'Novel Contribution', 'FontSize', 10, 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'center', 'Color', c_orange);
text(3.5, 5.0, 'RL handles 2D turning + bumps', 'FontSize', 8, ...
    'HorizontalAlignment', 'center', 'Color', c_gray);
text(3.5, 4.6, 'better than classical 1D control', 'FontSize', 8, ...
    'HorizontalAlignment', 'center', 'Color', c_gray, 'FontAngle', 'italic');

fprintf('Pipeline diagram drawn.\n');
fprintf('Save: exportgraphics(gcf, ''../results/project_pipeline.png'', ''Resolution'', 300)\n');

end % draw_pipeline

%% ========================================================================
%%  LOCAL HELPER FUNCTIONS
%% ========================================================================
function rbox(x, y, w, ht, face_c, edge_c, lw, curve)
    if nargin < 8, curve = 0.3; end
    rectangle('Position', [x-w/2, y-ht/2, w, ht], ...
        'Curvature', curve, 'FaceColor', face_c, ...
        'EdgeColor', edge_c, 'LineWidth', lw);
end

function dashed_rbox(x, y, w, ht, edge_c, lw)
    rectangle('Position', [x-w/2, y-ht/2, w, ht], ...
        'Curvature', 0.15, 'FaceColor', 'none', ...
        'EdgeColor', edge_c, 'LineWidth', lw, 'LineStyle', '--');
end
