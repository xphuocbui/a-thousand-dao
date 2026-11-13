# Draft: the catalogue's new Effects for effects.md

> **Applied 2026-11-13:** the user approved all 35 as drafted ("Approve all as drafted"); they are now in
> `design/gdd/effects.md` § Starter Effects. This file stays as the record of the draft.

> 2026-11-13, for the user's approval group by group (decided 2026-11-13: "by group, you approve each"). Each table is
> in `design/gdd/effects.md` § Starter Effects format and goes under the bold heading of the same name. Nothing here is
> in effects.md yet. Source: the `new` Effect records in `design/items/catalogue-*.json` (accepted for now 2026-11-12/13).

## Notes before approving

- **Delays already share a rule.** effects.md rule 6 (R1, 2026-11-11) halves each further delay on one target within
  `delay_falloff_window` (3 s) and applies `timer_resist_pct` (AC-EF-71). Soul Wound, Rime Lock, Deep Freeze, Plucked
  Time and Gripping Root all fall under it, so no new rule is needed.
- **Deep Freeze is Rime Lock repeated**: Rime Lock delays once when Ice reaches 10 (once per 4 pulses); Deep Freeze delays
  at every multiple of 10 (once per 2 pulses), for 10 % dearer arts. Suggestion: keep both (Rime Lock the minor Way and
  technique piece, Deep Freeze the item enabler), and note in Deep Freeze's row that it replaces Rime Lock when both are
  held.
- **Hosts** are as the item sessions wrote them; most say Named Item. **Tier** follows effects.md rule 4 (minor, major,
  enabler, keystone).

## Scaling (4)

| Name | Rule | Reads | Payload / action | Limits | Closes | Hosts | Build families | From |
|---|---|---|---|---|---|---|---|---|
| Sword Chorus (Kiếm Hợp Minh) | Your sword artifact arts deal 6 % more for each other equipped artifact that gives you a sword art, with no cap. | Equipped artifacts carrying a sword art, at equip | damage_more on sword artifact arts, per other sword artifact | — | Your arts that are not sword arts deal 15 % less. | Named Item | blade; The Sword Hall (Kiếm Các), a new build | item Sword-Nest Flag (`catalogue-blade`), enabler |
| Planted Banner (Thụ Kỳ) | Your Earth parts deal 2 % more for every 4 Earth buff stacks you hold. | Your Earth buff stacks, live | More damage on Earth parts | — | — | Item | earth; The Field Lord and The Mountain That Pays | item Boundary Flag of the Field Lord (`catalogue-earth`), minor |
| Wheel in the Flag (Ngũ Hành Tụ Kỳ) | Your arts deal 5 % more for each element whose buff stacks you hold, up to five elements. | Elements with at least one of your buff stacks, live | damage more, 5 % per element held | — | — | Named Item | general; The Wheel of Generation, The Overcomer, The Primor | item Five-Phase Flag (`catalogue-general`), minor |
| Sap Rises (Nhựa Thăng) | Each Wood buff stack you hold adds 1 % healing, up to 20 %. | Your Wood buff stacks, live | healing_pct, 1 per stack, at most 20 | — | — | Item, Way | wood; The Evergreen Wall | item Heartwood Bulwark (`catalogue-wood`), minor |

## Trigger (12)

