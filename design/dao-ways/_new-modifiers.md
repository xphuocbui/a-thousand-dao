# Đạo Ways: new modifiers and statuses

> Overnight 2026-11-11. The stat keys and statuses the Way drafts use that the game does not have yet. They are taken
> from each Way's **Theme stats** and **New pieces**, and checked against `tree-modifier-catalogue.md`,
> `character-stats.md`, `modifiers.md`, `combat.md` and `effects.md`. Comprehension and fortune already exist
> (`ngo_tinh`, `khi_van`), and the drafts now use those names. Sizes follow the catalogue's convention (a narrower
> key gets a bigger number) and are first guesses.

## New modifiers (plain numbers on a stat)

| Key (proposed) | What it is | Small / notable | Catalogue row it fills | Ways |
|---|---|---|---|---|
| `status_duration_pct` (scope: curse, fear, blind, exposed…) | Duration of statuses you apply | +2 % / +12 % | "Status duration" ○ | 24 Ways (Băng, Vụ, Quang, Ám, Sinh Tử, Trấn, Ấn, Ti, Điếu and others) |
| `status_chance_pct` | Chance your statuses land through status resistance | +1 % / +6 % | "Status chance" ○ | Mệnh |
| `companion_damage_pct` (scope: beast, ghost, spirit, clone, ink, gu) | Companion damage | +2 % / +12 % | "Companion damage" ○ | Thú, Mộc, Quỷ, Cốt, Hồn, Độc, Họa, Cầm, Tình, Phân Thân |
| `companion_speed_pct` | Companion attack speed | +1.5 % / +10 % | "Companion attack speed" ○ | Thú |
| `creature_damage_pct` | Damage to creatures (needs the `creature` foe tag, Pending CB-08) | +2 % / +12 % | none | Xạ, Trấn, Thú |
| `talisman_power_pct` | Talisman strength | +2 % / +12 % | "Talisman power" ○ | Trận, Kỹ |
| `renown_pct` | Renown gained | +2 % / +12 % | none | Bồ Đề, Hồng Trần, Mị, Hiếu, Thệ, Sư, Hiệp, Hoàng, Thần |
| `technique_mastery_pct` | Technique mastery speed | +2 % / +12 % | none | Sư, Ngọc, Luân Hồi |
| `craft_success_pct` (scope: refining, brewing, drawing) | Crafting success | +1 % / +6 % | none (alchemy has `alchemy_success`) | Kỹ, Tửu |
| `inventory_slots` | Carried item slots | +1 / +4 | none | Càn Khôn |
| `material_yield_pct` | Materials from creatures and harvests | +2 % / +12 % | none | Xạ, Tứ Thời, Thú |
| `stack_duration_pct` scoped by element | Already a key; scoping by element is new | as the key | "Needs key" in Kim | Kim, Mộc, Hỏa, Thổ, Băng and others |

## New statuses and curses (for the Effects System's Status Catalogue)

| Status | Kind | Rule | Ways |
|---|---|---|---|
| Veiled (Ẩn Vụ) | self-buff | Foe hits −25 pp accuracy until you hit | Vụ |
| Fogged / Dusted (Vụ / Bụi) | debuff stacks, no cap | −0.8 to −1 pp accuracy per stack (**one key for both**) | Vụ, Huyễn, Họa |
| Drowned (Chìm) | qi tick | 0.6 % of max linh lực a pulse, passes every shield | Vụ |
| Weighed (Áp Trọng) | curse | −15 % art speed | Thổ |
| Slowed Time (Thời Hoãn) | curse | Timers run 4 % slower per stack, to 5 (shared rule R1) | Thời, Băng |
| Blinded (Mù) | curse | −10 pp accuracy, −5 pp crit chance, stacks to 3 | Ám |
| Bound (Trói) | debuff stacks | −3 % art speed, −1 pp evade per stack, to 10 | Ti |
| Corrupted (Ma Nhiễm) | curse | −8 Chaos resistance, −4 % healing taken per stack, to 5 | Ma |
| Enthralled (Mê) | curse | Foe hits −30 %, its arts wait 0.3 s | Mị |
| Afraid (Sợ) | curse | Counted 1-in-4 hesitation of 0.5 s | Tình, Long |
| Possessed (Nhập) | curse | Foe's next art also hits itself for 30 % | Quỷ |
| Sealed Qi (Phong Khí) | curse | Foe may spend at most 8 % of max linh lực a pulse on arts | Trấn |
| Paralytic (Tê Liệt) | curse, poison tag | −10 % art speed | Độc |
| Internal Injury (Nội Thương) | stored damage | Released past shields every 3 s | Chưởng |
| Ghost Fire (Quỷ Hỏa) | soul tick | 10 % of the soul hit a pulse (needs a rule: soul never ticks) | Quỷ |
| Commanded (Hiệu Lệnh) | curse | The foe's next art fires at a moment you set | Nho |
| Rift (Liệt Không) | debuff stacks | Ward shields stop 6 % less per stack, to 5 | Càn Khôn |
| Hooked (Mắc Câu) | curse | No escape, evade 0 | Điếu |

## New self-counters (shared rule R7)

Fury, Spin, Hunger, Obsession, Resonance, Dragon stacks, Calamity stacks, Stillness, Boundless, Petals, Yin, Yang,
Stars, Seal Marks (on the foe), Line Weight, Tipsiness, Dew. If R7 is accepted, these are one record shape with a
`growing` tag.

## Life resources (shared rule R13)

Merit (công đức), Incense, Blood Purity, Dao Heart, Calamity Marks, Soul charges, Righteousness, Loneliness, Battle
Streak, kill count, Turned Demons, Mastery per art.
