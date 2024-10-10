% Beauty Trap
% Perform the most seductive dance

enum LEGS = {spin, leap, waltz, curtsey, prep, stand};
enum ARMS = {beckon, out, up, wrapped, neutral};
enum FACE = {smile, wink, batt, think, glow, blank};

int: maxlen;
set of int: STEP = 1..maxlen;
array[LEGS] of int: maxlegs;
array[ARMS] of int: maxarms;
array[FACE] of int: maxface;
constraint assert(maxlegs[stand] >= maxlen, "maxlegs[stand] smaller than maxlen");
constraint assert(maxarms[neutral] >= maxlen, "maxarms[neutral] smaller than maxlen");
constraint assert(maxface[blank] >= maxlen, "maxface[blank] smaller than maxlen");
array[LEGS,ARMS] of int: dance_value;
array[ARMS,FACE] of int: entice_value;
constraint assert(dance_value[stand,neutral] = 0, "incorrect dance_value array");
constraint assert(entice_value[neutral,blank] = 0, "incorrect entice_value array");
int: boredom; % how bored each step makes the viewer

var STEP: len;
array[STEP] of var LEGS: legs;
array[STEP] of var ARMS: arms;
array[STEP] of var FACE: face;

% Additional constraints

% 1. Base position at the end
constraint forall(i in len+1..maxlen) (
  legs[i] = stand /\
  arms[i] = neutral /\
  face[i] = blank
);

% 2. Maximum usage constraints
constraint forall(l in LEGS) (
  count(legs, l) <= maxlegs[l]
);
constraint forall(a in ARMS) (
  count(arms, a) <= maxarms[a]
);
constraint forall(f in FACE) (
  count(face, f) <= maxface[f]
);

% 3. Leg move constraints
% Must prep before leap
constraint forall(i in 2..maxlen) (
  legs[i] = leap -> legs[i-1] = prep
);

% After spin constraints
constraint forall(i in 1..maxlen-1) (
  legs[i] = spin -> 
    (legs[i+1] = curtsey \/ legs[i+1] = prep \/ legs[i+1] = stand)
);

% After leap constraints
constraint forall(i in 1..maxlen-1) (
  legs[i] = leap -> 
    (legs[i+1] = spin \/ legs[i+1] = waltz \/ legs[i+1] = stand)
);

% Waltz at most three times in a row
constraint forall(i in 1..maxlen-3) (
  not (legs[i] = waltz /\ legs[i+1] = waltz /\ 
       legs[i+2] = waltz /\ legs[i+3] = waltz)
);

% Cannot prep directly after curtsey
constraint forall(i in 1..maxlen-1) (
  legs[i] = curtsey -> legs[i+1] != prep
);

% Stand between waltz and curtsey
constraint forall(i in 1..maxlen-2) (
  (legs[i] = waltz /\ legs[i+1] != stand /\ legs[i+2] = curtsey) -> false
);

% 4. Arm move constraints
% Beckon only after out or up
constraint forall(i in 2..maxlen) (
  arms[i] = beckon -> (arms[i-1] = out \/ arms[i-1] = up)
);

% Wrapped only after beckon or neutral
constraint forall(i in 2..maxlen) (
  arms[i] = wrapped -> (arms[i-1] = beckon \/ arms[i-1] = neutral)
);

% No same moves in row except neutral
constraint forall(i in 1..maxlen-1) (
  arms[i] != neutral -> arms[i] != arms[i+1]
);

% 5. Face gesture constraints
% No more than two same gestures in row except blank
constraint forall(i in 1..maxlen-2) (
  face[i] != blank -> 
    not (face[i] = face[i+1] /\ face[i] = face[i+2])
);

% Cannot think after smile or batting eyelids
constraint forall(i in 1..maxlen-1) (
  (face[i] = smile \/ face[i] = batt) -> face[i+1] != think
);

% 6. Objective calculation
array[STEP] of var int: step_dance_value = 
  [dance_value[legs[i], arms[i]] | i in STEP];
array[STEP] of var int: step_entice_value = 
  [entice_value[arms[i], face[i]] | i in STEP];

var int: total_dance_value = sum(i in 1..len) (step_dance_value[i]);
var int: total_entice_value = sum(i in 1..len) (step_entice_value[i]);
var int: total_boredom = boredom * len;

var int: objective = total_dance_value + total_entice_value - total_boredom;

% Ensure no negative dance or entice values (disallowed combinations)
constraint forall(i in 1..len) (
  step_dance_value[i] >= 0 /\ step_entice_value[i] >= 0
);

solve maximize objective;

% Output
output ["len = \(len);\n"] ++
       ["legs = \(legs);\n"] ++
       ["arms = \(arms);\n"] ++
       ["face = \(face);\n"] ++
       ["objective = \(objective);\n"];