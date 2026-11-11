# Run Summary: overnight builds, 2026-11-10

> Written 2026-11-11 by the end-of-run session.
>
> **Sources:**
> - every guide and sheet in `builds/`
> - `staging-catalogue.md`, `suggestions.md`, `ledger.md`
> - the driver table
> - to explain what did not run: `queue.json`, `queue-later.json`, and the ends of the `_driver/` logs.
>
> **Status:** nothing here is decided. Every number is a sheet's first guess or paper model, not a fight result.

## 1. Synopsis

**The run in one paragraph.**
- **Builds:** 15 of 15 queued builds DONE on the first try, each with a sheet and a player guide. The first six guides were added afterwards by backfill sessions.
- **Checks:** 0 FAILED, 33 NOT ASSESSED.
- **Staging:** 276 new staged pieces and 66 reuses (driver count).
- **Suggestions:** 51 system suggestions.
- **Session time:** 328 min in all. The first six builds averaged 31 min. The last nine averaged 16 min, after the no-simulator decision. Sessions overlapped, so wall time was shorter.

**Fight checks were not assessed.** Every build's "The fight" check is NOT ASSESSED.
- **Last nine builds:** by the user's decision of 2026-11-11 (no simulator).
- **First six builds:** they ran before that decision and tried `fight_calc.py`. It is out of date: CONSTANT_DRIFT on 31 of 60 constants, and it still models the retired tick caps. Its output is kept only as observations, and their numbers are hand-worked paper models.
- **Unrun scripts:** four paper scripts were written but never run: `two-clocks.sim.py`, `first-volley.volley.py`, `soul-lance.sim.py`, `bare-fist.sim.py`.

**Builds by kind.**
- All 15 are player builds at top-end power. There is no starter or typical build yet.
- Power is from the paper model at Nguyên Anh (Nascent Soul) unless a realm is named.
- "Anchor" means the top-end anchor of Combat Formulas B: M 256 at Nguyên Anh, 325 at Hóa Thần.

