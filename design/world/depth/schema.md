# World depth: file schema

Every file in `design/world/depth/` follows this schema. `tools/design/world/depth_check.py` checks it. A record that
deepens an **existing** cast member keeps their `key`, name, birth year, realm, sect and rank (from
`assets/data/world_history.json`); fields may be added and the build revised to fit the rules. Change an existing
fact only with a `"changed": "<old> -> <new>: why"` note.

World facts: start year **1200** (ages are 1200 − born). Realm ids `luyen_khi`, `truc_co`, `ket_dan`, `nguyen_anh`,
`hoa_than`; minimum age 16 / 30 / 80 / 200 / 500, lifespan 120 / 200 / 500 / 1,000 / 2,000.

## `sects/<key>.md`: the sect page

Sections, in order:

1. **At a glance**: name, Hán, gloss, great/minor, lord and vassals, alignment, leans (old → new), lineage elements, rough size.
2. **Land and seat**: the R4 decision (stay, move to a named place id, or re-lean) and why; what the move costs
   (art, routes, province, density and the founder's array, lore lines); what the old seat becomes; how the land shapes the
   people born on it (R1).
3. **History**: founding and the sect's ages, wars, grudges, falls. Cite chronicle/annal ids (`C012`, `A143`) and
   people keys. Add new events as `N-<key>-01`... with year, kind, text (proposals for the chronicle).
4. **Doctrine and customs**: what they believe, how they live, rites, dress, taboos, sect rules, how they see outsiders.
5. **Lineage (công pháp)**: main, secret arts by rank, body technique, outer method; ids from `design/techniques/` or
   proposals in `<key>.techniques.json`; why the lineage fits the land.
6. **Admission**: R2 as the sect applies it, how it finds disciples, exceptions it allows (guest elders...). A
   no-lean sect (R3) says what it recruits by.
7. **Ranks and halls**: structure, peaks and halls and who runs them.
8. **Relations**: lord, vassals, allies, rivals, grudges, with people links.
9. **Inside the sect**: factions, succession, quarrels, secrets: the hooks the cast plays out.
10. **Treasures and sets**: the sect's named items and sets (details in `<key>.items.json`).
11. **Roster**: a table of the named cast: key, name, rank, realm, tier, root, role.
12. **Story hooks**: 6-12 seeds for events, chains and quests, each naming the people and places it uses.

## `sects/<key>.cast.json`: people

```json
{"sect": "bang_tam", "people": [ {person}, ... ]}
```

A person:

| Field | Tier | Meaning |
|---|---|---|
| `key` | all | snake_case of the name without tones (`so_ngoc_ho`); unique in the whole world |
| `name_hv`, `name_han`, `gloss` | all | name in Hán-Việt, in Hán characters, and what it means (A/B; C may omit gloss) |
| `sex` | all | `M` / `F` |
| `born` | all | year; `died` and `cause` if dead |
| `alive` | all | bool |
| `realm`, `stage` | all | the living person's realm id and stage 0-2 (dead: `peak_realm`) |
| `sect`, `rank` | all | sect key; rank: `tong_chu`, `truong_lao`, `noi_mon`, `ngoai_mon`, `founder`, `last_head`, `retired_head`, plus the proposed `thai_thuong` (grand elder, maps to truong_lao), `chan_truyen` (true disciple, maps to noi_mon), `khach_khanh` (guest elder, maps to truong_lao, R2 exception), `chap_su` (steward/deacon, maps to noi_mon), `tap_dich` (servant, maps to ngoai_mon, R2 exception) |
| `home`, `birthplace` | all | place **ids** from the continent (`_inputs/<sect>.json` ground or `world.json`) |
| `role` | all | one line: what they are in the sect and the world |
| `tier` | all | `A`, `B` or `C` (R8) |
| `root` | living | `{elements: {id: purity 10-100}, variants: {id: purity}}`; a variant's required elements in the root (Ice needs Water, Thunder Fire+Metal, Darkness Earth+Water, Light Fire, Chaos all five, Wind none) |
| `thien_phu` | A, B | the six talents 1-100: ngo_tinh, can_cot, than_hon, khi_van, dao_tam, mi_luc |
| `traits` | all | as `traits-v2.md` (personality 3 and calling 1 always; upbringing always; the rest by tier) |
| `appearance` | A, B | one sentence |
| `backstory` | all | A 120-250 words, B 50-100, C 1-2 sentences. Must name at least one other person (key) or one history event id (A and B). |
| `wants`, `secret` | A | what they are after; what they hide |
| `ties` | all | `[{to: key, kind, note}]`; kinds: master, disciple, parent, child, spouse, dao_partner, sibling, sworn_sibling, friend, rival, enemy, debt (they owe), creditor (owed), lover, former_master, former_disciple, feud, grandparent, grandchild, cousin, ancestor, descendant, aunt_uncle, niece_nephew, in_law. Masters also go in `master: key`. **Direction:** a kind names what the *other* person is to you (`master`: they
are your master; `parent`: they are your parent), except `debt` (you owe them) and `creditor` (they owe you). Ties may point to other sects' people (cross-sect pass fixes the far side). |
| `master` | if any | the master's key: older, higher realm, same sect when taught (or `former_master` tie) |
| `build` | living | (main technique: a `design/techniques/` id, a lineage proposal id, or a generated stand-in `<hoang|huyen|dia|thien>_<element>` as the game uses for people without a catalogue method) |
| `build` (cont.) | living | `{archetype, main {tech, layer}, aux [{tech, layer}] (≤2), gear [...], skills {craft: 1-9}, tree {start, intent}, note}`; archetype one of kiem_tu, dan_su, the_tu, tran_su, linh_thuc_su, phap_tu, tan_tu; gear `1 + realm index` pieces, max 3, each `{base, grade 1-4, element}` or `{named: id}`; tree `start` = an element or variant they own, `intent` = a sentence (no node ids) |
| `items` | A, B | named item ids they hold (in `<key>.items.json` or `design/items/`) |
| `exception` | if any | R2 exception reason (guest elder, servant, root changed, hostage...) |
| `changed` | if any | for an existing cast member: what this pass changed and why |

## `sects/<key>.techniques.json`: lineage and new techniques

```json
{"sect": "bang_tam",
 "lineage": {"main": "<id>", "secret": [{"id": "<id>", "rank": "noi_mon"}], "body": null, "outer": "<id>",
             "elements": ["thuy", "bang"]},
 "techniques": [ {technique proposal}, ... ]}
```

A technique proposal: `id` (kebab-case), `name` ("English (Hán-Việt)"), `tier` (0 Yellow, 1 Profound, 2 Earth,
3 Heaven, as `design/techniques/`), `tech_kind` (main / secret / body), `names` (element or variant ids it runs on),
`layers` (Yellow 6, Profound 9, Earth 12, Heaven 15, as the catalogue), `rank` (who may learn it), `concept` (2-4
sentences: how it cultivates or fights), `arts` (existing art ids from `design/arts/` or `{"new": "Name (Hán-Việt)",
"concept": "..."}`), `lore`, `status: "proposal"`. Unpriced.

## `sects/<key>.items.json`: signature items and sets

```json
{"sect": "bang_tam", "items": [ {item}, ... ], "sets": [ {set}, ... ]}
```

An item follows `design/items/` (`id`, `name` "English (Hán-Việt)", `family`, `kind` artifact/treasure, `base` from
`design/items/bases.json`, `grade` 1-4, `modifiers` [{key, value, scope}] with keys used in `design/items/`,
`effects` (rule text, unpriced), `arts` optional, `lore`, `build_use`) plus `holder` (person key), `made_by`,
`made_year`, `set` (set id or null), `status: "proposal"`.

A set: `id`, `name`, `pieces` (item ids, 2-5), `bonuses` [{pieces: n, modifiers: [...]}, {pieces: full, effect:
"rule text"}], `story`.

## `people/<group>.cast.json`: people outside sects

Same person schema, `sect: ""`; the group file names its group (loose cultivators of a region, a clan, a merchant
house, a hermitage, a demonic circle). A group page `people/<group>.md` holds its shared story.
