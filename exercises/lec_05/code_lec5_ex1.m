clearvars
close all
clc

% Load data
load('data/Keri_2020_clean.mat');
head(Keri_2020_clean);

% Select profile
stations = unique(Keri_2020_clean.station);
station_id = stations(1);

% Filter table to the selected station
idx = Keri_2020_clean.station == station_id;
profile = Keri_2020_clean(idx, :);

% Extract pressure and absolute salinity for the selected profile
pressure = profile.pressure_dbar;   
SA       = profile.SA_gkg;          

% Sort by pressure (ascending)
[pressure, sort_idx] = sort(pressure);
SA = SA(sort_idx);

% Remove data from the halocline layer (50 – 75 dbar)
halocline_min = 50;   
halocline_max = 75;

% Logical index of data points OUTSIDE the halocline
keep = pressure < halocline_min | pressure > halocline_max;

% Data with halocline removed
pressure_sparse = pressure(keep);
SA_sparse        = SA(keep);

% Define query points
xq = pressure;

% Interpolate missing data
SA_linear = interp1(pressure_sparse, SA_sparse, xq);

% Spline interpolation
SA_spline = interp1(pressure_sparse, SA_sparse, xq, 'spline');

% Visualise all three profiles
figure('Name', 'Salinity data interpolation', 'Position', [100 100 520 620]);

% full scatter
scatter(SA, pressure, 20, 'o', ...
    'MarkerEdgeColor', [0.3 0.3 0.3], ...
    'DisplayName', 'SA');
hold on

% Linear interpolation line
plot(SA_linear, xq, '-b', 'LineWidth', 1.5, 'DisplayName', 'SA linear');

% Spline interpolation line
plot(SA_spline, xq, '-r', 'LineWidth', 1.5, 'DisplayName', 'SA spline');

% Highlight the interpolated (halocline) region
xlims = xlim;
patch([xlims(1) xlims(2) xlims(2) xlims(1)], ...
      [halocline_min halocline_min halocline_max halocline_max], ...
      [0.85 0.85 0.85], ...
      'EdgeColor', 'none', ...
      'FaceAlpha', 0.4, ...
      'HandleVisibility', 'off');

% Axes formatting
set(gca, 'YDir', 'reverse');
xlim([min(SA)*0.99, max(SA)*1.01]);

xlabel('Salinity (g kg^{-1})');
ylabel('Pressure (dbar)');
title('Salinity data interpolation');
subtitle(sprintf('Interpolated data between: %d - %d dbar', ...
    halocline_min, halocline_max));
legend('Location', 'southeast');
grid on

% Save figure
gcf_handle = gcf;
gcf_handle.Position = [100 100 520 620];
saveas(gcf_handle, 'lec_05_ex_01_salinity_interpolation.png');