# Technique catalogue: blade family (element-less weapon forms)

Three techniques carry the 8 signature arts of the blade family: one per suite and one carrier for the group-less
Debt Blade. All name Metal (kim), the weapon element. Hunter's Reach Canon is the main method; the other two are
secret arts (bí thuật). Passives are plain modifiers that feed each suite's engine; no new rules.

## Afterimage Sword Canon (Tàn Ảnh Kiếm Kinh)
Secret art (bí thuật), Earth (Địa, tier 2), 12 layers. Names: kim. Suite `afterimage-sword-canon`.

| Layer | Art unlocked |
|---|---|
| 1 | Flurry Stance (Loạn Đao Thế) |
| 2 | Phantom Sword (Huyễn Ảnh Kiếm) |
| 4 | Triple Draw (Tam Bạt Đao) |
| 6 | Flying Sword (Phi Kiếm) |

Passives (24.0 W of 24):
- crit chance +9 pp, scope sword: 6 W
- crit damage +30 pp, scope sword: 6 W
- art speed +10 %: 6 W
- status duration +15 % (Bleed lasts longer): 6 W

Bonuses: attack +10 %, max health (khi huyết) +10 %.

Use: crits make Afterimages (Phantom Sword, Flying Sword hits) and trigger the echo, so stack sword crit chance and
crit damage around it. Art speed and Bleed duration keep Triple Draw's draw counter and the Bleed key of the engines
fed; keep Flurry Stance on for the basic-attack crit stream.

## Hunter's Reach Canon (Liệp Trình Kinh)
Main method (tâm pháp), Yellow (Hoàng, tier 0), 6 layers. Names: kim. Suite `hunters-reach-canon`.

| Layer | Art unlocked |
|---|---|
| 1 | Pinning Arrow (Đinh Tiễn) |
| 3 | Nocked Arrow (Nhập Huyền Tiễn) |
| 5 | Coiling Thrust (Triền Thương Đột) |

Passives (7.5 W of 8):
- crit chance +3 pp: 3 W
- art speed +5 %: 3 W
- status duration +5 %, scope curse (Slowed Time lasts longer): 1.5 W

Bonuses: none (Yellow).

Use: Slowed Time stacks and Coils feed both engines, so every extra art fired per pulse counts; stack art speed,
curse duration and crit (crits lay more Slowed Time and bank arrows). Add cheap, quick bow or spear arts so two canon
arts land in one pulse.

## Debt Ledger Blade (Huyết Trái Đao Lục)
Secret art (bí thuật), Yellow (Hoàng, tier 0), 6 layers. Names: kim. Suite none (carrier of Debt Blade).

| Layer | Art unlocked |
|---|---|
| 1 | Debt Blade (Huyết Trái Kiếm) |

Passives (7.2 W of 8):
- health leech +20 %: 4.2 W
- health regeneration, increased +10 %: 3.0 W

Bonuses: none (Yellow).

Use: Debt Blade pays 5 % health per cast and hits again per 15 % health missing, so build around low health with
leech, regeneration and healing; art speed and extra-hit sources multiply the interest. The lint prices a negative
`art_cost_health_pct` as a subtraction, so no health-cost reduction is on this technique.

```
checked 3 techniques, 0 findings
```
