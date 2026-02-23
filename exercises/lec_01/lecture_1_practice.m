a = 2;
b = 3;
c = a + b;

%data types
A = [1 2 3; 4 5 6; 7 8 9]; % 3x3 matrix

myStr = 'Hello'; % regular string
myStr(1) %Matlab starts counting from 1 not 0...

myStrArray = ["Hello", "Matlab", "Sucks"]; % character array
myStrArray(3)

myCell = {1, "text", [1 2 3]}; % cell array
myCell{1,2} % row 1, columns 2
myCell{2} % linear indexing

myMatrix = {'A', 'B';'C','D'};
myMatrix{1,2} % row 1, column 2

student.name = 'Timo';

Z = zeros(3,3); % 3x3 matrix of zeros
R = rand(3,3); % 3x3 matrix of random numbers between 0 and 1
L = linspace(0,10,5); % 5 linearly spaced points between 0 and 10
E = A .* A; % element-wise multiplication of A with itself
F = A'; % transpose of A

%Plotting
x = linspace(0,10,100);
y = sin(x);
plot(x,y)
title('Sine Wave')
xlabel('x')
ylabel('sin(x)')
grid on
legend('sin(x)','Location','northoutside','color','none')
xticks(0:pi/2:10);