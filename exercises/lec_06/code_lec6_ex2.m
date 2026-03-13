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

% Yearly mean wind components and quiver at every 5th coordinate
[LON, LAT] = meshgrid(lon, lat);
u10_yearly_mean = mean(u10, 3)';
v10_yearly_mean = mean(v10, 3)';

if ndims(lsm) == 3
	lsm_2d = lsm(:, :, 1)';
else
	lsm_2d = lsm';
end
u10_yearly_mean(lsm_2d == 1) = NaN;
v10_yearly_mean(lsm_2d == 1) = NaN;

step = 5;
figure('Color', 'w')
quiver(LON(1:step:end, 1:step:end), LAT(1:step:end, 1:step:end), ...
	   u10_yearly_mean(1:step:end, 1:step:end), v10_yearly_mean(1:step:end, 1:step:end), 'b')
grid on
xlabel('Longitude')
ylabel('Latitude')
title('10m Wind Vectors (ERA5)')

% One month and one location (on sea), quiver with axis equal
year_values = year(date_vector);
month_values = month(date_vector);
[group_id, group_year, group_month] = findgroups(year_values, month_values);
group_count = splitapply(@numel, date_vector, group_id);
[~, dense_idx] = max(group_count);
target_year = group_year(dense_idx);
target_month = group_month(dense_idx);
month_idx = year_values == target_year & month_values == target_month;
if ~any(month_idx)
	error('No data found for selected month.')
end

lat_target = 60;
lon_target = 20;
sea_mask = lsm_2d == 0;
distance_to_target = sqrt((LAT - lat_target).^2 + (LON - lon_target).^2);
distance_to_target(~sea_mask) = NaN;
[~, linear_idx] = min(distance_to_target, [], 'all', 'omitnan');
[lat_idx, lon_idx] = ind2sub(size(distance_to_target), linear_idx);

u10_month_point = squeeze(u10(lon_idx, lat_idx, month_idx));
v10_month_point = squeeze(v10(lon_idx, lat_idx, month_idx));
time_month = date_vector(month_idx);
u_month = u10_month_point(:);
v_month = v10_month_point(:);

day_values = day(time_month);
unique_days = unique(day_values);
u_day_mean = NaN(size(unique_days));
v_day_mean = NaN(size(unique_days));

for i_day = 1:numel(unique_days)
	day_idx = day_values == unique_days(i_day);
	u_day_mean(i_day) = mean(u_month(day_idx), 'omitnan');
	v_day_mean(i_day) = mean(v_month(day_idx), 'omitnan');
end

valid_days = ~isnan(u_day_mean) & ~isnan(v_day_mean);
x_month = unique_days(valid_days)';
y_month = zeros(size(x_month));
u_plot = u_day_mean(valid_days)';
v_plot = v_day_mean(valid_days)';

figure('Color', 'w')
quiver(x_month, y_month, u_plot, v_plot, 0, 'k')
axis equal
grid on
xlabel('Day')
ylabel('Wind component (m s^{-1})')
title(sprintf('Wind in %.0fN %.2fE (%s)', lat(lat_idx), lon(lon_idx), datestr(datetime(target_year, target_month, 1), 'mmm yyyy')))
