"""Visualize the liquid-sloshing model from Section 4.1 of Choi et al. (2024):
    F1 = F11 + F12, and L = a t^2/2 - l/2 + l^2/(12h) tan(theta).

Outputs: results/sloshing_model_diagram.png
"""
import os
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Arc, FancyArrowPatch

HERE = os.path.dirname(os.path.abspath(__file__))
OUT_DIR = os.path.join(HERE, '..', 'results')
os.makedirs(OUT_DIR, exist_ok=True)

# --- geometry for the schematic ---
l = 4.0                         # container length (x)
h = 2.5                         # liquid height (z)
theta_deg = 15                  # tilt angle for illustration
theta = np.deg2rad(theta_deg)
tan_t = np.tan(theta)
h_left  = h - (l / 2) * tan_t   # surface height at x = 0
h_right = h + (l / 2) * tan_t   # surface height at x = l
static_h = h_left               # bottom rectangular slab (F12 region)

fig, axes = plt.subplots(1, 2, figsize=(15, 6.5))

# =================================================================
# LEFT PANEL: F11 (shaking wedge) + F12 (static slab)
# =================================================================
ax = axes[0]

# container walls
ax.plot([0, 0], [0, h + 1.0], 'k-', lw=2)
ax.plot([l, l], [0, h + 1.0], 'k-', lw=2)
ax.plot([0, l], [0, 0], 'k-', lw=2)

# F12: rectangular "static" slab (moves rigidly with container)
ax.fill([0, l, l, 0], [0, 0, static_h, static_h],
        color='#9ec5fe', alpha=0.85, label=r'$F_{12}$ : static slab (rides with container)')

# F11: triangular "shaking" wedge (the sloshing part)
ax.fill([0, l, l], [static_h, static_h, h_right],
        color='#ffb86b', alpha=0.85, label=r'$F_{11}$ : shaking wedge (sloshing)')

# tilted free surface
ax.plot([0, l], [h_left, h_right], color='#1f4e8a', lw=2.5)

# dashed horizontal line separating the two regions
ax.plot([0, l], [static_h, static_h], 'k--', lw=1, alpha=0.5)

# theta angle marker
arc = Arc((0, h_left), 1.6, 1.6, angle=0, theta1=0, theta2=theta_deg,
          color='#1f4e8a', lw=2)
ax.add_patch(arc)
ax.text(0.95, h_left + 0.15, r'$\theta$', fontsize=16, color='#1f4e8a')

# dimensions
ax.annotate('', xy=(l + 0.35, 0), xytext=(l + 0.35, h),
            arrowprops=dict(arrowstyle='<->', lw=1.5))
ax.text(l + 0.55, h / 2, r'$h$', fontsize=15)

ax.annotate('', xy=(0, -0.35), xytext=(l, -0.35),
            arrowprops=dict(arrowstyle='<->', lw=1.5))
ax.text(l / 2, -0.7, r'$l$', fontsize=15, ha='center')

ax.annotate('', xy=(-0.35, 0), xytext=(-0.35, static_h),
            arrowprops=dict(arrowstyle='<->', lw=1.3, color='#555'))
ax.text(-0.55, static_h / 2, r'$h - l\,\tan\theta$',
        rotation=90, va='center', ha='right', fontsize=11, color='#555')

# acceleration arrow (container pushed rightward)
ax.annotate('', xy=(l + 2.1, h / 2), xytext=(l + 0.9, h / 2),
            arrowprops=dict(arrowstyle='-|>', lw=3, color='#c0392b', mutation_scale=20))
ax.text(l + 1.5, h / 2 + 0.3, r'$a$', color='#c0392b', fontsize=16, ha='center')
ax.text(l + 1.5, h / 2 - 0.5, 'container\nacceleration',
        color='#c0392b', fontsize=9, ha='center')

# gravity arrow
ax.annotate('', xy=(l / 2, -0.05), xytext=(l / 2, 1.0),
            arrowprops=dict(arrowstyle='-|>', lw=2, color='#27ae60', mutation_scale=18))
ax.text(l / 2 + 0.15, 0.45, r'$g$', color='#27ae60', fontsize=14)

# force labels next to each region
ax.text(l / 2, static_h + (h_right - static_h) / 3 - 0.05,
        r'$F_{11} = \rho\,l\,w\,h\,(a - g\tan\theta)$',
        ha='center', fontsize=11, color='#7a3b00',
        bbox=dict(facecolor='white', alpha=0.8, edgecolor='none'))
