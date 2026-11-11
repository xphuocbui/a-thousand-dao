# Staging: mirror-hide

## Modifiers

| ID | Name (Hán-Việt) | Stat and size | Form | Channel | Layer | Fit | Suggested home | Used by | Notes |
|---|---|---|---|---|---|---|---|---|---|
| return-share | Return Share (Phản Lượng) | `return_share_pct` +3 / +12 points; armour 30 | Flat base | return | none | Needs key | Tree, armour, technique | mirror-hide | Base of the Return channel |
| return-damage | Return Damage (Phản Thương) | +2 % / +12 % with the `return` tag | Increased | return | L1 | Needs key | Tree | mirror-hide | Tag `return` is new |
| return-more | Return More (Phản Trọng) | +30 points more, `return` tag | More | return | L2 | Needs key | Technique, Đạo | mirror-hide | |
| weight-of-the-hide | Hide Hardens (Bì Cứng) | +4 points return more per 5 block rating, up to +60 | Per | return | L2 | Needs key | Technique | mirror-hide | Second home: any block build |
| tick-return-weight | Tick Return Weight (Dư Thương) | ticks count 25 % toward return, +12 points a notable | Per | return | none | Needs key | Tree | mirror-hide | |
| return-cap-shift | Return Cap Shift (Phản Hạn) | +0.25 to `ret_cap` (base 2.0) | Cap shift | return | none | Needs key | Sealed cluster capability | mirror-hide | Rare one-off |

## Effects

| ID | Name (Hán-Việt) | Rule | Fit | Suggested home | Used by | Notes |
|---|---|---|---|---|---|---|
| held-reflection | Held Reflection (Tồn Ảnh) | Return clipped by `ret_cap` is banked, up to 3 U x stage; Open the Mirror spends it | Needs rule (effects.md overflow bank) | Đạo node, cluster | mirror-hide | Uses `held-payload` |
| self-wound-counts | Self-Wound Counts (Tự Thương Cũng Trả) | Health paid by your arts counts as a hit taken, once per cast | Needs rule (combat-defence.md rule 1) | Đạo, art | mirror-hide | See suggestion |
| boil-returned | Boil Returned (Phản Độc) | When a tick stack on you ends or is cleansed, 40 % of its total returns as a hit | Needs rule (effects.md event) | Đạo | mirror-hide | Uses `cleansed-stacks-event` |
| bait | Bait (Mồi Nhử) | Curse: enemy basic cooldown 20 % shorter | Needs rule (combat.md rule 8) | Art, Đạo | mirror-hide | See suggestion |

## Enablers

| ID | Name (Hán-Việt) | Kind | Lives on | Opens | Closes | Fit | Used by |
|---|---|---|---|---|---|---|---|
| mirror-scale-hide | Mirror-Scale Hide (Kính Lân Giáp) | New channel | Named body armour | The Return channel at 30 % of incoming damage, blocked part included | Wards (default ward too) and evade | Needs rule (combat.md Formulas G2) | mirror-hide |

## Artifacts, talismans, pills, formations

| ID | Name (Hán-Việt) | Type | What it does | Fit | Used by | Notes |
|---|---|---|---|---|---|---|
| quiet-mirror-talisman | Quiet Mirror Talisman (Tĩnh Kính Phù) | Talisman | Guard: a soul hit arrives; returns 30 % of the soul damage it stops as soul damage | Needs rule (soul ward return) | mirror-hide | The soul answer |
| bruise-blossom-pill | Bruise-Blossom Pill (Ứ Hoa Đan) | Pill | +5 Return Share for the fight; raises pill toxicity | Needs key (pill fight payload) | mirror-hide | |
| echo-wall-array | Echo-Wall Array (Hưởng Bích Trận) | Formation | Prepared return damage, L4 | Needs key (combat formation payload) | mirror-hide | |

## Công pháp

| ID | Name (Hán-Việt) | Kind and tier | What it gives | Fit | Used by | Notes |
|---|---|---|---|---|---|---|
| mirror-skin-scripture | Mirror-Skin Hundred Tempering Scripture (Kính Bì Bách Luyện Kinh) | Main, Địa giai | Health 14 %, block 6; Hide Hardens, Return Share small, Open the Mirror | Needs key | mirror-hide | |

## Arts

| ID | Name (Hán-Việt) | Source | Kind, tags | c_art / cost / cooldown | Rule | Fit | Used by |
|---|---|---|---|---|---|---|---|
| needle-mark | Needle Mark (Châm Ấn) | Scripture, 2 | elem, Metal, debuff | 0.3 / 0.03 / 3 s | 3 Metal stacks 10 s | Needs key | mirror-hide |
| open-the-mirror | Open the Mirror (Khai Kính) | Scripture, 8 | phys, Metal, return | 3.6 / 0.06 / 6 s | Hit plus the Held Reflection bank | Needs rule | mirror-hide |
| offering-cut | Offering Cut (Hiến Huyết Thức) | Đạo node | body, Metal | 0.8 / health 0.05 / 4 s | Health cost counts as a hit taken | Needs rule | mirror-hide |
| thorn-chorus | Thorn Chorus (Kinh Hợp Xướng) | Scripture, 10 | phys, Metal, return | 1.2 / 0.04 / 4 s | +5 % per return since last cast, up to 10 | Needs key | mirror-hide |

## Đạo pieces

| ID | Name (Hán-Việt) | Way and facet | Kind | What it does | Fit | Used by |
|---|---|---|---|---|---|---|
| nhan-qua-bao-ung-return | Every Blow Comes Home (Nhân Quả: Báo Ứng) | Nhân Quả Đạo, Retribution branch | Keystone and nodes | Returns cannot be evaded; tick weight 50 %; holds Held Reflection, Boil Returned, Offering Cut | Needs rule | mirror-hide |

## Concepts and keys

| ID | Name | Kind | What it is | Fit | Used by |
|---|---|---|---|---|---|
| return-channel | Return channel (Phản) | Rule | Free hit per incoming hit part, `ret_cap` per hit, depth 1, outside the trigger budget | Needs rule (combat.md Formulas G2) | mirror-hide |
| incoming-hit-readable | Incoming hit readable | Rule | An Effect can read the size of the hit that reached the defence path | Needs rule | mirror-hide |
| scarred-hide-cluster | Scarred Hide (Sẹo Bì) | Cluster idea | Body Tempering, Earth, sealed, 8 acupoints; capability Return Cap Shift | Needs key | mirror-hide |

## Reused

| ID | Found in |
|---|---|
| packed-earth-stance | staging |
| mending-breath | staging |
| held-payload | staging |
| cleansed-stacks-event | staging |
| preparation-fight-payload | staging |
| hot-spring-array | staging |
| iron-sand-hand-bath | staging |
| stone-marrow-pill | staging |
| hoi-xuan-affix | staging |
| Thorned Skin (Kinh Bì) | tree catalogue |
| Iron Marrow (Thiết Tủy) | tree catalogue |
| Thorns (Kinh Thứ) | missing pieces |
