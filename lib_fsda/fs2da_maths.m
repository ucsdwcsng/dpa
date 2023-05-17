function [weights_est, delays_est, k_mat] = fs2da_maths(param, angle_list, bw_fraction)
%FS2DA_MATHS Get flexible beams from math formula
%   Supports arbitrary number of beams, beam directions, beam bandwidth
%   Input:
%       param- struct of all parameters
%       angle_list- list of all angles
%       bw_fraction- list of all beam-bandwidth as fraction of 1
%   Output:
%       weights_est- antenna weights as phaser
%       delays_est- antenna delays
%--------------------------------------
%   Author: Ish Jain
%   Date created: Aug 2022
%--------------------------------------

k_constant_algo = 'best_perf';%'min_delay';

N_beams = length(angle_list);
assert(sum(bw_fraction)<=1)
assert(length(bw_fraction)==length(angle_list) | length(bw_fraction)==length(angle_list)-1)
if(length(bw_fraction)==length(angle_list)-1)
    bw_fraction(end+1) = 1-sum(bw_fraction);
end
bw_fraction = bw_fraction(:); %column array
angle_list = angle_list(:).'; %row array
alpha = bw_fraction(1);

theta0      = (angle_list(2)-angle_list(1))/2;
theta_shift = (angle_list(2)+angle_list(1))/2;

N = param.N; %Number of antenna
BW = param.BW; %bandwidth
make_delays_positive = param.make_delays_positive; %0 or 1



if(N_beams==1)
    k = round((0:N-1)*sind(theta0));
    phi = (0:N-1)*pi*sind(theta0);
    phase_est = k*pi * 2*alpha + phi *(1-2*alpha) + (0:N-1)*pi*sind(theta_shift);
    
    weights_est = exp(1j*phase_est);
    
    
    % weights_est = weights_est.*exp(1j* (0:N-1)*pi*sind(theta0) *(1-2*alpha));
    
    weights_est = weights_est/norm(weights_est);
    %%--delays coming from closed-form maths
    
    delay_step = (sind(angle_list(2)) - sind(angle_list(1))) * 1.5 / (2*BW);
    delay_range = 1.50000000/BW;
    delay_offset = -delay_range/2 ;
    if(make_delays_positive)
        delays_est = mod((0:N-1)*delay_step + delay_offset, delay_range) ;
    else
        delays_est = mod((0:N-1)*delay_step + delay_offset, delay_range) +delay_offset;
        
    end
    % delays_est2 = mod((0:N-1)*delay_step , delay_range);
    
    %%--another formulat for delay
    % delays_est2 = delay_range * ( (0:N-1)*sind(angle_list(2)) - round((0:N-1)*sind(angle_list(2))) );
    %
    delays_est = 4*alpha*(1-alpha)*delays_est;
    
    
else
    % develop generalized code
    for nidx=1:N
        n = nidx-1;
        phi_all = n*pi*sind(angle_list);

        switch k_constant_algo
            case 'best_perf'
                k_all(N_beams)=0;
                for bidx = N_beams-1:-1:1
                    k_all(bidx) = round((n*sind((angle_list(bidx+1))) + 2*k_all(bidx+1) -  n*sind(angle_list(bidx)))/2);
                end
            case 'min_delay'
                k_all(N_beams)=0;
                for bidx = N_beams-1:-1:1
                    k_all(bidx) = round((n*sind((angle_list(N_beams))) + 2*k_all(N_beams) -  n*sind(angle_list(bidx)))/2);
                end
        end
        
        k_mat(nidx,:) = k_all;
        %phase
        phase_est(nidx) = (phi_all+2*pi*k_all)*bw_fraction;
        weights_est(nidx) = exp(1j*phase_est(nidx));
        
        %delay
        for bidx = 1:N_beams
            delay_temp(bidx) = (phi_all(bidx)+2*pi*k_all(bidx)) * bw_fraction(bidx) *...
                (2*sum(bw_fraction(1:bidx)) - bw_fraction(bidx) -1 ) * 3/pi/BW;
        end
        
        delays_est(nidx) = sum(delay_temp);
    end
    weights_est = weights_est/norm(weights_est);
    
end

end

