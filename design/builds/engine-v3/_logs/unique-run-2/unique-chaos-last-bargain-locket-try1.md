# Job transcript: unique-chaos-last-bargain-locket (try 1)

I built and fought the Shadow Bargain (Ám Ảnh Tuyệt Khế), but the locket does not make this build.

It is a Core Formation Wood 60 / Metal 40 health-payer. It runs Verdant Cycle (main), Tearing Force Rites and Rotting Canopy as techniques, and five arts led by Bloodletting Rite. Thần thức is 50 against a limit of 53.1.

I wrote the fight file and the guide at the paths you named. I added the unmodelled lines to the fight file after the matrix and `--without` runs, so those runs used the file with an empty unmodelled list.

- **Fights:** it wins the same-realm fight 20-0 in 19.9 s. It loses 0-20 to every higher-realm and top-end matchup, in 1 to 10 s.
- **`--without` the locket's modifiers:** 20.3 s, so they are worth about 0.4 s.
- **`--without eff:Final Clause`:** no change. The build ends the same-realm fight at 100 % health, so the Down step is never reached. In the lost fights the clause would fire at the end of a fight already decided.
- **`--without tech:verdant-cycle-scripture`:** 20.4 s.
- **Fight length:** all of these are below the 30-60 s band.
- **Never fired:** every art shows NEVER_FIRED against Deity Transformation +2 and top end, because the build dies before its first cast.
- **Clipped:** Poison and Stagnation stacks are clipped by the caps, and the trigger budget clipped 2.5 times a fight.
- **Unmodelled:** the health, regeneration and status-resistance modifiers have no engine stat, and neither does Darkness. The locket's 26 % attack is tagged `am` and most likely adds nothing.
- **Final Clause is unproved:** I wrote it as a `down` event firing Bloodletting Rite, but no fight reached Down. I could not confirm the engine fires that event without `refuse_down`.

I treated the locket as the build's necklace and put a second necklace in an extra slot.

UNIQUE-DONE unique-chaos-last-bargain-locket

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/builds/unique-chaos-last-bargain-locket.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/builds/unique-chaos-last-bargain-locket.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/unique-chaos-last-bargain-locket.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/unique-chaos-last-bargain-locket.md) instead (Edit rules cover all file-editing tools).
```