| Name | Rule | Reads | Payload / action | Limits | Closes | Hosts | Build families | From |
|---|---|---|---|---|---|---|---|---|
| Stone Answers (Thạch Ứng) | When your body shield or a ward stops damage, you strike back with a free Physical hit worth 25 % of the damage stopped, at most 6 % of your maximum health per pulse. | Damage stopped by your shields and wards, live | A free Physical hit (Return channel), capped per pulse | — | None (a trigger; the cap per pulse is its limit) | Named Item | body; Mirror Hide and Debt of Stone builds | item Ring of the Answering Stone (`catalogue-body`), trigger |
| Debt of Stone (Thạch Trái) | When an art of yours is paid in health, you gain 1 Earth buff stack for 15 s for each 2 % of maximum health paid. | Health paid by your arts, live | Earth buff stacks on you | — | — | Item | earth; The Deep Vein health-payer | item Necklace of Stone Debt (`catalogue-earth`), minor |
| Phoenix Mend (Phượng Dũ) | When you restore health with an art, the enemy gains 1 Burn stack for each 1 % of your maximum health restored, at most 6 a pulse, at your Burn's values. | Health restored by your arts, live | Fire debuff stacks on the enemy | — | — | Item, Way, Tech | fire; The Phoenix Feather | item Phoenix Plume Armour (`catalogue-fire`), minor |
| Embers Feed the Hearth (Tàn Hỏa Dưỡng Lô) | Each Burn tick you deal returns linh lực equal to 0.4 % of your maximum, at most 2 ticks a pulse. | Your Burn ticks landing, live | Linh lực restored to you | — | — | Item, Way, Tech | fire; Burn builds that want their ticks to pay back | item Ring of the Fed Hearth (`catalogue-fire`), minor |
| Bought Fate (Mãi Mệnh) | Once a fight, a roll that goes against you (a crit you take, an evade that fails, an escape that fails) goes your way instead. | Rolls against you, instant | One roll flipped in your favour | — | Each flip burns spirit stones worth 5 % of the spirit stones you carry; with none carried it does nothing. | Named Item | general; Any build that dies to one bad roll | item Heaven-Purchasing Coin (`catalogue-general`), enabler |
| Toll Taker (Thu Thuế Giả) | When the enemy pays art cost that your Ice stacks added, you restore linh lực equal to 10 % of that extra cost. | The extra art cost your Ice stacks add to the enemy's arts, live | Linh lực restored to you | — | — | Item, Way, Tech | ice; The Frozen Treasury | item Black Ledger Mirror (`catalogue-ice`), minor |
| Lightning Drinker (Ẩm Lôi) | When a Lightning part hits you, 20 % of the damage it deals after resistance returns as linh lực. | Lightning damage you take, live | Linh lực restored | — | — | Item, Way | thunder; The Tribulation Rider | item Tribulation Rod (`catalogue-thunder`), minor |
| Backflow (Hồi Lưu Triều) | When you restore health with an art, you regain linh lực equal to 20 % of the health restored, at most 3 % of your maximum linh lực a pulse. | Health restored by your arts, live | Linh lực restored | — | — | Item, Way, Tech | water; The Overflowing Cup and Tide builds | item Ring of the Returning Tide (`catalogue-water`), minor |
| Owed Water (Thiếu Thủy) | When your linh lực falls to 20 % of maximum or below, you regain 15 % of your maximum linh lực over the next 5 s. Once every 20 s. | Linh lực pool, live | Linh lực restored over time | — | — | Item, Way, Tech | water; Builds that run dry before the foe | item Owed Water Pendant (`catalogue-water`), minor |
| Wind at Your Back (Thuận Phong) | When you evade, you gain 1 Wind buff stack for 4 s, at most 2 a pulse. | Your evades, instant | Wind buff stacks on you | — | — | Item, Way, Tech | wind; The Gale Dancer and The Untouchable | item Four-Winds Banner (`catalogue-wind`), minor |
| Scatter Gale (Tán Phong) | When you evade, you cleanse your own debuff stacks, at most 2 batches every 6 s. | Your evades, instant | Cleanse of your own debuff stacks, 2 batches per 6 s | — | — | Item, Way, Tech | wind; The Evade Dancer | item Scatter-Gale Pendant (`catalogue-wind`), minor |
| Gripping Root (Triền Căn) | When your Physical Wood hit lands, the target's art with the least time left is delayed by 0.5 s, once per 2 s. | Your Physical Wood hits landing, instant | The target's soonest art is delayed 0.5 s | — | — | Item, Way | wood; The Strangler Fig | item Thousand Roots Banner (`catalogue-wood`), minor |

## Conversion and overflow (1)

