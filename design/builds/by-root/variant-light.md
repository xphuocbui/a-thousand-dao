# Variant root: Light (Quang)

**What Light brings.** Transmuted from Fire. Light damage; its status is **Exposed** (all resistance −0.10). Role:
heart-demon ward. **No element stacks.** Đạo: Yang (Dương), Stars (Tinh Thần). The Light island on the map starts
here.

**Light's linh lực.** No stacks; Fire's keystone (Embers Feed the Hearth) works if it also burns, or a Light-island
keystone (New): **Dawn Tithe (Bình Minh Thuế)**: "while the foe is Exposed, your hits restore linh lực". How to
create: Meridian Map keystone on the Light island; reads statuses on the target.

---

## 1. The Sun Priest (Nhật Tư Tế)

**Concept.** Light lays the foe bare. Exposed cuts all resistance, which with #44's strong wards means the foe's
ward stops far less: at 0.8175 resistance, −0.10 is +55 % damage through.

**How it fights.** A Light art keeps Exposed up; Fire and Light arts strike through the open ward.

**Stacks.**
- **Linh căn:** Light (with Fire).
- **Công pháp:** Crimson Flame Heaven Canon, until a Light technique exists (New).
- **Đạo:** Yang.
- **Keystone:** Dawn Tithe (New).
- **Effects:** Kindled Wound (exists) if Fire is used.
- **Modifiers:** damage [light]; status chance.
- **Items:** a Mirror artifact (New kind).
- **Element stacks:** Fire debuff if it burns.

**Weakness.** Cleansing Exposed; a foe that relies on block, not resistance.

**New pieces.**
- **Radiant Canon (Quang Minh Kinh)**, a Light công pháp. How to create: `items_cong_phap.json` naming the Light
  variant.

## 2. The Mirror Ward (Kính Hộ)

**Concept.** A ward of light that turns blows back: a share of the damage it prevents is reflected as Light.

**How it fights.** A drain ward with a reflect payload; the foe's own offence feeds the reflection.

**Stacks.**
- **Linh căn:** Light.
- **Công pháp:** Radiant Canon (New).
- **Đạo:** Stars.
- **Keystone:** Dawn Tithe (New).
- **Effects:** Shattering Ward (exists).
- **Modifiers:** ward strength.
- **Items:** Mirror Ward (New ward).
- **Element stacks:** none.

**Weakness.** Ticks and soul attacks (no hit to reflect).

**New pieces.**
- **Mirror Ward (Kính Quang Hộ)**, a ward: "all resistance 0.40; 20 % of damage it prevents strikes back as Light".
  How to create: a ward record with a new "reflect" payload; price-checked with the reflect counted as value.

## 3. The Clear Heart (Thanh Tâm)

**Concept.** Light's role is the heart-demon ward. A cultivator who takes the dark Effects (Heart Demon's Blade,
Great Essence-Draining Art) without being consumed by them.

**How it fights.** Heart Demon's Blade (exists: more damage per heart demon above 30) with Light's heart-demon
resistance keeping deviation away.

**Stacks.**
- **Linh căn:** Light.
- **Công pháp:** Radiant Canon (New).
- **Đạo:** Yang.
- **Keystone:** Heart Demon Turned to Strength (capability, exists).
- **Effects:** Heart Demon's Blade (exists).
- **Modifiers:** heart-demon resistance; damage.
- **Items:** Clear Heart Ward.
- **Element stacks:** none.

**Weakness.** Its heart demon is a life cost outside the fight.

**New pieces.** None.

## 4. The Star Reader (Quan Tinh Giả)

**Concept.** A life build, not a fight build. Light opens the Stars Đạo: this cultivator reads the heavens before
every choice and walks the safe road through a dangerous life.

**How it plays.** Reading Heaven's Secrets (see every outcome before choosing) and Child of Fortune (reroll a failed
check) turn the Event Engine in its favour. It rarely fights; when it must, it is a plain Light build.

**Stacks.**
- **Linh căn:** Light.
- **Công pháp:** Radiant Canon (New).
- **Đạo:** Stars (Tinh Thần).
- **Keystone:** Reading Heaven's Secrets and Child of Fortune (capabilities, exist).
- **Effects:** none in fights.
- **Modifiers:** fortune (khí vận); comprehension.
- **Items:** a star chart (New utility item).
- **Element stacks:** none.

**Weakness.** It is weak in a fight; its strength is never needing one.

**New pieces.**
- **Star Chart (Tinh Đồ)**, an item: once a year, shows the next event's hidden branches. How to create: an Item DB
  treasure with an Event Engine read, a weaker relative of Reading Heaven's Secrets.
