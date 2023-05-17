function plot_dpa_beam_and_weights(param, G_fs_desired, G_fs_est, weights_est, delay_est)
%PLOT beam patterns
%
%   Author: Ish Jain
%   Date created: 12/6/21
%---------------------------------------
u = param.u;
freq_axis = param.freq_axis;

figure(3); clf
tiledlayout(2,2);
nexttile;
imagesc(u,freq_axis*1e-6,abs(G_fs_desired)); axis xy
colorbar; grid on; grid minor;
xlim([-1,1])
ylabel('Frequency (MHz)')
xlabel('Angle sin(\theta)')
title('Desired image')
set(gca, 'fontsize', 14)
% colorbar;

nexttile;
imagesc(u,freq_axis*1e-6,abs(G_fs_est)); axis xy
colorbar; grid on; grid minor;
xlim([-1,1])
ylabel('Frequency (MHz)')
xlabel('Angle sin(\theta)')
title('Estimated image')
set(gca, 'fontsize', 14)
colorbar;


nexttile;
plot(angle(weights_est), '.--');
grid on; grid minor; hold on;
yline(-pi, 'r--', 'linewidth', 2)
yline(pi, 'r--', 'linewidth', 2)
ylim([-pi,pi])
xlabel('Antenna Index')
ylabel('Phase (rad)')
title(' Phase')
set(gca, 'fontsize', 14)


nexttile;
plot(delay_est*1e9, '.--');
grid on; grid minor; hold on;
xlabel('Antenna Index')
ylabel('Delay (ns)')
title(' Delay')
set(gca, 'fontsize', 14)
end