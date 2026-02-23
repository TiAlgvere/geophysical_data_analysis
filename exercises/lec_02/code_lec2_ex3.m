clearvars
close all
format long
clc

target_dir = 'exercises/lec_02/results';

%Loading the matrix from previous exercise
load('exercises/lec_02/results/results_lec2_ex2.mat', 'X');
%disp('X')

writematrix(X, fullfile(target_dir, 'results_lec3_ex3.txt'), 'Delimiter','tab');
writematrix(X, fullfile(target_dir, 'results_lec3_ex3.xlsx'), 'Sheet',1, 'Range','A1');

clearvars

matrix_from_txt = load("exercises\lec_02\results\results_lec3_ex3.txt");
matrix_from_xlsx = xlsread("exercises\lec_02\results\results_lec3_ex3.xlsx");







