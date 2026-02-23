clearvars
close all
clc


% Create a random variable and write it to the .nc file 
rand_temp = rand(10, 5, 5);   
ncwrite(nc_file, 'temperature', rand_temp);

rand_sal  = rand(10, 5, 5);
ncwrite(nc_file, 'salinity', rand_sal);

%Load the entire variable from the .nc file
temp_full = ncread(nc_file, 'temperature');
disp('Full temperature variable size:');
disp(size(temp_full));

% Load a subset by defining start and count for each dimension 
xs = 2;  ys = 1;  zs = 1;
xe = 4;  ye = 3;  ze = 3;

temp_sub = ncread(nc_file, 'temperature', [xs, ys, zs], [xe, ye, ze]);
fprintf('Subset temperature size (start=[%d,%d,%d], count=[%d,%d,%d]):\n', ...
        xs, ys, zs, xe, ye, ze);
disp(size(temp_sub));

% Create a (1,N,N) subset from the full variable, then squeeze
N = 5;
temp_1NN = temp_full(1, 1:N, 1:N);
fprintf('Before squeeze: ');
disp(size(temp_1NN));

temp_squeezed = squeeze(temp_1NN);
fprintf('After  squeeze: ');
disp(size(temp_squeezed));
