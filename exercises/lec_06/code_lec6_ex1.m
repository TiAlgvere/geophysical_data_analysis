clearvars
close all
clc

% Read data from NetCDF file  
filename = 'data/data_stream-oper_stepType-instant.nc';
if ~exist(filename, 'file')
    % Try relative path from exercises/lec_06
    filename = '../../data/data_stream-oper_stepType-instant.nc';
    if ~exist(filename, 'file')
        error('NetCDF file not found. Current directory: %s', pwd);
    end
end

% Display available variables
info = ncinfo(filename);
disp('Available variables:');
for i = 1:length(info.Variables)
    fprintf('  %s: %s\n', info.Variables(i).Name, mat2str(info.Variables(i).Size));
end

% Read data using correct variable names (ncread step)
time = ncread(filename, 'valid_time');
lat = ncread(filename, 'latitude');
lon = ncread(filename, 'longitude');
u10 = ncread(filename, 'u10');
v10 = ncread(filename, 'v10');
sst = ncread(filename, 'sst');
lsm = ncread(filename, 'lsm');

% Make date vector (datetime step)
date_vector = datetime(time, 'ConvertFrom', 'datenum');

% Create grid of coordinates (meshgrid step)
[LON, LAT] = meshgrid(lon, lat);

% Calculate wind speed and direction (Mathematical, North = 0 degrees)
WS = sqrt(u10.^2 + v10.^2);
WD = mod(atan2d(u10, v10), 360);

% Get yearly mean of wind speed for each grid cell
WS_yearly_mean = mean(WS, 3);

% Plot one year of means (imagesc step)
figure;
imagesc(lon, lat, WS_yearly_mean');
axis xy;
colorbar;
title('Yearly Mean for Year 1');
xlabel('Longitude');
ylabel('Latitude');

% Use data on land-sea mask to mark land data as NaN
WS_yearly_mean_sea = WS_yearly_mean;
if ndims(lsm) == 3
    lsm_2d = lsm(:,:,1);
else
    lsm_2d = lsm;
end
WS_yearly_mean_sea(lsm_2d == 1) = NaN;

% Plot sea-only data
figure;
imagesc(lon, lat, WS_yearly_mean_sea');
axis xy;
colorbar;
title('Yearly Mean for Year 1 - SEA');
xlabel('Longitude');
ylabel('Latitude');

% Save workspace to existing results folder
script_dir = fileparts(mfilename('fullpath'));
if isempty(script_dir)
    script_dir = pwd;
end
results_dir = fullfile(script_dir, 'results');
if ~exist(results_dir, 'dir')
    mkdir(results_dir)
end
save(fullfile(results_dir, 'workspace_lec6_ex1.mat'));
