int: n; % Length of the array

array[1..n] of var 1..9: x; % Array of numbers from 0 to 9
% If we let 0 be a possible value, the solver will always choose [0,...,0] as the solution since sum and product will be 0

constraint
    sum(x) = product(x); % Sum of the numbers equals the product of the numbers

constraint forall(i in 1..n-1)(x[i] <= x[i+1]);

solve satisfy;

output ["x = \(x), sum = \(sum(x)), product = \(product(x))\n"];