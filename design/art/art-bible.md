# Art Bible

> **Status**: Draft (Sections 7–8, icons only, 2026-11-12)
> **Owned By**: art-director
> **Last Updated**: 2026-11-12
> **Art Director Sign-Off (AD-ART-BIBLE)**: SKIPPED 2026-11-12 — lean mode

`/art-bible` writes these nine sections in this order and replaces each
section's `[To be designed]` line as that section is approved. A section still
holding its placeholder is incomplete; a later run fills only those.

## 1. Visual Identity Statement

[To be designed] — a one-line visual rule that resolves any visual ambiguity,
plus 2–3 supporting principles, each with a design test ("when X is ambiguous,
choose Y") and the pillar it serves.

## 2. Mood & Atmosphere

[To be designed] — for each major game state (exploration, combat, victory,
defeat, menus — whichever this game has): the emotional target, lighting
character (time of day, colour temperature, contrast), 3–5 atmospheric
descriptors, and energy level. Each state must look distinct from the others.

## 3. Shape Language

[To be designed] — character silhouette philosophy (readable at thumbnail
size, one distinguishing trait per archetype), environment geometry, UI shape
grammar, and hero versus supporting shapes.

## 4. Color System

[To be designed] — a primary palette of 5–7 colours with their meaning in this
world, semantic colour usage, per-area colour temperature rules, the UI palette
and where it diverges, and colourblind safety: which semantic colours need a
shape, icon or sound backup.

## 5. Character Design Direction

[To be designed] — the player character's visual archetype, how players tell
enemies, NPCs and allies apart at a glance, expression and pose style, and how
much detail survives at game camera distance (LOD philosophy).

## 6. Environment Design Language

[To be designed] — architectural style and its tie to the world's culture,
texture philosophy (painted, PBR or stylised, and why), prop density rules per
area type, and environmental storytelling guidelines.

## 7. UI/HUD Visual Direction

> Scope of this pass (2026-11-12): **iconography** for the fight screen (`design/ux/fight-screen.md`). Drafted by
> art-director with a ux-designer alignment check; conflicts decided by the user. Typography and the rest of the HUD
> stay open.

**Direction (user, 2026-11-12).** Art and ward icons follow the *style* of Path of Exile 2 skill icons (dark square
tile, one dominant hue as a radial glow, one bright subject, rim light, sparks and motion arcs), never any of its icons.
Buff and debuff icons are very simple element glyphs: green for buffs, red for debuffs.

### 7.1 Dark tiles on ink-wash paper

The UI is rice paper with printed numbers; icons are the one place the player sees *a thing* rather than a number, so
they are glowing painted tiles set into the paper, like lacquered ink-stones inlaid in a page: a square filled with one
element hue (7.2), a thin dark frame, a 1 px warm-ink contact shadow and no outer glow. The glow never leaves the tile. This keeps the
anchor. *The world is brushed, the math is printed*: subjects are brush-weight silhouettes, while every number
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

Badges use the ledger typeface, tabular numerals, regular weight, 9 px minimum at 1x, on a flat near-black plate
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

## 9. Reference Direction

[To be designed] — 3–5 references (games, films, art styles or artists). For
each: the specific element to take from it, and what to avoid so the result
does not read as a copy.
