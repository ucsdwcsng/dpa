% main_dpa.m
%
% Author: Ish Jain, Rohith Reddy
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
N = 64;      
BW = 1000e6; 

algo_type = 'MATH'; 
theta_range = 0:180;   

results = struct();  % dictionary-like container

for algo_case = ["best_perf", "baseline"]
    k_constant_algo = char(algo_case);

    param = get_fsda_param(N, BW);
    M = param.M;
    freq_axis = param.freq_axis;

    dist_sq_mat = zeros(length(theta_range), N);

    for t_idx = 1:length(theta_range)
        theta_deg = theta_range(t_idx);

        angle_list = [-theta_deg, theta_deg];
        bw_fraction = [0.5, 0.5];

        G_fs_desired = get_desired_freq_space_image(param, angle_list, bw_fraction);

        switch algo_type
            case 'FSDA'
                [weights_est, delay_est, delay_phase_profile] = fs2da(param, G_fs_desired);
            case 'MATH'
                [weights_est, delay_est, delay_phase_profile] = fs2da_maths(param, angle_list, bw_fraction, k_constant_algo);
        end

        % h(n,f)
        phases = angle(weights_est);
        h = phases.' + 2*pi*delay_est.'*freq_axis;

        % Phi_ant
        counts = round(M * bw_fraction / sum(bw_fraction));
        angle_axis = repelem(angle_list, counts);
        angle_axis = angle_axis(1:M);
        angle_axis_rad = deg2rad(angle_axis);
        n_axis = (1:N)';
        delay_phase_profile_axis = repelem(delay_phase_profile, 1, counts);

        Phi_ant = n_axis .* pi .* sin(angle_axis_rad) + ...
                  2*pi.*delay_phase_profile_axis(:, 1:M);
        Phi_ant = Phi_ant - mean(Phi_ant, 2);

        % error
        diffs = Phi_ant - h;
        dist_sq = rms(abs(diffs).^2, 2);

        dist_sq_mat(t_idx, :) = dist_sq.';
    end

    % Store in dictionary (struct field)
    results.(k_constant_algo) = dist_sq_mat;
end

% Save as .mat file
save('dist_results.mat', 'results');
%% plotting

% Load saved results
S = load('dist_results.mat');   % contains struct 'results'
results = S.results;

% Prepare
algo_list = {'best_perf','baseline'};
colors = lines(2);     % just for visibility; optional

figure; hold on; grid on;

for i = 1:numel(algo_list)
    key = algo_list{i};
    A = results.(key);        % size: [num_theta x N]
    
    % Mean and std across angles (dim-1) -> per-antenna vectors (1 x N)
    mu  = mean(A, 1);                  % 1 x N
    sig = std(A, 0, 1);                % 1 x N
    
    x = 1:size(A,2);                   % antenna indices
    h = errorbar(x, mu, sig, '-o', 'LineWidth', 1.5, ...
                 'MarkerSize', 5);     %#ok<NASGU>
    % Optional color:
    % set(h, 'Color', colors(i,:), 'MarkerFaceColor', colors(i,:));
end

xlabel('Antenna index');
ylabel('Mean distance across angles (\mu) with std (\sigma)');
title('Per-antenna error: mean \pm std across angles');
legend(strrep(algo_list,'_','\_'),'Location','best');
set(gca, 'fontsize', 14)

%%

% Load saved results
S = load('dist_results.mat');   % contains struct 'results'
results = S.results;

algo_list = {'best_perf','baseline'};
names_for_legend = {'best\_perf','baseline'};   % customize if you want "Approach-1/2"
colors = lines(2);

% Compute per-antenna mean & std (across angles) for both algos
stats = struct();
for i = 1:numel(algo_list)
    key = algo_list{i};
    A = results.(key);            % [num_theta x N]
    stats(i).mu  = mean(A, 1);    % 1 x N (per-antenna mean across angles)
    stats(i).sig = std(A, 0, 1);  % 1 x N (per-antenna std across angles)
end

N = size(results.(algo_list{1}), 2);
x = 1:N;

% ---- Main figure with inset ----
figure('Color','w');
axMain = axes; hold(axMain,'on'); grid(axMain,'on');

% Main plot: full antenna range
h = gobjects(1,2);
for i = 1:numel(algo_list)
    h(i) = errorbar(axMain, x, stats(i).mu, stats(i).sig, '-o', ...
        'LineWidth', 1.5, 'MarkerSize', 4, 'Color', colors(i,:));
end
xlabel(axMain,'Antenna index');
ylabel(axMain,'Mean distance across angles (\mu) with std (\sigma)');
title(axMain,'Per-antenna error: mean \pm std across angles');
legend(axMain, names_for_legend, 'Location','best');

% Highlight 1..8 region on the main plot (optional shaded band)
xlo = 1; xhi = min(8, N);
yl = ylim(axMain);
patch(axMain, [xlo xhi xhi xlo], [yl(1) yl(1) yl(2) yl(2)], ...
      [0.9 0.9 0.95], 'EdgeColor','none', 'FaceAlpha',0.4);
uistack(h,'top');  % keep lines on top of the patch

% Inset axes: zoomed view 1..8
% axInset = axes('Position',[0.58 0.55 0.35 0.35]); % [left bottom width height]
axInset = axes('Position',[0.2 0.4 0.35 0.35]); % [left bottom width height]
hold(axInset,'on'); grid(axInset,'on');

for i = 1:numel(algo_list)
    errorbar(axInset, x, stats(i).mu, stats(i).sig, '-o', ...
        'LineWidth', 1.3, 'MarkerSize', 4, 'Color', colors(i,:));
end
xlim(axInset, [xlo-0.2, xhi+0.2]);

% Fit y-limits tightly to the visible data in 1..8 so differences pop
idxZoom = xlo:xhi;
all_y = [];
for i = 1:numel(algo_list)
    all_y = [all_y, stats(i).mu(idxZoom)-stats(i).sig(idxZoom), ...
                      stats(i).mu(idxZoom)+stats(i).sig(idxZoom)]; %#ok<AGROW>
end
ymin = min(all_y); ymax = max(all_y);
yr = ymax - ymin; if yr <= 0, yr = max(1e-6, abs(ymax)); end
ylim(axInset, [ymin - 0.1*yr, ymax + 0.1*yr]);

title(axInset,'Zoom: antennas 1–8');
xlabel(axInset,'Antenna index'); ylabel(axInset,'\mu \pm \sigma');

% ---- Optional: emphasize exponential growth visually ----
% If you expect "best\_perf" to grow ~exponentially, uncomment to use log scale:
% set(axInset, 'YScale', 'log'); set(axMain, 'YScale', 'log');

% If you prefer separate panels instead of an inset, use tiledlayout and two axes.

%%

% After plotting
set(gcf,'Color','w');             % white background

% Make axes fill the figure nicely (tight layout)
set(gca,'LooseInset', max(get(gca,'TightInset'), 0.02))

% Save to PDF (vector graphics)
print(gcf, 'antenna_error_plot.pdf', '-dpdf', '-painters');

% Alternatively, exportgraphics is cleaner (R2020a+):
exportgraphics(gcf, 'antenna_error_plot.pdf', 'ContentType','vector', 'BackgroundColor','white', 'Resolution',300);