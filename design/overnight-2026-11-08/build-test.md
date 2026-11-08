# Build Test: the 69 Overnight Builds Against the New Libraries

> Overnight run, 2026-11-08, unattended. Proposals only; nothing in a GDD was changed.
> Tested against the GDDs as they stand tonight: `modifiers.md` (Stat List, General Catalogue), `effects.md`
> (Status Catalogue, Starter Effects, Core Rules 5–12), `combat-defence.md` (rules 1–21, the starter ward
> catalogue in Formulas H) and `combat-damage-types.md` (rules 1–10). All four are marked NEEDS REVISION, so
> some calls below may move when they do.

## The result

| Class | Builds | Meaning |
|---|---|---|
| **A** buildable now | **19** | Every piece exists. 3 of them lean on a stat or tag still marked *Pending* (named below) |
| **B** needs 1–2 new pieces | **16** | The missing pieces use only the reads and actions in Effects rules 5–6 |
| **C** no longer works | **34** | 6 are killed by the new damage and defence rules, 4 need a new engine read, action or limit change, and 24 need a new subsystem |

**The split follows the enabler.**

| Group | A | B | C |
|---|---|---|---|
| 38 builds with a special enabler | 0 | 10 | 28 |
| 31 builds with no enabler (plain stacks, hybrids, hunters) | 19 | 6 | 6 |

The plain builds mostly survive, because the catalogue covers their rows. The enabler builds mostly don't,
because most of their enablers were a new subsystem (a new resource, a new kind of side, a life system).

**The best piece to add next** is an over-cost art (Head of Water, below). Three B builds need it: Full Price,
Dug Stone and Deepest Well. After that each missing piece serves only one build. So the libraries are not missing
a common piece. They are missing a long tail of build-specific Effects, which is what the Effects GDD expects.

## How I decided

- **A** if every piece the build stands on is in the Stat List, the General Catalogue, the Status Catalogue, the
  Starter Effects or the starter ward catalogue. I treat arts and techniques as content, not library pieces: an
  art with authored damage parts, element tags, cost and cooldown inside Combat's ranges is assumed authorable.
- **A with a swap**: the build's own piece is gone, but an existing piece does the same job. The swap is named.
- **B** if 1 or 2 new pieces finish it. Each must be a plain modifier on a listed stat, or an Effect that uses
  only the listed reads and actions.
- **C** if the build needs something the new rules removed, an engine read or action not on the list, a change to
  an engine limit, or a new subsystem.
- **Not done:** I re-ran no fights. "A" means the pieces exist, not that the build still wins under the new defence
  numbers. I read the summary row of every build. I read the spine, or searched the stack, of about 25 sheets
  where the call was unclear, not every sheet in full.

## All 69 builds

**Abbreviations:** SE = Starter Effect, SC = Status Catalogue, W = starter ward (Combat Defence & Healing Formulas H).

### Builds with a special enabler

