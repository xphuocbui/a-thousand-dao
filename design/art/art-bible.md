# Art Bible

> **Status**: Draft. Sections 1–4 and 7.10–7.16 approved 2026-11-22 (Rosewood Campaign Table); 7.1–7.9 and 8 (icons)
> 2026-11-12; Sections 5, 6 and 9 not yet written. The game concept's "Ink and Ledger" anchor
> (`design/gdd/game-concept.md`, Visual Identity Anchor) is superseded by Section 1; that file is not edited here.
> **Owned By**: art-director
> **Last Updated**: 2026-11-22
> **Art Director Sign-Off (AD-ART-BIBLE)**: CONCERNS (accepted) 2026-11-22 — Section 8 covered icons only (UI
> furniture and fonts added the same day as 8.7; map texture and place art standards still owed); Sections 5, 6 and 9
> not yet written (portraits and unique place art cannot be briefed until they are). Fixed the same day: 7.6's badge
> minimum (11 px, exempt from the 14 px floor) and typeface; the zoomed-out place marker (7.14). Earlier: SKIPPED
> 2026-11-12, lean mode.

`/art-bible` writes these nine sections in this order and replaces each
section's `[To be designed]` line as that section is approved. A section still
holding its placeholder is incomplete; a later run fills only those.

## 1. Visual Identity Statement

> Approved 2026-11-22. Drafted by art-director from the user's mood pick (`prototypes/ui-mood/`: panels
> `fight-b-hardwood-m.png`, map `r2-map-far-m.png` and `map-near-m.png`, windows `r2-person-m.png` and
> `r2-tooltip-m.png`). It replaces the concept's "Ink and Ledger" anchor (`design/gdd/game-concept.md`), keeping that
> anchor's rule that every mechanical number is printed.

**Direction: Rosewood Campaign Table**

**Visual rule:** *The world is painted, the furniture is carved, the numbers are printed.* Art may frame and depict,
but the UI draws every mechanical number and state crisply; none is ever baked into an image.

This keeps the old anchor's strongest idea and drops its ink-wash half. "Carved" separates the pick from the
lacquer, silk, bronze and ink boards the user turned down. "Printed" protects the inspectability the game rests on.
Painted region and place names on the map are art, not mechanics, so they are allowed.

**1. Print over paint** (Pillar 2: Every Number Is Bounded and Visible)
Parchment is the surface you read; wood and brass are the frame. Carved lattice, rivets and corner fittings stay at
the edges, so text never sits on ornament. The painted art and treasure tiles carry no digits; the engine draws
numbers around them.
*Test:* when it is unclear whether a value, count or slot state belongs in the art or the UI, choose engine-drawn type
on plain parchment.

**2. One map, two distances, no generic places** (Pillar 5: A World That Remembers)
Zoomed out, the continent is a paper campaign map: painted peaks and trees, tinted regions, ink borders (bold where the
holder changes, 7.14) and calligraphic names. Zoomed in, it is a golden-hour painted relief with miniature towns and pagodas. The world is the
same every life, so every named place has its own look and its own art, drawn from a written description and lore:
each town, sect seat (tông môn), ruin and blessed land (user, 2026-11-22). A place's art may later step up through
authored stages as it completes great projects or raises its production level, while its level stays a printed
number.
*Test:* when a place could reuse a generic look, it gets its own. When the world changes, borders and control arrive
as UI overlays; the land is never repainted, and only a place's own art advances by stage.

**3. Quiet table, loud build** (Pillar 1: Your Dao, Your Name)
Frames and panels stay brown, brass and parchment, so they never compete for attention. Strong colour is kept for what
belongs to a cultivator: the element-hued art and treasure tiles, the health and spiritual power (linh lực) bars, and
names. A grown build should be the most colourful thing on screen.
*Test:* when deciding whether something earns saturated colour, give it only if it is part of a cultivator's build or
state. Frames, tabs and buttons stay wood and brass; the one exception is a commit button (End turn, an event choice),
which takes the cinnabar seal (Section 4, user 2026-11-22).

*Where the rest lives:* how a place's look is described and how its art changes by stage go in Sections 6 and 8; each
place's description and lore go in a place catalogue (world data), not here. Sizing: 254 named places at two zoom
levels, times any stages, is a large asset count; Section 8 sets the stage count once it is sized.

## 2. Mood & Atmosphere

> Approved 2026-11-22 (drafted by art-director; the season grade adopted by the user as a proposal).

**What never changes.** The rosewood frame, brass fittings, parchment panels, printed type and HUD positions are the
same in every state. Parchment and numbers are never tinted, dimmed or graded, so Section 4's contrast holds everywhere
(Principle 1, Pillar 2), and the land is never repainted (Principle 2). Mood uses four dials only:
- the **grade** (colour and light) of the painted layer;
- the **vignette** (darkened screen edges);
- one **frame accent**: the title-bar corner fittings, lit, plain or dulled;
- **motion** in the art.

| State | Emotional target | Lighting of the painted layer | Descriptors | Energy | Carries the mood |
|---|---|---|---|---|---|
| Map, far (paper) | Calm command: the whole board to plan | No grade; flat even daylight, low contrast | cartographic, unhurried, legible | Low | Ink borders (bold where the holder changes, 7.14), calligraphic names |
| Map, near (painted) | Standing somewhere real | Golden hour, warm raking light, long shadows; **season grade** (proposal, user 2026-11-22): Xuân fresh, Hạ bright, Thu amber, Đông cool grey | lived-in, misty, specific | Low–medium | Drifting mist, the season's light |
| Event card / outcome | Weighing a choice, then the consequence | Dims about 30 % and desaturates; a warm pool of light on the card; one lift as the outcome lands | hushed, deliberate, decisive | Medium-low, one beat | The cinnabar seal on the chosen line |
| Season summary | Taking stock of time spent | Dusk: cooler, lower, longer shadows | reflective, ledger-like, weighty | Low | Age advancing; the season stamp |
| Fight replay | Scrutiny: why it went this way | No painted layer. Dark wood board, lamp-warm parchment columns, highest UI contrast | taut, forensic, lamp-lit | High, controlled | Only art tiles, bars and damage numbers are saturated; brass playhead; accent lit |
| Breakthrough (đột phá) | Held breath, then release | Pre-dawn lifting to dawn; the player's root (linh căn) hues bloom at the vignette edge | rising, luminous, inward | Builds to one peak | Root-hue bloom; accent lit |
| Heavenly tribulation (Thiên Kiếp) | Dread and defiance | Storm grade: cold, near-black sky, very high contrast; Thunder-violet strikes, at most 3 flashes per second | ominous, violent, sublime | Maximum | Each strike lights the land; strikes left printed |
| Travel | Passage; time has a cost | Clear morning, mild warmth | open, patient | Medium-low | Ink route drawn dash by dash; seasons spent printed |
| Cave abode (động phủ) | Safety, ownership | Lamplight, warm, enclosed, heavy vignette (its own view, or a lamp vignette over the map if it stays a window) | sheltered, private, earthy | Low | Gathering-qi array (Tụ Linh) glow in the player's root hues |
| Death, end of a life | Grief, then the world goes on | Drains to ink-wash grey; vignette closes | still, solemn, final | Stillness | Build tiles lose colour last; cinnabar seal on the life record; accent dulled |
| Main menu / new life | Invitation | Pre-dawn, unlit; warms as an origin is chosen | expectant, familiar | Low | The same continent, rolled out again |

