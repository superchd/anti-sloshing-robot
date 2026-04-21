function animate_comparison(res_L, res_R, scenario_name, speed_factor, save_path, label_L, label_R)
%ANIMATE_COMPARISON  Side-by-side educational animation
%   Shows two controllers running simultaneously so students can
%   immediately see the effect on liquid sloshing.
%
% Usage:
%   p = parameters();
%   [v_ref, dist, name] = scenarios(1, p);
%   res_lpf   = simulate_system(v_ref, p, 'lpf',   dist);
%   res_R = simulate_system(v_ref, p, 'sbsfc', dist);
%   animate_comparison(res_lpf, res_R, name);
%   animate_comparison(res_lpf, res_R, name, 8, '', 'LPF Only', 'SBSFC');

if nargin < 4, speed_factor = 8; end
if nargin < 5, save_path = ''; end
if nargin < 6, label_L = 'LPF Only'; end
if nargin < 7, label_R = 'SBSFC'; end

%% ── Robot drawing dimensions ─────────────────────────────────────────────
p       = parameters();
dt      = res_L.t(2) - res_L.t(1);
N       = length(res_L.t);

WHEEL_R = 0.08;   % wheel radius
BASE_W  = 0.40;   BASE_H  = 0.22;
POLE_W  = 0.10;   POLE_H  = 0.60;
TRAY_W  = 0.50;   TRAY_H  = 0.025;
CUP_W   = 0.10;   CUP_H   = 0.12;
PEND_L  = p.pend_l;

GND_Y   = 0;
BASE_Y  = WHEEL_R;
TRAY_Y  = BASE_Y + BASE_H + POLE_H;
TOTAL_H = TRAY_Y + TRAY_H + CUP_H + PEND_L + 0.15;

%% ── Figure layout ────────────────────────────────────────────────────────
fig = figure('Position', [40 40 1280 820], 'Color', [0.12 0.12 0.15], ...
             'Name', ['Anti-Sloshing: ' scenario_name]);
fig.NumberTitle = 'off';

% Title
annotation(fig, 'textbox', [0 0.94 1 0.06], ...
    'String',    ['Anti-Sloshing Control   |   ' scenario_name], ...
    'FontSize',  16, 'FontWeight', 'bold', ...
    'Color',     'w', 'HorizontalAlignment', 'center', ...
    'EdgeColor', 'none', 'BackgroundColor', 'none');

% Left robot axis
ax_L = axes('Position', [0.03 0.32 0.44 0.60], ...
            'Color', [0.15 0.15 0.18], 'XColor', 'w', 'YColor', 'w');
hold(ax_L, 'on'); axis(ax_L, 'equal'); grid(ax_L, 'on');
ax_L.GridColor = [0.3 0.3 0.3]; ax_L.GridAlpha = 0.4;
title(ax_L, ['  ' label_L '  '], 'FontSize', 14, 'FontWeight', 'bold', ...
    'Color', [1 0.4 0.4], 'BackgroundColor', [0.25 0.08 0.08]);

% Right robot axis (SBSFC)
ax_R = axes('Position', [0.53 0.32 0.44 0.60], ...
            'Color', [0.15 0.15 0.18], 'XColor', 'w', 'YColor', 'w');
hold(ax_R, 'on'); axis(ax_R, 'equal'); grid(ax_R, 'on');
ax_R.GridColor = [0.3 0.3 0.3]; ax_R.GridAlpha = 0.4;
title(ax_R, ['  ' label_R '  '], 'FontSize', 14, 'FontWeight', 'bold', ...
    'Color', [0.4 1.0 0.5], 'BackgroundColor', [0.05 0.22 0.08]);

% Bottom comparison plot
ax_P = axes('Position', [0.06 0.05 0.88 0.22], ...
            'Color', [0.13 0.13 0.16], 'XColor', 'w', 'YColor', 'w');
hold(ax_P, 'on'); grid(ax_P, 'on');
ax_P.GridColor = [0.25 0.25 0.25];
xlabel(ax_P, 'Time  [s]', 'Color', 'w', 'FontSize', 11);
ylabel(ax_P, '|θ|  [deg]', 'Color', 'w', 'FontSize', 11);
title(ax_P, 'Sloshing Angle  θ  (lower is better)', ...
    'Color', 'w', 'FontSize', 12, 'FontWeight', 'bold');

