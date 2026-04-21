function create_simulink_diagram()
%CREATE_SIMULINK_DIAGRAM
% Builds a Simulink block diagram for the Anti-Sloshing Serving Robot,
% mirroring the MathWorks MPC cart-pole example structure.
%
% Reference image:
%   MathWorks: Signal1/Disturbance → MPC ← x_Ref,theta_Ref
%              MPC → Pendulum & Cart → Scope + Animation
%
% This version:
%   Disturbance → SBSFC ← v_Ref, psi_Ref
%   SBSFC → Serving Robot System → Scope + Animation
%
% Run from the matlab/ directory.
% After running: open antisloshing_robot.slx, then File > Export > PNG for PPT

mdl = 'antisloshing_robot';
if bdIsLoaded(mdl), close_system(mdl, 0); end
new_system(mdl);
open_system(mdl);
set_param(mdl, 'Location', [50 50 1350 800]);
set_param(mdl, 'ZoomFactor', '100');

% Helper: position [left top right bottom] from center + size
pos = @(cx, cy, w, h) [cx-w/2, cy-h/2, cx+w/2, cy+h/2];
p = pos;   % shorthand used throughout

%% ════════════════════════════════════════════════════════════════════════
%  COMPUTE ACTUAL PARAMETERS — loaded into Simulink blocks via workspace
%% ════════════════════════════════════════════════════════════════════════
prm      = parameters();                         % physical params struct
[A_mat, B_mat] = build_state_space(prm);         % linearized robot body
[K_mat, ~]     = design_lqt(A_mat, B_mat, prm); % LQT feedback gains

% Combined input matrix: [B_control, B_disturbance]
B_dist = [0; 1/prm.I_p; 0; 1/prm.m];
B_full = [B_mat, B_dist];                        % 4×2: [u, dF]

% Push to base workspace so Simulink blocks can reference by name
assignin('base', 'A_mat',   A_mat);
assignin('base', 'B_full',  B_full);
assignin('base', 'K_mat',   K_mat);
assignin('base', 'prm',     prm);

fprintf('Parameters loaded into workspace.\n');
fprintf('  Sloshing freq: %.3f rad/s\n', prm.omega_f);
fprintf('  K_mat = [%.3f  %.3f  %.3f  %.3f]\n', K_mat);

%% ════════════════════════════════════════════════════════════════════════
%  REFERENCE INPUTS  (left side)
%% ════════════════════════════════════════════════════════════════════════

% Velocity reference — step signal (0 → 0.5 m/s at t=1s)
add_block('simulink/Sources/Step', [mdl '/v_Ref'], ...
    'Position',   p(80, 195, 65, 28), ...
    'Time',       '1', ...
    'Before',     '0', ...
    'After',      '0.5', ...
    'SampleTime', '0');

% Pitch angle reference = 0  (keep robot upright)
add_block('simulink/Sources/Constant', [mdl '/psi_Ref'], ...
    'Position', p(80, 270, 65, 28), ...
    'Value',    '0');

%% ════════════════════════════════════════════════════════════════════════
%  DISTURBANCE  (top center)
%% ════════════════════════════════════════════════════════════════════════
add_block('simulink/Sources/Pulse Generator', [mdl '/Disturbance'], ...
    'Position',  p(430, 75, 85, 38), ...
    'Amplitude', '15', ...
    'Period',    '10', ...
    'PulseWidth','10', ...
    'PhaseDelay','5');

%% ════════════════════════════════════════════════════════════════════════
%  MUX: combine v_Ref + psi_Ref → SBSFC reference input
%% ════════════════════════════════════════════════════════════════════════
add_block('simulink/Signal Routing/Mux', [mdl '/Mux_r'], ...
    'Position',      p(155, 232, 8, 88), ...
    'Inputs',        '2', ...
    'DisplayOption', 'none');