| Kind | Build | Engine | Power | Strongest upgrade |
|---|---|---|---|---|
| Ticks | Two Clocks (Song Thời), `two-clocks` | Burn empties the foe's linh lực through what its resistance stops (Ash Ledger), then Poison kills. Enabler: Twin-Wick Incense Clock (L5 on ticks; hits deal 0) | Typical foe ≈ 4 s; strong foe ≈ 8 s, at 58 % health | Twin-Wick Incense Clock: strong-foe kill 11 s → 8 s |
| Ticks + sustain | Thousand-Year Banyan (Thiên Niên Dung Thụ), `unkillable` | Healing past full lays Poison (Surplus Life); fatigue finishes the fight | Top-end sustain, damage low by design (M 6.8 against the typical 8.96 at Hóa Thần). Typical foe ≈ 25 s; outlasts a typical side at fatigue (falls ≈ 72 s against 66 s) | Surplus Life: the only damage channel. Without it the build wins only by fatigue |
| Art hit, timing | Flash Before the Thunder (Tiên Điện Hậu Lôi), `first-volley` | Four arts at the 0.5 s floor through opening haste. The Breaker empties the drain ward, then the followers land | M 228 with crit at both caps. Wins at 0.500 s against typical and top-end foes, also one and two realms up (old-model proxy) | Opening Haste: a loss at 1.0 s becomes a win at 0.5 s against top-end |
| Art hit, timing | Winnowing Gale (Dương Khang Phong), `cooldown-floor` | Six cheap, quick Wind arts at `cooldown_min`: 13 hits a second and per-hit sustain | M 89 per hit, but ≈ 21 coefficient a second: rate above every anchor | Slipstream: linh lực bill 15 % → 6.6 % of the pool a second |
| Art hit, timing | Slow Thunder (Trì Lôi), `slow-thunder` | Three cheap, slow peals keep the pool full. Its overflow loads the 12 s peal (Thunderhead) | M 176, then 266 once the foe is dry (anchor 256) | Thunderhead: great peal coefficient 4.23 → 7.23 |
| Art hit, timing | Empty Hall (Không Đường), `one-art` | One art at the lint maximum (6.75, 12 s). Each empty slot adds speed, coefficient, L5 and a ring. Enabler: Vow of the One Stroke | Hóa Thần: a stroke every 2.5 s at coefficient 9.55, ≈ 2.4 × the anchor's mean art per firing | Clear Path: the 12 s art fires every 2.5 s |
| Art hit, rule stack | Straw Effigy (Thảo Nhân Chú), `curse-engine` | Each landed hit lays the next curse of a litany. Each curse pulls the Iron Nail 0.5 s closer. Enabler: Petty-Man Effigy | Beats top-end at 1.5 s with 70 % health; typical foe dead in 0.5–1.0 s | Driven Nail: a win at 2.0 s on 3 % health becomes 1.5 s on 70 % |
| Art hit, rule stack | Three Smeltings (Tam Luyện), `triple-convert` | Physical → Fire (the art's own conversion) → Chaos (modifier), so three families of bonuses land as Chaos | M ≈ 255, the anchor | Second link to 100 (Smoke from the Flame): M ×89 → ×255 |
| Art hit, rule stack | Hearth Mountain (Trạch Sơn), `home-fortress` | All five kinds of preparation, past the L4 cap. The surplus becomes ward strength. Enabler: Threshold Flags | At home: M ≈ 235 and ward strength 407 (165 away). Blind away: M ≈ 88 | Overbuilt Walls: +100 ward strength |
| Art hit, rule stack | Armoury Mind (Tàng Binh Thức), `armoury-mind` | L3 is full with two or three pieces. Every extra weapon strikes each pulse and lays Metal stacks. Enabler: Garrison Mind | ×271 against 256; Hóa Thần ×396 against 325 | Garrison Mind: ×180 → ×271 |
| Art hit, rule stack | Needle Under the Mountain (Sơn Hạ Châm), `giant-killer` | Half a Realm halves the fight-unit gap one or two realms up. Pierce becomes soul resistance and penetration | Upward M ≈ 243 against 200. Against a top-end foe one realm up: 25–40 % (generic ≈ 1 %). Against equals: 0.3 of top-end | Half a Realm: fight-unit gap ×6.31 → ×2.51 |
| Linh lực burn | Dry Well (Khô Tỉnh), `dry-well` | Ice plus Cold Toll make the foe's drain ward bill its own pool. Guarded blades fire into the empty ward. Enabler: Water Table on a gourd | Beats top-end at 2.0 s with 81 % health; boss ≈ 3 s | Cold Toll: a loss at 2.0 s becomes a win at 2.0 s |
| Soul | Soul Lance (Hồn Thương), `soul-lance` | One soul art per lockout at `soul_cap`. Heavy treasures feed soul damage (Thousand-Weight Thought) | At the channel's ceiling (0.30 a second): typical and strong foes die at 4.0 s | Thousand-Weight Thought: a loss at Kết Đan becomes a win; 5 s → 4 s at Nguyên Anh |
| Basic attack | Brimming Hand (Mãn Tức Quyền), `bare-fist` | Never casts. A full pool's overflow loads the next punch (Stored Breath), and wards fill the art slots. Enabler: Closed Hand Vow | Late bloomer: damage 0.24 of top-end at Kết Đan, 0.72 at Nguyên Anh, 0.96 at Hóa Thần. Wins the top-end race at 1.33–2.0 s | Stored Breath: race 2.0 s → 1.33 s in half the rolls |
| Companion | Raising the Tiger (Dưỡng Hổ), `beast-carry` | The tiger strikes on two timers floored at 0.5 s. The keeper only buffs, heals and shields. Enabler: Shared-Heart Contract | M ≈ 203 × Fire buff (×2.4–3.1) × 4 bites a second, but only if Fire buff sits outside M (×1.1 if it sits in L1) | Bonded Spirit: 2 → 4 bites a second |

**Failed or did not run.**
- **Failed:** none of the 15.
- **Retry logs:** `_driver/` also holds a "-try2" log for `beast-carry`, `triple-convert`, `unkillable` and `home-fortress`, reading "failed, usage limit reached" (the 5-hour limit). The driver counts one try for each, and all four finished, so no build was lost.
- **Did not run:** 23 builds parked in `queue-later.json` were never queued. At 09:30:56 the driver logged "queue empty" after `giant-killer`, the one build taken from that file. The files do not say why the rest were held back. They are:
  - mirror-hide, status-collector, evade-dancer, meta-hunter, deity-warden, sect-ladder
  - starter-flame, starter-wall, starter-venom, starter-blade, starter-tide
  - loaded-dice, art-thief, pacifist, heart-demon-rider, borrowed-years, pill-furnace, second-wind, lone-star, fleeing-master, ward-eater, tempo-thief, berserk-bloom

**Guide notes.**
- `soul-lance.md` lost its "Realm by realm" heading: its realm bullets sit under the Upgrades table.
- The guides disagree on whether Unyielding Breath (Bất Khuất) is designed in the Effects GDD or only in the tree catalogue. `dry-well.md` says catalogue only; the others say designed. Check it once.

## 2. System suggestions

The 51 entries in `suggestions.md` are merged into 17 items. Two items also cover gaps every sheet raised through its Fit labels. They are ranked by how many builds need them and how much they change the game. Rule numbers follow the suggestions file.

### 1. Record fields so staged content can exist
- **Touches:**
  - `items_cong_phap.json` / `cong-phap.md`: techniques have no field for abilities, combat passives or Effects.
  - `combat.md` rule 12.
  - `item-database.md`.
  - The Alchemy and Talismans quick specs.
  - `character-stats.md` Formulas D (`pill_potency`).
  - `crafting_formations.json`: today's three formations are cultivation and defence only.
- **Proposal:**
  - Every pill, coating and combat talisman gets a `fight_payload`: L4 `damage_more` with a scope, or a stat; the situations that allow it; and what scales it (home-fortress).
  - Combat formations become data.
  - Technique records gain ability, passive and Effect lists, plus a budget for combat passives. Eight sheets could not check passives, because they sit outside `bonus_pool`.
- **Builds:** all 15.
  - Every staged technique is "Needs key" for this.
  - Every staged pill, coating and formation names the payload gap.
  - Nine Rods Array alone serves 11 builds.
- **Trade-off:** pills become most builds' main L4 source, so toxicity becomes the real limit on fighting often, which is the intended cost. Data work, no rule risk.
- **Recommend:** adopt first. It is schema, not balance, and no staged piece can be entered without it. Add the passive budget in the same pass.

### 2. New readables and events for Effects
- **Touches:** `effects.md` rule 5; `combat.md` rule 9 event list.
- **Proposal:** one batch of readables.
  - A tick's prevented points (two-clocks: Ash Ledger).
  - "Your stacks or curse were removed by a cleanse", with the count or the curse and its time left (two-clocks: Cinder Debt; curse-engine: Backlash).
  - Arts you fired this instant, and the enemy's firings counted in "firings this fight" (first-volley: Eruption, Unanswered).
  - Pool shortfall, and the extra art cost your Ice added (dry-well: Owed Water, Frost Tithe).
  - The linh lực a soul hit took (soul-lance: Lamp-Oil Siphon).
  - Health overflow, per pulse window (unkillable: Surplus Life).
  - A layer's total before its cap, at compile (home-fortress: Overbuilt Walls; armoury-mind: Edge Past the Rack).
  - The pieces you control, with count and roles (armoury-mind: Garrison Mind, Full Rack, Humming Shields).
  - Higher-realm knockouts this life, and "the target is a boss" (giant-killer).
- **Builds:** 10: two-clocks, first-volley, cooldown-floor, dry-well, soul-lance, curse-engine, unkillable, home-fortress, armoury-mind, giant-killer.
- **Trade-off:**
  - Almost all of these are values the engine already computes. The cost is Breakdown lines and one save counter (knockouts).
  - Each opens a family of "X becomes Y" Effects, and each of those needs its own cap.
- **Recommend:** adopt as one rule-5 edit, and require a cap on every Effect that reads one.

### 3. Reference thần thức and soul resistance by realm, and Thinned Mind
- **Touches:**
  - `combat-defence.md` rule 14 and Open Question 12.
  - `combat.md` rule 3 and Formulas E2.
  - `effects.md` rule 6.
- **Proposal:**
  - **The table (soul-lance):** reference thần thức and soul resistance for the typical foe, the top-end foe and rule 18's soul-resistant foe.
    - Starting guesses: typical 59.4 talent-units, soul resistance 0; top-end 142, soul resistance 15.
    - The soul-resistant foe adds a Soul-Guarding Lamp.
  - **Thinned Mind (armoury-mind):** an enabler's or keystone's close may set `divine_sense_def = free + k × bound` for its holder only (Garrison Mind: k 0.5).
- **Builds:**
  - Directly: soul-lance, giant-killer, armoury-mind.
  - The same missing figure left the thần thức budget unchecked in eight sheets: two-clocks, first-volley, dry-well, curse-engine, beast-carry, triple-convert, cooldown-floor, slow-thunder.
- **Trade-off:**
  - None to rules for the table, but it pins numbers that NPC Builds and the harness must honour (AC-CD-51).
  - Thinned Mind adds a branch to E2. At k 0 it would be a death sentence against any soul art.
- **Recommend:**
  - Fill the table now from soul-lance's guesses. It unblocks a check in eight sheets and every soul result.
  - Adopt Thinned Mind, and tune k once the table exists.

### 4. Close the pricing holes in the art lint
- **Touches:**
  - `combat.md` Formulas C and E2.
  - `effects.md` rule 9a, Formulas D and AC-EF-69.
  - `combat-defence.md` rule 6.
- **Proposal:**
  - (a) **Curses pay a lint charge** (dry-well): for example 0.10 per pulse for a rule-changing curse, 0.15 for Leaking Ward or Heavy Breath. Non-element ticks use the status lint.
  - (b) **Soul arts are priced** (soul-lance): `soul_pct ≤ 0.0125 × art lint`, clipped to 0.03–0.08.
  - (c) **Stack grants are bounded** (two-clocks): an art whose uncapped stack charge passes 0.6 fails the lint. One firing then grants at most 40 debuff or 60 buff stack-seconds.
  - (d) **Front-loaded batches** (two-clocks): pick one of
    - a minimum batch of 2 pulses,
    - a higher weight for short batches,
    - a cleanse that also thins a batch on the pulse it lands.
- **Builds:** 9.
  - The proposing builds: dry-well, soul-lance, two-clocks.
  - Every build that authors a curse art at the plain lint: first-volley, dry-well, curse-engine, triple-convert, armoury-mind, one-art, slow-thunder, soul-lance.
- **Trade-off:**
  - A new term in the lint, and a re-lint of the eight staged arts that apply curses. Cheap now, before content exists.
  - Option (d) as a 2-pulse minimum costs nothing authored. The cleanse version strengthens cleansing against every stack build.
- **Recommend:** adopt (a), (b) and (c) now. For (d), take the 2-pulse minimum.

### 5. One-line clarifications
- **Touches:** see each line.
- **Proposal:** these need no new mechanics.
  - **Linh lực shares:** read against the usable maximum, as start shares already are. `effects.md` rule 5; `combat.md` rule 13 guards (bare-fist).
  - **Empty art slot:** one that holds no art, talisman, escape art or ward. `effects.md` rule 5 (one-art, slow-thunder, bare-fist).
  - **When a curse starts working:** its rule applies the moment it is placed; its duration first falls at the next pulse. `combat.md` rule 10 (curse-engine: this decides its top-end matchup).
  - **Granted element stacks:** whether they roll status chance. (a) No roll, or (b) one roll per batch. `effects.md` rules 6 and 9a; `combat.md` Formulas F (unkillable; every stack build).
  - **"A hit landed" for on-hit sustain:** every own hit that is not evaded counts, including trigger hits and companion hits. A hit block takes to 0 still landed. `modifiers.md` rule 1, AC-MD-33 (cooldown-floor).
  - **Conversion history:** a converted part's earlier types are a scope and a readable, and a two-type scope like [fire, chaos] is valid at the narrow price. `modifiers.md` rule 8 and Formulas B; `effects.md` rule 5 (triple-convert).
  - **Measured Stroke's threshold:** 20 s → 10 s. #44 capped authored cooldowns at 12 s, so today nothing qualifies. `effects.md` Starter Effects (one-art, slow-thunder).
  - **Overflow is read whole:** every Effect that reads the overflow event reads the whole amount; overflow is never split between Effects. `effects.md` rule 5 (slow-thunder, bare-fist).
  - **Formations on one ground:**
    - away from home, one formation per side;
    - at your own abode, every standing home formation counts;
    - when both sides lay one, both count unless an Effect says otherwise.
    - `combat.md` rule 12 (home-fortress).
  - **Fire buff's "+1.2 % damage dealt":** which layer it fills, and whether companion hits count. `effects.md` rule 9a (beast-carry: it decides between ×2.4–3.1 and ×1.1).
- **Builds:** 9: bare-fist, one-art, slow-thunder, curse-engine, unkillable, cooldown-floor, triple-convert, home-fortress, beast-carry.
- **Trade-off:** none, except two real balance choices.
  - The stack roll: no roll leaves cleansing as the only answer to a stack pile.
  - The Fire buff layer.
- **Recommend:**
  - Adopt the batch as written.
  - Stack roll: (a), no roll. It matches #44's "cleansing is the answer".
  - Fire buff: a factor on all of a side's direct damage, outside M, with companion hits counting. Add a falling return on stack count only if the harness shows pure buffers above the anchor.

### 6. Timer stats beyond art speed: opening, basic attack, companion
- **Touches:**
  - `combat.md` rule 13 and Formulas A2.
  - `modifiers.md` Stat List.
  - `effects.md` rule 6.
- **Proposal:** one shape for three timers, `max(cooldown_min, base ÷ (1 + X/100))`.
  - `opening_haste_pct`: each art's first timer only (first-volley). Priced at ≈ 0.3 W per %, half of art speed.
  - `basic_speed_pct`: the basic attack's timer (bare-fist). This is the Stat List's Pending row (0.4 W per %).
  - `companion_speed_pct`: the companion's timer (beast-carry). Bonded Spirit also adds the owner's art speed, and "move a timer" may name the companion's timer.
- **Builds:** 6.
  - Opening haste: first-volley, one-art, slow-thunder.
  - Basic speed: bare-fist, cooldown-floor.
  - Companion speed: beast-carry.
- **Trade-off:**
  - Opening haste turns "who fires first" into a stat race at the top end, ending in ties at the 0.5 s floor. The NPC generator must give top-end NPCs some, or alpha strikes go unanswered.
  - Basic and companion speed each double their channel's rate ceiling. More basic hits also meet flat block more often.
- **Recommend:**
  - Adopt basic speed and companion speed.
  - Adopt opening haste, but keep it off tree smalls (techniques, Way notables, named items and pills only), so all-in burst stays rare as decided on 2026-11-08. Add it to the NPC generator's top-end roll.

### 7. New plain stat keys
- **Touches:** `modifiers.md` Stat List; `combat-defence.md` Formulas C (`ward_bill_pct`).
- **Proposal:**
  - `curse_effect_pct` (curse-engine; used by triple-convert): each curse's number × (1 + X/100). Each curse's own maximum still clips.
  - `ward_bill_pct` (dry-well; used by slow-thunder): enemy drain wards bill more for what they stop against your hits. It is not a curse, and the live pool still bounds it.
  - `companion_health_pct`, and a key for the Pending "companion power share" row (beast-carry).
  - `than_thuc_cost_pct` scoped by role [weapon] (armoury-mind: Weapon efficiency).
  - The Pending `status_duration_taken_pct`, and status duration [curse] (curse-engine: the Fourth Nail's close, the Nine Knots region).
- **Builds:** 6: curse-engine, triple-convert, dry-well, slow-thunder, beast-carry, armoury-mind.
- **Trade-off:**
  - Each key needs a W price.
  - `curse_effect_pct` grows curses that already push resistance below 0 (Sundered, Exposed).
  - `ward_bill_pct` weakens drain wards against anti-ward builds in a way the ward price check does not see.
- **Recommend:**
  - Adopt all.
  - Price `curse_effect_pct` above `stack_effect_pct` if Sundered outruns it in the harness.
  - Watch drain wards' share of NPC loadouts.

### 8. Coefficients outside the art lint
- **Touches:** `combat.md` Formulas C; `modifiers.md` Stat List.
- **Proposal:**
  - `basic_coef_add` (bare-fist): flat, basic attack only, from tree, technique, Way and item lines. The art lint never reads it.
  - `art_coef_add`: flat, arts, Effect payload only (never a node, affix or technique line). Two sources:
    - the Vow of the One Stroke (one-art): +0.4 per empty art slot, cap +2.8;
    - Thunderhead (slow-thunder): held, +0.1 per 1 % of overflow gathered, cap +3.0 per landing.
- **Builds:** 3: bare-fist, one-art, slow-thunder.
- **Trade-off:** the lint stops being the last word on an art's size, so the Breakdown must show the added part. Each source is bounded by its own cap.
- **Recommend:** adopt both keys. Keep `art_coef_add` to named, capped Effect sources: these two to start.

### 9. Held payload ("until your next X")
- **Touches:** `effects.md` rule 8, and rule 1's `limits` field.
- **Proposal:** a fifth timing for Effects. The payload is banked when its trigger fires, spent on the owner's next event of a named kind, capped by its record, and lost at fight end.
- **Builds:** 2: bare-fist (Stored Breath) and slow-thunder (Thunderhead). Many "your next art" ideas from earlier runs need the same shape.
- **Trade-off:** one more state an Effect can hold, and one more Breakdown line.
- **Recommend:** adopt.

### 10. Rare cap shifts
- **Touches:**
  - `combat.md` Formulas G (`trig_cap`) and F (`curse_slots`).
  - `combat-damage-types.md` rule 6 and Tuning Knobs.
  - `modifiers.md` rare table.
- **Proposal:**
  - **Trigger limit +1** (`trig_cap_bonus`, cooldown-floor): only on keystones, named items, quest rewards and Way capstones. The tree catalogue already lists it, with no rule behind it.
  - **One more curse slot** for one keystone's owner (the Fourth Nail, curse-engine). Never more than one.
  - **A third conversion per hit** on one keystone that closes an art slot (The Fourth Smelting, triple-convert, optional). Three is inside the knob's own safe range of 1–3.
- **Builds:** 2 to 5.
  - The proposing builds: cooldown-floor, curse-engine, triple-convert.
  - Builds that meet `trig_cap` (curse-engine, armoury-mind, one-art) would also want the trigger limit.
- **Trade-off:**
  - `trig_cap` is what keeps trigger loops finite. +1 per rare source keeps it bounded by how many rare sources exist.
  - The extra curse slot makes curse defence worth more for NPCs from Nguyên Anh.
  - A third conversion stretches the Breakdown to four shapes, the readability risk the knob's own row names.
- **Recommend:** adopt the trigger limit (single per source) and the curse slot. Defer the Fourth Smelting: the build does not need it.

### 11. Art cost accepts the dampened op
- **Touches:** `combat.md` Formulas E; `modifiers.md` Stat List row "Art cost" and rule 6a.
- **Proposal:** `cost = cost_share · (1 − cost_red) · (1 + cost_raise) · qi_max ÷ (1 + D/100)`.
  - The increased reduction keeps its 0.5 cap.
  - Only Effect payloads grant D, each with its own cap (Slipstream: +200).
- **Builds:** cooldown-floor. Named second homes: Wind builds, the beast-carry keeper, curse-engine's quick curses.
- **Trade-off:**
  - Floor builds become sustainable. A solved bill at 13 hits a second is a damage rate above the anchors.
  - Ice stacks and Heavy Breath still multiply the cost back up, so cost-tax enemies stay the counter.
- **Recommend:** adopt, Effect-only. It is the room for mana builds that #44 asked for.

### 12. Ice onto drain bills for one keystone, and linh lực debt
- **Touches:**
  - `combat-defence.md` Edge Cases, Formulas C and rule 8.
  - `effects.md` rules 5, 6 and 9a.
  - `combat.md` rule 11 and Formulas E.
- **Proposal:**
  - **Cold Toll (dry-well).** The 2026-11-10 decision ("Ice … never a ward-slot payment") stays for everyone. One named keystone overrides it for its owner, and halves that owner's own Ice raise on art costs. The bill stays bounded by `pay_frac` and the live pool.
  - **Linh lực debt (dry-well, Owed Water).** A side may owe linh lực, up to a cap set by the Effect that creates the debt (40 %). Regeneration pays the debt first, and while it owes, the side counts as having no linh lực.
- **Builds:** dry-well (both). The debt names two-clocks and soul-lance as second homes.
- **Trade-off:**
  - Cold Toll makes drain wards fragile against one Ice build. The counter is ward choice: reserved and per-hit wards are untouched.
  - Debt adds a second number to the linh lực bar, and makes "dry" sticky against regeneration builds.
- **Recommend:**
  - Adopt Cold Toll. In the paper model it turns the top-end matchup from a loss into a win.
  - Defer debt. The paper model shows no change without Owed Water in short fights. Revisit it with long fights: bosses and the Kết Đan arc.

### 13. A companion that can be hurt, healed and shielded
- **Touches:**
  - `combat.md` rule 19 and Formulas J.
  - `combat-defence.md` rule 16 and Formulas B.
  - `effects.md` rules 5 and 6.
  - `creatures_linh_thu.json`.
- **Proposal:**
  - **Beast in the open:** an opt-in state, opened only by one Effect (the Shared-Heart Contract).
    - The companion gets a health bar of 0.5 × its owner's health.
    - It takes 30 % of the hit damage that reaches the owner's health.
    - Heals and shields can target it.
    - At 0 it goes Down, and it rises after 8 s at 25 %.
  - **A new Effect action, enabler only:** "your basic attack becomes a companion strike".
  - **Creature species records with an element tag.** The companion's hits carry the tag and grant that element's stacks.
- **Builds:** beast-carry. Second homes: the by-root Turtle and Snake and Salamander Keeper, and Herd-Child from 2026-11-07.
- **Trade-off:**
  - A second health bar and a Down rule in the fight log and Breakdown.
  - A net defence gain for the keeper, paid for by the Contract's close: no damaging arts, and a Down beast means the side deals nothing.
- **Recommend:** adopt as opt-in. Spirit Beasts needs species records anyway.

### 14. Home ground
- **Touches:**
  - `combat.md` rules 1 and 12.
  - The Event Engine (#23, no GDD).
  - `crafting_formations.json` field `applies`.
  - `travel-map.md` rule 8.
  - `crafting_talismans.json`.
- **Proposal:**
  - **An `own_abode` ground tag.** The Event Engine stamps it for the abode's owner, and the Threshold Flags stamp it in a foreseen fight. Combat then counts that side's `applies: home` formations.
  - **A situation step.** A source may raise a fight's situation one step, for its owner's side only, at a named place:
    - the Alarm Array: a blind fight at home becomes an ambush;
    - the Challenge Letter: a rival's next fight is foreseen, at your abode.
- **Builds:** home-fortress. Second homes: sect guardians, bosses in lairs.
- **Trade-off:**
  - Sect seats and NPC abodes get the same advantage, so raids become sieges.
  - Fewer blind fights at home weaken the ambush as a threat.
  - The letter adds an Event Engine branch and an NPC behaviour.
- **Recommend:** adopt the tag, and Combat reading `applies`, now: the field already exists. Park the situation step until the Event Engine has a GDD.

### 15. Fighting upward: a fight-unit shift, and gap readers stop at two
- **Touches:** `combat.md` Formulas C, F, G and H; `effects.md` rules 5 and 6.
- **Proposal:**
  - **A new Effects action:** shift the fight unit a side's hits, ticks and trigger hits are struck at, by at most half a realm (Half a Realm, giant-killer).
  - **A convention:** any Effect that reads the realm gap pays out at gaps 1 and 2 only. Escape Effects are exempt.
- **Builds:** giant-killer.
- **Trade-off:**
  - A new kind of power outside the layers and their caps. One realm up costs ×2.51 instead of ×6.31, and a top-end build's chance one realm up rises from ≈ 1 % to 25–40 %.
  - NPCs use it too.
  - Every tribulation is fought one realm up (`thien-kiep.md` rule 6), so it touches breakthrough odds.
- **Recommend:**
  - Adopt "gap readers stop at two" now. It protects the ≤ 2 % three-realms-up target for every future vượt cấp piece.
  - Hold Half a Realm until the tribulation fights are designed. Then decide whether it works against a tribulation boss.

### 16. L5 on ticks through one enabler
- **Touches:** `combat.md` Formulas F; `modifiers.md` rule 6.
- **Proposal:** one sentence: an Effect may state that its owner's L5 payloads also apply to that owner's ticks, and the L5 cap is unchanged. The only host is the Twin-Wick Incense Clock, whose close is "your hits deal no damage".
- **Builds:** two-clocks. It also makes the by-root Fuel for the Fire work: today it does nothing.
- **Trade-off:**
  - Up to ×2 on the tick channel, bounded by the L5 cap.
  - The holder has no fallback against status resistance or a cleanser.
  - The NPC generator must treat the enabler as all-or-nothing.
- **Recommend:** adopt, enabler-only.

### 17. Check the top-end gear anchor against the slot limit
- **Touches:** `combat.md` Formulas B (top-end L3 3.5); `combat-defence.md` Formulas A0 (top-end artifact defence 5 × B_p).
- **Proposal:** state what gear the top-end profile implies. L3 at its cap plus artifact defence 5 needs:
  - about six Cực phẩm pieces (two Seals with Liệt, four Shields with Kiên);
  - every one of the 6 slots;
  - about 120 base thần thức units, against a typical 45;
  - more than six pieces at stage 1.45.
- **Builds:** armoury-mind. It reaches L3's cap easily but carries artifact defence 2.8, not 5.
- **Trade-off:** none to rules. It may lower the top-end artifact-defence anchor, or the W share given to it.
- **Recommend:** do it inside the anchor re-derivation (decision 1).

## 3. Staging catalogue in brief

**Counts by type** (rows counted directly):

| Type | Rows | Used by one build only |
|---|---|---|
| Modifiers | 30 | 24 |
| Effects | 53 | 49 |
| Enablers | 9 | 9 |
| Artifacts, talismans, pills, formations | 31 | 25 |
| Công pháp | 17 | 16 |
| Arts | 75 | 74 |
| Đạo pieces | 27 | 25 |
| Concepts and keys | 46 | 37 |
| **Total** | **288** | **259 (90 %)** |

**Notes on the counts.**
- The driver counts 276 new pieces and 66 reuses. Its counts and the row count differ, so I counted rows.
- Summing the sheets' own Fit lines gives 123 Fits today, 151 Needs key and 64 Needs rule. A reused piece is counted once per sheet, so these sums overlap.

**Most reused** (29 rows are used by two or more builds).
- **Nine Rods Array (Cửu Can Trận): 11 builds.** The shared L4 combat formation (Ringing Ground, +80).
- **Iron-Sand Hand Bath (Thiết Sa Dục Thủ): 6.**
- **Ore Weight (Khoáng Trọng): 4.**
- **3 builds each:** Opening Haste, Quiet Channels, Ore-Vein Scripture, preparation fight payload.
- **2 builds each:**
  - Weighted Bucket, basic attack speed, Deeper Nails, Cold Iron Order
  - Thousand-Weight Thought, Eruption, Undivided
  - Herald's Banner, Thunder-Gall Pill, Smelting affixes, Hot Spring Array, Spring Sap
  - Hồn Đạo's Thần Thức and Hồn Hộ pieces
  - the concepts: cleansed-stacks event, arts fired this instant, soul reference table, held payload, layer total, Swept Floor, `art_coef_add`, empty art slot.

**Reused from outside staging.**
- **Content ledger:**
  - Bare Vessel: two-clocks, dry-well, slow-thunder.
  - Rot Deepens and Corpse-Wax Coating: two-clocks, unkillable.
  - Tolled Seal: curse-engine, home-fortress.
- **By-root missing pieces (eleven):** Fuel for the Fire, Embers Feed the Hearth, Eruption, Frost Tithe, Mother Lode, Rain on Both, Sap Rises, The Spring Never Fails, Hot Spring Array, Breath Between Blows, element-tagged companions.

**Used by one build only.**
- 259 rows. Arts and công pháp are single-use by nature: each is one build's kit. All nine enablers are single-use.
- Several single-use pieces are library-shaped already: they fit today and name second homes.
  - **The L2 "more"-by-tag family, 14 rows, three already shared.**
    - By type: Banked Coals [burn], Cold Depths [cold], Kiln Heat [fire], Lingering Fume [chaos], Heavy Sky [lightning], Cold Iron Order [kim], Ore Weight [physical].
    - By source or form: Worn Knuckles [basic], Fang and Claw [companion], Laid Stone [formation], Needle's Eye [pierce].
    - By derived tag: Whole Weight [costly, slow], Light Chaff [quick, cheap], Long Fuse [slow, cheap].
  - **The "wound" conditionals:** Festering Wound (Chaos against your Poison) and Opened Seams (Physical against your Metal), beside the existing Kindled Wound.
  - **Affix rows on existing keys:** Soul-Piercing, Spring Returns, Kindred Vessels, Realm-Piercing, Smelting, Gale.

**The run's main pattern is Overflow.** 7 of the 15 identity pieces, and 13 Effects in all, spend what a cap or a full pool throws away. Examples: Ash Ledger, Stored Breath, Thunderhead, Overbuilt Walls, Straining Leash, Slipstream, Surplus Life. They lean on the readables in suggestion 2 and on "overflow is read whole" in suggestion 5.

## 4. Balance flags

**What the builds were measured against.**
- Combat Formulas B's top-end defence anchors are marked "re-derive" since #44.
- Every "top-end foe" in these paper models is the sheet's own first guess.
- So every number below is provisional.

**Fight length.**
- The paper models end same-realm top-end duels at Nguyên Anh in 0.5–8 s:
  - first-volley 0.5 s
  - bare-fist 1.33–2.0 s
  - curse-engine 1.5 s
  - dry-well 2.0 s
  - soul-lance 4.0 s
  - two-clocks ≈ 8 s
- Typical foes die in 0.5–4 s.
- #44's target is 30–60 s same-realm fights. Only unkillable lives in that range (≈ 25 s against a typical foe, ≈ 72 s at fatigue).

**Above the anchors.** The sheets marked these INFO and did not pull them back.

| Build | Against the anchor |
|---|---|
| first-volley | M 228 with crit at both caps: effective 457 against 384. Kills top-end foes, also one and two realms up, at 0.5 s (old-model proxy) |
| armoury-mind | ×271 against 256; ×396 against 325 at Hóa Thần |
| cooldown-floor | M 89 per hit, but ≈ 21 coefficient a second: above every anchor in rate |
| one-art | ≈ 1,270 per firing against ≈ 520 for the anchor's mean art at Hóa Thần. No anchor gives a rate |
| curse-engine | M 136 on paper, but strips 650 resistance points: beats the top-end profile at both realms |
| home-fortress | Ward strength 407 at home against ≈ 165: fight power above top-end in fights it chooses |
| slow-thunder | M 266 once the foe is dry, against 256 |
| beast-carry | M 203 × Fire buff 2.4–3.1 × 4 bites a second: at or above top-end if Fire buff sits outside M |
| giant-killer, upward | 243 against 200 one realm up. Against a top-end foe one up: 25–40 % (generic ≈ 1 %). Against a typical foe two up: ≥ 80 % (generic 54 %) |
| unkillable | Sustain likely above the top-end anchor |
| two-clocks | The sheet notes its kill times are top-end-fast |

**Below the anchors.** By design unless noted.
- bare-fist before Nguyên Anh: 0.24 of top-end damage at Kết Đan.
- unkillable's damage: M 6.8 against the typical 8.96 at Hóa Thần.
- giant-killer against equals: 0.3 of top-end.
- Blind fights, with L4 empty: first-volley M 91, home-fortress 88 (against 102), triple-convert 111, beast-carry 136.
- dry-well's L2 sits 80 points under its cap, because no fifth Cold L2 source exists. This one is not by design.

**At the anchor.** triple-convert (M 255 against 256). soul-lance sits at the soul channel's ceiling, 0.30 a second, not above it.

**Combat rule 18's boss target missed.** Rule 18 wants a boss to last at least 4 s against a top-end build.
- dry-well kills a ×4 boss in ≈ 3 s.
- first-volley kills a ×10 boss with ordinary damage in 1.5–2 s.

**Cap hits.** Where noted, an Overflow piece spends the surplus.

| Cap | Builds |
|---|---|
| L2 300 | first-volley, bare-fist, beast-carry, triple-convert (Third Smelting), one-art; slow-thunder 290 |
| L3 250 | first-volley, bare-fist, armoury-mind (150 clipped → Edge Past the Rack) |
| L4 150 | first-volley, dry-well, bare-fist, curse-engine, home-fortress (≈ 160 clipped → Overbuilt Walls) |
| L5 100 | two-clocks (after the first bell), dry-well (exactly), giant-killer (Against the Heavens); curse-engine 96 |
| Crit 50 % and ×3.0 | first-volley, slow-thunder |
| `cooldown_min` 0.5 s | first-volley, cooldown-floor, beast-carry, dry-well, curse-engine |
| `trig_cap` 6 | one-art (7th ring dropped at Hóa Thần), cooldown-floor, armoury-mind |
| `soul_cap` 0.30 and the lockout | soul-lance (every hit against typical and strong foes) |
| `c_comp_cap` 1.0 | beast-carry (surplus → Straining Leash) |
| `pierce_cap` 0.75 | giant-killer (surplus → Through the Ceiling) |
| Art cost −50 % | cooldown-floor |
| Stack charge 0.6 | two-clocks, beast-carry, giant-killer |
| Driven Nail, 3 a pulse | curse-engine (the cap that binds in its paper model) |
| Conversions per hit, 2 | triple-convert |

**Checks FAILED:** none in all 15 sheets.

**Checks NOT ASSESSED:** 33, matching the driver table.

| Check | Count | Builds | Why |
|---|---|---|---|
| The fight | 15 | all | Last nine: user decision, no simulator. First six: `fight_calc.py` out of date |
| Identity test (inside Stack) | 12 | two-clocks, dry-well, curse-engine, and the last nine | `fight_calc.py` cannot express the identity piece (first three); no simulator (last nine) |
| Budgets | 5 | two-clocks, soul-lance, dry-well, curse-engine, bare-fist | No thần thức budget figure; technique passives outside `bonus_pool`; no soul-art lint; curses priced at 0 |
| Scaling | 1 | two-clocks | Top-end anchors marked "re-derive" |

Smaller parts inside PASS checks were also not assessed:
- thần thức load: first-volley, beast-carry, triple-convert, cooldown-floor, slow-thunder;
- technique passives: triple-convert, armoury-mind, cooldown-floor, giant-killer.

**Tooling drift the builds ran into.**
- `fight_calc.py` drifts on 31 of 60 constants, and still models `dot_pulse_cap` and `dot_pool_cap`.
- The design-build skill's `combat-model.md` still lists `regen_cap`, `dot_pool_cap` and `dot_pulse_cap` as live limits (noted in `_driver/unkillable-try1.md`).
- Two seeds were written against those retired caps: two-clocks (`dot_pulse_cap`) and unkillable (`regen_cap`).

## 5. Decisions for the user

1. **Re-derive Combat Formulas B's top-end anchors before judging any build.** Include suggestion 17's check of the gear anchor against the slot limit.
   *Recommend:* yes, first. Until then, leave every "above the anchor" INFO alone: hold the macro targets, don't chase outliers.
2. **Fight length.** Min-max duels end in 0.5–8 s against a 30–60 s target.
   *Recommend:* keep 30–60 s as the target for typical mirrors, and accept short top-end duels. After decision 1, check the rule 18 boss target (dry-well ≈ 3 s, first-volley 1.5–2 s).
3. **Adopt the low-risk batch:** record fields (suggestion 1), readables (2), clarifications (5), and the thần thức and soul table (3).
   *Recommend:* yes. Do it in session, section by section, with you approving each.
4. **Close the art-lint holes (suggestion 4).**
   *Recommend:* yes, now. Take the 2-pulse minimum batch, and re-lint the eight staged curse arts.
5. **Which lint- and cap-breaking rules to allow.**
   *Recommend:*
   - Allow: `art_coef_add` (two capped Effect sources), `basic_coef_add`, the dampened art cost (Effect-only), trigger limit +1 (rare, one per source), one more curse slot (one keystone), Cold Toll (one keystone), L5 on ticks (one enabler).
   - Defer: the Fourth Smelting and linh lực debt.
6. **Opening haste.**
   *Recommend:* adopt, kept off tree smalls, and added to the NPC generator's top-end roll.
7. **Half a Realm and fighting upward.**
   *Recommend:* adopt "gap readers stop at two" now. Hold Half a Realm until the tribulation fights exist, because it changes breakthrough odds.
8. **Fire buff's layer.**
   *Recommend:* a factor outside M on all direct damage, with companion hits counting.
9. **Do granted element stacks roll status chance?**
   *Recommend:* no roll. Cleansing is the answer, as #44 decided.
10. **What to promote from staging into the library.**
    *Recommend:* first the shared and library-shaped rows: Nine Rods Array, Iron-Sand Hand Bath, the 14-row L2-by-tag family, the affix rows, Quiet Channels, the wound conditionals and Opening Haste. Keep the 259 single-use rows with their builds until a second build reuses one.
11. **The 23 parked builds in `queue-later.json`.**
    *Recommend:* run them after decisions 1, 3 and 4 land, so they build on settled rules. Start with the five starter builds (starter-flame, -wall, -venom, -blade, -tide): every build so far is top-end, so the catalogue has no starter or typical build.
12. **Tooling.**
    *Recommend:* in the design-build skill, mark `fight_calc.py` as pre-#44 and remove the retired caps from `combat-model.md`, so later sessions stop spending time on them. Leave the four unrun paper scripts parked while the simulator stays off. Fix the missing "Realm by realm" heading in `soul-lance.md`.
