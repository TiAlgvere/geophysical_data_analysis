clearvars
close all
clc

target_dir = 'exercises/lec_03/results';
nc_file = fullfile(target_dir,'example.nc');

%File deleter so you can run the code multiple times without errors
if isfile(nc_file)
    delete(nc_file)
end

%Create netCDF file with two 3D variables
nccreate(nc_file,'temperature','Dimensions',{'time',10,'latitude',5,'longitude',5});
nccreate(nc_file,'salinity','Dimensions',{'time',10,'latitude',5,'longitude',5});

%Write attributes
ncwriteatt(nc_file,'temperature','units','Celsius');
ncwriteatt(nc_file,'temperature','long_name','Water surface temperature');

ncwriteatt(nc_file,'salinity','units','PSU');
ncwriteatt(nc_file,'salinity','long_name','Water salinity');

%global attributes
ncwriteatt(nc_file,'/','Exercise', 'Lecture 3, Exercise 1');
ncwriteatt(nc_file,'/','Author', 'Timo Algvere');

%summary
ncdisp(nc_file)
ncinfo(nc_file)

