clearvars
close all
clc

my_char = 'Hello, character.';
my_str = "Hello, string.";
my_str_num = "67";
my_num = 42;
dt = datetime(2024,6,1,12,30,45);
my_table = table({my_char},my_str, my_str_num, my_num, dt)
my_matrix = rand(3,3);

%1. Charactor to double and vice versa
class(my_char)
char_double= double(my_char)
class(char_double)
char_back = char(char_double)

disp('------------------------------')

%2. String to double and vice versa
class(my_str_num)
str_double = double(my_str_num)
class(str_double)
str_back = string(str_double)

disp('------------------------------')

%3. Char to string to double
class(my_char)
char_to_str = string(my_char)
class(char_to_str)
char_to_str_double = double(char_to_str)
class(char_to_str_double)
disp('------------------------------')

%4. Num vector to logical
class(my_num)
num_to_logical = logical(my_num)
class(num_to_logical)
disp('------------------------------')

%5. character,string and double arrays to cell arrays
char_cell = cellstr(my_char)
str_cell = cellstr(my_str)
double_cell = num2cell(str_double)
disp('------------------------------')

%6. datetime array from year,month,day,hour,minute,second and vice versa
class(dt)
dt_to_num = datenum(dt)
class(dt_to_num)
dt_back = datetime(dt_to_num, 'ConvertFrom', 'datenum')
class(dt_back)
disp('------------------------------')

%7. arrays to table and arrays from table
class(my_table)
my_table_from_array = array2table([my_num, dt_to_num], 'VariableNames', {'Number', 'DateNum'})
class(my_table_from_array)
table_to_array = table2array(my_table_from_array)
class(table_to_array)
disp('------------------------------')

%8. matrix to cell array and vice versa
class(my_matrix)
matrix_to_cell = num2cell(my_matrix)
class(matrix_to_cell)
cell_to_matrix = cell2mat(matrix_to_cell)
class(cell_to_matrix)
disp('------------------------------')