# Accessibility Requirements

> Authoring guidance: .claude/docs/templates/guidance/accessibility-requirements-guide.md (load per-section as you author — do not read entirely).

> **Status**: Committed (tier committed by the user 2026-11-22; all sections approved)
> **Author**: user + ux-designer
> **Last Updated**: 2026-11-22
> **Accessibility Tier Target**: Standard (with the additions listed under This Project's Commitment)
> **Platform(s)**: PC (Steam / Epic); keyboard and mouse first, gamepad partial
> **External Standards Targeted**:
> - WCAG 2.1 Level AA (text contrast and resizing, for UI text)
> - AbleGamers CVAA Guidelines: Partial (the game has no communication features)
> - Xbox Accessibility Guidelines (XAG): No (PC only)
> - PlayStation Accessibility (Sony Guidelines): No (PC only)
> - Apple / Google Accessibility Guidelines: N/A
> **Accessibility Consultant**: None engaged
> **Linked Documents**: `design/gdd/systems-index.md`, `design/ux/hud.md`, `design/ux/fight-screen.md`, `design/ux/interaction-patterns.md` (not yet created)
> **Template**: Accessibility Requirements

> **Why this document exists**: Per-screen accessibility annotations belong in
> UX specs. This document captures the project-wide accessibility commitments,
> the feature matrix across all systems, the test plan, and the audit history.
> It is created once during Technical Setup by the UX designer with
> `/ux-design accessibility` — you pick the tier, against the criteria
> accessibility-specialist sets and audits against — then updated as features
> are added and audits are completed. If a feature conflicts with a commitment
> made here, this document wins — change the feature, not the commitment,
> unless the producer approves a formal revision.
>
> **When to update**: After each `/gate-check` pass, after any accessibility
> audit, and whenever a new game system is added to `systems-index.md`.

---

## Accessibility Tier Definition

Committed by the user 2026-11-22: **Standard, plus reduced motion and menu and panel screen-reader support.**

### Tier Definitions

| Tier | Core Commitment | Typical Effort |
|------|----------------|----------------|
| **Basic** | Critical player-facing text is readable at standard resolution. No feature requires color discrimination alone. Volume controls exist for music, SFX, and voice independently. The game is completable without photosensitivity risk. | Low — primarily design constraints |
| **Standard** | All of Basic, plus: full input remapping on all platforms, subtitle support with speaker identification, adjustable text size, at least one colorblind mode, and no timed input that cannot be extended or toggled. | Medium — requires dedicated implementation work |
| **Comprehensive** | All of Standard, plus: screen reader support for menus, mono audio option, difficulty assist modes, HUD element repositioning, reduced motion mode, and visual indicators for all gameplay-critical audio. | High — requires platform API integration and significant UI architecture |
| **Exemplary** | All of Comprehensive, plus: full subtitle customization (font, size, color, background, position), high contrast mode, cognitive load assist tools, tactile/haptic alternatives for all audio-only cues, and external third-party accessibility audit. | Very High — requires dedicated accessibility budget and specialist consultation |

### This Project's Commitment

**Target Tier**: Standard

**Rationale**: This is a turn-based cultivation world sim on PC, played on a map with no timed input: seasons are turns
and fights are auto-resolved and watched, so the motor barriers common in action games are mostly absent. The barriers
it does have are visual and cognitive: dense numbers, nested tooltips, Vietnamese diacritics, 330+ painted icons and
five colour-coded elements, where Fire (red) beside Wood (green), and green buffs beside red debuffs, are the classic
red-green clash that affects about 6 % of men. Standard covers exactly these: adjustable text size, a colourblind mode
and full remapping. The game is PC only, so no console certification rule (XAG) forces a higher tier, and a small
team cannot fund Comprehensive's difficulty assists and HUD repositioning. Dropping to Basic would lose the colourblind
mode and remapping, which would shut out red-green colourblind players from reading the element system the builds rest
on.

**Features explicitly in scope (beyond tier baseline)**:
- **Reduced motion mode** (Comprehensive): already committed by `design/ux/hud.md` (Accessibility) and cheap, since
  the game's motion is UI animation only.
- **Screen reader support for menus and panels** (Comprehensive): Godot 4.5+ Control nodes work with AccessKit
  (`docs/engine-reference/godot/modules/ui.md`); every icon button gets an accessible name, and alerts and toasts are
  announced (`design/ux/hud.md`).
- **Tooltip timing settings**: hover delay, lock mode (any of timer, middle-click and click) and close grace (0.3–2 s), because nested tooltips are the
  main way the game explains itself (`design/ux/hud.md`).

**Features explicitly out of scope**:
- **Screen reader for the map, the Đạo Đồ graph and fight playback**: they are custom-drawn, so AccessKit cannot read
  them without major work.
- **Difficulty assist modes**: the weak start and the difficulty targets (player edge 0.70 / 0.70 / 0.30 / 0.20) are
  design decisions, not settings.
- **HUD element repositioning**: the CK3-style layout is fixed; UI scale and the compact layout cover screen size.
- **Subtitles with speaker identification**: not applicable, because the game has no voice.

Each also appears in Known Intentional Limitations.

---

## Visual Accessibility

Approved by the user 2026-11-22 (text sizes and the colourblind approach decided the same day).

| Feature | Target Tier | Scope | Status | Implementation Notes |
|---------|-------------|-------|--------|---------------------|
| Minimum text size — HUD and panels | Standard | Map screen, every panel and full screen | Not Started | **16 px** at 1080p and 100 % UI scale. The template's 20–24 px assume TV viewing at 3 m; this is a PC game read at about 60 cm, where CK3 runs about 14–16 px. |
| Minimum text size — tooltip detail | Standard | Secondary lines inside tooltips and Breakdowns | Not Started | **14 px**. A tooltip's first lines (name, the key fact) use the 16 px floor. |
| Non-text contrast — icons, bars, focus ring | Standard | All UI | Not Started | At least 3:1 against what is behind them (WCAG 2.1 SC 1.4.11); added 2026-11-22 from the HUD full design review. |
| Text contrast — UI text on backgrounds | Standard | All UI text | Not Started | At least 4.5:1 for body text, 3:1 for large text (18 px+, or 14 px bold), WCAG AA. Text over the painted map always sits on a panel or plate, never straight on the art. Test with a contrast checker on final colour values. |
| Colorblind mode — Protanopia + Deuteranopia | Standard | Element hues, damage-type colours, buff and debuff halos, map-mode fills | Not Started | **One red-green mode** covering both, a swap palette for the colours in the art bible §7.4–7.5. Shape and word backups stay on in every mode (audit below). Verify with Coblis on screenshots. |
| Colorblind mode — Tritanopia | — | — | Out of scope | No palette; shapes and words carry it. See Known Intentional Limitations. |
| Color-as-only-indicator audit | Basic | All UI and gameplay | Not Started | Table below. |
| UI scaling | Standard | All UI elements | Not Started | **75–150 %**, default 100 % (user decision 2026-11-22), capped per window so the layout area never drops below 1280×720 (`design/ux/hud.md` Scaling rule: 150 % at 1080p and above, 100 % at 1280×720). A smaller window never shrinks text. **The text floors hold at 100 % and above**; below 100 % the player has chosen smaller text. The 200 % of WCAG 2.1 SC 1.4.4 is not met: see Known Intentional Limitations. Every screen is tested at both ends. |
| High contrast mode | Comprehensive | — | Out of scope | Not in the Standard commitment. |
| Brightness control | Basic | Map and art | Not Started | One slider. The game is 2D UI and painted art, so there is no gamma calibration screen. |
| Screen flash / strobe warning | Basic | Tribulation, fight VFX, the breakthrough glow | Not Started | A photosensitivity notice at first launch. No effect flashes more than 3 times a second above the luminance threshold (Harding FPA). |
| Motion/animation reduction mode | Standard (raised above the template) | All UI transitions and HUD animations | Not Started | As in `design/ux/hud.md` Accessibility: slides, glows, fades and fills become instant. |
| Subtitles (on/off, speaker identification, style, SFX captions) | — | — | N/A | The game has no voice. On-screen text is the whole channel and follows the text rules above. |

### Color-as-Only-Indicator Audit

| Location | Color Signal | What It Communicates | Non-Color Backup | Status |
|----------|-------------|---------------------|-----------------|--------|
| Element stacks and element tags | 8 element hues (art bible §7.5) | Which element | Each element has its own icon shape (flame, drop, leaf and vine, ingot, three-layer mountain, six-point crystal, bolt, three curls); the element's name in the tooltip | Not Started |
| Damage numbers and Breakdown parts | 7 damage-type colours (§7.5) | Damage type | A type icon on each number; the type word in the Breakdown | Not Started |
| Buff and debuff halos | Green #5BD66B / red #E5384F (§7.4) | Buff or debuff | Halo shape (soft round / jagged or dashed), ↑/↓ pip, separate BUFFS and DEBUFFS rows, the word in the tooltip | Not Started |
| Item rarity | A colour per rarity | Quality tier | The rarity word (item-database.md, AC-ID-82) | Not Started |
| Đạo Đồ nodes and links | Colour per group; link colours | Group or land | Node frame shape (notable ruyi, keystone dragon); the group name in the tooltip | Not Started |
| Map modes (sect territory, qi by element, danger, prices) | Hue fills | Who holds a place; element amounts; risk; price level | A legend with patterns (hatching for danger, element icons on qi); numbers on hover | Not Started |
| Lifespan readout | Amber | Little lifespan left | Hourglass icon and the numbers (`design/ux/hud.md`) | Not Started |
| Attitude bands and tie strength | Colour per band | How someone feels about the player | The band word and the tie glyph (npc-relationships.md) | Not Started |

---

## Motor Accessibility

Approved by the user 2026-11-22. The game is turn-based with no timed input, so most motor rows are N/A.

| Feature | Target Tier | Scope | Status | Implementation Notes |
|---------|-------------|-------|--------|---------------------|
| Full input remapping | Standard | Every key, mouse button and gamepad button | Not Started | Every default binding (`design/ux/hud.md` Platform Adaptation) is rebindable; a conflict shows a warning; bindings persist to the player profile. |
| Input method switching | Standard | PC | Not Started | Switch between keyboard and mouse and gamepad at any moment; prompts update to the active method. |
| One-hand mode | Standard | Whole game | Not Started | **Every action can be done with the mouse alone**; keys are shortcuts only. The keyboard alone also reaches everything through the HUD focus order (F6 between zones, Tab within). |
| Hold-to-press alternatives | Standard | Two hold inputs | Not Started | (1) Gamepad End turn can be a held Start (`end_turn_hold`, 0.3–1.5 s, gamepad only, optional); the gamepad default is "press, then confirm" (a second press, no timeout; `design/ux/hud.md` The turn). (2) Tooltips lock by a timer, a middle click or a click; the pointer can cross into a tooltip within a close grace the player sets (0.3–2 s), and a locked tooltip never closes on a timer. No other hold input exists. |
| Drag alternatives | Standard | Slot order editor, formation diagram editor, any later drag | Not Started | Every drag has a click path: move-up and move-down buttons in the slot order editor; click an art, then click a node, in the diagram editor. |
| Rapid input alternatives | — | — | N/A | No rapid or repeated input exists. |
| Input timing adjustments | — | — | N/A | No required timed input exists: seasons are turns and fights are watched, not played. The only timed input, the optional gamepad hold, has an untimed alternative. Tooltip timing is adjustable (`design/ux/hud.md` Tuning Knobs). |
| Aim assist; movement assists; platforming assists | — | — | N/A | No aiming, real-time movement or platforming. |
| HUD element repositioning | Comprehensive | — | Out of scope | See Known Intentional Limitations. |

---

## Cognitive Accessibility

Approved by the user 2026-11-22.

| Feature | Target Tier | Scope | Status | Implementation Notes |
|---------|-------------|-------|--------|---------------------|
| Difficulty options | Standard | — | **Fixed by design** | No easier mode (user decision 2026-11-22). The difficulty targets (player edge 0.70 / 0.70 / 0.30 / 0.20) and the weak start are the design, not settings; harder world settings unlock after a first Kết Đan (game-concept.md). Justification recorded in Known Intentional Limitations. |
| Pause anywhere | Basic | All gameplay states | Met by design | Nothing happens until the player presses End turn; fight replays have their own pause (`design/ux/fight-screen.md`). |
| Tutorial persistence | Standard | All hints and tutorials | Not Started | Every hint and tutorial is kept in the in-game wiki and can be reread. |
| Quest / objective clarity | Standard | Journal and quests | Not Started | The journal is one key (J) or one click away; each quest shows its current stage's full text; a **Show on map** button marks the stage's place. |
| Visual indicators for audio-only information | Standard | All SFX | Met by design | No information is carried by audio alone (Auditory audit below). |
| Reading time for UI | Standard | Auto-dismissing elements | Not Started | Auto-dismissing elements carry no choice: toasts (`toast_seconds`, 3 s, player-adjustable 2–6 s), refusals (2 s) and the breakthrough banner (2.5 s). Toast text is also listed in the season summary's "this season" list; a refusal reappears on hovering the control again; the breakthrough is listed in the summary. Every element that needs an answer (event cards, quest offers) stays until answered. |
| Cognitive load documentation | Comprehensive | — | Out of scope | Partly covered by the Per-Feature Accessibility Matrix. |
| Navigation assists | Standard | World navigation | Not Started | Route preview on hover (seasons, danger, encounter chance, fee); teleport arrays for a fee. No free fast travel: travel time is part of the game (travel-map.md). |

---

## Auditory Accessibility

Approved by the user 2026-11-22. The game has no voice, and no information is carried by sound alone.

| Feature | Target Tier | Scope | Status | Implementation Notes |
|---------|-------------|-------|--------|---------------------|
| Subtitles for all spoken dialogue | Basic | — | N/A | No voice. |
| Closed captions for gameplay-critical SFX | Comprehensive | — | N/A | Every meaningful sound already has a visual (audit below). |
| Mono audio option | Comprehensive | Global audio output | Not in the commitment | Cheap; may be added later. |
| Independent volume controls | Basic | Music / SFX / UI / Ambience buses | Not Started | Four sliders (no voice bus), 0–100 %, default 80 %, in settings and the game menu, saved to the player profile. |
| Visual representations for directional audio | — | — | N/A | 2D, no off-screen threats. |
| Hearing aid compatibility | Standard | All audio cues | Met by design | No cue carries information by sound alone, so high-frequency loss hides nothing. |

### Gameplay-Critical SFX Audit

| Sound Effect | What It Communicates | Visual Backup | Caption Required | Status |
|-------------|---------------------|--------------|-----------------|--------|
| Event arrival chime | An event needs an answer | The event card, its alert and the blocked End turn | No | Not Started |
| Breakthrough sound | A stage or realm breakthrough | The breakthrough banner and the season summary | No | Not Started |
| Hit and ward sounds in a fight | Damage taken or stopped | Floating numbers, bars and the fight log | No | Not Started |
| End turn resolved | The season is over | The season summary opens | No | Not Started |
| Refusal buzz | An action can't be done | The refusal note beside the control | No | Not Started |

---

## Platform Accessibility API Integration

Approved by the user 2026-11-22. PC only.

| Platform | API / Standard | Features Planned | Status | Notes |
|----------|---------------|-----------------|--------|-------|
| Steam (PC) | Steam Input | Controller remapping at system level | Not Started | In-game remapping is still required for keyboard and mouse (Motor Accessibility). |
| PC (Screen Reader) | NVDA / JAWS / Windows Narrator via AccessKit | Names and roles on every menu, panel and HUD control; alerts and toasts announced as live regions | Not Started | Godot 4.5+ Control nodes work with AccessKit, and 4.7 has `Control.accessibility_live` typed `AccessibilityServer.AccessibilityLiveMode` (`docs/engine-reference/godot/modules/ui.md`, `breaking-changes.md`). Custom-drawn views (map, Đạo Đồ, fight playback) are not covered (Known Intentional Limitations). |
| Xbox (GDK) | XAG | — | N/A | PC only. |
| PlayStation 5 | Sony Accessibility Guidelines | — | N/A | PC only. |
| iOS / Android | VoiceOver / TalkBack | — | N/A | No mobile release. |

---

## Per-Feature Accessibility Matrix

Approved by the user 2026-11-22. One row per player-facing system (GDDs in `design/gdd/`). No Game UI exists yet, so
"Planned" means the concern has an answer in this document or a UX spec, not that it is built.

| System | Visual Concerns | Motor Concerns | Cognitive Concerns | Auditory Concerns | Addressed | Notes |
|--------|----------------|---------------|-------------------|------------------|-----------|-------|
| Travel & Map (travel-map.md) | Map-mode hue fills; painted map behind text | None (turn-based) | Route choice reads several numbers (seasons, danger, encounter chance, fee) | None | Planned | Legend with patterns; text on plates; route preview tooltip; the map is not screen-readable, the place panel is |
| Combat, Defence, Damage Types (fight screen) | 7 damage-type colours; dense bars; floating numbers; flashes | None (watched, not played); replay controls | Many states at once (arts, wards, stacks, statuses) | Hit sounds | Planned | Type icons and words; flash limit; the fight log is the readable record (`design/ux/fight-screen.md`) |
| Đạo Đồ and Dao (dao-do.md, dao.md) | Node colour per group; link colours; about 7,000 nodes | Path tool clicking | Planning across many nodes and modifiers | None | Partial | Frame shapes; path tool totals; the graph is not screen-readable, a node list is |
| Character Stats, Spiritual Roots, Realms, Techniques | Element colours on the root block; bars | None | Breakdowns with many lines; curves and caps | None | Planned | Element icons and names; nested tooltips; 14 px detail floor |
| Item Database (inventory, equip) | Rarity colours | Equip drag | Comparing many values | None | Planned | Rarity word (AC-ID-82); click to equip |
| Alchemy | Element values; quality colours | Herb assignment drag | Recipe element values, fuel, chance lines | Brew sounds | Planned | Click alternative; every number has a Breakdown |
| Spirit Herbs & Fields | Fit words; Frozen and Locked marks | Plant and transplant clicks | Ages, maturity, growth lines per plot | None | Planned | Marks have icons and words |
| Cave Abode | Work states | None | Slots, upkeep, fading, grade costs | None | Planned | States are words |
| Formations (diagram editor) | Node polarity colours; links | Placing arts into nodes (drag) | Nodes, links, reservation, fuel | None | Planned | Click an art, then a node; polarity shown by +/− and a word |
| Event Engine (event cards) | Illustration behind text | None | 2–4 options with checks, odds and costs | Event chime | Planned | The card waits for an answer; the chime has a visual |
| Quests | Deadline warnings | None | Stages, deadlines, rewards | None | Planned | Journal one press away; Show on map |
| NPC Interaction, Relationships, Traits | Attitude band colours; tie glyphs | Right-click verbs | Many ties and favours to track | None | Planned | Band words and glyphs; the person card has a verbs button as well as right-click |
| Sects | Sect colours on the map | None | Ranks, duties, politics | None | Not Started | The sect screen spec is still to write |
| Regional Economy & Trade Goods | Price change colours | None | Prices, tariffs, last-seen data | None | Planned | Up/down arrows and numbers; the price Breakdown |
| Power Rankings | Highlighted player row | None | Ratings and stale states | None | Planned | A row marker and the word "You" |
| Heavenly Tribulation | Lightning VFX flashes | None | Waves, bosses, setup warnings | Thunder sounds | Planned | Flash limit; the wave header text |
| Codex, Karmic Carryover, Succession | Remembered marks | None | The heir choice reads many records | None | Planned | Marks are words; wiki search |
| World Generation (new game) | Origin list | None | 47 origins | None | Planned | A grouped list with words; screen-readable |
| Living World Tick (news, season summary) | None | None | Many news lines | None | Planned | At most 3 lines a season; the digest is grouped by person |

---

## Accessibility Test Plan

Approved by the user 2026-11-22. Runs once the Game UI exists; evidence goes to `production/qa/evidence/`.

| Feature | Test Method | Test Cases | Pass Criteria | Responsible | Status |
|---------|------------|------------|--------------|-------------|--------|
| Text contrast ratios | Automated — contrast analyser on UI screenshots | Every text and background pair on the map screen, panels and full screens | Body text ≥ 4.5:1; large text ≥ 3:1 | ux-designer | Not Started |
| Text size | Manual — measure at 1080p and 100 % scale | HUD, panels, tooltips | HUD and panel text ≥ 16 px; tooltip detail ≥ 14 px | ux-designer | Not Started |
| Red-green colourblind mode | Manual — Coblis on screenshots with the mode on | Map modes, fight screen, Đạo Đồ, inventory, buff and debuff rows | No information lost; every colour signal in the audit readable by its backup | ux-designer | Not Started |
| Input remapping | Manual — rebind every default input, play one full season | Every binding in `design/ux/hud.md` Platform Adaptation | Every action works; conflicts warn; bindings persist across a restart | qa-tester | Not Started |
| Mouse-only and keyboard-only play | Manual — play one season with each alone | Map screen, panels, one full screen | Every action reachable | qa-tester | Not Started |
| Click alternatives to drags | Manual | Slot order editor, formation diagram editor, equip | Every drag action doable by clicks | qa-tester | Not Started |
| Reduced motion | Manual — mode on, play one season | Every animation listed in `design/ux/hud.md` | None animates; changes are instant | ux-designer | Not Started |
| UI scale | Manual — at 75 % and at the window's cap (150 % at 1080p) | Every screen | Nothing clipped or overlapping | qa-tester | Not Started |
| Screen reader (menus and panels) | Manual — NVDA on | Game menu, settings, character sheet, person card, inventory, journal, event card | Every control announced with name and role; a logical order; alerts and toasts announced | ux-designer | Not Started |
| Flash limit | Manual — frame-step the VFX | Tribulation lightning, the breakthrough glow, art fire flashes | ≤ 3 flashes per second above the luminance threshold | technical-artist | Not Started |

---

## Known Intentional Limitations

Approved by the user 2026-11-22.

| Feature | Tier Required | Why Not Included | Risk / Impact | Mitigation |
|---------|--------------|-----------------|--------------|------------|
| Screen reader for the map, the Đạo Đồ graph and fight playback | Exemplary | Custom-drawn views; AccessKit covers Control nodes only | Blind and low-vision players cannot read these views directly | The same information is in readable panels: the place panel and route list, the Đạo Đồ node list, the fight log |
| Difficulty options and assist modes | Standard (options) / Comprehensive (assists) | The difficulty targets and the weak start are the design (user decision 2026-11-22); harder world settings only | Players who find the game too hard have no easier mode | The Advisor's warnings, the wiki, nested Breakdowns explaining every number, and saves |
| HUD element repositioning | Comprehensive | A fixed CK3-style layout (`design/ux/hud.md`) | Players with reduced peripheral vision may miss corner elements | UI scale 75–150 %; the compact layout; alerts are announced |
| Tritanopia palette | Standard needs one mode, met by the red-green mode | One colourblind mode chosen; blue-yellow affects about 0.001 % | Water and Thunder and similar pairs may be harder to tell apart | Element icon shapes and names; type icons and words |
| High contrast mode | Comprehensive | Not in the Standard commitment | Low-vision players get the default contrast only | A 4.5:1 minimum; text always on plates; UI scale |
| UI scale above 150 % (WCAG 2.1 SC 1.4.4's 200 %) | Standard (adjustable text size is met) | The layout area must stay at least 1280×720, which caps the scale at 150 % (user decision 2026-11-22) | Players who need text larger than 150 % of the floor | Text floors of 16 px and 14 px at 100 %; the automatic factor grows text on larger windows; screen-reader support for menus and panels |
| Mono audio | Comprehensive | Not in the commitment yet (cheap; may be added) | Players with single-sided deafness | No information is carried by sound alone |
| Portrait descriptions (person window) | Comprehensive | Portraits are composed or authored art with no text description (`design/ux/person.md`, added 2026-11-22) | Screen-reader users get a person's name but not their appearance | Everything else about the person is text: realm, sect, traits, stats, ties |

---

## Audit History

| Date | Auditor | Type | Scope | Findings Summary | Status |
|------|---------|------|-------|-----------------|--------|
| 2026-11-22 | `/ux-review` (headless Sonnet) | Internal review | `design/ux/hud.md` | Accessibility NOT ASSESSED: no tier committed. The spec's own measures (focus order, contrast, non-colour cues, reduced motion, tooltip timing, AccessKit names) were judged sound | Resolved by this document (tier committed 2026-11-22); re-review pending |

---

## External Resources

| Resource | URL | Relevance |
|----------|-----|-----------|
| WCAG 2.1 (Web Content Accessibility Guidelines) | https://www.w3.org/TR/WCAG21/ | Contrast ratios, text resizing |
| Game Accessibility Guidelines | https://gameaccessibilityguidelines.com | Game-specific checklist by category and cost |
| AbleGamers Player Panel | https://ablegamers.org/player-panel/ | User testing with disabled players, if engaged later |
| Colour Blindness Simulator (Coblis) | https://www.color-blindness.com/coblis-color-blindness-simulator/ | Checking the red-green mode on screenshots |
| Accessible Games Database | https://accessible.games | Examples of accessible design decisions |

---

## Open Questions

| Question | Owner | Deadline | Resolution |
|----------|-------|----------|-----------|
| Wind (#B5F5E0) and Ice (#C8F8FF) hues are near-identical for every player | art-director, user | Art bible §4 | Unresolved; icon shapes keep them apart meanwhile |
| The red-green swap palette's actual colours | art-director | Art bible §4 | Unresolved |
| Can AccessKit read nested tooltips built from `RichTextLabel` meta links? | ui-programmer | During the greybox build | Unresolved; NOT SOURCEABLE from `docs/engine-reference/godot/` |
| How do screen readers pronounce Vietnamese terms (NVDA with a Vietnamese voice vs English)? | ux-designer | Before the screen-reader test | Unresolved |
| Add mono audio later, or not at all? | user | Before Alpha | Unresolved |