%% ════════════════════════════════════════════════════════════════════════
%  CLASSICAL CONTROLLER SUBSYSTEM
%   Full name shown on block: "Classical Anti-Sloshing Controller"
%   Internal components shown so viewers understand without knowing SBSFC:
%
%   r (v_ref, psi_ref) ──► [1. Input Shaping] ──► v_smooth
%                                                       │
%   mo [x,x_dot,psi,psi_dot] ──► [2. LQT ] ──► u_lqt ─┐
%                            └──► [3. DOB ] ──► u_dob ─►[Σ]──► mv (u)
%                            └──► [4. Aux  ] ──► u_aux ─┘
%% ════════════════════════════════════════════════════════════════════════
add_block('simulink/Ports & Subsystems/Subsystem', [mdl '/SBSFC'], ...
    'Position',       p(278, 230, 135, 130), ...
    'ShowPortLabels', 'FromPortIcon');

% Rename the block label so viewers see the full meaning
set_param([mdl '/SBSFC'], 'Name', 'Classical Anti-Sloshing Controller');

% Clear default In1→Out1
delete_line([mdl '/Classical Anti-Sloshing Controller'], 'In1/1', 'Out1/1');
delete_block([mdl '/Classical Anti-Sloshing Controller/In1']);
delete_block([mdl '/Classical Anti-Sloshing Controller/Out1']);

ss = [mdl '/Classical Anti-Sloshing Controller'];   % shorthand

% ── Input ports ──────────────────────────────────────────────────────────
add_block('simulink/Ports & Subsystems/In1', [ss '/v_ref (velocity ref)'], ...
    'Position', p(50, 70, 30, 14), 'Port', '1');
add_block('simulink/Ports & Subsystems/In1', [ss '/q (robot states)'], ...
    'Position', p(50, 200, 30, 14), 'Port', '2');

% ── Output port ───────────────────────────────────────────────────────────
add_block('simulink/Ports & Subsystems/Out1', [ss '/u (accel cmd)'], ...
    'Position', p(440, 135, 30, 14), 'Port', '1');

% ── 1. Input Shaping ─────────────────────────────────────────────────────
%    Smooths v_ref to avoid exciting sloshing natural frequency (9.9 rad/s)
add_block('simulink/Ports & Subsystems/Subsystem', [ss '/1. Input Shaping'], ...
    'Position', p(140, 70, 100, 35));
set_param([ss '/1. Input Shaping'], 'BackgroundColor', 'cyan');
% Internals: just a low-pass filter placeholder
delete_line([ss '/1. Input Shaping'], 'In1/1', 'Out1/1');
delete_block([ss '/1. Input Shaping/In1']);
delete_block([ss '/1. Input Shaping/Out1']);
add_block('simulink/Ports & Subsystems/In1',  [ss '/1. Input Shaping/in'],  'Position', p(50,50,30,14),  'Port','1');
add_block('simulink/Ports & Subsystems/Out1', [ss '/1. Input Shaping/out'], 'Position', p(200,50,30,14), 'Port','1');
add_block('simulink/Continuous/Transfer Fcn', [ss '/1. Input Shaping/LPF'], ...
    'Position', p(125,50,70,25), ...
    'Numerator',   '[1]', ...
    'Denominator', '[0.1 1]');   % simple 1st-order LP — replace with shaping filter
add_line([ss '/1. Input Shaping'], 'in/1',  'LPF/1');
add_line([ss '/1. Input Shaping'], 'LPF/1', 'out/1');

% ── 2. LQT (Linear Quadratic Tracking) ───────────────────────────────────
%    State feedback: tracks v_ref, keeps pitch ψ ≈ 0
add_block('simulink/Ports & Subsystems/Subsystem', [ss '/2. LQT (State Feedback)'], ...
    'Position', p(140, 145, 100, 35));
