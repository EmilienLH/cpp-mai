array[int] of int: readings;
int: start;
int: n = length(readings);
set of int: HOUR = 1..n;
set of int: HOUR0 = 0..n;

enum CHOICE = {heat, strongly_heat, cool, strongly_cool, do_nothing};
array [CHOICE] of int: temp_change = [1, 4, -2, -5, 0];
array [CHOICE] of int: cost = [1, 5, 3, 9, 0];

array[HOUR] of var CHOICE: choice;
array[HOUR0] of var 25..30: temp;

% First : temp[0] = start
constraint temp[0] = start;

% Now let's define the real temperature, based on the readings and the previous temperature, and the choice
constraint forall(h in HOUR)(
    temp[h] = (readings[h] + temp[h-1]) div 2 + temp_change[choice[h]]
);

% Now let's define the total cost, that we want to minimize
var int: obj;
constraint obj = sum(h in HOUR)(cost[choice[h]]);

solve minimize obj;

output ["choice = \(choice);\ntemp = \(temp);\ntotal_cost = \(obj);\n"];