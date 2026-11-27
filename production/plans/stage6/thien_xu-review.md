# Thiên Xu Tông: Stage 6 record pass review (2026-11-27, headless job, decisions auto-accepted)

## Summary

**Built (all staged in `design/stage6-staging/thien_xu/`; nothing exported, nothing outside the brief's paths):**
- **6 techniques** (`techniques/catalogue-sect-thien_xu.json`): the 5 lineage methods (weighing-stone-primer,
  dipper-handle-canon, heavenly-pivot-true-canon, boundary-stele-array-canon, army-breaker-spear), plus a new servants'
  method, `water-clock-breath`, for the Water and Wood stand-ins. Every bonus and passive is new and mine (§C).
- **9 new arts** (`arts/part-sect-thien_xu.json`). The 8 depth arts are counterweight-palm, the-handle-points-east (it
  carries d9), the-pivot-does-not-turn, weigh-the-heart, north-star-writ, plant-the-stele, no-crossing-the-line and
  the-seventh-star-falls (it carries d21). The ninth is clock-breath, for the new method. The tenth depth art, The Pole
  Draws from the Vein (d8), is a passive art: an Effect on the Pivot canon from layer 4, not an art record.
- **22 Effects** (`effects/thien_xu.effects.json`): 11 item, 10 set and 1 passive art.
  - 19 run in the engine.
  - 2 are `not_run` with reasons: True Gold Shows is out of fight; The Banner Is Raised has no holder and no Darkness
    element.
  - 3 carry a `pending` part: The Pole Draws, Sentence Stands and A Fair Copy.
- **30 items and 10 sets** (`items/`), with the depth modifiers as given, `sources: ["npc"]`, `unique: true` and the R6
  exception on the 18 weapons, armour and robes.
- **8 stand-ins** in the cast files: 5 Earth servants to the primer, 3 Water and Wood servants to water-clock-breath.
- **0 beasts**, since the owner has none. Art ids were written into `thien_xu.techniques.json`, and water-clock-breath
  was registered there.

**Checks:**
- lint_arts, lint_techniques and lint_items: 0 findings. The OVER_BUDGET lines are notes, since the files are unpriced.
- engine.validate passes every Effect record.
- `sect_fight.py thien_xu` and `--gap 1` were run, plus real-kit probes (§H). **Every art fires at the same realm.**

**Counts:**
- **Deviations: 41** (§D-§G, numbered).
- **Decisions taken for the user: 14** (§A).
- **Pending words: 4**:
  - technique-effects (a passive art's Effect, attached by the loader);
  - darkness-element;
  - curse-fast;
  - curse-reflect.
- **Early promotions: none**, and no `foreign/` files. The sect's methods are only referenced by loose-south's people,
  and Thiên Xu holds no other owner's unpromoted method (Đồ Vô Cữu's main is a library method; his
  `ls-white-wind-hook` is loose-south's to promote).

**Never ran on a real holder, each with its reason (§H):**
- Know the Way Out: no holder slots an escape art.
- True Gold Shows: out of fight.
- The Banner Is Raised: lost, and no Darkness element.
- Seal and Weight in One Hand and The Army That Waits: no real holder. Both ran on synthetic kits.
- Sentence Stands: an `always` record, so the probe counts no runs; it changes the fight very little.
- A Fair Copy: the typical foe casts no soul art.
- The Pole Draws: the loader gap. It was run through `tree_effects`.
- The Pivot's movement clause: no holder has a movement art.
- Hình Thủ Tinh and Thịnh Hàm Quang: `fight.py` refuses Light purity.

**Open items** (for the user or the serial step; §I):
- the four pending words;
- the `fight.py` Light purity gap;
- `export_named.py` skips the 4 `kind: treasure` items;
- there is no spear base;
- Mountain Stance and Mountain Root Stance overwrite each other;
- sect_fight's slotting;
- two weak kits;
- three out-of-fight halves (dialogue, world event, appraisal).

## A. Decisions auto-accepted (user rule 2026-11-26), with reasons

1. **A passive art is a technique Effect, not an art** (The Pole Draws, d8).
   - What it is: the Pivot canon's `effects` holds `{name, unlock_layer 4, passive_art}`, and the engine record is
     the library Effect of that name.
   - Why: a passive art takes no art slot and never fires. The only engine forms available were an art that never
     fires (which wastes a slot) or an Effect, and the Effect keeps the meaning.
   - The gap: the loader does not attach technique Effects yet (pending word **technique-effects**). It was tested by
     name through `tree_effects`; on Phương Trực Ngôn the fight went from 52.3 s and 43 % health left to 45.8 s and
     54 %.
2. **The Pole Draws unlocks at layer 4, not 7.** d8's note names six holders (the head, the judge, the archivist, the
   stele master, the treasurer and the junior judge). Four of them hold the canon at layers 4-6, so layer 7 would have
   left out most of the people the wish was written for.
3. **The Dipper Handle is paced, not rushed: one star a breath (d9 refined).**
   - The rule as built: a second Metal art within 1 s of the last star moves no star. A non-Metal damaging art still
     loses the count, and the count comes back after 3 s with no damaging or movement art.
   - Why: as written ("two damaging arts within 1 s lose count", "Composed for 3 s"), the sim's always-fire arts lost
     the count about 10 times a fight, and the handle pointed about 0.1 times a fight. Variants were measured (§H).
   - Result: pure-Metal holders now point once or twice a fight, and holders who mix in non-Metal arts still lose
     count, which is the canon's lesson.
4. **The Pivot's still stance is a self-state counter**, not a stance slot. The pivot holders also slot Mountain Stance,
   and one stance slot would overwrite it (lesson 2). The text's "stance" is the image; the engine reads "while you are
   Composed".
5. **"Weight" means an Earth debuff stack on the foe.** This is the Pivot canon's own definition. Weighed lays one,
   and Sentence Stands reads `foe.debuff.earth`.
6. **"Your ward" is your main ward**, the one every fighter holds while it has linh lực. Before the Sun, Seven Lamps
   and the Regalia's "half their value" are all `ward_pct` on it, so they work for a holder with no ward art (lesson 3).
   The Door Stays Shut grows the stance ward instead, which `ward_grow` creates when none exists.
7. **"Breaks the foe's ward" is Exposed.** It covers Seventh Star (full), The Called Thrust, Seal and Weight and Sealed
   Writ.
   - A new `break_ward` word was weighed and rejected: Exposed (−100 resistance, a curse slot, 3-4 s) keeps the
     intent, and lesson 4 says an existing word that keeps the intent wins.
   - "Ignores / pierces the ward" on a hit is `bypass 0.5`, the engine's cap, as Băng Tâm's Every Fifth a Star.
8. **"Strike nothing" or "wait" is the Composed clock** (`own.since_act`): no damaging or movement art. Companions,
   summons and the basic attack do not break it, which is d21's rule for companions. The basic attack is my addition
   (the clock ignores it).
9. **Signature items as R6**: the base's common art or ward, and `exception` on the weapons and body gear.
10. **Treasures keep `kind: treasure`** and get `rarity 5` (grade 4 + 1), which lint_items requires. The kind is the
    depth text's (legendary bảo vật). That `export_named.py` skips treasures is an open item for the export, not a
    reason to rewrite the kind.
11. **The tally gets base `phu`.** A tally is a phù, and this is the plan's "give the 2 items with no base a base". The
    spear stays on `phi_kiem`, as the depth note says.
12. **Stand-ins.**
    - The 5 Earth-rooted servants take the Weighing-Stone Primer. Its own text says a one-element root "must carry the
      other by effort, slow but not closed", and its lore is a method written for outsiders on a market scale.
    - The 3 Water and Wood servants take a new servants' method, Water-Clock Breathing, as Băng Tâm's
      warm-hearth-breath. The seat keeps time by water clock and Hà Khắc Thủy keeps it, so the method is his.
13. **Retunes after the holder check** (sizes only; every coefficient stays under the art lint):
    - Handle cut 2.3;
    - Weigh the Heart 3.0 and North Star Writ 1.4;
    - The Pivot +4 % per Weight;
    - the Dipper gets `damage_more 3 [kim]`;
    - the Pivot trades ward efficiency for linh lực regeneration +16 %.

    Why: before the retune, the Dipper's Trúc Cơ holders won 1 fight in 10 and the plain Kết Đan Pivot elders 0 in 10
    against a typical same-realm foe. Băng Tâm's Trúc Cơ holders win 6 of 6. Linh lực was the elders' bottleneck
    (sustain is king).
14. **Plant the Stele needs a fifth of your linh lực in hand.** The rising cost is paid by refund, which can drive linh
    lực below 0. The guard keeps the cost real ("each dearer than the last") without a cap on charges.

## B. The mechanic table (step 1: the engine has it / needs a word / needs a ruling)

| Record | Mechanic | Engine |
|---|---|---|
| Weighing-Stone Primer, Counterweight Palm | Earth and Metal stacks, last-art memory, timer delay, Slowed Time | has (`counter`, filters `element` / `not_art_id`, `timer next`) |
| Dipper Handle, The Handle Points East (d9) | star counter, lost count, Composed recovery, empowered double strike, Broken | has (`since_act`, `composed_time`, `empower`, `split`, event `broken`) |
| Heavenly Pivot, The Pivot Does Not Turn | Weights while Composed, Metal damage per Earth stack, Pressing ends it | has (`composed`, `scale`, `dmg_more` by element, movement tag); the stance slot is avoided by a counter |
| Weigh the Heart | damage per stack of every element, strip buffs, no crit | has (7 `scale` records, `strip`, `crit` −1000 scoped by tag) |
| North Star Writ | Named, companions deal more, Withering above half | has (`dmg_more` kind companion, `withering`) |
| The Pole Draws from the Vein (d8) | linh lực per 3 Weights while Composed | the record runs; **needs a word** to attach a technique Effect (technique-effects) |
| Boundary Stele, Plant the Stele | charges with timers, rising cost, ward per charge, slow and Earth while two held | has (`each_for`, `refund` negative, `ward_pct` scaled) |
| No Crossing the Line | each time the foe acts | has (`foe_pressed`, read each second) |
| Army-Breaker, The Seventh Star Falls (d21) | Momentum, decay, upkeep, companions keep the wait, pierce, full Momentum | has (`decay_share`, `gain_qi` −, `ignore_block`, `bypass`, `exposed`) |
| Sealed Writ | no new buffs, wards half | has, approx (strip each second, Exposed) |
| Seven Lamps Turn, Before the Sun | next ward doubled | has (`ward_pct` +100 for 5 s) |
| Weighed | arts cost 20 % more; a lie is known | has, approx (Heavy Breath 25 %); the lie half is dialogue |
| The Called Blow | wait, sure crit, ignore block, "breaks a ward" | has (`since_act`, `sure_crit`, `ignore_block`, foe `qi_share` / `ward_share`) |
| Beat to Quarters | every companion strikes once | has, approx (one free hit; no summon-count readable) |
| Envoys Are Not Struck, Know the Way Out | first hit halved, leave at once, escape odds | has (heal of amount, mod `escape`, event `escape_failed`) |
| The Ink Remembers, Sentence Stands | curses longer; cannot be cleansed | has (`status_dur` scoped curse); **needs a word** for the cleanse lock (curse-fast) |
| True Gold Shows | appraisal | not a fight rule (`not_run`) |
| True to the Line | Stele charges last longer | has (a flag read by Plant the Stele: 15 s charges) |
| The Banner Is Raised | Darkness stacks | **needs a word** (darkness-element) |
| Seal and Weight in One Hand | stun, strip, wards broken, own ward half | has (`stop_clock`, `strip`, `exposed`, `ward_pct` −50) |
| The Army That Waits | riders as a companion for 10 s | has (`summon`, first hit `timer`) |
| The Called Thrust | Earth per waiting second; break at 5+ | has (`since_act`, `consume`, `exposed`) |
| The Weakest File | pierce a fifth of resistances | has (`pen`, scoped `tags` spear and `kind` companion) |
| Words Before Needles | needles loaded on evade, thrown by the fan | has (`evaded`, scaled `free_hit`) |
| The Door Stays Shut | seal-wards that fade; the foe's arts held | has, approx (`ward_grow` ±, a latched Composed, `timer next 2`) |
| True Line | cannot miss; fifth sword hit in a row | has (`acc` +100, row counter, `free_hit`) |
| A Fair Copy | soul or curse art copied back | soul: has (`soul_reflect`); curse: **needs a word** (curse-reflect) |

No ruling blocks a record: every vague case was settled by a standing ruling (R1-R6) or auto-accepted (§A).
`spatial_words_check.py` was not needed past the depth text: the 2026-11-26 rewording pass already made the Thiên Xu
records non-spatial (WIRED.md lines 246-255), and nothing staged names a position.

## C. Techniques (all bonuses and passives are NEW, sized against the same tier; unpriced)

| Technique | Tier, kind | Bonuses | Passives | Arts (unlock) | Peer it is sized against |
|---|---|---|---|---|---|
| weighing-stone-primer | Yellow main, Metal + Earth | none | attack 4 % [kim], Earth stack effect 6 % (debuff), defence 4 % | counterweight-palm 1, sinking-weight 2, whetstone-pass 4 | clear-frost-breath (8.2 W of 8) |
| dipper-handle-canon | Profound main, Metal | attack 8 % | art speed 6 % [kim], crit 4 [kim], damage more 3 [kim], accuracy 6, Metal stack duration 10 % (debuff) | the-handle-points-east 1, sheathed-edge 2, flying-blade-retinue 4 | hundred-blades-canon, snow-plum-sword (13.1 W of 16) |
| heavenly-pivot-true-canon | Heaven main, Metal + Earth | defence 12 %, thần thức 12 %, tâm ma resist 10 | Earth stack effect 16 % (authored b7), Earth stack duration 16 %, attack 8 % [kim], damage more 3 [kim], linh lực regeneration +16 % | the-pivot-does-not-turn 1, mountain-stance 2, weigh-the-heart 3, north-star-writ 4, stone-warden-call 5; passive art The Pole Draws (layer 4) | nine-seal-ledger, deep-vein-scripture (35.2 W of 32, a note) |
| boundary-stele-array-canon | Earth secret, Earth + Metal | defence 10 %, thần thức 10 % | Earth stack effect 10 %, Earth stack duration 12 %, curse duration 10 %, formation art cost −8 % | plant-the-stele 1, no-crossing-the-line 2, bastion-reprisal 4 | frost-lotus-array-canon (11.1 W of 24) |
| army-breaker-spear | Earth secret, Metal | attack 8 %, khí huyết 10 % | crit damage 30 % [physical], pierce 6, block 10, linh lực regeneration +8 % ("the long wait costs linh lực") | the-seventh-star-falls 1, coiling-thrust 2, sundering-wedge 4 | drawn-out-edge-canon (23.6 W of 24) |
| **water-clock-breath (new)** | Yellow main, Water + Wood | none | linh lực regeneration +5 %, health regeneration +8 %, status resistance 6 | clock-breath 1 | warm-hearth-breath (8.8 W of 8) |

Deviations:
- **D1.** The Pivot canon carries 5 abilities, above cong-phap rule 17's 1-4 (a lint note only). The depth text names
  five fighting arts for the founder's Heaven method, and all are kept.
- **D2.** The Pole Draws is a technique Effect at layer 4, not an art at layer 7 (§A 1-2).

## D. Arts (`arts/part-sect-thien_xu.json`), depth text beside engine form

| Art | Depth text | Engine form | Deviation |
|---|---|---|---|
| counterweight-palm | one Earth stack, and one Metal if the last art was Earth (or the reverse); a foe with one of each: soonest art waits 0.3 s and the next art is a little slower | Earth c 1.3, cost 0.03, cd 3. 1 Earth (8 s); +1 Metal if your last art was Earth or Metal; with both on the foe, `timer next` 0.3 s and 1 Slowed Time (2 s) | **D3** "(or the reverse)" read as either pan; **D4** "a little slower" is 1 Slowed Time |
| the-handle-points-east | spends a full handle (7 Metal arts) for the next Metal art to strike twice and lay 2 Metal; Broken keeps 3 stars; + d9 lose count | Metal sword c 2.3, cost 0.04, cd 3. The handle counter lives here. At 7+ stars this cut is empowered: c ×2 in two hits, 1 Metal per hit, and Broken keeps 3 stars | **D5** the double strike is this cut, not "the next Metal art"; **D6** one star a breath (no loss for rushing); **D7** recovery after 3 s with no damaging or movement art |
| the-pivot-does-not-turn | still stance: while Composed, 1 Earth every 2 s, Metal arts deal more per Earth stack; a movement art ends it and clears half the stacks it laid | Earth, c 0, cost 0.03, cd 4, tags formation. A counter flag. While Composed, 1 Earth (10 s) every 2 s and 1 per companion or summon hit (once a second); Metal arts +4 % per Earth stack, no cap; a movement art ends it and halves the foe's Earth stacks | **D8** a self-state, not a stance slot; **D9** companions' and summons' hits also lay Weights (the canon's "flying edges orbit them"); **D10** halves all Earth stacks, not only those it laid; **D11** tagged formation (the Seven-Star Array is keyed to the flag) |
| weigh-the-heart | Metal damage grows with every stack of any element; strips the two longest buffs; cannot crit | Metal c 3.0, cost 0.05, cd 6. +3 % per debuff stack of each of 7 elements; strips 2 stacks of the largest buff pile; crit −1000 scoped to itself | **D12** "two longest buffs" is 2 stacks of the largest pile |
| north-star-writ | for 8 s the foe is Named: companions deal more; above half health it takes Withering | Metal c 1.4, cost 0.04, cd 8, tags seal. Named 8 s: companions +30 %; each second above half health, Withering 2 s | **D13** tagged seal (a writ under the Bắc Thần Ấn); the sizes are mine |
| plant-the-stele | a Stele charge for 12 s, each dearer by half again while others are held; each charge a small ward | Earth, c 0, cost 0.03, cd 3. Charges (12 s, 15 with True to the Line); extra cost ×1.5^k by refund; ward +8 % per charge; with 2+ held, each second 1 Earth and 1 Slowed Time (the technique's text) | **D14** needs a fifth of linh lực in hand; from the sixth held the extra stays at ×11.4 |
| no-crossing-the-line | lights the lines 6 s: each time the foe acts while 2+ Steles are held, 1 Slowed Time and 3 Earth | Earth, c 0, cost 0.04, cd 8; fires only with 2+ Steles. 6 s; each second the foe acted (`foe_pressed`), Slowed Time 3 s and 3 Earth | **D15** "each time" is each second in which it acted |
| the-seventh-star-falls | spends all Momentum on one thrust that pierces block and ward; with full Momentum breaks a formation link or summoned ward; + d21 | Metal spear c 1.6, cost 0.05, cd 6. Momentum: +1 a waiting second, +1 a second when companions land while you wait, −5 % a second, upkeep 1 % linh lực past 5 s. +5 % damage per Momentum, ignores block, bypass 0.5; at 10+ Momentum the foe is Exposed 3 s | **D16** "pierces the ward" is bypass 0.5; "full" is 10; the break is Exposed; **D17** only this thrust spends Momentum; **D18** the basic attack does not break the wait |
| clock-breath (new) | n/a | Water heal, c_heal 0.5, cost 0.03, cd 5 | new art |

## E. Effects (`effects/thien_xu.effects.json`), depth text beside engine form

| Effect (piece) | Engine form | Deviation |
|---|---|---|
| The Pole Draws (Pivot canon, layer 4) | while Composed, +0.2 % linh lực a second per 3 Earth stacks on the foe | as d8; the attaching is pending (technique-effects) |
| Sealed Writ (North Star Seal) | first seal-tagged hit a fight: Exposed 4 s, and the foe's largest buff pile is stripped each second for 4 s | **D19** approx (Exposed for "wards half"; strip for "no new buffs") |
| Seven Lamps Turn (Seven-Star Flag) | each formation art lights a lamp; at 7, ward +100 % for 5 s and 2 Earth, then out | **D20** "next ward doubled" is +100 % for 5 s |
| Weighed (Heavenly Weight) | each seal hit: 1 Earth (6 s) and Heavy Breath 6 s, clamped to 5 | **D21** 25 %, not 20 %; the dialogue half is not run |
| The Called Blow (Phá Quân Spear) | after 3 s without striking, the next spear art is a sure crit and ignores block; if its hit leaves the foe's ward down, the wait halves | **D22** "breaks a ward" is the foe's main ward down (linh lực 0) or its stance ward broken |
| Beat to Quarters (War Drum) | a summon or formation art: one free hit 0.5, once each 10 s | **D23** one hit, not one per companion |
| Envoys Are Not Struck (Jade Tally) | until you strike, the first hit on you is half healed back; escape +100 while you have struck no one | **D24** "halved" is a heal of half; "leave at once" is escape +100 |
| Know the Way Out (Jade Tally, d2) | each failed escape +10 escape, no cap | none |
| The Ink Remembers (Inkstone) | from the third seal art, curses last twice as long (5 s clamp) | **D25** all your curses, not only the seal arts' |
| True Gold Shows (Touchstone) | `not_run`: an appraisal rule | **D26** out of fight |
| True to the Line (Square-and-Compass) | Stele charges last 15 s, not 12 | **D27** Anchor charges dropped (none in Thiên Xu); "not worn" needs nothing |
| The Banner Is Raised (Armoured Horse Banner) | `not_run`; the full record is in pending.json | **D28** "summons take a quarter less" dropped (summons are never struck) |
| Seal and Weight in One Hand (Regalia, 3) | foe below half with 5+ Earth, once: clock stops 2 s, strip, Exposed 4 s; own ward −50 % | **D29** approx, as D19 |
| The Army That Waits (Armoured Horse, 2) | at fight start, riders as a summon (0.6 every 2 s, 10 s); the first companion hit delays the foe's soonest art 0.5 s | **D30** riders at the start; the realm half is a world event |
| The Called Thrust (Harness, 3) | each waiting second 1 Earth (12 s); Seventh Star spends them, and 5+ first lays Exposed 4 s | **D31** "breaks the ward entirely" is Exposed |
| Sentence Stands (Bridge Court Pair, 2) | while the foe carries a Weight, curses last +50 % | **D32** +2 s is +50 %; the cleanse lock is pending (curse-fast) |
| The Weakest File (Drum, Flag and Spear, 3) | the drum's strike marks the foe 6 s: spear and companion hits ignore 40 resistance points | **D33** "a fifth of resistances" is `pen` 40; the multi-foe clauses are dropped |
| Words Before Needles (Envoy's Credentials, 3) | evades load needles; a second with a strike drops one; the next needle or fan art throws 0.1 per needle | **D34** "fan art" is the needle tag or the fan's Fan Gust (artifact); the leave clause is the tally's |
| The Door Stays Shut (Keeper's Desk, 3) | a seal art while Composed (as read at the last second): stance ward +4 % of health, fading 0.4 % a second per seal-ward; from the inkstone's third writing, the foe's soonest art waits 2 s | **D35** of health, not linh lực; the latched Composed; the hold is the soonest art only |
| True Line (Plumb and Level, 3) | with Metal on the foe, accuracy +100 (all hits); every fifth sword hit in a row, a free hit 0.6 | **D36** accuracy is read without the hit's context |
| Before the Sun (Dawn Pair, 2) | the first sword art is a sure crit; if it doesn't Break, ward +100 % for 5 s | as D20 |
| A Fair Copy (Copyist's Pair, 2) | soul reflect 1 for the fight; the curse half is pending (curse-reflect) | **D37** turned back at once, not by your next seal art |

## F. Items and sets (`items/catalogue-sect-thien_xu.json`, `items/sets-thien_xu.json`)

- **30 items, 10 sets**, with the depth modifiers as given. Effects are named in plain English. Weapons and body gear
  carry the R6 exception.
- **D38.** `tx-iron-horse-tally` gets base `phu` (§A 11).
- **D39.** `tx-hidden-string-zither`'s `song` scope becomes `artifact`. `song` is not in the Modifier vocabulary
  (WIRED b2 unapplied), and its String Cut is an artifact art.
- **D40.** The four treasures gain `rarity: 5`.
- **D41.** The fields `status`, `authored` and `note` are dropped. The note was "a spear on the phi_kiem base: no
  spear base exists"; see §I.
- Set `rule` texts are the depth's; the engine text is in the Effects file.

## G. Stand-ins (applied in `thien_xu.3.cast.json` and `thien_xu.4.cast.json`)

| Person | Root | Was | Now (layer kept) |
|---|---|---|---|
| dong_to_huong | Earth, Water | hoang_tho 3 | weighing-stone-primer 3 |
| huong_nghien_thach | Earth, Wood | hoang_tho 1 | weighing-stone-primer 1 |
| hang_that_ket | Earth, Fire | hoang_tho 2 | weighing-stone-primer 2 |
| phan_boi_son | Earth, Fire | hoang_tho 3 | weighing-stone-primer 3 |
| vu_tinh_giai | Fire 40, Earth 36 | hoang_hoa 1 | weighing-stone-primer 1 |
| ha_khac_thuy | Water, Wood | hoang_thuy 2 | water-clock-breath 2 (new) |
| o_tieu_dan | Wood, Water | hoang_moc 2 | water-clock-breath 2 (new) |
| dieu_duong_hac | Wood, Water | hoang_moc 2 | water-clock-breath 2 (new) |

## H. The holder table (`sect_fight.py thien_xu`, 10 seeds, typical same-realm foe; real-kit probes)

**Every art fires at the same realm.** At `--gap 1` everyone dies in 8-14 s. Flying Blade Retinue and Stone Warden Call
(9 s cooldowns) then never come off cooldown: that is the realm step, not a record fault (FIGHT-INPUT, traps).

| Holder (realm) | sect_fight result | Effect: with / without, runs | Note |
|---|---|---|---|
| doan_ngoc_hanh (NA) | 19.4 s, 10 of 10, 71 % | Sealed Writ 19.4/19.9 s (50 runs); Seven Lamps 19.4/19.4 (40) | With his seal's Seal Slam slotted, the kit is weaker, but Seven Lamps shows: 58.3 s, 14 % left with it against 60.2 s, 13 % without (139 runs). Without it the 7th lamp comes after his fights end |
| do_tinh_ha (NA) | 30.0 s, 10 of 10, 90 % | Called Thrust 30.0/32.6 s (179); Called Blow 7 | sect_fight never slots his spear; with his real kit (Seventh Star, Coiling Thrust): **Called Blow 22.0 s / 29.9 s without (106 runs)**, Called Thrust 22.0/28.5 s |
| phuong_truc_ngon (NA) | 27.5 s, 10 of 10, 74 % | **Weighed 27.5 s 74 % / 34.8 s 58 %** (124); Sentence Stands 0 runs, no change | Sentence Stands: an `always` record (no runs counted); his curses are 2 s Withering or already at the 5 s clamp |
| ngu_tran_bac (NA) | 45.8 s, 30 of 30, 62 % (30 seeds) | Beat to Quarters 45.8/46.5 s (115); Weakest File 45.8/46.3 s (115) | `pen` is applied about 8 times a fight; his fights run long, so it shows little |
| mau_tri_vien (KĐ) | 30.5 s, 10 of 10, 62 % | Envoys 30.5/30.5 (606); Words Before Needles 30.5/30.7 (204); Know the Way Out 0 | Envoys: half of one hit, too small to show. Needles: he strikes every second, so needles fall out (the envoy who fights pays); real kit with Fan Gust: no change. **Know the Way Out: no escape art** |
| su_ngung_mac (KĐ) | 26.3 s, 10 of 10, 72 % | Ink 26.3/26.9 (120); **Door Stays Shut 72 % / 64 %** (454) | |
| cong_ton_duan (KĐ) | 37.7 s, 10 of 10, 60 % | True Line 37.7/37.7 (303) | No sword art in sect_fight's kit; with his sword's Flying Sword Strike: 49.4/49.0 s, 27/26 % |
| doan_hi_hoa (TC) | 27.1 s, 10 of 10, 64 % | Before the Sun 64 % / 57 % (39) | |
| thich_minh_thu (TC) | 21.2 s, 10 of 10, 62 % | A Fair Copy 10 runs, no change | The typical foe casts no soul art |
| thien_thua_cu (KĐ) | 50.6 s, 3 of 10, 8 % | True to the Line 50.6 s 8 % / 51.3 s 1 % | Weak kit (Pivot plus one Stele art in 6 slots) |
| dang_quan_binh (KĐ) | 45.9 s, 7 of 10, 16 % | True Gold Shows: `not_run` | Out of fight |
| other Pivot elders (KĐ) | trong 9, boc 7, bach 7, quy 10 (of 10); nhiep 2 | | nhiep's kit waits for Momentum |
| Dipper inner gate (TC) | 7-10 of 10 (pure Metal 10, 59 %; plain 3-art 7, 19 %) | | After the retune (was 1 of 10) |
| Dipper (LK) | 6-7 of 10, 18 % | | |
| Primer outer gate (LK) | 0-7 of 10 | | Luyện Khí baseline: Băng Tâm's Luyện Khí go 0 of 6 against the same foe (weak start intended) |
| servants (LK) | 0 of 10 | | As Băng Tâm's servants (warm-hands 0 of 6) |
| hinh_thu_tinh, thinh_ham_quang | REFUSED | | `fight.py` purity does not accept `light` (§I) |

**Synthetic kits for the sets with no real holder:**
- **Seal and Weight in One Hand** (Doãn Ngọc Hành with all three Regalia pieces): it judged 4 times in 10 fights.
  The full set ends at 58 % health left against 75 % without, because the "own ward half" penalty outweighs it. That
  is faithful ("one who judges alone stands alone"), and the set is split by design.
- **The Army That Waits** (Ngũ Trấn Bắc with banner and tally): 20 runs; 40.9 s against 39.0 s without, which is noise.
- **The Banner Is Raised**: `not_run`.

**The Dipper Handle measurement** (stars and points per fight; §A 3):
- As written, a holder made 1-2.5 stars and about 0.1 points a fight, losing count about 10 times a fight.
- Paced: pure-Metal holders make 8-11 stars and 1-2 points. Mixed kits lose count on their non-Metal art, as the canon
  teaches.

**The five lessons:**
- [x] Every Effect changes the fight on its holders or has a written reason (above). Every art fires at the same realm.
- [x] No holder slots two stances of mine: my arts set no stance; the Pivot is a counter. The Mountain Stance and
  Mountain Root Stance overlap is between two library arts (§I).
- [x] Each "your X" works for a holder who lacks X: the main ward everyone holds, or `ward_grow`, which creates a
  stance ward.
- [x] The vague words are pinned in each `rule`: Weight, ward, strike nothing, full Momentum, fan art, the drum
  strikes, a breath, lost count, Composed as latched.
- [x] The new bonuses and passives are sized against the same tier and marked new (§C).

## I. Open items (for the user or the serial step)

1. **Pending words** (`pending.json`, with the full records):
   - technique-effects;
   - darkness-element (its stack effect needs a ruling);
   - curse-fast;
   - curse-reflect.
2. **`fight.py` refuses Light purity.** `to_build` checks purity against `ELEMENTS - {""}` without `light`, though the
   engine has had it since slice 4. Hình Thủ Tinh and Thịnh Hàm Quang (Light variants) cannot be checked. This is a
   tool fix for the serial step.
3. **`export_named.py` skips `kind: treasure`.** This is carried over from Băng Tâm, and here it covers 4 items: the
   North Star Seal, the Heavenly Weight, and the Armoured Horse banner and tally.
4. **There is no spear base.** Two spears sit on `phi_kiem` (an Item DB open question), so the spears' common art is
   Flying Sword Strike.
5. **Mountain Stance and Mountain Root Stance overwrite each other.** Mountain Root's toggle fires on any
   `stance`-tagged art. Quy Thủ Lũy's kit holds both, and so would any Pivot holder with Mountain Bone in an in-game
   loadout. Both are library arts (mountain-heart-canon, mountain-bone-body-art), so a combined state needs an edit
   outside this pass.
6. **sect_fight's slotting.** It takes the main's arts first, up to 6 at every realm, and technique arts only. So the
   Nguyên Anh aux arts (spears, swords) and the items' common arts (Seal Slam, Fan Gust, Flying Sword Strike) never
   slot. The real-kit probes above stand in, and the in-game NPC loadout decides.
7. **Weak kits** at the same realm: Thiện Thừa Củ 3 of 10, Nhiếp Minh Tiễn 2 of 10. All Luyện Khí lose about as Băng
   Tâm's do. Left for Stage 11 balance (do not chase outliers).
8. **Out-of-fight halves:**
   - Weighed's lie-knowing goes to NPC Interaction & Dialogue;
   - The Army That Waits' realm is a world event;
   - True Gold Shows is an appraisal rule for the market and item screens.
9. **WIRED.md items for the user:**
   - b13: the war flag's companion lines (keys missing);
   - the stale `build_use` on `tx-miasma-root-charm` ("and her root fields") is kept as the depth text has it;
   - the Way-Out Knot choice for phong_bach_ke.
10. **Cross-owner references:** loose-south's doan_moc_thinh and loc_bat_quy use the primer and the Dipper. They close
    when this pass merges.
11. **The gap report reads committed files only.** The staged records show as `rule text` until the serial step
    merges them; stand-ins already read 0.
