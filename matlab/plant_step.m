function [s_next, info] = plant_step(s, u, p, d_ext, A, B)
% PLANT_STEP  One dt Euler update of robot + pendulum.
%
% State s = [psi; psi_dot; x; x_dot; theta; theta_dot]   (6x1)
% Action u = x_ddot command [m/s^2]   (scalar)
% d_ext: external disturbance force [N]
% A, B: state-space matrices (pre-computed, avoids recomputing every step)

    q    = s(1:4);
    pend = s(5:6);

    d_vec = [0; d_ext / p.I_p; 0; d_ext / p.m];
    q_dot = A * q + B * u + d_vec;
    q     = q + q_dot * p.dt;

    robot_accel = u + d_ext / p.m;
    theta     = pend(1);
    theta_dot = pend(2);

    theta_ddot = -(p.g / p.pend_l) * sin(theta) ...
                 - (p.pend_b / (p.pend_m * p.pend_l^2)) * theta_dot ...
                 + (1 / p.pend_l) * robot_accel * cos(theta);

    pend(1) = pend(1) + pend(2)  * p.dt;
    pend(2) = pend(2) + theta_ddot * p.dt;

    s_next = [q; pend];
    info.x_ddot_actual = robot_accel;
end
