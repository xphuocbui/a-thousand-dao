# UX Spec: Sect Window

> **Status**: In Review, lean round 1 NEEDS REVISION (3 blocking, 9 advisory: applied 2026-11-24, see the notes on
> what the built game does); written 2026-11-24 night by Claude under the UI delegation (memory ui-design-delegated)
> **Author**: Claude (ux-designer role)
> **Last Updated**: 2026-11-24
> **Platform Target**: PC (Windows); keyboard and mouse primary, gamepad Partial (`design/ux/hud.md` Platform Adaptation)
> **Template**: UX Spec (lean: the headings of `design/ux/person.md`)
> **GDDs read**: `design/gdd/sects.md` (rules 19–22: standing, joining, promotion F13, leaving and desertion F10;
> ranks), `design/ux/hud.md` (element 35: the contribution box opens it; element 5 S; the sect bubble)
> **Patterns used**: Side panel with history, Sticky header and pinned action bar, Section jumps, Confirm in place,
> Reply strip, Look-only lock, Link styles, Will / won't badge and Refusal note (a greyed Promote, Join or Leave says
> why and stays focusable), Breakdown (promotion needs as a checklist). **New, flagged for the library**: the
> member / loose / other views of one window.
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

Exits: × / Esc (an armed confirm first), history, links, the action bar.

## Layout Specification

### ASCII Wireframe (member view)

```
+-------------------------------------------+
| < >  Sect                             [x] |  S1 frame
| Thanh Vân Tông 青雲宗 · great sect, chính đạo|  S2 sticky header
| You: outer disciple · contribution 85 · standing 12
|-------------------------------------------|
| YOUR PLACE                                |  S3 body
|  Ladder: ▶ outer · inner · elder · head   |
|  Next: inner disciple                     |
|   ✗ realm Luyện Khí of Trúc Cơ — not met  |
|   ✗ contribution 85 of 400 — not met      |
|   ✓ standing 12 of 0 — met                |
|  [Promote — realm Trúc Cơ needed; …]      |
| THE SECT                                  |
|  Seat  Thanh Vân Sơn (link) · region …    |
|  Head  Trần Vân (link) · Members 64       |
|  Treasury 12,400 · Specialty sword arts   |
|  Holds 3 regions: …                       |
| OTHER SECTS                               |
|  Hắc Phong Môn: standing −40 (hostile)    |
| LEAVING                                   |
|  [Leave on good terms…] [Desert…]         |
|-------------------------------------------|
| reply strip                               |  S4
| [Character] [Places]                      |  S5 action bar
+-------------------------------------------+
```

Loose-cultivator view: S2 reads "Loose cultivator (tán tu)"; S3 sections: **SECT HERE** (the seat's sect: name,
kind, alignment, specialty, its standing with you, the join checklist from `can_join`, [Join]), **OTHER SECTS**
(standing with you), and **GREAT SECTS** (name, seat, region, alignment: common knowledge).

### Component Inventory

| Zone | Component | Type | Shows | Interactive |
|---|---|---|---|---|
| S2 | Sect line | Text | Name, Hán name, kind (great / minor), alignment name | Tooltip: gloss |
| S2 | You line | Text | Rank name, contribution, standing; "Loose cultivator (tán tu)" with none | Tooltip: what contribution buys, how standing moves |
| S3 Your place | Ladder | Text | The rank ladder **from the data** (`world_generation.json` sects.rank_ladder; names from `sects_members.json` rank_names: outer, inner, elder, head) with the current rank marked ▶ | No |
| S3 Your place | Next rank gate | Checklist | F13's realm, contribution and standing for the next rank, each ✓ / ✗ with have / need and "met" / "not met" (never colour alone), the numbers read from `sects_members.json` promotion (great and minor sects differ). **The head's seat:** the built game does not reach it by promotion (`promotion_needs` says so); F13's head gate (Nguyên Anh, 30,000, standing 60) plus the trial waits for the trial, which is not built: the window shows the session's reason and "the head's trial is not in the game yet" | No |
| S3 Your place | Promote | Button + confirm | Enabled when the gate is met; confirm in place: "Promote to inner disciple? Spends 120 contribution." | Yes |
| S3 The sect | Facts | Rows | Seat (place link), region, founded year, head (person link), members, treasury (linh thạch), specialty, levels, regions held, liege sect (a link) | Links |
| S3 Other sects | Rows | Text | Every sect with a non-zero standing with the player; "(hostile)" at the threshold | Sect links |
| S3 Services | Text | Read-only | "Services bought with contribution (residence, treasure loans, teaching) are not in the game yet." (rule 19a; no session command) | No |
| S3 Leaving | Two buttons + confirm | Buttons | "Leave on good terms…" and "Desert…"; each confirm states **what the built game does**: leaving on good terms ends the membership and the rank, and the standing stays; desertion applies F10's fall (−40) capped at −30, so the confirm prints "standing falls from 12 to −28" and "it will treat you as hostile" when at or below `hostile_threshold`. Rule 19a's debts, residence and deposit are not built (no loans or residences exist yet), so nothing about them is claimed | Yes |
| S3 Sect here (loose) | Join | Checklist + button | `can_join`'s reasons as ✗ lines (at the seat, realm floor, standing at the recruit line, not in a sect); [Join] when none; confirm in place | Yes |
| S3 Great sects (loose) | Rows | Text | Name, seat, region, alignment | Sect links |
| S4 | Reply strip | Text | The result lines of Promote, Join or Leave | Dismiss |
| S5 | Character, Places | Buttons | Those windows | Yes |

