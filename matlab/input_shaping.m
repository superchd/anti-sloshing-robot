function v_shaped = input_shaping(v_ref, p)
% INPUT_SHAPING  Apply exponential filter to reference velocity (Eq. 2)
%
% Smooths the reference velocity to suppress sloshing by canceling
% the poles of the second-order sloshing dynamics G(s).
%
% Input:  v_ref   - raw reference velocity vector (Nx1)
% Output: v_shaped - shaped reference velocity vector (Nx1)

dt = p.dt;
N = length(v_ref);

% Sloshing model: G(s) = omega_r^2 / (s^2 + 2*delta*omega_f*s + omega_r^2)
omega_f = p.omega_f;
delta   = p.delta;
omega_r = omega_f * sqrt(1 - delta^2);  % damped natural frequency

% Filter parameters (Eq. 2)
mu = -delta * omega_f;
T_e = (2*pi) / (omega_f * sqrt(1 - delta^2));

% Build exponential filter F_c(s) in discrete time
% F_c(s) = mu/(exp(mu*T_e)-1) * (1 - exp(mu*T_e)*exp(-T_e*s)) / (s - mu)
%
% Discretize using first-order hold approximation
alpha = exp(mu * dt);
beta_coeff = exp(mu * T_e);

% Implement as a discrete convolution with the impulse response
% of F_c(s) sampled at dt
t_filter = 0:dt:T_e;
n_filter = length(t_filter);

% Impulse response of F_c
h = (mu / (beta_coeff - 1)) * exp(mu * t_filter);
% Add delayed component
h_delayed = zeros(size(h));
h_delayed(end) = -mu * beta_coeff / (beta_coeff - 1);

h_total = h + h_delayed;
h_total = h_total / (sum(h_total) * dt);  % normalize for unity DC gain

% Apply filter via convolution
v_shaped = conv(v_ref, h_total * dt, 'full');
v_shaped = v_shaped(1:N);  % trim to original length

fprintf('Input shaping filter applied (T_e = %.4f s, %d tap filter).\n', ...
        T_e, n_filter);

end
