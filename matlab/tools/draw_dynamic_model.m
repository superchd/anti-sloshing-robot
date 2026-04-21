%% DRAW_DYNAMIC_MODEL  Clean free-body diagram of serving robot
clear; close all; clc;

figure('Position', [50 50 1400 700], 'Color', 'w');

%% ========== LEFT PANEL: Robot Diagram Only ==========
ax1 = axes('Position', [0.01 0.03 0.50 0.90]);
hold on; axis equal; axis off;

th = linspace(0, 2*pi, 40);

% --- Ground ---
fill([-4 4 4 -4], [-0.4 -0.4 0 0], [0.88 0.85 0.78], 'EdgeColor', 'none');
plot([-4 4], [0 0], 'k-', 'LineWidth', 2.5);

% --- Wheels ---
fill(0.4*cos(th)-1.0, 0.4*sin(th)+0.4, [0.2 0.2 0.2], 'EdgeColor','k','LineWidth',1.5);
fill(0.4*cos(th)+1.0, 0.4*sin(th)+0.4, [0.2 0.2 0.2], 'EdgeColor','k','LineWidth',1.5);

% --- Lower Body ---
fill([-1.3 1.3 1.3 -1.3], [0.9 0.9 2.0 2.0], [0.4 0.4 0.45], ...
     'EdgeColor','k','LineWidth',2);
text(0, 1.45, 'Lower Body (m_s)', 'FontSize', 11, 'FontWeight', 'bold', ...
     'Color', 'w', 'HorizontalAlignment', 'center', 'Interpreter', 'tex');

% --- Springs ---
for side = [-0.7, 0.7]
    ny = 16;
    sy = linspace(2.0, 2.6, ny);
    sx = zeros(1, ny);
    for i = 2:ny-1
        sx(i) = 0.12 * (-1)^i;
    end
    plot(sx + side, sy, '-', 'Color', [0.85 0.55 0.1], 'LineWidth', 2.5);
end

% --- Upper Body ---
fill([-1.1 1.1 1.1 -1.1], [2.6 2.6 5.4 5.4], [0.78 0.78 0.82], ...
     'EdgeColor',[0.5 0.5 0.5],'LineWidth',2);
text(0, 4.0, 'Upper Body (m)', 'FontSize', 12, 'FontWeight', 'bold', ...
     'HorizontalAlignment', 'center', 'Interpreter', 'tex');

% Shelves
for sy = [3.2, 3.8, 4.6]
    plot([-0.9 0.9], [sy sy], '-', 'Color', [0.65 0.65 0.7], 'LineWidth', 1.2);
end

% --- Tray ---
fill([-1.6 1.6 1.6 -1.6], [5.5 5.5 5.65 5.65], [0.3 0.75 0.3], ...
     'EdgeColor', [0.15 0.5 0.15], 'LineWidth', 2.5);

% --- Cup ---
fill([-0.25 0.25 0.22 -0.22], [5.65 5.65 6.2 6.2], ...
     [0.75 0.88 1.0], 'EdgeColor', [0.3 0.5 0.7], 'LineWidth', 1.5);
fill([-0.23 0.23 0.22 -0.22], [5.68 5.68 6.0 6.0], ...
     [0.3 0.5 0.85], 'EdgeColor', 'none', 'FaceAlpha', 0.6);

