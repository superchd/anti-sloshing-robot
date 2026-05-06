# Anti-Sloshing Control for Food-Serving Robots

Simulation code accompanying the paper:

> **Optimal Control vs Reinforcement Learning for Anti-sloshing Control in Food-Serving Robots**  
> Hyundae Cha, Mohammadreza Shahsavar — University of Houston

---

## Overview

This repository compares two controllers for suppressing liquid sloshing in a food-serving robot:

| Controller | Approach | Key idea |
|---|---|---|
| **LPF** | Baseline | Low-pass filter on velocity command only |
| **SBSFC** | Classical optimal control | Reference shaping + LQT + auxiliary compensator + disturbance observer |
| **SAC (RL)** | Model-free reinforcement learning | Learns policy from interaction with simulation; no system model required |

Both SBSFC and SAC reduce mean sloshing angle by over **93%** compared to the LPF baseline on a sudden start-and-stop scenario.

---

## Requirements

- MATLAB R2023b or later
- Reinforcement Learning Toolbox
- Deep Learning Toolbox
- Control System Toolbox

Python scripts in `scripts/` require `python-pptx` and `matplotlib` (for figure generation only; not needed to run the simulation).

---

## Repository Structure

```
matlab/
  parameters.m          # robot and pendulum physical parameters
  build_state_space.m   # builds A, B matrices from parameters
  plant_step.m          # single Euler integration step (1 kHz)
  scenarios.m           # velocity reference profiles (5 scenarios)
  simulate_system.m     # runs SBSFC or LPF over a full scenario
  controller.m          # SBSFC control law (LQT + aux comp + DOB)
  design_lqt.m          # computes LQT gain K
  input_shaping.m       # exponential reference-shaping filter
  train_rl_agent.m      # trains the SAC agent (saves to results/)
  rl_step.m             # RL environment step callback
  rl_reset.m            # RL environment reset (with domain randomization)
  evaluate_rl.m         # loads trained agent, runs Scenario 1, plots comparison
  main_simulation.m     # runs all 5 scenarios for SBSFC vs LPF
  run_comparison.m      # side-by-side SBSFC vs LPF summary
  plot_results.m        # time-series plots
  animate_2d.m          # 2-D animation of robot + pendulum
  animate_comparison.m  # side-by-side animation of all controllers
  animate_rl.m          # animation of the trained RL policy
  tools/                # helper scripts for figures and diagrams

scripts/                # Python scripts that generate PPTX/PNG figures
urdf/
  serving_robot.urdf    # robot geometry for visualization
```

---

## Quick Start

### 1 — Run the classical SBSFC baseline

```matlab
run matlab/main_simulation.m
```

Simulates all 5 scenarios and saves plots to `results/`.

### 2 — Train the SAC agent

```matlab
run matlab/train_rl_agent.m
```

Trains for up to 600 episodes (≈ 10–20 min on a modern laptop).  
The trained agent is saved to `results/rl_agent_final.mat`.

### 3 — Evaluate and compare

```matlab
run matlab/evaluate_rl.m
```

Loads the saved agent, runs Scenario 1, prints the metrics table, and saves `results/rl_vs_sbsfc.png`.

---

## Results (Scenario 1 — Sudden Start and Stop)

![Comparison of LPF, SBSFC, and RL](results/rl_vs_sbsfc.png)

| Metric | RL | SBSFC | LPF (baseline) |
|---|---|---|---|
| Mean \|θ\| [°] | **0.238** | 0.317 | 5.066 |
| Variance θ [°²] | **0.193** | 0.193 | 35.41 |
| Max \|θ\| [°] | 2.081 | **1.712** | 11.41 |
| Reduction in mean vs LPF | **95.3%** | 93.7% | — |

---

## Implementation Notes

- The plant (`plant_step.m`) uses first-order Euler integration at **1 kHz** with a nonlinear pendulum model (full `sin`/`cos`, not linearized).
- The RL environment runs at **100 Hz** (10 physics substeps per decision).
- Training applies **domain randomization** each episode: pendulum length ±15%, damping 0.5–2×, total mass ±10%, and randomized velocity profiles — so Scenario 1 is an out-of-distribution test case.
- During evaluation the SAC actor is queried **deterministically** (mean of the learned Gaussian, no exploration noise).

---

## Reference

This work extends the SBSFC method introduced in:

> Choi et al., "Suppressing violent sloshing flow in food serving robots,"  
> *Robotics and Autonomous Systems*, 2024.  
> DOI: [10.1016/j.robot.2024.104728](https://doi.org/10.1016/j.robot.2024.104728)
