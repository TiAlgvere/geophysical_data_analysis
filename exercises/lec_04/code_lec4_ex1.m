clearvars
close all
clc

% --- Imports ---
data_file = 'data/Keri_2020.mat';
out_dir   = 'exercises/lec_04/results';
out_fig   = fullfile(out_dir, 'Keri_2020_salinity_clean.png');
out_mat   = fullfile(out_dir, 'Keri_2020_clean.mat');

if ~exist(out_dir, 'dir')
    mkdir(out_dir)
end

% --- Data import ---
S = load(data_file);
T = S.T;

% --- Data browsing ---
disp('Variables in table T:')
disp(T.Properties.VariableNames)
disp(head(T))

% --- Change of variables ---
juda_UTC = T.juda_UTC;
depth_m  = T.depth_m;
SA_gkg   = T.SA_gkg;

% --- Plot before outlier removal ---
figure('Color', 'w')
scatter(juda_UTC, depth_m, 8, SA_gkg, 'filled')
set(gca, 'YDir', 'reverse')
grid on
title('Keri 2020 – all data')

% --- Bad data removal ---
% Find profiles by unique Julian day
[profile_days, ~, pid] = unique(juda_UTC);
n = numel(profile_days);

% Salinity at max depth per profile
sal_bot = nan(n, 1);
for i = 1:n
    idx = pid == i;
    [~, imax]  = max(depth_m(idx));
    tmp = SA_gkg(idx);
    sal_bot(i) = tmp(imax);
end

% Keep profiles: salinity at max depth >= 7 g/kg and after day 60
keep = sal_bot >= 7 & profile_days >= 60;
keep_rows = keep(pid);

Keri_2020_clean = T(keep_rows, :);

juda_UTC_c = Keri_2020_clean.juda_UTC;
depth_m_c  = Keri_2020_clean.depth_m;
SA_gkg_c   = Keri_2020_clean.SA_gkg;

% --- Plot cleaned data ---
figure('Color', 'w')
scatter(juda_UTC_c, depth_m_c, 8, SA_gkg_c, 'filled')
set(gca, 'YDir', 'reverse')
grid on
xlabel('Julian Day (UTC)')
ylabel('Depth (m)')
title('Keri 2020 – salinity profiles (cleaned)')
cb = colorbar;
cb.Label.String = 'Salinity (g kg^{-1})';

% Save figure
exportgraphics(gcf, out_fig, 'Resolution', 300)

% --- Save cleaned table ---
save(out_mat, 'Keri_2020_clean')
