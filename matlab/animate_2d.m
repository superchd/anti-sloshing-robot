function animate_2d(results, scenario_name, speed_factor)
% ANIMATE_2D  2D side-view animation of the serving robot with pendulum
%
% Inputs:
%   results       - struct from simulate_system()
%   scenario_name - string for title
%   speed_factor  - playback speed multiplier (default: 5)

if nargin < 3
    speed_factor = 5;
end

%% Parameters
p = parameters();
dt = results.t(2) - results.t(1);
N  = length(results.t);

% Robot drawing dimensions [m]
body_w  = 0.40;
body_h  = 0.25;
wheel_r = 0.08;
upper_w = 0.30;
upper_h = 0.65;
tray_w  = 0.40;
tray_h  = 0.02;
pend_l  = p.pend_l;
cup_w   = 0.06;
cup_h   = 0.08;

% Vertical layout
ground_y = 0;
base_y   = wheel_r;
upper_y  = base_y + body_h;
tray_y   = upper_y + upper_h;

%% Setup figure
fig = figure('Position', [100 50 1000 740], 'Color', 'w', ...
             'Name', scenario_name);

% --- Control panel (top strip) ---------------------------------------
state.paused  = false;
state.speed   = speed_factor;
state.restart = false;

pnl = uipanel(fig, 'Units', 'normalized', ...
    'Position', [0.0 0.94 1.0 0.06], ...
    'BackgroundColor', [0.93 0.93 0.95], ...
    'BorderType', 'line', 'HighlightColor', [0.7 0.7 0.7]);

btn_pause = uicontrol(pnl, 'Style', 'pushbutton', ...
    'String', '⏸ Pause', 'Units', 'normalized', ...
    'Position', [0.02 0.20 0.10 0.60], 'FontSize', 11, 'FontWeight', 'bold', ...
    'BackgroundColor', [1.0 0.9 0.6], ...
    'Callback', @(src,~) toggle_pause(src));

btn_restart = uicontrol(pnl, 'Style', 'pushbutton', ...
    'String', '⟲ Restart', 'Units', 'normalized', ...
    'Position', [0.13 0.20 0.10 0.60], 'FontSize', 11, ...
    'BackgroundColor', [0.8 0.9 1.0], ...
    'Callback', @(~,~) mark_restart());

uicontrol(pnl, 'Style', 'text', 'String', 'Speed:', ...
    'Units', 'normalized', 'Position', [0.26 0.30 0.06 0.45], ...
    'BackgroundColor', [0.93 0.93 0.95], ...
    'FontSize', 11, 'FontWeight', 'bold', 'HorizontalAlignment', 'right');

sld_speed = uicontrol(pnl, 'Style', 'slider', ...
    'Min', 0.1, 'Max', 10, 'Value', speed_factor, ...
    'SliderStep', [0.01 0.1], ...
    'Units', 'normalized', 'Position', [0.33 0.30 0.35 0.45], ...
    'Callback', @(src,~) update_speed(src));

lbl_speed = uicontrol(pnl, 'Style', 'text', ...
    'String', sprintf('%.1fx', speed_factor), ...
    'Units', 'normalized', 'Position', [0.69 0.30 0.06 0.45], ...
    'BackgroundColor', [0.93 0.93 0.95], ...
    'FontSize', 11, 'FontWeight', 'bold', 'HorizontalAlignment', 'left');

lbl_status = uicontrol(pnl, 'Style', 'text', ...
    'String', '▶ Playing', ...
    'Units', 'normalized', 'Position', [0.80 0.30 0.18 0.45], ...
    'BackgroundColor', [0.93 0.93 0.95], ...
    'FontSize', 11, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
    'ForegroundColor', [0 0.5 0]);

