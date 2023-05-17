function [wmulti] = get_beam_weights(beamAng, array, gain, phase)
%GET_BEAM_WEIGHTS gives weights for a conventional multi-beam pattern
%   Multi-beam weights specified by an array of beam angles, gain and
%   phase. The single-beam is a default case. Use them for baseline
%
%   Author: Ish Jain
%   Date created: 12/6/21

if(nargin<2)
    N = 8; %Number of antennas in ULA
    array = 0:N-1;
end
if(nargin<1)
    beamAng=[0,30]; % Degrees
end
if(nargin<4)
    phase = zeros(size(beamAng)); % Degrees
end
if(nargin<3)
    gain = ones(size(beamAng)); %Magnitude: Caution not in dB
end


if(length(beamAng)~=length(gain))
    error('Wrong Gain vector in multibeam')
end

if(length(beamAng)~=length(phase))
    error('Wrong Phase vector in multibeam')
end
% Assume d=lambda/2 ULA
beamAng = beamAng(:).';
mbGain = gain(:).';
mbPhase = phase(:).';
array = array(:); % make array vertical vector
N = length(array);

psi = 2*pi/2*sind(beamAng); % pointing direction
w_unnormalized = 1/N* exp(1j*array*psi); % unnormalized weights

%%multibeam with power and phase control
mbweight = mbGain(:).*exp(1j*deg2rad(mbPhase(:)));

wmulti_unnormalized = sum(w_unnormalized*mbweight,2); %unnormalized multibeam
wmulti = wmulti_unnormalized/norm(wmulti_unnormalized); %normalized multibeam

end

