# Job transcript: dao-fix-15-26 (try 1)

All twelve drafts (15-kim through 26-am) now cite a rule where a decision covers the label. I only edited those drafts and wrote `design/dao-ways/reviews/fix-15-26.md`. I didn't run any check on the edits.

No new review rows needed fixing: the batch 15–26 rows were already fixed in-session (see `TRIAGE.md`). This pass was step 2 only.

**Changes beyond swapping a label for a citation:**
- **Phong:** two capstones were both cap shifts, which breaks the one-per-Way rule. Never in One Place now turns evade above `evade_cap` into +2 block rating per pp. The Wind Has No Floor keeps the `cooldown_min` shift.
- **Băng:** Frozen Clock and The World Stops were foe slows or freezes. They are now bounded `delay_timer` effects (0.4 s / 0.8 s per pulse; 2 s once per 15 s) with falloff and `timer_resist_pct`.
- **Quang:** Halo's Soul stop was 40 % and The Sun Within went to 80 %, both over the caps. Halo is now Chaos 40 % / Soul 20 %, and The Sun Within is 50 % / 30 %.
- **Vụ:** Fogged is now 5 pulses (curse clamp, R22) instead of 6.
- **Ám:** Step into Shadow's untargetable window is now bounded by the avoid budget (2 hits per pulse); ticks still tick.
- **Lôi:** Thunder God's Body now gives `basic_speed_pct` equal to lightning art speed, rather than making the basic attack count as an art.
- **Hỏa:** Burning Heaven is now a per-pulse check, not a new event.

**Deferred:**
- Thủy's Bottomless overdraw stays labelled `(deferred, R12)`.

**Left as they were (no decision covers them):**
- Block and evade against ticks (Thổ, Phong).
- Hit splitting (Phong, Ngọc).
- Kim's Living Arsenal slot above `equip.max_slots`.
- Mộc's Spreading Growth.
- Băng's Eternal Glacier.
- Ngọc's skill-points and `jade` tag pieces.
- Quang's Exposed stacking.
- Lôi's Overcharge crit readable and self-hit.
- The new curses: Weighed, Blinded, Veiled and Drowned.

I did not touch Băng's Absolute Zero or Cold Toll.

FIX-DONE design/dao-ways/reviews/fix-15-26.md

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/dao-ways/reviews/fix-15-26.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/dao-ways/reviews/fix-15-26.md) instead (Edit rules cover all file-editing tools).
```
