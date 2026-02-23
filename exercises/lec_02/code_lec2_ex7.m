clearvars
close all
clc

%Analyze the data table
opts = detectImportOptions('data\data_for_lec2_ex6.txt');

% only load the coordinates and depth
opts.SelectedVariableNames = {'Longitude', 'Latitude', 'Depth_m'};

% load again based on the new rules
table1 = readtable('data\data_for_lec2_ex6.txt', opts);

disp('')
disp(head(table1))

opts.SelectedVariableNames = {'Depth_m', 'Temperature_degreesC', 'Salinity_psu'};
table2 = readtable('data\data_for_lec2_ex6.txt', opts);
table2 = sortrows(table2, 'Salinity_psu');
disp('Sorted Table 2:')
disp(head(table2))

% Table joining

joined_data1 = join(table1, table2);
disp('Joined Table 1 and Table 2:')
disp(head(joined_data1))

joined_data2 = join(table2, table1);
disp('Joined Table 2 and Table 1:')
disp(head(joined_data2))

joined_data3 = outerjoin(table1, table2);
disp('Outerjoined Table 1 and Table 2:')
disp(head(joined_data3))

joined_data4 = outerjoin(table1, table2, 'Type', 'left', 'MergeKeys', true);
disp('Left Outerjoined Table 1 and Table 2:')
disp(head(joined_data4))

joined_data5 = innerjoin(table1, table2);
disp('Innerjoined Table 1 and Table 2:')
disp(head(joined_data5))