| # | Build | Class | Why | Missing pieces |
|---|---|---|---|---|
| 1 | Brush Fee | C | New subsystem: a mimic art that copies the enemy's art, and a cost billed to the other side. No action does either | — |
| 2 | Fortieth Breath | B | Has Measured Stroke, Final Clause, Bare Rack, Still Water (SE) and Golden Bell (W, in place of Standing Verdict). Healing now decays to 10 % by 15 s, so the 39-second wait must be re-proved | **Withheld Hand** (Effect, enabler) |
| 3 | Full Price | B | Seal of Full Payment is a Starter enabler. Priced Above the Sea needs an art above Combat's 0.25 cost ceiling | **Head of Water**, the stone-paid form (Effect, keystone here) |
| 4 | Great Tonic | C | New subsystem: Surfeit, linh lực held above maximum as a new damage | — |
| 5 | Incense Vigil | C | New subsystem: a stalemate counted as a win, and a deferred-damage ledger. Healing decay (rule 18) was designed against winning by outlasting | — |
| 6 | Receiving Hand | C | Engine addition: no action cancels an enemy art's hit. The "stained for life" slot is a life state | — |
| 7 | Remnant Host | C | New subsystem: Flight, artifacts on their own timers outside the slots. The read Spare Mind needs, free thần thức, does exist (Open Sky) | — |
| 8 | Struck Name | C | Dead: a "bare hit" with no type breaks Damage Types rule 1 (every part has exactly one type). Borrowed Name reads the enemy's lost bonus, which is not exposed. Silence (SC) already does the stripping half | — |
| 9 | Taster's Fever | B | Bitter Tithe fits as "refund the poison art's cost and report toxicity" (both listed actions). Fever reads toxicity at compile | **Bitter Tithe** (Effect, enabler); **Fever** (Effect, major) |
| 10 | Turned-Away | C | New subsystem: Gate Scar (a saved count of failed breakthroughs) and a breakthrough that always fails. The Down refusal it ends in does exist (Effects rule 11) | — |
| 11 | Already-Waited | B | Heart demon read at compile, "shorten your own timer" and "report a life cost" are all listed. `cooldown_min` still applies | **Already Waited** (Effect, enabler) |
| 12 | Deepest Well | B | Water Table is a Starter enabler. Scraping the Well is now core: unpaid drain leaks through (Defence rule 8). The pour needs an art above the 0.25 cost ceiling | **Head of Water** (Effect, major) |
| 13 | Given Years | C | New subsystem: kin ties, lifespan given to another person, seasons lost in place of health | — |
| 14 | Level Ground | C | New subsystem: Ground Law, a formation that moves Combat keys for both sides | — |
| 15 | Wedding Furnace | C | New subsystem: a new artifact type loaded with coatings before a fight. Element order in Effects is allowed (Damage Types rule 8), but loading courses is not | — |
| 16 | Ant General | C | New subsystem: mortal levies in mass battle | — |
| 17 | Best Plan | C | New subsystem: a deferred-damage tab and the Creditors' Book. The escape pieces it uses do exist (Cold Feet, Beneath Notice) | — |
| 18 | Drink the Lightning | C | Dead: Thiên Kiếp now sets `no_heal` on every wave (Defence rule 19), so "in on 40 %, out on 97 %" cannot happen. Also needs Ground Law | — |
| 19 | Forum Build | C | New subsystem: Ground Law and Title Deed. It was built as an exploit to close | — |
| 20 | Lucky Fool | C | New subsystem: the self-hit rule (an enemy art lands on its caster) | — |
| 21 | Not-Yet-Full | C | New subsystem: Eaten Power, uncapped fight power. Great Essence-Draining Art covers only the cultivation half | — |
| 22 | Stand-In | C | New subsystem: curses owned by a character from life, and moving them to the target | — |
| 23 | Understudy | B | Counted chance on evade is exactly Effects rule 12. Drop the thần thức ratio, because the enemy's thần thức is not on the read list | **The Understudy** (Effect, keystone: counted evade); **Encore** (Effect, minor: after an evade, the fist or a cued art answers) |
| 24 | The Transplant | C | New subsystem: a grafted root with rejection over decades | — |
| 25 | Worst Root | C | New subsystem: the Dull Root splits hits into parts, and parts under a threshold skip defence, which no rule allows. Block is now split across parts, so splitting gains nothing against block | — |
| 26 | Thirteenth Summer | C | New subsystem: the Cicada Root and brood years | — |
| 27 | Pill Glutton | C | New subsystem: a timed pill dose (Item DB Open Question 7) | — |
| 28 | Puppeteer | C | New subsystem: puppets as bodies that walk on in turn | — |
| 29 | Held Door | C | New subsystem: a ward around the enemy. Its other half, Twin Wards, is now core: ward slots and layered wards (Defence rule 5) | — |
| 30 | Spring Hand | B | Paid in Advance and Talisman Sleeve are Starter Effects. Talisman keep chance and talisman stock are *Pending* stats | **Let It Ride** (Effect, minor: a kept talisman strikes again as a free hit) |
| 31 | The Heir | C | New subsystem: succession into a disciple | — |
| 32 | The Mortal | C | New subsystem: a mortal body, received years, and the self-hit rule | — |
| 33 | Clever Harm | B | Reads ngộ tính at compile. Its closing cost (no `attack_pct`, no increased damage, −40 fortune) is expressible | **First on the List** (Effect, enabler: L1 from comprehension) |
| 34 | House Call | B | Heal arts are now core (Defence rule 16) and Gorged exists. Both pieces assume a heal can go to the enemy and that "health restored this fight" can be read for the enemy side. Check both with the Effects owner | **Both Sides** (Effect, enabler); **Joy of the Work** (Effect, major) |
| 35 | Good Year | B | Grave-Silk Shroud is the model: a standing status on the enemy from t = 0. Herb age is not readable, so "old herbs hit harder" is dropped | **Sown Field** (Effect, enabler); **Sown Herb** (a standing tick status, Status Catalogue) |
| 36 | Indigo Drop | C | New subsystem: the self-hit rule. It also reads the enemy's root purity, which is not exposed | — |
| 37 | Welcome Bath | C | Engine addition: reading the enemy's layer values. Sealed Meridian (SC) already does the "wash off a layer" half | — |
| 38 | Empty River | C | New subsystem: Size, a fight value that shrinks a side | — |

