# World depth: rule proposals

> **Status**: Proposal, written overnight 2026-11-24/25 at the user's request ("for the new content and the changes,
> please just write them down for now"). Nothing here is in a GDD, in `assets/data` or in code yet. Each rule names
> the GDD it would amend; the user approves amendments section by section (memory: user decides GDD rewrites).
> **Why**: the world reads as unconnected. Băng Tâm Các is an Ice sect on badlands (10 % Water, no Ice); its random
> members roll roots with no regard for the sect, the land, or the công pháp they are taught. 37 of 50 sect seats fail
> the land-fit test in R4 (`seat-audit.md`).

The rules below are the frame every content file in `design/world/depth/` is written against.

---

## R1. Roots follow the land (Linh Căn amendment; user 2026-11-24: "strong lean")

A person's root is shaped by the land they were born on. Every new person (world-generation fill, births in the Living
World Tick, townsfolk) rolls their root with the element weights tilted by their **birthplace's** land qi.

**Formula R1a: element weight.**

`w'_e = w_e × clamp(1 + k_land × (s_e − s_even) / s_even, f_lo, f_hi)`

| Variable | Meaning | Value (proposal) |
|---|---|---|
| `w_e` | the element's base roll weight (Linh Căn rule 7; equal for the five) | from data |
| `s_e` | the element's share of the birthplace's qi, percent (`place.qi.shares`) | 0-100 |
| `s_even` | the even share, 100 / 5 | 20 |
| `k_land` | how hard the land pulls | **1.0** (strong) |
| `f_lo`, `f_hi` | the factor's bounds | 0.25, 3.0 |

Examples: a 40 % Water glacier gives Water × 2.0; a 10 % Water badland gives × 0.5; a 67 % Water ice peak gives × 3.0
(capped). An even city (all five near 20 %) changes nothing, which is why cities stay mixed.

The same factor scales the **purity** draw mildly: an element whose factor is above 1 adds `p_land × (factor − 1)`
purity, `p_land` = 6 (so the 3.0 cap adds +12). A strong land breeds strong roots of its kind, never a perfect one.

**Formula R1b: variant odds.** For a variant whose required elements the root has (Linh Căn rule 9):

`chance'_v = chance_v × clamp(1 + k_var × q_v / 10, 1, v_hi)`, `q_v` = the birthplace's variant qi (`place.qi.variants`),
`k_var` = 1.0, `v_hi` = 5. Ice land (variant 40) gives Ice × 5 for anyone born with Water. Innate Wind (no required
element) reads wind land the same way.

**Birthplace.** A new record gains `birthplace` (place id). Births use the mother's home. World-generation fill draws
it: a sect member's from the sect's own ground (share `local_recruit` = 0.75; the rest from anywhere settled, weighted
as Formulas M), a loose cultivator's from their region. The fill rolls the root from the birthplace **before** R2
decides where they may join.

**Why strong:** the user wants regions that feel like their land. With k_land 1.0 a Water region's people are about
twice as often Water-rooted as a plain's, which is visible in any sect hall and any village census, without making
regions monocultures (k_land 2+ would).

---

## R2. A sect admits only roots that can absorb its teaching (Sects amendment; user 2026-11-25)

> User: "It shouldn't make sense for someone to join a sect that has all công pháp in fire to not be able to absorb
> fire linh khí."

A sect's **lineage** (R5) names the elements its công pháp run on. Admission:

| Rank | Must hold |
|---|---|
| Outer disciple (ngoại môn) | at least one of the lineage's base elements at purity ≥ `admit_min` (30) |
| Inner disciple (nội môn) and above | the **main method's** element at purity ≥ `admit_core` (45); for a variant lineage (Ice, Thunder, Darkness, Light, Wind) the variant itself |
| Head (tông chủ) | the main method's element and, for a variant lineage, the variant at purity ≥ 50 |

