int: n;
set of int: INDEX = 1..n;
array[INDEX] of var 0..3: x;

% first element is 0, last element is 3
constraint x[1] = 0;
constraint x[n] = 3;

% for all the indices i, x[i] + x[i+1] <= 3
constraint forall(i in INDEX where i < n)(x[i]+x[i+1] <= 3);
% for index divisible by 3, x[index] >= 2
constraint forall(i in INDEX where i mod 3 = 0)(x[i] >= 2);

% maximize the sum of the array
solve maximize sum(i in INDEX)(x[i]);

% Output sum(x) = x
output ["x = \(x), sum = \(sum(x))\n"];

% for n between 3 and 9 : 
% n = 4 is unsatisfiable
% n = 7 is unsatisfiable