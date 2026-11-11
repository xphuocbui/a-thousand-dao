# Session transcript: unkillable-try1

> Final message of one headless `claude -p` session.

I've designed the build as **The Thousand-Year Banyan (Thiên Niên Dung Thụ)**, a Water–Wood tank built for the top end from Kết Đan to Hóa Thần. The sheet, the player guide and all the shared-file rows are written. Nothing was simulated: under your 2026-11-11 decision, the fight check and the identity test are marked NOT ASSESSED. The key numbers below are worked from the GDD formulas, and every number on a new piece is a first guess.

**One mismatch with the seed.** `regen_cap` no longer exists; the #44 economy revision removed it. Linh lực regeneration now has a log curve that never stops, and health regeneration has no cap at all. I read "regeneration at regen_cap" as "push regeneration until more stops paying". For health, that point is a full bar, so the build's key new piece spends whatever the full bar cannot hold.

**How it wins**
- **Surplus Life (Dư Sinh)**, the new enabler: healing lost to a full health bar lays Poison on the enemy, 1 stack for 10 s per 1 % of maximum health, at most 30 a pulse. Poison never misses or crits, which gives you "damage low but certain".
- **Its price, Rooted (Bám Rễ):** evade is fixed at 0 and the build can never slot an escape art.
- **When unpressed** it kills a typical Hóa Thần foe in about 25 s. **When pressed** the overheal drops to zero, it stops attacking and simply holds.
- **The 60 s backstop:** fatigue takes the same flat amount from both sides and nothing changes it. With a bar of about 48,200 and about 10.9 % regeneration a pulse, it falls at about 72 s, against 66 s for a typical side. No rule change is needed for this.

**The enemy built to break it: the Salt-Sower (Tát Diêm Giả).** It uses only existing pieces: Withering, Stagnation, Clear Heart Ward to wash the Poison away, high Chaos resistance, and a steady hitter that keeps the bar just under full. Against it the banyan's best result is even.

**What I added to the shared files**
- **Staging catalogue:** 14 new rows. These include Surplus Life, Growth Rings (regeneration that grows with the cultivator's age), the Thousand-Root Spring Scripture technique and its arts, the Banyan-Bark Mantle, the health-overflow readable, the Heartwood cluster and the Salt-Sower.
- **Reused:** I added my slug to Spring Sap, Quiet Channels and the Thực affix. I copied Sap Rises, The Spring Never Fails and Hot Spring Array from the by-root catalogue. Rot Deepens and Corpse-Wax Coating come from the content ledger.
- **Suggestions:** two.
  - Make health overflow a readable (effects.md rule 5); the build depends on it.
  - State whether stacks granted by an Effect roll a status chance (effects.md rule 6 against combat.md Formulas F). The build assumes they don't.
- **Ledger:** rows added in every section.

**Checks:** 8 PASS, 0 FAIL, 2 NOT ASSESSED (the fight and the identity test, because there was no simulator this run).

One thing outside this build: the skill's `combat-model.md` still lists `regen_cap`, `dot_pool_cap` and `dot_pulse_cap` as live limits, so later runs will meet the same wording.

Files are in `design/builds/overnight-2026-11-10/`:
- `builds/unkillable.sheet.md`
- `builds/unkillable.md`
- `staging-catalogue.md`
- `suggestions.md`
- `ledger.md`

BUILD-RESULT: slug=unkillable status=DONE staged_new=14 staged_reused=6 suggestions=2 checks_fail=0 checks_na=2
