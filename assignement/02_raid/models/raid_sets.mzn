% assignment 2
% select a set of raiding warrior
enum WARRIOR;
WARRIOR: dummy;
enum CLAN; % the clan they belong too

int: l; % minimum raid party size
int: u; % maximum raid party size
int: m; % limit of hatreds

array[WARRIOR] of int: strength;
array[WARRIOR] of CLAN: clan;

array[CLAN,CLAN] of 0..1: hates;

var set of WARRIOR: raid;

% cardinality constraint : l <= raid <= u
constraint card(raid) >= l /\ card(raid) <= u;

% ensure no dummy warrior is included in the raid
constraint forall(w in raid)(w > dummy);

% ensure no two warriors in the raid hate each other more than m
constraint sum(w1, w2 in raid where w1 < w2)(hates[clan[w1], clan[w2]]) <= m;

% symmetry breaking: enforce an ordering on the warriors in the raid
constraint forall(w1, w2 in raid where w1 < w2)(w1 < w2);

% redundant constraint: sum of strengths should be at least l * minimum strength
constraint sum(w in raid)(strength[w]) >= l * min(strength);

% objective function: maximize the total strength of the raid
var int: obj = sum(w in raid)(strength[w]);
solve maximize obj;

% output the result
output ["raid = \(raid)\n"] ++ ["obj = \(obj)\n"];