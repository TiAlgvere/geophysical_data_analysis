clearvars
close all
clc

% Load workspace from Lecture 6, Exercise 1
script_dir = fileparts(mfilename('fullpath'));
if isempty(script_dir)
	script_dir = pwd;
end
workspace_file = fullfile(script_dir, 'results', 'workspace_lec6_ex1.mat');
if ~exist(workspace_file, 'file')
	workspace_file = fullfile('exercises', 'lec_06', 'results', 'workspace_lec6_ex1.mat');
end
if exist(workspace_file, 'file')
	load(workspace_file)
else
	filename = 'data/data_stream-oper_stepType-instant.nc';
	if ~exist(filename, 'file')
		filename = '../../data/data_stream-oper_stepType-instant.nc';
	end
	time = ncread(filename, 'valid_time');
	lat = ncread(filename, 'latitude');
	lon = ncread(filename, 'longitude');
	u10 = ncread(filename, 'u10');
	v10 = ncread(filename, 'v10');
	lsm = ncread(filename, 'lsm');
	date_vector = datetime(time, 'ConvertFrom', 'datenum');
end

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

% Select one sea location and apply mask
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

u10 = squeeze(u10(lon_idx, lat_idx, :));
v10 = squeeze(v10(lon_idx, lat_idx, :));
WS = sqrt(u10.^2 + v10.^2);

year_values = year(date_vector);
month_values = month(date_vector);
day_values = day(date_vector);
hour_values = hour(date_vector);

idx_time = year_values >= 1997 & year_values <= 2025 & ...
		   hour_values >= 9 & hour_values <= 21 & ...
		   day_values >= 1 & day_values <= 31 & ...
		   month_values >= 1 & month_values <= 12;

u10 = u10(idx_time);
v10 = v10(idx_time);
WS = WS(idx_time);
valid = ~isnan(u10) & ~isnan(v10) & ~isnan(WS);
u10 = u10(valid);
v10 = v10(valid);
WS = WS(valid);

if isempty(u10)
	error('No valid wind data after filtering.');
end

% Wind direction and wind-rose plots
WD_from = mod(atan2d(u10, v10) + 180, 360);
WD_to = mod(atan2d(u10, v10), 360);

dir_edges_deg = 0:10:360;

fig1 = figure('Color', 'w');
ax1 = polaraxes('Parent', fig1);
polarhistogram('Parent', ax1, 'BinEdges', deg2rad(dir_edges_deg), 'Data', deg2rad(WD_from), ...
	'Normalization', 'count', 'FaceColor', [0.2 0.6 0.9], 'EdgeColor', 'k')
ax1.ThetaZeroLocation = 'top';
ax1.ThetaDir = 'clockwise';
thetaticks(0:45:315)
thetaticklabels({'N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'})
title(sprintf('Wind direction frequency at %.2f degN, %.2f degE', lat(lat_idx), lon(lon_idx)))

speed_edges_ms = [0 0.5 10 15 20];
WS_plot = WS;
WS_plot(WS_plot >= speed_edges_ms(end)) = speed_edges_ms(end) - eps;

dir_idx = discretize(WD_from, dir_edges_deg);
spd_idx = discretize(WS_plot, speed_edges_ms);
valid_bins = ~isnan(dir_idx) & ~isnan(spd_idx);

n_dir = numel(dir_edges_deg) - 1;
n_spd = numel(speed_edges_ms) - 1;
bin_counts = accumarray([dir_idx(valid_bins), spd_idx(valid_bins)], 1, [n_dir, n_spd], @sum, 0);
cum_counts = cumsum(bin_counts, 2);

colors = [0 0 1; 0 1 0; 1 1 0; 1 0 0];

fig2 = figure('Color', 'w');
pax = polaraxes('Parent', fig2);
hold(pax, 'on')
h = gobjects(n_spd, 1);
for i_spd = n_spd:-1:1
	h(i_spd) = polarhistogram('Parent', pax, 'BinEdges', deg2rad(dir_edges_deg), 'BinCounts', cum_counts(:, i_spd)', ...
		'FaceColor', colors(i_spd, :), 'EdgeColor', 'k', 'LineWidth', 0.4);
end
ax2 = pax;
ax2.ThetaZeroLocation = 'top';
ax2.ThetaDir = 'clockwise';
pax.ThetaTick = 0:45:315;
pax.ThetaTickLabel = {'N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'};
legend([h(4) h(3) h(2) h(1)], {'15 - 20 m/s', '10 - 15 m/s', '0.5 - 10 m/s', '0 - 0.5 m/s'}, 'Location', 'eastoutside')
title(sprintf('Wind rose by speed class at %.2f degN, %.2f degE', lat(lat_idx), lon(lon_idx)))