| Name | Kind | Rule | Reads | Payload / action | Limits | Hosts | Build families | From |
|---|---|---|---|---|---|---|---|---|
| Brimming Cup (Mãn Bôi) | conversion | Linh lực lost to a full pool fills your Cup: you gain 1 Water buff stack for 8 s for every 5 % of maximum linh lực lost, at most 2 stacks a pulse. | Linh lực lost to a full pool, live | Water buff stacks | — | Item, Way, Tech | water; The Overflowing Cup | item Underground Spring Censer (`catalogue-water`), minor |

## Rule change (5)

| Name | Rule | Reads | Payload / action | Limits | Hosts | Build families | From |
|---|---|---|---|---|---|---|---|
| Lingering Afterimage (Dư Ảnh Bất Tán) | Your Blade counters (Afterimages, Coils) do not decay. **Closes:** Your basic attack deals 30 % less. | Counter decay per pulse, live | Blade counters keep their count until spent | — | Named Item | blade; The Sword Hall and the Afterimage Sword Canon | item Ring of Unbroken Edges (`catalogue-blade`), enabler |
| First Stand (Tiên Lập) | At the start of a fight, your body shield is already raised to 30 % of your maximum health. **Closes:** None (once, at the start; it does not refill) | Fight start, your maximum health | Body shield set to 30 % of health at t = 0 | — | Named Item | body; Mountain-Splitting Axe and Bulwark builds | item Pendant of the First Stand (`catalogue-body`), trigger |
| Unmoved Stance (Bất Động Thế) | The art-speed and basic-speed penalties of your stances do not apply to you. **Closes:** Your evade is 0 while a stance is on. | Your stance states, live | Stance speed penalties removed | — | Named Item | earth; The Mountain That Pays | item Unmoving Gate Shield (`catalogue-earth`), enabler |
| Embers Never Die (Tàn Hỏa Bất Diệt) | Your Burn on a target cannot be cleansed. A cleanse that would remove it removes the same number of your own Fire buff stacks instead. **Closes:** Your own wards cannot cleanse you. | Cleanses on the target, instant | Cleanse immunity for your Burn | — | Named Item | fire; Burn builds against cleansing foes (Clear Heart Wa | item Undying Ember Lantern (`catalogue-fire`), enabler |
| Moss Ledger (Đài Sổ) | Poison stacks you lay cannot be cleansed for their first 4 s. | Your Wood debuff stacks, at the moment they are laid | A 4 s cleanse-immunity window on each Poison batch you lay | — | Item, Way | wood; The Wood poisoner's light armour | item Moss-Ledger Robe (`catalogue-wood`), minor |

## Enablers (13)

| Name | Rule | Reads | Payload / action | Limits | Closes | Hosts | Build families | From |
|---|---|---|---|---|---|---|---|---|
| Shield Pays the Blood (Thuẫn Thế Huyết) | Health that your arts would cost is paid from your body shield first, point for point; once the shield is gone, health pays again. | Your arts' health costs and your body shield, live | Health costs paid by body shield | — | Your healing is 20 % weaker. | Named Item | body; Marrow Tithe builds | item Vajra-Hide Armour (`catalogue-body`), enabler |
| Fan the Pyre (Phiến Hỏa Liệu Nguyên) | Each Fire hit you land refreshes the duration of every Burn batch you have on the target. | Your Fire hits landing, instant | Burn batches on the target restart their timers | — | Your direct Fire hits deal 8 % less (softened from 15 %, user decision 2026-11-13). | Named Item | fire; The Bonfire's keystone piece | item Ashen Phoenix Fan (`catalogue-fire`), enabler |
| Unmaking Glass (Hủy Nguyên Kính) | Each hit you land strips 1 buff stack from the target, from its largest pile, at most once a pulse. Each stack stripped counts as a status you landed, so it feeds your Fray and every read of the foe's distinct statuses. | Your hits landing, instant; the target's buff stacks | Removes 1 foe buff stack a pulse; counts as a status application | — | Your own buff stacks last 25 % shorter. | Named Item | force-chaos; The Unmaker | item Mirror of Primordial Chaos (`catalogue-force-chaos`), enabler |
| Deep Freeze (Thâm Đống) | Each time your Ice stacks on a target cross a multiple of 10, that target's art with the least time left is delayed by 1 s, once every 2 pulses. | Your Ice stacks on the target crossing a multiple of 10, instant | A 1 s delay on the target's art with the least time left | — | Your arts cost 10 % more linh lực. | Named Item | ice; The Frost Lock's keystone piece | item Deep Freeze Ring (`catalogue-ice`), enabler |
| Edge Returns the Breath (Phong Hồi Khí) | Each crit with a Physical hit restores 0.8 % of your maximum linh lực. | Your Physical crits, instant | linh_luc_on_crit_pct 0.8 | — | Your non-Physical hits cannot crit. | Item, Way | metal; The Thousand Cuts | item Ring of the Returning Edge (`catalogue-metal`), enabler |
| Whetstone Vow (Ma Thạch Thệ) | Art costs you pay in health are halved. | Art costs paid in health, live | Health costs halved | — | You can never heal above 80 % of your maximum health. | Named Item | metal; Blood on the Whetstone | item Blood-Seasoned Whetstone (`catalogue-metal`), enabler |
| Armoury Count (Binh Khí Kê) | Your hits deal 4 % more for each equipped weapon-base artifact you carry. | Equipped artifacts on weapon bases, live | damage_more 4 per weapon-base artifact | — | Your wards are 15 % weaker. | Named Item | metal; Armoury Mind | item Armoury Banner (`catalogue-metal`), enabler |
| Plucked Time (Huyền Trì) | When one of your song arts lands a soul hit, the enemy's next ready art is delayed by 0.4 s, at most once a second. | Your song arts landing soul hits, instant | Delay of the enemy's next ready art | — | Your arts that are neither soul nor song deal 15 % less. | Named Item | soul-song-seal; The Zither Player's keystone | item Thousand-String Zither (`catalogue-soul-song-seal`), enabler |
| Lamp-Lit Reading (Đăng Chiếu) | Each different status of yours on the target lowers its soul resistance by 3 points, to at most 5 statuses. | Your different statuses on the target, live | Soul resistance reduction on the target | — | Your own soul resistance is 15 points lower. | Named Item | soul-song-seal; Soul builds against high soul resistance (their st | item Ninth Vigil Heart-Lamp (`catalogue-soul-song-seal`), enabler |
| Verdict Stands (Phán Quyết Bất Diệt) | Your Thunder debuff stacks on a Slowed target cannot expire. | Slowed Time on the target, live | Thunder stacks on a Slowed foe never expire | — | Thunder stacks you lay on a foe that is not Slowed last 25 % shorter. | Named Item | thunder; The Thunderclap | item Seal of the Ninth Tribulation (`catalogue-thunder`), enabler |
| Drumbeat (Cổ Tiết) | Every fourth art you fire in a fight is a guaranteed crit, and each such crit gives you 1 Thunder buff stack. | Arts fired this fight, live | Guaranteed crit; Thunder buff stack | — | Your other arts have 8 less crit chance. | Named Item | thunder; The Thunder Drum | item Heartbeat of Heaven Drum (`catalogue-thunder`), enabler |
| Sea Already Deep (Hải Dĩ Thâm) | You begin every fight with 8 Water buff stacks that last the whole fight. | Fight start, instant | Water buff stacks for the fight | — | Your arts cost 10 % more linh lực. | Named Item | water; The Deep Sea and The Moon in the Well | item Mirror of the Drowned Moon (`catalogue-water`), enabler |
| Phantom Dodge (Ảnh Tị) | Each basic attack of yours that lands counts as an evade for your arts' counters and held payloads, at most twice a pulse. | Your basic attacks landing, instant | An evade event for your counters, Breath and Echoes | — | You evade 10 pp less. | Named Item | wind; The Gale Dancer's keystone piece | item Nine-Gale Heron Fan (`catalogue-wind`), enabler |

