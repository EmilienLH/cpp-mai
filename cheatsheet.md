# MiniZinc Cheat Sheet

## Model Structure

```mzn
include "globals.mzn";        % Use globals library

int: n;                       % Fixed integer parameter
var 1..n: x;                  % Integer decision variable
array[1..n] of var 1..n: y;   % Array of integer decision variables
constraint sum(y) <= x;       % Constraint

solve satisfy;                % Find satisfying solution

output ["Solution:\n", "x = ", show(x),  % Output list of strings
        "y = \(y)"];                     % Interpolation \(expression)
```

## Basic Types

```mzn
int: i;                      % Integer
3..5: j;                     % Integer with domain

float: f;                    % Floating point number
3.0..5.0: g;                 % Floating point number with domain

bool: b;                     % Boolean

set of int: s;               % Set of integers
set of 3..5: t;              % Set of integers with domain

enum E = { Boat, Airplane }; % Enumerated type
```

## Type-insts

```mzn
var int: x;                  % Declare variable (also with float, bool, and set of int)
var 3..7: y;                 % Declare variable with domain (also 3.0..7.0)
var set of 10..20: s;        % Declare set variable (only fixed set of int!)

array[1..4,1..10] of var 0.0..100.0: f; % Declare 2D array of float variables

var opt 1..10: ox;           % Declare optional int variable (can be 1..10 or "absent", written <>)
```

## Basic Constraints

```mzn
constraint x = y;
constraint x < y;
constraint x <= y;
constraint x > y;
constraint x >= y;
constraint x != y;           % Not equals
```

## Logical Connectives

```mzn
int: d = if i > 10 then a elseif i > 0 then b else c endif; % Conditionals
constraint if x < y then y < z else y > z endif;

constraint x < y \/ y != z;        % Logical "or"
constraint x < y /\ y != z;        % Logical "and"
constraint x < y -> y != z;        % Logical implication
constraint not (x < y /\ y > z);   % Logical negation
```

## Set Constraints

```mzn
constraint s subset t;             % Non-strict subset relation
constraint s intersect t subset w; % Intersection
constraint s union t subset w;     % Union
```

## Predicates and Functions

```mzn
constraint all_different(x);       % Predicate call
constraint mydiv(x,y) = 2;         % Function call
```

## Comprehensions and Generators

```mzn
array[int] of int: a = [ i | i in 1..10]; % Create array [1,2,3,4,5,6,7,8,9,10]

array[int] of int: a = [ i | i in 1..10 where i mod 3=0]; % Create array [3, 6, 9]

constraint forall (i,j in 1..n where i<j) (x[i] != x[j]); % Same as
constraint forall ([ x[i] != x[j] | i,j in 1..n where i<j ]);
```

## Array Index Set Coercions

```mzn
array[20..30] of int: i = array1d(20..30, x);

array[int,int] of float: x = array2d(1..10, 1..10, [ 0.0 | i,j in 1..10 ]);
```

## Search and Search Annotations

```mzn
solve maximize sum(x);        % Optimization
solve minimize sum(x);

solve ::int_search([x,y,z], input_order, indomain_min) satisfy; % Search annotation
                      % Variable selection (examples):
                      %   input_order, first_fail, max_regret, smallest
                      % Value selection (examples):
                      %   indomain_min, indomain_max, indomain,
                      %   indomain_split, indomain_reverse_split
                      % Similar for bool_search, set_search, float_search

solve ::seq_search([int_search(x, first_fail, indomain),
                    int_search(y, input_order, indomain_min)])
      satisfy;                % First search x, then y
```

## Strings and Output

```mzn
string: s = "a" ++ join(", ",[show(x[i]) | i in 1..3]); % Concatenation using ++, join arrays using string ", ", convert expression into string using show
```

## User-defined Predicates and Functions

```mzn
predicate no_overlap(var int: start0, var int: duration0,
                     var int: start1, var int: duration1) =
  start0 + duration0 <= start1 \/ start1 + duration1 <= start0;

function var float: average(array[int] of var int: x) =
  sum(x) / length(x);
```

## Example

Here is a complete example combining the above elements:

```mzn
% Variables
var 0..100: x;
var 0..100: y;
var 0..100: z;

% Constraints
constraint x + y = z;
constraint x > 0;
constraint y > 0;

% Solve
solve maximize z;

% Output
output ["x = ", show(x), "\n", "y = ", show(y), "\n", "z = ", show(z), "\n"];
```