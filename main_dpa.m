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

addpath('lib_fsda')
clearvars

N = 16;      % Number of antennas
BW = 1000e6;   % Bandwidth in Hz

angle_list = [-30, 0, 30,]; %beam pointing angles
bw_fraction = [.4, .3, .3]; % fraction of bandwidth for each beam

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

[G_fs_est, w_fa] = da2fs(param, weights_est,delay_est);

%% Plot freq-antenna image
plot_dpa_beam_and_weights(param, G_fs_desired, G_fs_est, weights_est, delay_est);

colormap(hot)