% --- Pendulum pivot ---
plot(0, 5.65, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r', 'LineWidth', 1.5);

% --- Pendulum (swinging) ---
pend_angle = 0.3;
pend_len = 1.5;
bob_x = pend_len * sin(pend_angle);
bob_y = 5.65 - pend_len * cos(pend_angle);
plot([0 bob_x], [5.65 bob_y], '-', 'Color', [0.5 0.5 0.5], 'LineWidth', 3);
fill(0.12*cos(th)+bob_x, 0.12*sin(th)+bob_y, [1.0 0.5 0.0], ...
     'EdgeColor', [0.7 0.3 0.0], 'LineWidth', 2);

% Vertical reference for theta
plot([0 0], [5.65 5.65-pend_len-0.2], '--', 'Color', [0.6 0.6 0.6], 'LineWidth', 1);

% Theta arc
arc_r = 0.8;
arc_th = linspace(-pi/2, -pi/2+pend_angle, 25);
plot(arc_r*cos(arc_th), 5.65 + arc_r*sin(arc_th), '-', ...
     'Color', [0.9 0.4 0.0], 'LineWidth', 2.5);

% --- LABELS (all outside the robot) ---

% theta label - far right of pendulum
text(1.2, 4.6, '\theta', 'FontSize', 20, 'FontWeight', 'bold', ...
     'Color', [0.9 0.4 0.0], 'Interpreter', 'tex');
text(1.2, 4.2, '(sloshing)', 'FontSize', 9, 'Color', [0.9 0.4 0.0], ...
     'Interpreter', 'tex');

% m_p label
text(bob_x + 0.3, bob_y, 'm_p', 'FontSize', 12, 'FontWeight', 'bold', ...
     'Color', [0.9 0.4 0.0], 'Interpreter', 'tex');

% l_p label
text(0.5, (5.65+bob_y)/2 + 0.2, 'l_p', 'FontSize', 12, 'FontWeight', 'bold', ...
     'Color', [0.5 0.5 0.5], 'Interpreter', 'tex');

% psi label - far left
text(-3.5, 3.5, '\psi_t', 'FontSize', 20, 'FontWeight', 'bold', ...
     'Color', [0.9 0.1 0.1], 'Interpreter', 'tex');
text(-3.5, 3.0, '(pitch angle)', 'FontSize', 9, 'Color', [0.9 0.1 0.1]);

% psi reference lines
plot([-2.5 -2.5], [0.5 5.8], '--', 'Color', [0.7 0.7 0.7], 'LineWidth', 1);
psi_draw = 0.12;
plot([-2.5, -2.5 + 5*sin(psi_draw)], [0.5, 0.5+5*cos(psi_draw)], '-', ...
     'Color', [0.9 0.1 0.1], 'LineWidth', 1.5);
psi_arc_r = 2.0;
psi_arc = linspace(pi/2, pi/2-psi_draw, 20);
plot(-2.5 + psi_arc_r*cos(psi_arc), 0.5 + psi_arc_r*sin(psi_arc), ...
     '-', 'Color', [0.9 0.1 0.1], 'LineWidth', 2);

% Height dimension (l) - far left
dim_x = -3.2;
plot([dim_x dim_x], [0.9 5.5], '-', 'Color', [0 0.3 0.8], 'LineWidth', 2);
plot([dim_x-0.1 dim_x dim_x+0.1], [1.1 0.9 1.1], '-', 'Color', [0 0.3 0.8], 'LineWidth', 2);
plot([dim_x-0.1 dim_x dim_x+0.1], [5.3 5.5 5.3], '-', 'Color', [0 0.3 0.8], 'LineWidth', 2);
text(dim_x-0.2, 3.2, 'l', 'FontSize', 14, 'FontWeight', 'bold', ...
     'Color', [0 0.3 0.8], 'Rotation', 90, 'HorizontalAlignment', 'center', ...
     'Interpreter', 'tex');

% r (wheel radius) label
text(1.7, 0.4, 'r', 'FontSize', 13, 'FontWeight', 'bold', ...
     'Color', [0 0.3 0.8], 'Interpreter', 'tex');

% Spring label
text(1.5, 2.3, 'spring', 'FontSize', 10, 'FontWeight', 'bold', ...
     'Color', [0.85 0.55 0.1]);

% Tray label
text(-2.2, 5.6, 'Tray', 'FontSize', 11, 'FontWeight', 'bold', ...
     'Color', [0.15 0.5 0.15]);

% IMU labels
fill([1.3 1.6 1.6 1.3], [1.3 1.3 1.5 1.5], [0 0.7 0], 'EdgeColor','k');
text(1.8, 1.4, 'IMU_L', 'FontSize', 8, 'FontWeight', 'bold', 'Color', [0 0.5 0]);
fill([1.1 1.4 1.4 1.1], [5.35 5.35 5.5 5.5], [0 0.7 0], 'EdgeColor','k');
text(1.6, 5.43, 'IMU_U', 'FontSize', 8, 'FontWeight', 'bold', 'Color', [0 0.5 0]);

% --- FORCE ARROWS (well separated) ---

% Gravity
quiver(1.8, 4.5, 0, -1.2, 0, 'Color', [0.9 0.1 0.1], 'LineWidth', 2.5, ...
       'MaxHeadSize', 0.4);
text(2.1, 3.8, 'mg', 'FontSize', 14, 'FontWeight', 'bold', ...
     'Color', [0.9 0.1 0.1], 'Interpreter', 'tex');

% Control input
quiver(-3.8, 1.5, 1.3, 0, 0, 'Color', [0 0.6 0], 'LineWidth', 3, ...
       'MaxHeadSize', 0.3);
text(-3.8, 1.9, 'u_t', 'FontSize', 14, 'FontWeight', 'bold', ...
     'Color', [0 0.5 0], 'Interpreter', 'tex');

% Disturbance
quiver(3.5, 2.5, -1.3, 0, 0, 'Color', [0.7 0 0.5], 'LineWidth', 3, ...
       'MaxHeadSize', 0.3);
text(2.8, 2.9, 'd_t', 'FontSize', 14, 'FontWeight', 'bold', ...
     'Color', [0.7 0 0.5], 'Interpreter', 'tex');

% Position
quiver(-3.5, -0.6, 2.5, 0, 0, 'Color', [0 0.3 0.8], 'LineWidth', 2, ...
       'MaxHeadSize', 0.3);
text(-2.5, -0.9, 'x_t', 'FontSize', 13, 'FontWeight', 'bold', ...
     'Color', [0 0.3 0.8], 'Interpreter', 'tex');

% Title
text(0, 7.0, 'Physical Model', 'FontSize', 15, 'FontWeight', 'bold', ...
     'HorizontalAlignment', 'center');

xlim([-4.5 4]);
ylim([-1.5 7.5]);


%% ========== RIGHT PANEL: Equations Only ==========
ax2 = axes('Position', [0.54 0.05 0.44 0.88]);
hold on; axis off;
xlim([0 10]); ylim([0 22]);

y = 21;
text(5, y, 'State-Space Equations', 'FontSize', 15, 'FontWeight', 'bold', ...
     'HorizontalAlignment', 'center');

y = 19.5;
text(0.5, y, 'State Vector', 'FontSize', 13, 'FontWeight', 'bold', ...
     'Color', [0 0.3 0.8]);
y = y - 1;
text(1, y, 'q  =  [ \psi,   \psi,   x,   x ]^T', ...
     'FontSize', 12, 'Interpreter', 'tex');
text(2.55, y+0.35, '.', 'FontSize', 14, 'FontWeight', 'bold');  % dot over psi
text(6.3, y+0.35, '.', 'FontSize', 14, 'FontWeight', 'bold');   % dot over x

y = y - 1.5;
text(0.5, y, 'Robot Dynamics', 'FontSize', 13, 'FontWeight', 'bold', ...
     'Color', [0 0.3 0.8]);
y = y - 1;
text(1, y, 'q  =  A q  +  B u  +  d', 'FontSize', 13, 'FontWeight', 'bold', ...
     'Interpreter', 'tex');
text(1.15, y+0.35, '.', 'FontSize', 16, 'FontWeight', 'bold');

y = y - 1.8;
text(0.5, y, 'A  =', 'FontSize', 12, 'FontWeight', 'bold');
% A matrix with brackets
mat_x = 2.0;
text(mat_x, y+0.8, '[  0       1       0       0  ]', 'FontSize', 10, 'FontName', 'Courier');
text(mat_x, y+0.2, '[  a_1    0       0       0  ]', 'FontSize', 10, 'FontName', 'Courier');
text(mat_x, y-0.4, '[  0       0       0       1  ]', 'FontSize', 10, 'FontName', 'Courier');
text(mat_x, y-1.0, '[  A_{21}  0       0       0  ]', 'FontSize', 10, 'FontName', 'Courier');

y = y - 2.0;
text(0.5, y, 'B  =  [ 0,   \beta_1/\beta_2,   0,   1 ]^T', ...
     'FontSize', 11, 'Interpreter', 'tex');

y = y - 1.8;
text(0.5, y, 'Intermediate Terms', 'FontSize', 13, 'FontWeight', 'bold', ...
     'Color', [0 0.3 0.8]);
y = y - 0.8;
terms = {
    '\gamma = r^2(m_s^2 l^2 - I_\omega m + 2I_p I_\omega + 2I_p m) + 4I_p^2'
    'a_1 = m_s g (m r^2 + 2 I_\omega) / \gamma'
    'a_2 = -(m_s r)^2 g / \gamma'
    '\beta_1 = (2mr^2 + 4I_\omega + m_s r l) / \gamma'
    '\beta_2 = -r (2m_s l + I_\omega - 2I_p) / \gamma'
    'A_{21} = -(\beta_2 a_1 - \beta_1 a_2) / \beta_2'
};
for i = 1:length(terms)
    text(1, y, terms{i}, 'FontSize', 9.5, 'Interpreter', 'tex');
    y = y - 0.7;
end

y = y - 0.8;
text(0.5, y, 'Pendulum (Sloshing)', 'FontSize', 13, 'FontWeight', 'bold', ...
     'Color', [0.9 0.4 0.0]);
y = y - 1;
text(1, y, '\theta  =  -(g / l_p) sin\theta  -  (b / m_p l_p^2) \theta  +  (x cos\theta) / l_p', ...
     'FontSize', 10, 'Interpreter', 'tex');
text(1.0, y+0.35, '..', 'FontSize', 14, 'FontWeight', 'bold', 'Color', [0.9 0.4 0.0]);
text(7.1, y+0.35, '.', 'FontSize', 14, 'FontWeight', 'bold');
text(5.4, y+0.35, '..', 'FontSize', 14, 'FontWeight', 'bold');

y = y - 1.5;
text(0.5, y, 'Parameter Values', 'FontSize', 13, 'FontWeight', 'bold', ...
     'Color', [0.4 0.4 0.4]);
y = y - 0.7;
vals = {
    'm_s = 38.0 kg          m = 42.0 kg'
    'l = 0.95 m              r = 0.08 m'
    'I_\omega = 2.15 kg m^2      I_p = 13.71 kg m^2'
    'l_p = 0.15 m     m_p = 0.5 kg     b = 0.01'
    'g = 9.81 m/s^2'
};
for i = 1:length(vals)
    text(1, y, vals{i}, 'FontSize', 9, 'Color', [0.4 0.4 0.4], 'Interpreter', 'tex');
    y = y - 0.6;
end

fprintf('Dynamic model figure drawn.\n');
fprintf('Save with: saveas(gcf, ''../results/dynamic_model.png'')\n');
