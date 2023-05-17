function [weights, delays,delay_phase_profile] = fs2da(param, G_fs)
%FS2DA Summary: Frequency-space to delay antenna transform
%   2D-FFT function from freq-space image to delays and phases per antenna
%
%   Author: Ish Jain
%   Date created: 12/6/21


N =     param.N; % Number of antennas
freq_axis = param.freq_axis; % set of frequencies
u =     param.u; % set of angles sin(thetas)
% grid of delay values that we use to map inverse 2D transform to.
del_grid = param.del_grid; % uniform grid of delay values for FFT

skip_magnitude = param.skip_magnitude; % recommend 1


d_by_lam = 0.5; % d by lambda (ignore changes in lambda due to bandwidth)
a_n = exp(-1j*2*pi*d_by_lam*u.'*(0:N-1)); %array response

w_freq_ant = [];
for freq_id = 1:length(freq_axis)
%     new_d_lam = d./lambda(freq_id);

    w_freq_ant(:, freq_id) = G_fs(freq_id,:)*conj(a_n);
end

% Inverse response from freq to delay for each antenna
delay_phase_profile = (w_freq_ant) *exp(-1j*2*pi*freq_axis.'*del_grid);

%%
% Extract delay, and phase per-antenna 

w_abs = abs(delay_phase_profile);
weights=[];
for antid = 1:N
    
    [~,maxind(antid)] = max(w_abs(antid,:));
    
    weights(antid) = delay_phase_profile(antid,maxind(antid)); % Get complex weights per antenna

end
if(skip_magnitude)
    weights = exp(1j*angle(weights));
end

delays = del_grid(maxind); % Get delay per antenna
weights = weights./norm(weights); % Normalized antenna weights (phase and magnitude)

end

