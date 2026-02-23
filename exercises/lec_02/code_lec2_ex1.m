clearvars
close all
format long
clc

target_dir = 'exercises/lec_02/results';
file_name = 'results_lec2_ex1.mat';

% Create two 5x1 numeric vectors
Z = rand(5,1);
Y = rand(5,1);

disp('Random generated vectors are:')
disp('Vector Z:')
disp(Z)
disp('Vector Y:')
disp(Y)
disp('------------------------------')

disp('Vector addition:')
vector.add = Z + Y;
disp(vector.add)
disp('------------------------------')

disp('Vector subtraction:')
vector.sub = Z - Y;
disp(vector.sub)
disp('------------------------------')

disp('Element-wise multiplication:')
vector.mult = Z .* Y;
disp(vector.mult)
disp('------------------------------')

disp('Element-wise division:')
vector.div = Z ./ Y;
disp(vector.div)
disp('------------------------------')

disp('Saving workspace...')

if ~exist(target_dir, 'dir')
    mkdir(target_dir)
end

try
    save(fullfile(target_dir, file_name))
    disp('Workspace saved successfully')
catch ME
    disp('Error saving workspace:')
    disp(ME.message)
end
