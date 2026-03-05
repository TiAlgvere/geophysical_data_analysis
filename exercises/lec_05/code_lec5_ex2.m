clearvars
close all
clc

% Load data
% Table with halocline lower border depth and oxygen at deepest depth
load('exercises/lec_04/results/results_lec4_ex2.mat');

% Extract variables
x = results.halocline_depth_dbar;   % halocline lower border depth (dbar)
y = results.bottom_do_mgl;          % oxygen at bottom (mg/L)

% Remove NaN fields
valid = ~isnan(x) & ~isnan(y);
x = x(valid);
y = y(valid);

%% Basic statistics
fprintf('--- Basic Statistics ---\n');
fprintf('Variable X (Halocline lower border):\n');
fprintf('  Mean:   %.4f dbar\n',   mean(x));
fprintf('  Median: %.4f dbar\n',   median(x));
fprintf('  Min:    %.4f dbar\n',   min(x));
fprintf('  Max:    %.4f dbar\n',   max(x));
fprintf('  Std:    %.4f dbar\n\n', std(x));

fprintf('Variable Y (Oxygen at bottom):\n');
fprintf('  Mean:   %.4f mg/L\n',   mean(y));
fprintf('  Median: %.4f mg/L\n',   median(y));
fprintf('  Min:    %.4f mg/L\n',   min(y));
fprintf('  Max:    %.4f mg/L\n',   max(y));
fprintf('  Std:    %.4f mg/L\n\n', std(y));

% Correlation: r, R², and p-value
[R_matrix, P_matrix] = corrcoef(x, y);
r       = R_matrix(1, 2);
p_value = P_matrix(1, 2);
R2      = r^2;

fprintf('--- Correlation ---\n');
fprintf('  r       = %.4f\n',   r);
fprintf('  R2      = %.4f (%.0f%% of variance explained)\n', R2, R2*100);
fprintf('  p-value = %.4f\n\n', p_value);

% Linear fit
p     = polyfit(x, y, 1);   % p(1) = slope, p(2) = intercept
y_fit = polyval(p, x);      % linear fit values at x

% Visualisation
figure('Name', 'Correlation Analysis', 'Position', [100 100 560 480]);

% Scatter of data points
scatter(x, y, 40, 'b', 'filled', 'DisplayName', 'Data points');
hold on

% Linear fit line (sort x for clean line)
x_sorted = sort(x);
y_sorted = polyval(p, x_sorted);
plot(x_sorted, y_sorted, '-r', 'LineWidth', 2, 'DisplayName', 'Linear Fit');

% Equation text on figure
eq_str = sprintf('y = %gx + %g', round(p(1), 6), round(p(2), 4));
text(0.55, 0.75, eq_str, ...
    'Units', 'normalized', ...
    'Color', [0.13 0.55 0.13], ...
    'FontSize', 10);

% Labels and formatting
xlabel('Variable X (Halocline lower border (dbar))');
ylabel('Variable Y (Oxygen at bottom (mg L^{-1}))');
title(sprintf('Correlation Analysis (r = %.1f)', r));
subtitle(sprintf('%.0f%% of variance is explained by the fit', R2*100));
legend('Location', 'northeast');
grid on

% Save figure
gcf_handle = gcf;
gcf_handle.Position = [100 100 560 480];
saveas(gcf_handle, 'lec_05_ex_02_correlation.png');