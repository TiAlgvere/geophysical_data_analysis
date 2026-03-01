clearvars
close all
clc

% --- Imports ---
data_file = 'exercises/lec_04/results/Keri_2020_clean.mat';
out_dir   = 'exercises/lec_04/results';
out_mat   = fullfile(out_dir, 'results_lec4_ex2.mat');

if ~exist(out_dir, 'dir')
    mkdir(out_dir)
end

% --- Data import ---
S = load(data_file);
T = S.Keri_2020_clean;

% --- Plot all salinity profiles (x=SA, y=pressure, color=Julian Day) ---
figure('Color', 'w')
scatter(T.SA_gkg, T.pressure_dbar, 8, T.juda_UTC, 'filled')
set(gca, 'YDir', 'reverse')
grid on
xlabel('Salinity (g kg^{-1})')
ylabel('Pressure (dbar)')
title('Keri 2020 – all salinity profiles')
cb = colorbar;
cb.Label.String = 'Julian Day (UTC)';

% --- Subset: Julian Day > 270 ---
mask = T.juda_UTC > 270;
Tsub = T(mask, :);

juda_UTC     = Tsub.juda_UTC;
SA_gkg       = Tsub.SA_gkg;
pressure_dbar = Tsub.pressure_dbar;
do_mgl       = Tsub.do_mgl;

n = height(Tsub);

% --- Smooth data: manual mean over 2.5 m---
SA_smooth = nan(n, 1);
for i = 3:n-2
    SA_smooth(i) = mean(SA_gkg(i-2:i+2));
end

% --- Calculate vertical salinity gradient  ---
SA_gradient = nan(n, 1);
for i = 3:n-2
    SA_gradient(i) = (SA_smooth(i+2) - SA_smooth(i-2)) / ...
                     (pressure_dbar(i+2) - pressure_dbar(i-2));
end

% --- Find halocline: gradient > 0.07 g/kg/m and pressure > 40 dbar ---
halocline = SA_gradient > 0.07 & pressure_dbar > 40;

% --- Visualize halocline SA values ---
figure('Color', 'w')
scatter(SA_gkg(halocline), pressure_dbar(halocline), 10, juda_UTC(halocline), 'filled')
set(gca, 'YDir', 'reverse')
grid on
xlabel('Salinity (g kg^{-1})')
ylabel('Pressure (dbar)')
title('Halocline layer – SA values (Julian Day > 270)')
cb = colorbar;
cb.Label.String = 'Julian Day (UTC)';

% --- Deepest halocline point and bottom O2 per Julian Day ---
unique_days = unique(juda_UTC);
nd = numel(unique_days);

halo_depth_dbar = nan(nd, 1);   
bottom_do_mgl   = nan(nd, 1);

for i = 1:nd
    day_mask = juda_UTC == unique_days(i);

    % deepest halocline point
    halo_idx = halocline & day_mask;
    if any(halo_idx)
        halo_depth_dbar(i) = max(pressure_dbar(halo_idx));
    end

    % oxygen at bottom depth
    [~, ibot] = max(pressure_dbar(day_mask));
    tmp = do_mgl(day_mask);
    bottom_do_mgl(i) = tmp(ibot);
end

% --- Build and save result table ---
results = table(unique_days, halo_depth_dbar, bottom_do_mgl, ...
    'VariableNames', {'juda_UTC', 'halocline_depth_dbar', 'bottom_do_mgl'});

save(out_mat, 'results')
disp(results)
