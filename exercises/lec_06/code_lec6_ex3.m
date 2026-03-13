clearvars;
close all;
clc;

auto_quit_after_run = false;

script_tic = tic;
fprintf('[1/6] Starting Exercise 3 script...\n');
drawnow;

% --- Load saved workspace from Lecture 6, Exercise 1 ---
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

fprintf('[2/6] Loading workspace variables...\n');
drawnow;
load(workspace_file, 'WS', 'date_vector', 'time', 'lat', 'lon', 'lsm');
fprintf('[2/6] Workspace loaded (elapsed %.2f s).\n', toc(script_tic));
drawnow;

% --- Build reliable datetime vector ---
fprintf('[3/6] Building datetime vector...\n');
drawnow;
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
fprintf('[3/6] Datetime ready (N = %d, elapsed %.2f s).\n', numel(date_vector), toc(script_tic));
drawnow;

% --- Select one sea location near 60N, 20E ---
fprintf('[4/6] Selecting nearest sea location to target point...\n');
drawnow;
[LON, LAT] = meshgrid(lon, lat);

if ndims(lsm) == 3
	lsm_2d = lsm(:, :, 1)';
else
	lsm_2d = lsm';
end

lat_target_degN = 60;
lon_target_degE = 20;

sea_mask = lsm_2d == 0;
distance_to_target = sqrt((LAT - lat_target_degN).^2 + (LON - lon_target_degE).^2);
distance_to_target(~sea_mask) = NaN;

[~, linear_idx] = min(distance_to_target, [], 'all', 'omitnan');
[lat_idx, lon_idx] = ind2sub(size(distance_to_target), linear_idx);
fprintf('[4/6] Location selected: %.2f°N, %.2f°E (elapsed %.2f s).\n', lat(lat_idx), lon(lon_idx), toc(script_tic));
drawnow;

% --- Monthly mean wind speed for every year at one location ---
fprintf('[5/6] Computing monthly mean wind speed per year...\n');
drawnow;
WS_ms = squeeze(WS(lon_idx, lat_idx, :));
WS_ms = WS_ms(:);

year_values = year(date_vector);
month_values = month(date_vector);

valid = ~isnan(WS_ms) & ~isnat(date_vector);
WS_ms = WS_ms(valid);
year_values = year_values(valid);
month_values = month_values(valid);

unique_years = unique(year_values);
n_years = numel(unique_years);
monthly_mean_WS_ms = NaN(n_years, 12);

for i_year = 1:n_years
	this_year = unique_years(i_year);
	for i_month = 1:12
		idx = year_values == this_year & month_values == i_month;
		if any(idx)
			monthly_mean_WS_ms(i_year, i_month) = mean(WS_ms(idx), 'omitnan');
		end
	end
end
fprintf('[5/6] Monthly means computed for %d years (elapsed %.2f s).\n', n_years, toc(script_tic));
drawnow;

% --- Plot: y = wind speed, x = month ---
fprintf('[6/6] Creating plot...\n');
drawnow;
figure('Color', 'w');
hold on;

x_month = 1:12;
for i_year = 1:n_years
	plot(x_month, monthly_mean_WS_ms(i_year, :), '-o', 'LineWidth', 1.2, 'MarkerSize', 4);
end

grid on;
box on;
xlabel('Month');
ylabel('Wind speed (m s^{-1})');
title(sprintf('Monthly Mean Wind Speed at %.2f°N, %.2f°E', lat(lat_idx), lon(lon_idx)));
xticks(1:12);
xticklabels({'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'});
legend(string(unique_years), 'Location', 'eastoutside');
fprintf('[6/6] Plot ready. Total elapsed %.2f s.\n', toc(script_tic));
drawnow;

if usejava('desktop')
	fprintf('[INFO] MATLAB Desktop mode: it will stay open after script finish. Type "exit" to close.\n');
	if auto_quit_after_run
		fprintf('[INFO] auto_quit_after_run=true -> closing MATLAB now.\n');
		quit force;
	end
else
	fprintf('[INFO] Batch mode: MATLAB exits automatically when script ends.\n');
end