### Builds with no enabler

| # | Build | Class | Why | Missing pieces |
|---|---|---|---|---|
| 39 | Fierce Fire | A | Fire damage, cost, speed and crit rows are in the catalogue. The Lava spur is dead but was only a spur. Status duration is *Pending* | — |
| 40 | Daily Lesson | A | Steady Thread is Steady Breath (SE) scoped [sword]. The sword rows are in the catalogue | — |
| 41 | Second Sickness | A | Poison and Qi Disruption (SC) are the blood and the breath. Swap its body guard row for block | — |
| 42 | One Long Word | A | Standing Word is three catalogue curses: Heavy Breath, Leaking Ward and Stagnation. That fills all 3 curse places | — |
| 43 | One Ladle | A | Thin Stream is "+damage, scope [thuy, cheap]". The `cheap` tag is *Pending* (Modifier rule 10) | — |
| 44 | Long Firing | A, swap | The flat per-second Stone Ward is gone: upkeep now grows each pulse. A reserved ward (Still Lake Aura) is the new "costs the same whatever lands". Body guard becomes Iron Body Art (block, body shield, Physical resistance). Re-run it | — |
| 45 | Grindstone | A | Plain Metal stack | — |
| 46 | Evergreen | A | The pool race still holds: a side with no linh lực has no default ward (Defence rule 11) | — |
| 47 | Rice Pestle | A | Blood-paid arts are core (`body_cost_share`), and so is Blood Casting. Drop Hard Knuckle, which read body guard | — |
| 48 | Third Look | A | `x_soul` and thần thức rows exist. Every profile now has soul defence (Defence rule 14), so re-run it | — |
| 49 | Guide Hound | A | Still Hand is Bare Rack (SE), capability #17 is Beast Soul Union (SE), and Steady Breath can be scoped [companion]. Companion power share is *Pending* | — |
| 50 | Seven Lamps | C | Dead: the build is regeneration outrunning a flat upkeep, the exact fault upkeep growth fixes (Defence Formulas C). "Outlast" is also what healing decay is designed to stop | — |
| 51 | Cut Line | A | Its sheet says it stands without Running Line. Running Line cannot be added anyway, because it shortens `soul_lockout`, an engine limit (Effects rule 7). Every profile now has soul defence, so re-run it | — |
| 52 | Herd-Child | C | Engine change: Stands Over You needs a side that fights on after Down. The Down step allows one last act only (Effects rule 11) | — |
| 53 | Kept Hearth | C | Dead: no element cycle in fights and no ward phase (Damage Types rules 2 and 8) | — |
| 54 | Long Carry | B | Block and body shields carry the "blows on the body". Both linh lực shares are readable | **Longer Breath** (Effect, major) |
| 55 | Thousand Scales | C | Engine limit: Widening Wound raises the tick cap, and caps stay with their owners (Effects rule 7). The rest exists: Bleed, Opening Cut, Spillover | — |
| 56 | Loud Sword | A | Called Blow is a Starter keystone | — |
| 57 | The Corner | B | Qi Disruption and Stagnation exist. The core leak covers hits, not burns | **Requisition** (Effect, minor: qi burn counts as ward payment); **Scraping the Well, burn form** (Effect, major: burn on an empty pool lands on health) |
| 58 | Banked Well | C | Dead: it needs a flat per-second ward so the whole pool can go on arts. Upkeep now grows, and a reserved ward takes pool up front | — |
| 59 | Dew on the Blade | B | Ring Step (an element converts) is dead, but not needed: an art can carry both the Metal and Water tags | **Cold Dew** (Effect, minor: on a crit, restore linh lực) |
| 60 | Five Hot Stones | A, swap | Ring Step is dead: element tags never convert. Author the five arts with both the Fire and Earth tags (Fire and Physical parts), and each reads both paths | — |
| 61 | Long Drought | A | Stagnation, Poison and Qi Disruption | — |
| 62 | Swidden | B | Kindled Wound and Marked Prey stand in roughly, but neither grows with the thorn stacks | **New Shoot's Thorn** (Effect, minor: Fire parts deal more per Bleed stack of yours on the target) |
| 63 | Three Shirts | B | Body gear exists, and loadout is readable. Swap its Stone Ward for a reserved ward | **Ore Vein** (Effect, minor) |
| 64 | Third Tug | A | Uses Spent Breath, but its threshold is 30 %, not the sheet's 50 %. Two tugs leave 40 %, so re-run it | — |
| 65 | Dug Stone | B | Golden Bell is the per-hit ward. Whole Seam (85 % of the pool) is above the 0.25 cost ceiling | **Head of Water** (Effect, major) |
| 66 | The Proctor | A | Golden Bell. Per-hit wards still beat big volleys | — |
| 67 | Wet Cloth | C | Dead: per-hit wards are now priced to lose to many small hits (Golden Bell's fee is 0.14, the sheet's was 0.04). Block is the new answer to fast kits (Iron Shirt), which makes a different build | — |
| 68 | Long Answer | A, swap | Stone Ward becomes a reserved ward. Iron Shirt's block also answers the fast kit | — |
| 69 | Under the Eaves | A | Golden Bell in place of Standing Verdict | — |

