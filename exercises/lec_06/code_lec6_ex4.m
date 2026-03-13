clearvars
close all
clc

% Load saved workspace from Lecture 6, Exercise 1
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

% Get wind speed from one location
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

WS_ms = squeeze(WS(lon_idx, lat_idx, :));
WS_ms = WS_ms(:);

year_values = year(date_vector);
month_values = month(date_vector);
day_values = day(date_vector);
hour_values = hour(date_vector);

idx_time = year_values >= 1997 & year_values <= 2025 & ...
		   month_values >= 1 & month_values <= 12 & ...
		   day_values >= 1 & day_values <= 31 & ...
		   hour_values >= 9 & hour_values <= 21;

WS_ms = WS_ms(idx_time);
valid = ~isnan(WS_ms);
WS_ms = WS_ms(valid);

if isempty(WS_ms)
	error('No valid wind-speed values after filtering.');
end

% Histogram with Normal Distribution Overlay
figure('Color', 'w')
histfit(WS_ms)
grid on
xlabel('Wind speed (m s^{-1})')
ylabel('Frequency')
title(sprintf('Wind Speed Histogram + Normal Fit at %.2f\circN, %.2f\circE', lat(lat_idx), lon(lon_idx)))