%% ── Pre-draw background traces ───────────────────────────────────────────
plot(ax_P, res_L.t,  rad2deg(abs(res_L.theta)),  '-', ...
    'Color', [1 0.4 0.4 0.25], 'LineWidth', 1);
plot(ax_P, res_R.t, rad2deg(abs(res_R.theta)), '-', ...
    'Color', [0.4 1.0 0.5 0.25], 'LineWidth', 1);

h_trace_none  = plot(ax_P, NaN, NaN, '-', 'Color', [1 0.4 0.4],  'LineWidth', 2.5);
h_trace_sbsfc = plot(ax_P, NaN, NaN, '-', 'Color', [0.4 1.0 0.5],'LineWidth', 2.5);
h_tline = xline(ax_P, 0, 'w--', 'LineWidth', 1.5);

xlim(ax_P, [0 res_L.t(end)]);
yl = max([rad2deg(abs(res_L.theta)); rad2deg(abs(res_R.theta))]) * 1.2 + 0.5;
ylim(ax_P, [0 max(yl, 1)]);

legend(ax_P, {label_L, label_R}, 'TextColor','w', ...
    'Color',[0.18 0.18 0.22], 'EdgeColor',[0.4 0.4 0.4], ...
    'FontSize', 11, 'Location', 'northwest');

%% ── Draw static ground on both axes ─────────────────────────────────────
for ax = [ax_L, ax_R]
    fill(ax, [-4 4 4 -4], [-0.12 -0.12 GND_Y GND_Y], ...
        [0.35 0.30 0.22], 'EdgeColor', 'none');
    % Ground line with texture
    plot(ax, -4:0.2:4, zeros(1,41), 'v', 'Color', [0.5 0.45 0.35], ...
        'MarkerSize', 3, 'MarkerFaceColor', [0.5 0.45 0.35]);
    plot(ax, [-4 4], [0 0], '-', 'Color', [0.6 0.55 0.45], 'LineWidth', 2);
end

%% ── Create graphics objects for LEFT robot ───────────────────────────────
gL = make_robot_graphics(ax_L, WHEEL_R, BASE_W, BASE_H, POLE_W, POLE_H, ...
                          TRAY_W, TRAY_H, CUP_W, CUP_H);

%% ── Create graphics objects for RIGHT robot ──────────────────────────────
gR = make_robot_graphics(ax_R, WHEEL_R, BASE_W, BASE_H, POLE_W, POLE_H, ...
                          TRAY_W, TRAY_H, CUP_W, CUP_H);

%% ── Label panels ─────────────────────────────────────────────────────────
txt_L = text(ax_L, 0, 0, '', 'FontSize', 10, 'Color', 'w', ...
    'BackgroundColor', [0.2 0.2 0.25 0.9], 'Margin', 4, ...
    'HorizontalAlignment', 'center');

txt_R = text(ax_R, 0, 0, '', 'FontSize', 10, 'Color', 'w', ...
    'BackgroundColor', [0.2 0.2 0.25 0.9], 'Margin', 4, ...
    'HorizontalAlignment', 'center');

% Phase label (Accelerating / Coasting / Decelerating / Disturbed!)
txt_phase = annotation(fig, 'textbox', [0.38 0.90 0.24 0.04], ...
    'String', '', 'FontSize', 12, 'FontWeight', 'bold', ...
    'Color', [1 0.85 0.2], 'HorizontalAlignment', 'center', ...
    'EdgeColor', [0.5 0.45 0.1], 'BackgroundColor', [0.18 0.16 0.06]);

% Sloshing severity bar (left side)
txt_slosh_L = text(ax_L, 0, 0, '', 'FontSize', 12, 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'center');
txt_slosh_R = text(ax_R, 0, 0, '', 'FontSize', 12, 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'center');

%% ── Animation timing ─────────────────────────────────────────────────────
target_fps = 30;
frame_step = max(1, round(speed_factor / (dt * target_fps)));
frame_dt   = frame_step * dt / speed_factor;

%% ── Video writer setup ───────────────────────────────────────────────────
do_video = ~isempty(save_path);
if do_video
    vw = VideoWriter(save_path, 'MPEG-4');
    vw.FrameRate = target_fps;
    vw.Quality   = 90;
    open(vw);
    fprintf('Recording to: %s\n', save_path);
