# UX Spec: Sect Window

> **Status**: In Review, lean round 2 NEEDS REVISION (2 blocking, 4 advisory: applied 2026-11-24); round 1 was
> 3 blocking, 9 advisory, applied 2026-11-24, see the notes on what the built game does; written 2026-11-24 night by
> Claude under the UI delegation (memory ui-design-delegated). Round 2 brought the body in line with the illustrated
> window as built (`src/ui/windows/sect_window.gd`, `illustrated.gd`); what the code does not do yet is under
> "Not built yet" and in the Open Questions, not described as built.
> **Author**: Claude (ux-designer role)
> **Last Updated**: 2026-11-24
> **Platform Target**: PC (Windows); keyboard and mouse primary, gamepad Partial (`design/ux/hud.md` Platform Adaptation)
> **Template**: UX Spec (lean: the headings of the earlier person spec; `design/ux/person.md` is superseded by the
> character sheet, `design/ux/character-sheet.md`)
> **GDDs read**: `design/gdd/sects.md` (rules 19–22: standing, joining, promotion F13, leaving and desertion F10;
> ranks), `design/ux/hud.md` (element 35: the contribution box opens it; element 5 S; the sect bubble)
> **Patterns used**: Side panel with history, Sticky header and pinned action bar, Section jumps, Confirm in place,
> Reply strip, Look-only lock, Link styles, Will / won't badge and Refusal note (a greyed Promote, Join or Leave says
> why and stays focusable), Breakdown (promotion needs as a checklist). **New, flagged for the library** (to add to
> `interaction-patterns.md`; the character sheet and other windows already share the same pieces from
> `illustrated.gd`): the member / loose / other views of one window; **Hero banner** (a place painting with a dark
> cartouche carrying the name, Hán name and gloss; missing art shows PlaceholderArt named for the sect); **Portrait
> frame** (a framed painting, placeholder when missing); **Portrait medallion** (round, brass ring, with a person
> link and a rank line beside it; a missing portrait shows the placeholder stripes inside the ring); **Icon tile**
> (icon, small label, big value; focusable for its tooltip); **Parchment inset** (a section on parchment with a
> small brass heading); in the library each needs its states: normal, missing art, focused, look-only.
> **Illustrated layout (user 2026-11-24, round-3 mock-up `prototypes/ui-mood/out/r3-sect-l.png`, "Yes, build it")**:
> the seat's place-catalogue painting as a hero banner (assets/art/places/<continent id>.webp) with the name, Hán name
> and gloss on a dark cartouche; the head's portrait beside the kind line, Head and Seat links and four tiles
> (Founded, Members, Treasury, Holds); the notable members (head, then elders by rank and realm, ui_windows.json
> sect.notables) as round portrait medallions with links; then each section as a parchment inset. The header keeps
> only where the player stands with the sect. Width: 62 % of the screen.

---

## Purpose & Player Need

"Where do I stand in my sect, what does the next rank need, and what does my sect hold?" For a member: rank,
contribution and standing, the next rank's gate as a checklist, Promote; the sect's seat, leader, members, treasury,
specialty and territory; Leave (on good terms, or desert). For a loose cultivator (tán tu): the sect whose seat is
here, whether it would take the player and why not, Join; and the sects the player has standing with.

## Player Context on Arrival

From the sect contribution box (element 35, in a sect), the Sect button (Z2) or S, the sect bubble on the map (a sect
seat here), or a sect name link. Usually after missions (contribution rose) or when arriving at a sect's seat.

## Navigation Position

A Z6 window of the window host. Subject: a sect id, or "" for the player's sect (or the sect seated here when the
player has none). Names of places and people open their windows.

## Entry & Exit Points

| Entry | Opens at |
|---|---|
| Contribution box, Sect button, S | the player's sect; a loose cultivator's view when none |
| Sect bubble at a seat | that sect |
| A sect link (person window, place details) | that sect |

