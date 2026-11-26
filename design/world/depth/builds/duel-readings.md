# Duel readings (Đấu Giải): proposal

> **Superseded 2026-11-26** (user: no spatial fight; fights of several fighters postponed;
> `design/world/depth/DECISIONS-2026-11-26.md`). Combat rule 25 and Formulas L now hold the readings: Still and Moving
> are **Composed** and **Pressing**, "the foe moved" is **the foe pressed**, and At range, Displace, Planted, Rooted,
> Pinned, field Pieces, spreads, allies and Alone are gone or postponed. Read this file as history only.

> **Status**: proposal for the user's review (authoring approved 2026-11-25). Nothing here is added to
> `design/gdd/combat.md`, `effects.md`, `modifiers.md` or the depth JSON yet.
> **Wish**: a1 in `wishlist.md` (`ra-G1 + rb-01 + sets-bt-01 + sets-bt-04`), about 54 builds.
> **Rule for every reading** (user ruling 2026-11-25): it reads the two fighters' own state only (pools, timers,
> statuses, stances, companions, the fight's own clock, the side's own preparation). Never terrain, ground, weather,
> world time, season or place.

## The engine facts the readings rest on

- **A side is one fighter plus companions** (Combat rule 1). A side with a second cultivator is not supported
  (Open Question 27).
- **Companions cannot be targeted and never leave the fight** except by their owner's defeat (Combat rule 19). They
  have no health, linh lực or wards. A companion is a power share that hits every `basic_cooldown` (Formulas J). So
  "a foe's companion falls" never happens, and only strike payloads mean anything to a companion.
- **Arts fire on their own timers. There is no cast time and no choice in the fight** (Combat rule 13). The basic
  attack always runs (1 s). So "interrupt" can only mean a timer delay, and "casts nothing" is either a gap between
  cooldowns or a stance that holds arts back.
- **Delays already exist.** Effects rule 6, "Move a timer", has a falloff (each further delay on the same target
  within 3 s moves half as much) and the foe's `timer_resist_pct`. The precedent is Gripping Root (0.5 s, once per
  2 s).
- **Stances already exist** as R29 states (Effects rule 16). A state swaps a modifier set and tags, guards may read
  it, and it may suppress named arts.
- **"On a kill" has no in-fight moment.** The knockout ends the fight. The pool-crossing event (Combat rule 9) is the
  in-fight hook. Payoffs that outlive the fight use the knockout event and are reported (Effects rule 10).

---

## 1. The reading table

One reading per family, written once. A **capitalised word** in the readings (Still, Moving, Displaced and so on)
is the engine term, and content is reworded to use it (section 3).

