# Named-Item Catalogue

> **Status**: Pilot, 2026-11-12. The fire family only, for the user's review before the other 12 families are written.
> Not reviewed, not in game data.
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

## Open

- New wards are scaled starter wards (payload and payment by the same factor), so their price check is inherited,
  not run; a ward price-check tool does not exist yet.
- `reserve_w_rate` and `named_W_tolerance` are guesses (item-database.md Open Question 19).
