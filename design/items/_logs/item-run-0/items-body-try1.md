# Job transcript: items-body (try 1)

I wrote `design/items/catalogue-body.json` with 10 body-family items. The lint reports 0 findings on `python -I tools/design/items/lint_items.py design/items/catalogue-body.json`, and every spend is at or above its 80 % target. I did not run any fight sim; the numbers are first guesses.

| Grade | Item | Slot | What it gives |
|---|---|---|---|
| 1 | Bone Cleaver (Phách Cốt Phủ) | weapon (Phủ) | Bone-Splitting Chop: a slow chop that writes 1 Debt and some body shield |
| 1 | Ring of Tempered Marrow (Luyện Tủy Giới) | ring | modifiers only |
| 2 | Mountain-Hide Armour (Sơn Bì Giáp) | armour (Giáp) | ward at 1.4 × Black Tortoise Shell |
| 2 | Mountain-Gate Shield (Sơn Môn Thuẫn) | ward gear (Thuẫn) | ward at 2 × Golden Light Shield |
| 2 | Stone-Marrow Pendant (Thạch Tủy Bội) | necklace | reserve art at 10 % reserved, granting body shield and block |
| 3 | Seal of Unbroken Flesh (Bất Hoại Nhục Ấn) | weapon (Ấn) | Flesh-Seal Slam, in suite `unbroken-flesh-canon` |
| 3 | Ring of Renewed Iron Skin (Thiết Bì Phục Giới) | ring | Iron Skin Renewed |
| 3 | Echo-Skin Drum (Hưởng Bì Cổ) | utility (Cổ) | Echo |
| 4 | Vajra-Hide Armour (Kim Cương Bì Giáp) | armour (Giáp) | ward at 2 × Black Tortoise Shell, plus the new Effect Shield Pays the Blood |
| 4 | Mountain-Splitting Axe (Phích Sơn Phủ) | weapon (Phủ) | Splitting the Mountain, plus Blood Drinker |

- **Flesh-Seal Slam:** it writes 2 Debt and some body shield, and its x3.5 step needs 4 Debt and a 20 % body shield. It is x2.83 of the lint, gated.
- **Splitting the Mountain:** its x4.5 step needs 5 Debt plus either Mountain Root or a 30 % body shield. It is x3.87 of the lint, gated.
- **Shield Pays the Blood:** health costs of your arts are paid from your body shield first. It closes with "Your healing is 20 % weaker." It is the only new Effect in the family.
- **Unique items:** the two grade 4 items never list "craft" as a source, and each has a `holder` line.
- **Rule 21:** there are no exceptions in the family.
- **Weaker spends:** the lint prints the Mountain-Splitting Axe at 42.8 W of 51.1 (84 %) and the Echo-Skin Drum at 32.5 W of 38.3 (85 %). Both are above their 80 % targets.

ITEMS-DONE body

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/items/catalogue-body.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/items/catalogue-body.json) instead (Edit rules cover all file-editing tools).
```
