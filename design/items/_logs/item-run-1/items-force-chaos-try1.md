# Job transcript: items-force-chaos (try 1)

I wrote `design/items/catalogue-force-chaos.json` with 10 items. The lint reports 0 findings, and every spend is at or above 80 % of its grade's budget.

| Grade | Item | Slot | What it gives |
|---|---|---|---|
| 1 | Shock-Wave Zither (Chấn Ba Cầm) | weapon | Attack art that lays Qi Disruption and adds Drink. It joins `hollow-tide-scripture` as its `group`. |
| 1 | Hollow Ring (Không Giới) | ring | Modifiers only. |
| 2 | Hollow Robe (Không Y) | armour | Ward: the Qi-Scattering Robe ward ×1.2. |
| 2 | Ledger-Murmur Pendant (Phế Thanh Bội) | necklace | Reserve art, 10 %. |
| 2 | Ledger Branding Iron (Phế Trướng Lạc Thiết) | utility | Marked Prey. |
| 3 | Balance-Sheet Seal (Kết Toán Ấn) | weapon | Attack art that joins `ruin-ledger-scripture` as its `group`. It pays out only through gated Fray and distinct-status `empower` entries. |
| 3 | Hollow Bell (Không Chung) | ward gear | Ward: the Golden Bell ×1.3. |
| 3 | Ring of the Open Vein (Khai Mạch Giới) | ring | Blood Drinker. |
| 4 | Mirror of Primordial Chaos (Hỗn Nguyên Kính) | utility | New Effect Unmaking Glass, closing cost "own buff stacks last 25 % shorter", plus a reserve art, 15 %. Unique. |
| 4 | Locket of the Last Bargain (Tuyệt Khế Bội) | necklace | Final Clause. Unique. |

- **Grade 4 holders:** the mirror's holder line is a Chaos-root elder at Nascent Soul or above, else Lost in the ruins at the map's centre. The locket's is the Shadow Shrine keeper, else Lost in a sunken tomb on the Darkness island. Neither lists `craft` as a source.
- **New Effects:** one, Unmaking Glass. Both grade 4 items are marked unique in the lint output.
- **Element ids:** the mirror's damage scopes to `hon_don` and the locket's to `am`.
- **Exceptions:** none used, so no `exception` field appears.
- **Not run:** no combat sim, only the lint, so the two item arts' numbers are untested.

ITEMS-DONE force-chaos

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/items/catalogue-force-chaos.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/items/catalogue-force-chaos.json) instead (Edit rules cover all file-editing tools).
```
