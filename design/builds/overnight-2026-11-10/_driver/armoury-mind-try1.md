# Session transcript: armoury-mind-try1

> Final message of one headless `claude -p` session.

I've designed the armoury-mind build as **The Armoury Mind (Tàng Binh Thức)**: a top-end Metal (Kim) build for Nascent Soul (Nguyên Anh) to Deity Transformation (Hóa Thần). No checks failed. Two are NOT ASSESSED, the fight and the identity test, because there is no simulator this run (user decision 2026-11-11).

**What the rules showed.** Two things in the data set this build up:
- **L3 fills fast.** A top-grade (Cực phẩm) piece made for your own realm gives L3 points of 3 × its base attack ÷ stage: a Seal (Ấn) gives 120, a Needle (Châm) 66. The L3 cap is 250, so two or three pieces fill it and every piece after that adds nothing to L3.
- **Divine sense (thần thức) is the real limit.** The realm multiplier cancels out, so costs come down to base cost units: Seal 30, Shield (Thuẫn) 15, Needle 10, Armour (Giáp) 5. You pay them from soul strength (thần hồn) × stage × (1 + divine sense bonuses).

**Direction chosen: the Garrison Mind (Thủ Khố Tâm).** L3 is capped early, and every later piece has to earn its place on the rack in another way:
- **Weapon pieces strike.** Each one hits the enemy every pulse with no art slot and lays a Metal stack. Each stack makes the enemy take +1.8 % more Physical damage, and with four weapons that is about +51 %.
- **Ward pieces are walls.** They add ward strength and efficiency, which have no cap, and give back linh lực each pulse.
- **The count is its own bonus.** Every piece past the third adds +10 to the L5 layer, up to +50.
- **The wasted L3 becomes reach.** L3 points past the cap turn into Physical penetration.
- **The price is your soul.** Against soul hits, only your free divine sense and half of what your pieces hold defend you. The founder of the lineage died to a soul needle.

**What the budget forces out:**
- At Nascent Soul, divine sense is the limit: cheap Needles, Shields and Armour crowd out a second Seal.
- At Deity Transformation, slots are the limit: old Nascent Soul Needles cost 3 units each and go back on the rack as strikers.
- Always forced out: Open Sky (no divine sense is left free), every other trigger Effect (the strikes use all 6 trigger firings a pulse), and artifacts' own arts (they would take art slots).

**The numbers, from the formulas only (not a fight test):**

| Realm | Multiplier from the layers | With the Metal stacks | Game's top-end reference |
|---|---|---|---|
| Nascent Soul | about ×180 | about ×271 | ×256 |
| Deity Transformation | about ×241 | about ×396 | ×325 |

The build sits above the Deity Transformation reference; I noted that and did not pull it back. Without the Garrison Mind, Nascent Soul falls to about ×180. Its counter is a soul-piercer. The answers are the Soul-Guarding Lamp, soul resistance lines, a soul-cleanse art, or taking a piece off the rack before a foreseen fight.

**Directions I did not pick:**
- **The Treasure Breaker:** treasures burst one by one as huge hits. It is an all-in burst build, which the project wants rare, and it destroys the player's gear every fight.
- **The Hollow Rack:** one piece and free divine sense. It is the opposite of what you asked for, and that keystone already exists.

**What changed in the shared files:**
- **Staging catalogue:** 20 new rows, including the enabler, four Effects, three modifiers, a Heaven-grade (Thiên giai) technique with six arts, a named rack and a Way facet. I added this build to the "Used by" cell of 8 existing rows.
- **Run ledger:** rows added in every section.
- **Suggestions:** three entries. Effects should be able to read the pieces you control. The soul close needs a rule change in Combat rule 3 and Formulas E2. And the game's top-end gear reference needs about six top-grade pieces and around 120 units of divine sense (a typical cultivator has about 45), which only an all-gear build reaches.

Files are in `design/builds/overnight-2026-11-10/builds/`:
- `armoury-mind.sheet.md`
- `armoury-mind.md`

BUILD-RESULT: slug=armoury-mind status=DONE staged_new=20 staged_reused=8 suggestions=3 checks_fail=0 checks_na=2