Exits: × / Esc (an armed confirm first), history, links, the action bar. A person link (the head's name or a notable
member's name) opens the shared character sheet (`design/ux/character-sheet.md`) through `open_requested("person",
id)`; the head's portrait and the medallion pictures are not links (the name beside them is).

## Layout Specification

### ASCII Wireframe (member view)

The window is 62 % of the screen wide (user 2026-11-24). The body is a dark wood ground; the hero, the head block, the
notable members and every section sit on it. Order as built, member view:

```
+---------------------------------------------------+
| < >  Sect                                     [x] |  S1 frame
| You: outer disciple · contribution 85 · standing 12  S2 sticky header (the only line:
|                                                   |     the banner carries the sect's name)
|---------------------------------------------------|
| +-----------------------------------------------+ |  S3 body, scrolls
| |  hero: the seat's painting (220 px; 150 compact)| |
| | [Thanh Vân Tông 青雲宗 / gloss]  cartouche     | |
| +-----------------------------------------------+ |
| +--------+ +-------------------------------------+|
| | head   | | Great sect · chính đạo · sword arts ||  parchment inset (kind line, links, tiles)
| | portrait| | Head: Trần Vân (link) · Nguyên Anh  ||
| | 160x200| | Seat: Thanh Vân Sơn (link) · region ||
| |(130x165| | [Founded][Members][Treasury][Holds] ||  4 tiles (2 columns when compact)
| |compact)| +-------------------------------------+|
| +--------+                                        |
| NOTABLE MEMBERS (inset)                           |
|  (o) Name (link)        (o) Name (link)           |  round medallions, 2 columns (1 compact)
|      rank · realm           rank · realm          |
| YOUR PLACE (inset)                                |
|  Ladder: ▶ outer · inner · elder · head           |
|  Next: inner disciple                             |
|   ✗ realm Luyện Khí of Trúc Cơ — not met          |
|   ✗ contribution 85 of 400 — not met              |
|   ✓ standing 12 of 0 — met                        |
|  [Promote — realm Trúc Cơ needed; …]              |
| THE SECT (inset): Levels, Holds, Liege (link)     |
| OTHER SECTS (inset)                               |
|  Hắc Phong Môn: standing −40 (hostile)            |
| SERVICES (inset): not in the game yet             |
| LEAVING (inset)                                   |
|  [Leave on good terms…] [Desert…]                 |
|---------------------------------------------------|
| reply strip                                       |  S4
| [Character] [Places]                              |  S5 action bar
+---------------------------------------------------+
```

Your place comes after the hero, head block and notable members, so on a short window Promote and the gate sit below
the fold: see Open Question 3. The Hán name and gloss are on the cartouche; the kind, alignment and specialty are the
heading of the head block.

Loose-cultivator view: S2 reads "Loose cultivator (tán tu)" and "You belong to no sect (tán tu)". With a sect seated
here the same hero, head block and notable members come first, then **SECT HERE** (or **JOINING** when the sect is not
seated here): its standing with you, the `can_join` reasons as ✗ lines, [Join]; then **THE SECT**, **OTHER SECTS**
(standing with you) and **GREAT SECTS** (name, seat, region, alignment: common knowledge). With no sect seated here
there is no hero: "No sect has its seat here. Sects recruit only at their seat."

Other-sect view: the sect's S2 line reads "You are not of this sect. Its standing with you: N"; the hero, head block,
notable members, the facts and Other sects follow; Join shows only through the join section when it applies.

### Component Inventory

| Zone | Component | Type | Shows | Interactive |
|---|---|---|---|---|
| S2 | You line | Text | Rank name, contribution, standing (member); "You belong to no sect (tán tu)" (loose); "You are not of this sect. Its standing with you: N" (other). With a sect there is no sect line in S2: the hero carries the name | Tooltip (member): what contribution buys, how standing moves |
| S3 Hero | Banner | Framed painting + cartouche | The seat's place painting (`assets/art/places/<continent id>.webp`, `seat_art`), 220 px high (150 compact); on a dark brass-edged cartouche: name, Hán name, gloss. No painting: PlaceholderArt with the sect's name | No (not focusable) |
| S3 Head block | Head portrait | Framed painting | The head's portrait, 160×200 (130×165 compact); no head portrait: PlaceholderArt "No painting yet". Absent when the sect has no head | Tooltip: name, "Head of the sect", realm; not focusable |
| S3 Head block | Kind line | Heading text | Great / minor sect, alignment name, specialty name | No |
| S3 Head block | Head and Seat links | Link rows | "Head: name" with the realm; "Seat: place" with the region | Links: person (character sheet), place |
| S3 Head block | Tiles | 4 icon tiles | Founded (year), Members, Treasury (linh thạch), Holds (N regions; the tooltip lists them or "no region") | Focusable for the tooltip; no action |
| S3 Notable members | Medallions | Round portrait + link + rank line | Up to `ui_windows.json` sect.notables (default 4) living members, highest sect rank first, then highest realm: each a 56 px medallion, the name as a link, "rank · realm" under it. Two columns (one compact). Section absent when empty. A missing portrait shows the placeholder stripes inside the ring | Name link opens the character sheet; the medallion picture itself is not focusable |
| S3 Your place | Ladder | Text | The rank ladder **from the data** (`world_generation.json` sects.rank_ladder; names from `sects_members.json` rank_names: outer, inner, elder, head) with the current rank marked ▶ | No |
| S3 Your place | Next rank gate | Checklist | F13's realm, contribution and standing for the next rank, each ✓ / ✗ with have / need and "met" / "not met" (never colour alone), the numbers read from `sects_members.json` promotion (great and minor sects differ). **The head's seat:** the built game does not reach it by promotion (`promotion_needs` says so); F13's head gate (Nguyên Anh, 30,000, standing 60) plus the trial waits for the trial, which is not built: the window shows the session's reason and "the head's trial is not in the game yet" | No |
| S3 Your place | Promote | Button + confirm | Enabled when the gate is met; confirm in place: "Promote to inner disciple? Spends 120 contribution." | Yes |
| S3 The sect | Facts | Rows | Levels, regions held (count and names), liege sect (a link). Seat, head, founded, members, treasury and specialty moved to the head block above | Links |
| S3 Other sects | Rows | Text | Every sect with a non-zero standing with the player; "(hostile)" at the threshold | Sect links |
| S3 Services | Text | Read-only | "Services bought with contribution (residence, treasure loans, teaching) are not in the game yet." (rule 19a; no session command) | No |
| S3 Leaving | Two buttons + confirm | Buttons | "Leave on good terms…" and "Desert…"; each confirm states **what the built game does**: leaving on good terms ends the membership and the rank, and the standing stays; desertion applies F10's fall (−40) capped at −30, so the confirm prints "standing falls from 12 to −28" and "it will treat you as hostile" when at or below `hostile_threshold`. Rule 19a's debts, residence and deposit are not built (no loans or residences exist yet), so nothing about them is claimed | Yes |
| S3 Sect here (loose) | Join | Checklist + button | `can_join`'s reasons as ✗ lines (at the seat, realm floor, standing at the recruit line, not in a sect); [Join] when none; confirm in place | Yes |
| S3 Great sects (loose) | Rows | Text | Name, seat, region, alignment | Sect links |
| S4 | Reply strip | Text | The result lines of Promote, Join or Leave | Dismiss |
| S5 | Character, Places | Buttons | Those windows | Yes |

### Information Hierarchy

1. The player's rank and what the next one needs. On the screen this is the second thing under the S2 line, not the
   first: the hero, head block and notable members come before Your place (see Open Question 3).
2. What the sect is and holds (hero, head, tiles, notable members, the sect facts).
3. Relations with other sects; leaving.

## States & Variants

| State | What changes |
|---|---|
| Member | As the wireframe |
| Loose cultivator | The loose view; Join only at a seat |
| Viewing another sect | No Your place / Leaving; the hero, head block, notable members and facts (the player sees everything: the project's see-everything rule, as in the character sheet, `design/ux/character-sheet.md`) and its standing with the player; Join when at its seat and loose |
| No sect painting | The hero is PlaceholderArt (magenta-and-ink stripes, "PLACEHOLDER") with the sect's name; the cartouche still shows name, Hán name and gloss |
| Head with no portrait | The head frame shows PlaceholderArt "No painting yet"; the Head link stays |
| No head | No head portrait and no Head link; the kind line and Seat link remain |
| No notable members | The Notable members section is left out (no empty heading) |
| Notable with no portrait | The medallion shows the placeholder stripes with the tooltip "PLACEHOLDER · No portrait yet"; the name link stays |
| Compact (below `ui_windows.json` compact_width, e.g. 1280×720) | Hero 150 px, head portrait 130×165, tiles in 2 columns, notable members in 1 column |
| After leaving | The view re-reads into the loose view; focus goes to the first control; the HUD's contribution box fades out (element 35) |
| Empty lists | "none" under Other sects; "no region" in Holds |
| Gate met | Promote enabled |
| Highest rank | "You hold the highest rank" in place of the gate |
| Confirm armed | The confirm row under its button; Esc or Cancel disarms |
| Action refused | The session's reason in the reply strip; the view re-reads after every action |
| Event waiting | Look-only: Promote, Join and Leave disabled with 🔒 and the reason |
| Fallen sect | Viewing a fallen sect (a ruin): "Fell in year N: cause"; no actions |

## Interaction Map

| Input | Action |
|---|---|
| S | Open / close |
| Tab, Up / Down | Controls and rows |
| Enter / click | Activate; links open their windows |
| Home / End, LT / RT | Section jumps: the body's headings in order (Notable members, Your place, The sect, Other sects, …); Home goes to the first heading, End to the last; the hero and head block have no heading and are not jump targets |
| Esc | Disarm, then close |

Focus order as built: the header, then the tiles (focusable for their tooltips) and the Head, Seat and notable-member
name links in body order, then the gate and Promote, then the rest section by section, then the action bar. The
medallion pictures, the head portrait and the hero are not focusable; the name link beside each is the target.
Tab and the arrows move through the tiles and links; there is no separate medallion jump. Z2's Sect button has no
badge (hud.md element 5 lists badges for unspent points and unread news only).

Not built yet: a d-pad order for the medallion grid (two columns) is whatever the focus neighbours give; no "Your
place" jump or sticky Promote (Open Question 3).

Every key is rebindable (hud.md Platform Adaptation).

## Data Requirements

One read, `GameQuery.sect(s, sect_id)`: {mode (member / loose / other), sect: {id, name, name_han, gloss, kind,
alignment_name, specialty, status, founded_year, fell_year, cause, seat {id, name}, region, head {id, name}, members,
treasury, levels, regions [names], liege {id, name}, specialty_name, seat_art (the seat place's continent id: the hero
painting; -1 when none), head {id, name, realm_label, portrait}, notables [{id, name, rank, realm_label, portrait}]}, you: {rank, rank_name, contribution, standing, hostile}, ladder:
[{rank, name, current}], next: {rank_name, gate: [{label, have, need, met}], reachable, top}, join: {here, ok,
reasons}, leave_preview: {standing_now, desert_standing, desert_hostile, hostile_threshold}, others: [{id, name,
standing, hostile}], great: [{id, name, seat, region, alignment}]}. Standing runs −100 to 100 (F10), shown rounded;
"Other sects" lists every sect with a non-zero standing, positive or negative. Join's reasons are `can_join`'s (the
built game checks the seat, the realm floor, the recruit line from the Recruitment dial's default, and membership; the
root-fit condition is not built). Notables: `GameQuery._sect_notables` takes the sect's living members, sorts them by sect rank (highest first), then
realm index (highest first), and keeps the first `ui_windows.json` sect.notables (default 4); the head is expected to
come first by rank, but the code does not pin the head to slot one. Each portrait comes from `portrait_of`; the hero
picture is looked up from `seat_art` by `PortraitPicker.place_painting` and the head and medallion pictures by
`PortraitPicker.texture_for`; a missing one returns null and the window shows PlaceholderArt. Owners: sect facts Sects;
standing and contribution SectMembers (F10); regions Travel & Map; portraits and place paintings the art pipeline
(`assets/portraits`, `assets/art/places`). Notables refresh with the rest of the read. Re-read on open, after every job and on End turn. Built with
SectMembers' pure reads (`standing`, `contribution`, `promotion_needs`, `can_join`, `rank_name`): never `record()`, which
creates a record. Actions: `session.promote()`, `session.join_sect(sect_id)`, `session.leave_sect(desert)` as jobs.

## Events Fired

`action_requested("promote" | "join_sect" | "leave_sect", args)`, `open_requested("person" | "place" | "sect", id)`. A person request (the Head link or a notable member's name) opens
the shared character sheet.

## Transitions & Animations

None of its own; the host's slide is instant under reduced motion.

## Input Method Completeness Checklist

- [x] Keyboard: every control and link
- [x] Mouse: everything clickable
- [x] Gamepad: d-pad, A / B, LT / RT (Partial); the medallion grid's d-pad order is unspecified (Open Question 3)
- [x] No hover-only information: gates and standings are in the text

## Accessibility

Text at the 16 px floor (tooltips 14 px), checked at 75 % and 150 % UI scale; ✓ / ✗ with words ("met", "need 120");
hostile is a word; contrast 4.5:1 text, 3:1 controls. Screen reader: the gate reads "contribution 85 of 120, not met";
armed confirms are announced with their consequence; the reply strip politely.

Illustrated parts (as built, and what is open): no information is carried by a picture alone: the name, rank, realm,
and the tile values are all text. The hero's name sits on a dark cartouche (about 86 % opaque, bone-coloured text);
its contrast on the final colours is not yet measured (Open Question 4). Text on the parchment insets must still meet
4.5:1 on the parchment colour; also unmeasured. The tiles are focusable and carry a tooltip; the medallion's name link
is the accessible target (its text is the person's name, the rank line follows). Not built yet: accessible names that
say "opens the character sheet" for the person links, and a text name on each tile beyond its visible label and value.
Not yet verified at 75 % and 150 % UI scale at the 62 % width.

## Localization Considerations

Rank and sect names in Vietnamese with English glosses where the data has them; numbers follow the language; rows wrap.

## Acceptance Criteria

- [ ] `[GdUnit]` `GameQuery.sect` returns the member, loose and other views as above and leaves `to_dict()` unchanged
      (no SectMembers record is created by reading).
- [ ] `[GdUnit]` The gate lists realm, contribution and standing with met / not met; Promote is enabled exactly when all are met.
- [ ] `[GdUnit]` Promote, Join and both Leave buttons arm first; only Confirm emits the action with its arguments.
- [ ] `[GdUnit]` A loose cultivator away from any seat sees no Join; at a seat, Join shows `can_join`'s reasons when refused.
- [ ] `[GdUnit]` Look-only disables every action with a reason in its accessible name.
- [ ] `[GdUnit]` The desertion confirm prints the standing now and after (F10 fall and ceiling) and "hostile" when it applies.
- [ ] `[GdUnit]` The ladder comes from the data read; at the head step the reason and the trial note show.
- [ ] `[GdUnit]` The read and build take under 50 ms (headless test machine).
- [ ] `[GdUnit]` `GameQuery.sect` returns `notables` (at most the configured count, living members only, highest sect
      rank then realm first), `head.portrait` and `seat_art`; a sect with no members returns an empty `notables`.
- [ ] `[GdUnit]` A sect with no painting, a head with no portrait and a notable with no portrait show PlaceholderArt,
      never a finished-looking stand-in; an empty `notables` leaves out the Notable members section.
- [ ] `[GdUnit]` The hero, the head block (portrait, Head and Seat links, four tiles) and a medallion with its name link
      are built; the name link emits `open_requested("person", id)`.
- [ ] `[Screenshot]` 1280×720 and 1920×1080: the member view and the loose view (a fresh life), compact layout at
      1280×720; nothing clips; contrast 4.5:1 text, 3:1 controls. No screenshot of the illustrated window is retained
      in `production/qa/evidence/` yet (none found 2026-11-24); capture before the story closes.

## Revision: weak-point pass (2026-11-24)

Action bar (weak-point pass, 2026-11-24, #15): the bar leads with the one decision as a gold primary that scrolls to
its confirm, **Join ↓** for an outsider at a sect's seat (its reason in the tooltip while closed) or **Promote ↓** for
a member below the top rank (`GameWindow.bar_jump`). Links to other windows are text buttons with ›.

## Open Questions

- Sect services bought with contribution (sects.md) have no session command yet: listed as "not in the game yet".
- Missions are a season focus (the turn), not a button here; the window says so in Your place.
1. (Decided 2026-11-24, UI owner; the user may overrule: the head (tông chủ) comes first among the notables and stays
   in the list as well as in the head block. Built as a sort by sect rank, highest first, then realm
   (`GameQuery._sect_notables`); the head comes first because the head holds the top rank, and the code does not pin
   the head to slot one.)
2. (Decided 2026-11-24, UI owner; the user may overrule: the cap of 4 is kept; no "see all members" view.)
3. (Decided 2026-11-24, UI owner; the user may overrule: in the member view "Your place" moves above the notable
   members, so Promote is reachable at 1280×720. Not built yet: today it sits after the hero and the notables, in
   `sect_window.gd` `_build`.) A d-pad order for the medallion grid is not built either.
4. **Contrast and scale checks**: measure the cartouche and parchment contrast on the final colours, and the window at
   75 % and 150 % scale at 62 % width; add accessible names that say a person link opens the character sheet, and a
   text equivalent for each tile. Not built yet.
5. (Done 2026-11-24: the library has "Hero painting", "Portrait frame and round medallion", "Icon tile" and
   "Wood ground and parchment inset" entries.)
