%% TRAIN_RL_AGENT  Train a SAC policy to replace SBSFC.
%
% Action = scalar x_ddot command  [m/s^2]
% Obs    = [psi, psi_dot, x, x_dot, theta, theta_dot, v_ref]
%
% Requires: Reinforcement Learning Toolbox, Deep Learning Toolbox.

clear; close all; clc;
rng(0);

%% Observation + action specs
obsInfo = rlNumericSpec([7 1], ...
    'LowerLimit', [-pi; -20; -10; -3; -pi; -20; -2], ...
    'UpperLimit', [ pi;  20;  10;  3;  pi;  20;  2]);
obsInfo.Name = 'obs';

actInfo = rlNumericSpec([1 1], 'LowerLimit', -4, 'UpperLimit', 4);
actInfo.Name = 'u_cmd';

%% Environment
env = rlFunctionEnv(obsInfo, actInfo, 'rl_step', 'rl_reset');

%% SAC agent with default networks
agentOpts = rlSACAgentOptions( ...
    'SampleTime',               0.010, ...
    'DiscountFactor',           0.99,  ...
    'ExperienceBufferLength',   1e6,   ...
    'MiniBatchSize',            256,   ...
    'NumWarmStartSteps',        1000,  ...
    'TargetSmoothFactor',       5e-3);

agentOpts.ActorOptimizerOptions.LearnRate        = 3e-4;
agentOpts.CriticOptimizerOptions(1).LearnRate    = 3e-4;
agentOpts.CriticOptimizerOptions(2).LearnRate    = 3e-4;
agentOpts.EntropyWeightOptions.LearnRate         = 3e-4;
agentOpts.EntropyWeightOptions.TargetEntropy     = -1;

% initFn uses default MLP (2 hidden layers, 256 units) for actor and critics
initOpts = rlAgentInitializationOptions('NumHiddenUnit', 256);
agent    = rlSACAgent(obsInfo, actInfo, initOpts, agentOpts);

%% Training options
trainOpts = rlTrainingOptions( ...
    'MaxEpisodes',              600, ...
    'MaxStepsPerEpisode',       1000, ...     % 10 s / 0.01 s
    'ScoreAveragingWindowLength', 20, ...
    'StopTrainingCriteria',     'AverageReward', ...
    'StopTrainingValue',        -5, ...       % tune after first run
    'SaveAgentCriteria',        'EpisodeReward', ...
    'SaveAgentValue',           -20, ...
    'SaveAgentDirectory',       '../results/rl_checkpoints', ...
    'Plots',                    'training-progress', ...
    'Verbose',                  false);

%% Train
fprintf('Starting SAC training...\n');
trainStats = train(agent, env, trainOpts);

%% Save final agent
if ~exist('../results', 'dir'), mkdir('../results'); end
save('../results/rl_agent_final.mat', 'agent', 'trainStats');
fprintf('Saved: ../results/rl_agent_final.mat\n');
