clearvars
close all
clc


opts = detectImportOptions('data\data_for_lec2_ex6.txt');

% Load full table
T = readtable('data\data_for_lec2_ex6.txt');


% Only the chosen columns
opts.SelectedVariableNames = {'Longitude', 'Latitude'};
T_selected = readtable('data\data_for_lec2_ex6.txt', opts);

disp('--- Table Summary ---')
summary(T)
summary(T_selected)

disp('--- Table Properties ---')
disp(T.Properties)

disp('--- Variable Names ---')
disp(T.Properties.VariableNames)

% Rename a variable
T_renamed = renamevars(T, 'Depth_m', 'Depth');

table_rows = height(T);
table_cols = width(T);

disp('--- Table Dimensions ---')
disp(['Rows: ', num2str(table_rows), ' | Columns: ', num2str(table_cols)])

% head() shows the first 8 rows
disp('--- Head (Top 8 Rows) ---')
disp(head(T_renamed))

% tail() shows the last 8 rows
disp('--- Tail (Bottom 8 Rows) ---')
disp(tail(T_renamed))