# World depth: the user's rulings (2026-11-25, walked group by group)

Each ruling is the user's answer to a question with a recommendation. "Approved" means approved to become a GDD
amendment, which a later session writes section by section with the user.

## Group 1: rules R1-R8 (`rules-proposals.md`)

- **R1 roots follow the land:** approved as written (k_land 1.0, factor 0.25-3, variant odds up to x5).
- **R2 admission:** approved with the convergence fix: core ranks of a convergence-variant lineage (Thunder, Darkness,
  Chaos) need the main method's element **or** the variant.
- **R3 no-lean sects:** approved, all 11 minor sects as written.
- **R4 seats on fitting land:** approved as written (5 great sect moves, minor re-leans and moves; Cửu Cao fails by
  design as a Wind lineage).
- **Environment conditions** (ground, terrain, biome, weather, place) in fight rules: removed (user, 2026-11-25:
  "this is stupid, remove conditions like this"); sweep run over techniques, items, sets and wishlists.
- **R5 lineages:** approved; the 178 proposed techniques go to the catalogue pass to be priced and linted.
- **R6 traits v2:** approved, all three parts (more kinds, bigger rows, opens + likes/dislikes).
- **R7 signature items and sets:** approved; items stay unpriced proposals until the item pass (item lint to repair).
- **R8 cast scale:** keep ~1,900 authored people; the random fill supplies the rest below (mostly Luyện Khí).

## Group 2: seats and history

- **Seat density:** founder's arrays: each moved sect gets a `seat_array_density` bonus sized to bring its new seat near
  the old density, written into its history; breaking the array is a hook.
- **Phượng Minh's seat in Phần Vũ's province:** the lord takes the province (it becomes Phượng Minh's seat province);
  Phần Vũ keeps its seat inside it as a vassal.
- **Chronicle rewordings** (C007, A190, sóc khí text, Thiết Mã tally split, Cô Hạc's maker, A188 distance, A087 via
  N-thien_xu-04): approved, applied at re-export.
- **New events** (N-<sect>-NN, ~150): added to the chronicle and annals at export, by kind.

## Group 3: rule tensions

- **Fire births (R1 amendment):** a birth reads its **province's land qi** (the whole province, wild land included), not
  the village tile alone. Fixes Fire and any element whose strong land is uninhabited.
- **Variant land (R1b amendment):** on variant land, R1 also raises the variant's required elements (Thunder land
  tilts Fire and Metal; Darkness tilts Earth and Water; Ice tilts Water; Light tilts Fire), so the variant can form.
- **Wind sects (R4 amendment):** innate variants (Wind) are exempt from the seat test; a Wind sect's seat is tested
  only on its base-element leans, and it recruits by the variant wherever it is born.
- **Master rule:** kept (a master is of a higher realm); Trúc Cơ-headed minor sects stay small.

## Group 4: smaller calls

- **Luyện Khí sets:** keep 2-piece sets; the person wears one piece, and the set bonus switches on when they reach Trúc
  Cơ and gain a slot (a growth goal).
- **Stone-burning arts:** no; drop rb-30 (coin darts). Stones burn only as formation, crafting and abode fuel.
- **The four replaced technique ids:** keep the lineage methods (the `changed` notes stand).
- **Wishes that add Đạo Đồ nodes:** **not on the tree.** The tree stays as it is; those wishes are re-homed onto items,
  sets and techniques (lineage passives and arts). ACTION: re-home them in `builds/wishlist.md`.

## Group 5: traits v2

- **v1 fate gifts:** talent tiers replace the plain gifts (v1 gifts map to a tier, e.g. Wise-born = Quick-minded 3);
  v1 fates that are stories stay (Demon-seeded, Spirit-eyed, Pure-hearted).
