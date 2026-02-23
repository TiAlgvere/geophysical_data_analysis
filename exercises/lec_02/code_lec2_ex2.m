clearvars
close all
format long
clc

target_dir = 'exercises/lec_02/results';
file_name = 'results_lec2_ex2.mat';

% Generate matrix
X = rand(20,30);

%Statistics
%min
matrix.min.all= min(X(:));
matrix.min.col = min(X, [], 1);
matrix.min.row = min(X, [], 2);

%max
matrix.max.all=max(X(:));
matrix.max.col = max(X, [], 1);
matrix.max.row = max(X, [], 2);

%mean
matrix.mean.all= mean(X(:));
matrix.mean.col = mean(X, 1);
matrix.mean.row = mean(X, 2);


%median
matrix.median.all= median(X(:));
matrix.median.col = median(X, 1);
matrix.median.row = median(X, 2);


%sum
matrix.sum.all= sum(X(:));
matrix.sum.col = sum(X, 1);
matrix.sum.row = sum(X, 2);

%Minimum value of the matrix
disp('Minimum value of the matrix:')
disp('Entire matrix:')
disp(matrix.min.all)
disp('Per column:')
disp(matrix.min.col)
disp('Per row:')
disp(matrix.min.row)
disp('------------------------------')

%Maximum value of the matrix
disp('Maximum value of the matrix:')
disp('Entire matrix:')
disp(matrix.max.all)
disp('Per column:')
disp(matrix.max.col)
disp('Per row:')
disp(matrix.max.row)
disp('------------------------------')

%Mean value of the matrix
disp('Mean value of the matrix:')
disp('Entire matrix:')
disp(matrix.mean.all)
disp('Per column:')
disp(matrix.mean.col)
disp('Per row:')
disp(matrix.mean.row)
disp('------------------------------')

%Median value of the matrix
disp('Median value of the matrix:')
disp('Entire matrix:')
disp(matrix.median.all)
disp('Per column:')
disp(matrix.median.col)
disp('Per row:')
disp(matrix.median.row)
disp('------------------------------')

%Sum of the matrix
disp('Sum of the matrix:')
disp('Entire matrix:')
disp(matrix.sum.all)
disp('Per column:')
disp(matrix.sum.col)
disp('Per row:')
disp(matrix.sum.row)
disp('------------------------------')

%saving

disp('Saving workspace...')

if ~exist(target_dir, 'dir')
    mkdir(target_dir)
end

try
    save(fullfile(target_dir, file_name), 'X', 'matrix')
    disp('Workspace saved successfully')
catch ME
    disp('Error saving workspace:')
    disp(ME.message)
end

