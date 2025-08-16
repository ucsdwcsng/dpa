% main_dpa.m
%
% Author: Ish Jain
% 
% Revision 10/3/22
%   Simplified code for testing the functionality of delay phased array (DPA)
%   We simulate two or more beams, with given beam angles and beam-bandwidths
%   (fraction of bandwidth per beam), and then get the respective
%   delays and phases through FSDA algorithm or MATH and plot beam patterns as 2D
%   frequeny-space image.
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc
addpath('lib_fsda')
clearvars

%%
N = 16;      % Number of antennas
BW = 1000e6;   % Bandwidth in Hz

theta_deg = 30;
angle_list = [-theta_deg, theta_deg]; %beam pointing angles
bw_fraction = [.5, .5]; % fraction of bandwidth for each beam

algo_type = 'FSDA'; % 'MATH' or 'FSDA'

param = get_fsda_param(N, BW);
freq_axis = param.freq_axis;
array = param.array;
M = param.M;
u = param.u;
del_grid = param.del_grid;

%% Get G_fs degired freq-space images
% Contains 0s and 1s matrix

G_fs_desired = get_desired_freq_space_image(param, angle_list, bw_fraction);

%% FSDA: Inverse 2D function from space-freq to antenna-delay
switch algo_type
    case 'FSDA'
        [weights_est, delay_est, delay_phase_profile] = fs2da(param, G_fs_desired);
    case 'MATH'
        [weights_est, delay_est, delay_phase_profile] = fs2da_maths(param, angle_list, bw_fraction);
end
%% DAFS: Inverse FSDA to visualize the freq-space beams

[G_fs_est, w_fa] = da2fs(param, weights_est, delay_est);

%% Plot freq-antenna image
% plot_dpa_beam_and_weights(param, G_fs_desired, G_fs_est, weights_est, delay_est);
% 
% colormap(hot)

%% 
% computing error between h(𝑛,𝑓) and Phi_ant

% computing h(𝑛,𝑓)=Φ𝑛+2𝜋𝑓𝜏𝑛
ant_axis = 1:N;
phases = angle(weights_est);
h = phases.' + 2*pi*delay_est.'*freq_axis;

% computing Phi_ant
counts = round(M * bw_fraction / sum(bw_fraction));
angle_axis = repelem(angle_list, counts);
angle_axis = angle_axis(1:M);
angle_axis_rad = deg2rad(angle_axis);
n_axis = (1:N)';                                % antenna indices
Phi_ant = n_axis .* pi .* sin(angle_axis_rad);  % N x M matrix

% compute error d(n) ||h - Phi_ant||^2
diffs = Phi_ant - h;          % [N x M]
dist_sq = sum(abs(diffs).^2, 2);  % [N x 1], distance per row

disp(['Distances: [', num2str(dist_sq.', '%.2f '), ']'])
mean_val = mean(dist_sq);
std_val  = std(dist_sq);
fprintf('Mean distance = %.2f, Std = %.2f\n', mean_val, std_val);

%% 
% plotting
figure(1); clf
plot(freq_axis/1e6, Phi_ant.', LineWidth=2)
grid on; grid minor; hold on;
xlabel('Frequency (in MHz)')
ylabel('\Phi_{ant}')
set(gca, 'fontsize', 14)
title('\Phi_{ant} with Frequencies')

figure(2); clf
plot(freq_axis/1e6, h.', LineWidth=2)
grid on; grid minor; hold on;
xlabel('Frequency (in MHz)')
ylabel('h(n,f)')
set(gca, 'fontsize', 14)
title('h(n,f) with Frequencies')


