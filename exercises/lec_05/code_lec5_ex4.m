clearvars
close all
clc

% Load data
load('data/Keri_2020_clean.mat');

% Extract pressure and salinity, remove NaN pairs
pressure = Keri_2020_clean.pressure_dbar;
salinity = Keri_2020_clean.SA_gkg;

valid    = ~isnan(pressure) & ~isnan(salinity);
pressure = pressure(valid);
salinity = salinity(valid);

% Define 10-dbar depth layer bounds
layer_bounds = 0:10:100;   % bounds: 0, 10,..., 100 dbar
n_layers     = length(layer_bounds) - 1;   % number of layers = 10

% Create depth group labels (e.g. "0-10 m", "10-20 m", ...)
layer_labels = cell(n_layers, 1);
for i = 1:n_layers
    layer_labels{i} = sprintf('%d-%d m', layer_bounds(i), layer_bounds(i+1));
end

% Assign each data point to a depth group
dep_group = zeros(size(pressure));
for i = 1:n_layers
    in_layer          = pressure >= layer_bounds(i) & pressure < layer_bounds(i+1);
    dep_group(in_layer) = i;
end

% Remove points outside 0-100 dbar range (dep_group == 0)
keep     = dep_group > 0;
salinity  = salinity(keep);
dep_group = dep_group(keep);

% Convert dep_group to categorical using layer labels for axis tick names
dep_group_cat = categorical(dep_group, 1:n_layers, layer_labels);

% Calculate mean salinity per depth group
summary_tbl  = groupsummary(salinity, dep_group_cat, 'mean');
[group_means, group_names] = groupsummary(salinity, dep_group_cat, 'mean');

% Print arithmetic mean per layer to console
fprintf('--- Mean Salinity per 10-dbar Layer ---\n');
for i = 1:n_layers
    fprintf('  %s:  %.4f g/kg\n', layer_labels{i}, group_means(i));
end

% Visualisation
figure('Name', 'Box chart of salinity distributions per layers', ...
    'Position', [100 100 560 560]);

% Horizontal box chart (Orientation = 'horizontal')
bc = boxchart(dep_group_cat, salinity, ...
    'Orientation',   'horizontal', ...
    'BoxFaceColor',  [0.85 0.45 0.45], ...
    'BoxFaceAlpha',  0.6, ...
    'MarkerStyle',   '.', ...
    'MarkerColor',   [0.4 0.4 0.4]);
hold on

% Overlay arithmetic mean as black dashed line connecting group means
[~, sort_idx] = sort(1:n_layers);
plot(group_means(sort_idx), 1:n_layers, 'k--o', ...
    'LineWidth', 1.5, ...
    'MarkerFaceColor', 'k', ...
    'MarkerSize', 5, ...
    'DisplayName', 'Mean');

% Axes formatting
set(gca, 'YDir', 'reverse');   % shallow layers at top
grid on

xlabel('Salinity (g kg^{-1})');
ylabel('Depth layer');
title('Box chart of salinity distributions per layers');
legend('Location', 'southeast');

% Save figure
gcf_handle = gcf;
gcf_handle.Position = [100 100 560 560];
saveas(gcf_handle, 'lec_05_ex_04_boxchart.png');