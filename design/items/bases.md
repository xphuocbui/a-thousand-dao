# Artifact bases

> Generated from `bases.json` by `tools/design/items/make_md.py`; edit the JSON. Rules: `design/gdd/item-database.md`
> rules 6, 11 and 21, Formulas D and E. **Built** bases are in game data; **new** ones join the rolled pool when the
> catalogue goes into data.

| Base | Roles | Attack / defence | Thần thức | Value | Weight | Damage | Gives when rolled | Status |
|---|---|---|---|---|---|---|---|---|
| **Phi Kiếm** (Flying Sword) | weapon | 30 / 0 | 20 | 20 | 25 | Physical | attack art: Flying Sword Strike (Phi Kiếm Trảm) (c 1.97, cost 0.030, 2 s) | built |
| **Ấn** (Seal) | weapon | 40 / 5 | 30 | 25 | 10 | Physical | attack art: Seal Slam (Ấn Áp) (c 3.20, cost 0.050, 5 s) | built |
| **Chuông** (Bell) | ward_gear | 10 / 25 | 25 | 25 | 10 | Physical | ward: Golden Bell (Kim Chung Tráo) (starter ward) | built |
| **Hồ Lô** (Gourd) | weapon, utility | 25 / 10 | 25 | 25 | 8 | Physical | attack art: Gourd Spout (Hồ Lô Phún) (c 2.46, cost 0.040, 3 s) | built |
| **Thuẫn** (Shield) | ward_gear | 0 / 35 | 15 | 18 | 12 | Physical | ward: Golden Light Shield (Kim Quang Thuẫn) (starter ward) | built |
| **Giáp** (Armour) | body_gear | 0 / 30 | 5 | 18 | 12 | Physical | ward: Black Tortoise Shell (Huyền Quy Giáp) (starter ward) | built |
| **Phiến** (Fan) | weapon | 32 / 5 | 25 | 22 | 8 | Physical | attack art: Fan Gust (Phiến Phong) (c 2.09, cost 0.030, 2.5 s) | built |
| **Châm** (Needle) | weapon | 22 / 0 | 10 | 15 | 8 | Physical | attack art: Needle Rain (Châm Vũ) (c 1.48, cost 0.020, 1 s) | built |
| **Kỳ** (Flag) | utility | 15 / 15 | 20 | 20 | 7 | Physical | modifiers only | built |
| **Phủ** (Axe) | weapon | 45 / 0 | 25 | 22 | 8 | Physical | attack art: Mountain Cleave (Khai Sơn Phủ) (c 3.20, cost 0.050, 5 s) | new |
| **Tiền Tiêu** (Coin) | weapon | 18 / 0 | 8 | 12 | 6 | Physical | attack art: Coin Shot (Tiền Tiêu Kích) (c 1.48, cost 0.020, 1 s) | new |
| **Cầm** (Zither) | weapon | 28 / 4 | 25 | 25 | 5 | Force | attack art: String Cut (Cầm Huyền Trảm) (c 2.20, cost 0.035, 2.5 s) | new |
| **Mao** (Anchor) | weapon | 35 / 10 | 30 | 24 | 4 | Physical | attack art: Anchor Drop (Mao Trầm) (c 3.45, cost 0.050, 6 s) | new |
| **Cổ** (Drum) | utility | 10 / 10 | 20 | 22 | 5 | Physical | modifiers only | new |
| **Kính** (Mirror) | utility | 8 / 16 | 18 | 22 | 6 | Physical | modifiers only | new |
| **Hương Lô** (Censer) | utility | 5 / 5 | 10 | 20 | 5 | Physical | modifiers only | new |
| **Đăng** (Lantern) | utility | 8 / 8 | 15 | 20 | 5 | Physical | modifiers only | new |
| **Lạc Thiết** (Branding Iron) | utility | 20 / 0 | 15 | 18 | 4 | Physical | modifiers only | new |
| **Lôi Trượng** (Lightning Rod) | utility | 15 / 5 | 20 | 22 | 4 | Lightning | modifiers only | new |
| **Nhẫn** (Ring) | ring | 0 / 0 | 8 | 15 | 14 | Physical | modifiers only | new |
| **Ngọc Bội** (Necklace (jade pendant)) | necklace | 0 / 0 | 10 | 18 | 10 | Physical | modifiers only | new |
| **Đạo Bào** (Robe) | body_gear | 0 / 18 | 6 | 16 | 10 | Physical | ward: Qi-Scattering Robe (Tán Khí Bào) (starter ward) | new |

**Notes**

- **Giáp**: Heavy armour: the most body defence
- **Kỳ**: The Five-Phase Flag (Ngũ Hành Kỳ) the builds asked for is a named Kỳ, not a base
- **Phủ**: Slow and heavy (dual-metal-wood, The Woodcutter)
- **Tiền Tiêu**: Thrown, cheap, Metal-tagged (single-metal, Gold Rain)
- **Cầm**: Music arts (triple-metal-water-wood, The Zither Player); a [music] form tag would be new in the Modifier vocabulary
- **Mao**: A heavy lock tool (triple-earth-metal-water, The Anchor)
- **Cổ**: Rhythm focus (variant-thunder, The Thunder Drum)
- **Kính**: Light statuses (variant-combos, The Eclipse)
- **Hương Lô**: Holds an incense soul art; cheap to control (triple-wood-fire-earth, The Incense Burner)
- **Đăng**: Holds a reactive Effect (triple-water-wood-fire, The Lantern Healer)
- **Lạc Thiết**: Curse focus (triple-metal-water-fire, The Executioner); authored utility though its numbers read as a weapon
- **Lôi Trượng**: Holds the Effect (variant-thunder, The Tribulation Rider); authored utility
- **Nhẫn**: Worn; costs thần thức only in an extra slot (rule 11)
- **Ngọc Bội**: Worn; costs thần thức only in an extra slot (rule 11)
- **Đạo Bào**: Light armour: less body defence than Giáp; affixes lean to resistance and thần thức

Common arts are in `common-arts.json` (art records, linted by `tools/design/arts/lint_arts.py`). Common wards
are the starter wards of `design/gdd/combat-defence.md` Formulas H, already price-checked.