**Exceptions, each named in the record:** guest elders (khách khanh: hired crafters or protectors, any root, never
taught the lineage), mortal and servant staff, a member admitted for a non-lineage craft the sect hires (an alchemist
in a Water sect), and a member whose root changed after joining (Linh Căn root change: they keep the rank and are
**marked**: a story hook, not an error). A hostage or political marriage may also sit in a sect outside the rule.

**Random members** are drawn under the rule: the fill rolls a root from the birthplace (R1) and joins a sect whose
admission it passes, preferring its own ground's sects; a root that passes none stays loose. This is also why loose
cultivators skew toward odd roots, which is true of the genre.

**Outer disciples in a variant sect.** Ice sects take Water-rooted outer disciples who lack Ice: the outer gate is the
pool that hopes to awaken (a root change by Ice transmutation; Linh Căn rule 10). Few do. That is the outer gate's story.

---

## R3. Sects with no favoured root (Sects amendment; user 2026-11-25)

Some sects teach công pháp that run on no element: body techniques (thể tu), the blade, soul/song/seal and force
families in `design/techniques/`. Such a sect has `leans: []` and admits **any root**; it recruits by talent
(thiên phú: a body sect by căn cốt, a soul sect by thần hồn, a sword sect by ngộ tính) or by trade and kin (a merchant
house, a clan sect). Its members' roots simply follow their birthplaces (R1), so a no-lean sect looks like its region.

Proposal: **5-8 minor sects become no-lean** in this pass (the writers pick sects whose seat land is mixed and whose
story suits it), plus at most one no-lean great sect if a writer makes the case. They are listed in `README.md`.

---

## R4. A sect sits on land that fits it (World Generation / Travel & Map amendment; user 2026-11-24: "move seats")

**Fit test** (`tools/design/world/depth_seat_audit.py`): the first lean is a base element with ≥ 25 % of the seat's qi
or the seat's top element; every other base lean ≥ 15 % or among the seat's top two; every variant lean ≥ 5 variant
qi. A no-lean sect always fits.

**Great sects** move their seat inside their own territory to a place that fits (user decision). **Minor sects** may
instead **re-lean to their land** (their identity is less fixed, and moving 30 minor seats would cost 30 repaints);
each minor sect's file says which. A sect with no fitting place in its own ground re-leans, or moves to a fitting
place next door with a story for it (bought, granted by its lord, taken in a war).

