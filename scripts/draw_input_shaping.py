"""Visualize the exponential input-shaping filter F_e(s) from Section 4.2
of Choi et al. (2024):

  - time-domain: step command vs. F_e-shaped reference
  - pole-zero map on the complex plane: F_e zeros cancel G(s) poles
  - step responses of G(s) with and without the filter

Outputs: results/input_shaping_diagram.png
"""
import os
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch

HERE = os.path.dirname(os.path.abspath(__file__))
OUT_DIR = os.path.join(HERE, '..', 'results')
os.makedirs(OUT_DIR, exist_ok=True)

# --- plant parameters (Choi et al. Sec. 5.1 uses these orders of magnitude) ---
wf = 9.922                            # natural frequency of sloshing [rad/s]
delta = 0.05                          # low damping (water sloshes a lot)
wd = wf * np.sqrt(1 - delta**2)       # damped natural frequency

# --- filter parameters (the recipe from Sec. 4.2) ---
Te = 2 * np.pi / wd                   # one damped oscillation period
mu = -delta * wf                      # filter real pole


# =================================================================
# Time-domain step response of F_e(s) to a unit step at t=0.
# Closed form: s(t) = (1 - e^{mu t}) / (1 - e^{mu Te}) for 0<=t<=Te,
#              s(t) = 1 for t >= Te.
# (Derived from inverse Laplace of F_e(s) * 1/s.)
# =================================================================
def fe_shaped_step(t):
    out = np.ones_like(t)
    mask = t < Te
    # For mu < 0, the denominator (1 - exp(mu*Te)) is positive and < 1.
    out[mask] = (1 - np.exp(mu * t[mask])) / (1 - np.exp(mu * Te))
    out[t < 0] = 0
    return out


# =================================================================
# Simulate G(s) step response by integrating the 2nd-order ODE:
#    xdd + 2*delta*wf*xd + wf^2 * x = wf^2 * u(t)
# RK4 on state [x, xd].
# =================================================================
def simulate_plant(u_of_t, t):
    dt = t[1] - t[0]
    x = np.zeros_like(t)
    xd = np.zeros_like(t)

    def rhs(state, u):
        xi, xdi = state
        return np.array([xdi, wf**2 * (u - xi) - 2 * delta * wf * xdi])

    state = np.array([0.0, 0.0])
    for i in range(len(t) - 1):
        u_mid = 0.5 * (u_of_t[i] + u_of_t[i + 1])
        k1 = rhs(state,                u_of_t[i])
        k2 = rhs(state + 0.5 * dt * k1, u_mid)
        k3 = rhs(state + 0.5 * dt * k2, u_mid)
        k4 = rhs(state + dt * k3,       u_of_t[i + 1])
        state = state + (dt / 6.0) * (k1 + 2 * k2 + 2 * k3 + k4)
        x[i + 1], xd[i + 1] = state
    return x


t = np.linspace(0, 5.0, 4000)
u_step = np.where(t >= 0.0, 1.0, 0.0)
u_shaped = fe_shaped_step(t)

y_raw = simulate_plant(u_step, t)
y_shaped = simulate_plant(u_shaped, t)


# =================================================================
# Figure
# =================================================================
fig = plt.figure(figsize=(15, 9))
gs = fig.add_gridspec(2, 2, hspace=0.35, wspace=0.28,
                      height_ratios=[1.0, 1.15])

# ------------------------------------------------
# Panel 1 (top-left): Reference shaping in time
# ------------------------------------------------
ax1 = fig.add_subplot(gs[0, 0])
ax1.plot(t, u_step, color='#1565c0', lw=2.5, label='step command (raw)')
ax1.plot(t, u_shaped, color='#c0392b', lw=2.5, label=r'shaped by $F_e(s)$')
ax1.axvline(Te, color='gray', ls='--', alpha=0.6)
ax1.text(Te + 0.03, 0.15, f'$T_e \\approx {Te:.2f}$ s\n(one sloshing period)',
         fontsize=10, color='gray')
