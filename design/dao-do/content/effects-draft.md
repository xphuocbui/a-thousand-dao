# Đạo Đồ content: Effects drafted for the tree (DRAFT 2026-11-19)

Step B of `../content-method.md`. These are drafts, hand-designed and **unpriced** (effects.md rules 3-4: an Effect's
payload is its designer's, with no W; its stat, op, scope and grid still validate). They move into `design/gdd/effects.md`
only with the user's approval, section by section. Format as effects.md's Starter Effects. Host `MM` = the Đạo Đồ.
**L5 +N** = N points in Combat's L5 layer, which only Effects may grant (Modifier System rule 6).

## Keystones (24)

Each keystone = its Effect (below or a starter record) + at least 50 W of plain stats (in the area's content file).
Every element land has a linh-lực keystone (dao-do.md Open Question 20). Side = the neighbour it leans toward.

| Keystone node | Land, side | Effect | Starter or new | Build it ends |
|---|---|---|---|---|
| c901 keystone_R (2893) | Fire, toward Earth | Burning Lifespan (Nhiên Thọ) | starter | comeback, dark path, body |
| c901 keystone_L (2892) | Fire, toward Wood | Ever-Burning Furnace (Vĩnh Nhiên Lô) | **new**, linh lực | burn engine |
| c901 keystone_rim_R (2978) | Fire, toward Earth | Alchemist's Heart (Đan Tâm) | **new** | alchemy, pills in fights |
| c901 keystone_rim_L (2979) | Fire, toward Wood | Overheat (Quá Nhiệt) | starter (closing added) | fast fire arts |
| c902 keystone_e (3727) | Earth, toward Metal | No Ward (Vô Hộ) | starter | body, thể tu |
| c902 keystone_w (3726) | Earth, toward Fire | Open Sky (Không Thiên) | starter (closing added) | ward caster |
| c902 keystone_rim_R (3838) | Earth, toward Metal | Immovable Mountain (Bất Động Sơn) | **new** | slow, heavy hitter |
| c902 keystone_rim_L (3839) | Earth, toward Fire | Earth Vein Tap (Địa Mạch Dẫn) | **new**, linh lực | formation caster |
| c903 keystone +12 (4678) | Metal, toward Water | Called Blow (Báo Chiêu) | starter | crit, deterministic |
| c903 keystone -12 (4677) | Metal, toward Earth | Ten Thousand Swords Return (Vạn Kiếm Quy Tông) | **new** | flying swords |
| c903 keystone_rim_L (4787) | Metal, toward Earth | Unyielding Breath (Bất Khuất) | starter | body, last stand |
| c903 keystone_rim_R (4786) | Metal, toward Water | Autumn Harvest (Thu Hoạch) | **new**, linh lực | crit sustain |
| c904 keystone_dark (5508) | Water, toward Metal | Still Water (Tĩnh Thủy) | starter (closing added) | full-pool caster |
| c904 keystone_hook (5507) | Water, toward Wood | Flowing Water (Lưu Thủy) | starter (closing added) | crit tempo |
| c904 keystone_rim_L (5586) | Water, toward Metal | Thousand Talismans (Thiên Phù) | **new** | talisman |
| c904 keystone_rim_R (5585) | Water, toward Wood | Boundless Sea (Vô Biên Hải) | **new**, linh lực | big pool, drain |
| c905 keystone_e (6497) | Wood, toward Fire | Bare Rack (Không Giá) | starter (closing added) | companion, basic attack |
| c905 keystone_w (6496) | Wood, toward Water | Spirit Garden (Linh Viên) | **new** (replaced Endless Spring, 2026-11-19 review: two regeneration keystones in one land) | spirit fields, herbs |
| c905 keystone_rim_R (6618) | Wood, toward Fire | Ten Thousand Poisons (Vạn Độc) | **new** | poison |
| c905 keystone_rim_L (6619) | Wood, toward Water | Sun and Rain (Nhật Vũ) | **new**, linh lực | regeneration caster |
| c931 keystone_gate_R (8994) | Light | Heaven's Eye (Thiên Nhãn) | **new** | Light crit, Exposed |
| c931 keystone_gate_L (8995) | Light | Sun That Never Sets (Bất Lạc Nhật) | **new** | long life, cultivation |
| c932 keystone_tip (8996) | Thunder | Glass Meridians (Lưu Ly Kinh Mạch) | starter | tempo, glass cannon |
| c933 keystone_pendant (8997) | Darkness | Hidden Moon (Ẩn Nguyệt) | **new** | evasion crit |

**Closings added to starter records** (a keystone must close something; these starters have none): Overheat closes
your art costs +35 %; Open Sky closes artifact power −30 % (`artifact_power_pct` −30); Still Water closes healing
taken from every other source −50 % (`healing_taken_pct` −50); Flowing Water closes art costs +40 %; Bare Rack closes
maximum health −15 %. Starters that already close something keep it (Burning Lifespan: 2 % of the realm's base
lifespan in years each time it fires; Unyielding Breath: maximum health −15 %; Called Blow: crit cap 0.50 → 0.35, so
its plain side pays crit damage and art speed, not crit chance). Revised after the 2026-11-19 review. When these move
to effects.md they are keystone variants of the starter, not changes to it.

### New keystone Effects

| Name | Rule | Reads | Payload / action | Limits | Closes | Hosts | Build families |
|---|---|---|---|---|---|---|---|
| Ever-Burning Furnace (Vĩnh Nhiên Lô) | Every Burn stack your hits apply returns linh lực. | Burn stacks applied (event) | +0.2 pp of maximum linh lực per stack | 10 stacks a pulse | Your linh lực regeneration is 0 | MM | Burn, Fire caster |
| Alchemist's Heart (Đan Tâm) | The first pill you take in each fight counts twice. | Pill use (event) | That pill's effect applies a second time | Once per fight | Pill toxicity fades half as fast | MM | Alchemist, pill fighter |
| Immovable Mountain (Bất Động Sơn) | Slowed Time and timer delays never land on you. | Incoming delay or slow | Refusal | — | Art speed modifiers do nothing for you | MM | Heavy hitter, slow arts, body |
| Earth Vein Tap (Địa Mạch Dẫn) | While your own formation stands, your linh lực regenerates faster; with none, not at all. | Own formation, live | `linh_luc_regen_inc_pct` +50 while it stands | — | No linh lực regeneration while no formation of yours stands | MM | Formation caster |
| Ten Thousand Swords Return (Vạn Kiếm Quy Tông) | Your sword arts deal more for each sword artifact you carry. | Carried sword artifacts, compile | L5 +8 per sword artifact | Cap +32 | Only arts with the `sword` form tag may be slotted; your wards are 30 % weaker | MM | Flying swords, sword |
| Autumn Harvest (Thu Hoạch) | Your crits refund the art's cost. | Crit event | Restore the art's linh lực cost | 3 firings per pulse | Your linh lực regeneration is 0 | MM | Crit, Metal caster |
| Thousand Talismans (Thiên Phù) | The talismans you draw before a fight cost no stock for the first two uses. | Talisman use (event) | No stock spent | 2 per fight | Arts that are not talismans deal 30 % less (stock is Pending: the rule switches on with the Talismans GDD) | MM | Talisman |
| Boundless Sea (Vô Biên Hải) | Your linh lực pool doubles but no longer regenerates on its own: only leech, on-crit and overflow restore it. | — | `linh_luc_pct` × 2 at compile; regeneration to 0 | — | As the rule, and linh lực on hit gives nothing | MM | Big pool, drain, Water caster |
| Spirit Garden (Linh Viên) | Herbs in your spirit fields ripen a season sooner. | Field harvest (season) | One season off each growth | — | You can keep at most one spirit beast | MM | Spirit fields, herbs, alchemy supply |
| Ten Thousand Poisons (Vạn Độc) | Your Poison batches last until the fight ends. | Poison batches (rule 9a) | Batch duration to the end of the fight | — | Your hits deal 25 % less (`attack_pct` [hit] −25): poison does the work | MM | Poison, Wood |
| Sun and Rain (Nhật Vũ) | Your health regeneration also restores linh lực, at half the amount (as a share of each pool). | Health regeneration pulse | Restore linh lực | — | Maximum linh lực −30 % (`linh_luc_pct` −30) | MM | Regeneration caster |
| Heaven's Eye (Thiên Nhãn) | Your crits against an Exposed foe deal more. | Crit event, foe's Exposed | L5 +20 on that hit | — | Your ward strength is 30 % lower | MM | Light, crit (pairs with Dawn's Daybreak, which applies Exposed) |
| Sun That Never Sets (Bất Lạc Nhật) | Each season you cultivate, you also gain 1 point of đạo tâm. | Season end (cultivation) | `dao_tam` +1, permanent | +10 per realm | You can never conceal yourself (stealth counts 0, Concealed Breath #20 cannot be held); heart-demon resistance −30 % | MM | Long life, cultivation |
| Hidden Moon (Ẩn Nguyệt) | Your evade also counts as crit chance, point for point. | Evade, compile | `crit_chance_pct` + evade | — | Your block and body shield count nothing; maximum health −20 % | MM | Evasion, crit, Darkness |

## Crown Effects of big pictures (12)

Fights are duels (Combat rule 1: a side is one combatant and its companions), so no Effect assumes several foes (revised 2026-11-19).

At most one per big picture, on its crown notable (method §4.6). Smaller than a keystone; no closing cost.

| Name | On (idea) | Rule | Reads | Payload / action | Limits | Hosts | Build families |
|---|---|---|---|---|---|---|---|
| Eruption (Bộc Phát) | Fire F8 Volcano | Your costly Fire arts (cost share 10 % or more) deal more. | The art's cost share (`costly` tag), compile | L5 +15 on those arts | — | MM | Fire caster, big costly arts |
| Wildfire (Dã Hỏa) | Fire F5 Prairie Fire | When one of your Burn batches runs out, half its stacks rekindle as a new batch. | Batch end (event) | New Burn batch, half the stacks, 2 pulses | Once per batch | MM | Burn |
| Burning Ground (Địa Hỏa) | Earth B1 Kiln Hill | Your Earth arts leave burning ground: the foe gains 2 Burn stacks. | Earth art hit | Burn +2 stacks | Once per art firing | MM | Earth-Fire hybrid |
| Grinding Weight (Trọng Ma) | Earth E5 Millstone | Your slow arts apply a stack of Slowed Time. | Slow art hit | Slowed Time +1 stack | Once per art firing | MM | Earth, control |
| Thorns (Đảo Thích) | Wood D6 Thorn Hedge | A blocked hit returns a share of its damage to the attacker. | Block event | Physical damage, 30 % of the blocked amount | Once per pulse | MM | Block, body |
| Tide (Thủy Triều) | Water W3 Moon over the Tide | Your Water damage rises and falls in a 6-pulse cycle. | Fight time | L5 +0 to +20 by the cycle | — | MM | Water caster, tempo |
| Reflection (Phản Chiếu) | Water B5 Mirror Lake | After you evade, your next art deals more. | Evade event | L5 +15 on the next art | Once per evade | MM | Evasion, counter |
| Daybreak (Phá Hiểu) | Light L4 Dawn | Your first Light hit each fight lays the foe bare (Exposed). | First Light hit | Apply Exposed (3 pulses) | Once per fight | MM | Light |
| First Thunder (Tiên Lôi) | Thunder T3 Thunder Step | Your first art each fight fires at `cooldown_min`. | Fight start | Move a timer | First firing only | MM | Tempo, opener |
| Heaven's Verdict (Thiên Phán) | Thunder T4 Heaven's Hammer | Your slow Thunder arts deal more against a foe below half health. | Foe health, live | L5 +20 | — | MM | Burst, Thunder |
| Dark of the Moon (Sóc Ám) | Darkness K3 New Moon | After you evade, your next hit crits. | Evade event | Next hit crits | Once per pulse | MM | Evasion, crit |
| Before Heaven (Tiên Thiên) | Hub H4 Before Heaven | Your damage and resistance grow with the number of elements your root owns. | Root elements, compile | L5 +4 and `resist_pct` +40 per owned element | Cap 5 elements | MM | Chaos root, hybrids |