end

%% ══════════════════════════════════════════════════════════════════════════
%  MAIN LOOP
%% ══════════════════════════════════════════════════════════════════════════
for k = 1:frame_step:N
    if ~isvalid(fig), return; end
    tic;

    tk  = res_L.t(k);

    %% Determine motion phase
    if abs(res_L.d_ext(k)) > 1
        phase_str = '⚡ Disturbed!';
        phase_col = [1 0.3 0.3];
    elseif k > 2 && (res_L.v_ref(k) - res_L.v_ref(max(1,k-50))) > 0.05
        phase_str = '▶ Accelerating';
        phase_col = [1 0.85 0.2];
    elseif k > 2 && (res_L.v_ref(k) - res_L.v_ref(max(1,k-50))) < -0.05
        phase_str = '◀ Decelerating';
        phase_col = [0.3 0.7 1.0];
    elseif abs(res_L.v_ref(k)) < 0.01
        phase_str = '■ Stopped';
        phase_col = [0.7 0.7 0.7];
    else
        phase_str = '→ Coasting';
        phase_col = [0.5 1.0 0.5];
    end
    txt_phase.String     = phase_str;
    txt_phase.Color      = phase_col;
    txt_phase.EdgeColor  = phase_col * 0.6;

    %% Update LEFT robot (No Control)
    xL   = res_L.x(k);
    psiL = res_L.psi(k);
    thL  = res_L.theta(k);
    dL   = res_L.d_ext(k);
    vL   = res_L.x_dot(k);

    update_robot(gL, xL, psiL, thL, dL, vL, ...
        WHEEL_R, BASE_W, BASE_H, POLE_W, POLE_H, TRAY_W, TRAY_H, ...
        CUP_W, CUP_H, PEND_L, BASE_Y, TRAY_Y, false);

    % Camera
    xlim(ax_L, [xL - 1.4, xL + 1.4]);
    ylim(ax_L, [-0.15, TOTAL_H]);

    % Info label
    set(txt_L, 'Position', [xL, TRAY_Y + CUP_H + PEND_L + 0.08], ...
        'String', sprintf('ψ = %+.1f°   θ = %+.1f°', ...
        rad2deg(psiL), rad2deg(thL)));

    % Sloshing severity
    sev_L = min(abs(rad2deg(thL)) / 15, 1);  % 0→1 over 15°
    if sev_L < 0.3
        slosh_col_L = [0.3 1.0 0.4];  slosh_sym = '● Calm';
    elseif sev_L < 0.6
        slosh_col_L = [1.0 0.8 0.0];  slosh_sym = '◐ Sloshing';
    else
        slosh_col_L = [1.0 0.3 0.2];  slosh_sym = '● SPILLING!';
    end
    set(txt_slosh_L, 'Position', [xL, -0.08], ...
        'String', slosh_sym, 'Color', slosh_col_L);

    %% Update RIGHT robot (SBSFC)
    xR   = res_R.x(k);
    psiR = res_R.psi(k);
    thR  = res_R.theta(k);
    dR   = res_R.d_ext(k);
    vR   = res_R.x_dot(k);

    update_robot(gR, xR, psiR, thR, dR, vR, ...
        WHEEL_R, BASE_W, BASE_H, POLE_W, POLE_H, TRAY_W, TRAY_H, ...
        CUP_W, CUP_H, PEND_L, BASE_Y, TRAY_Y, true);

    xlim(ax_R, [xR - 1.4, xR + 1.4]);
    ylim(ax_R, [-0.15, TOTAL_H]);

    set(txt_R, 'Position', [xR, TRAY_Y + CUP_H + PEND_L + 0.08], ...
        'String', sprintf('ψ = %+.1f°   θ = %+.1f°', ...
        rad2deg(psiR), rad2deg(thR)));

    sev_R = min(abs(rad2deg(thR)) / 15, 1);
    if sev_R < 0.3
        slosh_col_R = [0.3 1.0 0.4];  slosh_sym_R = '● Calm';
    elseif sev_R < 0.6
        slosh_col_R = [1.0 0.8 0.0];  slosh_sym_R = '◐ Sloshing';
    else
        slosh_col_R = [1.0 0.3 0.2];  slosh_sym_R = '● SPILLING!';
    end
    set(txt_slosh_R, 'Position', [xR, -0.08], ...
        'String', slosh_sym_R, 'Color', slosh_col_R);

    %% Update comparison plot
    set(h_trace_none,  'XData', res_L.t(1:k),  ...
                       'YData', rad2deg(abs(res_L.theta(1:k))));
    set(h_trace_sbsfc, 'XData', res_R.t(1:k), ...
                       'YData', rad2deg(abs(res_R.theta(1:k))));
    set(h_tline, 'Value', tk);

    %% Frame timing / video capture
    if do_video
        drawnow;
        writeVideo(vw, getframe(fig));
    else
        elapsed = toc;
        pause_time = frame_dt - elapsed;
        if pause_time > 0.002
            pause(pause_time);
        else
            drawnow;
        end
    end