% Top: animation
ax1 = axes('Position', [0.05 0.40 0.90 0.52]);
hold on; axis equal; grid on;
set(ax1, 'Color', [0.96 0.96 0.98]);
title(scenario_name, 'FontSize', 14, 'FontWeight', 'bold');
ylabel('Height [m]');

    function toggle_pause(src)
        state.paused = ~state.paused;
        if state.paused
            set(src, 'String', '▶ Resume', 'BackgroundColor', [0.6 1.0 0.6]);
            set(lbl_status, 'String', '⏸ Paused', 'ForegroundColor', [0.8 0.3 0]);
        else
            set(src, 'String', '⏸ Pause', 'BackgroundColor', [1.0 0.9 0.6]);
            set(lbl_status, 'String', '▶ Playing', 'ForegroundColor', [0 0.5 0]);
        end
    end

    function update_speed(src)
        state.speed = get(src, 'Value');
        set(lbl_speed, 'String', sprintf('%.1fx', state.speed));
    end

    function mark_restart()
        state.restart = true;
    end

% Bottom-left: theta plot (sloshing)
ax2 = axes('Position', [0.08 0.06 0.41 0.25]);
hold on; grid on;
xlabel('Time [s]'); ylabel('|\theta| [deg]');
title('\theta  Sloshing Angle (pendulum)', 'FontSize', 11, 'Color', [0 0 0.7]);
plot(ax2, results.t, rad2deg(abs(results.theta)), '-', ...
     'Color', [0.85 0.85 0.95], 'LineWidth', 1);
h_theta_trace = plot(ax2, NaN, NaN, 'b-', 'LineWidth', 2);
h_time_line   = xline(ax2, 0, 'r-', 'LineWidth', 1.5);
xlim(ax2, [0 results.t(end)]);
yl = max(rad2deg(abs(results.theta))) * 1.3 + 0.5;
ylim(ax2, [0 yl]);

% Bottom-right: psi plot (robot body tilt)
ax3 = axes('Position', [0.56 0.06 0.41 0.25]);
hold on; grid on;
xlabel('Time [s]'); ylabel('|\psi| [deg]');
title('\psi  Robot Body Tilt', 'FontSize', 11, 'Color', [0.7 0 0.5]);
plot(ax3, results.t, rad2deg(abs(results.psi)), '-', ...
     'Color', [0.95 0.88 0.92], 'LineWidth', 1);
h_psi_trace = plot(ax3, NaN, NaN, '-', 'Color', [0.75 0.2 0.6], 'LineWidth', 2);
h_time_line2 = xline(ax3, 0, 'r-', 'LineWidth', 1.5);
xlim(ax3, [0 results.t(end)]);
yl2 = max(rad2deg(abs(results.psi))) * 1.3 + 0.5;
ylim(ax3, [0 yl2]);

%% Pre-draw ground (wide enough)
axes(ax1);
x_min = min(results.x) - 2;
x_max = max(results.x) + 2;
fill([x_min x_max x_max x_min], [-0.15 -0.15 0 0], ...
     [0.85 0.8 0.7], 'EdgeColor', 'none');
plot([x_min x_max], [0 0], 'k-', 'LineWidth', 2);

%% Create patch/line objects
% Wheels
th = linspace(0, 2*pi, 24);
h_wheelL = patch(NaN, NaN, [0.15 0.15 0.15], 'EdgeColor','k','LineWidth',1);
h_wheelR = patch(NaN, NaN, [0.15 0.15 0.15], 'EdgeColor','k','LineWidth',1);

% Base body
h_base = patch(NaN, NaN, [0.35 0.35 0.4], 'EdgeColor','k','LineWidth',1.5);

% Upper body
h_upper = patch(NaN, NaN, [0.78 0.78 0.82], 'EdgeColor',[0.5 0.5 0.5],'LineWidth',1);

% Tray
h_tray = patch(NaN, NaN, [0.3 0.8 0.3], 'EdgeColor',[0.15 0.5 0.15],'LineWidth',2.5);

