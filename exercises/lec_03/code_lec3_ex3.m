clearvars
close all
clc

target_dir = 'exercises/lec_03/results';
nc_file = fullfile(target_dir, 'example2.nc');

% Delete the file if it already exists
if exist(nc_file, 'file')
    delete(nc_file);
    fprintf('Deleted existing file: %s\n', nc_file);
else
    fprintf('No existing file found, creating new: %s\n', nc_file);
end

% Create the .nc file using the netcdf
nc = netcdf.create(nc_file, 'NETCDF4');

% Set dimensions
nx = 5;    % longitude
ny = 5;    % latitude
nt = 10;   % time

% Define fixed dimensions
dim_lon  = netcdf.defDim(nc, 'xaxis_1', nx);
dim_lat  = netcdf.defDim(nc, 'yaxis_1', ny);

% Define unlimited time dimension
unlim_id = netcdf.defDim(nc, 'Time', netcdf.getConstant('NC_UNLIMITED'));

% Define variables
varid1 = netcdf.defVar(nc, 'xaxis_1', 'double', dim_lon);
varid2 = netcdf.defVar(nc, 'yaxis_1', 'double', dim_lat);
varid5 = netcdf.defVar(nc, 'Time',    'double', []);
varid4 = netcdf.defVar(nc, 'temp',    'double', [dim_lon dim_lat unlim_id]);
netcdf.endDef(nc);

% Define attributes
netcdf.putAtt(nc, varid1, 'long_name',      'xaxis_1');
netcdf.putAtt(nc, varid1, 'units',          'none');
netcdf.putAtt(nc, varid1, 'cartesian_axis', 'X');

netcdf.putAtt(nc, varid2, 'long_name',      'yaxis_1');
netcdf.putAtt(nc, varid2, 'units',          'none');
netcdf.putAtt(nc, varid2, 'cartesian_axis', 'Y');

netcdf.putAtt(nc, varid5, 'long_name',      'Time');
netcdf.putAtt(nc, varid5, 'units',          'time level');
netcdf.putAtt(nc, varid5, 'cartesian_axis', 'T');

netcdf.putAtt(nc, varid4, 'long_name', 'temp');
netcdf.putAtt(nc, varid4, 'units',     'none');

% Put data into coordinate variables
netcdf.putVar(nc, varid1, 1:nx);
netcdf.putVar(nc, varid2, 1:ny);
netcdf.putVar(nc, varid5, 1);

% Create random temperature
temperature = rand(nx, ny, nt);

start = [0, 0, 0];
count = [nx, ny, nt];

netcdf.putVar(nc, varid4, start, count, temperature);

% Close the file
netcdf.close(nc);

% summary
ncdisp(nc_file);
