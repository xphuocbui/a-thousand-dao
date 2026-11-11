# [Build Name] ([Tên Hán-Việt])

> **Status**: Design sheet, [date]. Not in game data. Numbers on new content are first guesses.
> **Seed**: [the user's words]
> **Direction**: [the direction chosen]
> **Realm span**: [from – to] · **Power level**: [ordinary / top-end / legend] · **Use**: [player / NPC or sect / boss]
> **Fit**: [n] Fits today · [n] Needs key · [n] Needs rule
> **Checks**: [n] PASS · [n] FAIL · [n] NOT ASSESSED ([which, and why])

## The Spine

- **The channel:** [how it wins, which layers and caps that means]
- **The enabler:** [what opens the build and what it closes, or none]
- **The loop:** [what it does, over and over]
- **The engine:** [the one interaction that makes it more than its parts]
- **The sacrifice:** [what it cannot do, and refuses to fix]
- **The arc:** [how it changes from first realm to last]

## The Legend

[Two or three short paragraphs: where this path came from, who walks it now, what it does to them,
who wants it gone. Told as the world tells it.]

## How It Fights

[Plain language, one paragraph. Then the signature moment.]

## Enabler

[Only if used. What it is, where a player finds it, what it opens, what it closes.]

## The Stack

The build's modifiers, in order up the ladder. Sizes on new modifiers are first guesses.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| [rung] | [name (Hán-Việt)] | [one line] | [form] | [channel] | [L1–L5 or none] | [● ◐ ○] | [system] | [other build, or signature] |

**Identity piece:** [the modifier that makes this build itself, and why]
**Empty rungs:** [each one, and whether it is a gap or a sacrifice]

| Layer | Points at [realm] | Multiplier | Sources |
|---|---|---|---|
| L1 to L5 | [n] | [×n] | [what fills it, or why it is empty] |

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | [elements, purity wanted] | [why] |
| Key talents | [such as Comprehension, Physique] | [why] |
| The Way (Đạo) | [name, nodes wanted] | [why] |

## Công Pháp

### [Technique name] — [main / secret / body], [tier]

[One line of flavour.]

```json
{ technique record }
```

**Fit:** [label] · **Budget:** [Σ value / pool_max against the tier's budget]

## Arts

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| [name] | [source] | [tags] | [n] | [n] | [s] | [condition] | [label] |

For each art: **Effect:** [rule terms]. **Description:** [one line of flavour].

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| [realm] | [n] | [arts, in order] | [ward] | [what changes] |

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| [name] | [artifact, weapon] | [base, grade, tier] | [link to engine, sacrifice or arc] | [label] |

Include talismans, pills and formations here. Give each signature item a line of history.

## Companion

[Only if used. The beast, its fixed art and why it belongs.]

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| [order] | [name] | [number] | [why] | [label] |

### Hidden cluster idea: [name (Hán-Việt)]

[Theme, element affinity, kind, seal condition, size, the small acupoints in words, notables, capability.
An idea for the tree rework, not data.]

## Đạo

[Only if the build proposes one. Requirement, `theme_stats`, three named branches, keystone, the nodes
that matter.]

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| [realm] | [how] | [what it gains] | [what it costs them] |

## Matchups

| Enemy | Result | Why |
|---|---|---|
| [type] | [wins / even / loses] | [why] |

**Counter:** [what beats this build, and how]

## Checks

Each result is PASS, FAIL or NOT ASSESSED, with the reason.

| Check | Result | Detail |
|---|---|---|
| Budgets | [result] | [the numbers] |
| Validity | [result] | [ids and tiers checked] |
| Stack | [result] | [ladder, forms, channel fit, layer totals] |
| Scaling | [result] | [m_static against the anchors; INFO if above] |
| The fight | [result] | [see Fight Results] |
| Reuse | [result] | [second homes, signature count, what was reused] |
| NPC use | [result] | [what was checked] |
| Counterplay | [result] | [the enemy type and how it wins] |
| Originality | [result] | [what was checked] |

## Fight Results

Input: `design/builds/[slug].fight.json`. Observations from `fight.py` on the combat simulator
(`tools/design/combat_sim/sim.py`, 20 fixed seeds), not the game.

| Enemy | Gap | Wins / losses / draws | Mean time | Own dry at | Never fired | Cap hits |
|---|---|---|---|---|---|---|
| [typical / top_end] | [0–2] | [w / l / d] | [s] | [s or never] | [art ids or none] | [names] |

**Identity test** (`--without [piece]`): [the matchups that changed, or NO_CHANGE everywhere]

**Unmodelled:** [each piece the fight did not test]

## New Concepts

[Only if used. The concept, the rule it needs and in which GDD, its bounds, its Breakdown line, the two
other builds it serves, and the question for the user.]

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| [name] | Needs key / Needs rule | [the key, or the rule to change] |
