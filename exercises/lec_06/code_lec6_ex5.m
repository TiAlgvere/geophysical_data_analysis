clearvars
close all
clc

% Load the saved workspace from Lecture 6, Exercise 1.
script_dir = fileparts(mfilename('fullpath'));
if isempty(script_dir)
	script_dir = pwd;
end
workspace_file = fullfile(script_dir, 'results', 'workspace_lec6_ex1.mat');
if ~exist(workspace_file, 'file')
	workspace_file = fullfile('exercises', 'lec_06', 'results', 'workspace_lec6_ex1.mat');
end
if ~exist(workspace_file, 'file')
	error('Workspace file not found: %s', workspace_file);
end
load(workspace_file)

if ~exist('date_vector', 'var') || ~isdatetime(date_vector) || any(year(date_vector(1:min(10, end))) > 2200)
	time_vec = double(time(:));
	if max(time_vec, [], 'omitnan') > 1e8
		date_vector = datetime(time_vec, 'ConvertFrom', 'posixtime', 'TimeZone', 'UTC');
		date_vector.TimeZone = '';
	else
		date_vector = datetime(time_vec, 'ConvertFrom', 'datenum');
	end
else
	date_vector = date_vector(:);
end

% Get wind speed from one location.
[LON, LAT] = meshgrid(lon, lat);
if ndims(lsm) == 3
	lsm_2d = lsm(:, :, 1)';
else
	lsm_2d = lsm';
end
lat_target = 60;
lon_target = 20;
sea_mask = lsm_2d == 0;
distance_to_target = sqrt((LAT - lat_target).^2 + (LON - lon_target).^2);
distance_to_target(~sea_mask) = NaN;
[~, linear_idx] = min(distance_to_target, [], 'all', 'omitnan');
if isempty(linear_idx) || isnan(linear_idx)
	error('No sea grid cell found for selected target location.');
end
[lat_idx, lon_idx] = ind2sub(size(distance_to_target), linear_idx);

wind_data = squeeze(WS(lon_idx, lat_idx, :));
wind_data = wind_data(:);

year_values = year(date_vector);
month_values = month(date_vector);
day_values = day(date_vector);
hour_values = hour(date_vector);

idx_time = year_values >= 1997 & year_values <= 2025 & ...
		   month_values >= 1 & month_values <= 12 & ...
		   day_values >= 1 & day_values <= 31 & ...
		   hour_values >= 9 & hour_values <= 21;

wind_data = wind_data(idx_time);
valid = ~isnan(wind_data);
wind_data = wind_data(valid);

if isempty(wind_data)
	error('No valid wind-speed values after filtering.');
end

% Fit the distribution.
params = wblfit(wind_data);
scale = params(1);
shape = params(2);

% Create a histogram.
figure('Color', 'w')
h = histogram(wind_data, 'Normalization', 'pdf');
hold on

% Generate Weibull PDF values for plotting.
x_range = 0:0.1:max(wind_data);
y_weibull = wblpdf(x_range, scale, shape);

% Plot the curve.
p = plot(x_range, y_weibull, 'r-', 'LineWidth', 2);
grid on
xlabel('Wind speed (m s^{-1})')
ylabel('Probability density')
title(sprintf('Weibull Fit at %.2f%cN, %.2f%cE', lat(lat_idx), char(176), lon(lon_idx), char(176)))
legend([h, p], {'Observed PDF', 'Weibull PDF'}, 'Location', 'best')

% Use your previously calculated parameters to calculate probability of a storm.
A = scale;
k = shape;
threshold = 25;
prob_below = wblcdf(threshold, A, k);
prob_storm = 1 - prob_below;

fprintf('Weibull scale A: %.6f\n', A);
fprintf('Weibull shape k: %.6f\n', k);
fprintf('The probability of wind exceeding %d m/s is: %.4f%%\n', threshold, prob_storm * 100);
