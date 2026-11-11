# The Armoury Mind (Tàng Binh Thức)

Hang seven treasures on one mind: two of them fill your gear layer, and every one after that strikes, walls or counts.

## Why it works

Four rules of the game make this build.

1. **Gear is one damage layer, and it has a cap.** Your damage multiplier is five layers multiplied together; layer L3 is
   your gear. L3 points = 100 × the total attack of your treasures (pháp bảo) ÷ (your realm's power base × your stage).
   L3 stops at **250 points (×3.5)**. For a top-grade (Cực phẩm) piece made for your own realm, that works out to
   **3 × the base's attack ÷ stage**: a Seal (Ấn) gives 120 points, a Flying Sword (Phi Kiếm) 90, a Needle (Châm) 66.
   So **two or three pieces already fill L3**. Everything you carry after that adds nothing to L3.
2. **Divine sense (thần thức) pays for every piece.** Your divine sense is soul strength (thần hồn) × realm multiplier ×
   stage × (1 + your thần thức bonuses). A piece made for your realm costs its base cost × the same realm multiplier, so
   the multiplier cancels: think in **base-cost units**. A Seal costs 30, a Flying Sword 20, a Shield (Thuẫn) 15, a Needle
   10, Armour (Giáp) 5. A cultivator with soul strength 60 and +50 % divine sense has **90 units**. A piece you cannot
   pay for is worn but does nothing.
3. **You may wear 6 pieces**, plus every artifact slot (`artifact_slots`) you earn.
4. **Ward gear has no cap.** Each unit of "artifact defence ÷ power base" adds **+30 ward strength and +30 ward
   efficiency**. A top-grade Shield gives 1.05 units: +31.5 of each. Stronger, cheaper wards are sustain.

**The engine.** L3 reads the *sum* of attack and stops; this build adds pieces that read the *count*:

- **Garrison Mind (Thủ Khố Tâm)**: every weapon you control strikes the enemy once a pulse (once a second) and lays a
  Metal stack. Each Metal stack makes the enemy take **+1.8 % Physical damage** (more with a pure Metal root:
  ×1.19 at purity 95). Four weapons hold 24 stacks: **+51 %**.
- **Full Rack (Mãn Giá)**: +10 points of L5 for each piece past the third, up to +50.
- **Edge Past the Rack (Giá Ngoại Phong)**: the L3 points the cap throws away become **Physical penetration**, 1 for 1,
  up to 200.
- **Humming Shields (Thuẫn Minh)**: each ward piece gives back 0.3 % of your linh lực every pulse.

**The key numbers** (game formulas at Nascent Soul (Nguyên Anh), stage 1.00; arithmetic, not a fight test):

| | |
|---|---|
| Your rack (7 pieces) | L3 sum 400 → capped at 250; **150 → penetration** |
| Divine sense used | **75 of 90** units |
| Ward from gear | ward strength and efficiency **+83** each |
| Multiplier on your big art | ×3.66 × 3.65 × 3.5 × 2.3 × 1.67 ≈ **×180**, and **×271** with the Metal stacks |
| The game's top-end reference | ×256 |
| Without Garrison Mind | ×180: a third less |

**What it costs:** your soul. With most of your divine sense out on the rack, only the free part and half the bound
part defend you against soul attacks. Binding 83 % of it, a soul hit takes **about 3 times** its usual share.

## What to look for

In the order a player usually finds them.

1. **Spiritual root (linh căn): single Metal (Kim), purity 90 or more.** Purity powers your Metal stacks, and Metal is
   the Way's requirement. *In the game.*
2. **Talents: soul strength (thần hồn) first, then comprehension (ngộ tính).** Every point of soul strength is about
   1.5 units of rack. Some events raise it. *In the game.*
3. **Meridian Map capabilities:** #3 Treasure Nurtured Within (your first piece costs no divine sense and grows +1 % a
   year, to +50 %), #2 Divided Divine Sense (+1 piece, +20 % divine sense), #1 Twin Arms in Harmony (a pair of one
   kind, +15 % attack). *In the game.*
