# Job transcript: items-wood (try 1)

I wrote `design/items/catalogue-wood.json` with 10 wood items, and the lint reports 0 findings. To get there I lowered two arts' `c_art`: the needle's from 1.5 to 1.4 and the hatchet's from 2.6 to 2.3. The lint had flagged both as over their limits. Every spend is at 94–100 % of its grade budget except the Slow Garden ring, which is at 86 %. The reserve notes read 10 W of 12 W on the pendant and 5 W of 15 W on the banner.

| Grade | Item | Base | What it gives |
|---|---|---|---|
| 1 | Bramble Needle (Kinh Cức Châm) | Châm | A quick Poison art, `wood-bramble-flick` |
| 1 | Sprout Ring (Manh Nha Giới) | Nhẫn | Modifiers only |
| 2 | Heartwood Hatchet (Tâm Mộc Phủ) | Phủ | Attack art `wood-fell-the-rotting`, in the `rotting-canopy-canon` suite. Its step is gated and eats 8 Poison for 2.4× damage. |
| 2 | Ironbark Cuirass (Thiết Bì Giáp) | Giáp | A ward, scaled 1.3× from Black Tortoise Shell |
| 2 | Sap-Heart Pendant (Dịch Tâm Bội) | Ngọc Bội | Reserve art `wood-verdant-aura` (12 % reserved) |
| 3 | Verdant Cycle Seal (Thanh Hoàn Ấn) | Ấn | Attack art `wood-seal-of-turning-seasons`, in the `verdant-cycle-scripture` suite. It spends 3 Seeds and needs Rooted Form or 8 Wood stacks for 2.8×. |
| 3 | Heartwood Bulwark (Tâm Mộc Thuẫn) | Thuẫn | A ward scaled 1.6× from Golden Light Shield, plus the new Effect Sap Rises (Nhựa Thăng) |
| 3 | Ring of the Slow Garden (Hoãn Viên Giới) | Nhẫn | The existing Effect Spillover |
| 4 | Grave-Silk Robe (Mộ Ti Bào) | Đạo Bào | A ward scaled 1.5× from Fire-Shunning Veil, plus Grave-Silk Shroud |
| 4 | Thousand Roots Banner (Vạn Căn Kỳ) | Kỳ | The new Effect Gripping Root (Triền Căn), plus reserve art `wood-root-web` (15 % reserved) |

The two grade 4 items are unique, each with a `holder` line and no "craft" source.

- **New Effects:** two of the three allowed, Sap Rises and Gripping Root. Both come from the Wood build sheets' "New pieces" and carry no closing cost, since they are minor, not enablers.
- **Exceptions:** none.
- **Build fit:** the Slow Garden and Evergreen Wall builds each get a ring, ward gear and a utility or reserve piece. The Strangler Fig gets the banner. The Woodcutter gets the hatchet.

ITEMS-DONE wood

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/items/catalogue-wood.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/items/catalogue-wood.json) instead (Edit rules cover all file-editing tools).
```
