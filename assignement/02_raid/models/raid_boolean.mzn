% assignment 2
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

% boolean array to try to speed up the search, based on tip from the teacher in forum
array[WARRIOR] of var bool: in_raid;

% cardinality constraint : l <= raid <= u
% boolean array : sum of presence of warriors in the raid should be between l and u
constraint sum(w in WARRIOR)(in_raid[w]) >= l /\ sum(w in WARRIOR)(in_raid[w]) <= u;

% ensure no dummy warrior is included in the raid
% with the boolean array, we can just set the dummy warrior to false as a constraint
constraint in_raid[dummy] = false;

% ensure no two warriors in the raid hate each other more than m
% boolean array : presence is 1, so if two people are present, the multiplication will be 1*hate
constraint sum(w1, w2 in WARRIOR where w1 < w2)(in_raid[w1] * in_raid[w2] * hates[clan[w1], clan[w2]]) <= m;

% objective function: maximize the total strength of the raid
var int: obj = sum(w in WARRIOR)(in_raid[w] * strength[w]);
solve maximize obj;

% convert boolean array to set of warriors for output (needed for checker)
var set of WARRIOR: raid = {w | w in WARRIOR where in_raid[w]};

% output the result
output ["raid = \(raid)\n"] ++ ["obj = \(obj)\n"];