% Cup
h_cup = patch(NaN, NaN, [0.65 0.82 1.0], 'EdgeColor',[0.3 0.5 0.7],'LineWidth',1.5);

% Water inside cup (will tilt with pendulum angle)
h_water = patch(NaN, NaN, [0.3 0.5 0.9], 'EdgeColor','none', 'FaceAlpha', 0.7);

% Pendulum rod
h_rod = plot(NaN, NaN, '-', 'Color', [0.5 0.5 0.5], 'LineWidth', 2.5);

% Pendulum bob
h_bob = patch(NaN, NaN, [1.0 0.45 0.0], 'EdgeColor',[0.7 0.25 0.0],'LineWidth',1.5);

% Disturbance arrow
h_arrow = quiver(0, 0, 0, 0, 0, 'r', 'LineWidth', 3, 'MaxHeadSize', 2, ...
                 'Visible', 'off');

% Info text
h_txt = text(0, 0, '', 'FontSize', 11, 'FontWeight', 'bold', ...
             'BackgroundColor', [1 1 1 0.85], 'EdgeColor', 'k', 'Margin', 4);

% ── ψ angle indicator (magenta): robot body tilt from vertical ──
% Dashed vertical reference line at robot center
h_psi_ref = plot(NaN, NaN, '--', 'Color', [0.75 0.2 0.6 0.5], 'LineWidth', 1.5);
% Solid line along robot body direction
h_psi_body = plot(NaN, NaN, '-', 'Color', [0.75 0.2 0.6], 'LineWidth', 2.5);
% Arc between them
h_psi_arc = plot(NaN, NaN, '-', 'Color', [0.75 0.2 0.6], 'LineWidth', 2.5);
% Label
h_psi_lbl = text(NaN, NaN, '', 'FontSize', 14, 'FontWeight', 'bold', ...
    'Color', [0.75 0.2 0.6], 'HorizontalAlignment', 'center');

% ── θ angle indicator (orange): pendulum swing from body vertical ──
% Dashed reference line (body-vertical direction, hanging down from tray)
h_th_ref = plot(NaN, NaN, '--', 'Color', [1.0 0.5 0.0 0.5], 'LineWidth', 1.5);
% Pendulum rod is already drawn (h_rod), so just draw the arc
h_th_arc = plot(NaN, NaN, '-', 'Color', [1.0 0.5 0.0], 'LineWidth', 2.5);
% Label
h_th_lbl = text(NaN, NaN, '', 'FontSize', 14, 'FontWeight', 'bold', ...
    'Color', [1.0 0.5 0.0], 'HorizontalAlignment', 'center');

%% Animation timing
target_fps = 30;

