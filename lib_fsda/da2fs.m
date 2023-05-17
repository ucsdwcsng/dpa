function [G_fs, w_fa] = da2fs(param, weights,delay_values)
%DA2FS Summary: delay-Antenna to Freq-space transform
%   Author: Ish Jain
%   Date created: 12/6/21
%   
%   Apply 2D transform to convert antenna weights and delay-per-antenna to
%   2D freq-space beam pattern matrix.
assert (length(weights) == length(param.array), "da2fs: wrong weights");

weights = weights(:).';
delay_values = delay_values(:).';

% N =     param.N;
fc =    param.fc; %center freq
% BW =    param.BW;
% scs =   param.scs;
M =     param.M; % Number of freq. bands
gain_per_antenna = param.gain_per_antenna;
freq_axis = param.freq_axis; % vector of frequency subcarriers
u =     param.u; % u=sin(theta)
array = param.array; % array antenna selection
flag_beam_squint = param.flag_beam_squint; %Flag to include beam squint in da2fs

assert(M==length(freq_axis), "Wrong M, number of frequencies")

d_spacing = 3e8/fc/2; % assume antenna spacing based on center freq
lam_array = 3e8./(fc+freq_axis);
if(flag_beam_squint)
    new_d_lam = d_spacing./lam_array;
else
    new_d_lam = 0.5; % d by lambda
end

%%--First FFT from delay to frequency
weights_matrix = repmat(weights, M,1);

w_fa = gain_per_antenna*weights_matrix.*exp(1j*2*pi*freq_axis.'*delay_values);


%%--Second FFT antenna-freq to space-freq
if(flag_beam_squint)
    G_fs=zeros(M,length(u));
    for freq_id = 1:length(freq_axis)
        a_n = exp(-1j*2*pi*new_d_lam(freq_id)*u.'*(array)); %array response
        G_fs(freq_id,:) = w_fa(freq_id,:)*a_n.';

    end
else
    a_n = exp(-1j*2*pi*new_d_lam*u.'*(array)); %array response
    G_fs = w_fa*a_n.';

end


end

