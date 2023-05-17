function [G_fs_desired, param] = get_desired_freq_space_image(param,...
    angle_list, bw_fraction)
%GET_DESIRED_FREQ_SPACE_IMAGE Summary: Create matrix of 0s and 1s
%   Take the angles in angle_list and return a matrix of 0s and 1s at
%   appropriate places.
%
%   Input:
%       angle_list: list of angle for multibeam in degree
%       bw_fraction: bandwidth allocation in fraction (list for each beam)
%           bw_fraction(end) will be ignored because sum = 1
%   Output:
%       G_fs_desired: Freq-Space Matrix of 0s and 1s 
%
%   Author: Ish Jain
%   Date created: 12/6/21

if(nargin==2)
    bw_fraction = 1/length(angle_list); % Equal bw fraction
end
assert (sum(bw_fraction) <=1);
assert(length(bw_fraction)==length(angle_list) | length(bw_fraction)==length(angle_list)-1)
if(length(bw_fraction)==length(angle_list)-1)
    bw_fraction(end+1) = 1-sum(bw_fraction);
end
bw_fraction = bw_fraction(:); %column array
% angle_list = sort(angle_list); %Sort to increasing order

M =     param.M;
freq_axis = param.freq_axis;
u =     param.u;

% Width of angle for narrow vs wide beam
angle_width_deg = 1; %degree
N_angles = length(angle_list); %Nbr of angles

angle_list_sin_theta = sind(angle_list); % Angle list in sin theta
N_freq_per_angle = floor(M* bw_fraction); % Number of freq subs

angle_width_u = sind(angle_width_deg/2) * 2;
angle_width_nbr = length(u) * angle_width_u/ (u(end) - u(1));
angle_width_nbr_half = round(angle_width_nbr/2); %approx half angle width

% Initialize
G_fs_desired = zeros(length(freq_axis), length(u));
param.num_freq = zeros(N_angles,1);
param.freq_idx_mat = zeros(N_angles, M);
param.angle_idx_mat = zeros(N_angles,1);

% Loop over all angles
for aid = 1:N_angles
    angle_u = angle_list_sin_theta(aid);
    [~,angle_idx] = min(abs(u-angle_u));

    if(aid==1)
        freq_start = 1;
    else
        freq_start = freq_end(aid-1)+1;
    end
    freq_end(aid) = freq_start+ N_freq_per_angle(aid);
    if(aid == N_angles)
        freq_end(aid) = M;
    end
    angle_start = angle_idx - angle_width_nbr_half+1;
    angle_end = angle_idx + angle_width_nbr_half;
    
    freq_idx_array = freq_start:freq_end(aid);
    G_fs_desired(freq_idx_array, angle_start:angle_end) = 1;

    % get freq index and angle index to return - used later in final
    % meteric analysis
    param.num_freq(aid,1) = length(freq_idx_array);
    param.freq_idx_mat(aid,1:param.num_freq(aid,1)) = freq_idx_array;
    param.angle_idx_mat(aid,1) = angle_idx;

%     if(aid==2)
%         G_fs_desired(freq_start:freq_end, angle_start:angle_end) = exp(1j*pi/2);
%     end
end

end