set_param([ss '/2. LQT (State Feedback)'], 'BackgroundColor', 'cyan');
delete_line([ss '/2. LQT (State Feedback)'], 'In1/1', 'Out1/1');
delete_block([ss '/2. LQT (State Feedback)/In1']);
delete_block([ss '/2. LQT (State Feedback)/Out1']);
add_block('simulink/Ports & Subsystems/In1',  [ss '/2. LQT (State Feedback)/q'],    'Position', p(50,70,30,14),  'Port','1');
add_block('simulink/Ports & Subsystems/In1',  [ss '/2. LQT (State Feedback)/v_d'],  'Position', p(50,110,30,14), 'Port','2');
add_block('simulink/Ports & Subsystems/Out1', [ss '/2. LQT (State Feedback)/u_lqt'],'Position', p(200,90,30,14), 'Port','1');
add_block('simulink/Math Operations/Gain',    [ss '/2. LQT (State Feedback)/K'],     'Position', p(130,90,50,25), 'Gain','K_mat', 'Multiplication', 'Matrix(K*u)');
add_line([ss '/2. LQT (State Feedback)'], 'q/1',   'K/1');
add_line([ss '/2. LQT (State Feedback)'], 'K/1',   'u_lqt/1');
add_block('simulink/Sinks/Terminator', [ss '/2. LQT (State Feedback)/T'], 'Position', p(130,110,20,14));
add_line([ss '/2. LQT (State Feedback)'], 'v_d/1', 'T/1');

% ── 3. DOB (Disturbance Observer) ────────────────────────────────────────
%    Estimates & cancels external forces (bumps, pushes)
add_block('simulink/Ports & Subsystems/Subsystem', [ss '/3. DOB (Dist. Observer)'], ...
    'Position', p(140, 210, 100, 35));
set_param([ss '/3. DOB (Dist. Observer)'], 'BackgroundColor', 'cyan');
delete_line([ss '/3. DOB (Dist. Observer)'], 'In1/1', 'Out1/1');
delete_block([ss '/3. DOB (Dist. Observer)/In1']);
delete_block([ss '/3. DOB (Dist. Observer)/Out1']);
add_block('simulink/Ports & Subsystems/In1',  [ss '/3. DOB (Dist. Observer)/q'],    'Position', p(50,90,30,14),  'Port','1');
add_block('simulink/Ports & Subsystems/Out1', [ss '/3. DOB (Dist. Observer)/u_dob'],'Position', p(200,90,30,14), 'Port','1');
add_block('simulink/Math Operations/Gain',    [ss '/3. DOB (Dist. Observer)/eta'],   'Position', p(130,90,50,25), 'Gain','1');
add_line([ss '/3. DOB (Dist. Observer)'], 'q/1',   'eta/1');
add_line([ss '/3. DOB (Dist. Observer)'], 'eta/1', 'u_dob/1');

% ── 4. Auxiliary Compensator ─────────────────────────────────────────────
%    Damps residual pitch oscillation
add_block('simulink/Ports & Subsystems/Subsystem', [ss '/4. Aux Compensator'], ...
    'Position', p(140, 275, 100, 35));
set_param([ss '/4. Aux Compensator'], 'BackgroundColor', 'cyan');
delete_line([ss '/4. Aux Compensator'], 'In1/1', 'Out1/1');
delete_block([ss '/4. Aux Compensator/In1']);
delete_block([ss '/4. Aux Compensator/Out1']);
add_block('simulink/Ports & Subsystems/In1',  [ss '/4. Aux Compensator/psi'],   'Position', p(50,90,30,14),  'Port','1');
add_block('simulink/Ports & Subsystems/Out1', [ss '/4. Aux Compensator/u_aux'], 'Position', p(200,90,30,14), 'Port','1');
add_block('simulink/Math Operations/Gain',    [ss '/4. Aux Compensator/Kc'],    'Position', p(130,90,50,25), 'Gain','0.001');
add_line([ss '/4. Aux Compensator'], 'psi/1', 'Kc/1');
add_line([ss '/4. Aux Compensator'], 'Kc/1',  'u_aux/1');

% ── Sum: u_lqt + u_dob + u_aux → u_total ────────────────────────────────
add_block('simulink/Math Operations/Sum', [ss '/Sum_u'], ...
    'Position',  p(350, 135, 25, 60), ...
    'Inputs',    '+++', ...
    'IconShape', 'rectangular');

% ── Internal connections ──────────────────────────────────────────────────
% v_ref → Input Shaping → LQT (v_d input)
add_line(ss, 'v_ref (velocity ref)/1', '1. Input Shaping/1',       'autorouting','on');
add_line(ss, '1. Input Shaping/1',     '2. LQT (State Feedback)/2','autorouting','on');