| # | Family: the words as authored | The reading: what the engine checks | Example from the content |
|---|---|---|---|
| R1 | **Ally**: ally, allies, you and your allies, filemate, the file, every ally in the fight, the ally lowest on health, the most wounded ally, an ally beside you | **Your side**: you plus each of your companions, plus each **Piece** you have up (R4). **Allies counted** = 1 (you) + companions + Pieces. **Body payloads** (heal, ward, shield, linh lực, cleanse, damage taken, evade) land on **you, once**. "You and your allies heal 8 %" heals you 8 %, and "the ally lowest on health" is you. A body payload meant only for *another* ally does nothing, so that content needs a fix. **Strike payloads** (damage, art speed, fury stacks, "strikes once") go to you in full and to each companion at **half**, through the `[companion]` scope. Pieces receive nothing. | Coming Home at Dusk (`lac_ha` evening-song-of-the-boats): "allies nearby regain 2 % of their linh lực each second" means you regain 2 %. |
| R2 | **Alone**: no ally near, fights alone | **Allies counted = 1**: no companion and no Piece. This is a real condition, false for any build with a beast or a planted piece. It is *not* always on (correcting a1's note). | Bare Winter (`ngao_tuyet` lone-branch-sword): on for a companion-less sword build. |
| R3 | **The foe, wherever it stands**: every foe, all foes, foes near you, in reach, in hearing, nearest foe, foes inside / under the field, foes who enter it | **The foe**: the other side's fighter. Its companions are untargetable, so every foe payload lands on the foe once. "Foes who enter it" means the foe, once, when the field rises. **Spread** ("spreads to a nearby foe", "passes to the nearest foe") means it lands again on the same foe, once, at half strength. | Who Is Afraid (`xuyen_lam` calm-wind-staff-canon): "hits every foe in reach" hits the foe. |
| R4 | **Field and Piece**: a cloud, rain, haze, mist, glow, ring, lantern light, a song held (Field); a stele, flag, bell, banner, lantern, lantern-stone, lamp, seal or ward laid on the ground (Piece); "inside your own formation / array", "the centre of your array" | A **Field** is a timed self-state of your side (an R29 state tagged `field`). While it is up, you and your allies are "in it" and the foe is "inside / under it". A **Piece** is a counted charge on your side (an R7 self-counter tagged `piece`), each with its own duration. A Piece is gone when its duration ends, or after the number of foe hits it is written to absorb ("burns out after a set number of blows"). **Your own formation / array** means an array Field of yours is up, or your combat diagram is laid (Formations rule 9). | Plant the Stele (`thien_xu` boundary-stele-array-canon): three steles are three Pieces, and each gives you a small ward. |
| R5 | **A foe who moves**: moves, crosses, enters, dodges, steps toward you, crosses between two bells or the line | **The foe acts**: it fires a damaging or movement art (not its basic attack, a ward or a heal), or evades one of your hits. This is the same test that ends Still (R6). "While it moves" = within **1 s** of such an act. "Each second a foe moves" = each pulse in which the foe acted. "Crosses between two Pieces / the line" = the foe acts while two or more of your Pieces stand. "Crosses one" = it acts while one stands, and that Piece is spent. | Eighth-Month Snow (`le_hoa` pear-blossom-snow-sword): the foe gains an Ice stack for each second in which it fired an art. |
| R6 | **Still**: stand still, do not move, has not moved for N s, casts nothing, sitting or standing stance, stays on one spot | **Still** = you are in a still stance (an R29 state tagged `still`), **or** 2 s have passed since you last fired an art with a damage part, evaded, or used a movement art. Wards, heals and the basic attack do not break it. **Still ends** when you fire a damaging or movement art, when you evade, or when you are **Displaced** (R8), which also blocks it from restarting for 2 s. "After N s Still" and "each second you do not move" read seconds Still. **Held stances** ("casts nothing") suppress your damaging arts (R29) until a **written release condition**: a ward reaching X % of your health, N s held, or the foe reaching N stacks. The same test applies to the foe: "a foe who stands still for 3 s" = the foe Still for 3 s. | The Pivot Does Not Turn (`thien_xu` heavenly-pivot-true-canon): it lays Earth while you are Still, and being Displaced ends it. |
| R7 | **Moving (you)**: keep moving, a walking or riding stance, each step, stopping | **Moving** = a footwork stance is up (an R29 state tagged `footwork`), or within 1 s after you evade or fire a movement art (tag `movement`). Moving and Still never hold together. "Each second you keep moving" = each pulse Moving. **Stopping** = you become Displaced or Rooted, or the footwork stance ends. "Each step toward a foe" = each pulse Moving in which you fired no damaging art (rb-01). | The Long Ride (`muc_van` cloud-herd-body-canon): one momentum per pulse Moving, and half is lost when Displaced. |
| R8 | **Displace**: knock back, push, pull, drag, haul, reel in, sweep, pushed a step, off balance, knocked away | **Displace** = the target's art with the least time left is delayed **0.3 s** (**0.5 s** heavy), through the existing Move-a-timer action (falloff and `timer_resist_pct` apply). The target is also **Displaced** for 2 s: it is not Still and cannot become Still, it stops Moving, and a stance that bills a "step out of the centre" pays its written price. A **pull, drag or haul** also ends the target's At range (R10). A **push away** gives the pusher At range for 1 s. Being pushed yourself (a price) makes you Displaced. | Counterweight Palm (`thien_xu` weighing-stone-primer): "pushed off balance and their next art is a little slower" is a Displace. |
| R9 | **Planted**: cannot be moved, cannot be pushed or knocked back, take root (yourself), resist being pushed | **Planted** = immune to Displace. Neither the delay nor Displaced applies, and the log writes "Planted: refused". "Moved one step aside" as flavour on your own defence (a slip, a sidestep) is not a Displace. It is named **Planted (Trụ)**, not "Unmoved", because the Effect Unmoved Stance (Bất Động Thế) already exists with another meaning. "Take root" on yourself = Planted, not Moving, evade 0 for the time (the price). | Heavy Keel (`market-folk` mf-sea-crossing-anchor): "while you stand still you cannot be knocked back" = Planted while Still. |
| R10 | **Rooted, Pinned**: rooted N s, rooted for a moment / a breath, bound, pinned, hooked, cannot leave the line | **Rooted** (a status lasting N s on the millisecond timeline, like the delays; "a moment" or "a breath" = 1 s): the foe's evade counts as 0, it is not Moving, and when Rooted lands its art with the least time left is delayed N/2 s (same action, same falloff). **Pinned / hooked** = Rooted, and while it holds, the foe's escape channel cannot succeed. | No Hiding on the Quay (`thuy_vi` tv-cold-ford-watch): a Rooted foe has evade 0, so "loses its evasion" is the status itself. |
| R11 | **At range**: at range, at distance, from afar, ten paces away, before the foe closes, out of reach, closes or crosses the distance, at arm's length | **At range** = the fight's first **3 s**, plus 1 s after you evade, fire a movement art or push the foe away. A pull or drag on you ends it. "Closes / crosses the distance" = the art spends your At range (it ends). "Close range, arm's length" = not At range. | Ten Paces, One Cut (`phat_y` py-ten-paces): the bonus applies while At range, and the cut ends it. |
| R12 | **Broken (on a kill)**: on a kill, if it kills, after you kill a foe, a strike that kills, when the foe dies | **Broken** = the first time this fight the foe's health crosses **25 %** or below (the existing pool-crossing event). It fires once per fight per Effect. "If it kills" = this art's hit is the one that crosses. A payoff that outlives the fight (cultivation base, heart demon) keeps the knockout event and is reported. "A blow that would kill you" is the Down step and already works: no reading needed. | Wine in the Night-Glow Cup (`da_quang` night-glow-blood-sabre-canon): it heals and frees the next art when the foe is Broken. |
| R13 | **Wounded (an ally falls)**: when an ally falls, sung over a fallen ally, each ally who falls, a foe or ally dies | **Wounded** = the first time this fight **your** health crosses 25 % or below. It is Broken's mirror, and the same event. "An ally *would* fall / be killed" = your Down step (existing refusal rules). | The Ninth Verse (`lac_ha` evening-song-of-the-boats): it fires on your first Wounded. |
| R14 | **The point of the file**: the ally nearest the foe, at the front, draws the foe's attacks, the ally behind you, foes cannot reach the allies behind, blows aimed at an ally | **You are always the point.** Every foe hit lands on you, so a condition "while you are nearest the foe" is always true, and "draws the foe's attacks" adds nothing: keep the payload, drop the condition. A body payload for "the ally behind you" goes to you (R1). "Blows aimed at an ally" waits for a4 Protect a charge (Bảo Tiêu). Until then it reads as "foe hits on you while the stance holds". | Take the Wind (`nhan_tran` nt-point-of-file): it is always on. |

**Also seen, read the same way (no new state):**
- "Stunned N s", "cannot act / cannot target the player with an art for N s": the foe's arts that come ready within
  N s wait until the N s end (Move a timer, falloff applies).
- "Slowed", "casts more slowly": Slowed Time stacks.
- "Silenced for a moment": the Silence curse.

**Not covered here:**
- "Unseen", "ambush", "concealment", "the next hit is foreseen" belong to a3 Forewarned (Tiên Giác) and the
  foreseen / ambush / blind situations (Combat rule 12).
- One place condition survived the 2026-11-25 sweep (section 3, last table).

---

## 2. Hooks per family

**Existing** cites the rule that already carries it. **New** says what kind of addition it is: a rule 5 readable
(with its read time), a rule 6 action, a catalogue status, a tag or a stat key. R20 holds throughout: a window
starting is not an event, so every "while" reading below is a conditional read at instant start.

| Family | Existing | New |
|---|---|---|
| R1 Ally | Companions one per source (Combat rule 19, R31). The `[companion]` scope on damage and speed Modifiers (`companion_power_pct`, `companion_speed_pct`, Bare Rack's `[companion]` L5). The compile read "the pieces you control (count and roles)" (Effects rule 5). | **Readable** `allies` (live, instant start) = 1 + companions + Pieces up. **Rule** (a clarification in Effects rule 5): the body and strike payload routing, with companions taking a strike payload at `companion_share` (0.5). |
| R2 Alone | Nothing beyond R1. | Reads `allies` = 1. |
| R3 The foe | The art record and its single target. | **Rule**: a spread re-lands on the same foe once at half. **Lint note** for the catalogue pass: an art written for "every foe" is worth one target. |
| R4 Field, Piece | R29 states (Effects rule 16). R7 self-counters with a decay "on an event" (Effects rule 8). The laid diagram (Formations rule 9; Effects rule 5 "your formation's level"). | **Tags** `field` (on states) and `piece` (on self-counters). **Self-counter extension**: each Piece has its own timer and its own "blows" count, worn by foe hits that land. **Readable** `pieces` (live), `field_up` (instant start), `diagram_laid` (compile). |
| R5 A foe who moves | The events "an art fired" and "an evade", and the live readable "the enemy's firings this fight" (Effects rule 5). | **Readable** `since_act` per side (live): seconds since that side last fired a damaging or movement art, or evaded. The foe is acting while `since_act` < `act_window` (1 s). |
| R6 Still | R29 states, guards reading a state, and a state suppressing named arts. | **Tag** `still` on states. **Readable** `still_time` per side (live): seconds Still since Still last began, or 0. **Combat rule** (one definition beside rule 13): what makes and ends Still, `still_after` 2 s, and the held-stance release condition, required by the art lint. |
| R7 Moving | R29 states. Evade events. | **Tags** `footwork` (states) and `movement` (arts; the escape art also counts). **Readable** `moving` (live). |
| R8 Displace | **Action** Move a timer (Effects rule 6), with its falloff and `timer_resist_pct` (Modifier stat list). Gripping Root as the number precedent. | **Status** Displaced (catalogue; not a curse, so it takes no curse slot), tag `displace`, 2 s. Like Rooted it runs in seconds, not pulses, because content writes "rooted 1.5 s" and "for half a second". **Tag** `heavy` on a Displace (0.5 s instead of 0.3 s). |
| R9 Planted | Nothing fits. R28's immunities cover curses that name a tag, and they are major or capstone only, but Displaced is not a curse and the delay is an action. | **New immunity**: "Planted" refuses any action or status tagged `displace`, open at every tier, because a Displace is worth a 0.3 s delay. It is a flag a state or a conditional Effect sets. |
| R10 Rooted, Pinned | Move a timer for the N/2 s delay. Evade (Combat Formulas I). | **Status** Rooted (catalogue, not a curse, in seconds), tags `rooted`, and the payload "evade counts as 0". Under R21 the foe's evade can only change through a status, so Rooted must be one. **Combat rule** (rule 10, Escape): a Pinned side's escape channel fails while Pinned holds. |
| R11 At range | Fight time (Effects rule 5), read at instant start. | **Readable** `at_range` per side (instant start). **Knob** `range_open` (3 s). |
| R12 Broken | The pool-crossing event (Combat rule 9). The knockout event for payoffs after the fight. | **Knob** `broken_threshold` (0.25) and a once-per-fight latch. **Flag, not a reprice**: `linh_luc_on_kill_pct` ("worth little in a duel", Modifier stat list) would fire once, on Broken. |
| R13 Wounded | The same event on your own pool. The Down step (Effects rule 11). | None beyond R12's knob. |
| R14 The point | Every foe hit targets you (Combat rule 19). | None. a4 Protect a charge is the later home of "aimed at an ally". |

**Tuning knobs**, for `combat_rules.json` when adopted:

| Knob | Value | Safe range | What it moves |
|---|---|---|---|
| `still_after` | 2 s | 1–3 s | How often a fast build is Still between casts |
| `act_window` | 1 s | 0.5–2 s | How long a foe counts as "moving" after an art |
| `displace_delay` | 0.3 s (0.5 s heavy) | 0.2–0.5 s (0.3–0.8 s heavy) | What a push or pull is worth on the timeline |
| `displaced_time` | 2 s | 1–3 s | How long a push denies Still and breaks stances |
| `range_open` | 3 s | 2–5 s | The ranged builds' opening |
| `broken_threshold` | 0.25 | 0.15–0.30 | When "on a kill" pays (above the cull threshold, 8 %) |
| `companion_share` | 0.5 | 0.25–1.0 | Strike payloads given to companions |

---

## 3. Content fixes

The authored rules that should be reworded to use the readings. Nothing is edited here. The id is `item / rule` for
an item's rule, the set id plus the Effect's name for a set, and `technique › art` for an art. "(note)" marks a
clause that becomes always on, or does nothing, so the catalogue pass should know.

### 3a. Ally, Alone, the point (R1, R2, R13, R14)

| File | Id | Suggested wording |
|---|---|---|
| `people/loose-south.items.json` | `ls-thuy-khau-stern-lamp / no-fare` | "While you have a companion, you regain 1 % of your health each second." |
| `people/loose-south.items.json` | `ls-free-crossing` No One Drowns | "while you have a companion or are Still, your ward regains 2 % each second; …" (the rest unchanged) |
| `people/market-folk.items.json` | `mf-second-spring-needles / second-spring` | "Once a fight, while you are below a quarter of your health, the next poison batch or curse placed on you lands at half strength." |
| `people/market-folk.techniques.json` | `second-spring-needle-art › Draw the Poison` | "Halve one poison batch or one curse on you (its strength, or its time left)." (note: there is no other body to draw from) |
| `sects/bach_vu.techniques.json` | `roosting-branch-canon › Under the Wing` | "One bird shields you and takes your next hit (a decoy); the bird returns to the branch to heal." |
| `sects/binh_thuy.items.json` | `bth-slack-water` The Tenth Layer | "… and each heal it makes also gives you one Water buff stack; …" ("heals the nearest ally the same" heals you twice in a duel) |
| `sects/ho_lam.techniques.json` | `night-beside-the-tree › Bark Closes` | "Wraps you in bark for 4 s: you take 25 % less damage, heal a little each second and are Planted; your evade is 0 and you cannot be Moving." |
| `sects/lac_ha.items.json` | `lh-cold-geese-sword / geese-in-file` | "… While your One Colour field is up, each ally beyond yourself (companion or Piece) adds one blade (to 12), …" |
| `sects/lac_ha.items.json` | `lh-cloud-bridge-flags / span-the-gap` | "Plants two flag Pieces for 12 s; while both stand, you take 10 % less damage and gain a small ward every 3 s." |
| `sects/lac_ha.items.json` | `lh-off-the-field` Geese in the Cold | "While your One Colour field stands, you take 10 % less damage; the first time you are Wounded inside it, the Cold Geese Sword gains two blades for the rest of the fight." |
| `sects/lac_ha.techniques.json` | `evening-song-of-the-boats › The Ninth Verse` | "Fires once, when you are first Wounded: for 10 s you take 10 % less damage and are Planted, and the foe's delays on your arts do not apply. Once per fight." |
| `sects/lac_ha.techniques.json` | `long-sky-one-colour › Geese Startled by the Cold` | "While your field is up and you count three or more allies (you, companions, Pieces), you take 8 % less damage and your Earth stacks on the foe last 2 s longer." |
| `sects/le_tuyen.items.json` | `ltp-sweet-dew-needles / needle-of-mending` | "Your needle arts may be set, in the loadout, to heal you for the damage they would deal and clear one debuff stack instead of striking." |
| `sects/minh_loan.techniques.json` | `singing-luan-bell-canon › Ward Peal` | "One long note: a creature foe's soonest art waits 2 s (it flees); you gain a ward that grows with the Metal stacks on the foe." |
| `sects/muc_van.items.json` | `mv-cloud-herding-lance / turn-the-herd` | "When your companion's hit lands within 1 s of one of your art hits, the foe is Displaced and your companion's next hit deals 30 % more." |
| `sects/muc_van.items.json` | `mv-phu-dao-last` Ninety Thousand Li | "… spend them all on a gust: you are At range for 2 s and gain 20 % evasion for 4 s." |
| `sects/muc_van.techniques.json` | `cloud-herd-body-canon › Run With the Herd` | "A charge that spends momentum: your hit and your companion's next hit land together; the foe is Displaced (heavy) and takes Physical damage scaled by the stacks spent." |
| `sects/nam_pho.items.json` | `np-dusk-half` Roll Up the Western Rain | "When the foe is Broken, or sheds your Wood stacks (a cleanse or their end), each stack shed heals you 1 % of your health and removes one of your debuffs." |
| `sects/ngao_tuyet.items.json` | `ngt-plum-and-snow` Bare Branch Blooms | "While you fight alone (no companion, no Piece) and are below half health, …" (note: on for companion-less builds) |
| `sects/ngao_tuyet.techniques.json` | `lone-branch-sword › Bare Winter` | "While you fight alone (no companion, no Piece), your sword arts cost less linh lực and deal more damage." (note, as above) |
| `sects/nhan_tran.items.json` | `nt-first-file-banner / one-goose` | "While the banner is planted (a Piece) and you count three or more allies, the damage you take is multiplied by (1 − X) for each ally beyond yourself, and the banner's first share is yours." (the same "shared across the file" rule as Geese Stance) |
| `sects/nhan_tran.items.json` | `nt-out-of-the-grey` Last Man in the File | "While the Banner's spread holds, your hits taken are blocked as though you had raised the shield, and each blocked hit lets you shed one poison or miasma stack (once every 3 s)." |
| `sects/nhan_tran.items.json` | `nt-point-of-file` Take the Wind | "You take 10 % less damage, and each block you make gives you a small ward." (note: always on; you are always the point) |
| `sects/nhan_tran.techniques.json` | `wild-geese-formation-canon › Geese Stance` | "A stance: while at least two allies stand in your file (you count as one; companions and Pieces count), the damage you take is multiplied by (1 − X) for each ally beyond yourself, and you gain a small ward every 3 s the stance holds. Being Displaced breaks the line." |
| `sects/nhan_tran.techniques.json` | `wild-geese-formation-canon › Trading the Point` | "For 4 s you take 30 % less damage; then the stance ends and clears one curse from you." |
| `sects/nhan_tran.techniques.json` | `spring-levy-drum › Close the File` | "When you are first Wounded, or each time you are Displaced, the drum closes the gap: for 5 s you gain attack speed (your companions half) and take 10 % less damage." |
| `sects/nhan_tran.techniques.json` | `walking-out-of-the-grey › One Breath Down the File` | "For 8 s, the curse and debuff stacks on you are divided by your ally count (rounded down) and last 25 % shorter." |
| `sects/nhan_tran.techniques.json` | `walking-out-of-the-grey › The Rear Guard Faces Back` | "You step back: for 3 s you gain evasion and a ward, you are At range for 1 s, and you strike the foe once (a free hit)." |
| `sects/phat_y.techniques.json` | `dry-road-sword-primer › Noon Guard` | "A stance: each foe hit on you while it holds is partly turned onto your sword (less damage taken) and grants a stack of Heat that strengthens your next cut." (a4 Protect a charge gives it a client later) |
| `sects/thien_xu.items.json` | `tx-iron-horse` The Army That Waits | "… In a fight, once, the riders join you as a companion for 10 s; their first hit Displaces the foe (heavy). …" (the rest unchanged) |
| `sects/thien_xu.techniques.json` | `heavenly-pivot-true-canon › North Star Writ` | "For 8 s the foe is Named: your companions and Pieces deal more to it, and while it is above half health it takes Withering." |
| `sects/thien_xu.techniques.json` | `boundary-stele-array-canon › Plant the Stele` | "Plants a stele Piece for 12 s (up to three at once); each stele up gives you a small ward." |
| `sects/thu_phan.techniques.json` | `autumn-grave-canon › Add a Voice` | "The chorus gains a voice when the foe is Broken and when you are Wounded (max 8)." (d7 Voices from the Ground owns the rest of the chorus) |
| `sects/thuy_vi.items.json` | `tv-green-moss-mirror / light-on-the-moss` | "A quarter of the healing you receive is stored, and released on you the next time you fall below half health." (note: as written it reflects onto you, so it does nothing) |
| `sects/thuy_vi.items.json` | `tv-poria-under-pine` Nobody Falls | "Once a fight, a heal that lands on you while you are below a quarter of your health also gives you a Wood ward worth 10 % of your health." |
| `sects/tuan_tung.items.json` | `ttg-caravan-bell / ring-for-the-wardens` | "Ringing the bell: for 3 s you take 20 % less damage, and your companions' hits in that time deal 20 % more." |
| `sects/tuan_tung.techniques.json` | `pine-warden-staff-and-bow-canon › Wolf Ring` | "A full turn of the staff that strikes the foe and Displaces it (heavy)." |
| `sects/vu_an.techniques.json` | `mist-lock-array-canon › Lock the Road` | "Lays a mist field for 8 s: you gain evasion, the foe loses accuracy for each second of the field, and the foe's first art inside it misses (an avoid)." |
| `sects/vu_an.techniques.json` | `mist-lock-array-canon › Lantern-Stone` | "Plants a lantern-stone Piece: while it stands and you are Still, your mist field does not fade; it is worn by the foe's hits, and when it is gone the field ends." |
| `sects/nhan_van.techniques.json` | `living-scroll-art › Door Guardian` | "Unrolls a painted guardian for 10 s: a companion that strikes with Wood and takes the foe's hits as a decoy; after it has taken N hits it goes back into the scroll and cannot be called for 20 s." ("draws foes' attacks" and "when it falls" have no target to read) |

### 3b. The foe, spread, stun (R3)

| File | Id | Suggested wording |
|---|---|---|
| `sects/le_hoa.items.json` | `lh-bolt-ice-bell / toll-of-the-frozen-bolt` | "… the foe gains 2 Ice stacks, and its arts that come ready in the next 0.5 s wait until it ends …" |
| `sects/minh_loan.techniques.json` | `hanging-bells-array › Alarm Line` | "Rings all your bell Pieces at once: the foe gains 2 Earth stacks, and its arts that come ready in the next 0.5 s wait until it ends." |
| `sects/phuong_minh.items.json` | `pm-tieu-thieu-quan / eight-of-nine` | "… a foe with eight stacks holds its arts: those that come ready in the next 2 s wait until the 2 s end. …" (the story-only ninth movement unchanged) |
| `sects/thuy_vi.techniques.json` | `green-furnace-canon › Green Fire Eats Dead Wood` | "… if the foe is Broken while it burns, the burn is laid on it again at half strength." |
| `sects/van_hac.techniques.json` | `ten-thousand-ravines-zither-canon › Ten Thousand Ravines` | "The foe takes Force damage for each Resonance stack it carries; then half its stacks (rounded down) are laid on it again as a new batch." |
| `sects/lac_ha.techniques.json` | `long-sky-one-colour › One Colour` | "… your single-target Earth arts hit the foe again for 30 % of their damage while the field holds." ("every other foe in the field" is nobody) |
| `sects/thinh_vu.techniques.json` | `thunder-in-the-rain-canon › The Chain Carries It Down` | "… the next 2 s of Lightning hits on the foe chain once more onto it at half, if it carries a Metal stack; each chained hit deals more for each Metal stack." |
| `sects/ho_lam.techniques.json` | `raft-and-root-primer › Log on the Current` | "A heavy Wood hit that Displaces the foe; if a Water stack is on you, the hit carries on and strikes the foe again at half." |
| `sects/thinh_vu.techniques.json` | `opening-thunder-canon › Open the Sky` | Drop "The second cast falls on you if no foe is near": the foe is always near, so the clause never fires. Or tie the price to something real ("the second cast also strikes you while you are below half health"). |

### 3c. Field and Piece, foe moves (R4, R5)

| File | Id | Suggested wording |
|---|---|---|
| `sects/lac_ha.items.json` | `lh-cloud-bridge-works` Anchored Span | "While both your flags stand, each time the foe acts it gains 2 Earth stacks and one Slowed Time stack (once per 2 s); while you are Still, your array's upkeep costs no linh lực." |
| `sects/minh_loan.techniques.json` | `hanging-bells-array › Hang the Bells` | "Sets four bell Pieces for 10 s; each time the foe acts while two or more stand, it gains one Slowed Time stack and a Metal stack, and each such crossing makes the next one ring louder." |
| `sects/suong_tung.techniques.json` | `frost-pine-ward-canon › Laid Ward` | "Lays up to three ward Pieces; each time the foe acts, one is spent: the foe is Rooted for a moment and takes Wood damage." |
| `sects/thien_xu.techniques.json` | `boundary-stele-array-canon › No Crossing the Line` | "Lights the lines between your stele Pieces for 6 s: each time the foe acts while two or more steles stand, it gains one Slowed Time stack and three Earth stacks." |
| `sects/thien_xu.items.json` | `tx-square-and-compass / true-to-the-line` | "Your stele and anchor Pieces are not worn by foe hits, and last 3 s longer." |
| `sects/cung_tinh.items.json` | `ct-pole-star-court` The Field Turns | "While your array field is up and you are Still, every 4 s the foe gains one Earth stack and is Displaced. …" (the Mirror clause unchanged) |
| `sects/tung_dao.items.json` | `td-broken-ice-flags / crack-the-ice` | "While the flags stand, a foe that has been Still for 3 s is Rooted for 2 s and takes a Water stack each second." |
| `sects/minh_loan.items.json` | `ml-bridge-bells` Forty Answer | "Bells you hang with Hang the Bells answer your hand bell: each time the foe acts, every bell Piece you have up rings once, each a light Metal hit; at most once per second." |
| `sects/cung_tinh.techniques.json` | `star-pacing-primer › Seven Steps` | "Each of your next seven arts leaves a mark; on the seventh the marks join into a Field: on rising it gives the foe one Slowed Time stack, and you take less damage while it holds." |
| `people/market-folk.techniques.json` | `loom-of-letters-array › Walking Ward` | "Once a fight, your array Field's duration is refreshed." (moving a formation has nothing to move) |
| `people/market-folk.items.json` | `mf-loom-of-letters-seal / carried-array` | "A formation you have laid before in the same fight is laid again in half the time; once a fight, your array Field's duration is refreshed." |
| `sects/thinh_vu.techniques.json` | `lightning-rod-sword › Sword Raised to the Cloud` | "… after 1 s a bolt falls, dealing Lightning damage and a Thunder stack; if the foe acted in that second, the bolt misses and this art's next timer is 2 s longer." |

### 3d. Still, Moving, Displace, Planted (R6–R9)

| File | Id | Suggested wording |
|---|---|---|
| `sects/bang_tam.techniques.json` | `jade-vessel-ice-heart-canon › Heart in the Jade Vessel` | "A held stance: it holds your damaging arts while your frost ward grows each second; when the ward reaches X % of your health, the stance ends and releases it as Cold damage on the foe." (a release condition is required) |
| `sects/bang_tam.items.json` | `bt-glacier-vigil` The Peak Does Not Move | "While your diagram is laid and you are Still, your ward gains 3 % of its value each second, up to double. When the foe breaks it (a shield breaks), the foe gains 4 Ice stacks and is Rooted for 1 s." |
| `sects/bach_vu.techniques.json` | `hundred-call-breath › Still on the Branch` | "A still stance: while you are Still you gain evasion, and your next art's timer is 0.5 s shorter." ("lands first" has no meaning without turns) |
| `sects/thien_xu.techniques.json` | `heavenly-pivot-true-canon › The Pivot Does Not Turn` | "A still stance: while you are Still, the foe gains one Earth stack every 2 s, and your Metal arts deal more for each Earth stack on it. Being Displaced, or firing a movement art, ends the stance and clears half the stacks it laid." |
| `sects/cung_tinh.techniques.json` | `bowing-stars-canon › Fixed Pole` | "After 3 s Still, your Earth arts deal more damage and you are Planted, with more timer resistance; it resets when you stop being Still." |
| `sects/thien_xu.items.json` | `tx-archive-desk` The Door Stays Shut | "While you are Still, each seal art …; a foe whose name the inkstone has written three times holds its arts: those that come ready in the next 2 s wait until the 2 s end." |
| `sects/tung_dao.items.json` | `td-coiled-root-banner / roots-under-the-field` | "When the foe has been Still for 2 s, it is Rooted for 1 s; once every 10 s." |
| `sects/muc_van.techniques.json` | `cloud-herd-body-canon › The Long Ride` | "A footwork stance: each hit you land while Moving adds a momentum stack (no cap; stacks fade by a tenth each second you are not Moving); each stack raises Physical damage and body shield a little; being Displaced or Rooted loses half. (Wired as d20's hit clock; 2026-11-25 no-caps ruling.)" |
| `sects/phat_y.techniques.json` | `contract-sword-canon` (method concept) | "… In a fight, each second you are Moving and strike nothing serves a Term (Khoản 款), and each hit you take strikes one Term off. …" (fixB-apply: Final Count's pierce now at five Terms) |
| `people/clans.items.json` | `cl-locust-shade` He Waited | "for each 10 s you are Still, your wards gain 5 % strength (no cap; the bonus fades by a tenth each second after you act); your first damaging art after it is a sure hit. (2026-11-25 no-caps ruling.)" |
| `sects/bang_tam.items.json` | `bt-jade-vessel / ice-in-the-vessel` | "While you are Still, your frost ward regains 2 % of its value each second; …" |
| `sects/bang_tam.items.json` | `bt-fishers-heirs` Sitting on the Ice | "after 2 s Still, you regenerate 1.5 % of your health and linh lực each second, and your next cut adds 2 Ice stacks." ("no art" becomes "no damaging art", so wards keep you sitting) |
| `sects/van_khoi.items.json` | `vk-empty-mountain` Sit as Thôi Sat | "every 5 s you are Still, you bank a Cloud; …" (the rest unchanged; a5 Banked charges carries the store) |
| `sects/xuyen_lam.techniques.json` | `straw-sandal-step-primer › Lighter Than a Horse` | "A movement art: for a few seconds you are Moving, faster and harder to hit; the first time in that window the foe acts, its next art is delayed (you left its reach)." |
| `people/loose-south.items.json` | `ls-miasma-walker` Walked Out of Chiết Kích | "… while that ward holds, your escape channel is a third shorter." ("toward the edge of the fight" has no edge) |

### 3e. At range, Broken (R11, R12)

| File | Id | Suggested wording |
|---|---|---|
| `sects/phat_y.items.json` | `py-grey-seal` The Last Step | "… your next sword art while you are At range ends your At range and deals 30 % more damage; if its hit makes the foe Broken, you vanish again." |
| `sects/phat_y.techniques.json` | `contract-sword-canon › Step Back` | "After your hit makes the foe Broken or breaks a ward, you step away: you gain evade for a moment and are At range for 1 s." |
| `sects/tung_dao.techniques.json` | `startled-goose-step › The Goose Rises from the Reeds` | "You leap away: you are At range for 1 s, the foe's next hit within 2 s misses, and your next art lands with 30 % more effect." |
| `sects/da_quang.items.json` | `dq-night-glow-cup / drink-after-the-raid` | "When the foe is Broken, the cup fills: your next three arts cost health instead of linh lực and heal you for 5 % of the damage they deal." |
| `sects/da_quang.techniques.json` | `night-glow-blood-sabre-canon › Wine in the Night-Glow Cup` | "When the foe is Broken, you heal for a part of its maximum health and your next art is free." |
| `sects/thien_xu.items.json` | `tx-pha-quan-spear / the-called-blow` | "… if its hit makes the foe Broken, the next wait is halved." (once a fight, as Broken is) |
| `sects/thien_xu.items.json` | `tx-dawn-pair` Before the Sun | "… if its hit does not make the foe Broken, your next ward is doubled." |
| `sects/thien_xu.techniques.json` | `dipper-handle-canon › The Handle Points East` | "… if its hit makes the foe Broken, the handle keeps three stars." |
| `sects/tuan_tung.techniques.json` | `wolf-winter-arrow › The Leader First` | "Marks the foe; arrows at it ignore part of its ward, and when it is Broken it gains two Slowed Time stacks." ("the strongest foe" and "every other foe" read as the foe) |
| `sects/tuan_tung.items.json` | `ttg-wolf-winter-bow / the-pack-turns` | "When the foe you marked is Broken, a creature foe's arts that come ready in the next 3 s wait until they end (it flees)." (no other beast is in the fight) |

### 3f. A place condition left after the 2026-11-25 sweep

| File | Id | Suggested wording |
|---|---|---|
| `people/hermits-sages.items.json` | `hs-fifth-month-plum / falling-plum-tune` | Drop "When it is played inside the abode where it lay, a second voice answers it" (a place condition), or keep it as flavour outside fights. |

**Total: 87 fixes** (3a 40, 3b 9, 3c 12, 3d 15, 3e 10, 3f 1). Coverage check: every sect on a1's "Who" list has
at least one row here or in the list below.

### Reads as written

These read correctly through the table above and need no rewording. The catalogue pass should still know the
reading.

- **R1, body payloads to you**: `cl-first-sheaf-bell / harvest-bell`; Warm Shed; `cv-rain-calling-banner`; Follows
  the Wind Into the Night; When the Season Comes; Call the Grain Rain; `hn-moon-fish-lantern`; `lh-sunset-regalia`;
  `lh-envoys-errand`; The Sunset Clouds Fly with the Lone Duck; Coming Home at Dusk; Oars Together (strike half to
  companions); `ld-last-white-sail` (its 1-health clause is a Down refusal); Morning Dew; Hundred-Herb Draught; Open
  the Cask; `pvd-xich-ha-ky / red-cloud-rising`; `pm-nest-thread-banner`; `pm-five-virtue`; Dawn Clouds Take the
  Colour; Frost on the Pine; Cold Night Lamp; `tc-herb-terraces` and Grain Rain; `tx-seventh-star-drum`;
  `tvl-tuong-phi-tan`; `tv-white-cloud-whisk`; `tv-founders-seed-gourd` (the Down step); `tv-haze-regalia`; Empty
  Green Wets the Robe; Moss in the Returning Light; `ts-lone-smoke-sabre`; Hold the Line; `ttv-seed-warming-censer`;
  The Flowering; `td-pine-rain-fan`, `td-ferryman-remedy`, `td-still-water-relics`, `td-rain-over-long-lake`; Rain
  Through the Needles; Set the Lamp (a Piece with blows); A Breath of Road Mist; Heard Through the Roots;
  `xl-guide-lamp`; all of `yen_quang`'s haze and furnace rules.
- **R3, the foe**: `hs-quy-khu-vase`; `mf-vermilion-azure`; both `chan_kim` rules; `cc-green-field-bell`; Crescent of
  Red Sand; `hc-blind-founder`, Lift the Lid, Hold the Fume; Fired Mould; `lh-prize-and-brush`; First and Fifth
  Movements; `st-hundred-wards-flag`; `tx-seven-star-flag`; Sweep the Stones, Ghosts Sing Old Poems, Autumn Comes;
  The Held Rest; Who Is Afraid; `vl-clear-bell`; The Line Rings.
- **R5 and R6, foe acts and Still**: The Forest Listens; Eighth-Month Snow; Shade of the Road; The Lake Shows the
  Moon; `mf-bao-hull`; `bt-regalia`; Sitting in the Snow; Ink Sediment; Hot Rock; Perch on the Wutong; Pine Against
  the Wind with `tv-cliff-pine`; Bank the Kiln; Bar the Gate; Rain Before the Peal; `td-pine-regalia`;
  `td-cold-ford-charge`; `td-ice-breaker-array`; Ten Thousand Pines Answer; `ml-luan-bell / rings-as-it-moves` and
  Carriage Bell (the foe acts or evades); `lg-ice-hook`, `lg-lone-line` and `lg-heap-of-snow` (the sitting stance);
  Clouds Rise and The Water Has Ended (`van_khoi`); Sit Against the Door.
- **R7–R10, Moving, Displace, Planted, Rooted**: Not Counting the Steps; Walk Slowly; `xl-bamboo-staff`; Reel In;
  Pillar in the Current; `cl-twin-bridges`; The Flood Takes It; Counterweight Palm; `lh-the-gate`; Bend, Not Break;
  Wash the Feet; Haul In; `ta-old-ivory-hunt` and `ta-canglang-harpoon` (Pinned); `hlm-first-light`;
  `mf-sea-crossing-anchor / heavy-keel`; `tv-evening-ferry`; `tv-cold-ford-watch`; `td-white-wolf-fang`;
  `td-goose-and-dragon`; The White Wolf Falls; Line Through the Ice (Pinned); Close Over the Stone; Crane Descends
  (`cuu_cao`, a Displace); `chc-unbroken-thread` ("bound" = Pinned); Throw the Iron (Pinned plus Slowed Time); Open
  the Sluice and Furrow Palm (Slowed Time); Brush the Sleeve and Step into the Green (At range, a miss); The Gate Is
  Not There (the stun reading); `bth-the-crossing` and Ninth Bend ("behind the attacker" is flavour);
  `td-wandering-dragon-sash` ("moved one step aside" is flavour, not a Displace); The Wave Comes Back.
- **R4 and R1, Fields, Pieces, decoys**: The Handle Turns (refreshes Fields and Pieces); Haze on the Path; Hidden
  Fragrance and the `nhan_van` reflection-double rules (a decoy that "falls" when used up); `cc-green-field-riders`
  ("beside you" = the crane king is your companion).
- **False positives of the word scan**: "a blow that would kill you" (the Down step: `tb-grown-red-pearl`, Pawn the
  Pearl, Nirvana of the Red Wall); "Wind-rooted hand" (`hs-lone-crane`); "a line of an old poem" and other prose in
  method concepts.

The `sects/*.md` pages repeat the JSON wording in prose (51 ally mentions). They follow the JSON when it changes and
are not listed separately.

---

## 4. Open questions (all answered 2026-11-25 with the recommendations; see `../DECISIONS-2026-11-25.md` group 9)

1. **Broken at 25 % or 15 %?** ra-G1 proposed 25 %; the brief's example said 15 %. **Recommendation: 25 %, once a
   fight.** At 15 % the payoff often comes too late to matter before the knockout, and it sits close to the
   cull threshold (8 %).
2. **What ends Still?** ra-G1 says "no art cast for 2 s", sets-bt-01 says "an attack art or a push", and rb-01 says
   "no evade, no movement art". **Recommendation: the combined reading in R6.** A damaging or movement art, an
   evade or a Displace ends Still; wards, heals and the basic attack do not. Otherwise a ward-sitter could never be
   Still.
3. **Displacement: a timer delay, or real positions?** sets-bt-04 asks for a real push, pull and Unmoved.
   **Recommendation: the delay reading (R8), with Planted as a new immunity open at every tier.** Positions would need a distance
   model in a fight that has none. If you reject both, the "cannot be moved" clauses become block or damage-taken
   lines, as sets-bt-04 names.
4. **Who counts as an ally, and at what share?** **Recommendation: you, companions and Pieces count toward "allies";
   companions take strike payloads at half and body payloads go to you; Pieces receive nothing.** The alternatives
   are companions only (Pieces not counted), or companions at a full share.
5. **What does "alone" mean for Lone Branch?** Under R2 it is a real condition, but most of Ngạo Tuyết's sword builds
   have no beast, so for them it is on in every fight (and Take the Wind, R14, is always on for everyone).
   **Recommendation: keep R2 (no companion and no Piece of your own) and tell the catalogue pass.** The alternative
   is a true duel: alone only while *neither* side has a companion, read from the foe's profile at compile (R34). A
   beast-tamer foe would then switch Lone Branch off, which gives it a counter.
