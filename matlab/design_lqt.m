function [K, K_track] = design_lqt(A, B, p)
% DESIGN_LQT  Design LQR tracking controller (Eq. 3)
%
% Outputs:
%   K       - LQR feedback gain (1x4)
%   K_track - feedforward tracking term: B_pinv * (A + B*K)
%
% Control law: u_t^u = K*q - K_track * q_desired

% Solve continuous algebraic Riccati equation
% MATLAB lqr returns K for u = -K*x, negate to match paper convention u = K*x
[K_lqr, ~, ~] = lqr(A, B, p.Q, p.R);
K = -K_lqr;

% Pseudo-inverse of B for tracking
B_pinv = pinv(B);

% Tracking gain (Eq. 3)
K_track = B_pinv * (A + B*K);

fprintf('LQT controller designed.\n');
fprintf('  K = [%.4f, %.4f, %.4f, %.4f]\n', K);
fprintf('  Closed-loop eigenvalues: [');
cl_eig = eig(A + B*K);
fprintf('%.4f, ', cl_eig(1:end-1));
fprintf('%.4f]\n', cl_eig(end));

end