% q → LQT, DOB, Aux (fan out)
add_line(ss, 'q (robot states)/1', '2. LQT (State Feedback)/1', 'autorouting','on');
add_line(ss, 'q (robot states)/1', '3. DOB (Dist. Observer)/1', 'autorouting','on');
add_line(ss, 'q (robot states)/1', '4. Aux Compensator/1',      'autorouting','on');

% u_lqt, u_dob, u_aux → Sum
add_line(ss, '2. LQT (State Feedback)/1', 'Sum_u/1', 'autorouting','on');
add_line(ss, '3. DOB (Dist. Observer)/1', 'Sum_u/2', 'autorouting','on');
add_line(ss, '4. Aux Compensator/1',      'Sum_u/3', 'autorouting','on');

% Sum → output
add_line(ss, 'Sum_u/1', 'u (accel cmd)/1', 'autorouting','on');

% Color outer block
set_param([mdl '/Classical Anti-Sloshing Controller'], 'BackgroundColor', 'cyan');

%% ════════════════════════════════════════════════════════════════════════
%  SERVING ROBOT SYSTEM SUBSYSTEM
%   Ports:  dF    (in 1)  — external disturbance force
%           u     (in 2)  — control acceleration command
%           x     (out 1) — robot position
%           x_dot (out 2) — robot velocity
%           psi   (out 3) — robot pitch angle
%           psi_dot (out 4) — robot pitch rate
%           theta (out 5) — sloshing angle
%% ════════════════════════════════════════════════════════════════════════
add_block('simulink/Ports & Subsystems/Subsystem', ...
    [mdl '/Serving_Robot_System'], ...
    'Position',       p(530, 215, 170, 215), ...
    'ShowPortLabels', 'FromPortIcon');

Simulink.SubSystem.deleteContents([mdl '/Serving_Robot_System']);

% Input ports
add_block('simulink/Ports & Subsystems/In1', ...
    [mdl '/Serving_Robot_System/dF'], ...
    'Position', p(55, 80, 30, 14), 'Port', '1');
add_block('simulink/Ports & Subsystems/In1', ...
    [mdl '/Serving_Robot_System/u'], ...
    'Position', p(55, 195, 30, 14), 'Port', '2');

% Output ports
out_labels = {'x', 'x_dot', 'psi', 'psi_dot', 'theta'};
out_y_pos  = [100, 140, 180, 220, 265];
for i = 1:numel(out_labels)
    add_block('simulink/Ports & Subsystems/Out1', ...
        [mdl '/Serving_Robot_System/' out_labels{i}], ...
        'Position', p(330, out_y_pos(i), 30, 14), ...
        'Port', num2str(i));
end

rs = [mdl '/Serving_Robot_System'];   % shorthand

% ── Mux: combine [u; dF] → 2-input state-space ───────────────────────────
add_block('simulink/Signal Routing/Mux', [rs '/Mux_inputs'], ...
    'Position', p(120, 150, 8, 60), 'Inputs', '2', 'DisplayOption', 'none');
add_line([mdl '/Serving_Robot_System'], 'u/1',  'Mux_inputs/1');
add_line([mdl '/Serving_Robot_System'], 'dF/1', 'Mux_inputs/2');

% ── Robot Body: q_dot = A*q + B_full*[u; dF]  (actual A, B from workspace)
add_block('simulink/Continuous/State-Space', [rs '/Robot_Body'], ...
    'Position', p(200, 150, 80, 55), ...
    'A',  'A_mat', ...      % from workspace: build_state_space output
    'B',  'B_full', ...     % from workspace: [B_mat, B_dist] (2 inputs)
    'C',  'eye(4)', ...
    'D',  'zeros(4,2)', ...
    'X0', 'zeros(4,1)');
add_line([mdl '/Serving_Robot_System'], 'Mux_inputs/1', 'Robot_Body/1');

% ── Demux robot states → [psi, psi_dot, x, x_dot] output ports ───────────
%    Note: state order in A is [psi, psi_dot, x, x_dot]
%    Output ports order: x(1), x_dot(2), psi(3), psi_dot(4)
add_block('simulink/Signal Routing/Demux', [rs '/Demux_q'], ...
    'Position', p(310, 150, 8, 60), 'Outputs', '4');
