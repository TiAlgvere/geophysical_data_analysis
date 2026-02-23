clearvars
close all
clc

a = (1:0.4:30)';
b = (2:0.9:67)';

%two random order vectirs
a_rand = a(randperm(length(a)));
b_rand = b(randperm(length(b)));
disp('---------------------------------')

%sorting 
a_sorted_up = sort(a_rand, 'ascend');
a_sorted_down = sort(a_rand, 'descend');
b_sorted_up = sort(b_rand, 'ascend');
b_sorted_down = sort(b_rand, 'descend');
disp('---------------------------------')

%table creation
comb_table = table(a_rand, b_rand);
sortrows(comb_table, 'a_rand', 'ascend')
sortrows(comb_table, 'a_rand', 'descend')
disp('---------------------------------')

%matrix creation
comb_matrix = [a_rand, b_rand];
sortrows(comb_matrix, 1, 'ascend')
sortrows(comb_matrix, 1, 'descend')

%Hardcoded replacement

%Replace the 5th element of a_rand with 999
a_rand(5) = 999;
%replace the value in row 3, column 2 with 888
comb_matrix(3,2) = 888;
%replace the 1st item in the b_rand column with 777
comb_table.b_rand(1) = 777;

%value replacement using logical indexing
a_rand(a_rand > 25) = 0;

%using the find function:
locations = find(a_rand > 10);
b_rand(locations) = -100;






