% Variables
var 0..10: x;

% Constraints
constraint x mod 4 = 0;

% Objective
var int: objective = (x - 7) * (x - 7);

% Solve
solve minimize objective;

% Output
output ["x = \(x)\n"];