## Missing pieces, ranked

Ranked by the B builds whose key piece it is. Optional rows that A or B builds also asked for are counted in the
last column.

| Rank | Piece | Kind and tier | Rule in one line | Builds (key) | Also wanted by |
|---|---|---|---|---|---|
| 1 | **Head of Water** (Thủy Đầu) | Effect, rule change, major. Keystone in its stone-paid form, Priced Above the Sea | One art may cost more than Combat's 0.25 ceiling, and the art lint prices its coefficient for what it paid | Full Price, Dug Stone, Deepest Well (3) | — |
| 2 | **Longer Breath** (Trường Tức) | Effect, conditional, major | While your linh lực share leads the target's by more than a set margin, your hits deal more (L5) | Long Carry (1) | Deepest Well (stack row) |
| 3 | Withheld Hand | Effect, enabler | Your basic attack never fires; each one skipped adds to your slowest art until it fires | Fortieth Breath | — |
| 3 | Already Waited | Effect, enabler | Heart demon pays an art's remaining wait; the seasons owed are reported after | Already-Waited | — |
| 3 | Bitter Tithe + Fever | Effect, enabler + major | Poison arts are refunded and report toxicity; art speed per point of toxicity | Taster's Fever | — |
| 3 | The Understudy + Encore | Effect, keystone + minor | Evade is counted (rule 12); after an evade, you answer | Understudy | — |
| 3 | First on the List | Effect, enabler | Comprehension becomes L1; closes increased damage and fortune | Clever Harm | — |
| 3 | Both Sides + Joy of the Work | Effect, enabler + major | Your heals also heal the enemy; their healing counts three times for Gorged | House Call | — |
| 3 | Sown Field + Sown Herb | Effect, enabler + a status | Each plot is a standing tick on the enemy from t = 0 | Good Year | — |
| 3 | Requisition + Scraping the Well (burn) | Effect, minor + major | Qi burn counts as ward payment; a burn on an empty pool hits health | The Corner | — |
| 3 | Let It Ride | Effect, minor | A talisman that is kept strikes again | Spring Hand | — |
| 3 | Cold Dew | Effect, minor | On a crit, restore linh lực | Dew on the Blade | — |
| 3 | New Shoot's Thorn | Effect, minor | Fire parts deal more per Bleed stack of yours on the target | Swidden | — |
| 3 | Ore Vein | Effect, minor | Metal arts deal more per artifact equipped, to a cap | Three Shirts | — |

