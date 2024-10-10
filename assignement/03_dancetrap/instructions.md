# Beauty Trap: Part 2
## Basic Modeling for Discrete Optimization: Assignment 3

## Problem Statement

Wang Yun plots to help defeat Dong Zhou. He sets out to have both Dong Zhou and his best fighter Lü Bu fall for his foster daughter Diao Chan. Diao Chan is a remarkable beauty. When Lü Bu is invited to Wang Yun's house she performs a dance of seduction in order to trap him into love. This is the dance trap part of the "beauty trap".

### Dance Planning

Diao Chan must plan the most seductive dance possible. During each phase of the dance she must choose:
- What her legs are doing
- What her arms are doing 
- What her face is doing

There are constraints on sequences of possible actions for legs, arms and face.

Since Lü Bu is easily bored:
- She must choose the optimal length of the dance
- The longer it is, the more interesting it has to be
- There are upper limits on how many times she can use the same move

### Move Constraints

#### Leg Moves
Available moves: spin, leap, waltz, curtsey, prep(are) for a leap, and stand

Constraints:
- Must prep before any leap
- After a spin, can only:
  - Curtsey
  - Prep
  - Stand
- After a leap, can only:
  - Spin
  - Waltz
  - Stand
- Can waltz at most three times in a row
- Cannot prep directly after a curtsey
- Between any waltz and a following curtsey there must be a stand

#### Arm Moves
Available moves: beckon, hands out, hands up, hands wrapped around her body, and neutral

Constraints:
- Can beckon only directly after out or up
- Can wrapped only directly after beckon or neutral
- Cannot do any of the same moves in a row except neutral

#### Facial Gestures
Available moves: smile, wink, batt(ing) her eyelids, think(ing), glow with beauty, or blank

Constraints:
- Cannot make more than two of the same gestures in a row except blank
- Cannot think directly after smile(ing) or batt(ing) her eyelids

### Scoring

- The combination of legs move and arms move determines the value of her dance
- The combination of arms move and facial gesture determines the enticement
- Some combinations are impossible or must be avoided
- After the dance ends, she must stay in the base position: stand, neutral, and blank

### Objective

Maximize the seductive power of the dance, calculated as:
```
Seductive Power = Dance Value + Enticements - (Boredom Level × Dance Length)
```

## Data Format Specification

Input files are named `data/dancetrap_*.dzn` and contain:

- `maxlen`: maximum length of the dance
- `boredom`: boredom value of Lü Bu
- `dance_value`: 2D array mapping leg move + arm move to dance value (negative for disallowed)
- `entice_value`: 2D array mapping arm move + facial gesture to enticement value (negative for disallowed)
- `maxlegs`: array for maximum usage of each leg move
- `maxarms`: array for maximum usage of each arm move
- `maxface`: array for maximum usage of each facial gesture

### Guarantees
- Dance value of stand + neutral = 0
- Enticement value of neutral + blank = 0
- Maximum usages of stand, neutral, and blank ≥ maxlen

## Technical Requirements

- Use MiniZinc Bundle version 2.8.2
- Model should contain variable declarations for:
  - len
  - legs
  - arms
  - face
- Must calculate correct objective value
- ::output_only variable declarations allowed

## Example

### Sample Data
```minizinc
maxlen = 10;
boredom = 8;
dance_value = [| -1, 5, 3, 2, 2
              | 2, 4, 2, -1, 1
              | 4, 4, 0, -1, 2
              | 5, 1, -1, 2, 2
              | 0, 0, 0, 0, 0
              | 2, 1, 1, 2, 0 |];
entice_value = [| 4, 6, 5, -1, 3, -1
               | 3, 2, 3, 3, 1, 1
               | 2, 4, 5, 4, -1, 0
               | 5, 3, 2, 5, 6, 0
               | 4, 2, 1, 4, -1, 0 |];
maxlegs = [3, 3, 6, 2, 4, 20];
maxarms = [3, 3, 3, 3, 20];
maxface = [5, 2, 2, 7, 3, 20];
```

### Sample Solution
```minizinc
len = 9;
legs = [stand, stand, spin, curtsey, spin, curtsey, waltz, waltz, spin, stand];
arms = [wrapped, up, out, beckon, out, beckon, out, beckon, wrapped, neutral];
face = [glow, batt, smile, batt, smile, wink, smile, wink, glow, blank];
objective = 4;
```