4. **The Way (Đạo): Kim Đạo · Bách Luyện (Hundred Temperings), the Binh Khố facet (the Armoury).** Wanted: an artifact
   slot notable, Cold Iron Order notables, Full Rack, Edge Past the Rack, and the capstone Garrison Mind; from the Lò
   Rèn facet (the Forge), Ore Weight nodes. *The Way is in the catalogue; these nodes are not in the game yet (staged:
   `binh-kho-rack`, `ore-weight`).* A second Way, Hồn Đạo, for divine sense lines and soul resistance. *Not in the game
   yet (staged: `hon-than-thuc-weight`, `hon-ho-lines`).*
5. **Main technique (công pháp): Pass-Garrison Armoury Scripture (Quan Khố Chân Kinh)**, Heaven grade (Thiên giai),
   Metal, to Deity Transformation; an Earth-grade copy (Quan Khố Quyết) for the climb. +22.5 % divine sense, +20 %
   linh lực, +15 ward strength; six arts and seven passives. *Not in the game yet (staged: `pass-garrison-scripture`).*
6. **Arts (thần thông):** Called Blade, Hook and Chain (lays Sundered), Peg-Line Cut (Metal buffs on you), Re-Temper (a
   heal), Rack-Wide Volley (the big blow), Shut the Armoury Door (cleanses soul curses). *Not in the game yet
   (staged: `called-blade`, `hook-and-chain`, `peg-line-cut`, `re-temper`, `rack-wide-volley`,
   `shut-the-armoury-door`).*
7. **Items:**
   - Top-grade (Cực phẩm) Seals, Flying Swords, Needles, Shields and Armour with "Liệt" (weapon attack), "Kiên"
     (artifact defence) and "Linh" (thần thức cost) affixes. *In the game.*
   - The Kindred Vessels affix (Đồng Khí): +4–10 % artifact power for every piece. *Not in the game yet (staged:
     `kindred-affix`).*
   - The Pass-Garrison Rack (Quan Ải Binh Giá), a named rack: +2 artifact slots, +15 % artifact power, weapons cost 15 %
     less divine sense, and it carries Full Rack. *Not in the game yet (staged: `garrison-rack`).*
   - Nine Rods Array and Iron-Sand Hand Bath for foreseen fights. *Not in the game yet (staged: `nine-rods-array`,
     `iron-sand-hand-bath`, from other builds).*
   - Soul-Guarding Lamp (Hộ Hồn Đăng), a ward for your soul. *In the game.*
8. **Enabler: Garrison Mind (Thủ Khố Tâm)**, on the scripture at layer 11 or the Kim Đạo capstone. *Not in the game yet
   (staged: `garrison-mind`).*

## The enabling Effects