%% Main animation loop
k = 1;
while k <= N
    if ~isvalid(fig), return; end

    % Handle restart
    if state.restart
        state.restart = false;
        k = 1;
        continue;
    end

    % Handle pause (spin-wait, keep UI responsive)
    while isvalid(fig) && state.paused && ~state.restart
        pause(0.05);
    end
    if ~isvalid(fig), return; end
    if state.restart, continue; end

    % Dynamic speed from slider
    spd = max(0.1, state.speed);
    frame_step = max(1, round(spd / (dt * target_fps)));
    frame_dt   = frame_step * dt / spd;

    tic;

    xk   = results.x(k);
    psik = results.psi(k);
    thk  = results.theta(k);
    vk   = results.x_dot(k);
    tk   = results.t(k);

    % Rotation matrix for body pitch
    c = cos(psik); s = sin(psik);

    % Helper: rotate and translate
    rot = @(pts, ox, oy) [c*pts(1,:)-s*pts(2,:)+ox; s*pts(1,:)+c*pts(2,:)+oy];

    %% Wheels
    wLc = rot([0;0], xk - 0.12, base_y);
    set(h_wheelL, 'XData', wheel_r*cos(th)+wLc(1), ...
                  'YData', wheel_r*sin(th)+wLc(2));
    wRc = rot([0;0], xk + 0.12, base_y);
    set(h_wheelR, 'XData', wheel_r*cos(th)+wRc(1), ...
                  'YData', wheel_r*sin(th)+wRc(2));

    %% Base body
    bx = [-body_w/2, body_w/2, body_w/2, -body_w/2];
    by = [0, 0, body_h, body_h];
    bp = rot([bx; by], xk, base_y);
    set(h_base, 'XData', bp(1,:), 'YData', bp(2,:));

    %% Upper body
    ux = [-upper_w/2, upper_w/2, upper_w/2, -upper_w/2];
    uy = [0, 0, upper_h, upper_h];
    up = rot([ux; uy], xk, upper_y);
    set(h_upper, 'XData', up(1,:), 'YData', up(2,:));

    %% Tray
    tx = [-tray_w/2, tray_w/2, tray_w/2, -tray_w/2];
    ty = [0, 0, tray_h, tray_h];
    tp = rot([tx; ty], xk, tray_y);
    set(h_tray, 'XData', tp(1,:), 'YData', tp(2,:));

    %% Tray center (pivot point for pendulum)
    tray_cx = xk + (-s) * (tray_h/2);
    tray_cy = tray_y + c * (tray_h/2);

    %% Cup on tray
    cux = [-cup_w/2, cup_w/2, cup_w/2, -cup_w/2];
    cuy = [tray_h, tray_h, tray_h+cup_h, tray_h+cup_h];
    cup_p = rot([cux; cuy], xk, tray_y);
    set(h_cup, 'XData', cup_p(1,:), 'YData', cup_p(2,:));

    %% Water in cup (tilts with pendulum angle)
    water_tilt = thk * 2;  % exaggerate for visibility
    % Water is a trapezoid that tilts
    wh = cup_h * 0.6;  % water height
    left_h  = wh + sin(water_tilt) * cup_w/2;
    right_h = wh - sin(water_tilt) * cup_w/2;
    left_h  = max(0.01, min(cup_h*0.95, left_h));
    right_h = max(0.01, min(cup_h*0.95, right_h));
    wwx = [-cup_w/2+0.005, cup_w/2-0.005, cup_w/2-0.005, -cup_w/2+0.005];
    wwy = [tray_h+0.005, tray_h+0.005, tray_h+right_h, tray_h+left_h];
    wp = rot([wwx; wwy], xk, tray_y);
    set(h_water, 'XData', wp(1,:), 'YData', wp(2,:));

    %% Pendulum
    abs_angle = psik + thk;
    pend_ex = tray_cx + pend_l * sin(abs_angle);
    pend_ey = tray_cy - pend_l * cos(abs_angle);
    set(h_rod, 'XData', [tray_cx pend_ex], 'YData', [tray_cy pend_ey]);

    bob_r = 0.02;
    set(h_bob, 'XData', bob_r*cos(th)+pend_ex, ...
               'YData', bob_r*sin(th)+pend_ey);

    %% ── Draw ψ arc (robot body tilt from vertical) ──────────────────────
    psi_cx = xk;                         % arc center: wheel axle center
    psi_cy = base_y;
    psi_r  = upper_h * 0.55;            % arc radius

    % Dashed vertical reference (true vertical from base)
    set(h_psi_ref, 'XData', [psi_cx, psi_cx], ...
                   'YData', [psi_cy, psi_cy + psi_r * 1.1]);
    % Solid line along tilted body direction
    set(h_psi_body, 'XData', [psi_cx, psi_cx - sin(psik)*psi_r*1.1], ...
                    'YData', [psi_cy, psi_cy + cos(psik)*psi_r*1.1]);

    if abs(psik) > deg2rad(0.2)
        % Draw arc from vertical (pi/2) to body direction (pi/2 - psi)
        n_arc = 20;
        arc_angles = linspace(pi/2, pi/2 - psik, n_arc);
        set(h_psi_arc, 'XData', psi_cx + psi_r * cos(arc_angles), ...
                       'YData', psi_cy + psi_r * sin(arc_angles));
        % Label at midpoint of arc
        mid_a = pi/2 - psik/2;
        set(h_psi_lbl, 'Position', [psi_cx + psi_r*1.25*cos(mid_a), ...
                                     psi_cy + psi_r*1.25*sin(mid_a)], ...
            'String', sprintf('\\psi=%.1f°', rad2deg(psik)));
    else
        set(h_psi_arc, 'XData', NaN, 'YData', NaN);
        set(h_psi_lbl, 'Position', [NaN NaN], 'String', '');
    end

    %% ── Draw θ arc (pendulum sloshing from body vertical) ────────────
    th_r = pend_l * 0.6;  % arc radius

    % Dashed reference: body-vertical direction hanging DOWN from tray
    ref_ex = tray_cx - (-s)*th_r*1.1;   % body-vertical downward
    ref_ey = tray_cy - c*th_r*1.1;
    set(h_th_ref, 'XData', [tray_cx, ref_ex], 'YData', [tray_cy, ref_ey]);

    if abs(thk) > deg2rad(0.2)
        % Arc from body-vertical to pendulum direction
        % Body-vertical (downward) angle in world = psik - pi/2
        % Pendulum angle in world = (psik + thk) - pi/2
        base_ang = psik - pi/2;          % body-vertical pointing down
        pend_ang = (psik + thk) - pi/2;  % actual pendulum direction
        arc_angles = linspace(base_ang, pend_ang, 20);
        set(h_th_arc, 'XData', tray_cx + th_r * cos(arc_angles), ...
                      'YData', tray_cy + th_r * sin(arc_angles));
        mid_a = (base_ang + pend_ang) / 2;
        set(h_th_lbl, 'Position', [tray_cx + th_r*1.35*cos(mid_a), ...
                                    tray_cy + th_r*1.35*sin(mid_a)], ...
            'String', sprintf('\\theta=%.1f°', rad2deg(thk)));
    else
        set(h_th_arc, 'XData', NaN, 'YData', NaN);
        set(h_th_lbl, 'Position', [NaN NaN], 'String', '');
    end

    %% Disturbance arrow
    dk = results.d_ext(k);
    if abs(dk) > 0.5
        arr_x = xk + sign(dk)*0.55;
        arr_y = base_y + body_h/2;
        set(h_arrow, 'XData', arr_x, 'YData', arr_y, ...
            'UData', -sign(dk)*0.3, 'VData', 0, 'Visible', 'on');
    else
        set(h_arrow, 'Visible', 'off');
    end

    %% Info text
    set(h_txt, 'Position', [xk - 1.2, tray_y + 0.22], ...
        'String', sprintf('t = %.1fs   v = %.2f m/s   \\psi = %.1f°   \\theta = %.1f°', ...
                  tk, vk, rad2deg(psik), rad2deg(thk)));

    %% Camera follows robot
    xlim(ax1, [xk - 1.5, xk + 1.5]);
    ylim(ax1, [-0.15, tray_y + 0.55]);

    %% Update bottom plots
    set(h_theta_trace, 'XData', results.t(1:k), ...
                       'YData', rad2deg(abs(results.theta(1:k))));
    set(h_time_line, 'Value', tk);

    set(h_psi_trace, 'XData', results.t(1:k), ...
                     'YData', rad2deg(abs(results.psi(1:k))));
    set(h_time_line2, 'Value', tk);

    %% Frame timing
    elapsed = toc;
    pause_time = frame_dt - elapsed;
    if pause_time > 0
        pause(pause_time);
    else
        drawnow;
    end

    k = k + frame_step;
end

% Hold on the last frame — user can restart or close
if isvalid(fig)
    set(lbl_status, 'String', '■ Done', 'ForegroundColor', [0.3 0.3 0.3]);
end
fprintf('Animation complete.\n');
end