end

if do_video
    close(vw);
    fprintf('Video saved: %s\n', save_path);
end
fprintf('Animation complete. Scenario: %s\n', scenario_name);
end

%% ══════════════════════════════════════════════════════════════════════════
%  LOCAL: create all patch/line objects for one robot
%% ══════════════════════════════════════════════════════════════════════════
function g = make_robot_graphics(ax, WHEEL_R, BASE_W, BASE_H, ...
    POLE_W, POLE_H, TRAY_W, TRAY_H, CUP_W, CUP_H)

circle = linspace(0, 2*pi, 32);

% Wheels
g.wL = patch(ax, NaN, NaN, [0.22 0.22 0.22], 'EdgeColor',[0.6 0.6 0.6],'LineWidth',1.5);
g.wR = patch(ax, NaN, NaN, [0.22 0.22 0.22], 'EdgeColor',[0.6 0.6 0.6],'LineWidth',1.5);
% Wheel hub dots
g.hL = plot(ax, NaN, NaN, 'o', 'MarkerSize',4, 'Color',[0.7 0.7 0.7], 'MarkerFaceColor',[0.7 0.7 0.7]);
g.hR = plot(ax, NaN, NaN, 'o', 'MarkerSize',4, 'Color',[0.7 0.7 0.7], 'MarkerFaceColor',[0.7 0.7 0.7]);

% Base body
g.base = patch(ax, NaN, NaN, [0.28 0.33 0.40], 'EdgeColor',[0.5 0.55 0.6],'LineWidth',1.5);

% Pole (vertical column connecting base to tray)
g.pole = patch(ax, NaN, NaN, [0.55 0.58 0.62], 'EdgeColor',[0.45 0.48 0.52],'LineWidth',1);

% Tray platform (green)
g.tray = patch(ax, NaN, NaN, [0.20 0.65 0.30], 'EdgeColor',[0.1 0.50 0.15],'LineWidth',2.5);

% Cup outline
g.cup = patch(ax, NaN, NaN, [0.75 0.82 0.92], 'EdgeColor',[0.4 0.5 0.65],'LineWidth',2);

% Water fill (color changes with sloshing severity)
g.water = patch(ax, NaN, NaN, [0.25 0.55 0.95], ...
    'EdgeColor','none', 'FaceAlpha', 0.85);

% Water surface line
g.surface = plot(ax, NaN, NaN, '-', 'Color', [0.7 0.85 1.0], 'LineWidth', 2);

% Pendulum rod
g.rod = plot(ax, NaN, NaN, '-', 'Color', [0.7 0.7 0.75], 'LineWidth', 2);

% Pendulum bob (represents liquid center of mass)
g.bob = patch(ax, NaN, NaN, [0.3 0.55 1.0], 'EdgeColor',[0.1 0.3 0.8],'LineWidth',1.5);

% θ arc (sloshing angle indicator)
g.theta_arc = plot(ax, NaN, NaN, '-', 'Color', [1.0 0.7 0.2], 'LineWidth', 2.5);

% ψ arc (pitch angle indicator)
g.psi_arc   = plot(ax, NaN, NaN, '-', 'Color', [0.9 0.4 0.9], 'LineWidth', 2.0);

% Labels for angles
g.lbl_theta = text(ax, NaN, NaN, '\theta', 'FontSize', 13, 'FontWeight', 'bold', ...
    'Color', [1.0 0.7 0.2], 'HorizontalAlignment', 'center');
