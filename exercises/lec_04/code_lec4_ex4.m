clearvars
close all
clc

% --- Imports ---
data_file = 'exercises/lec_04/results/Keri_2020_clean.mat';

% --- Data import ---
S = load(data_file);
T = S.Keri_2020_clean;

juda_UTC     = T.juda_UTC;
SA_gkg       = T.SA_gkg;
pressure_dbar = T.pressure_dbar;

n = height(T);

% --- Smooth all profiles per-profile (to avoid blending across casts) ---
SA_smooth1 = nan(n, 1);   % movmean  w=5
SA_smooth2 = nan(n, 1);   % gaussian w=11

unique_days = unique(juda_UTC);

for i = 1:numel(unique_days)
    idx = juda_UTC == unique_days(i);
    SA_smooth1(idx) = smoothdata(SA_gkg(idx), 'movmean',  5);
    SA_smooth2(idx) = smoothdata(SA_gkg(idx), 'gaussian', 11);
end

% --- Find halocline from smooth1 (gradient > 0.07 g/kg/m, pressure > 40 dbar) ---
% Per-profile gradient using 4-point central difference (0.5 dbar step)
SA_gradient = nan(n, 1);

for i = 1:numel(unique_days)
    idx  = find(juda_UTC == unique_days(i));
    m    = numel(idx);
    p    = pressure_dbar(idx);
    s    = SA_smooth1(idx);
    grad = nan(m, 1);
    for k = 3:m-2
        grad(k) = (s(k+2) - s(k-2)) / (p(k+2) - p(k-2));
    end
    SA_gradient(idx) = grad;
end

halocline = SA_gradient > 0.07 & pressure_dbar > 40;

% --- FIG 1: all profiles coloured by Julian Day + halocline overlay ---
figure('Color', 'w')
scatter(SA_gkg, pressure_dbar, 6, juda_UTC, 'filled')
hold on

% halocline points highlighted as black circles
scatter(SA_gkg(halocline), pressure_dbar(halocline), 20, 'k', 'o', ...
        'DisplayName', 'Halocline')
hold off
set(gca, 'YDir', 'reverse')
grid on
xlabel('Salinity (g kg^{-1})')
ylabel('Pressure (dbar)')
title('Keri 2020 – all profiles + halocline (smooth1)')
cb = colorbar;
cb.Label.String = 'Julian Day (UTC)';
legend('Location', 'best')

% --- FIG 2: difference  ---
diff1 = SA_gkg - SA_smooth1;

figure('Color', 'w')
scatter(juda_UTC, pressure_dbar, 6, diff1, 'filled')
set(gca, 'YDir', 'reverse')
grid on
xlabel('Julian Day (UTC)')
ylabel('Pressure (dbar)')
title('SA – SA smooth1 (movmean w=5)')
cb = colorbar;
cb.Label.String = '\DeltaSA (g kg^{-1})';

% --- FIG 3: difference SA smooth
diff2 = SA_gkg - SA_smooth2;

figure('Color', 'w')
scatter(juda_UTC, pressure_dbar, 6, diff2, 'filled')
set(gca, 'YDir', 'reverse')
grid on
xlabel('Julian Day (UTC)')
ylabel('Pressure (dbar)')
title('SA – SA smooth2 (gaussian w=11)')
cb = colorbar;
cb.Label.String = '\DeltaSA (g kg^{-1})';
