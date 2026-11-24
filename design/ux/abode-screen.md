# UX Spec: Abode Screen

> **Status**: In Review, lean round 2 NEEDS REVISION (2 blocking, 3 advisory: applied 2026-11-24); written
> 2026-11-24 night by Claude under the UI delegation (memory ui-design-delegated)
> **Header note, 2026-11-24 (illustrated rebuild)**: the window was rebuilt in the illustrated style (user, 2026-11-24:
> `abode_screen.gd` with `Illustrated`): a wood ground, a hero place painting with a brass name plate, and four icon
> tiles under it. The spec below describes that build. The old plain text header is replaced by the hero and tiles
> plus the text home line (see A1).
> **Author**: Claude (ux-designer role)
> **Last Updated**: 2026-11-24
> **Platform Target**: PC (Windows); keyboard and mouse primary, gamepad Partial (`design/ux/hud.md` Platform Adaptation)
> **Template**: UX Spec (lean: the headings of `design/ux/person.md`)
> **GDDs read**: `design/gdd/cave-abode.md` (rules 1–13, F1–F5, UI Requirements: the abode screen, the work picker, the
> claim screen; AC-CA-21), `design/ux/hud.md` (Layout Zones: full screens; element 31 the abode bubble; Z2 A)
> **Patterns used**: Full screen (hud.md: replaces the map, Z1 stays, a back button), Sticky header and pinned action
> bar, Section jumps, Confirm in place, Inline chooser, Reply strip, Look-only lock, Breakdown.
> **New patterns (not yet in `design/ux/interaction-patterns.md`; to be added there)**: Hero painting (a framed
> place painting with a name plate; falls back to PlaceholderArt), Stat tile grid (icon, label, value, optional note;
> 4 columns, 2 when compact). Nearest existing: Stat bar and Status chip. `person.md` is superseded by the character
> sheet; this screen does not link to it (see Entry & Exit).

---

## Purpose & Player Need

"How good is my home, what is it giving me, and what should I build or raise next?" The cave abode (động phủ) or
residence: its grade, slots used, each work's level and what it gives, the clamp lines (where a cap holds
the gain back), the grade upkeep, the next grade's cost; and the work picker: the home works the player can build
with their gain, cost, upkeep and the free level at this grade (each level above costs x2 more). With no home: renting a residence here, and how
to open or claim an abode.

## Player Context on Arrival

From the abode bubble on the map (element 31), the Abode button (Z2) or A, or the season summary's upkeep line.
Usually between seasons: after saving stones, at a breakthrough (a higher grade opens), or when a slot was lost.

## Navigation Position

A **full screen** (hud.md Layout Zones): it replaces the map and every zone but Z1; the top bar stays (its boxes
tooltip-only); a "← Back to map" button top left under Z1; Esc goes back. An event that fires opens over it as a modal.

## Entry & Exit Points

| Entry | Opens at |
|---|---|
| Abode bubble, Abode button, A | the home's top |
| Season summary upkeep line | the home's top |

The claim block names no previous owner (the read carries none), so there is no link to the character sheet from
this screen (Open Question 4).

Exits: Back to map, Esc (an armed confirm or open chooser first). The screen has no uncommitted edits (each build is
one confirmed action), so it never asks before leaving.

## Layout Specification

### ASCII Wireframe (1920×1080; one centred wood-ground column, about 900 px)

```
+--------------------------------------------------------------+
| Z1 top bar (stays)                                           |
| [← Back to map]   Abode: Thanh Phong Cốc                     |  window title
| Grade 2 · 3 of 4 slots · upkeep 40 linh thạch a season       |  A1 text home line
| You are here / You are away: changes need you here (🔒)       |
| +----------------------------------------------------------+ |
| |  hero place painting (180 px high, brass frame)          | |  A1 hero
| |  [ Thanh Phong Cốc · cave abode (động phủ) ]  <- plate   | |
| +----------------------------------------------------------+ |
| [Grade 2] [Slots 3 / 4] [Upkeep 40 a season] [Density 1.85]  |  A1 tiles (2 x 2 when compact)
|--------------------------------------------------------------|
| HOME                                                         |  A2 body
|  Next grade 3: 1,200 linh thạch, 6 slots, a season's work    |
|  [Raise to grade 3…]                                         |
|  Density here 1.85 · your land match 0.72 (Breakdown)        |
| WORKS (3)                                                    |
|  Dưỡng động phủ   level 2 / 3   density +0.04   [Raise…]     |
|  Tụ nguyên trận   level 3 · +12 share · upkeep 3           |
|                   share +8 Hỏa · upkeep 3   [Raise…] [Sleep]  |
|  Linh tuyền       dormant                    [Wake…]          |
| CLAMPS                                                       |
|  layer-1 upkept density clamped at 0.75                      |
| BUILD A WORK                                                 |
|  Linh tuyền  share +2 per level · 300 LT, 1 material, 1 season · free level 3 here; each level above costs x2 more [Build…]
|--------------------------------------------------------------|
| reply strip                                                  |  A3
+--------------------------------------------------------------+
```

