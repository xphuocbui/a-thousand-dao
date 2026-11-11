# UX Spec: Fight Screen

> **Status**: Ready for review (all sections approved by the user 2026-11-11)
> **Author**: user + ux-designer
> **Last Updated**: 2026-11-11
> **Journey Phase(s)**: unknown — no player journey map yet
> **Platform Target**: PC (Steam / Epic); keyboard and mouse
> **Visual direction**: ink-wash (thuỷ mặc), user choice 2026-11-11; no art bible yet
> **Template**: UX Spec
> **Sources**: `design/gdd/combat.md`, `combat-defence.md`, `combat-damage-types.md`, `effects.md` (UI Requirements);
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
convention, not any one game's look): cooldown fill, flash on fire, link lines.

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
│ ARTS                          │ …                            │                          ARTS │
│ [◈1][◈2][◈3][◈4][◈5]          │                              │          [◈1][◈2][◈3][◈4][◈5] │
│  ◔cd  step2  ⚡empowered       │                              │                               │
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

### Layout Zones

| Zone | Position | Holds |
|---|---|---|
| Header | Top strip | Realm and situation (sect duel, ambush, tribulation), fight clock and pulse count, the foe's realm |
| Your column | Left third | Your portrait and name, bars, then the rows ARTS, WARDS, ITEMS, BUFFS, DEBUFFS, STATUS |
| Fight log | Centre third | The event log, newest at the top, Summary or Full |
| Foe column | Right third | The mirror of yours: portrait on the right, bars filling from the right |
| Controls | Bottom strip | Step, play/pause, speed, skip to result, the timeline scrubber |

The two columns mirror each other so the eye compares like with like across the log.

### Component Inventory

| Component | Zone | Shows | Interactive | Pattern |
|---|---|---|---|---|
| Portrait | Columns | Small portrait, name, realm, root elements | Hover: character summary (sheet numbers: health, linh lực, ward strength and efficiency, resistances by type, block, body shield, thần thức) | Tooltip (new) |
| Health bar | Columns | Health, with floating numbers on change | Hover: exact numbers | Stat bar (new) |
| Body shield bar | Columns | The body shield as its own bar over health (Combat Defence UI) | Hover | Stat bar |
| Ward shield bar | Columns | One bar per ward shield in slot order, or one segmented bar | Hover: each shield | Stat bar |
| Linh lực bar | Columns | Linh lực, the reserved share drawn as a locked segment | Hover | Stat bar |
| Art icon | ARTS row | The art; **cooldown fill**; **flash on fire**; badges: next step (multi-step arts), ⚡ empowered, charges left; dimmed if unaffordable | Hover: art tooltip (rule, cost, cooldown, damage parts by type colour, step and empower conditions) | Loadout icon (new) |
| Ward icon | WARDS row | State: waiting, up, down, broken, expired, off; duration ring for cast wards; recharge fill for shields; the default ward when it is the one up | Hover: ward tooltip (payloads, payment, drain paid so far) | Loadout icon |
| Item icon | ITEMS row | Item abilities: cooldown fill, uses left, flash on use | Hover: item tooltip | Loadout icon |
| Buff / debuff chip | BUFFS, DEBUFFS | Element stacks with a count; their time left | Hover: what each stack does now | Status chip (new) |
| Status chip | STATUS | Statuses with stacks and pulses left; curse slots (n of 3); the build's **counters** (Twin flames, Tide, Temper) with their count; **Spent** marks on once-per-fight Effects; counted-chance meters | Hover: the Effect's rule and limits | Status chip |
| Link line | Over the columns | A brief line from a source icon or chip to the one it feeds (an art adding a counter, a step unlocking, an echo re-firing an art, a ward stopping a hit) | No | Link line (new) |
| Floating number | Over the struck bars | Damage split by part and coloured by final type; heals in their own colour; "evaded", "blocked" | No | Floating number (new) |
| Fight log | Centre | One line per event (Summary) or per pulse in full (Full), coloured by side | Click a hit: its Breakdown; switch Summary / Full | Log list (new) |
| Breakdown panel | Over the log | For one hit: evade → resistance (all + type, in points) → block → each ward shield → body shield → health, the drain or fee paid, and each Effect that applied, fired or was clipped and why | Close | Breakdown (new) |
| Playback controls | Bottom | Step one pulse, play/pause, 1× / 2× / 4×, skip to result, timeline scrubber | Yes | Playback bar (new) |

### Information Hierarchy

