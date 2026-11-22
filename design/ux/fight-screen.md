# UX Spec: Fight Screen

> **Status**: In Review (revised 2026-11-22 with the user after `/ux-review` NEEDS REVISION, 8 blocking; first approved 2026-11-11)
> **Author**: user + ux-designer
> **Last Updated**: 2026-11-22 (revision after `/ux-review`; the formation diagram replaces the ARTS row, user request)
> **Journey Phase(s)**: unknown — no player journey map yet
> **Platform Target**: PC (Steam / Epic); keyboard and mouse, gamepad Partial (basic pad support, user 2026-11-22)
> **Visual direction**: ink-wash (thuỷ mặc), user choice 2026-11-11; no art bible yet
> **Template**: UX Spec
> **Sources**: `design/gdd/combat.md`, `combat-defence.md`, `combat-damage-types.md`, `effects.md`, `formations.md` (UI Requirements);
> the fight's events come from the combat engine (`tools/design/combat_sim/engine.py`, to be ported to GDScript)

---

## Purpose & Player Need

The player arrives wanting to **see their build work, and understand why the fight went the way it did**. Fights are
auto-resolved (`combat.md`: the choices that decide a fight are made before it), so the screen is for watching and
reading, not acting. It must make the build's engine visible: which art fired, which ward stopped what, which stack or
curse grew, and when a step or empower went off. Without it a loss is only a number, and the concept's promise ("you
can explain exactly why it works") fails.

---

## Player Context on Arrival

The game sends the player here after Preparation, when an encounter becomes a fight (ambush, sect duel, hunt,
tribulation). They have just set their arts, wards and items and are curious or tense to see the plan hold. Fights are
frequent from mid-game, so the screen must be quick to read and quick to skip.

---

## Navigation Position

World / event → Preparation → **Fight screen** → Result screen → back to the caller (event, map, sect).
Context-only: never opened from a menu. A **replay** of a past fight may reopen it from the Result screen or a fight
history (see Open Questions).

---

## Entry & Exit Points

| Entry source | Trigger | Context carried |
|---|---|---|
| Preparation screen | "Begin" | Both sides' loadouts and the fight request (situation, shares, seed) |
| Ambush (blind situation) | An event starts a fight with no preparation | The current loadout as it stands |
| Result screen / fight history | "Watch again" | The recorded fight (seed and events) |

| Exit destination | Trigger | Notes |
|---|---|---|
| Result screen | The fight ends, or the player skips | The outcome is fixed before playback; skipping changes nothing |
| (none mid-fight) | — | No flee or quit here: escape is a combat rule, not a UI button |

---

## Layout Specification

### ASCII Wireframe

