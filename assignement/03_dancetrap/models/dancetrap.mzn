% Beauty Trap
% Perform the most seductive dance using regular constraints

include "regular.mzn";

% Enums for different types of moves
enum LEGS = {spin, leap, waltz, curtsey, prep, stand};
enum ARMS = {beckon, out, up, wrapped, neutral};
enum FACE = {smile, wink, batt, think, glow, blank};

% Input parameters
int: maxlen;                    % Maximum length of the dance
set of int: STEP = 1..maxlen;   % Set of possible steps
array[LEGS] of int: maxlegs;    % Maximum times each leg move can be used
array[ARMS] of int: maxarms;    % Maximum times each arm move can be used
array[FACE] of int: maxface;    % Maximum times each facial expression can be used
int: boredom;                   % Boredom factor per step

% Value matrices for scoring
array[LEGS,ARMS] of int: dance_value;     % Value of leg+arm combinations
array[ARMS,FACE] of int: entice_value;    % Value of arm+face combinations

% Assertions to ensure valid input data
constraint assert(maxlegs[stand] >= maxlen, "maxlegs[stand] smaller than maxlen");
constraint assert(maxarms[neutral] >= maxlen, "maxarms[neutral] smaller than maxlen");
constraint assert(maxface[blank] >= maxlen, "maxface[blank] smaller than maxlen");
constraint assert(dance_value[stand,neutral] = 0, "incorrect dance_value array");
constraint assert(entice_value[neutral,blank] = 0, "incorrect entice_value array");

% Decision variables
var STEP: len;                  % Length of the dance
array[STEP] of var LEGS: legs;  % Sequence of leg moves
array[STEP] of var ARMS: arms;  % Sequence of arm moves
array[STEP] of var FACE: face;  % Sequence of facial expressions

% LEGS CONSTRAINTS
% Transition matrix for leg moves
% Rows: current state, Columns: possible next moves
% States: 1=start, 2=spin, 3=leap, 4=waltz, 5=curtsey, 6=prep, 7=stand
array[1..7, LEGS] of 0..7: transi_legs =
     [|2,0,4,5,6,7  % 1 start - can go to spin, waltz, curtsey, prep, or stand
      |0,0,0,5,6,7  % 2 after spin - can only go to spin, curtsey, prep, or stand
      |2,0,4,0,0,7  % 3 after leap - can only go to spin, waltz, or stand
      |2,0,4,0,6,7  % 4 after waltz - can go to spin, waltz, prep, or stand
      |2,0,4,5,0,7  % 5 after curtsey - can go to spin, waltz, curtsey, or stand (not prep)
      |2,3,4,5,6,7  % 6 after prep - can go to any move
      |2,0,4,5,6,7|];% 7 after stand - can go to any move except leap

% Regular constraint for leg moves sequence
constraint regular(legs, 7, 6, transi_legs, 1, {2,3,4,5,6,7});
% legs : sequence of leg moves (what we are trying to find)
% 7 : number of states (6 move + initial state)
% 6 : number of possible moves
% transi_legs : transition matrix for the leg moves (from this move you can go to these moves)
% 1 : initial state (start of the sequence of moves)
% {2,3,4,5,6,7} : accepting states (states where the sequence can end without issue)

% Additional leg constraints
% Maximum usage for each leg move
constraint forall(i in LEGS)(
  sum(j in 1..maxlen)(legs[j] = LEGS[i]) <= maxlegs[i]
);

% No more than three waltzes in a row
constraint forall(i in 1..maxlen-3)(legs[i] = waltz /\ legs[i+1] = waltz /\ legs[i+2] = waltz -> legs[i+3] != waltz);

% Must have stand between waltz and curtsey
constraint forall(i in 1..maxlen-1)
                 ((LEGS[legs[i]] = waltz ->
                 forall(j in i+1..len)
                       (LEGS[legs[j]] = curtsey ->
                        exists(k in i+1..j-1)(LEGS[legs[k]] = stand))));

% After dance ends, remain in stand position
constraint forall(i in len+1..maxlen)(legs[i] = stand);

% ARMS CONSTRAINTS
% Transition matrix for arm moves
% States: 1=start, 2=beckon, 3=out, 4=up, 5=wrapped, 6=neutral
array[1..6, ARMS] of 0..6: transi_arms =
     [|0,3,4,5,6  % 1 start
      |0,3,4,5,0  % 2 after beckon
      |2,0,4,0,6  % 3 after out - can beckon
      |2,3,0,0,6  % 4 after up - can beckon
      |0,3,4,0,6  % 5 after wrapped
      |0,3,4,5,6|];% 6 after neutral

% Regular constraint for arm moves sequence
constraint regular(arms, 6, 5, transi_arms, 1, {2,3,4,5,6});
% Additional arm constraints
constraint forall(i in ARMS)(
  sum(j in 1..maxlen)(arms[j] = ARMS[i]) <= maxarms[i]
);

% After dance ends, remain in neutral position
constraint forall(i in len+1..maxlen)(arms[i] = neutral);

% FACIAL CONSTRAINTS
% Transition matrix for facial expressions
% States: 1=start, 2=smile, 3=wink, 4=batt, 5=think, 6=glow, 7=blank
array[1..7, FACE] of 0..7: transi_face =
[| 2, 3, 4, 5, 6, 7      % 1 Start
 | 0, 3, 4, 0, 6, 7      % 2 After smile - can't think
 | 2, 0, 4, 5, 6, 7      % 3 After wink
 | 2, 3, 0, 0, 6, 7      % 4 After batt - can't think
 | 2, 3, 4, 0, 6, 7      % 5 After think
 | 2, 3, 4, 5, 0, 7      % 6 After glow
 | 2, 3, 4, 5, 6, 7 |];  % 7 After blank

% Regular constraint for facial expressions sequence
constraint regular(face, 7, 6, transi_face, 1, {2,3,4,5,6,7});

% Additional facial constraints
constraint forall(i in FACE)(
  sum(j in 1..maxlen)(face[j] = FACE[i]) <= maxface[i]
);

% After dance ends, remain with blank expression
constraint forall(i in len+1..maxlen)(face[i] = blank);

% Make sure we don't have invalid dance moves (added after first submission to try and improve the score) - not sure if useful
constraint forall(i in 1..len)(
  dance_value[legs[i], arms[i]] >= 0 /\
  entice_value[arms[i], face[i]] >= 0
);

% OBJECTIVE
var int: obj; 
% Sum up dance values and entice values for each step, subtract boredom
constraint obj = sum(i in 1..len)(
  dance_value[legs[i], arms[i]] + entice_value[arms[i], face[i]]
) - boredom * len; 
solve maximize obj;

output ["len = ", show(len), ";\n" ++
        "legs = ", show(legs), ";\n" ++
        "arms = ", show(arms), ";\n" ++
        "face = ", show(face), ";\n" ++
        "obj = ", show(obj),";"];