ax1.set_xlim(-0.1, 2.5)
ax1.set_ylim(-0.08, 1.25)
ax1.set_xlabel('time [s]')
ax1.set_ylabel('velocity reference')
ax1.set_title('Step command  →  smooth exponential ramp', fontsize=13)
ax1.legend(fontsize=10, loc='lower right')
ax1.grid(alpha=0.3)

# ------------------------------------------------
# Panel 2 (top-right): pole-zero map
# ------------------------------------------------
ax2 = fig.add_subplot(gs[0, 1])

# plant poles: -delta*wf +- j*wd
plant_poles_re = -delta * wf
plant_poles_im = [+wd, -wd]

# Fe zeros: -delta*wf +- j*n*wd, for several n
n_values = list(range(-3, 4))

# draw the vertical line where all Fe zeros live
ax2.axvline(-delta * wf, color='#c0392b', alpha=0.25, lw=1,
            linestyle='--')

# Fe zeros
for n in n_values:
    ax2.plot(-delta * wf, n * wd, 'o', color='#c0392b',
             markersize=12, markerfacecolor='none', markeredgewidth=2)

# plant poles (always drawn on top)
for im in plant_poles_im:
    ax2.plot(plant_poles_re, im, 'x', color='#1565c0',
             markersize=16, markeredgewidth=3)

# cancellation callout at n=1
ax2.annotate('n=1 zeros land exactly\non the plant poles  →  CANCEL',
             xy=(plant_poles_re, wd), xytext=(2, wd + 4),
             fontsize=11, color='black',
             arrowprops=dict(arrowstyle='->', color='black', lw=1.3))

# axes
ax2.axhline(0, color='black', lw=0.8)
ax2.axvline(0, color='black', lw=0.8)
ax2.set_xlim(-8, 10)
ax2.set_ylim(-3.2 * wd, 3.2 * wd)
ax2.set_xlabel('Re')
ax2.set_ylabel('Im')
ax2.set_title(r'Pole–zero map:  $G(s)$ poles (×) and $F_e(s)$ zeros (○)',
              fontsize=13)
ax2.grid(alpha=0.3)

# legend via dummy handles
from matplotlib.lines import Line2D
legend_handles = [
    Line2D([], [], marker='x', color='#1565c0', linestyle='None',
           markersize=12, markeredgewidth=3,
           label=r'plant poles of $G(s)$'),
    Line2D([], [], marker='o', color='#c0392b', linestyle='None',
           markersize=11, markerfacecolor='none', markeredgewidth=2,
           label=r'zeros of $F_e(s)$ (at $n=0,\pm1,\pm2,\ldots$)'),
]
ax2.legend(handles=legend_handles, fontsize=10, loc='lower right')

# ------------------------------------------------
# Panel 3 (bottom full width): step responses
# ------------------------------------------------
ax3 = fig.add_subplot(gs[1, :])
ax3.axhline(1.0, color='#999', ls=':', lw=1.5, label='reference (target = 1)')
ax3.plot(t, y_raw, color='#1565c0', lw=2.2,
         label='plant with raw step  →  overshoot + ringing')
ax3.plot(t, y_shaped, color='#c0392b', lw=2.2,
         label=r'plant with $F_e$-shaped input  →  no overshoot, no ringing')
ax3.set_xlim(0, 5)
ax3.set_ylim(-0.05, 2.0)
ax3.set_xlabel('time [s]')
ax3.set_ylabel('plant output (e.g. sloshing angle)')
ax3.set_title(r'Step response of $G(s)$  —  same final value, very different paths',
              fontsize=13)
ax3.legend(fontsize=11, loc='upper right')
ax3.grid(alpha=0.3)

plt.suptitle(r'Reference shaping $F_e(s)$  (Choi et al. 2024, Sec. 4.2)',
             fontsize=15, y=0.995)

out_path = os.path.join(OUT_DIR, 'input_shaping_diagram.png')
plt.savefig(out_path, dpi=150, bbox_inches='tight')
print(f'Saved: {out_path}')
print(f'  wf = {wf} rad/s,  delta = {delta},  Te = {Te:.3f} s,  mu = {mu:.3f}')