**Distinctness.** States split on two axes. Temperature: warm for the near map, event, abode and travel; cool for the
summary, tribulation and death. Energy: from the low planning states up to the tribulation. No two neighbouring states
share both their grade and their vignette.

**Proposals to check.** The season grade, the breakthrough bloom and the tribulation strikes need a technical-artist
feasibility check and the flash test (`design/accessibility-requirements.md`: at most 3 flashes per second). With
reduced motion on, mist and bloom are still images and strikes become one slow brightening.

## 3. Shape Language

> Approved 2026-11-22 (drafted by art-director).

**Shape names the kind; colour names the element.** Anything that can be slotted, cast or opened has one fixed outline,
so the player knows its kind before reading a word. That leaves colour free for the build (Principle 3, Pillar 1).
Shapes still work for colourblind players, so shape carries the meaning and colour only reinforces it.

| Shape | Means | Second feature (when the shape is shared) |
|---|---|---|
| Square, sharp corners, dark frame | An art; a technique manual | Element colour field (7.2) |
| Chamfered square, double line | A ward | Symmetric subject (7.3) |
| Square, rounded corners | An item or treasure | Rim in its rarity colour (Section 4) |
| Small circle with a halo | Buff, counter, stance (soft halo); debuff, status (jagged or dashed halo) | Halo outline and ↑↓ pip (7.4) |
| Circle in a bronze ring | A Dao mark (đạo văn) node | Đạo Đồ screen only (7.9) |
| Dark disc with a glyph | Something you can act on at a place: a person, a sect hall, a market | Map only; badge for a count |
| Diamond | A fixed named place | Map only (replaces the greybox's dots) |
| Parchment rectangle | Something to read: window, tooltip, log | Corner brackets |
| Wood rectangle, brass rim | Something to press: tab, button | Selected = lit brass rim |

**Frames and lattice.** Carved meander lattice (hồi văn) and brass corner fittings sit only at corners and title bars,
never under text (Principle 1). Ornament steps down by rank: windows get full fittings, tooltips small brackets, and
each nested tooltip has less ornament than its parent, so a stack reads as depth. A locked tooltip shows its pin.

**Characters.** Portraits are bust-length, three-quarter view, in the square portrait frame. Each archetype has **one**
trait that reads at thumbnail size:
- sect disciple: robe cut and collar;
- loose cultivator (tán tu): travel cloak and hat;
- mortal: work clothes and no implement;
- demonic beast: a non-human outline.

Power **may** be drawn, but not always (user, 2026-11-25, replacing "realm is never drawn"): a portrait may show a
cultivator's power, such as a qi glow, an aura or an ethereal presence, where it suits the person and the moment, and
many portraits show none. The realm number is still printed by the UI (Pillar 3, Principle 1). On the map, people are discs, not painted figures, because they move each season and changes
arrive as overlays (Principle 2).

**Environment geometry.** Terrain follows real geography: irregular coasts, branching ridges and rivers that drain,
with no symmetric or themed shapes.
- **Villages and towns:** low horizontal clusters of grey-tile roofs, towns inside rectangular walls. Footprint shows
  size.
- **Sect seats (tông môn):** vertical. Stacked pagoda roofs and terraces climb a slope, and each is the tallest outline
  in its land.
- **Ruins:** broken verticals.
- **Blessed lands:** a natural feature leads (a spring, peak or grove), with no roofline on top.

Each place keeps its own outline (Principle 2, Pillar 5).

**Hero and support.** Heroes are the cultivator's tiles, bars and name, and the sect seats on the map: hard edges, the
most value contrast, saturated colour. Support is frames, lattice, terrain and villages: repeated, soft-edged, low
contrast. Each panel has one hero.

## 4. Color System

> Approved 2026-11-22 (drafted by art-director). User decisions the same day: cinnabar for commit buttons only; the
> rarity ladder as proposed; the ward shield keeps its blue and is told apart by hatching. Wood, brass and parchment
> hex values are picked by eye from the mock-ups, and every contrast ratio below is worked out by hand: measure them on
> real screenshots before the theme ships (`design/accessibility-requirements.md`).

**Primary palette**

| Name | Hex | Meaning |
|---|---|---|
| Rosewood | #2A1A12 | The table: every frame and the fight board |
| Brass | #C9A25A | Fittings, rims, headings on wood; lines only, never a bar fill |
| Parchment | #E3D4AE | The surface you read |
| Iron-gall ink | #2B2118 | All printed text and numbers on parchment |
| Cinnabar | #84191B | The seal: committing (End turn, an event choice) and terms (always underlined) |
| Map sea | #5E86A6 | The paper map's water: world, never UI |
| Golden hour | #E2A24A | The light of the painted relief: light, never a UI fill |

**Semantic colours** (on wood / on parchment)

| Use | Colour | Why |
|---|---|---|
| Player, friend | #A8D0FF / #284177 | Cool = you; blue against orange is the safest pair for colourblind players |
| Foe, hostile | #FFB890 / #7A300C | Warm = the other side |
| Health / linh lực (spiritual power) | #C04040 / #4A8CE6 (kept) | Blood and qi |
| Body shield | #B08A5A (kept) | Hardened flesh; brass is never a bar fill, so the two cannot be confused |
| Ward shield | #7AB8D8, hatched, chamfered end cap (kept) | Close to linh lực blue, so shape tells them apart (user decision) |
| Good / bad for you (buff, heal, gain / debuff, danger, loss) | #5BD66B / #E5384F (kept, 7.4) | One polarity pair. On parchment these are halos and ▲▼ marks only; the numbers stay in ink |
| Time running out | Amber #E0A040 / #6E4600 | Lifespan warning, as `design/ux/hud.md` requires; always with the hourglass |
| Elements, damage types | 7.5 (kept) | One colour means one thing everywhere |
| Rarity | Phàm ink #2B2118, Hạ jade #14523B, Trung lapis #1F4580, Thượng amethyst #5E2A84, Cực gilt #5E4316, Thánh wine #7A1030 | Item names and item rims only (`design/gdd/item-database.md` ranks); the rarity word always shows, item names regular weight (people's names are bold) |
| Sect and region fills | Low chroma, below every element colour | Quiet table (Principle 3) |

**Commit buttons.** End turn and the chosen line of an event card are cinnabar buttons with bone text (#E8D9B5, 7.0:1);
every other tab and button is wood with a brass rim, the selected one with a lit rim (user, 2026-11-22; amends
Principle 3's test).

**Colour temperature by layer.**
- **Paper map:** neutral-warm and low chroma.
- **Painted terrain:** warm golden hour; it is the only layer that takes state and season grades (Section 2).
- **Panels:** fixed and never graded.
- **Fight board:** warmth comes only from the lamp-lit parchment; cool comes only from the player's side and the
  elements.

**UI palette.** The UI uses wood, brass, parchment, ink and cinnabar. The world never uses brass or cinnabar, and the UI
never uses greens or sea blues (apart from the semantic colours above).

**Contrast** (base colour / texture limit; text sits on parchment no darker than #D8C7A0, or on wood no lighter than
#40291B). Body text needs 4.5:1, non-text 3:1.

| Pair | Ratio |
|---|---|
| Ink on parchment | 10.0 / 9.4 |
| Player, foe, cinnabar and gilt text on parchment | 5.8–6.3 / 5.5–6.0 |
| Bone #E8D9B5 on wood | 12.0 / 9.7 |
| Brass on wood | 7.0 / 5.7 |
| Player and foe on wood | 10.0–10.5 / 8.0 |
| Terms on wood: light cinnabar #E88A78 | 6.7 / 5.4 |
| Bone on a cinnabar button | 7.0 |
| Brass on parchment | 1.5: **banned**; use gilt #5E4316 |
| Cinnabar on wood | 1.9: **banned**; use #E88A78 |

**Colourblind pairs that fail, and their backups**

| Pair | Backup |
|---|---|
| Health red / buff-heal green | Heals are "+" and rise; buffs sit in their own row with a round halo |
| Buff / debuff | Rows, halo outline, pip, tooltip word (7.4) |
| Gain / loss, danger | ▲▼ marks and +/− signs; danger adds a triangle glyph |
| Ward / linh lực | Hatching and end cap; linh lực has its own labelled bar |
| Thunder / Chaos / Darkness; Ice / Wind / Soul / Metal / Light; Fire / Earth / physical | Element and damage-type glyph beside every number and tile |
| Amber lifespan / brass | Hourglass icon |
| Rarity, relation colours | The rarity word; bold for people, regular for items |
| Player / foe | Passes, but also left/right side and "(You)" |

**To settle when the theme is built.** Body shield #B08A5A almost equals the Đạo Đồ bronze #B08D57 (different
screens); parchment amber #6E4600 sits near gilt #5E4316 (the hourglass separates them); the red-green swap palette
(accessibility requirements) must avoid the player and foe values above. Cinnabar moves to #84191B from earlier
drafts, and the darker on-parchment player and foe colours are new.

## 5. Character Design Direction

[To be designed] — the player character's visual archetype, how players tell
enemies, NPCs and allies apart at a glance, expression and pose style, and how
much detail survives at game camera distance (LOD philosophy).

## 6. Environment Design Language

> Approved by the user 2026-11-23.

**One land, painted once.** The continent is authored and the same every life (fixed world), so its terrain is painted
once, as two layers registered to the 540 × 360 grid (Section 1, Principle 2):
- **Far layer (paper campaign map):** warm parchment, ink coastlines with a soft coloured wash, pale sea with sparse
  brushed waves, mountains as rows of small painted peaks, forests as clusters of round tree symbols, washes for grass,
  desert and dry hills. One painting; region tints, borders and names are engine overlays (7.14).
- **Near layer (painted relief):** a hand-painted scale model seen straight down: individual tree crowns, folded ridges
  with snow, glinting rivers, golden-hour light from the top left. 12 px per tile. No settlements, roads or text: the
  land only.

**Places are built into the land, not stamped on it.** Each named place is painted into its own patch of the near layer,
so its base follows the slope, shore and river that are there, and its light and scale match the land. Shape grammar by
kind (Section 3): villages low clusters of grey or thatch roofs with gardens; towns inside a modest wall or palisade;
markets around a big open square of awnings; cities a rectangular wall with gate towers, dense roofs and suburbs along
the roads; sect seats vertical, stacked pagoda roofs and terraces climbing a slope, the tallest outline in their land;
ruins broken and roofless, no smoke; natural sites (peaks, veins, lakes, groves, vents) lead with the feature and carry
at most a shrine or a ring of stones.

**Architecture and culture.** One civilisation of cultivators: timber halls on stone bases, grey-tile roofs with curved
eaves, red-lacquered halls only for sects and the rich, brass and bronze for fittings and bells, white-walled lanes in the
south, wind-scoured stone in the north and the high ranges. A sect's architecture follows its element leanings and
craft (a forge sect's chimneys, a water sect's bridges), never a theme park.

**Every place has one signature** (Section 1, Principle 2; the place catalogue): one visual element no other place
shares (a nine-tier bell terrace, a spiral white path, smoke rising out of firs). The art brief names it; the painting
makes it the tallest or brightest thing in the patch.

**Texture philosophy.** Painted, not PBR: soft brushwork at map scale, real light (one sun, top left, warm), colour
from the biome, never from a theme. The world's colour stays below the build's (Principle 3): no saturated element
colours in the land except where the world itself glows (a spirit vein, a lava vent), and those are small.

**Growth is visible.** A place's development levels and its great projects' stages are painted from its own painting,
changing only what the level or stage adds (a furnace hall, a second wall ring, an array of lit pillars), so a place
visibly grows in the same spot and the same light. The land under it never changes (Principle 2); world-state changes
(borders, control, war) are overlays.

**Environmental storytelling.** The catalogue's look and lore decide what the painting shows: a burned quarter that was
never rebuilt, a drowned jetty, the dry stream bed where a river once ran. Secrets (hidden places, tile secrets) are
never painted until found.

## 7. UI/HUD Visual Direction

> Scope: 7.1–7.9 are the **iconography** pass (2026-11-12, art-director with a ux-designer check; conflicts decided by
> the user). 7.10–7.16 are the **UI furniture** pass (approved 2026-11-22: panels, type, controls, top bar, map labels,
> motion, and the UX view), following Section 1's Rosewood Campaign Table.

**Direction (user, 2026-11-12).** Art and ward icons follow the *style* of Path of Exile 2 skill icons (dark square
tile, one dominant hue as a radial glow, one bright subject, rim light, sparks and motion arcs), never any of its icons.
Buff and debuff icons are very simple element glyphs: green for buffs, red for debuffs.

### 7.1 Dark tiles on parchment

(Renamed 2026-11-22 from "Dark tiles on ink-wash paper": Section 1 replaced the ink-wash UI with parchment in a
rosewood frame; the tile rules below are unchanged.)

The UI is parchment in a rosewood frame with printed numbers; icons are the one place the player sees *a thing* rather
than a number, so they are glowing painted tiles set into the parchment, like lacquered ink-stones inlaid in a page: a
square filled with one element hue (7.2), a thin dark frame, a 1 px warm-ink contact shadow and no outer glow. The glow
never leaves the tile. This keeps Section 1's rule (*the numbers are printed*): subjects are brush-weight silhouettes,
while every number
(cooldown, stack count, charges) is printed in-engine around the tile or on a flat badge, never baked into the art.
*Glyphs, not paintings* is **revised for icons** (user decision 2026-11-12, after the first vector set was judged too
weak): art, technique, ward and status icons are **painted images made with an image-generation model** and picked by
the user, held to this section's grammar. Each icon keeps its prompt beside it so a set can be regenerated. The vector
pipeline (`tools/asset-pipeline/icons/`) stays for frames, rings and badges, and as the placeholder set.

### 7.2 Art icon grammar

Revised 2026-11-12 (user, after testing the look on GPT Image 2): the painted icon is a **whole-tile colour field**,
not a dark tile with a small glow.

1. **Colour field**: the whole square is one element hue (7.5), rich and saturated, darker toward the corners; nearly
   monochrome, one hue family from deep shadow to blazing white. No second colour.
2. **Rendering**: semi-realistic painted concept art, soft atmospheric edges and motion blur: a cinematic still of the
   spell going off, not flat and not visibly brush-textured.
3. **Subject**: one readable thing caught mid-moment (a projectile streaking, a strike landing, a seal flaring, a bell
   tolling). Solid forms are dark or mid-tone silhouettes cut against intense glowing energy, which is the brightest
   thing in the image. Hands and people only where the art is about them (a palm strike, a stance), never as decoration.
4. **Composition**: dynamic, often diagonal, cropped tight so the effect fills the tile and runs off its edges; strong
   bloom, sparks, smoke or motion streaks. Readable at 48 px.
5. **Frame**: none in the painting. The fixed dark frame (#1E2227, 1 px inner highlight at 25 %) with a 1–2 px light
   rim is added in-engine, so it is the same for every art and reads on both the light and the dark theme.

- **Element** is read from hue (glow and rim) and the family motif: fire rising sparks, water ripple arcs, earth
  falling shards, metal flat glints, wood curling tendrils, ice angular crystals, thunder forked bolts, wind long
  curved streaks, blade one straight slash arc, body an impact burst, force concentric rings, chaos fractured shards,
  soul-song-seal drifting wisps and rings.
- **Tag** (palm, fist, sword, seal, song, bell, talisman, stance, summon, curse, poison, bow, spear) is read from the
  subject's shape. **The silhouette is the identifier**: one build may carry five arts of one element.
- **Role** is a small mark top-left: none for damage; three ticks stacks, hook curse, plus-sprout heal, arc ward,
  flame-dot soul, diamond utility, chain control, double-dot summon.
- **Common arts** use a muted tier (a less saturated colour field and a smaller bright core), so signature arts read brighter.

### 7.3 Ward icon grammar

A ward reads as protection before attack: **chamfered corners and a double-line frame**; a symmetric, closed subject
(shield, bell dome, ring, seal disc, frontal talisman), never a figure in motion; slow concentric effects (ring, halo,
ripple) and no spark trails; a centred, cooler, tighter glow. The drain-paid ward carries a small inverted-drop "pays
linh lực" badge; ward shields carry a stacked-bar badge. Later ward catalogue entries keep the chamfer and double frame
and add one badge per payment kind.

### 7.4 Buffs, debuffs, statuses, counters and stances: icon and number

Revised 2026-11-12 (user: "a green or red halo; just an icon and a number, think Backpack Battles").
- **Display**: each one is **only its icon and a number** (stacks, or pulses left for a timed status); the name, rule and
  timer are in the tooltip. No text label on the chip.
- **Element stacks** use one element icon each, in **the element's own colours** (Section 7.5): Fire flame, Water drop,
  Wood leaf and vine, Metal ingot, Earth three-layer mountain, Ice six-point crystal, Thunder bolt, Wind three curls.
- **Polarity is a halo**: a **green halo (#5BD66B) for a buff**, a **red halo (#E5384F) for a debuff**, drawn in-engine
  around the icon, so one element icon serves both. Backup cues stay: the separate BUFFS and DEBUFFS rows, the halo's
  shape (buff a soft round halo, debuff a jagged or dashed one), a tiny ↑ or ↓ pip, and "Buff" or "Debuff" in the tooltip.
- **Every status, counter and stance has its own icon**: the 13 statuses (Bleed, Withering, Sealed Meridian ...), the
  build counters (Twin flames, Tide, Temper ...) and the stances (Brazier Form, Iron Hide ...). Statuses on a side
  are debuffs (red halo), counters and stances are the owner's (green halo, or no halo for a neutral counter).
- **Element stack painting** (2026-11-12, after the first painted batch: the flat element glyph read as clip art).
  The 8 element stack icons only are painted as **one bold emblem**: centred, about two thirds of the tile, thick
  silhouette, white-hot core in its hue, on a deep near-black vignette tinted with that hue, readable at 24 px with
  room for the halo. **Statuses, counters and stances use the full art style (7.2)** (user, same day: "the basic buffs
  and debuffs are fine, but everything else should be the same"). Subjects are written per icon in
  `tools/asset-pipeline/icons/subjects.py`.
- Glyphs for physical, force, chaos and soul conditions are still open (7.8, F7).

### 7.4b Technique icons

A technique (công pháp) icon is the manual itself: a closed cultivation scripture, scroll or jade slip seen at a slight
angle, its cover emblem drawn from the technique's suite (the payoff art's subject) and glowing in its element hue, on
the same dark tile. Tier shows in the binding: Yellow plain cloth, Profound dark lacquer, Earth jade, Heaven gold. Body
techniques show a figure in a stance instead of a book.

### 7.5 Icon hue table (the colour field of each icon)

| Element | Fire (Hỏa) | Water (Thủy) | Wood (Mộc) | Metal (Kim) | Earth (Thổ) | Ice (Băng) | Thunder (Lôi) | Wind (Phong) |
|---|---|---|---|---|---|---|---|---|
| Hex | #FF7A1A | #2A50E0 | #22B07A | #FFFFFF | #B47A40 | #C8F8FF | #B060FF | #B5F5E0 |

| Land (Đạo Đồ) | Light (Quang) | Darkness (Ám) |
|---|---|---|
| Hex | #FFFBE0 | #8A3AB8 |

Revised 2026-11-20 (user): **Metal is silver-white** (was gold #E3B341, its Five Elements colour), **Earth more
brown** (was ochre #B9772E), **Light a brighter yellow** and **Darkness a dark purple**, so Earth, Metal and Light no
longer read as three golds and Darkness stays apart from Thunder. Painted icons made before this keep the old hues
until regenerated (7.8, F8). **Palette v2 (same day)** replaced the table above with the values now shown, chosen by
measurement: `design/research/poe-node-icons.md` §4b, which also holds the topic colours of the Đạo Đồ stat icons.

| Damage type | Physical | Fire | Cold | Lightning | Force | Chaos | Soul |
|---|---|---|---|---|---|---|---|
| Hex | #BFB39A | #FF7A1A | #C8F8FF | #B060FF | #E58FB5 | #C02CA8 | #CFC4FF |

These are the anchor's element colours lifted to read on near-black (Water's indigo is lifted the most). Hue is for glow
and rim only; subjects keep the near-white core; a whole icon is never tinted. Floating damage numbers and tooltips use
the same table, so one colour means one thing everywhere.

### 7.6 Badge typography and placement

Badges use Literata (7.11), tabular numerals, regular weight, **11 px minimum at 1x** (raised from 9 px, user
2026-11-22: badges are glyph-like and every value is repeated in the tooltip, so they are exempt from 7.11's 14 px
floor), on a flat near-black plate
(#0B0D10 at 85 %, 1 px #1E2227 border, text #F4F1E8), drawn in-engine. **Fixed corners on both sides** (user decision;
the foe column mirrors tile order, not badge positions): top-right ⚡ empowered, bottom-right charges, bottom-left step
(pips when three badges show), top-left reserved for state (low linh lực, "?" for an ambush unknown). Badges cover at
most 30 % of the tile, and every badge value is also in the tooltip.

### 7.7 States (in-engine, never baked)

- **Charging** (user decision: rim ring plus dim glow): the glow sits dim (25–35 %) and a bright ivory ring fills around
  the tile's edge, with one direction and start point for every art, ward and item.
- **Ready**: the ring closes, the glow is at full strength, and a small corner tick appears.
- **Flash** (on fire): 120 ms brighten to the white core and one frame-highlight pulse, eased back over 180 ms; once per
  fire, never looping. Reduced motion replaces it with a 1 s rim colour change.
- **Disabled or unaffordable**: desaturated, glow 15 %, frame dimmed 40 %, plus a diagonal hairline (#8A8478), so it
  never looks like a charging tile.
- Ward durations (cast wards) use an outer arc and shield recharge a bottom bar, so they never share the art ring.

### 7.8 Flags and open points

- **F1** Dark tiles are the highest-contrast thing on the paper screen; the health bar must still read first (squint
  test on a screenshot).
- **F2** Icons carry element hue from the first art; the anchor's "colour appears as the build grows" applies to the
  paper UI, not to icon tiles.
- **F3** Blade and body share bone-grey; wind, wood, soul and the buff green sit close in hue: shape and motif carry
  them.
- **F4** The debuff red is close to Fire: never a fire glow on a debuff chip.
- **F6** The parametric pipeline looks more templated than hand-painting; quality lives in the subject library.
- **F7** Glyphs for physical, force, chaos and soul conditions: undecided.
- **F8 To be changed (user 2026-11-20):** the 57 painted fight icons made in the old Metal gold or Earth ochre must be
  regenerated in the 7.5 hues of 2026-11-20: 39 arts, 10 statuses, 5 techniques, 3 wards (about $6 at medium).
  Find them by the old hex in `assets/icons/PROVENANCE.json` prompts (#E3B341, #B9772E). **Palette v2 (same day,
  `design/research/poe-node-icons.md` §4b) also moves Fire to flame orange #FF7A1A, Wood to qīng #22B07A, Water to
  #2A50E0 and Earth to #B47A40**: every fight icon painted in the old Fire, Wood, Water or Earth hue joins this list,
  and the fight screen's element colours (7.5) follow the v2 table.
- Not adopted (user, 2026-11-12): a flash cap at 4× speed.

### 7.9 Đạo Đồ node art (draft, 2026-11-20)

**Current state, in short (end of 2026-11-20; the bullets below are the day's record and some are superseded):**
- Stat icons: one per stat **and scope** (145), colour = group (palette v2, 7.5 and `design/research/poe-node-icons.md`
  §4b), painted in **style 2** (dark, layered; NOT SETTLED, may go brighter or darker).
- Notables: **one icon per distinct name** (1,414), coloured by main line, shown with a darkening tone (NOT SETTLED).
  Big-picture idea icons are a fallback only.
- Keystones, capabilities, Effect notables, starts: their own icon each (low quality, palette v2).
- Frames: small, road, capability, start in bronze B1; **notables a gilded ruyi-cloud ring**, **keystones an engraved
  dragon disc with an octagonal window**.
- Roads: the qi pearl, colour-mapped per element, candidates mixed per node.
- Files: `assets/icons/dao_do/` as WebP; `INDEX.json` maps every node id to its icon and frame; `CATALOGUE.json` holds
  each icon's subject, real prompt and quality (everything after palette v2 is **low**, marked `"low": true`).
- Display: icons at 85 % of the sizes below; the map's layout was spread on 2026-11-20 so no icons overlap
  (`design/dao-do/layout/`).
- **Deferred to release** (user 2026-11-20: "mark that to do for the future when we release"): the brightness of
  style 2 and of the notable tone; crafts reading close to fortune gold; the F8 fight-icon repaint; a per-icon pass
  (redo the weak ones, medium quality where it shows); wiring `INDEX.json` into the Đạo Đồ screen once a graphical one
  exists (the game has only the debug terminal today).

**Decided by the user (2026-11-20):** the recommended set now, the full set later; **round** nodes, as on a PoE passive
tree. The test batch (12 icons, 6 frames) is the look check before the full run.

- **Shape**: each icon is a painted **circle medallion** (`gen_ai.py` `ROUND_STYLE`): a centred, emblem-like subject in
  one hue family, near-black outside the circle, no frame painted in. The round frame is laid over it.
- **Frames** (user 2026-11-20: flat frames "lack depth"; **painted set B1** picked over a sculpted height-map set):
  six painted aged-bronze rings (road, small, notable, capability, keystone, start), candidate `<kind>_dd0` in
  `tools/asset-pipeline/icons/ai/openai/dd_frame/`. `frames_painted.py` measures each ring and cuts it so its inner edge
  meets the painting's hole. Size rises with weight (game diameters at 1x: road 30, small 40, notable 62, capability
  70, keystone 96, start 110 px). The painting gets an inner shadow so it sits sunk in the frame. A thin enamel line at
  the hole is the **land tint**, coloured in-engine. States (unallocated, allocatable, allocated) are in-engine as in
  7.7, never separate art.
- **Travel nodes (roads)** (user 2026-11-20: "the same but differently colour coded for each element", as PoE's
  Strength, Dexterity and Intelligence nodes): **one motif** is painted in greyscale and colour-mapped by
  `frames_painted.colourize()` to each of the 14 road kinds: 8 single lands, border roads blended between their two
  lands, hub roads ringed with the five elements. Motif: **qi pearl** (user 2026-11-20; acupoint star and rising qi
  not taken), with **both candidates mixed at random**: a road shows candidate `road_candidate(node id)`, stable per
  node. Stat icons stay antique bronze (user, "for now").
- **Hue**: shared stat icons (small nodes, and notables outside a big picture) are painted in a neutral
  **antique bronze (#B08D57)** so one icon reads in every land. Roads, ideas, keystones, capabilities and starts use
  their land's hue (7.5, with Light and Darkness; hub and Chaos #E0409A).
- **Sharing**: small nodes share one icon per stat (68); roads one motif, colour-mapped; notables in a big picture
  share their **idea's** icon (168 ideas, a mirrored pair counting once); a **plain notable reuses the small-node icon
  of its main stat** in the notable frame (user 2026-11-20, as PoE does: all 958 plain notables' main stats have one);
  the 91 named pieces (25 capabilities, 12 Effect notables, 43 keystones, 11 starts) each get their own. About 340
  paintings in all.
- **Lookup and the full set later**: a node looks for `assets/icons/dao_do/node_<id>.png`, then
  `idea_<idea>.png`, then `stat_<main stat>.png`. Upgrading any notable to its own icon is only adding a `node_` file.
- **Subjects** are hand-written per icon in `tools/asset-pipeline/icons/subjects_dao_do.py`. **Descriptions are kept
  for reuse** (user 2026-11-20): `assets/icons/dao_do/CATALOGUE.json` (tracked) holds every icon's subject, the exact
  prompt sent, its candidate files and the nodes it serves (`catalogue_dao_do.py`, which also checks every node has a
  subject). The full run is **one candidate per icon** (user 2026-11-20): 325 icons (66 stat, 168 idea, 25 capability,
  12 Effect, 43 keystone, 11 start). Flat and increased regeneration share one stat icon (health, linh lực).
- **Revised later on 2026-11-20 (user):** (1) stat icons by stat **and scope**, colour = group (palette v2, 7.5 and
  `design/research/poe-node-icons.md` §4b), full colour field with shades; (2) **every notable has its own icon**, one
  per distinct name (1,414; mirrored pairs share one), coloured by its main line, subjects in
  `tools/asset-pipeline/icons/notes/`; idea icons are only a fallback now; (3) **notable and keystone frames v2**
  (PoE study: types differ by outline, colour and window): notables a gilded gold ring with eight ruyi cloud points
  (`dd_frame/notable2_f20`), keystones a heavy engraved dragon disc with an octagonal window (`keystone2_f20`), chosen
  by the user; small, road, capability and start frames stay B1; (4) everything since palette v2 is painted at **low**
  quality (user: "do the whole everything in low, but mark low"): `CATALOGUE.json` records each pick's real quality
  and prompt from the generator log (`"low": true`), medium originals are kept, and `picks_dao_do.py` decides which
  file is used (PICKS.json, then `_lo0`, then `_dd0`).
- **Stat icon style 2 (2026-11-20, NOT SETTLED):** the minor-node icons were repainted darker and layered
  (`gen_ai.STAT_STYLE2`, tag `_l2`; `design/research/poe-node-icons.md` §7). The user: "that looks better for sure, but
  note this down, we might want it brighter or darker, let's not settle for this for now". Brightness and darkness
  stay open: tune with the style 2 prompt's shadow share ("about a quarter near-black") or an in-engine brightness
  curve, compare in the viewer, and keep the `_lo` set until it is decided. Notables, keystones and special icons are
  still in the bright style.
- **Notable tone (2026-11-20, NOT SETTLED):** the user found the notables "a bit bright". Instead of repainting, a
  display tone darkens them: gamma 1.4 on the painting, a vignette leaving 35 % brightness at the rim, saturation 0.9
  (`NOTE_TONE` in the viewer build; the engine should apply the same curve at draw time). The source paintings are
  untouched, so the level can go up or down freely; a repaint in style 2 stays an option (about $8.50 at low).
- **Install** (`install_dao_do.py`): 256 px unframed paintings in `assets/icons/dao_do/` as `stat_<stat>`,
  `idea_<idea>`, `node_<id>` (capabilities, Effect notables, keystones, starts), `road_<kind>_<0|1>`, `frame_<kind>`,
  plus `FRAMES.json` (each frame's hole radius, the road zoom and the road candidate rule).
- Open: frame finish (the test frames are flat vector placeholders; a painted or ornate set may replace them),
  backgrounds per land, connector line and arc art.

### 7.10 Panels and frames (UI furniture, 2026-11-22)

The HUD is screen-space, not diegetic, styled as campaign-table furniture (Section 1). **One furniture family on every
screen**: hardwood frames and parchment bodies, over the map as well (user, 2026-11-22; `map-near-m.png`'s dark
gold-trim panels are a terrain reference only).
- **Window:** a rosewood frame; carved lattice (hồi văn) in the title bar and the corners only; brass corner fittings
  with rivets; a parchment body.
- **Tooltip:** a parchment card with a thin dark-wood edge and small brass corner brackets. Each nested level has one
  step less ornament than its parent (Section 3); a locked tooltip shows its brass pin.
- **Frame budget:** side edges **8 px** at 1280×720 (12 px at 150 % UI scale; raised from 6 px by the user on
  2026-11-22 after the theme sheet, `production/qa/evidence/theme/`); lattice only in title bars and corners, so the
  fight screen keeps its room.
- **Titles:** the title bar is decorative; a window's title is the first heading on its parchment body (user,
  2026-11-22), as in the picked mock-up's log panel.
- **Depth:** one soft drop shadow under floating cards; nothing glows outside its frame.
- **Texture:** parchment never darker than #D8C7A0 under text, wood never lighter than #40291B (Section 4).
- **Build:** frames and textures are nine-slice pieces (stretchable centre and edges, fixed corners) so they scale with
  the UI without blurring the corners.

### 7.11 Typography

Checked in Godot 4.7.1 on 2026-11-22 (`tools/asset-pipeline/ui/font_check.gd`): all three files (Literata upright and
italic, Cormorant Garamond; variable fonts from Google Fonts, OFL, in `assets/fonts/`) have all 146 Vietnamese letters
(every vowel with every tone, upper and lower case, đ Đ), and with the `tnum` OpenType feature on (a `FontVariation`)
all ten digits have one width. Default digits are proportional, so numbers must use the `tnum` variation. Still to
check on screen: hinting and legibility at 14 and 16 px.

| Role | Face | Rule |
|---|---|---|
| Headings, names, window titles | Cormorant Garamond SemiBold | 20 px and above only (its hairlines break up smaller) |
| Labels, body text, log, tooltips | Literata | A serif drawn for screens; the default face |
| Numbers | Literata, tabular lining figures | Columns and resource boxes line up; numbers never shift a layout |
| Region names (zoomed-out map) | A calligraphy-style display face, engine-drawn | See 7.14 |

Size steps 14 / 16 / 18 / 22 / 28 px; floors 16 px for body and 14 px for small text (`design/ux/fight-screen.md`
AC 15). Exempt: icon badges, 11 px minimum (7.6). Ink on parchment, bone (#E8D9B5) on wood, brass for headings on wood only (never brass on parchment,
Section 4).

### 7.12 Controls and states

| Control | Look | States |
|---|---|---|
| Tab, button | Wood plaque, brass rim | Hover: rim brightens. Pressed: 1 px lower, darker. Selected: lit rim and a small brass notch. Disabled: dimmed, no rim, and its hover always says why |
| Commit button (End turn, an event choice) | Cinnabar with bone text (Section 4) | As above |
| Focus ring | Double ring: bone outside, ink inside | The same on wood and parchment; keyboard and gamepad |
| Bar | Recessed brass trough, flat colour fill, numbers printed inside | Ward shields and the reserved share of linh lực hatched |
| Slot | Dark recessed square | Empty: dashed brass line |
| Log line | Ink on parchment; side colours in their on-parchment values | Selected: a darker band and a small cinnabar seal at its start, plus the focus ring when focused |

### 7.13 Top bar and resource boxes

Taken from grand-strategy top bars (user, 2026-11-22; CK3/EU4 layout picked 2026-11-23, `design/ux/hud.md` Z1).
- **The bar** is one continuous strip of carved dark rosewood with a polished brass trim along both edges, a calm
  repeating fret carving and a slim gilt bead under it (`assets/ui/topbar/topbar_strip.png`, tiled sideways).
- **Each resource** sits on the strip, not in its own plaque: a painted **medallion icon** (a brass-rimmed disc of dark
  lacquer holding one painted object) in a round brass socket, its printed tabular number in the bold face, and the
  season's change as ▲ / ▼ with a sign in the smaller face (never colour alone). Thin brass dividers with a small
  diamond separate the resources. Fixed width per resource, so a changing number never shifts the bar.
- **The date** hangs at the right end in a rosewood cartouche with brass scroll ends and a lower edge that dips in the
  middle, holding the season's medallion and the printed season and year.
- Hover opens the breakdown tooltip (income and costs); a click opens the window the resource belongs to. Contextual
  boxes appear only when they apply (sect contribution only in a sect).
- **Icons picked by the user (2026-11-23, 8.6 rule 9):** linh thạch, spirit-stone crystals; lifespan, a longevity
  peach; cultivation, a golden qi orb; rating, crossed swords; renown, a bronze bell; sect contribution, a jade token.
  Seasons: plum blossom (spring), lotus (summer), maple leaves (autumn), snowy pine (winter). Masters, prompts and the
  picks are in `tools/asset-pipeline/ui/` (`kit-topbar`, `kit-res-icons`, `kit-season-icons`, `topbar-picks.json`).

### 7.14 Map labels and markers

- **Zoomed in:** place names in Literata on a dark, see-through label backing, beside the diamond place marker
  (Section 3). Things to do at a place are dark discs with a brass rim and a glyph; counts are a small badge.
- **Zoomed out:** region names in a calligraphy-style display face, **drawn by the engine, not painted into the map**
  (user, 2026-11-22): sharp at every zoom and UI scale, translatable, and readable by screen readers. Place marks are
  small cinnabar diamonds (Section 3's place shape, in the seal colour).
- Borders, control and other world-state changes are overlays (Principle 2).
- **The political map** (zoomed out, 2026-11-23; `design/ux/hud.md` Map zoom and the political map): regions tinted
  in their great sect's colour at 35 % (over the paper, and over the relief when the Sect territory mode is chosen), muted map colours, never a saturated element hue (Section 6);
  a bold ink line where the holder changes, the thin region line between a sect's own regions, both drawn
  smooth (the grid's steps straightened and rounded, never a staircase); each great sect's
  name large and letter-spaced across its territory in the same display face as the region names, which sit smaller
  beneath. All drawn by the engine.

### 7.15 UI motion

The furniture is heavy: nothing bounces, springs or slides across the map.
- Panels fade in over about 120 ms and settle 2 px; they close faster than they open.
- The brass hover light takes about 80 ms; tooltips fade in within 60 ms (their lock timer is ADR-0005's).
- Numbers tick to their new value; a loss gives one brief flash.
- Every animation goes through the reduced-motion setting (instant changes, no tick, no flash), and flashes stay
  within `design/accessibility-requirements.md` (at most 3 per second).

### 7.16 UX view (checked against `design/accessibility-requirements.md` and the UX specs)

- **Interaction fit:** the furniture suits long reading (parchment windows, nested tooltips) and the fight replay (a
  dark board where only tiles, bars and numbers are saturated). The frame budget (7.10) protects the fight screen at
  1280×720.
- **Readability:** the most important things (bars, tiles, numbers) have the strongest contrast; ornament never sits
  under text; a grown build stays the loudest element (Principle 3).
- **Accessibility floor:** the size floors hold (7.11); every colour pair has its backup cue (Section 4); the double
  focus ring passes 3:1 on both surfaces; disabled states never rely on dimming alone; nine-slice frames keep the
  corners sharp at 150 %.
- **Conflict decided by the user (2026-11-22):** the art view wanted the zoomed-out region names painted into the map
  (closest to the mock-up); the UX view wanted them engine-drawn (sharp, translatable, accessible). **Engine-drawn.**
- **To verify on the built theme:** measured contrast on real screenshots (Section 4's ratios are hand-worked);
  Vietnamese coverage and tabular figures of both faces (7.11); no clipping at 1280×720 and 150 % with the frame
  budget.

## 8. Asset Standards

> Scope of this pass (2026-11-12): **icons** (arts, wards, buff and debuff chips). Drafted by art-director and
> technical-artist; their three disagreements were decided by the user. Engine claims about Godot 4.7.1 are from
> training data and **unverified** until one test import confirms them (`docs/engine-reference/godot/` has no notes).

### 8.1 Masters and exports

- **Master**: one SVG per icon, viewBox 256 × 256, named groups (ground, glow, subject, effects, frame, marks). Glow and
  sparks stay inside the canvas with about 12 % padding for falloff; the subject sits in the central ~76 %.
- **Exports** (user decision: one size per class, sized for 2× UI scale; the engine scales down):

  | Class | Shown at | Export | Plus |
  |---|---|---|---|
  | Art | 50 px | 128 × 128 | 256 × 256 for tooltips and the inspect panel |
  | Ward | 40 px | 96 × 96 | — |
  | Buff / debuff chip | 16–20 px | 48 × 48 | drawn as its own simplified master, never a downscaled art icon |
  | HUD medallion (top bar resources, seasons) | 28–32 px | 64 × 64 | a painted brass-rimmed disc on chroma green, cut by `tools/asset-pipeline/ui/cut_topbar.py`; no SVG master (7.13) |

  The art director's five tiers (256/128/64/48/24) were not adopted; revisit only if 1× icons look soft in play.
- **Format**: PNG, sRGB, 8-bit RGBA, straight alpha, no embedded ICC profile, SDR (HDR output must not lift the
  near-black ground).
- **Rendering**: offline, by a pinned renderer from a script, so output is reproducible. Godot's SVG importer
  (ThorVG) is expected not to support `feGaussianBlur` and blend modes (unverified), so SVGs are never imported directly.

### 8.2 Godot import

Individual textures (user decision; atlases only if profiling shows the UI is draw-call bound). Import as **Lossless**
(no VRAM compression: it bands the near-black ground and blocks the glow), **mipmaps off**, **linear** filter, Fix
Alpha Border on, Detect 3D off; one shared import preset. `.import` files are committed; `.godot/` is not.

### 8.3 Naming and folders

Lowercase snake_case ASCII, keyed by the library id, so a data row finds its icon by convention and no lookup table is
needed (user decision):

```text
assets/icons/arts/art_<art_id>.png          (+ art_<art_id>@256.png)
assets/icons/wards/ward_<ward_id>.png
assets/icons/status/buff_<element>.png, debuff_<element>.png
assets/icons/hud/res_<resource>.png, season_<season>.png   (top bar medallions, 7.13)
tools/asset-pipeline/icons/                 subject library, recipes, SVG masters, the render script (outside Godot)
```

Hán-Việt and display names live in the data, never in file names. A missing icon falls back to `art_missing.png` with
a logged warning.

### 8.4 In-engine states and memory

Icons stay single static textures. The charging ring, flash, badges and disabled hatch are separate nodes or one shared
shader (Section 7.7), driven by the fight state. Memory: about 64 KiB per 128 px art icon, about 9.9 MiB for ~170 icons
if all are loaded at once (a fight needs 20–60); a proposed 16 MiB icon budget (no `performance` block exists in
`project.yaml` yet: confirm it there).

### 8.5 Validation script

A pipeline check runs on every render and fails on: a library id with no icon file, a wrong size for its class, a
non-zero alpha on the border pixels, a name outside the convention, or two icons in one family whose 50 px greyscale
silhouettes overlap too closely. It writes a contact sheet at 50 px and 40 px, in colour and greyscale.

### 8.6 Quality checklist (an icon ships only if all pass)

1. **Silhouette at 40 px**: as pure black on white, the subject is recognisable and not confusable with another icon in
   its family.
2. **Value contrast**: subject core at least 7:1 against the local ground at 40 px; the greyscale thumbnail still reads.
3. **Hue rule**: glow and rim use the Section 7.5 hex exactly, one hue per icon; green and red only on chips.
4. **Shape cue**: buff and debuff chips stay distinguishable in deutan, protan and tritan simulations.
5. **Composition**: one subject, at most two effect motifs and 7 sparks; subject 62–72 % of the tile, clear of the frame.
6. **Grammar**: square frame for arts, chamfered double frame for wards, role mark present, badge corners left clear.
7. **Distinctness**: beside its family and one icon from each neighbouring family at 50 px, nothing is mistakable.
8. **No copying**: the subject is original, not traced or closely redrawn from any PoE 2 or other game icon; style
   traits only. A reviewer records the check.
9. **AI-generated icons are allowed** (user decision 2026-11-12, replacing "no AI-generated material"): every shipped
   icon is picked by the user from candidates; its prompt, model and seed are kept beside it; no game's icons are used
   as a style reference or input (the style reference is our own approved icons only).
10. **Technical**: the validation script passes and no banding shows on the near-black ground.
11. **Evidence**: a screenshot of the icons in fight-screen slots at 1× and 2× is kept in `production/qa/evidence/`.

**HUD medallions** (7.13; top bar resources and seasons) pass items 1, 2 (core 7:1 against the medallion's own lacquer ground, at 32 px), 5 (adapted: the disc fills the tile, its subject 62–72 % of the disc's inside, the border pixels clear), 7, 8, 9 and 10 (no banding; `python -I tools/asset-pipeline/ui/cut_topbar.py <repo> check` fails on a missing or extra file in `assets/icons/hud/`, a size other than 64 × 64, a name outside `res_<resource>` / `season_<season>`, or a non-zero alpha on the border pixels), with 32 px in place of 40 and 50 px; items 3, 4 and 6 are combat-icon grammar and do not apply. Item 11's evidence is a top-bar screenshot at 1280×720 and 1920×1080 in `production/qa/evidence/hud-greybox/`.

### 8.7 UI furniture assets (approved 2026-11-22)

**Art view.** A small kit of textures; every state (hover, pressed, selected, disabled, focus) is drawn in the engine,
never baked (7.7, 7.12).

| Piece | Made as | Export (2× UI scale) |
|---|---|---|
| Window frame: rosewood corner with the lattice title-bar end, plus edge strips | Image model, one frame texture with nine-slice margins (`assets/ui/kit.json`) | 655 × 452 at 2× (8 px side border at 1×); a `_1x` copy for the theme |
| Title-bar lattice band | Image model, horizontally tileable | 64 px tall |
| Brass corner fitting (one, mirrored in the engine) | Image model | 48 × 48 |
| Parchment texture, rosewood texture | Seamless, procedural (loom), inside Section 4's limits (parchment #D8C7A0–#E3D4AE, wood #2A1A12–#40291B) | 512 × 512 each |
| Tab / button plaque (wood, brass rim); cinnabar commit plaque | Image model, nine-slice, 12 px margins | 96 × 48 |
| Tooltip corner bracket | Image model | 24 × 24 |
| Bar trough (recessed brass) | Image model, nine-slice | 128 × 32 |
| Slots, focus ring, hover, pressed and disabled states | Drawn in the engine | — |
| Resource icons (top bar, 7.13) | The status-icon pipeline (8.1) | 48 × 48, shown at 24 px |
| Fonts: Cormorant Garamond SemiBold; Literata regular, semibold, italic | OFL font files, licence text beside them | — |

- **Masters:** the image-model output is the master, kept with its prompt, model and seed in
  `tools/asset-pipeline/ui/`; a script cuts and exports the pieces, so the kit can be regenerated.
- **Naming:** `assets/ui/frames/frame_window_corner.png`, `assets/ui/textures/tex_parchment.png`,
  `assets/ui/plaques/plaque_wood.png`, `plaque_cinnabar.png`, `assets/ui/brass/brass_corner.png`,
  `assets/ui/bars/bar_trough.png`, `assets/fonts/<family>/`.
- **No baked text or state glow.** Map textures and place art get their standards with the map test (Section 1,
  Principle 2; Sections 5 and 6 owed).

**Technical view.**
- **Engine:** one Godot `Theme`; `StyleBoxTexture` panels with nine-slice margins, tiled edge and lattice strips,
  `NinePatchRect` for decorative frames. **Unverified**: `docs/engine-reference/godot/` does not cover these or font
  import; one test import confirms them before the full kit is cut.
- **Import:** the icon preset (8.2: lossless, mipmaps off, linear); tiling textures need texture repeat on
  (unverified).
- **Memory:** about 1 MiB per 512² RGBA texture; the kit stays under **8 MiB** (proposed: `project.yaml` has no
  texture-memory budget).
- **Draw calls:** about one per panel plus tiled edges; no draw-call budget is set, and the fight screen's ~60 controls
  are far from threatening 60 fps (16.6 ms).
- **Fonts:** dynamic TTF/OTF; the dynamic-font importer's hinting default changed in 4.x (`breaking-changes.md`), so
  import settings are checked on screen at 14 and 16 px.
- **Conflicts between the views:** none found.

### 8.8 Map and place art standards (approved 2026-11-23)

| Asset | Made as | Size | Notes |
|---|---|---|---|
| Guide render | `tools/asset-pipeline/map/guide.py` | 2160 × 1440 (4 px/tile) | biome colours, hill shade, rivers, sea by depth; the input to every map painting |
| Near layer | 35 overlapping crops painted over the guide, colour-matched, feather-stitched (`paint_tiles.py`), open sea calmed (`sea_fix.py`) | 6480 × 4320 (12 px/tile), JPEG q90 | imported VRAM-compressed with mipmaps (~19 MB VRAM) |
| Far layer | one painting of the whole guide (`prompts/far.md`), high quality; repainted at 3× from 16 overlapping crops of itself (`far_upres.py`, 2026-11-23), then **registered to the true coast** (`register_far.py`: the painting's inked coast found near the grid's, three warp passes; the model had drifted it by up to a few tiles) | 4608 × 3072 (8.5 px/tile), JPEG q92 | BPTC (high quality) with mipmaps; checked with the true coast drawn in red over it (`register_check.jpg`) |
| Provinces | generated, not painted (`tools/design/map/provinces.py`): one per settlement grown by travel cost inside its region, wilderness provinces (drawn like any other) where land is far from any; borders as smoothed, gently wobbled lines | `assets/map/continent_11_provinces.json` (currently 273 provinces, their border lines) | drawn by the engine; never baked into a layer |
| Place art | each place painted into its own 40 × 22.5-tile patch of the near layer (`place_art.py`); a soft-edged circle cut out, fitted to what was painted and capped at 55 % of the distance to the next place | 2× the near layer (24 px/tile), RGBA PNG | `assets/map/places/manifest.json`: tile and size in tiles; drawn for known places only |
| Stage art | levels and great-project stages painted from the place's own painting (`place_stages.py`), cut with the base patch | as place art | `assets/map/places/stages/manifest.json` |

- **Masters and prompts** are kept beside the scripts (`design/map/continent-11/art/`, `tools/asset-pipeline/map/prompts/`)
  with each call's meta file (model, quality, prompt, usage); everything regenerates from the scripts. The master PNGs
  are tracked in Git LFS (`.gitattributes`, `design/map/continent-11/art/**/*.png`).
- **Model:** gpt-image-2, medium for crops and places (high for the single far painting); about $0.053 per medium image.
- **Never baked:** text, labels, borders, markers, region names, player or NPC figures.
- **Memory:** near layer ~19 MB VRAM, far layer ~6 MB, place sprites loaded on first draw (~254 × ~0.6 MB worst case if
  all are seen; budget to confirm in `project.yaml` when performance budgets are set).

## 9. Reference Direction

[To be designed] — 3–5 references (games, films, art styles or artists). For
each: the specific element to take from it, and what to avoid so the result
does not read as a copy.