1. **Health of both sides**, with the body shield and ward shields as their own bars: who is winning.
2. **Linh lực**: most builds lose by running dry; the reserved share shows as a locked segment.
3. **Arts and wards firing**: cooldown fills, flashes, step and empower badges, link lines.
4. **Buffs, debuffs and STATUS** (statuses, curses, the build's counters, Spent marks): the engine filling up.
5. **The log**, Summary by default; a hit's Breakdown on click.
6. **Hover details**: discovered, never needed to follow the fight.

---

## States & Variants

| State | When | What changes |
|---|---|---|
| Intro | First second | Both columns fill in; bars rise to their starting values (injured sides start lower) |
| Playing | Default | The clock runs at the chosen speed; events animate |
| Paused | Space, or clicking a log line | Everything freezes; hover and Breakdown still work |
| Stepping | The step key | Advances one pulse (1 s of fight time), then pauses |
| Scrubbing | Dragging the timeline | Jumps to any time; the fight is recorded, so this is free |
| Fatigue (60 s +) | The fight passes `fatigue_start` | The header shows "Fatigue"; both health bars take the flat fatigue loss each pulse, labelled as such |
| Down / Last act | A side reaches 0 with a refusal or last act left | Its portrait greys; a "Down" chip shows its refusals or last act |
| Ended | A side falls or is culled | Playback stops on the final blow; "See result" appears; controls stay for review |
| Replay | From the Result screen or fight history | Same screen, starting paused at 0 s, with a "Back to result" exit |

| Variant | Difference |
|---|---|
| Ambush (blind) | Your loadout as it stands; the foe's slots show "?" until each fires (Combat Open Question 4) |
| Boss / tribulation | The foe's column shows its larger pools; boss phases are not modelled yet (Open Questions) |

---

## Interaction Map

| Input | Action |
|---|---|
| Space | Play / pause |
| → / ← | Step one pulse forward / back (back is a scrub) |
| 1 / 2 / 3 | Speed 1× / 2× / 4× |
| Enter or S | Skip to the result |
| L | Log: Summary ↔ Full |
| Hover | Tooltip on a portrait, bar, art, ward, item, buff, debuff or status |
| Click a log line | Pause and open that hit's Breakdown |
| Click an icon or chip | Pin its tooltip and filter the log to that piece's events; click again to clear |
| Esc | Close the Breakdown or pinned tooltip; otherwise nothing (no quitting mid-fight) |
| Drag the timeline | Scrub |

---

## Data Requirements

The screen only **reads** a recorded fight; it never computes combat.

| Data | Source | Notes |
|---|---|---|
| Fight record | Combat engine (`tools/design/combat_sim/engine.py`, later its GDScript port) | Seed, both loadouts, and a timed event list: art fired, step unlocked, empowered, hit landed (parts), crit, evaded, hit stopped, tick, heal, shield broken, status applied, cleansed, down, kill; plus per-pulse snapshots of health, body shield, ward shields, linh lực, stacks, statuses and counters |
| Cause of each event | Combat engine | The Effect or art that caused it: drives link lines and log lines. The engine knows it; the record must keep it |
| Tooltip text | Art, ward, item and Effect records | Name, rule, numbers; art damage parts with type colours (Combat Damage Types UI) |
| Hit Breakdown | Combat engine, stored per hit | So the screen never recomputes it (Combat Defence UI) |
| Character summary | Character sheet (Combat UI: Character sheet) | For the portrait tooltip |

---

## Events Fired

| Event | When | Payload |
|---|---|---|
| `fight_viewed` | The screen opens | fight id, replay or live |
| `fight_skipped` | Skip to result | fight time reached, speed used |
| `breakdown_opened` | A hit's Breakdown opens | event id |
| `result_reached` | Playback ends or is skipped | fight id |

The screen changes no game state: the outcome is fixed before playback.

---

## Transitions & Animations

No spectacle yet (user, 2026-11-11): icons, bars and numbers only.

| Element | Animation | Time |
|---|---|---|
| Art, ward, item icon | Fills as it charges; flashes when it fires or triggers | flash about 150 ms |
| Link line | Draws from source to target, then fades | about 400 ms |
| Floating number | Rises and fades over the struck bar | about 700 ms |
| Bars | Ease to the new value; a trailing segment shows the chunk lost | about 120 ms |
| 4× speed | Numbers merge per side per pulse so the screen does not flood | — |
| Reduced motion | Flashes and link lines off; bars snap | — |

---

## Input Method Completeness Checklist

- [x] Keyboard: every action has a key (Interaction Map)
- [x] Mouse: hover tooltips, click to pin and filter, drag the timeline
- [x] Every hover target is reachable by Tab, with its tooltip on focus
- [ ] Gamepad: not targeted (PC, keyboard and mouse)
- [ ] Touch: not targeted

---

## Accessibility

No project accessibility tier is committed yet (Open Questions). Baseline for this screen:
- Damage-type colours always come with a type icon or letter; health and linh lực differ by label and shape, never by
  colour alone.
- Text scaling; the log and the Breakdown can be read as plain text.
- Reduced motion turns off flashes and link lines.
- Any speed, and pause is always available: nothing is timed for the player.

---

## Localization Considerations

- Labels in English with Hán-Việt terms (project terminology rule).
- Log lines are built from templates with named slots, never by joining strings.
- Numbers use the locale's separators.
- Leave about 30 % room in labels and chips for longer languages.

---

## Acceptance Criteria

1. A recorded fight plays back with the same health, linh lực and winner as the engine's result.
2. Skipping reaches the Result screen with the same outcome.
3. Scrubbing to any time shows the same bars as playing up to it.
4. Every art, ward, item, buff, debuff and status has a tooltip.
5. Clicking a hit opens a Breakdown whose steps add up to the damage shown.
6. Every multi-step art shows its next step; every empower shows ⚡ when it fires.
7. Fatigue, Down and the fight's end are each labelled.
8. At 4×, no more than one floating number per side per pulse.
9. Every action works from the keyboard.

---

## Open Questions

1. No player journey map, art bible or accessibility tier yet. Author the journey map from
   `.claude/docs/templates/player-journey.md`; the art bible sets the ink-wash look.
2. Does a fight history exist for replays, and how many fights does it keep?
3. How much does an ambush reveal of the foe's loadout (Combat Open Question 4)?
4. Boss phases and companion targets are not modelled by the engine yet.
5. Should a text version exist in the Debug Terminal first (the combat GDDs ask for it)?
6. The combat engine must be ported to GDScript before this screen can be built.
