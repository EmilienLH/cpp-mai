% assignment 2 - commented submission after getting the correct solution
% select a set of raiding warrior
enum WARRIOR;
WARRIOR: dummy; 
enum CLAN; % the clan they belong to

int: l; % minimum raid party size
int: u; % maximum raid party size
int: m; % limit of hatreds

array[WARRIOR] of int: strength;
array[WARRIOR] of CLAN: clan;

array[CLAN,CLAN] of 0..1: hates;

% array of warriors in the raid
array[1..u] of var WARRIOR: raid_array;

% first ensure the total number of hatreds between warriors in the raid does not exceed m
constraint sum(i, j in 1..u where i < j)(hates[clan[raid_array[i]], clan[raid_array[j]]]) <= m;

% then optimize the search to find the maximum strength of the raid in time
% ensure the first l warriors in the raid are not dummy
constraint forall(i in 1..l)(raid_array[i] > dummy);

% enforce an ordering on the warriors in the raid, and ensure no dummy warrior is included in the raid
constraint forall(i in 1..u-1)(raid_array[i] >= raid_array[i+1] + (raid_array[i+1] != dummy));

% objective function: maximize the total strength of the raid
var int: obj = sum(i in 1..u)(strength[raid_array[i]]);
solve maximize obj;

% convert array to set of warriors for output (needed for checker)
var set of WARRIOR: raid = {raid_array[i] | i in 1..u where raid_array[i] != dummy};

% output the result
output ["raid = \(raid)\n"] ++ ["obj = \(obj)\n"];