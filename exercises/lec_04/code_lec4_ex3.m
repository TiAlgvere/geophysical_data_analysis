clearvars
close all
clc

% --- Imports ---
data_file = 'exercises/lec_04/results/Keri_2020_clean.mat';

% --- Data import ---
S = load(data_file);
T = S.Keri_2020_clean;

% --- first unique Julian Day ---
first_day = T.juda_UTC(1);
mask      = T.juda_UTC == first_day;
prof      = T(mask, :);

pressure_dbar = prof.pressure_dbar;
SA_gkg        = prof.SA_gkg;

% --- Smooth option 1: moving mean, window = 5 ---
SA_smooth1 = smoothdata(SA_gkg, 'movmean', 5);

% --- Smooth option 2: Gaussian-weighted, window = 11 ---
SA_smooth2 = smoothdata(SA_gkg, 'gaussian', 11);

% --- Plot: raw vs both smoothed versions ---
figure('Color', 'w')
plot(SA_gkg,     pressure_dbar, 'k.',  'DisplayName', 'Raw')
hold on
plot(SA_smooth1, pressure_dbar, 'b-', 'LineWidth', 1.5, 'DisplayName', 'movmean w=5')
plot(SA_smooth2, pressure_dbar, 'r-', 'LineWidth', 1.5, 'DisplayName', 'gaussian w=11')
hold off
set(gca, 'YDir', 'reverse')
grid on
xlabel('Salinity (g kg^{-1})')
ylabel('Pressure (dbar)')
title(sprintf('Profile smoothing – Julian Day %.0f', first_day))
legend('Location', 'best')
