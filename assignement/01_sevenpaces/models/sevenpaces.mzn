var 0..9: S;
var 0..9: E;
var 0..9: V;
var 0..9: N;
var 0..9: P;
var 0..9: A;
var 0..9: C;
var 0..9: R;

include "alldifferent.mzn";

% Making sure every variable is a different digit
constraint alldifferent([S, E, V, N, P, A, C, R]);

% Contraint of the cryptarithmetic problem for SEVEN + PACES = VERSE
constraint 10000*S+1000*E+100*V+10*E+N
           +10000*P+1000*A+100*C+10*E+S
           =10000*V+1000*E+100*R+10*S+E;

% Instead of satisfy, we use maximize to get the maximum value of the sum
solve maximize 10000*V+1000*E+100*R+10*S+E;

% Output the result
output ["   \(S) \(E) \(V) \(E) \(N)\n "
        ++ "+ \(P) \(A) \(C) \(E) \(S)\n "
        ++ "------------------\n "
        ++ "= \(V) \(E) \(R) \(S) \(E)\n"
        ++ "sum = \(10000*V+1000*E+100*R+10*S+E)\n"];