# Variant root: Thunder (Lôi)

**What Thunder brings.** Converges from Fire and Metal. Lightning damage; role: attack (`attack_pct` by purity).
Buff stacks: +1 pp accuracy and +0.5 pp crit chance. Debuff stacks: the foe takes +0.5 pp crit chance and +2 % crit
damage. Công pháp: Thunder Emperor True Canon (Lôi Đế Chân Kinh). Đạo: Heavenly Thunder (Thiên Lôi). The Thunder
island on the map starts here.

**Thunder's linh lực keystone (New, every Thunder build):** **Storm Battery (Lôi Trì)**: every crit restores
1.9 % of maximum linh lực (starting number, `notes.md`). How to create: Meridian Map keystone on the Thunder island; an Effect on the crit event
(any type), payload `linh_luc_on_crit_pct`; closing cost "your non-crit hits deal 10 % less".

---

## 1. The Crit Storm (Lôi Bạo)

**Concept.** Lightning never misses twice: Thunder buff makes crits likelier, Thunder debuff makes the foe take them
harder, and every crit recharges the pool.

**How it fights.** Fast Lightning arts; by 20 s, buff stacks put crit chance near its cap and debuff stacks add
+40 % crit damage taken. Storm Battery turns the crits into linh lực, so the storm never stops.

**Stacks.**
- **Linh căn:** Thunder (with Fire and Metal).
- **Công pháp:** Thunder Emperor True Canon.
- **Đạo:** Heavenly Thunder.
- **Keystone:** Storm Battery (New); Called Blow (exists) for steady crits.
- **Effects:** Flowing Water (exists).
- **Modifiers:** crit chance, crit damage, damage [lightning], `linh_luc_on_crit_pct`.
- **Items:** a Bell (thunderclap); Flying Sword with Lightning affinity.
- **Element stacks:** Thunder buff and debuff.

**Weakness.** The crit chance cap; Lightning resistance; cleansing the crit exposure.

**New pieces.** Storm Battery.

## 2. The Tribulation Rider (Độ Kiếp Kỵ)

**Concept.** A cultivator who walks into heavenly tribulation and drinks the lightning. Lightning resistance and
healing from Lightning damage taken.

**How it fights.** In tribulation waves (all Lightning), a New Effect turns a share of Lightning damage taken into
linh lực. In ordinary fights, a Lightning crit build.

**Stacks.**
- **Linh căn:** Thunder.
- **Công pháp:** Thunder Emperor True Canon.
- **Đạo:** Heavenly Thunder, the tribulation branch.
- **Keystone:** Storm Battery (New).
- **Effects:** Lightning Drinker (New).
- **Modifiers:** resistance [lightning]; maximum linh lực.
- **Items:** a Lightning Rod artifact (New kind).
- **Element stacks:** Thunder buff.

**Weakness.** Ordinary foes who are not Lightning.

**New pieces.**
- **Lightning Drinker (Ẩm Lôi)**, an Effect: "20 % of Lightning damage you take returns as linh lực". How to create:
  trigger on being hit by a Lightning part, action "restore linh lực".
- **Lightning Rod (Lôi Trượng)**, an artifact kind (utility, holds the Effect). Note: an overnight build sheet
  (`overnight-2026-11-07/sheets/drink-the-lightning.md`) explored a similar idea.

## 3. The Thunderclap (Lôi Minh)

**Concept.** One deafening strike: a slow Lightning seal that stuns (delays all the foe's art timers) and crits
against the exposure built by fast sparks.

**How it fights.** Sparks build Thunder debuff; a 12 s Thunderclap delays every enemy art by 1 s and lands a crit.

**Stacks.**
- **Linh căn:** Thunder.
- **Công pháp:** Thunder Emperor True Canon.
- **Đạo:** Heavenly Thunder.
- **Keystone:** Storm Battery (New).
- **Effects:** Measured Stroke (exists) would forbid the crit; take Called Blow instead.
- **Modifiers:** crit damage; damage [slow].
- **Items:** Bell; Seal.
- **Element stacks:** Thunder debuff.

**Weakness.** Cleansing before the clap.

**New pieces.**
- **Thunderclap (Lôi Minh)**, an art with an action "delay every enemy art by 1 s". How to create: art record with
  the Effects action "move the enemy's timer" applied to all its arts; a strong control, so a long cooldown (12 s).

## 4. The Thunder Drum (Lôi Cổ)

**Concept.** Thunder keeps time. A rhythm build: every fourth art is a guaranteed crit, and the drumbeat (Thunder
buff stacks) never stops.

**How it fights.** Called Blow turns crit chance into a visible meter, so crits come on a steady count; with Thunder
buff raising the chance, the meter fills every third or fourth art. Storm Battery refills linh lực on each beat.

**Stacks.**
- **Linh căn:** Thunder.
- **Công pháp:** Thunder Emperor True Canon.
- **Đạo:** Heavenly Thunder, the drum branch (New nodes).
- **Keystone:** Called Blow (exists, Effect keystone); Storm Battery (New).
- **Effects:** Flowing Water (exists: each crit shortens other timers).
- **Modifiers:** crit chance; crit damage; art speed.
- **Items:** Drum (New kind) or Bell.
- **Element stacks:** Thunder buff and debuff.

**Weakness.** Evade breaks the count (an evaded hit rolls no crit).

**New pieces.**
- **Drum (Cổ)**, an artifact kind: rhythm focus, +crit chance for arts fired on a steady interval. How to create: add
  a kind to `items_artifacts.json` (utility role).
