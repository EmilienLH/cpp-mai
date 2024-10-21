include "globals.mzn";

% Court Data
int: n; % number of court members
set of int: COURT = 1..n;
int: emperor = 1;
array[COURT] of int: rank;
array[COURT] of int: ability;

% Horse Data
int: m; % number of horses
set of int: HORSE = 1..m;
array[HORSE] of int: beauty;
array[HORSE] of int: speed;

array[COURT, HORSE] of int: enjoy;
int: max_riding = min(m, n); % number of court members that can ride

array[COURT] of var 0..m: horse;  % Horse assigned to each court member (0 if not assigned)
array[HORSE] of var 0..n: court;  % Court member assigned to each horse (0 if not assigned)

% contraint 1: The emperor must enjoy the day more than anyone else
constraint forall(i in COURT where i != emperor)(
  horse[i] > 0 -> enjoy[i, horse[i]] < enjoy[emperor, horse[emperor]]
);

% contraint 2: All court members must ride unless there is no horse left available
constraint sum([horse[x] > 0 | x in COURT]) = max_riding;

% contraint 3: if a court member holds a higher rank than another then :
constraint forall(i, j in COURT where rank[i] > rank[j])( 
    (beauty[horse[i]] >= beauty[horse[j]]) \/ %(a) the beauty of their horse can be no less than that assigned to the other
     horse[j] = 0 \/                          %(b) the lower rank member does not ride, or
    (horse[i] = 0 /\ horse[j] = 0));          %(c) both court members do not ride.

% contraint 4: court members must ride horses according to their ability
% this is not actually a constraint, but a value we calculate and use in the objective function
var int: violation_cost;
violation_cost = sum(i, j in HORSE where speed[i] > speed[j])
  (bool2int(not(
    ability[court[i]] >= ability[court[j]]  \/  % (a) the rider of the faster horse has no less riding
                                                %     ability than that of the slower horse
    court[i] = 0 \/                             % (b) the faster horse has no rider
    (court[i] = 0 /\ court[j] = 0)              % (c) both horses have no rider
  ))) * 100;                                    % penalty for each violation is 100


% Contraint not defined in the instructions but needed to make the model work properly

% contraint 5: inverse constraints to ensure that horse and court are consistent
% inverse didn't work as court and horse are not the same size in this model so we need to use a constraint
constraint forall(c in COURT, h in HORSE)(horse[c] = h <-> court[h] = c);

% Constraint 6: Compatibility constraint, make sure that the court member enjoys the horse
constraint forall(c in COURT, h in HORSE)(
  horse[c] = h -> enjoy[c, h] >= 0
);

% Constraint 7 : All-Different constraint, make sure that each horse is assigned to at most one court member
constraint alldifferent_except_0(horse);


% Objective: Maximize total enjoyment minus penalties for violations
var int: obj;
constraint obj = sum(i in COURT where horse[i] > 0)(enjoy[i, horse[i]]) - violation_cost;

solve maximize obj;

output [
  "horse = ", show(horse), ";\n",
  "obj = ", show(obj), ";\n"
];