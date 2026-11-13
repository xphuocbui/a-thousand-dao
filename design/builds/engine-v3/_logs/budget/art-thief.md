# Budget report: art-thief (Hollow Thief, Hư Thủ Thâu Pháp), Nguyên Anh (nguyen_anh)

**Claimed share of the layer gap:** 84 % before -> 22 % after (budget 23 %). `fight.py` prints `layer_budget`.

**Layers [L1..L5]:** `[400, 200, 240, 150, 0]` -> `[370, 40, 40, 20, 0]`. L2-L4 are now the typical enemy's values (claim nothing); L1 trimmed 30 (400 alone gave 26 %, 350 gave 20 %); L5 was already 0. Reason: techniques' passives and items' modifiers already run as Effects, so those layers double-counted them; L1 carries the echo-palm concept, so it was cut least.

**Fights (mean s, wins-losses-other, 20 each, same engine):**

| Matchup | Before | After |
|---|---|---|
| typical nguyen_anh+0 | 1.9 s, 20-0-0 | 6.0 s, 20-0-0 |
| typical hoa_than+1 | 3.6 s, 20-0-0 | 20.2 s, 20-0-0 |
| top_end nguyen_anh+0 | 5.2 s, 20-0-0 | 37.9 s, 9-10-1 |
| top_end hoa_than+1 | 8.7 s, 3-17-0 | 5.9 s, 0-20-0 |

`--without eff:Echo` and `--without item:force-chaos-shock-zither` were rerun: Echo shifts times by about 0.2-3.5 s, the zither's modifiers change nothing.

**Pieces removed:** none. Techniques, items and arts are unchanged. The typical Nguyên Anh fight (6.0 s) is under the 10-20 s target because the ward and Effects are strong; I did not tune them (out of scope).

**What the build now lacks to stay strong** (from the guide's catalogue gaps):
- An art or ring that copies the foe's last art (the theft identity is unmodelled).
- An Echo that stacks, or a stronger Echo; Echo now adds little.
- A force-scoped `attack_pct` necklace or ring (force-chaos family).
- A palm-scoped treasure adding Drink or speed (body family), so Marrow-Siphon Palm and Hollowing Strike fire more.
- Armour with a ward above the build's own payload 342.5 plus linh lực regeneration.
- It loses every fight against the Hóa Thần top-end foe and is even against the top-end Nguyên Anh foe; it needs these pieces rather than layers to close that.
