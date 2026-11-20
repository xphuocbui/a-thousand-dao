# Đạo Đồ: how the nodes are filled (content method, APPROVED 2026-11-19)

**Status: APPROVED by the user 2026-11-19 with choices 1b, 2a, 3a (§7).** The user controls this process; the content itself
is reviewed once, when the whole tree is filled (user, 2026-11-19: "I will only check once the whole tree is there.
Meanwhile, the only thing i want to control is your process"). After approval, Claude runs it to the end without
per-land approvals; any change to these rules goes back to the user first.

This file is written so a fresh session can run it cold: read it, `content-decisions.md`, then the files in §1.

## 1. Inputs (read before working)

| What | Where | Used for |
|---|---|---|
| The graph, frozen | `cells/versions/v5-frozen-2026-11-19/dao-do-map.json` (8,038 nodes; SHA256 in its `SHA256SUMS`) | Node ids, kinds, clusters, positions. Never edited by this work |
| Cluster audit | `cluster-audit-v5-2026-11-19.md`, `tools/design/dao_do_rework/cells/audit_clusters.py` | Which pieces are big pictures, pairs, bands |
| Approved ideas and capabilities | `big-clusters-draft-2026-11-18.md` (80 ideas, all 25 capabilities placed by land) | The ideas to place |
| Ideas on v5 | `big-cluster-ideas-v5.md` (Fire approved, Earth drafted) | Step A output |
| Stats | `design/gdd/modifiers.md`: Stat List (keys, ops, price W, grid, status), General Catalogue (the plain modifier library), rules 8-13 (scope, tags, breadth, rare) | Every number on a node |
| Rules with effects | `design/gdd/effects.md`: Status Catalogue (burn, poison, bleed, curses such as Slowed Time), Starter Effects (14 may sit on the Đạo Đồ, host `MM`) | Keystones, capability notables, at most one Effect per big picture |
| The tree's own rules | `design/gdd/dao-do.md` rules 4 (bonuses, purity, keys), 16-18 (capabilities), Formulas A2 (grades), E (capability notables), F (breakthrough curve) | Budgets, capabilities |
| Land themes | `tools/design/dao_do_rework/regions/common.py` (road stats, theme notables; its `dot_pct` key is old: use `attack_pct` scoped `[over_time]`) | Land identity |

## 2. What every node gets

| Node kind | Count on v5 | Content |
|---|---|---|
| Road | 751 | Unchanged from the GDD (rule 4): its land's purity, about 0.5, exact; border roads half of each neighbour's; hub Source roads general stats. Not authored here |
| Start | 11 | Unchanged (the GDD's start choice) |
| Small node in a cluster | 5,493 | **One** plain modifier at the small grade, **1.2 W** (Formulas A2 `S0`) |
| Notable | 1,759 | **Two** plain modifiers (rarely three) summing to **8 W** (`N0`), plus a unique name. Optionally one Effect (§4.6) |
| Capability notable | 25 | The capability (rule 16, `cap_realm_min` Core Formation) plus `f_tier · 8 W` of plain modifiers (Formulas E: T1 4 W, T2 2 W, T3 0 W) |
| Keystone | 24 | One Effect (a rule change with a closing cost, `effects.md` style) plus a plain positive side of at least 50 W; rare modifiers allowed here only |

**Values are never typed by hand.** A node stores *stat, scope and W budget*; the number comes from Modifier System
Formulas C (`value = floor(B · breadth_mult / (price · grid)) · grid`) and is multiplied in play by the land's
purity (rule 4). So the open value-scale question (v5 has 1,759 notables, the GDD assumed 1,084; mean 2.60 W against
the 2.07 W target) stays one knob for the end (choice 3).

## 3. Hard rules for any modifier on a node (checked by script)

1. The stat is in the Modifier System's Stat List and the stat-plus-scope is a row of its General Catalogue (or a
   two-tag scope its rules allow). Unknown key, scope or op fails.
2. **Never on a small node or a notable:** rare counts (art, artifact, ward, beast, kind-locked slots; field plots;
   pills per brew; talisman stock; stacks per grant; status stack cap), any `more` key (`damage_more`, `ward_more`,
   `body_more`: modifiers.md rule 12, "the Đạo Đồ never grants more"), `leech_health_pct`, `bonus_ward_slots`
   (rule 4), `art_coef_add`, and `opening_haste_pct` on smalls. Rare counts may sit on keystones.
3. A stat whose value floors to 0 at the node's budget is not used there (e.g. spirit-qi density on a small node).
   Rounding loss over 15 % is reported (`rounding_lint_threshold`).
4. **Pending stats** (talisman power, taming chance, pill quality, formation upkeep, shield recharge, foe scopes, ...):
   choice 2.
5. `breakthrough_chance` only in ideas about breakthroughs or late life (Fire F4, Earth E10's line, Water W10, Thunder
   T1, Fire F9), at most one notable per such picture; the tree-wide sum is reported (it runs through the curve of
   Formulas F, so it is not clamped).
   **Amended 2026-11-20 (content-decisions #34, user):** the build also turns one cultivation-life line per piece into
   `breakthrough_chance` at the same W (`build.py breakthrough_spread`), so a late-gate build can gather it.
6. Words that describe a rule (while, when, below X, spreads, area, stun, on kill) are never faked with plain stats:
   that part is an Effect (§4.6) or is dropped. There is no Stun status; slowing uses Slowed Time.

## 4. The algorithm

### Order of work
- **A. Ideas** for every big picture in the whole tree (finish Earth, then Metal, Water, Wood, Light, Thunder,
  Darkness + Shrine, hub swirl, start motifs). Doing all ideas first lets overlaps between lands be seen.
- **B. Capabilities and keystones:** the 25 capability notables and the 24 keystones (Effects).
- **C. Big pictures' nodes:** every node of every big picture (226 pieces, 3,850 nodes, 861 notables).
- **D. Medium clusters** (238 pieces, 1,684 nodes, 447 notables).
- **E. Small clusters** (399 pieces, 1,668 nodes, 451 notables).
- **F. Checks, viewer, final report.**

### 4.1 Step A: one idea per big picture
For each area, from the audit's list (a mirrored pair counts once and carries one idea on both copies):
1. **Capabilities first.** Each sits in the land the approved list gives it, at the approved distance (#22 and #23
   outermost). A capability whose planned picture no longer exists goes to the land picture that best matches its
   rule-17 description; logged (e.g. #14 Portable Cave Abode → Earth's cave, c51).
2. **Approved ideas next**, in their land. Ideas from the removed blend zones sit on the side facing their old
   neighbour. The approved band is kept where the land's pictures allow, else moved one band; every move is logged.
3. **New ideas for the rest**, chosen in this order: (a) what the land is about (`common.py` themes, the element's
   meaning: Fire heart and soul, Earth faith and body, Metal killing and refining, Water wisdom and flow, Wood growth
   and life); (b) whatever that land still lacks from the **coverage list** below; (c) related to the neighbouring
   pictures, so a district forms (2-4 related ideas side by side).
4. **The carriable test** for every idea: it names 2-3 stat lines that pass §3 at 8 W. If it cannot, it is reworded,
   or its rule part becomes that picture's one Effect.
5. **Coverage list** each element land must reach: an element-damage line, a defence line, at least one sustain line
   (health or linh lực regeneration, sustain is king), its own system (alchemy, formations, refining, talismans,
   fields and beasts), a cultivation or life line, and a late-life line on the rim. Islands and the hub follow their
   approved themes.
6. Two lands may reach the same need by different stats (e.g. heart-demon resistance through đạo tâm in Earth, thần
   hồn in Fire); the same stat line as another land's idea is not repeated. Logged when it happens.

### 4.2 Step B: capabilities and keystones
- A capability notable holds the capability plus its `f_tier` share of plain stats on the idea's main line. On a
  mirrored pair it sits on the lower-angle copy; the other copy's notable carries a full 8 W instead.
- Each keystone: one Effect that changes a rule and closes something (the price), plus at least 50 W of plain stats
  on the same line. The two keystone pairs on each land's rim point to two different build directions of that land.
  Effects come from `effects.md`'s Starter Effects with host `MM` first; new ones are drafted, unpriced, in
  `content/effects-draft.md` (they move into `effects.md` only with the user's approval, section by section).

### 4.3 Step C: a big picture's nodes
- Walk the piece from its entry (the node joined to the road) outward.
- **Small nodes** carry the idea's two main stat lines, alternating along the path (A, A, B, A, A, B ...), 1.2 W
  each, so every step toward the crown pays the idea.
- **Notables** carry 8 W: the main line (4-5 W) and one of the idea's other lines (3-4 W), each notable a different
  pairing. The **crown** notable (the one farthest from the entry) may hold the picture's one Effect (§4.6) or the
  capability.
- Names: English with the Hán-Việt in brackets, unique in the whole tree, said like a technique or a place, not a
  stat ("Nine Turns (Cửu Chuyển)", not "Alchemy Up").

### 4.4 Step D: medium clusters
- Each medium cluster gets a **minor theme** by hand: one stat line chosen from its land's pool (§4.7), preferring
  a line that supports the nearest big picture's idea without repeating its main line (e.g. crit beside a damage
  idea, health beside a ward idea), and not the same theme as the medium cluster next to it.
- Nodes follow the same pattern as §4.3 (smalls the theme line, notables theme plus one partner line).

### 4.5 Step E: small clusters
- Choice 1 decides how. In both options every small cluster gets its own stat line from its land's pool, and
  neighbouring copies of the same drawing get different lines (PoE 2: one drawing, different passives).

### 4.6 Effects on ordinary notables
- At most **one** Effect per big picture (on its crown), none on medium or small clusters. An Effect is used only
  where the idea needs a rule (spread, area, below-half-health, conversion with a condition). A plain conversion
  (`convert_pct`) is a modifier, not an Effect (user, 2026-11-08).

### 4.7 Land pools
Before step D, each land gets a hand-written pool of 15-25 stat lines (stat + scope), drawn from its themes and
coverage list, with a weight for how common each line should be. Pools are written in `content/pools.md` and used
only to pick medium and small cluster lines.

### 4.8 Who does the work
- Claude writes everything in this session, area by area, so one hand keeps names and ideas consistent.
- After each area, a **fresh reviewer agent** (not told what to expect) reads this method and the area's content and
  reports rule breaks, repeats and dull stretches; Claude fixes them. Reviewers report only; they never edit.
- Scripts only compile, check and render (memory `hand-author-no-scripts`): they compute values, validate keys,
  report coverage and render the viewer. They never choose content.

## 5. Where content lives

- `content/<area>.json`, one file per area, keyed by v5 node id, with the map's SHA256 at the top. Per node: `name`
  (notables), `mods` as `[stat, scope, budget W]`, optional `pending` (choice 2), `cap`, `effect`.
- `content/effects-draft.md` (new Effects), `content/pools.md` (land pools), `big-cluster-ideas-v5.md` (step A),
  `content-decisions.md` (every call made on the user's behalf, with its reason).
- Checker: `tools/design/dao_do_rework/content/check_content.py` (reuses `tools/design/modifier_catalogue.py`'s prices
  and tiers): key and scope validity, §3 rules, values by Formulas C, budgets per node kind, pairs identical,
  each capability once, 24 keystones with an Effect, names unique, coverage per land, mean W per Dao mark,
  breakthrough sum. Observations only.
- The viewer artifact shows each node's name and modifiers on hover.
- Nothing is committed until the user says so (own paths only, memory `commit-own-paths-only`).

## 6. Pilot (run 2026-11-19 on four real clusters)

Values are before the land's purity multiplier.

**Big picture, Fire F1 Nine-Turn Furnace** (c28 sunrise, 11 nodes: notables 2302, 2306, 2312; its mirror c29
sunrise is identical except the capability). Lines: alchemy success (2.7 W/pp), pill effect (1.0 W/%), fire damage.
- 8 small nodes alternate: alchemy success 1.2 W = **+0.4 pp**; pill effect 1.2 W = **+1.2 %**.
- 2302 **Nine Turns (Cửu Chuyển)**: alchemy success 5 W = +1.8 pp; pill effect 3 W = +3.0 %.
- 2306 **Furnace Fire (Lô Hỏa)**: Fire-element damage `[hoa]` 4 W = +6.0 %; alchemy success 4 W = +1.4 pp.
- 2312 (crown, c28 only) **Divided Furnace Flame (Phân Lô Hỏa)**: capability #10 (T1) + alchemy success 4 W =
  +1.4 pp. On c29 the crown carries 8 W instead.
- Found: "pill quality" is Pending (choice 2); "two recipes a season" is the capability's rule, not a stat.

**Medium, Fire c18 flame_b** (7 nodes, beside F6 Sun Disc). Theme: fire damage; partner: crit.
- 5 smalls: `[hoa]` damage 1.2 W = **+1.8 %**.
- 2183 **Kindling (Mồi Lửa)**: `[hoa]` damage 4 W = +6.0 %; crit chance 4 W = +4.0 pp.
- 2185 **Ember Glow (Ánh Than)**: `[hoa]` damage 4 W = +6.0 %; maximum health 4 W = +6.6 %.

**Small, Fire c3 C_spur** (5 nodes, the start cell). Line from the pool: thần hồn (Fire is the heart that houses the
spirit).
- 3 smalls: thần hồn 1.2 W = **+0.40**.
- 2866 **Heart Flame (Tâm Hỏa)**: thần hồn 4 W = +1.33; `[hoa]` damage 4 W = +6.0 %.
- 2868 **Warm Meridians (Ôn Mạch)**: maximum health 4 W = +6.6 %; fire resistance 4 W = +150 points.

**Where it breaks: a Water talisman picture** (W1 Brush and Inkstone, #13 Endless Talismans). Talisman power,
keep chance, ink cost and drawing success are all **Pending**; talisman stock is rare. What can be carried today is
talisman damage (`attack_pct [talisman]`, 8 W = +12.0 %) and art speed. The same holds for Wood's beasts (taming
chance and beast slots Pending; companion power, speed and health are Designed). Choice 2 decides this.

**Also found in the drafts so far** (fixed in step A, logged): Earth's Heavy Star and Stone Skin used `more` keys
(not allowed on the tree); Landslide's "stun" does not exist (Slowed Time instead); Fire's Pill Pouch "pill slot" and
Earth's field plots are rare counts (keystone only); "healing when low", "spread", "area damage" and "while burning"
are Effects.

## 7. Choices (decided by the user 2026-11-19: 1 b, 2 a, 3 a)

**Decided:** small clusters cluster by hand, nodes by pattern; Pending stats in a separate `pending` field; author at
today's grades and settle the scale at the end.


1. **Small clusters (399 pieces, 1,668 nodes).**
   - **(a) Node by node by hand**, like the big pictures. Most varied, slowest.
   - **(b) Cluster by hand, nodes by pattern (recommended).** Claude picks each small cluster's line by hand from the
     land pool (399 decisions); its nodes follow the fixed pattern of §4.3 (smalls the line, notables line + a
     partner). Same as PoE 2's small clusters; much faster. Medium clusters stay node by node in both options.
2. **Pending stats.**
   - **(a) Keep them in a separate `pending` field (recommended).** The node is valid today with its Designed stats,
     and the pending line switches on when its owner GDD defines the key. Talisman and beast ideas stay whole.
   - **(b) Live and Designed stats only.** Talisman and beast pictures carry damage and companion stats only until
     those GDDs are done.
3. **The value scale.**
   - **(a) Author at today's grades (small 1.2 W, notable 8 W) and settle the scale at the end (recommended).**
     Values are derived, so one knob fixes the mean afterwards.
   - **(b) Lower the notable grade now** (about 8 W → 5.5 W) so the mean is on target while authoring.

## 8. Amendments made while running it (2026-11-19, logged in `content-decisions.md`)

These came up during the run. None changes the user's three choices; each is listed so a fresh session matches what
was built. Items marked **(process question)** are open for the user.

1. **Areas beyond the audit:** the border lines (`content/src/border.py`: the Wind start's figure, the four border
   emblems, the five border combos 911-915) and 50 loose small nodes of the base map (10 per land, no cluster; filled
   with `ONE(ids, line)`, one line per mirrored pair). The base map's unnamed start and emblem figures are filled in
   step D like medium clusters (decision 8).
2. **Mirrored pairs:** a capability or Effect sits on the copy with the negative axis offset; the other copy's
   notable carries `alt` stats (decision 7). Copies keep the same names.
3. **Checks added to the build:** no two notables of one big picture or medium share a stat pairing (§4.3), and no
   medium takes its cell's big-picture main line as its theme (§4.4).
4. **Breakthrough chance** sits on at most one small node in three of a picture (decision 15), besides §3.5.
5. **Fights are duels** (Combat rule 1): no Effect assumes several foes and no node carries linh lực on kill.
6. **Review pass:** five fresh reviewer agents after the fill (§4.8 ran once for all areas, not after each area).
   Their rule breaks were fixed; their taste calls were partly applied (decisions 16-18). The fixes were not
   re-reviewed.
7. **Decided (user, 2026-11-19): keep.** §4.3 says a big picture's notable pairs its main line with "one of the idea's other lines".
   In practice most notables pair the main line with a related stat from the land pool, so that no two notables in a
   picture are the same (an idea has only 2-3 lines). Reviewers flagged it; the user kept it: a notable pairs the idea's main line with one of its other lines or a related land-pool stat.
8. **Decided (user, 2026-11-19): keep the echo; rename to Hán-Việt.** Small clusters may echo the nearest big picture's lines (only mediums may not); notable
   names carry plain Vietnamese or Hán-Việt in brackets, mixed (decision 18). Names get a Hán-Việt pass (decision 22).
9. **Tag spellings assumed:** the variant element tags `bang`, `phong`, `loi` (Ice, Wind, Thunder) are not spelled
   in any GDD yet (Spiritual Roots names the variants, the Modifier System's element family "includes the root
   variants"). Rename in `content_lib.EXPAND` if the registry spells them differently.
