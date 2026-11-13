# Named-Item Catalogue

> **Status**: First complete draft, 2026-11-12, patched 2026-11-13: 168 named items in 13 families, accepted for now by
> the user. Not in game data.
> **Rules**: `design/gdd/item-database.md` rules 6 (roles), 11 (base and extra slots), 20 (named items: copies,
> sources, refining), 21 (what an item gives, a blueprint with marked exceptions) and Formulas I (the plain-modifier
> budget); modifiers priced by `design/gdd/modifiers.md` Formulas A–B; Effects from `design/gdd/effects.md`; item arts
> are Combat art records; wards inherit their price check from the starter wards of `design/gdd/combat-defence.md`
> Formulas H.

## Files

| File | Holds |
|---|---|
| `bases.json` / `bases.md` | The 22 artifact bases: 9 built and 13 new (10 kinds the build catalogue asked for, plus ring, necklace and robe), with what each gives when rolled |
| `common-arts.json` | The common attack art of each weapon base (9), as art records |
| `catalogue-<family>.json` / `.md` | A family's named items; the `.md` is generated, so edit the JSON |

## Shape (user decisions 2026-11-12)

- 13 families: the 12 art families (blade, body, earth, fire, force-chaos, ice, metal, soul-song-seal, thunder, water,
  wind, wood) plus `general`. About **10 per family**: 2 Hạ, 3 Trung, 3 Thượng, 2 Cực (unique), so about 130 items
  and 26 unique ones.
- Each family mixes slots: weapons (an attack art), armour (a ward), rings and necklaces (an Effect or modifiers, and
  maybe a reserve art), and a utility treasure for the extra slots.
- Plain modifiers spend up to the grade's budget (Formulas I: 12.8 W per affix the grade allows). Effects are
  unpriced. New Effects are written inline, marked `"new": true`, for promotion into `effects.md` once approved.
- An item art may name a công pháp suite as its `group`, so the suite's engines count it (Red Sun Seal).

## Item record

`id`, `name` (English (Hán-Việt)), `family`, `kind` (artifact or treasure), `base`, `grade` 1–4 (a treasure has
`rarity` 4–5 instead), `modifiers` [{key, value, scope}], `effects` [an `effects.md` name, or a new record], `arts`
[art records], `wards` [{id, name, payload, payment, activation, check_from}], `reserve_arts` [{id, name, reserve,
rule}], `exception` (a reason, when the item breaks the rule 21 blueprint), `sources` (event, npc, quest, craft),
`holder` (where a unique item sits at world start), `lore`, `build_use`.

## Checks

- `python -I tools/design/items/lint_items.py`: the budget, modifier keys and scopes, Effect names, the bases, unique
  items never crafted, the rule 21 blueprint and its marked exceptions, ward records, reserve shares, and every item
  art through the art lint (and so the combat engine's validator). Fire pilot: **10 items, 0 findings**.
- `python -I tools/design/items/make_md.py` regenerates the `.md` pages.

## Decided at the fire pilot review (user, 2026-11-12)

1. **Item arts may join a công pháp suite** (`group`) on named items only, with no limit on how many count for one
   suite (item-database.md rule 20a). Common and rolled arts never name a suite; the lint checks it.
2. **Reserve arts are priced** at `reserve_w_rate` 1.0 W of modifiers per percentage point of maximum linh lực
   reserved, on top of the item's budget (Formulas I). Effects inside them stay unpriced.
3. **The three new Effects stay as written:** Phoenix Mend, Fan the Pyre, Embers Never Die. Fan the Pyre makes Burn
   grow without limit while the hits keep landing; run it in the fight sim before the items go into data.
4. **Spend 80–100 % of the budget**; an item whose main value is a strong enabler may go to about 60 % and says why.
   The lint notes a lower spend.

## Decided at the full-catalogue review (user, 2026-11-12)

5. **All 130 items stand** (12 families written by headless Sonnet sessions from the fire pilot; `_logs/`).
6. **The general Heaven-Purchasing Coin carries Bought Fate** (once a fight a roll against you flips, paid in spirit
   stones), so the metal Heaven-Minted Coin alone carries Seal of Full Payment, for Gold Rain.
7. **Edge Returns the Breath and Whetstone Vow stay item Effects** (metal), though `missing-pieces.md` proposed them as
   Meridian Map keystones; a future tree keystone can be a stronger version with a harsher cost.
8. **The 27 new Effects are accepted for now** (each marked `status` in its record). They are not in `effects.md` yet;
   promoting them is a separate, section-by-section step.

## Patch 2026-11-13 (from the engine-v3 build round)

38 items appended to the 13 families (168 in all, 27 unique), each answering asks the playtested builds made
(`_logs/patch/asks-<family>.md`, and `notes` on each item says which): 8 armour pieces with standing drain wards the
combat sim runs, 10 rings above grade 1 (thunder, wind and fire among them), 6 cheap extras at 10 thần thức, 10 items
with `than_thuc_pct`, and lost signature pieces of the old builds (Embers Feed the Hearth, Scatter Gale, Owed Water,
the Armoury Banner). 8 more new Effects, marked "accepted for now" like the first 27. No existing item changed; the
lint is clean. Asks that are not items (engine, effects.md, enemy design, techniques) are in `_logs/patch/not-items.md`.

## Open

- **Promote the 35 new Effects into `effects.md`** (with the user, section by section). Worth a look then:
  Deep Freeze (ice) is Rime Lock repeating at every 10 Ice stacks, and five Effects now delay the foe's next art
  (Soul Wound, Rime Lock, Deep Freeze, Plucked Time, Gripping Root), so delay may need one shared rule.
- **Fan the Pyre** in the fight sim before the items go into data.
- **Into game data:** the 13 new bases, the common arts, the ring, necklace and robe roles, and the named items
  (`items_artifacts.json` and a named-item file); the Item Database build gaps of rules 11, 20 and 21 come with it.

- New wards are scaled starter wards (payload and payment by the same factor), so their price check is inherited,
  not run; a ward price-check tool does not exist yet.
- `reserve_w_rate` (1.0) is a guess. `named_W_tolerance` is 1.05 since 2026-11-13 (item-database.md Open Question 19).
