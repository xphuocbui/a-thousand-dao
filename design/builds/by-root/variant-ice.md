# Variant root: Ice (Băng)

**What Ice brings.** Transmuted from Water. Cold damage. Ice has a debuff and no buff (Water carries the pair's
buff): each stack makes the foe's arts cost +1 %, with no cap and past Heavy Breath's curse cap. Role: pill-toxicity
resistance. After #44, when linh lực is life, Ice attacks the foe's life directly.

**Ice's linh lực keystone (New, every Ice build):** **Frost Tithe (Sương Thuế)**: you gain 9 % of the
extra cost your Ice stacks make the foe pay as linh lực (starting number, `notes.md` § 9). How to create: Meridian Map keystone in the Water land's Ice reach; an
Effect on the foe's art-cost event (readable: the extra cost from your stacks), action "restore linh lực".

---

## 1. The Frozen Treasury (Băng Khố)

**Concept.** Freeze the foe's purse. Every hit raises their art costs; Frost Tithe takes a share of what they
overpay. By 30 s their arts cost +50 % and half the extra flows to you.

**How it fights.** Fast Cold arts that each add 2 Ice stacks for 8 s. The foe's pool runs dry early; its ward
falls; the fight ends.

**Stacks.**
- **Linh căn:** Ice (with Water).
- **Công pháp:** Dark Water Heaven Canon (Cold arts).
- **Đạo:** Mist, the frost branch (New nodes).
- **Keystone:** Frost Tithe (New).
- **Effects:** Rime Lock (exists).
- **Modifiers:** `stack_duration_pct` [bang, debuff]; art speed; damage [cold].
- **Items:** Needle of ice; Fan.
- **Element stacks:** Ice debuff, Water buff.

**Weakness.** Foes with cheap arts care less; cleansing.

**New pieces.** Frost Tithe.

## 2. The Frost Lock (Sương Tỏa Quyết)

**Concept.** Control by cold: Rime Lock delays the foe's arts at every 10 Ice stacks, and expensive arts become too
dear to fire.

**How it fights.** Pile Ice stacks fast; each threshold delays the foe; costly enemy arts stall.

**Stacks.**
- **Linh căn:** Ice.
- **Công pháp:** Dark Water Heaven Canon.
- **Đạo:** Mist.
- **Keystone:** Frost Tithe (New).
- **Effects:** Rime Lock (exists).
- **Modifiers:** `stack_grant` [bang, debuff] (rare); art speed.
- **Items:** Flag.
- **Element stacks:** Ice debuff.

**Weakness.** A cleansing ward.

**New pieces.**
- **Deep Freeze (Thâm Đống)**: Rime Lock at every 10 stacks, not only the first. How to create: change Rime Lock's
  limit from "once per 4 pulses" to "each 10 stacks, once per 4 pulses".

## 3. The Ice Physician (Băng Y)

**Concept.** Ice's other role: pill toxicity resistance. A cultivator who can take far more pills than anyone, so
every foreseen fight starts with five combat pills in the blood.

**How it fights.** Preparation-heavy: pills (L4 more, resistance, regeneration) stacked beyond the usual toxicity.

**Stacks.**
- **Linh căn:** Ice.
- **Công pháp:** Dark Water Earth Scripture.
- **Đạo:** Pill Fire (needs Fire? use a Water-pill Đạo: New).
- **Keystone:** none special.
- **Effects:** none.
- **Modifiers:** pill toxicity resistance; pill effect.
- **Items:** many pills.
- **Element stacks:** Water buff.

**Weakness.** Blind fights.

**New pieces.**
- **Cold Pill Đạo (Hàn Đan Đạo)**: Ice-and-Water alchemy (preserving pills, toxicity). How to create: a `dao.json`
  entry requiring Ice.

## 4. The Winter Sleep (Đông Miên)

**Concept.** A life build. Ice slows everything, the body included: long closed-door cultivation (bế quan) that ages
the cultivator slowly, and a life that outlasts its rivals.

**How it plays.** Embryonic Breath (age at three-quarters speed in seclusion) and Ice's toxicity resistance let it
take more pills and sit longer; it reaches high realms late but alive.

**Stacks.**
- **Linh căn:** Ice (with Water).
- **Công pháp:** Dark Water Earth Scripture.
- **Đạo:** Time (Thời Gian), the slow branch.
- **Keystone:** Embryonic Breath (capability, exists).
- **Effects:** none in fights.
- **Modifiers:** lifespan; pill toxicity resistance; cultivation speed in seclusion (New scope).
- **Items:** cultivation pills.
- **Element stacks:** none needed.

**Weakness.** Events that come to it while it sleeps; a slow start.

**New pieces.**
- **Seclusion scope [secluded]** already exists as a tag family in the Modifier System; a "cultivation speed while
  secluded" row should be authored with it.
