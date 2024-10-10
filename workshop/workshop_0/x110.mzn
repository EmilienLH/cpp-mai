% Define the range for the decision variable
var 1..10: x;

solve satisfy;

% Output the value of x
output ["x = \(x)"];