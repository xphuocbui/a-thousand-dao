# Budget report: beast-carry (Raising the Tiger, Dưỡng Hổ), Nguyên Anh (nguyen_anh)

**Claimed share of the layer gap:** 94 % before -> 18 % after (budget 23 %). `fight.py` prints `layer_budget`.

**Layers [L1..L5]:** `[332, 300, 250, 110, 89]` -> `[332, 40, 40, 20, 0]`. L2-L4 are now the typical enemy's values; L5 (89) went to 0, cut first because it only stood in for the unmodelled Straining Leash; L1 kept whole as the beast's bite is the concept. Reason: passives and item modifiers already run as Effects, so the old layers double-counted them.

**Fights (mean s, wins-losses-other, 20 each, `--matrix`):**

| Matchup | Before | After |
|---|---|---|
| typical nguyen_anh+0 | 1.5 s, 20-0-0 | 18.5 s, 20-0-0 |
| typical hoa_than+1 | 4.3 s, 20-0-0 | 16.0 s, 0-20-0 |
| top_end nguyen_anh+0 | 2.0 s, 0-20-0 | 2.0 s, 0-20-0 |
| top_end hoa_than+1 | 1.0 s, 0-20-0 | 1.0 s, 0-20-0 |

**Pieces removed:** none. Techniques, items and arts are unchanged. I stopped at 18 % rather than spending the last 5 % because the typical fight is already in the 10-20 s target.

**What the build now lacks to stay strong:**
- A companion weapon or collar: companion damage, speed and a companion hit filter (Sure Bite, Marked Prey).
- A beast-share modifier (Straining Leash fed by gear), now that L5 is gone.
- A beast ward / Down-prevention item for the tiger's health bar.
- An item Effect feeding the 0.5 s companion timer from art speed (Bonded Spirit).
- A Fire-stack utility item for the empty extra slots.
- Defence against Hóa Thần and top-end foes: the realm default body and ward lose in 1-2 s, and the item shields are unmodelled.