**Not a new piece, but a key to finish.** These stats and tags are already in the Stat List, but marked
*Pending*, so no modifier on them can be authored yet.

| Pending stat or tag | Owner | Builds |
|---|---|---|
| Companion power share | Spirit Beasts / Combat J | Guide Hound (A); Herd-Child (C) would also want it |
| Talisman keep chance; talisman stock | Talismans | Spring Hand (B) |
| Status duration | Combat F | Fierce Fire (A) |
| Derived tag `cheap` | Combat (Modifier rule 10) | One Ladle (A) |

**Stack rows asked for twice** (optional, not key): Thrift, a quarter of ward efficiency counts as art cost (Long
Carry, Deepest Well); Rush Order, an art's first firing at half its cooldown, and Bulk Order, points per full share
of cost (Full Price, Deepest Well). All three fit as Effects with listed reads and actions.

## Things worth knowing

- **Head of Water touches Combat.** The 0.25 cost ceiling is Combat Formulas E's, so the owner decides whether an
  Effect may lift it. If not, all three of its builds become C.
- **Near misses.** Four C builds become B with a smaller version of their key piece, using existing rules:
  - Herd-Child: the buffalo makes one last act at Down, in place of fighting on.
  - Welcome Bath: Wash the Dust applies Sealed Meridian to L2, with no stealing.
  - Thousand Scales: Spillover replaces Widening Wound.
  - Wet Cloth: rebuilt on Iron Shirt's block.

  Each of these changes the build's identity, so I did not count them.
- **The Stone Ward family splits.** Long Firing and Long Answer only needed "costs the same whatever lands", so a
  reserved ward does the job. Seven Lamps and Banked Well needed "income beats a flat bill", which the new upkeep
  growth was written to stop.
- **Element conversion is gone, and dual tags replace it.** Five Hot Stones and Dew on the Blade used Ring Step
  only so one hit would read two element paths. An art with both element tags does that now. This assumes an art
  may carry two element tags. Damage Types rule 2 says "element tags, possibly none", which reads as a list.
- **Soul builds need a re-run.** Every profile now carries soul defence (Defence rule 14). That was written against
  exactly the Cut Line case ("a top-end with no soul defence dies").
- **Starter pieces these 69 builds never used:** Echo, Flowing Water, Shattering Ward, Blood Drinker, Iron Skin
  Renewed, Soul Wound, Rime Lock, Flame-Tempered Edge, Thunder Palm, Rot Seeps In, Field Walls, Overheat,
  Elemental Fist, First Move, Open Sky, Unyielding Breath, Burning Lifespan, No Ward, Glass Meridians, Heart
  Demon's Blade and Pack Hunt. They came from other inventory sources. Unused here is not a reason to cut them.