add_line([mdl '/Serving_Robot_System'], 'Robot_Body/1', 'Demux_q/1');

% q states: [psi=1, psi_dot=2, x=3, x_dot=4] → output ports reordered
% out port 1=x, 2=x_dot, 3=psi, 4=psi_dot
add_line([mdl '/Serving_Robot_System'], 'Demux_q/3', 'x/1');       % x
add_line([mdl '/Serving_Robot_System'], 'Demux_q/4', 'x_dot/1');   % x_dot
add_line([mdl '/Serving_Robot_System'], 'Demux_q/1', 'psi/1');     % psi
add_line([mdl '/Serving_Robot_System'], 'Demux_q/2', 'psi_dot/1'); % psi_dot

% ── Sloshing Pendulum (nonlinear): theta dynamics ─────────────────────────
%    theta_ddot = -(g/l)*sin(theta) - b/(m*l^2)*theta_dot + (1/l)*u*cos(theta)
%    u(1)=accel, u(2)=theta, u(3)=theta_dot
%
%    Implemented as: Mux → Fcn → Integrator(theta_dot) → Integrator(theta)
%    with feedback of theta and theta_dot back into Fcn

add_block('simulink/Signal Routing/Mux', [rs '/Mux_slosh'], ...
    'Position', p(155, 270, 8, 55), 'Inputs', '3', 'DisplayOption', 'none');

slosh_eq = ['-(9.81/0.15)*sin(u(2)) - (0.01/(0.5*0.15^2))*u(3)' ...
            ' + (1/0.15)*u(1)*cos(u(2))'];
add_block('simulink/User-Defined Functions/Fcn', [rs '/Slosh_Fcn'], ...
    'Position', p(230, 270, 90, 25), 'Expr', slosh_eq);

add_block('simulink/Continuous/Integrator', [rs '/Int_theta_dot'], ...
    'Position', p(350, 270, 50, 25), 'InitialCondition', '0');
add_block('simulink/Continuous/Integrator', [rs '/Int_theta'], ...
    'Position', p(430, 270, 50, 25), 'InitialCondition', '0');

% Forward path: Mux → Fcn → theta_ddot → theta_dot → theta
add_line([mdl '/Serving_Robot_System'], 'Mux_slosh/1',    'Slosh_Fcn/1');
add_line([mdl '/Serving_Robot_System'], 'Slosh_Fcn/1',    'Int_theta_dot/1');
add_line([mdl '/Serving_Robot_System'], 'Int_theta_dot/1','Int_theta/1');
add_line([mdl '/Serving_Robot_System'], 'Int_theta/1',    'theta/1');

% Inputs to sloshing Mux: [u, theta, theta_dot]
add_line([mdl '/Serving_Robot_System'], 'u/1',           'Mux_slosh/1', 'autorouting','on');
add_line([mdl '/Serving_Robot_System'], 'Int_theta/1',   'Mux_slosh/2', 'autorouting','on');
add_line([mdl '/Serving_Robot_System'], 'Int_theta_dot/1','Mux_slosh/3','autorouting','on');

% Color the plant block orange
set_param([mdl '/Serving_Robot_System'], 'BackgroundColor', 'orange');

%% ════════════════════════════════════════════════════════════════════════
%  SCOPE  (right side)
%% ════════════════════════════════════════════════════════════════════════
add_block('simulink/Sinks/Scope', [mdl '/Scope'], ...
    'Position',       p(790, 185, 50, 140), ...
    'NumInputPorts',  '5');

%% ════════════════════════════════════════════════════════════════════════
%  ANIMATION block  (bottom right, mirrors reference image)
%% ════════════════════════════════════════════════════════════════════════
add_block('simulink/Sinks/To Workspace', [mdl '/Animation'], ...
    'Position',      p(800, 395, 80, 38), ...
    'VariableName',  'sim_out', ...
    'MaxDataPoints', 'inf');

%% ════════════════════════════════════════════════════════════════════════
%  MUX: 5 signals → Scope
%% ════════════════════════════════════════════════════════════════════════
add_block('simulink/Signal Routing/Mux', [mdl '/Mux_scope'], ...
    'Position',      p(745, 185, 8, 140), ...
    'Inputs',        '5', ...
    'DisplayOption', 'none');

