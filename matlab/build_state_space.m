function [A, B] = build_state_space(p)
% BUILD_STATE_SPACE  Construct linearized state-space model (Eq. 1)
%
% State vector: q = [psi; psi_dot; x; x_dot]
%   psi     = pitch angle of robot
%   psi_dot = pitch angular velocity
%   x       = 1-D position
%   x_dot   = 1-D velocity
%
% Dynamics: q_dot = A*q + B*u + d
%   where u = x_ddot (acceleration command)

% Compute intermediate parameters from Eq. 1
gamma = p.r^2 * (p.m_s^2 * p.l^2 - p.I_w * p.m + 2*p.I_p * p.I_w + ...
        2*p.I_p * p.m) + 4*p.I_p^2;

a1 = p.m_s * p.g * (p.m * p.r^2 + 2*p.I_w) / gamma;
a2 = -(p.m_s * p.r)^2 * p.g / gamma;

beta1 = (2*p.m * p.r^2 + 4*p.I_w + p.m_s * p.r * p.l) / gamma;
beta2 = -p.r * (2*p.m_s * p.l + p.I_w - 2*p.I_p) / gamma;

% A21 from the paper
A21 = -(beta2*a1 - beta1*a2) / beta2;

% State-space matrices
A = [0,    1,    0,    0;
     a1,   0,    0,    0;
     0,    0,    0,    1;
     A21,  0,    0,    0];

B = [0;
     beta1/beta2;
     0;
     1];

fprintf('State-space model built.\n');
fprintf('  A matrix eigenvalues: [%.4f, %.4f, %.4f, %.4f]\n', eig(A));
fprintf('  System is ');
if any(real(eig(A)) > 0)
    fprintf('UNSTABLE (open-loop) -- needs active balancing.\n');
else
    fprintf('stable (open-loop).\n');
end

end