- **Garrison Mind (Thủ Khố Tâm)**, the enabler and the identity piece. *At each pulse, each weapon piece you control
  strikes (a small free hit) and, if it lands, lays 1 Metal stack for 6 s.* It needs no art slot and no linh lực. At most
  6 strikes a pulse (the game's trigger limit). **Closes, Thinned Mind:** against soul hits only your free divine sense
  and half of what your pieces bind defend you. *Why the build needs it:* it is what makes the count matter to the
  enemy. *Not in the game yet (staged: `garrison-mind`).*
- **Full Rack (Mãn Giá).** *Your hits deal +10 more (L5) for each piece you control past the third, up to +50.* Seven
  pieces: +40. *Why:* it pays for the pieces L3 cannot use. *Not in the game yet (staged: `full-rack`).*
- **Edge Past the Rack (Giá Ngoại Phong).** *L3 points your gear brings past the cap become Physical penetration, 1 for
  1, up to 200.* *Why:* it turns the waste of the cap into reach against armoured enemies. *Not in the game yet
  (staged: `edge-past-the-rack`).*
- **Humming Shields (Thuẫn Minh).** *Each pulse, restore 0.3 % of your linh lực for each ward piece, up to 1.5 %.*
  *Why:* fuel, and a reason for the ward pieces to be more than numbers. *Not in the game yet (staged:
  `humming-shields`).*
- **Opened Seams (Khai Phùng).** *Your Physical parts deal +15 more (L5) to a target bearing your Metal stacks.* *Why:*
  the stacks are always there, so this is always on. *Not in the game yet (staged: `opened-seams`).*
- **Iron Skin Renewed (Thiết Bì Phục).** *When you fire an art with a Physical part, your body shield regains 2 % of
  your health, once a pulse.* *Why:* every art you fire is Physical, so this is steady body sustain. *In the game.*
- **Steady Breath (Bình Tức).** *+12 more (L5) for Metal arts while your linh lực is at 50 % or above.* *In the game.*

## Modifiers to stack

Most important first.

1. **Divine sense (`than_thuc_pct`) and lower thần thức cost (`than_thuc_cost_pct`, "Linh" affixes, Weapon
   efficiency).** *The budget, not a layer.* Stop when every slot holds a piece you can control; past that, only a
   heavier piece in an existing slot gains anything.
2. **Artifact slots (`artifact_slots`).** *Cap shift on how many pieces you wear.* Each one is a piece more for Garrison
   Mind, Full Rack or the ward. Rare: capability #2, the Binh Khố notable, the named rack.
3. **Artifact power and weapon attack (`artifact_power_pct`, "Liệt").** *Layer L3.* Stop when L3 is at **250**: past
   it, attack is only penetration, up to 200 more. Late in a realm (stage 1.45) every piece is worth a third less, so
   keep a margin of about 100.
4. **Artifact defence ("Kiên", Shields, a Bell).** *Ward strength and efficiency, no cap.* The top-end reference wears
   5 units; this build wears about 3. Each Shield is +31.5 (+41 with Kiên).
5. **Cold Iron Order and Ore Weight (`damage_more` [kim] and [physical]).** *Layer L2.* Stop at **300**.
6. **Full Rack, Opened Seams, Steady Breath.** *Layer L5.* Stop at **100**; you reach about 67 to 77.
7. **Damage and Metal damage (`attack_pct`).** *Layer L1.* Past 200 points each counts half; hard stop at 400 effective.
8. **Crit chance, then crit damage.** *Outside the layers.* Crit chance stops at 50 %.
9. **Soul resistance (`soul_res_pct`).** *Your answer to the close.* Worth more to you than to anyone else.
10. **A formation and a coating.** *Layer L4,* cap 150, foreseen fights only.

## Upgrades to look for

| Piece | Modifier or Effect | What it adds to this build | Where it comes from | In the game or staged | Priority |
|---|---|---|---|---|---|
| Garrison Mind | Effect (enabler): a strike and a Metal stack per weapon piece each pulse | Up to +64 % Physical damage taken; the reason the count matters | Scripture layer 11; Kim Đạo capstone | Staged: `garrison-mind` | core |
| Pass-Garrison Armoury Scripture | `than_thuc_pct` +22.5, six arts, seven passives | The budget and the whole loadout | Main technique | Staged: `pass-garrison-scripture` | core |
| Treasure Nurtured Within | Capability #3: first piece free, +1 %/year to +50 % | 30 units of divine sense back; a Seal at 234 L3 points alone | Meridian Map capability | In the game | core |
| Divided Divine Sense | Capability #2: +1 slot, +20 % divine sense | A seventh piece and room to pay for it | Meridian Map capability | In the game | core |
| Full Rack | Effect: L5 +10 per piece past the third, cap +50 | +40 at seven pieces, +50 at eight | Scripture layer 12; Binh Khố `major`; the named rack | Staged: `full-rack` | core |
| Thần thức | `than_thuc_pct` | More pieces controlled | Tree, Hồn Đạo Thần Thức lines | Stat in the game; Way lines staged (`hon-than-thuc-weight`) | core |
| Top-grade pieces with Liệt / Kiên / Linh | `artifact_attack_pct`, `artifact_defense_pct`, `than_thuc_cost_pct` (local) | L3 with fewer pieces; thicker walls; cheaper pegs | Generated artifacts | In the game | core |
| Edge Past the Rack | Effect: L3 surplus → Physical penetration, cap +200 | +150 penetration at Nascent Soul | Binh Khố `major`; scripture layer 14 | Staged: `edge-past-the-rack` | strong |
| Cold Iron Order | `damage_more` +60 / +40 L2 [kim] | 140 of L2 | Scripture passive; Binh Khố notables | Staged: `cold-iron-order` | strong |
| Ore Weight | `damage_more` +25 L2 [physical] | 50 of L2 | Kim Đạo Lò Rèn nodes | Staged: `ore-weight` (another build) | strong |
| The Pass-Garrison Rack | `artifact_slots` +2, `artifact_power_pct` +15, Weapon efficiency −15 %, Full Rack | Net one more piece and cheaper weapons | Named item (the Cold Pass armoury) | Staged: `garrison-rack` | strong |
| Humming Shields | Effect: 0.3 % linh lực per ward piece each pulse | +0.6 % a pulse with two Shields | Scripture layer 7 | Staged: `humming-shields` | strong |
| Soul-Guarding Lamp | Ward: soul resistance +22.5 pp, soul shield bar 0.10 × (1 + ward strength/100) | Turns the Thinned Mind from a loss to even | Ward | In the game | strong |
| Hồn Hộ lines | `soul_res_pct` | The close's other answer | Hồn Đạo Hồn Hộ facet | Staged: `hon-ho-lines` | strong |
| Opened Seams | Effect: L5 +15 vs your Metal stacks | 15 of L5, always on | Scripture layer 13 | Staged: `opened-seams` | strong |
| Kindred Vessels affix | `artifact_power_pct` +4–10 | Every piece lifts every piece: L3 and walls | Generated artifacts | Staged: `kindred-affix` | nice |
| Weapon efficiency | `than_thuc_cost_pct` on weapon pieces, −6 % notable | Cheaper strikers | Tree; the named rack | Staged: `weapon-efficiency` | nice |
| Nine Rods Array, Iron-Sand Hand Bath | L4 +80, +50 | L4 at 130 in foreseen fights | Formation, coating | Staged (other builds) | nice |
| Twin Arms in Harmony | Capability #1: +15 % attack for a pair | Only penetration once L3 is full | Meridian Map | In the game | nice |
| Thousand-Weight Thought | Effect: bound thần thức → soul attack damage | A soul art as a side channel, if you ever want one | Hồn Đạo Thần Thức facet | Staged: `thousand-weight-thought` (another build) | nice |

## Realm by realm

- **Core Formation (Kết Đan), before the span.** Three or four pieces and the Earth-grade copy of the scripture. Put your
  best Seal first in equip order once you have capability #3: it costs nothing from then on and grows every year.
- **Nascent Soul (Nguyên Anh), the build's home.** Seven pieces; **divine sense is the limit.** A new realm's first
  pieces overflow L3 by 150; Garrison Mind and Full Rack come online. The first soul needle that gets through teaches
  you the Soul-Guarding Lamp.
- **Late Nascent Soul (stage 1.45).** Every piece's attack and defence counts a third less (the stage divides them),
  so L3 falls to about 276 and the penetration almost vanishes, while your divine sense has grown ×1.45. Spend it:
  swap a Needle for a second Seal.
- **Deity Transformation (Hóa Thần).** Ten pieces; **slots are the limit.** Your old Nascent Soul Needles now cost 3
  units (10 × 30 ÷ 100) and still strike, so they go back on the rack while new pieces carry L3. With five strikers,
  30 Metal stacks: ×241 in the layers, about ×396 with the stacks, against the game's top-end ×325.

## How it plays

**The rack (Nascent Soul, equip order):** Nurtured Seal (free), Flying Sword, Needle, Needle, Shield, Shield, Armour.
Divine sense 75 of 90.

**Loadout (six art slots, in order):** Rack-Wide Volley, Peg-Line Cut, Hook and Chain, Called Blade, Re-Temper (at
70 % health), Shut the Armoury Door (only when Slackened Soul or Silence is on you). Ward slots: Common Ward,
Golden Bell, Soul-Guarding Lamp.

**Order of play:** the fight runs itself. From the first pulse four blades strike each second and the Metal stacks
build; Called Blade and Hook and Chain every 2 s keep the enemy Sundered; Peg-Line Cut every 3 s keeps your Metal buffs
up; Rack-Wide Volley lands at 6 s and every 6 s after (sooner with art speed). Put it in slot 1 so it pays first when
linh lực runs short.

**The signature moment:** the first Volley. Its Breakdown shows L3 clipped at 250 with 150 spent as penetration, Full
Rack at +40 for seven pieces, and 24 Metal stacks on a target that takes half again its Physical damage. Seven
treasures on one mind, and six of them are not why it hit.

## What beats it

- **A soul-piercer** (every realm has a soul dealer). Your close makes their soul arts take about three times their
  usual share. Adapt: Soul-Guarding Lamp in a ward slot (its soul shield grows with your ward strength, which your
  Shields raise), Hồn Hộ soul resistance, Shut the Armoury Door slotted. Before a foreseen fight against a soul sect,
  take a piece or two off the rack: unbound divine sense defends at full.
- **An evader.** Strikes and arts can be evaded, so fewer stacks land. Accuracy helps.
- **An Earth body.** Earth buff stacks dampen Physical damage taken and cancel part of your Metal stacks. Penetration
  and Sundered still work.
- **A cleansing ward** (Clear Heart Ward). It takes a quarter of each Metal batch each pulse; the strikes renew every
  pulse, so you win slower.
- **A drainer.** Six arts overspend, as most builds do. Your gear's ward efficiency and Humming Shields carry you.
- **A blind ambush** costs you only L4 (×2.3). The rack, the strikes and the walls are always with you.

## Not in the game yet

Every staged piece this build needs (all in the staging catalogue):

- Enabler and Effects: `garrison-mind`, `full-rack`, `edge-past-the-rack`, `humming-shields`, `opened-seams`.
- Modifiers: `cold-iron-order`, `kindred-affix`, `weapon-efficiency`; `ore-weight` (from another build).
- Technique and arts: `pass-garrison-scripture`, `called-blade`, `hook-and-chain`, `peg-line-cut`, `re-temper`,
  `rack-wide-volley`, `shut-the-armoury-door`.
- Items: `garrison-rack`; `nine-rods-array`, `iron-sand-hand-bath` (from other builds).
- Way: `binh-kho-rack`; `hon-than-thuc-weight`, `hon-ho-lines`, `thousand-weight-thought` (from another build).
- Concepts: `equipped-pieces-readable`, `thinned-mind`, `peg-wall-cluster`; `layer-total-readable`,
  `preparation-fight-payload` (from another build).
- Keys the GDDs already design but the code lacks: `artifact_slots` (Item DB Build Gaps, rule 11).

## Changes the game would need

1. **Let Effects read the pieces you control.** Effects System (`design/gdd/effects.md`) rule 5: add "the pieces its
   owner controls (Item Database rule 11), their count, and each piece's role tags and base", read at compile. Today
   the list has free thần thức but not the pieces, so Garrison Mind, Full Rack and Humming Shields cannot be written.
2. **Allow a close that thins soul defence.** Combat (`design/gdd/combat.md`) rule 3 says the thần thức artifacts occupy
   never lowers the thần thức a side fights with, and Formulas E2 reads the whole of it as `divine_sense_def`. Let an
   enabler's or keystone's close set, for its holder only, `divine_sense_def = free + k × bound` (k 0.5 here).
3. **A layer's total before its cap, read at compile.** Effects System rule 5; already proposed by the home-fortress
   build (`layer-total-readable`). Edge Past the Rack is its second user.
4. **Check the top-end gear anchor against the slot limit.** Combat Formulas B's top-end profile (L3 at its cap) and
   Combat Defence & Healing Formulas A0's top-end artifact defence (5 × the power base) together need about six
   top-grade pieces (two attack pieces with Liệt and four Shields with Kiên), the whole of `equip.max_slots`, and about
   120 units of divine sense against a typical 45. The anchor is reachable only by a build like this one; the harness
   should know that when it fits the W shares.
