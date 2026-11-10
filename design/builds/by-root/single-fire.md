# Single root: Fire (Hỏa)

**What Fire brings.** Fire damage. Buff: +1 % damage per stack. Debuff: **Burn**, Fire ticks that count as the
applier's damage, so Fire's own damage increases feed them. Craft role: alchemy success and quality. Công pháp:
Crimson Flame Earth Scripture (Xích Diễm Địa Quyết), Crimson Flame Heaven Canon (Xích Diễm Thiên Kinh). Talisman:
Fireball (Hỏa Cầu Phù). A Fire root can transmute into Light (variant).

**Fire's linh lực keystone (New, every Fire build):** **Embers Feed the Hearth (Tàn Hỏa Dưỡng Lô)**: each Burn
tick you deal restores linh lực equal to 15 % of its damage (starting number, `notes.md`). How to create: Meridian Map keystone in the Fire
land; an Effect on the tick event, action "restore linh lực"; closing cost "your direct Fire hits deal 15 %
less".

---

## 1. The Bonfire (Liệu Nguyên)

**Concept.** Start small, burn forever. Every hit piles Burn; every Burn tick pays for the next art.

**How it fights.** Quick Fire arts add 2 Burn stacks for 6 s per hit; Fire buff stacks (+1 % damage) grow on every
firing and make each new Burn batch stronger, since a batch keeps the applier's values. Burn ticks refill the pool
through the keystone.

**Stacks.**
- **Linh căn:** single Fire.
- **Công pháp:** Crimson Flame Heaven Canon.
- **Đạo:** Lava (Dung Nham) needs Earth, so single Fire takes **Pill Fire (Đan Hỏa)**, whose furnace branch is
  about heat held over time (New nodes: Burn duration).
- **Keystone:** Embers Feed the Hearth (New).
- **Effects:** Kindled Wound (exists: Fire parts deal more to a burning target), Spillover (exists).
- **Modifiers:** damage [fire], [over_time]; `stack_duration_pct` [hoa, debuff]; `stack_effect_pct` [hoa, buff].
- **Items:** Fan (Phiến) artifact to fan the flames; Fireball talismans.
- **Element stacks:** Fire debuff and buff.

**Weakness.** Fire resistance (Fire-Shunning Veil, 0.75); cleansing wards.

**New pieces.** The keystone, and Pill Fire nodes for Burn duration (Đạo data).

## 2. The Furnace Master (Lô Chủ)

**Concept.** An alchemist who fights with pills: drinks a burst pill at the right second, and lives because Fire's
craft role makes the best pills in the sect.

**How it fights.** Before a foreseen fight it takes its own pills (L4 preparation more). In the fight, a pill-like
Effect at 30 % health turns heat into a short, furious burst.

**Stacks.**
- **Linh căn:** single Fire (alchemy role).
- **Công pháp:** Crimson Flame Earth Scripture.
- **Đạo:** Pill Fire, the furnace branch.
- **Keystone:** Divided Furnace Flame (capability, exists: brew two recipes a season) for supply; Burning Lifespan
  (exists: burn years for 5 s of fury) as the fight's turn.
- **Effects:** Burning Lifespan (exists); Strange Pill Reborn (exists: failed brews make lesser pills).
- **Modifiers:** pill effect; alchemy success; damage [fire].
- **Items:** self-brewed combat pills (L4 `damage_more`); Gourd for carrying them.
- **Element stacks:** Fire buff.

**Weakness.** Blind fights (no preparation) take its L4 away.

**New pieces.**
- **Mid-Fight Pill (Lâm Trận Đan)**, a pill kind usable once in a fight, as a guarded art slot. How to create: an
  Item DB pill category that occupies an art slot with a guard (Combat rule 13).

## 3. The Phoenix Feather (Phượng Vũ)

**Concept.** A Fire healer-striker: each heal art also burns the foe, so the same flame mends and wounds.

**How it fights.** A heal art (refunding its cost) applies 2 Burn stacks to the foe on cast. Gorged makes hits
stronger for every 1 % healed. It wins the long fight.

**Stacks.**
- **Linh căn:** single Fire.
- **Công pháp:** Crimson Flame Heaven Canon.
- **Đạo:** Yang (Dương Đạo), the sun branch (healing, Fire).
- **Keystone:** Embers Feed the Hearth (New).
- **Effects:** Gorged (exists), Kindled Wound (exists).
- **Modifiers:** healing; damage [fire]; health regeneration.
- **Items:** Fan; a reserved Fire aura (Flame-Quelling Aura) against Fire foes.
- **Element stacks:** Fire debuff.

**Weakness.** Withering; Fire resistance.

**New pieces.**
- **Phoenix Mend (Phượng Dũ)**, a heal art that applies Burn on cast. How to create: art record with a heal payload
  and a debuff grant; the lint charges the stacks and the heal separately.

## 4. The Self-Immolator (Tự Phần)

**Concept.** A cultivator who sets itself alight. Arts paid in its own body, years burned for fury, and a fire that
grows as its health falls.

**How it fights.** Glass Meridians (arts far faster, fragile body) and Blood Casting; at 30 % health Burning Lifespan
gives 5 s of fury. It wins in that window or not at all.

**Stacks.**
- **Linh căn:** single Fire.
- **Công pháp:** Crimson Flame Heaven Canon.
- **Đạo:** Destruction (Hủy Diệt).
- **Keystone:** Glass Meridians (exists, Effect keystone); Blood Casting (exists).
- **Effects:** Burning Lifespan (exists), Spent Breath (exists: more damage at low linh lực; here read as the fury
  phase).
- **Modifiers:** art speed; damage [fire]; `art_cost_health_pct`.
- **Items:** Fan; no ward slots spent on defence beyond the Common Ward.
- **Element stacks:** Fire buff and debuff.

**Weakness.** Anything that survives the fury; the years it burns are a life cost.

**New pieces.** None.
