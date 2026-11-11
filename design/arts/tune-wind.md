# Wind tuning (suite_check)

## Before

```
suite_check	wind	suite gale-courier-scripture	truc_co	mean 9.5 s, typical mirror 25.6 s, x0.37 (FAST)	W-L 20-0
suite_check	wind	suite gale-courier-scripture	ket_dan	mean 9.5 s, typical mirror 20.0 s, x0.47 (FAST)	W-L 20-0
suite_check	wind	suite slow-hour-scripture	truc_co	mean 13.7 s, typical mirror 25.6 s, x0.54 (FAST)	W-L 20-0
suite_check	wind	suite slow-hour-scripture	ket_dan	mean 11.8 s, typical mirror 20.0 s, x0.59 (FAST)	W-L 20-0
```
(held-breath NEVER_ENGAGED in both courier rows; Echo empower 3.6 / 2.9 per fight.)

## After

```
suite_check	wind	suite gale-courier-scripture	truc_co	mean 18.0 s, typical mirror 25.6 s, x0.70 (near typical)	W-L 20-0
suite_check	wind	suite gale-courier-scripture	ket_dan	mean 14.1 s, typical mirror 20.0 s, x0.71 (near typical)	W-L 20-0
suite_check	wind	suite slow-hour-scripture	truc_co	mean 21.1 s, typical mirror 25.6 s, x0.82 (near typical)	W-L 20-0
suite_check	wind	suite slow-hour-scripture	ket_dan	mean 18.2 s, typical mirror 20.0 s, x0.91 (near typical)	W-L 20-0
```
Engagement after: Flurry step 1 1.0 / step 2 0.7-0.8 per fight; Held Breath empower 0.2 per fight at Trúc Cơ and Kết Đan (before the Wind-stack route was added it was NEVER_ENGAGED at Kết Đan); Echo empower 0.2; Reckless step 1 1.0-1.3, step 2 0.1-0.4; Trailing step 1 1.1-1.4. Lint 0 findings.
Not reached: Trailing step 3 (rare, as intended).

## Changes

- Swallow Stance: basic speed +50 % -> +10 % (the stance was the cause of the courier suite being FAST; moving it alone took x0.39 to x0.72).
- Three-Step Chase: c_art 1.2 -> 0.8; Stride dash bonus 10 % -> 4 % per Stride.
- Hundred-Feather Flurry: c_art 1.6 -> 0.8, cooldown 5 -> 6; Feather hit 0.28 -> 0.1; step 1 c_mult 3 -> 2.
- Flurry step 2: gate is now 8 Feathers AND (Slowed foe OR Swallow OR 3 courier arts); c_mult 6 -> 3.5; its Wind burn now has `then` a 0.4 free hit `per` stack burned, so a bigger stock hits harder with no cap.
- Held Breath: c_art 1.2 -> 0.9; banked hit 0.35 -> 0.2.
- Held Breath: Breath count now resets only when Held Breath itself fires (it was reset by any art, so it never reached 6 - the cause of NEVER_ENGAGED).
- Held Breath empower: gate is now 2 Breath AND (Swallow OR Slowed foe OR 3 Wind stacks OR 3 courier arts in a pulse); c_mult 5 -> 3.5. Wind-stack route added as an easy feed.
- Echo of the Dodge: c_art 1.2 -> 1.0; empower gate now 3 Echoes AND (Slowed foe OR Swallow); c_mult 5 -> 3.5 (was fired 3.6 times a fight on a single OR-group).
- Reckless Gale: c_art 2.4 -> 1.8; step 1 c_mult 2.5 -> 2.
- Reckless Gale step 2: gate is now <=50 % health AND (foe <=30 % OR 6 Wind stacks) (was <=35 % OR foe <=30 % OR 6 stacks); c_mult 5.5 -> 3.5; Wind burn `then` a 0.3 hit `per` stack burned.
- Trailing Gale: c_art 1.6 -> 1.2; step 1 c_mult 2.5 -> 2.
- Trailing Gale step 3: gate is now 3 Slowed Time AND (5 Slowed Time OR 3 slow-hour arts in a pulse OR 3 Echoes); c_mult 5 -> 3.5.
- No dead routes found in Wind (Slowed Time is laid by Trailing Gale itself, so its routes can open). Rule texts in the json and the table in family-wind.md updated to match.
