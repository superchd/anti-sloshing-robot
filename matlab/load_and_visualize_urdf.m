%% LOAD_AND_VISUALIZE_URDF  Import URDF and display the serving robot
%
% Requires: Robotics System Toolbox

clear; close all; clc;

%% Import URDF
urdf_path = fullfile('..', 'urdf', 'serving_robot.urdf');
robot = importrobot(urdf_path);
robot.DataFormat = 'column';
robot.Gravity = [0 0 -9.81];

%% Display robot info
fprintf('Number of bodies: %d\n', robot.NumBodies);
fprintf('Body names:\n');
for i = 1:robot.NumBodies
    fprintf('  %d. %s\n', i, robot.BodyNames{i});
end

%% Show robot in default configuration
figure('Name', 'Serving Robot - Default Pose', 'Position', [100 100 800 600]);
show(robot);
title('Serving Robot with Pendulum (URDF)');
xlabel('X [m]'); ylabel('Y [m]'); zlabel('Z [m]');
light('Position', [1 1 2]);
view(135, 25);
axis equal;
grid on;

%% Show robot with pendulum deflected
config = homeConfiguration(robot);

% Find pendulum joint index
joint_names = {robot.Bodies{:}};
for i = 1:robot.NumBodies
    if strcmp(robot.Bodies{i}.Joint.Name, 'pendulum_joint')
        pend_idx = i;
        break;
    end
end

% Deflect pendulum 15 degrees
figure('Name', 'Serving Robot - Pendulum Deflected', ...
       'Position', [200 100 800 600]);

subplot(1, 2, 1);
config_neutral = homeConfiguration(robot);
show(robot, config_neutral);
title('Balanced (no sloshing)');
view(0, 0);  % side view
axis equal; grid on;

subplot(1, 2, 2);
config_deflected = homeConfiguration(robot);
% Set pendulum angle to 15 degrees
for i = 1:length(config_deflected)
    if strcmp(robot.Bodies{i}.Joint.Name, 'pendulum_joint')
        config_deflected(i) = deg2rad(15);
    end
end
show(robot, config_deflected);
title('Sloshing (pendulum deflected 15°)');
view(0, 0);  % side view
axis equal; grid on;

sgtitle('Serving Robot with Pendulum', 'FontSize', 14);