No-home view: "You have no home yet." Then **RENT HERE** (on settled ground: each residence grade the place offers,
with rent and the realm minimum, [Rent] and [Buy]), **OPEN A CAVE ABODE** (how: on a wilderness tile, travel there and
pay the opening fee: "choose the tile on the map; the map lens is not in the screens yet"), **CLAIM** (a Left or
ruined abode here: its recorded grade, the grade it comes back at, the fee, [Claim]).

### Component Inventory

| Zone | Component | Type | Shows | Interactive |
|---|---|---|---|---|
| A1 | Back to map | Button (hud.md element 26) | — | Yes; Esc |
| A1 | Home line | Text | Place name, cave abode, residence or starting room, grade, slots used of available, **grade upkeep (abodes) or rent a season (a rented residence)**, "raising to grade n" when pending | Tooltip: rules 3, 6, 8 |
| A1 | Hero | Framed painting (`Illustrated.framed`, 180 px high) | The home place's painting (`PortraitPicker.place_painting(home_place.art)`, art = the place's continent id) with a brass name plate "Place · cave abode / residence / starting room". No painting: PlaceholderArt (magenta stripes, PLACEHOLDER) | No (decorative, see Accessibility) |
| A1 | Stat tiles | 4 tiles (`Illustrated.tile`) | **Grade** (icon), **Slots** used / available (no icon), **Upkeep** (abodes) or **Rent** (residences), in linh thạch with the note "a season" (icon), **Density** at home (icon). They repeat the text home line and the Density row; they replace neither | Focusable; accessibility name "Upkeep 40 a season"; no tooltip (Not built yet: tile tooltips, Open Question 2) |
| A1 | Unpaid warning | Text | "⚠ Upkeep unpaid for n season(s): the abode falls a grade if it stays unpaid." (words, not colour) | No |
| A1 | Here / away | Text | "You are here" or "You are away (at X): changes need you here" with 🔒 | No |
| A2 Home | Next grade | Text + button | Next grade's cost, slots and "needs a higher realm" when the realm cannot hold it; residences: "a residence's grade is fixed" | Raise (confirm in place: cost, a season) |
| A2 Home | Density | Text | The density the player cultivates at home (`place_density`), and what the home works add | Tooltip: the works' layer lines with their clamp lines |
| A2 Home | Leave this home | Disabled button | "Not in the game yet: a home is left when you open, claim or rent another (rule 10)" (the GDD asks for Leave; no session command exists, so it shows, greyed, with its reason) | No |
| A2 Works | Work rows | Rows | Name, level (a work has no highest level, user 2026-11-24; an array shows level / its Trận Pháp max), "dormant" when it sleeps, the gain at the effective level, upkeep (upkept works) | Raise… (confirm: cost, materials, seasons; a share work keeps its element; a standing array's next level is `formation_build`), Sleep / Wake (rule 9 swap, only while a slot is short) |
| A2 Clamps | Lines | Text | Every density line that says "clamped" (rule 13) | No |
| A2 Build | Catalogue rows | Rows | Each home (layer 1) work not yet built: gain per level, next cost (linh thạch, materials, seasons), upkeep, the free level at this grade and the x2 price above it (an array: its max), "no free slot" when full | Build… (confirm; element chooser for share works) |
| A2 No home | Rent rows | Rows | Residence grades here with rent, the realm minimum; refusal reasons | Rent / Buy (confirm) |
| A2 No home | Claim | Block | A claimable abode here: recorded grade, grade after (F4), fee, **works kept** (name and level; upkept ones "if not faded") | Claim (confirm) |
| A2 Works | Rule 9 banner | Text | When a work is dormant: "⚠ A slot is short, so a work sleeps. Choose which one sleeps with Sleep / Wake (the latest built sleeps by default)." | No |
| A3 | Reply strip | Text | The last action's result lines | Dismiss |

### Information Hierarchy

1. Grade and slots (what limits the home).
2. Works and what each gives now.
3. What to build or raise next, and its cost.

## States & Variants

| State | What changes |
|---|---|
| At home, cave abode | As the wireframe |
| At home, residence | No Raise (fixed grade: "rent or buy a better one, or open a cave abode"); no grade upkeep |
| Away | Read-only: every action 🔒 with "you are away: travel home to change it" |
| Upkeep short | The unpaid warning in A1; after a grade fall the rule 9 banner shows on the next open |
| Rent confirm | "… It becomes your home; your current home is left." (take_residence leaves the old home, rule 10) |
| No home | The no-home view |
| No painting for the home place | The hero shows PlaceholderArt (magenta stripes, "PLACEHOLDER", the place name as its label), never a stand-in that looks finished (`.claude/rules/ui-code.md`, 2026-11-24). Cause: `home_place.art` is -1 or `res://assets/art/places/<art>.webp` is missing. The plate and tiles still show |
| Compact (window under `ui_windows.json` `compact_width`, 1500 px: 1280×720) | The tile grid has 2 columns instead of 4; the hero keeps its 180 px height |
| Slot short | The latest built is dormant; Sleep / Wake swaps show (rule 9) |
| Raise pending | "Raising to grade n: takes effect next season"; Raise disabled |
| Action refused | The session's reason in the reply strip; the view re-reads after every action |
| Event waiting | Look-only: actions 🔒 "locked while an event waits"; an event opens over the screen as a modal |

## Interaction Map

| Input | Action |
|---|---|
| A | Open (from the map) / back |
| Esc | Disarm or close a chooser, then back to the map |
| Tab, Up / Down | Controls |
| Home / End, LT / RT | Section jumps |
| Enter / click | Activate |

Every key is rebindable (hud.md Platform Adaptation). On this full screen the top bar's boxes are tooltip-only.

**Focus order:** Back to map, Raise grade, then each work row's buttons left to right, top to bottom, then the
Build rows, then the reply strip's dismiss. On entry focus goes to the first enabled control; after a confirm or a
chooser closes it returns to the row's button. Confirm and Cancel are buttons (Enter on the focused one; Esc cancels).
Gamepad: A activates, B backs out (Cancel, then Back to map); the keyboard key A opens the screen from the map.

## Data Requirements

One read, `GameQuery.abode(s)`: {has_home, here, home_place {id, name, art (the place's continent id for its painting, -1 when none)}, kind (abode / residence), grade, slots,
used, upkeep, pending, unpaid, next {grade, cost, slots, realm_ok}, works: [{key, id, kind (work / array), name, level,
max, eff, dormant, gain, upkeep, stat, share}], clamps [lines], density {total, lines}, catalogue: [{id, name, stat,
per_level, next_cost {lt, materials, seasons}, upkeep, max (0 = none), free_level, surcharge, ok, reason, share}], rent: [...], claim: {...}}.
Built with CaveAbode and MapWorks reads (`home_rec`, `slots`, `used`, `eff_level`, `can_raise`,
`grade_cost`, `grade_upkeep`, `top_grade`, `MapWorks.cost`, `MapWorks.density`), which never write. Actions:
`raise_abode()`, `build_work(id, element)`, `formation_build(id)` (a standing array's next level), `abode_sleep(id,
wake)`, `take_residence(grade, buy)`, `claim_abode()` as jobs.

## Events Fired

`action_requested("raise_abode", [])`, `("build_work", [work_id, element])`, `("formation_build", [array_id])`,
`("abode_sleep", [sleep_key, wake_key])`, `("take_residence", [grade, buy])`, `("claim_abode", [])`; `back_requested`.

| Data | Owner | Null text |
|---|---|---|
| Grade, slots, works, dormancy | CaveAbode | "You have no home yet." |
| Next grade | CaveAbode F1 | "The highest grade." / "A residence's grade is fixed" |
| Clamps | MapWorks.density | "none: no cap holds a gain back" |
| Catalogue | map_works.json (layer 1) | "Every home work is built." |
| Rent | MapWorks.rent, Travel & Map rule 34 | "No residences here" |

## Transitions & Animations

The screen appears at once (no slide). The hero painting and tiles are static (no animation), so reduced motion has
nothing to stop.

## Input Method Completeness Checklist

- [x] Keyboard: every control; Esc back
- [x] Mouse: everything clickable
- [x] Gamepad: d-pad, A / B, LT / RT (Partial)
- [x] No hover-only information: gains, costs and states are in the rows

## Accessibility

Text at the 16 px floor (tooltips 14 px), checked at 75 % and 150 % UI scale; states in words (dormant, away);
locked actions announce "locked: <reason>"; the reply strip is a polite live region; the ⚠ and 🔒 marks come with words;
contrast 4.5:1 text, 3:1 controls. Screen reader: the screen is announced "Abode, Thanh Phong Cốc"; a work row reads
"Tụ nguyên trận, level 3, share plus 12 Hỏa, upkeep 3"; confirms announce their cost. Each stat tile has a text label and value and an accessibility name ("Upkeep 40 a season",
"Slots 3 / 4"); meaning never rests on an icon alone (the Slots tile has none). The hero is decorative: the name it shows
is already in the window title, the plate and the text home line. Not built yet: the hero has no accessibility name or
"decorative" marking in code, and the tiles have no tooltips (Open Question 2). At 1280×720 the tiles (2 columns) and
hero keep the 16 px text floor; tile labels trim with an ellipsis rather than clip (checked by the screenshot below).

## Localization Considerations

Work names are the data's Vietnamese; numbers follow the language; rows wrap.

## Acceptance Criteria

- [ ] `[GdUnit]` `GameQuery.abode` returns the grade, slots, used, upkeep, each work's level, effective level, gain and
      state, the clamp lines and the next grade's cost; it leaves `to_dict()` unchanged.
- [ ] `[GdUnit]` A work over the ceiling shows "counts at n"; a dormant work shows "dormant" and gives nothing.
- [ ] `[GdUnit]` Raise grade, Raise a work and Build arm first; only Confirm emits; a share work asks for the element.
- [ ] `[GdUnit]` Away from home every action is disabled with the away reason.
- [ ] `[GdUnit]` Esc disarms first, then asks the map screen to go back.
- [ ] `[Screenshot]` AC-CA-21: a grade-3 abode with a dormant work and a clamp line, at 1920×1080 and 1280×720 (a fixture
      view, `--abode-fixture`, display only); the starting home at 1920×1080; nothing clips; long rows wrap.
- [ ] `[GdUnit]` The hero and tiles: a view with `home_place.art` pointing at a real painting shows the painting; with
      `art` -1 (or a missing file) the hero holds PlaceholderArt; the tile grid has 4 columns, or 2 when `compact`;
      the four tiles' accessibility names read their label and value. (Test fixtures: `sample_view()` has art 2; add one with -1.)
- [ ] `[Screenshot]` The illustrated build (hero, plate, tiles) in `production/qa/evidence/`: at 1920×1080, at 1280×720
      (compact, 2 × 2 tiles), and one with the placeholder hero. None is retained yet; AC-CA-21 above covers the same
      fixture and must now include them.
- [ ] `[GdUnit]` `GameQuery.abode` fixtures for criteria 1–6 include `home_place.art`.
- [ ] `[GdUnit]` The screen builds in under 50 ms (headless test machine).
- [ ] `[Manual]` 75 % and 150 % UI scale; contrast 4.5:1 text, 3:1 controls; NVDA reads locked actions with their reason.

## Revision: weak-point pass (2026-11-24)

Layout (weak-point pass, 2026-11-24, #5): on a full screen the parchment column is 1440 px (capped by the screen)
and the body two columns: Home, Clamps and Build / Rent / Claim on the left, Works on the right; compact stacks them.
A clamp line's GDD formula reference moves into its tooltip.

## Open Questions

- Leaving an abode has no session command yet (rule 10 runs on opening or claiming another home): not offered here.
- Opening an abode needs a tile pick on the map (a map lens): the screen explains it; the lens is not built.
- Spirit fields as home works (AC-CA-05) wait for #14.
1. (Done 2026-11-24: the library has "Hero painting" and "Icon tile" entries; the tile grid is `Illustrated.grid`.)
2. Not built yet: tooltips on the four tiles, and an accessibility name or "decorative" marking on the hero. Wanted:
   each tile's tooltip names its rule (grade and slots, upkeep, density breakdown), and the hero marked decorative.
3. (Decided 2026-11-24, UI owner; the user may overrule: keep both. The tiles are the at-a-glance figures; the text
   home line carries the wording.)
4. (Later, decided 2026-11-24, UI owner: the previous owner's link on a claimable abode waits until the claim data
   carries an owner id; it carries none now.)