### Information Hierarchy

1. The player's rank and what the next one needs.
2. What the sect is and holds.
3. Relations with other sects; leaving.

## States & Variants

| State | What changes |
|---|---|
| Member | As the wireframe |
| Loose cultivator | The loose view; Join only at a seat |
| Viewing another sect | No Your place / Leaving; the facts (the player sees everything, the project's see-everything rule from person.md) and its standing with the player; Join when at its seat and loose |
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
| Home / End, LT / RT | Section jumps |
| Esc | Disarm, then close |

Focus order: the header, the gate lines, Promote, then section by section, then the action bar. Z2's Sect button
has no badge (hud.md element 5 lists badges for unspent points and unread news only).

Every key is rebindable (hud.md Platform Adaptation).

## Data Requirements

One read, `GameQuery.sect(s, sect_id)`: {mode (member / loose / other), sect: {id, name, name_han, gloss, kind,
alignment_name, specialty, status, founded_year, fell_year, cause, seat {id, name}, region, head {id, name}, members,
treasury, levels, regions [names], liege {id, name}}, you: {rank, rank_name, contribution, standing, hostile}, ladder:
[{rank, name, current}], next: {rank_name, gate: [{label, have, need, met}], reachable, top}, join: {here, ok,
reasons}, leave_preview: {standing_now, desert_standing, desert_hostile, hostile_threshold}, others: [{id, name,
standing, hostile}], great: [{id, name, seat, region, alignment}]}. Standing runs −100 to 100 (F10), shown rounded;
"Other sects" lists every sect with a non-zero standing, positive or negative. Join's reasons are `can_join`'s (the
built game checks the seat, the realm floor, the recruit line from the Recruitment dial's default, and membership; the
root-fit condition is not built). Owners: sect facts Sects; standing and contribution SectMembers (F10); regions Travel &
Map. Re-read on open, after every job and on End turn. Built with
SectMembers' pure reads (`standing`, `contribution`, `promotion_needs`, `can_join`, `rank_name`): never `record()`, which
creates a record. Actions: `session.promote()`, `session.join_sect(sect_id)`, `session.leave_sect(desert)` as jobs.

## Events Fired

`action_requested("promote" | "join_sect" | "leave_sect", args)`, `open_requested("person" | "place" | "sect", id)`.

## Transitions & Animations

None of its own; the host's slide is instant under reduced motion.

## Input Method Completeness Checklist

- [x] Keyboard: every control and link
- [x] Mouse: everything clickable
- [x] Gamepad: d-pad, A / B, LT / RT (Partial)
- [x] No hover-only information: gates and standings are in the text

## Accessibility

Text at the 16 px floor (tooltips 14 px), checked at 75 % and 150 % UI scale; ✓ / ✗ with words ("met", "need 120");
hostile is a word; contrast 4.5:1 text, 3:1 controls. Screen reader: the gate reads "contribution 85 of 120, not met";
armed confirms are announced with their consequence; the reply strip politely.

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
- [ ] `[Screenshot]` 1280×720 and 1920×1080: the loose view (a fresh life); nothing clips; contrast 4.5:1 text, 3:1 controls.

## Open Questions

- Sect services bought with contribution (sects.md) have no session command yet: listed as "not in the game yet".
- Missions are a season focus (the turn), not a button here; the window says so in Your place.
