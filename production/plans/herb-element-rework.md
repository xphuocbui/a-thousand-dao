# Plan: herb element rework (decided 2026-11-21, during /design-system alchemy)

Status: **decided; amendments owed.** Alchemy (`design/gdd/alchemy.md`) carries the recipe side now. The rest is
applied after the Spirit Herbs review loop finishes (that loop must not have its file edited mid-run).

## The user's decisions (2026-11-21)

1. **Five basic herbs, one per element**, reusing the five existing low-rarity herbs: Ngưng Khí Thảo (Wood),
   Thanh Tâm Liên (Water), Hỏa Linh Chi (Fire), Hoàng Tinh Sâm (Earth), Kim Tủy Quả (Metal). There are also
   **multi-element herbs** (some herbs with two or more elements); the other five current herbs become multi-element
   herbs or are retired, decided with the catalogue.
2. **No tier grid: a herb's worth is its value from age**, Item Database Formula B (`base_value × E(age / mature_years)`,
   linear to maturity, a plateau, then doubling past the knee: the 2026-11-20 curve is kept).
3. **Recipes ask for element value**: an ingredient is "element ≥ V". Any herbs of that element add up by value, so
   many young herbs replace an old one (full substitution).
4. **A multi-element herb fills one ingredient of any one of its elements at its full value** (once per use).

## Owed amendments

| GDD / data | Change | Note |
|---|---|---|
| Alchemy (#15) | Recipes as (element, value); ρ = value put in ÷ needed; margin lint on values; breakthrough recipes translated to values | **Done** in Core Rules 2, 5, 9, 11, 12 (2026-11-21) |
| Item Database (#13) | Catalogue: 5 basic + multi-element herbs; **re-tune Formula B's knee and doubling per herb (or in years)** | A short-lived herb otherwise explodes: Ngưng Khí Thảo (mature 1) at age 10 would be worth about 113,000 |
| Trade Goods (#45, approved) | The 11-herb catalogue becomes 5 basic + multi-element herbs; recipes' inputs by element value | Amendment to an approved GDD |
| Spirit Herbs (#14) | The seed rarity gate (Kim Tủy Quả is rarity 4, sold only from Core Formation); catalogue references | After its review loop |
| Realms (#8) | Formula D pill supply from herb-years and `min_age` to element value; re-run the calibration | Harness task |
| Data | `items_herbs.json` (catalogue, elements as a list), `items_recipes.json` (ingredients by element value) | Implementation |

## Facts found while deciding

- At maturity the five basics earn almost the same value per herb-year (about 2; Kim Tủy Quả 3), so value-based
  recipes treat elements fairly before the knee.
- Translating the Core Formation pill: 2 Kim Tủy Quả at 42 (value 126 each) + Xích Huyết Đằng at 18 (value about 41)
  gives Metal ≥ 252 + Fire ≥ 41.