ax.text(l / 2, static_h / 2,
        r'$F_{12} = \rho\,l\,w\,(h - l\tan\theta)\,a$',
        ha='center', fontsize=11, color='#0b3d91',
        bbox=dict(facecolor='white', alpha=0.8, edgecolor='none'))

ax.set_xlim(-1.7, l + 3.2)
ax.set_ylim(-1.3, h + 1.3)
ax.set_aspect('equal')
ax.axis('off')
ax.set_title(r'Force split:   $F_1 = F_{11} + F_{12}$', fontsize=14, pad=10)
ax.legend(loc='upper left', fontsize=10, framealpha=0.9)

# =================================================================
# RIGHT PANEL: Center of mass L
# =================================================================
ax = axes[1]

# container walls
ax.plot([0, 0], [0, h + 1.0], 'k-', lw=2)
ax.plot([l, l], [0, h + 1.0], 'k-', lw=2)
ax.plot([0, l], [0, 0], 'k-', lw=2)

# full liquid region (tilted)
ax.fill([0, l, l, 0], [0, 0, h_right, h_left],
        color='#9ec5fe', alpha=0.75)
ax.plot([0, l], [h_left, h_right], color='#1f4e8a', lw=2.5)

# centroid of the tilted liquid
com_shift = (l**2) / (12 * h) * tan_t
com_x = l / 2 + com_shift
# centroid z of trapezoid of heights h_left .. h_right over length l:
com_z = (h_left**2 + h_left * h_right + h_right**2) / (3 * (h_left + h_right))

# container geometric center (for comparison)
ax.plot(l / 2, h / 2, marker='o', markersize=10, color='gray',
        markerfacecolor='white', markeredgewidth=2)
ax.text(l / 2 - 0.15, h / 2 + 0.25, 'container\ncenter',
        ha='right', fontsize=9, color='gray')

# actual CoM (shifted by tilt)
ax.plot(com_x, com_z, marker='*', markersize=24, color='#c0392b',
        markeredgecolor='black', markeredgewidth=1)
ax.text(com_x + 0.15, com_z + 0.15, 'center of mass',
        fontsize=10, color='#c0392b')

# shift arrow
ax.annotate('', xy=(com_x, h / 2 - 0.5), xytext=(l / 2, h / 2 - 0.5),
            arrowprops=dict(arrowstyle='-|>', lw=2, color='#c0392b'))
ax.text((com_x + l / 2) / 2, h / 2 - 0.85,
        r'shift $= \dfrac{l^2}{12h}\tan\theta$',
        ha='center', fontsize=11, color='#c0392b')

# dashed vertical centerline
ax.plot([l / 2, l / 2], [0, h + 0.5], '--', color='gray', alpha=0.6)

# dimension labels
ax.annotate('', xy=(l + 0.35, 0), xytext=(l + 0.35, h),
            arrowprops=dict(arrowstyle='<->', lw=1.5))
ax.text(l + 0.55, h / 2, r'$h$', fontsize=15)
ax.annotate('', xy=(0, -0.35), xytext=(l, -0.35),
            arrowprops=dict(arrowstyle='<->', lw=1.5))
ax.text(l / 2, -0.7, r'$l$', fontsize=15, ha='center')

# formula breakdown as text block
ax.text(l / 2, -1.55,
        r'$L \;=\; \dfrac{a\,t^2}{2} \;-\; \dfrac{l}{2} \;+\; \dfrac{l^2}{12\,h}\tan\theta$',
        ha='center', fontsize=15)
ax.text(l / 2, -2.25,
        'container travel     to container center     shift from tilt',
        ha='center', fontsize=9, color='gray', family='sans-serif')

ax.set_xlim(-1.2, l + 1.8)
ax.set_ylim(-2.6, h + 1.3)
ax.set_aspect('equal')
ax.axis('off')
ax.set_title('Center of mass  $L$', fontsize=14, pad=10)

plt.suptitle('Liquid sloshing model (Choi et al. 2024, Sec. 4.1)',
             fontsize=15, y=1.02)
plt.tight_layout()

out_path = os.path.join(OUT_DIR, 'sloshing_model_diagram.png')
plt.savefig(out_path, dpi=150, bbox_inches='tight')
print(f'Saved: {out_path}')
