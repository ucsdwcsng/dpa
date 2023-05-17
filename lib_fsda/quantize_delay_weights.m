function [delays_est_q, weight_est_q] = quantize_delay_weights(nbit_del, delays_est, range_del, nbit_phase, weights_est)
%% QUANTIZE delays and weights according to num bits
%
% Assume delay is -range_del/2 to range_del/2
%
%   Author: Ish Jain
%   Date created: 12/6/21
%----------------------------------------

% nbit_del = 5;
% nbit_phase = 5;
% range_del = 3/2/BW*(length(angle_list)-1)+1e-12;

nset_del = 2^nbit_del;
delay_resolution = range_del/nset_del; % in sec

% assert(sum(delays_est>range_del) ==0); % No delays more than range
% The assert is taken care of by clipping method below

delay_int = floor(delays_est/delay_resolution); % -32 to 32
delay_int_clip = max(min(delay_int, nset_del/2), -nset_del/2); %clip delay to the min to max range
delays_est_q = delay_int_clip * delay_resolution; % scale with delay_resolution

nset_ph = 2^nbit_phase;
range_ph = 2*pi;
angle_est = angle(weights_est); %angle in 0 to 2pi
angle_est_q = floor(angle_est/range_ph*nset_ph) * range_ph/nset_ph;
weight_est_q = exp(1j*angle_est_q);
weight_est_q = weight_est_q./norm(weight_est_q);