**What a move costs** (each sect file lists its own): the seat's painted place art, its map symbol, routes to it, its
province's seat record (Provinces #48), the qi density the economy reads (the new seat is often thinner; the
proposal for that is a **founder's array**: a sect seat has `seat_array_density` that raises its density toward
the old value, written into history as the founder's vein-raising work), the place lore and chronicle lines that name
the old seat (the old place stays and becomes something with a story: an outer-gate market, a fallen hall, a
pilgrims' stair).

---

## R5. Every sect has its own công pháp lineage (Sects / Cultivation Techniques amendment)

A sect record gains `lineage`:

| Field | Meaning |
|---|---|
| `main` | the sect's main method (công pháp chính): great sect Earth or Heaven tier, minor sect Profound or Earth |
| `secret` | 2-4 secret arts by rank (taught at inner disciple, elder, head) |
| `body` | 0-1 body technique |
| `outer` | the outer gate's method: a Yellow or Profound method of the lineage's element, the common start |
| `elements` | the base elements and variants the lineage runs on (R2 reads this) |

Techniques come from `design/techniques/` where one fits; otherwise the sect file **proposes** a new technique in
`sects/<key>.techniques.json` (light schema in `schema.md`: concept, tier, kind, elements, which arts it carries or
new art concepts, the rank that learns it). New techniques are unpriced proposals until the Cultivation Techniques
catalogue pass prices them (`design/techniques/README.md`).

**Members resemble the lineage** (user 2026-11-25): at least 80 % of a sect's named members run the lineage's main or
outer method; the rest carry an outside method with a reason in their backstory (came from a fallen sect, a guest
elder, a heretic in the making). The world fill draws members' main technique from the lineage the same way.

---

## R6. Traits v2: deeper, CK3-like (NPC Traits amendment; user 2026-11-24: all three of more traits, bigger effects, cast trait sets)

Full proposal in `traits-v2.md` (kinds, catalogue, rows, what each opens). In short:

- **More kinds per person**: personality (3, as now), calling (1, as now), **upbringing** (1, new), **talent tiers**
  (0-2, new, graded 1-3 like CK3's congenital tiers, replacing most fate-given gifts), **cultivation path** (0-2, new:
  what the person's cultivation has made them), **lifestyle** (0-1, new: what they do with their time), **health**
  (0-1, new: wounds, deviations, poisons), plus the existing gained traits (0-2) and fate-given (0-2, now mostly fates
  with a story: Demon-seeded, Ill-starred). A notable person carries 6-12 traits (widened 2026-11-25); an ordinary one 4-6.
- **Bigger rows**: personality rows double (about +4 % / −2 %), tiers scale ×1/×2/×3, path traits carry real build
  stats (sized as a third of a technique passive budget), all through the Modifier System as plain numbers.
- **Traits open things**: each new trait may `open` an event option, a dialogue verb, a sect policy lean or a duel
  stance (`opens` field), and has `likes`/`dislikes` other traits (CK3-style same-trait and opposite-trait opinion),
  so two Reclusive elders like each other and a Just head despises a Deceitful one.

---

## R7. Signature items and item sets (Item Database amendment; user 2026-11-24: "both")

**Signature items.** Notable cast carry named items made for them or handed down: heads 3-4, elders 2-3, key
disciples 1-2. They follow `design/items/` schema (rule 11 bases, rule 20 named items, rule 21 what items give),
proposed in `sects/<key>.items.json`, unpriced until the item catalogue pass.

**Set rule (new, Item DB rule proposal).** A named item may carry `set: <set id>`. A set is 2-5 named items made
together (a sect's regalia, a master's pair of swords, a clan's heirloom suite). Bonuses by pieces worn:

| Pieces | Bonus |
|---|---|
| 2 | Modifiers (plain numbers on stats, Modifier System), about half a single item's budget |
| 3+ | as above, plus at the full set an **Effect** (a rule: hand-designed, unpriced per the Effects memory) |

A set's pieces may be split across holders (a sect's regalia shared by its head and first elder), which is a story:
the set is whole only when one person wears it all, so succession and theft matter. Sets live in
`sects/<key>.items.json` under `sets`.

---

## R8. Cast scale and depth tiers (World Generation amendment: the cast grows from ~100 to ~1,500)

World Generation's fixed cast was 60-100 people (rule 6). This pass writes **about 1,500** authored people, in three
depth tiers, so the fixed world is fixed down to the inner disciples of every great sect:

| Tier | Who | Record |
|---|---|---|
| **A** | heads, Nguyên Anh, first elders, famous figures, key disciples | full: backstory 120-250 words, wants, secret, 6-12 traits, ties, full build, signature items |
| **B** | elders, Kết Đan, notable inner disciples, minor sect heads' circles | backstory 50-100 words, 5-8 traits, ties, build, 0-1 item |
| **C** | inner and outer disciples, loose cultivators, clan members | 1-2 sentences, 4-6 traits, a tie, root + main method |

**Realm quotas** (world targets, memory difficulty-targets: ~27 Nguyên Anh, ~3 Hóa Thần): no new Hóa Thần (3 exist
or are spoken for); Nguyên Anh grows from 16 to at most 27 (each great sect ≤ 4; spare for the loose world);
authored Kết Đan ≤ 170 of 191; Trúc Cơ and Luyện Khí as each file's quota says. Quotas per file: `README.md`.

The game still fills each sect to its capacity with random members under R1 and R2; the authored cast is the top of
each sect and its named people, not all of it.