Approved 2026-11-11 (user: small portraits; per side the art, ward and item slots, health and linh lực bars, buffs,
debuffs and statuses; everything hoverable; the log in the middle; numbers when something happens; no spectacle yet,
icons pop). Build counters sit in STATUS (user). Icon behaviour borrows the auto-battler loadout pattern (genre
convention, not any one game's look): cooldown fill, flash on fire, link lines. **Revised 2026-11-22 (user):** each
column's ARTS row is that side's **formation diagram** (`design/gdd/formations.md`: the diagram is the art loadout);
see the column detail below.

```
┌──────────────────────────────────────────────────────────────────────────────────────────────┐
│  Kết Đan · Sect duel                     ⏱ 23.4 s   pulse 23                 Foe: Kết Đan    │ ← header
├───────────────────────────────┬──────────────────────────────┬───────────────────────────────┤
│ ┌────┐ Lâm Thanh (You)        │  FIGHT LOG          [Summary▾]│        Hắc Phong (Foe) ┌────┐ │
│ │ ◐  │ Kết Đan · Fire/Wood    │ 23.0  You ◈ Twin Flame Echo  │    Kết Đan · Metal     │ ◑  │ │
│ └────┘                        │       step 2 · 1,240 fire    │                        └────┘ │
│ ▓▓▓▓▓▓▓▓▓▓▓▓░░░░  Health 72%  │       ↳ ward stopped 410     │  Health 41% ░░░░░░▓▓▓▓▓▓▓▓▓▓ │
│ ▒▒▒▒▒░░░░░░░░░░░  Body shield │ 22.5  Foe ◈ Iron Rain        │  Body shield  ░░░░░░░░░░░▒▒▒▒ │
│ ▔▔▔▔▔▔▔▔▔▔▔░░░░░  Ward shield │       880 phys → blocked 120 │  Ward shield  ░░░░░▔▔▔▔▔▔▔▔▔▔ │
│ ████████░░░░▒▒▒▒  Linh lực    │ 22.0  Burn ×12 ticks 96      │  Linh lực     ░░░░░░░░████████ │
│              (▒ reserved)     │ 21.0  pulse: You regen +38   │                               │
│ FORMATION  laid 100%          │ …                            │          carried 70% FORMATION│
│  (the diagram: column detail) │                              │  (the diagram: column detail) │
│ plain [◈5][◈6]                │                              │                [◈5] plain     │
│ WARDS   [⛨][⛨][⛨]             │                              │             [⛨][⛨][⛨]   WARDS │
│ ITEMS   [⚱][⚱]                │                              │                 [⚱][⚱]  ITEMS │
│ BUFFS   🔥×6  🌿×3             │                              │             ⚙×4     BUFFS     │
│ DEBUFFS ❄×2                   │                              │          🔥×12 ☠×3  DEBUFFS   │
│ STATUS  ●●○Twin flames         │                              │   [Withering 4p] Temper×4     │
│         [Slowed 3p] [Curse 2/3]│                              │                     STATUS    │
├───────────────────────────────┴──────────────────────────────┴───────────────────────────────┤
│   ⏮ step   ▶/⏸   1× 2× 4×   ⏭ skip to result          ───●──────────── timeline scrubber    │ ← controls
└──────────────────────────────────────────────────────────────────────────────────────────────┘
   Floating numbers pop over the struck side's bars; icons fill as they charge, flash when they fire,
   and a brief link line runs from one icon to another when it feeds it.
```

**Column detail: your column with the formation diagram** (the foe's mirrors it):

```
│ ┌────┐ Lâm Thanh (You)            │
│ │ ◐  │ Kết Đan · Fire/Wood        │
│ └────┘                            │
│ ▓▓▓▓▓▓▓▓▓▓▓▓░░░░  Health 72%      │
│ ▒▒▒▒▒░░░░░░░░░░░  Body shield     │
│ ▔▔▔▔▔▔▔▔▔▔▔░░░░░  Ward shield     │
│ ████████░░░▒▒▒▒▒  Linh lực        │
│          (▒ reserved: wards + formation) │
│ FORMATION  Ngũ Hành Hoàn   laid 100% │
│        (+◈1)                      │
│       ↗     ↘                     │
│  (?◈4) ——(+◈0)—— (−◈2)            │
│       ↖     ↙                     │
│        (+◈3)                      │
│ plain  [◈5][◈6]                   │
│ WARDS  [⛨][⛨][⛨]                  │
│ ITEMS  [⚱][⚱]                     │
│ BUFFS  🔥×6  🌿×3    DEBUFFS ❄×2   │
│ STATUS ●●○Twin flames [Slowed 3p] │
│        [Escape ▓▓░ 1.2 s]         │
```

`+`, `−` and `?` are the node polarity marks (positive, negative, conditioned); arrows are feed links, plain lines
adjacency links; the sample names are placeholders. **Size rule:** the diagram area holds up to 8 nodes at 1280 × 720
with 32 × 32 px targets; a larger diagram scales its nodes down to the 32 px floor, then scrolls within the area.

### Layout Zones

| Zone | Position | Holds |
|---|---|---|
| Header | Top strip | Realm and situation (sect duel, ambush, tribulation), fight clock and pulse count, the foe's realm |
| Your column | Left third | Your portrait and name, bars, then the formation diagram and its plain slots, then the rows WARDS, ITEMS, BUFFS, DEBUFFS, STATUS |
| Fight log | Centre third | The event log, newest at the top, Summary or Full |
| Foe column | Right third | The mirror of yours: portrait on the right, bars filling from the right |
| Controls | Bottom strip | Step, play/pause, speed, skip to result, the timeline scrubber |

The two columns mirror each other so the eye compares like with like across the log.

### Component Inventory

| Component | Zone | Shows | Interactive | Pattern |
|---|---|---|---|---|
| Portrait | Columns | Small portrait, name, realm, root elements | Hover: character summary (sheet numbers: health, linh lực, ward strength and efficiency, resistances by type, block, body shield, thần thức, power number (Power Rankings)) | Tooltip layer (ADR-0005) |
| Health bar | Columns | Health, with floating numbers on change | Hover: exact numbers | Stat bar (new) |
| Body shield bar | Columns | The body shield as its own bar over health (Combat Defence UI) | Hover | Stat bar |
| Ward shield bar | Columns | One bar per ward shield in slot order, or one segmented bar | Hover: each shield | Stat bar |
| Linh lực bar | Columns | Linh lực; the reserved share drawn as a locked segment, now the wards' **and the formation's** reservation (`formations.md` rule 9a) | Hover: each reservation's share | Stat bar |
| **Formation diagram** | Columns (replaces ARTS) | Round nodes with the art's icon inside, in the Đạo Đồ node grammar (art bible §7.9). **Polarity is a shape in the ring:** + positive, − negative, a condition glyph for conditioned, backed by colour. **Feed links are arrows, adjacency links plain lines.** Each node keeps the art's **cooldown fill**, **flash on fire**, and badges (next step, ⚡ empowered, charges left; dimmed if unaffordable). The heading names the diagram and its **share: "laid 100 %", "carried 70 %" or "50 %"**; a carried diagram is drawn dimmed. Plain slots follow as a short row; the default line ("Plain Row") is that row only | Hover a node: the art tooltip (rule, cost, cooldown, damage parts by type colour, step and empower conditions) **plus the node's rule and its tally so far** (damage by its art, feed seconds given and received, gate time open). Hover a link: its kind and feed seconds. Click the heading: the **diagram Breakdown** (every node and link contribution, the lay fuel burnt, the share, the reservation) | Formation diagram (new) |
| **Feed pulse** | Along a feed arrow | When a fed art's timer drops, a pulse runs along the arrow with the seconds taken off ("−2.0 s") | No | Link line |
| **Gate state** | On a gated node | Open or shut; a brief ring the moment it opens | Hover: its condition | Formation diagram |
| **Escape channel** | STATUS row | While a side channels an escape: a chip with a channel bar and the time left | Hover: the escape art and what interrupts it | Status chip |
| Ward icon | WARDS row | State: waiting, up, down, broken, expired, off; duration ring for cast wards; recharge fill for shields; the default ward when it is the one up | Hover: ward tooltip (payloads, payment, drain paid so far) | Loadout icon |
| Item icon | ITEMS row | Item abilities: cooldown fill, uses left, flash on use | Hover: item tooltip | Loadout icon |
| Buff / debuff chip | BUFFS, DEBUFFS | **Only the element icon and its stack count** (user, 2026-11-12: "just an icon and a number, think Backpack Battles"); a green halo for a buff, a red halo for a debuff (art bible 7.4), **with the halo's shape (soft round for a buff, jagged for a debuff) and a ↑/↓ pip**, so colour is never the only cue (`design/accessibility-requirements.md`; user 2026-11-22) | Hover: name, what each stack does now, time left | Status chip (new) |
| Status chip | STATUS | **Only an icon and a number** for each status (stacks or pulses left), curse (n of 3), the build's **counters** (Twin flames, Tide, Temper) and stance; every one has its own icon (art bible 7.4); **Spent** marks on once-per-fight Effects; counted-chance meters | Hover: the Effects tooltip shape (`design/gdd/effects.md`): name, kind, `closes` for keystones and enablers, then the rule and its limits | Status chip |
| Link line | Over the columns | A brief line from a source icon or chip to the one it feeds (an art adding a counter, a step unlocking, an echo re-firing an art, a ward stopping a hit); a formation feed uses the feed pulse instead | No | Link line (new) |
| Floating number | Over the struck bars | Damage split by part and coloured by final type, with the element tag beside the type colour; heals in their own colour; "evaded", "blocked" | No | Floating number (new) |
| Fight log | Centre | One line per event (Summary) or one line per pulse (Full, `combat.md`: actions, damage by type, resistance, block, shield soaks, heals, **health and linh lực after**), coloured by side; **feed lines** (source, target, seconds) and **gate openings** (`formations.md` UI Requirements) | Click a hit: its Breakdown; a feed or gate line: that node's Breakdown line; switch Summary / Full | Log list (new) |
| Breakdown panel | Over the log | For one hit: evade → resistance (all + type, in points) → block → each ward shield → body shield → health, the drain or fee paid, and each Effect that applied, fired or was clipped and why. **Each part shows its final type and its conversion history** ("Lightning ← Fire ← Physical", AC-DT-23). **Variants:** a Soul hit shows only the soul steps; a tick skips evade and block; a **heal** shows the amount, the healer's healing, the receiver's healing taken and any linh lực refunded (Combat Defence) | Close | Breakdown (new) |
| Playback controls | Bottom | Step one pulse, play/pause, 1× / 2× / 4×, skip to result, timeline scrubber | Yes | Playback bar (new) |

### Information Hierarchy

1. **Health of both sides**, with the body shield and ward shields as their own bars: who is winning.
2. **Linh lực**: most builds lose by running dry; the reserved share shows as a locked segment.
3. **The formation working, and wards firing**: nodes firing, feeds pulsing along arrows, gates opening, cooldown
   fills, step and empower badges.
4. **Buffs, debuffs and STATUS** (statuses, curses, the build's counters, Spent marks): the engine filling up.
5. **The log**, Summary by default; a hit's Breakdown on click.
6. **Hover details**: discovered, never needed to follow the fight.

---

## States & Variants

| State | When | What changes |
|---|---|---|
| Intro | First second | Both columns fill in; bars rise to their starting values (injured sides start lower); a **laid** diagram shows the stones burnt ("laid: 120 linh thạch"), a carried one dims with its share |
| Playing | Default | The clock runs at the chosen speed; events animate |
| Paused | Space, or clicking a log line | Everything freezes; hover and Breakdown still work |
| Stepping | The step keys | . / , (or → / ← with the controls focused) move to the **next or previous event** (an art, a hit, a status, a feed, a pulse); with Shift, a whole pulse; then it pauses (user 2026-11-22). Fights run in instants, not pulses, so stepping by pulse alone would skip events; scrub state is rebuilt from the event list |
| Scrubbing | Dragging the timeline | Jumps to any time; the fight is recorded, so this is free |
| Fatigue (60 s +) | The fight passes `fatigue_start` | The header shows "Fatigue"; both health bars take the flat fatigue loss each pulse, labelled as such |
| Down / Last act | A side reaches 0 with a refusal or last act left | Its portrait greys; a "Down" chip shows its refusals or last act |
| Ended | The fight ends | Labelled with `combat.md`'s result: **Knockout** (a side is Down), **Draw** or **Flight** (an escape succeeded). Playback stops on the last event; "See result" appears; controls stay for review |
| Replay error | The fight record is missing, corrupt or from an older version | "This fight can't be replayed (*reason*)" with "Back to result"; never a crash |
| Empty rows | A side has no laid or carried formation (the default line), or no wards, items or statuses | Each row stays with "none"; the default line shows only the plain-slot row, so the layout is the same for every fight |
| Replay | From the Result screen or fight history | Same screen, starting paused at 0 s, with a "Back to result" exit |
| Loading | None | The fight record is in memory when the screen opens (a live fight hands it over; a replay reads it from the history first), so there is no loading state |

| Variant | Difference |
|---|---|
| Ambush (blind) | Your loadout as it stands; the foe's diagram shape shows, but its nodes are "?" until each fires (Combat Open Question 4); both diagrams are carried (70 % in an ambush, 50 % blind) |
| Boss / tribulation | The foe's column shows its larger pools; boss phases are not modelled yet (Open Questions) |

---

## Interaction Map

**Focus** (revised 2026-11-22): the screen opens with focus on the playback controls. **F6** jumps between zones
(header, your column, log, foe column, controls) and **Tab** moves within one (the HUD's rule). Inside a zone the arrow
keys move focus: spatially between diagram nodes, along a chip row (one Tab stop per row), and **Up / Down through log
lines**. Every focusable element shows the focus ring and a hover highlight, and every hit target is at least
32 × 32 px. A controller disconnecting pauses playback, with a toast saying keyboard and mouse still work (`toast_seconds`, 3 s,
`design/ux/hud.md`).

| Input | Action |
|---|---|
| Space | Play / pause |
| **. / ,** (always), or **→ / ←** when the controls have focus | Next / previous event; with **Shift**, a whole pulse |
| 1 / 2 / 3 | Speed 1× / 2× / 4× |
| **S** | Skip to the result (Enter only activates the focused control, so Enter on Play never skips) |
| L | Log: Summary ↔ Full |
| Hover, or **Q / F2** on a focused element | Tooltip (the HUD's tooltip layer, ADR-0005): portrait, bar, node, link, ward, item, chip |
| Click or **Enter** on a log line | Pause and open that hit's Breakdown (or a feed or gate line's node line) |
| Click or **Enter** on a node, icon or chip | Pin its tooltip and filter the log to its events; again to clear |
| Click or Enter on the formation heading | The diagram Breakdown |
| Drag the timeline; with it focused, ← / → step **by event** (Shift by pulse), PageUp / PageDown ±10 s, Home / End | Scrub |
| Esc | Close the Breakdown or the pinned tooltip; otherwise settings only (no leaving mid-fight, `design/ux/hud.md`) |
| **Gamepad (basic, user 2026-11-22)** | **A** play / pause, **LB / RB** slower / faster, **Y** skip to the result, **D-pad ← / →** step by event, **D-pad ↑ / ↓** move through the log, **X** open the selected line's Breakdown, **B** close it. **Right stick click toggles Inspect** (user 2026-11-22): playback pauses, the D-pad moves a focus ring across nodes, links, chips, bars and the portrait, and each one's tooltip shows (A pins it and filters the log, as a click does); the same button returns to playback. So every number is reachable on a pad |

---

## Data Requirements

The screen only **reads** a recorded fight; it never computes combat.

| Data | Source (owner) | Update trigger | When missing | Notes |
|---|---|---|---|---|
| Fight record | Combat engine (`tools/design/combat_sim/engine.py`, later its GDScript port) | Read once when the screen opens | The replay error state ("This fight can't be replayed") | Seed, both loadouts, and a timed event list: art fired, step unlocked, empowered, hit landed (parts), crit, evaded, hit stopped, tick, heal, shield broken, status applied, cleansed, down, kill |
| Bars, stacks, statuses and counters | Combat engine (per-pulse snapshots in the record) | The nearest snapshot at or before the playback clock, then the events after it | The last known value, marked "—" in its tooltip | Health, body shield, ward shields, linh lực, stacks, statuses, counters |
| Cause of each event | Combat engine | With each event | The log line names only the event; no link line is drawn | The Effect or art that caused it: drives link lines and log lines |
| Tooltip text | Art, ward, item and Effect records (their systems) | When the tooltip opens | "—" for a missing field; the name from the record id | Name, rule, numbers; art damage parts with type colours (Combat Damage Types UI) |
| Hit Breakdown | Combat engine, stored per hit | When opened | "No Breakdown recorded for this hit" | So the screen never recomputes it (Combat Defence UI) |
| Character summary | Character sheet (Combat UI: Character sheet) | When the portrait tooltip opens | The portrait tooltip shows name and realm only | For the portrait tooltip |
| Each side's diagram | Formations (the Set diagram, compiled into the loadout) | Read once when the screen opens | The default line (plain slots only) | Nodes (polarity, rule, the art in each), links (kind, feed seconds), the shape for drawing, laid or carried, share, lay fuel burnt, `reserve_share` |
| New fight-record events | Combat engine | With each event | Events the record lacks (an older record version) are simply not shown; the version is checked first | `feed_fired` (source, target, seconds), `gate_opened` and `gate_closed`, the escape channel (start, end, interrupted), heal parts, each damage part's type history, the ending (knockout, draw, flight), and a **record version** |
| Per-node tally | The fight record (Combat engine): a derived view summed from its events | At the playback clock (scrubbing recomputes it from the events) | 0 for a node with no events | Reading and adding up recorded events, never computing combat; the record reaches the screen through the GameSession rules (ADR-0006: a copy, read while no job runs) |
---

## Events Fired

| Event | When | Payload |
|---|---|---|
| `fight_viewed` | The screen opens | fight id, replay or live |
| `fight_skipped` | Skip to result | fight time reached, speed used |
| `breakdown_opened` | A hit's Breakdown opens | event id |
| `result_reached` | Playback ends or is skipped | fight id |

These four are reserved names: the project has no telemetry system yet. Play, pause, step, speed, scrub, log mode,
pin, filter, tooltips and the diagram Breakdown **fire nothing by design**. The screen changes no game state: the
outcome is fixed before playback.

---

## Transitions & Animations

No spectacle yet (user, 2026-11-11): icons, bars and numbers only.

| Element | Animation | Time |
|---|---|---|
| **Screen enter / exit** | Cross-fade in from Preparation (or the event), out to the Result screen | `motion_fast` (0.15 s) |
| Art (in its node), ward, item icon | Fills as it charges; flashes when it fires or triggers, within the flash cap | flash about 150 ms |
| **Feed pulse** | Runs along the arrow, with "−2.0 s" at the target | about 300 ms |
| **Gate opening** | A brief ring on the node | about 250 ms |
| **Flash cap** | **At most 3 flashes a second on the whole screen** (`design/accessibility-requirements.md` flash limit). Flashes in one instant merge into one, and any beyond the cap show as a steady highlight instead. At 4× every flash is a steady highlight | — |
| Link line | Draws from source to target, then fades | about 400 ms |
| Floating number | Rises and fades over the struck bar | about 700 ms |
| Bars | Ease to the new value; a trailing segment shows the chunk lost | about 120 ms |
| 4× speed | Numbers merge per side per pulse so the screen does not flood | — |
| Reduced motion | Flashes, link lines, feed pulses and gate rings become a static highlight; bars snap; cooldown fills step instead of sliding; floating numbers appear in place without rising; screen transitions are instant | — |

---

## Input Method Completeness Checklist

An item is ticked only where the Interaction Map specifies it. Touch is not targeted (PC).

**Keyboard**
- [x] All interactive elements are reachable with F6 (zones), Tab (within a zone) and the arrow keys (within a row, the diagram and the log)
- [x] Focus order follows the layout: header, your column, log, foe column, controls
- [x] Every mouse action has a key: hover is Q / F2, a click is Enter, dragging the timeline is its focused keys
- [x] Focus is visible at all times (the focus ring on every focusable element)
- [x] Focus does not escape: the fight screen is the only screen shown, and F6 cycles its zones
- [x] Esc closes or cancels (the Breakdown, a pinned tooltip) and never leaves the fight (settings only)

**Gamepad (Partial)**
- [x] All interactive elements are reachable: the log and playback directly, nodes, links, chips, bars and the portrait through Inspect (right stick click)
- [x] Button mapping documented: A play / pause, LB / RB speed, Y skip, D-pad steps and the log, X Breakdown, B close
- [x] No action needs analog precision (the timeline is stepped by event)
- [x] Shoulder shortcuts documented (LB / RB speed; the HUD's bar is hidden on this screen)
- [x] A controller disconnecting pauses playback, with a toast

**Mouse**
- [x] Hover highlights on every interactive element
- [x] Hit targets at least 32 × 32 px, chips included
- [x] Right-click does nothing on this screen (no verbs mid-fight)
- [x] The wheel scrolls the log only

---

## Accessibility

Tier: **Standard**, plus reduced motion and screen-reader support for menus and panels (`design/accessibility-requirements.md`,
committed 2026-11-22; that document wins where the two differ).

- **Text:** at least **16 px** for labels, names and log lines; at least **14 px** for tooltip detail, Breakdown lines
  and chip numbers. It scales with the UI scale (75–150 %, capped so the layout area stays at least 1280 × 720); at
  1280 × 720 each column is about 427 px and the diagram fits in about 200 × 140 px.
- **Contrast:** text **4.5 : 1** (3 : 1 for large text); icons, bars, nodes and the focus ring **3 : 1** against what is
  behind them. Floating numbers sit on a plate or outline so they stay readable over bars.
- **Never colour alone:** damage types carry an icon or letter; health and linh lực differ by label and shape; buff and
  debuff chips have their halo shape and ↑/↓ pip; a node's polarity is a mark in its ring (+, −, a condition glyph); a
  feed is an arrow and adjacency a plain line; the share is printed; endings are words. The red-green colourblind
  mode recolours damage types, element hues and halos.
- **Screen reader:** playback itself is not readable (a Known Intentional Limitation in the accessibility doc); the
  route is the **fight log and the Breakdown**, built from standard controls with names and roles. Log lines are read
  on focus with their time; nothing is announced live during playback; the ending is announced once ("Knockout: you
  won at 41.2 s"). Nodes, chips and icons are **real `Control` nodes** (not drawn into one canvas), so every control, node and icon has
  an accessible name ("Node 1, positive, Twin Flame Echo, ready"); only the link lines and pulses are drawn,
  and the diagram Breakdown reads the diagram as a list.
- **Photosensitivity:** the flash cap (at most 3 flashes a second, Transitions & Animations) and the first-launch
  notice from the accessibility doc.
- **Motor:** no timed input; pause is always available; any speed; every key is rebindable (the HUD's key bindings).
- **Sound:** every sound cue (hits, a ward breaking, the ending) has an on-screen equivalent (a floating number, a
  state change, a log line), so nothing is carried by sound alone.
- **Reduced motion:** as in Transitions & Animations.

---

## Localization Considerations

- Labels in English with Hán-Việt terms (project terminology rule); every string through translation keys.
- **40 % expansion check:**

| Element | Issue | Max length at 1280 × 720 (16 px) | Priority |
|---|---|---|---|
| Formation heading | Vietnamese diagram names are long: the heading wraps to two lines, never truncates | 2 lines of 28 characters | **HIGH** |
| Log lines and Breakdown lines | Built from templates with named slots, never by joining strings; they wrap | 3 lines of 48 characters per line | **HIGH** |
| Chip tooltip title | The status or Effect name | 32 characters | Medium |
| Header situation label | Wraps within the header strip | 40 characters | Medium |
| Playback controls | Icons with tooltips, so labels never sit on the buttons | — (tooltip text only) | Low |
| Ending words (Knockout, Draw, Flight) | Short; a glossary term each | 12 characters | Low |

- **Numbers and times follow the language** (one locale-aware formatter, `design/ux/hud.md`): 23,4 s and 1.240 in the
  Vietnamese UI, 23.4 s and 1,240 in English.

---

## Acceptance Criteria

1. Playback at any speed ends with the same health, linh lực and result as the fight record says.
2. Skipping shows the same Result screen as playing to the end.
3. Scrubbing to 20.0 s shows the same bars as playing to 20.0 s.
4. Every node, link, ward, item, chip, bar and the portrait has a tooltip, reachable by mouse, keyboard (Q) and the
   pad's Inspect mode.
5. A hit's Breakdown steps add up to the damage shown, and each part shows its type history ("Lightning ← Fire ←
   Physical"); a heal shows its heal Breakdown (amount, healing, healing taken, linh lực refunded).
6. Each diagram is drawn with its nodes' polarity marks, feed arrows and adjacency lines; a carried diagram is dimmed
   with its share printed; a laid one shows the stones burnt at the Intro.
7. Every feed that fires shows a pulse along its arrow and a log line with its source, target and seconds.
8. Hovering a node shows its tally so far, and the tallies of all nodes add up to the fight's totals.
9. The diagram Breakdown lists every node and link contribution, the lay fuel, the share and the reservation.
10. The ending is labelled Knockout, Draw or Flight.
11. A missing, corrupt or old-version fight record shows the replay error state with "Back to result".
12. A side with no formation, wards, items or statuses shows "none" rows.
13. `.` steps to the next event and Shift+`.` to the next pulse.
14. The screen opens within 6 frames of the trigger.
15. `[Screenshot]` At 1280 × 720 and at the 150 % UI scale cap, nothing is clipped and text keeps its 16 px / 14 px floors.
16. `[Screenshot]` In greyscale, node polarity, feed versus adjacency, buff versus debuff, and damage type are all still distinguishable.
17. `[Manual]` At 4× with several arts firing, no more than 3 flashes appear in any second (frame-step check).
18. With reduced motion on, nothing moves on its own.
19. Every action works from the keyboard alone.
20. On a gamepad, play, speed, step, skip, the log and the Breakdown all work.
21. `[Manual]` With a screen reader, log lines and the Breakdown are read, and the ending is announced.
22. At 4×, no more than one floating number per side per pulse.
23. Past `fatigue_start` the header shows "Fatigue" and each pulse's fatigue loss is labelled as such.
24. In an ambush the foe's diagram shows its shape with "?" nodes until each fires.
25. An escape channel shows its chip and bar; a successful escape ends the fight labelled Flight.
26. `[Screenshot]` With the longest Vietnamese strings (formation name, log line, header label), nothing truncates and
    every element stays within its max length (Localization).

---

## Open Questions

1. No player journey map or art bible look yet. Author the journey map from `.claude/docs/templates/player-journey.md`;
   the art bible sets the ink-wash look. (The accessibility tier is now committed: Standard.)
2. Does a fight history exist for replays, and how many fights does it keep?
3. How much does an ambush reveal of the foe's loadout (Combat Open Question 4)? This spec shows the diagram's shape
   with "?" nodes until each fires.
4. Boss phases and companion targets are not modelled by the engine yet.
5. Should a text version exist in the Debug Terminal first (the combat GDDs ask for it)?
6. The combat engine must be ported to GDScript before this screen can be built; the record needs the new events
   (feeds, gates, escape channel, heal parts, type history, the ending, a record version).
7. **The diagram editor (Preparation) needs its own UX spec** (the Formations GDD's UX flag), and the Result screen has
   none yet.
8. ~~Large diagrams.~~ **Decided 2026-11-22:** the diagram area holds up to 8 nodes at 1280 × 720 with 32 px targets;
   a larger diagram scales its nodes down to a 32 px floor and then scrolls (Layout). Check the 8-node figure once real
   diagrams exist.
9. **Pattern library gap:** there is no `design/ux/interaction-patterns.md`. This spec's patterns for it: the formation
   diagram, the feed pulse, the playback bar, the stat bar, the loadout icon, the status chip, the log list, the
   Breakdown and the disconnect toast. Tooltips use the HUD's tooltip layer (ADR-0005), not a pattern of their own.
10. ~~**Gamepad tooltip access.**~~ **Decided 2026-11-22:** a pad Inspect mode (right stick click), Interaction Map.
