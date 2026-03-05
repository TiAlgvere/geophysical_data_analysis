clearvars
close all
clc

% Load data
load('data/Keri_2020_clean.mat');

% Extract salinity and temperature, remove NaN pairs
S = Keri_2020_clean.SA_gkg;        % absolute salinity (g/kg) - predictor x
T = Keri_2020_clean.CT_degC;       % conservative temperature (deg C) - response y
P = Keri_2020_clean.pressure_dbar; % pressure for colormap

valid = ~isnan(S) & ~isnan(T) & ~isnan(P);
S = S(valid);
T = T(valid);
P = P(valid);

% Fit 2nd degree polynomial: T = B0 + B1*S + B2*S^2
stats     = fitlm(S, T, 'poly2');      % poly2 for quadratic model
R_squared = stats.Rsquared.Ordinary;   % ordinary R²
coef      = stats.Coefficients;        % table with Estimate, SE, tStat, pValue

% Display model summary
fprintf('--- 2nd Degree Polynomial Fit: T = B0 + B1*S + B2*S^2 ---\n');
fprintf('R-squared (Ordinary): %.4f\n\n', R_squared);
disp(coef);

% Extract coefficients for equation label
B0 = coef.Estimate(1);   % intercept
B1 = coef.Estimate(2);   % linear term
B2 = coef.Estimate(3);   % quadratic term

% Predict temperature over a smooth salinity range
S_range = linspace(min(S), max(S), 100);
T_pred  = predict(stats, S_range');

% Visualisation
figure('Name', 'T-S Diagram with Polynomial Fit', 'Position', [100 100 580 520]);

% Scatter coloured by pressure (depth)
scatter(S, T, 5, P, 'filled');
colormap(jet);
cb = colorbar;
cb.Label.String = 'Pressure (dbar)';
hold on

% Polynomial trend line
plot(S_range, T_pred, 'r-', 'LineWidth', 2, 'DisplayName', ...
    sprintf('Poly2 fit (R^2 = %.2f)', R_squared));

% Labels and formatting
xlabel('Salinity (g kg^{-1})');
ylabel('Temperature (degrees C)');
title('T-S Diagram with 2^{nd} Degree Polynomial Fit');
subtitle(sprintf('T = %.4f + %.4f·S + %.4f·S^2', B0, B1, B2));
legend('Location', 'northeast');
grid on

% Save figure
gcf_handle = gcf;
gcf_handle.Position = [100 100 580 520];
saveas(gcf_handle, 'lec_05_ex_03_TS_polyfit.png');