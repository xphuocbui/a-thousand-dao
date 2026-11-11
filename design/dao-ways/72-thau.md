# 72 · Thâu Đạo · *Diệu Thủ* (the Wondrous Hand)

> Overnight draft 2026-11-11. Proposal. **Needs:** none.
> **Theme stats:** `evade_pct`, `escape_pct`, `art_speed_pct`, `leech_linh_luc_pct`, `co_duyen_pct`, `crit_chance_pct`.
> **Road:** `evade_pct` +0.4.

## Build directions

1. **Steal Qi.** Take the foe's buff stacks and linh lực for your own (Trộm Khí): the stack-thief who feeds on stack
   builds. Counter to Fire, Wind and Earth buff builds.
2. **Steal Arts.** Copy the foe's last-fired art into an empty slot for a while (Trộm Thuật): the build with empty
   slots that fill with what the foe brought.
3. **Steal Treasures.** Loot more from fights and pick pockets in the world (Trộm Bảo).
4. **Quick Hands.** Speed and first strikes: the thief strikes first and gets away (Khoái Thủ, Biến Mất).

## Facets

### 1. Trộm Bảo (Steal Treasures)
- **Small:** `co_duyen_pct` +1 · loot rolls +1
- **Stat notables:** Light Fingers (Ngón Nhẹ): loot ×2 · Lucky Thief (Kẻ Trộm May): fortune ×2 · Deep Pockets (Túi Sâu):
  loot +1, fortune +1 · Fence (Kẻ Tiêu Thụ): sell price +2
- **Effects:**
  - **Major: Pick the Treasure (Diệu Thủ Thâu Bảo).** Fights you win against cultivators give one extra item roll from
    their equipment (never their bound artifact). `Needs key` (loot from NPC gear).
  - Minor: Pickpocket (Móc Túi). Once a season, steal spirit stones in a town (event, risk of a grudge). *(starter)*
  - Minor: Appraise the Mark (Nhìn Mặt Hàng). You see a foe's carried items before the fight.

### 2. Trộm Khí (Steal Qi)
- **Small:** `leech_linh_luc_pct` +0.2 · `art_speed_pct` +0.5
- **Stat notables:** Qi Thief (Đạo Khí): leech ×2 · Borrowed Breath (Hơi Mượn): art speed ×2 · Siphon (Hút Trộm): leech
  +0.2, art speed +0.5 · Thief's Vein (Mạch Trộm): max linh lực +2
- **Effects:**
  - **Major: Steal Qi (Thâu Khí).** Each of your hits steals 2 of the foe's buff stacks (largest pile first): they leave
    the foe and become your own buff stacks of that element (a batch for 6 pulses).
  - Minor: Quick Siphon (Hút Nhanh). Your first hit each fight steals 5. *(starter)*
  - Minor: Waterlogged (Sũng Nước). *Shared minor* (with Vụ, Phệ): L5 +15 against a foe with 0 linh lực.

### 3. Trộm Thuật (Steal Arts)
- **Small:** `than_thuc_pct` +0.5 · `art_speed_pct` +0.5
- **Stat notables:** Watchful Eye (Mắt Dòm): thần thức ×2 · Copycat (Bắt Chước): art speed ×2 · Second Look (Nhìn Lại):
  thần thức +1, art speed +1 · Mimic (Nhại): crit chance +2
- **Effects:**
  - **Major: Steal the Art (Thâu Thuật).** Each empty art slot you have holds the foe's last-fired art (a copy at 70 %
    damage, with your stats, its own cooldown), replaced each time the foe fires a new art. `Needs rule`.
  - Minor: Quick Study (Học Nhanh). A stolen art's first firing comes at half its cooldown. *(starter)*
  - Minor: Keep the Best (Giữ Cái Hay). Once per fight, lock a stolen art so it is not replaced.

### 4. Khoái Thủ (Quick Hands)
- **Small:** `art_speed_pct` +0.5 · `crit_chance_pct` +0.4
- **Stat notables:** Nimble (Lanh Lẹ): art speed ×2 · Sleight (Ảo Thuật Tay): crit chance ×2 · Fast Fingers (Ngón Nhanh):
  art speed +1, crit chance +0.5 · Sharp Knife (Dao Sắc): crit damage +2
- **Effects:**
  - **Major: Faster than the Eye (Nhanh Hơn Mắt).** Your first art each fight fires at 0.5 s, and the foe's first hit on
    you each fight is evaded for certain.
  - Minor: Snatch (Giật). Your quick arts cost 15 % less. *(starter)*
  - Minor: Quick Exit (Rút Nhanh). After stealing 20 buff stacks in a fight, your escape chance +25 %.

### 5. Biến Mất (Vanish)
- **Small:** `escape_pct` +1 · `evade_pct` +0.4
- **Stat notables:** Slip Away (Lẩn Đi): escape ×2 · Smoke Bomb (Bom Khói): evade ×2 · Gone in a Breath (Biến Trong Hơi
  Thở): escape +1, evade +1 · Shadow Run (Chạy Bóng): travel +2
- **Effects:**
  - **Major: Vanish (Biến Mất).** Your escape art succeeds for certain if you have stolen 30+ buff stacks or a stolen art
    has fired this fight. `Needs rule` (a certain escape).
  - Minor: No Trace (Không Dấu Vết). Fights you flee leave no World Database grudge. *(starter)*
  - Minor: Cover Story (Chuyện Bịa). Town guards suspect you 50 % less.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **Whatever They Have Is Yours (Vật Tha Tức Ngã)** | keystone | Steal Qi steals 5 per hit | You cannot gain buff stacks except by stealing | Trộm Khí |
| **The Thousand-Art Thief (Thiên Thuật Đạo)** | keystone | Stolen arts deal 100 % and cost you nothing | You may slot at most 1 art of your own | Trộm Thuật |
| **Wondrous Hand (Diệu Thủ Không Không)** | keystone | Pick the Treasure gives 2 extra rolls | Every theft (world events) has a counted chance to be discovered | Trộm Bảo |

## New pieces

- Copying the foe's arts; stealing buff stacks; loot from NPC gear: `Needs rule` / `Needs key`.

## Kept apart from

Thái Âm's Borrowed Light (copies a share of the foe's buffs without taking them; Thâu takes them), Phệ (drain linh
lực twice), Hồn (sees the foe's loadout). Thâu is **stealing stacks and arts, and getting away with it**.
