# System Roles

Who carries what. Once the modifiers exist, each needs a home. The point of this file is that every
system keeps its own job, so a player assembles a build from different parts of a life instead of
finding it in one place. **Spread the stack across systems:** a build that lives in one system is a kit,
not a build.

Field formats are in `content-formats.md`. Live limits are in the sources it lists.

## Who does what

| System | Its job in a build | Good for | Not for |
|---|---|---|---|
| **Spiritual root (linh căn)** | Identity from birth: elements and variants, which set tags, harmony and what a build can reach | Which tags are cheap, which Đạo requirements are met | Rules. A root is chosen once, so it should not be the whole build |
| **Techniques (công pháp)** | The engine: the arts a build fires and the way it grows through layers | Enablers, signature arts, tag-keyed L2 "more" | Generic stats, which belong on the tree |
| **Arts (thần thông)** | What actually happens in the fight | Channels, statuses, curses, conversions, guards | Passive stacking |
| **Wards** | How the build spends linh lực to live | New cost models, tag resistance | Damage, except through a keystone |
| **Artifacts (pháp bảo)** | L3, and what the build carries | Attack and defence, affixes, named enablers, active effects | The whole stack: thần thức limits them |
| **Talismans (phù lục)** | Prepared single uses | Answers to gaps, opening bursts, escapes | Sustained power, because each takes an art slot and is used up |
| **Formations (trận pháp)** | The ground and L4 | Preparation builds, ground tags | Blind fights, unless a modifier says otherwise |
| **Pills** | Preparation, and permanent change through toxicity | L4, timed buffs, life-stat hooks | Anything during a fight |
| **Spirit beasts (linh thú)** | A second free channel | A companion's tags, a fixed art | More than one source: one companion |
| **Tree acupoints** | Small, general steps of the stack | Increased modifiers, everyday stats | Rule changes |
| **Hidden clusters** | A themed stretch of the stack that a player plans a life around | Specialised scaling, a capability or keystone at the end | Tying a cluster to one build: the theme must be wider |
| **Đạo** | The rule-bending, and the build's name | Keystones, conversion, passives, arts | Generic stats: a line any Đạo could hold belongs on the tree |
| **New concept** | A mechanic the game does not have | Only when nothing above can carry the need | A way to skip the work of fitting the rules |

## Limits that shape proposals

**Tree acupoints and hidden clusters.** The tree is being reworked once all systems exist (Combat Open
Question 22), so **this skill never edits `meridian_tree.json`**. It writes cluster ideas to the catalogue.
A cluster idea states the following, following `design/gdd/kinh-mach-do.md` rules 6, 7, 12, 16 and 19:

- A theme that is a system the game has, wider than one build, and an element affinity
- Kind: sealed (authored, the same every life, plannable) or open
- One seal condition: an event, an item or a technique. A technique can list it in `seal_clusters`,
  which is how a technique and a cluster become one build's path
- A size of 3 to 12 acupoints, one notable per `huyet_per_notable`, with the payoff farthest from the entry
- At most one capability on one notable, only on an outer sealed cluster of at least `cap_min_n`

**Đạo.** A new Đạo or a new branch is data (dao.md rule 1), under these rules:

- 19 to 22 nodes: three named branches and a keystone. Nodes are stat lines, passives or arts
- Stat lines use only the Đạo's `theme_stats`. No passive id appears in two trees (rule 12)
- With the name hidden, a player can tell the Đạo from its nodes
- No ceiling raises and no root factors (rule 4). A Combat cap is not a Character Stats ceiling, but a cap
  shift still needs a bound
- Requirements: elements at a purity, a variant, or a technique kind (rule 5)
- Node value follows dao.md Formulas D1. Art nodes may be designed now (user decision 2026-11-07), and
  they are not added to game data until the fight is built

**Techniques.** `Σ value / pool_max ≤ bonus_budget[tier]`, each value within `bonus_single_cap`, and tier
`max_realm` reaches the span claimed (cong-phap.md Formulas D). Only keys in `bonus_pool` can be
checked, so a combat modifier on a technique is usually `NOT ASSESSED` for budget. Abilities do not count
against the budget. A character has one main and `aux_slots` auxiliary techniques.

**Artifacts.** Pieces are limited by `equip.max_slots` and by thần thức. Defence feeds ward or body guard,
never both (item-database.md rules 6 and 11). Random affixes come from the `affixes` table; a named piece
can carry an authored effect. Prefer an affix a generated item could roll, and keep authored effects
for enablers.

**Modifiers in the catalogue.** New ideas go in `design/quick-specs/tree-modifier-catalogue.md`
under its legend (● exists, ◐ designed, ○ new).

## When to invent a new concept

A new concept (a new resource, status family, slot type or win condition) is allowed and welcome, but it
costs every system something. Propose one only when the gap check shows that:

1. No existing system can carry the need, even with a new key.
2. It opens more than this build: name at least two other builds it would serve.
3. It can be stated as a rule in a named GDD, with its bounds and its Breakdown line.
4. NPCs can use it, or its absence for NPCs is stated and accepted.

Record it in the sheet's New Concepts section, in the content ledger, and as a question for the user.
Building it is a separate decision.
