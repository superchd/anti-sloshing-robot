%% Run Side-by-Side Comparison Animation
%  LPF (left) vs SBSFC (right)
%  Just click "Run" in MATLAB to execute.
%
%  Why LPF vs SBSFC?
%    'none' = u=0, robot doesn't move at all (useless for comparison)
%    'lpf'  = basic LQT + low-pass filter (robot moves, but more sloshing)
%    'sbsfc'= full controller (input shaping + LQT + DOB + compensator)

p = parameters();

% Change scenario here: 1=sudden start, 2=speed bumps, 4=external push
[v_ref, dist, name] = scenarios(1, p);

% Run both simulations
res_lpf   = simulate_system(v_ref, p, 'lpf',   dist);
res_sbsfc = simulate_system(v_ref, p, 'sbsfc', dist);

% Play animation: LPF (left) vs SBSFC (right)
animate_comparison(res_lpf, res_sbsfc, name, 8, '', 'LPF Only', 'SBSFC');

% To save as video, uncomment the line below:
% animate_comparison(res_lpf, res_sbsfc, name, 8, '../results/comparison.mp4', 'LPF Only', 'SBSFC');