g.lbl_psi   = text(ax, NaN, NaN, '\psi',   'FontSize', 13, 'FontWeight', 'bold', ...
    'Color', [0.9 0.4 0.9], 'HorizontalAlignment', 'center');

% Disturbance arrow
g.arrow = quiver(ax, 0, 0, 0, 0, 0, 'LineWidth', 3.5, ...
    'Color', [1 0.3 0.1], 'MaxHeadSize', 3, 'Visible', 'off');

% Disturbance label
g.lbl_dist = text(ax, NaN, NaN, 'PUSH!', 'FontSize', 11, 'FontWeight', 'bold', ...
    'Color', [1 0.4 0.2], 'HorizontalAlignment', 'center', 'Visible', 'off');

% Velocity arrow (shows direction of motion)
g.vel_arrow = quiver(ax, 0, 0, 0, 0, 0, 'LineWidth', 2.5, ...
    'Color', [0.4 0.8 1.0], 'MaxHeadSize', 2);

% Store circle template
g.circle = circle;
end

%% ══════════════════════════════════════════════════════════════════════════
%  LOCAL: update all graphics objects for one robot frame
%% ══════════════════════════════════════════════════════════════════════════
function update_robot(g, xk, psik, thk, dF, vk, ...
    WHEEL_R, BASE_W, BASE_H, POLE_W, POLE_H, TRAY_W, TRAY_H, ...
    CUP_W, CUP_H, PEND_L, BASE_Y, TRAY_Y, is_sbsfc)

circle = g.circle;
c = cos(psik); s = sin(psik);

% Rotate-and-translate helper
R = @(pts, ox, oy) [c*pts(1,:) - s*pts(2,:) + ox; ...
                    s*pts(1,:) + c*pts(2,:) + oy];