%% ════════════════════════════════════════════════════════════════════════
%  MUX: 4 signals → Animation
%% ════════════════════════════════════════════════════════════════════════
add_block('simulink/Signal Routing/Mux', [mdl '/Mux_anim'], ...
    'Position',      p(745, 382, 8, 80), ...
    'Inputs',        '4', ...
    'DisplayOption', 'none');

%% ════════════════════════════════════════════════════════════════════════
%  MUX: feedback y → SBSFC mo input  [x; x_dot; psi; psi_dot]
%% ════════════════════════════════════════════════════════════════════════
add_block('simulink/Signal Routing/Mux', [mdl '/Mux_y'], ...
    'Position',      p(680, 510, 8, 110), ...
    'Inputs',        '4', ...
    'DisplayOption', 'none');

%% ════════════════════════════════════════════════════════════════════════
%  CONNECTIONS
%% ════════════════════════════════════════════════════════════════════════

% --- References → Mux_r → SBSFC ref input ---
add_line(mdl, 'v_Ref/1',   'Mux_r/1', 'autorouting', 'on');
add_line(mdl, 'psi_Ref/1', 'Mux_r/2', 'autorouting', 'on');
add_line(mdl, 'Mux_r/1',   'Classical Anti-Sloshing Controller/1', 'autorouting', 'on');

% --- Disturbance → Robot System dF ---
add_line(mdl, 'Disturbance/1', 'Serving_Robot_System/1', 'autorouting', 'on');

% --- SBSFC mv → Robot System u ---
add_line(mdl, 'Classical Anti-Sloshing Controller/1', 'Serving_Robot_System/2', 'autorouting', 'on');

% --- Robot System outputs → Mux_scope → Scope ---
for i = 1:5
    add_line(mdl, ['Serving_Robot_System/' num2str(i)], ...
        ['Mux_scope/' num2str(i)], 'autorouting', 'on');
end
add_line(mdl, 'Mux_scope/1', 'Scope/1', 'autorouting', 'on');

% --- Robot System outputs → Mux_y (feedback: x, x_dot, psi, psi_dot) ---
for i = 1:4
    add_line(mdl, ['Serving_Robot_System/' num2str(i)], ...
        ['Mux_y/' num2str(i)], 'autorouting', 'on');
end
add_line(mdl, 'Mux_y/1', 'Classical Anti-Sloshing Controller/2', 'autorouting', 'on');

% --- Robot System outputs → Mux_anim → Animation ---
anim_ports = [1, 3, 5, 2];  % x, psi, theta, x_dot
for i = 1:4
    add_line(mdl, ['Serving_Robot_System/' num2str(anim_ports(i))], ...
        ['Mux_anim/' num2str(i)], 'autorouting', 'on');
end
add_line(mdl, 'Mux_anim/1', 'Animation/1', 'autorouting', 'on');

%% ════════════════════════════════════════════════════════════════════════
%  TITLE ANNOTATION
%% ════════════════════════════════════════════════════════════════════════
try
    % R2019b+ API
    a = Simulink.Annotation([mdl '/title']);
    a.Text     = 'Anti-Sloshing Control: SBSFC vs RL for Food-Serving Robot  |  MECE 6397';
    a.Position = [50, 20];
catch
    % Older MATLAB: skip annotation (add manually in Simulink)
end

%% ════════════════════════════════════════════════════════════════════════
%  SAVE
%% ════════════════════════════════════════════════════════════════════════
save_path = fullfile(fileparts(mfilename('fullpath')), [mdl '.slx']);
save_system(mdl, save_path);

fprintf('\nSaved: %s\n', save_path);
fprintf('\nNext steps:\n');
fprintf('  1. open(''%s'')      — view the diagram\n', [mdl '.slx']);
fprintf('  2. File > Export > Image (PNG)  — screenshot for PPT\n');
fprintf('  3. Fill in SBSFC/K_LQT gain with actual K matrix\n');
fprintf('  4. Replace Robot_Body_Dynamics A,B with build_state_space output\n');

end