- **v1 personality rows:** doubled (Brave +4 % health / −1.6 % evade).
- **First consumer of `opens`:** dialogue verbs (NPC Interaction & Dialogue #30).

## Group 6: after the terrain sweep

- **Time and season conditions in fight rules:** removed like terrain (autumn-grave-canon, dm-cave-orchid-pendant,
  td-moon-lake-mirror, Thu Phần "weak in spring", armillary-array-canon "the hour it was cast").
- **Timing in cultivation methods:** time-of-day rules (dusk / night / dawn) become flavour; season-paced rules may
  stay (seasons are turns).
- **Place-gated cultivation** (Emerald Haze, Sunset Cloud): gates removed; the existing land-match cultivation speed
  carries the stories.
- **Vụ Ẩn's mist counter** ("a foe's Wind art lifts its mist"): kept, logged as an Effect wish.

## Group 7: the wishlist

- **Author next, all four:** duel readings; Modifier scopes on items and lineage techniques; the lineage Effects; the
  missing techniques and arts.
- **How:** proposals now, into `design/world/depth/` (wired onto the items, sets and techniques that need them),
  unpriced; the user reviews once later.

## Group 8: after the authoring

- **Caps inside pieces** (30 % store, 5 Debts, 3 wards, 10 momentum...): removed; where a piece would run away, it
  gets a closing cost or a decay instead (memory: scale without caps).
- **Engine features some Effects need** (delayed damage, timer-delay immunity, tick-to-heal, foe clock stop, mist tag,
  Charmed/Sleep holding the caster's arts): keep the Effects; list the features for the combat port
  (`builds/engine-wishes.md`).
- **Wires into shared catalogues:** apply the `song` and `bow` tags to the library arts (`design/arts/`); skip the two
  lineage lines on shared catalogue methods and put them on the lineages' own methods instead.
- **The crane king:** author as a named spirit beast record bonded to its rider (proposal).

## Group 9: duel readings (`builds/duel-readings.md` § 4)

- **Broken:** the foe's first drop below **25 %** health, once a fight.
- **Still ends on** a damaging or movement art, an evade or a Displace; wards, heals and the basic attack do not.
- **Displace:** a timer delay (0.3 s, heavy 0.5 s) plus Displaced for 2 s; **Planted** is a new immunity. No positions.
- **Allies:** you, your companions and your Pieces; companions take strike payloads at half, body payloads go to you,
  Pieces count but receive nothing.
- **Alone:** you have no companion and no Piece of your own.

## Group 10: GDD amendment, Linh Căn (R1), measured on the real map

- **Baseline:** each element against its own **world mean** (population-weighted over settlement provinces):
  factor = clamp(1 + k (s_e − s̄_e) / s̄_e, 0.25, 3). Keeps every element at ~37 % of people world-wide (flat 20 % would
  make Wood 51 %, Fire 31 %, Metal 30 %) while each element gets home regions (40 Fire-rich provinces at 1.5+).
- **Variant read:** the province's **strongest tile** of that variant's qi (province means dilute it to ~2.5).
- **Player's Fated birth** reads the starting origin's province; Self-made is unaffected.

## Group 11: open questions from the GDD amendments

- **World floor:** raised from 3,000 to **5,000** cultivators (the authored cast needs 4,947). World Generation OQ 8;
  memory difficulty-targets to update.
- **Place tags in fights:** keep **tribulation** (a kind of fight, not a place); **remove `own_abode` and `vein`**
  bonuses (or move them to what is built, e.g. the abode's arrays). Combat OQ 30.
- **Set growth goal:** binds the **cast and NPCs only**; the player's slots follow Item DB rule 11. Item DB OQ 26.
- **New chronicle events:** the kind-to-tier mapping is accepted (264 events). World Generation OQ 9.
- **Trait details:** all seven accepted (Frail tier 1, Dull-witted tier 3; Empty-souled; like +5 / dislike −10;
  callings not doubled; health ≤ 2; three opposed path pairs; ordinary person ≤ 6 traits at creation). NPC Traits OQs.
ACTION after the finishing pass: apply these to world-generation.md (floor), combat.md / effects.md / modifiers.md
(place tags), item-database.md OQ 26, world-generation.md OQ 9, npc-traits.md OQs (mark answered).

## Group 12: the remaining open questions

- **Founder's arrays:** re-size by Formula G: Băng Tâm +0.75, Lạc Hà +0.5 (World Gen OQ 11).
- **Hidden events:** a `hidden` chronicle kind: kept out of the public chronicle and annals until the player uncovers
  them (event or Codex); the four kindless secrets get it (World Gen OQ 9).
- **Data floor:** change `world_generation.json` `world_cultivators_min` to 5000 now and run the world tests.
- **Talent grade display:** show the effective grade with the base beside it (NPC Traits OQ 16).
- **v2 choice weights:** behaviour-shaping v2 traits get choice-tag weights (paths such as Demonic and Buddha's path,
  coping traits, Duel-seeker, Gambler...); talents and health stay stat-only (NPC Traits OQ 18).
- **Trait bands:** tier A widened to 6-12; people above 12, and tier B/C over-band people, are trimmed at export (drop
  the weakest-fitting extras) (NPC Traits OQ 14).
- **Trait rows:** Hunter → `attack_pct` scoped to the foe tag `creature`; One-element devotee → `attack_pct` scoped to
  the holder's own top element (NPC Traits OQ 12, 22).
- **formations.md back-links:** add them (a Dependencies note only, no rule changes).

## Group 13: content review fixes (`review/RANKED.md`)

- Fix all four before implementation: A (the mechanical sweep), the Phất Y IP rewrite, B (break the repeated story
  shapes), C (depth and tone).
