function [ param] = get_fsda_param(N, BW)
%% GET_FSDA_PARAM to get high level parameters for FSDA algorithm
%
%   Author: Ish Jain
%   Date created: 12/6/21
%----------------------------------------

if(nargin<2)
    BW = 100e6;   % Bandwidth in Hz
end
if(nargin<1)
    N = 16;      % Number of antennas
end

fc = 28e9;  % Center frequency in Hz
scs = 120e3;  % Subcarrier spacing in Hz
M = round(BW/scs); % Number of freq. bands
gain_per_antenna = db2mag(15); % Gain per-antenna at phased array
freq_axis = (-M/2+1:M/2)*scs ; % vector of frequency subcarriers
array = 0:N-1;      % array antenna selection
use_theta_x_axis = 0; % x-axis is theta instead of sin(theta)
skip_magnitude = 1; %skip magnitude in FSDA, recommended 1
theta = linspace(-90,90,1000);
if(use_theta_x_axis)
    u = sind(theta); % u=sin(theta)
    u = u(1:end-1);
else
    u = linspace(-1,1,1000); % u=sin(theta)
    u = u(1:end-1);
end


% grid of delay values that we use to map inverse 2D transform to.
del_grid = (-50:.1:100)*1e-9; %delay range array in sec;
make_delays_positive = 0; %offset delay_est by 3/4B - not implemented
flag_beam_squint = 1; %Flag to include beam squint in da2fs

param.N = N;
param.Nt=N;
param.d_by_lambda = 0.5;
param.noBeamDelays=1;
param.fc = fc;
param.BW = BW;
param.scs = scs;
param.M = M;
param.gain_per_antenna = gain_per_antenna;
param.freq_axis = freq_axis;
param.u = u;
param.del_grid = del_grid;
param.array = array;
param.make_delays_positive=make_delays_positive;
param.skip_magnitude = skip_magnitude;
param.flag_beam_squint = flag_beam_squint;
end