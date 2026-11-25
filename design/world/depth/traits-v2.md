# Traits v2 (proposal)

> **Status**: Proposal, overnight 2026-11-24/25 (rules-proposals R6). Amends the approved NPC Traits GDD
> (`design/gdd/npc-traits.md`) and its catalogue; the user approves the amendment section by section. The catalogue
> of new kinds is `traits-v2.json`. v1 traits stay as they are and are cited by their v1 names.

## Why

v1 gives a person 3 personality traits, 1 calling and rarely a fate-given trait. A personality trait carries one stat
pair of about +2 % / −0.8 %, so a person reads as three adjectives and a job. CK3 characters carry an education, a
lifestyle, congenital traits in tiers, health, coping and reputation traits. Many of those *do* something: open an
interaction, change how others regard them, or make a decision possible. The user asked for all three: more traits,
bigger effects, and hand-written trait sets for the cast.

## Kinds per person

| Kind | v1 / v2 | Per person | Notes |
|---|---|---|---|
| Personality | v1 (37) | 3 | unchanged ids; rows doubled (below) |
| Calling | v1 (14) | 1 | unchanged |
| **Upbringing** | v2 (12) | 1 | how they grew up; set at creation from birthplace and family |
| **Talent** | v2 (12, tiers 1-3) | 0-2 (notable 1-3) | gifts and flaws on the six talents (thiên phú); CK3 congenital tiers; inherited with drift (F5) |
| **Path** | v2 (24) | 0-2 | what cultivation made them; gained by technique, deed or accident |
| **Lifestyle** | v2 (14) | 0-1 | what they do with their time |
| **Health** | v2 (10) | 0-1 | wounds, deviations, poisons, age |
| **Coping** | v2 (8) | 0-1 | gained under stress; fades or hardens |
| Fate-given | v1 (10) | 0-2 | kept for fates with a story (Demon-seeded, Spirit-eyed); talent tiers replace the plain gifts for new records |
| Gained | v1 (16) | 0-2 | unchanged (Scarred, Renowned, Life-debt...) |

A notable person (cast tier A) carries **6-12 traits** (widened 2026-11-25, ruling group 12), a tier B person 5-8, an ordinary one 4-6. The tick cost stays
flat: rows are summed once at creation and on change, as v1 does.

## Bigger effects

1. **Rows.** v1 personality rows double (Brave +4 % health / −1.6 % evade). Talent tiers add +6 / +12 / +20 to a talent
   (thiên phú) and, at tiers 2-3, a stat row. Path traits are sized at about a third of a Profound technique's
   passive budget, enough that a Sword-heart is visible on the fight sheet. Every row is a plain Modifier System number
   (memory: Modifier vs Effect).
2. **Opens.** A v2 trait may open an event option (`event:`), a dialogue verb (`verb:`), a sect policy lean when its
   holder leads (`policy:`), a duel stance (`stance:`) or a craft edge (`craft:`). These are hooks for the Event
   Engine chain layer, NPC Interaction & Dialogue verbs and Sects policy. Each needs its consumer to be built before it
   shows in play. That is the honest limit of this pass: the data makes people deeper, and the unbuilt chain and verb
   layers make the depth visible.
3. **Likes and dislikes.** CK3-style regard: the same trait or a listed one gives opinion, an opposed or listed one
   takes it away (NPC Traits F3 computes opinion; v2 adds the pairs). Two Reclusive elders get on; a Just head despises
   a Deceitful elder; a Street orphan resents a Clan heir.

## How content cites traits

```json
"traits": {
  "personality": ["Reclusive", "Calm", "Just"],
  "calling": "Strategist",
  "upbringing": "hermit_taught",
  "talent": [{"id": "steady_heart", "tier": 3}, {"id": "keen_soul", "tier": 2}],
  "path": ["frost_veined", "heart_demon_victor"],
  "lifestyle": "qin_player",
  "health": null,
  "coping": null,
  "fate_given": [],
  "gained": ["Renowned"]
}
```

`depth_check.py` checks every id against v1 (`assets/data/traits.json`) and v2 (`traits-v2.json`).

## Open for the user

1. Talent tiers replace the plain v1 fate gifts (Wise-born, Iron-boned, Frail...) for new records. Should v1's be
   retired, or kept as the tier-3 names?
2. Doubling v1 personality rows touches combat balance slightly (Brave +4 % health). Accept, or keep v1 rows and put
   all new weight in the new kinds?
3. Which `opens` hooks to build first. Recommended: dialogue verbs (#30), because the player meets traits there first.