%% Wheels (don't pitch — they stay on ground)
wL_x = xk - BASE_W*0.35;
wR_x = xk + BASE_W*0.35;
set(g.wL, 'XData', WHEEL_R*cos(circle) + wL_x, ...
          'YData', WHEEL_R*sin(circle) + WHEEL_R);
set(g.wR, 'XData', WHEEL_R*cos(circle) + wR_x, ...
          'YData', WHEEL_R*sin(circle) + WHEEL_R);
set(g.hL, 'XData', wL_x, 'YData', WHEEL_R);
set(g.hR, 'XData', wR_x, 'YData', WHEEL_R);

%% Base body
bx = [-BASE_W/2, BASE_W/2, BASE_W/2, -BASE_W/2];
by = [0,          0,          BASE_H,    BASE_H  ];
bp = R([bx; by], xk, BASE_Y);
set(g.base, 'XData', bp(1,:), 'YData', bp(2,:));

%% Pole (the tall vertical column)
px = [-POLE_W/2, POLE_W/2, POLE_W/2, -POLE_W/2];
py = [0,          0,          POLE_H,    POLE_H  ];
pp = R([px; py], xk, BASE_Y + BASE_H);
set(g.pole, 'XData', pp(1,:), 'YData', pp(2,:));

%% Tray
tx = [-TRAY_W/2, TRAY_W/2, TRAY_W/2, -TRAY_W/2];
ty = [0,          0,          TRAY_H,    TRAY_H  ];
tp = R([tx; ty], xk, TRAY_Y);
set(g.tray, 'XData', tp(1,:), 'YData', tp(2,:));

% Tray center (pivot for pendulum and cup)
tray_cx = xk - s*(TRAY_H/2 + CUP_H/2);
tray_cy = TRAY_Y + c*(TRAY_H/2 + CUP_H/2);

%% Cup outline
cup_pts_x = [-CUP_W/2, CUP_W/2, CUP_W/2*0.85, -CUP_W/2*0.85];
cup_pts_y = [0,          0,          CUP_H,          CUP_H        ];
cup_p = R([cup_pts_x; cup_pts_y], xk, TRAY_Y + TRAY_H);
set(g.cup, 'XData', cup_p(1,:), 'YData', cup_p(2,:));

%% Water inside cup (tilted trapezoid — tilt exaggerated ×3 for visibility)
water_tilt  = thk * 3;
water_fill  = 0.65;                      % fill fraction
base_height = CUP_H * water_fill;
left_h  = max(0.005, min(CUP_H*0.95, base_height + sin(water_tilt)*CUP_W/2));
right_h = max(0.005, min(CUP_H*0.95, base_height - sin(water_tilt)*CUP_W/2));

wx = [-CUP_W/2+0.006, CUP_W/2-0.006, CUP_W/2-0.006, -CUP_W/2+0.006];
wy = [0.005,          0.005,           right_h,         left_h        ];
wp = R([wx; wy], xk, TRAY_Y + TRAY_H);
set(g.water, 'XData', wp(1,:), 'YData', wp(2,:));

% Water color: green (calm) → yellow → red (sloshing)
sev = min(abs(thk) / deg2rad(12), 1);
if is_sbsfc
    wcolor = [0.10 + 0.50*sev, 0.50 - 0.10*sev, 0.90 - 0.30*sev];
else
    wcolor = [0.20 + 0.75*sev, 0.50 - 0.45*sev, 0.90 - 0.70*sev];
end
set(g.water, 'FaceColor', wcolor);

% Water surface line
surf_p = R([wx(3:4); wy(3:4)], xk, TRAY_Y + TRAY_H);
set(g.surface, 'XData', surf_p(1,:), 'YData', surf_p(2,:));

%% Pendulum (hangs from tray center)
abs_angle = psik + thk;   % absolute angle in world frame
pend_ex   = tray_cx + PEND_L * sin(abs_angle);
pend_ey   = tray_cy - PEND_L * cos(abs_angle);
set(g.rod, 'XData', [tray_cx, pend_ex], 'YData', [tray_cy, pend_ey]);

bob_r = 0.022;
set(g.bob, 'XData', bob_r*cos(circle) + pend_ex, ...
           'YData', bob_r*sin(circle) + pend_ey);
% Bob color matches water severity
set(g.bob, 'FaceColor', wcolor);

%% θ arc indicator (sloshing angle, drawn from tray center)
arc_r = PEND_L * 0.45;
if abs(thk) > deg2rad(0.1)
    theta_arc_angles = linspace(psik - pi/2, abs_angle - pi/2, 20);
    set(g.theta_arc, ...
        'XData', tray_cx + arc_r * cos(theta_arc_angles), ...
        'YData', tray_cy + arc_r * sin(theta_arc_angles));
    set(g.lbl_theta, ...
        'Position', [tray_cx + arc_r*1.15*cos(mean(theta_arc_angles)), ...
                     tray_cy + arc_r*1.15*sin(mean(theta_arc_angles))]);
else
    set(g.theta_arc, 'XData', NaN, 'YData', NaN);
    set(g.lbl_theta, 'Position', [NaN, NaN]);
end

%% ψ arc indicator (pitch angle, from base)
psi_base_y = BASE_Y + BASE_H/2;
psi_r      = 0.22;
if abs(psik) > deg2rad(0.3)
    psi_arc_angles = linspace(-pi/2, psik - pi/2, 20);
    set(g.psi_arc, ...
        'XData', xk + psi_r * cos(psi_arc_angles), ...
        'YData', psi_base_y + psi_r * sin(psi_arc_angles));
    set(g.lbl_psi, ...
        'Position', [xk + psi_r*1.2*cos(mean(psi_arc_angles)), ...
                     psi_base_y + psi_r*1.2*sin(mean(psi_arc_angles))]);
else
    set(g.psi_arc, 'XData', NaN, 'YData', NaN);
    set(g.lbl_psi, 'Position', [NaN, NaN]);
end

%% Disturbance arrow
if abs(dF) > 0.5
    arr_x = xk + sign(dF)*0.7;
    arr_y = BASE_Y + BASE_H/2;
    set(g.arrow, 'XData', arr_x, 'YData', arr_y, ...
        'UData', -sign(dF)*0.35, 'VData', 0, 'Visible', 'on');
    set(g.lbl_dist, 'Position', [arr_x + sign(dF)*0.1, arr_y + 0.12], ...
        'Visible', 'on');
else
    set(g.arrow,    'Visible', 'off');
    set(g.lbl_dist, 'Visible', 'off');
end

%% Velocity arrow (blue, shows direction of motion)
set(g.vel_arrow, 'XData', xk, 'YData', WHEEL_R*1.5, ...
    'UData', 0.30 * tanh(5*vk), 'VData', 0);

end
