# HUD Design (`design/ux/hud.md`) — Review Log

Reviews run headless (`claude -p`, Sonnet, read-only); this log was written afterwards from their reports. Only the
last entry has a receipt: the earlier reviews read texts that were revised the same day and are not kept, so no hash
can be given for them.

## Review — 2026-11-22 — Verdict: NOT ASSESSED (`/ux-review`)
Review mode: `/ux-review` checklist 3B · Workflow: standard
Specialists: none (checklist)
Blocking items: 0 | Recommended: 6
Summary: Sound spec with no blocking gaps, but accessibility could not be assessed because no tier was committed
(`design/accessibility-requirements.md` absent). Six advisory fixes applied the same day.
Prior verdict resolved: First review
Findings:
- [RECOMMENDED] Layout Zones: no safe-zone margin
- [RECOMMENDED] Information Architecture / Element Specs / Hierarchy: Must Show count disagreed (8 vs 11)
- [RECOMMENDED] Visual Budget: no element-count cap
- [RECOMMENDED] Platform / Accessibility: Tab had two roles
- [RECOMMENDED] Acceptance Criteria: no performance criterion
- [RECOMMENDED] Acceptance Criteria: the last criterion bundled three checks
Reviewed-Content-Hash: not stamped (the reviewed text was revised the same day and is not kept)

## Review — 2026-11-22 — Verdict: APPROVED (`/ux-review`, round 2)
Review mode: `/ux-review` checklist 3B · Workflow: standard
Specialists: none (checklist)
Blocking items: 0 | Recommended: 5
Summary: After the accessibility tier (Standard) was committed, the checklist approved the spec; four advisory edits
applied the same day, the fifth (Z2 fit at 1280×720) left to the first build screenshot.
Prior verdict resolved: Yes
Findings:
- [RECOMMENDED] Accessibility / Open Questions / header: stale "no tier committed" lines
- [RECOMMENDED] Platform Adaptation: rebinding not stated
- [RECOMMENDED] Tuning Knobs: colourblind mode and brightness missing
- [RECOMMENDED] Platform / Tuning Knobs: no End turn hold alternative
- [RECOMMENDED] Visual Budget: Z2 budget at 1280×720 unchecked
Reviewed-Content-Hash: not stamped (the reviewed text was revised the same day and is not kept)

## Review — 2026-11-22 — Verdict: NEEDS REVISION (`/design-review --review full`, round 1)
Review mode: full · Workflow: standard
Scope signal: XL
Specialists: ux-designer, ui-programmer, qa-lead, game-designer, godot-specialist, creative-director (senior)
Blocking items: 5 | Recommended: 12
Summary: The core holds (map as the board, windows, seasons as turns, nested tooltips); five gaps would force
programmers to guess in the most-used part of the screen. Revised the same day in four batches with user decisions
(default focus carries over and breaks on a risk change; ratings apply one season late, `power-rankings.md` rule 13).
Prior verdict resolved: First full review
Findings:
- [BLOCKING] Platform / The turn: End turn input unsafe (Enter on focused buttons, key repeat, no confirm for keyboard)
- [BLOCKING] Platform / Accessibility: scaling shrinks text below the floor at 720p; 200 % does not fit
- [BLOCKING] Element 14 / default focus: no preview contract; carry-over hides new risk
- [BLOCKING] Philosophy rule 4: no tooltip stack, lock, close or keyboard rules
- [BLOCKING] Accessibility: no keyboard or screen-reader path to the map
- [RECOMMENDED] Counts, criteria tags and coverage, Z6/Z7 overlap, death in the flow, multi-season rules, Esc and
  focus, pointer-only verbs, data contracts, reduced motion, smaller points, header status
Reviewed-Content-Hash: not stamped (the reviewed text was revised the same day and is not kept)

## Review — 2026-11-22 — Verdict: NEEDS REVISION (`/design-review --review full`, round 2)
Review mode: full · Workflow: standard
Scope signal: L
Specialists: ux-designer, accessibility-specialist, ui-programmer, qa-lead, systems-designer, game-designer,
godot-specialist, creative-director (senior)
Blocking items: 23 | Recommended: 14
Summary: Not major: every blocker had a design answer, but four were partial and scaling was wrong (the UI scale cap
omitted the automatic factor, so 200 % was unreachable). Four user decisions (Q1 cap 150 %; Q2 look but don't change
during a blocking event; Q3 closed door stops only for what needs an answer; Q4 second-press confirm) and batch 5 the
same day; the long tail carried into the build stories.
Prior verdict resolved: Partly (map path resolved; four partial)
Findings:
- [BLOCKING] Platform: UI scale cap formula wrong; Z7 vs `panel_share_max`; chrome 15 % unreachable at 720p; no
  minimum window size
- [BLOCKING] The turn: Enter on the focused End turn button bypasses the setting; hold and confirm unspecified
- [BLOCKING] The turn: risk band, baseline and preview contract undefined; "dropdown" is a comparison view
- [BLOCKING] Tooltips: unlocked tooltip cannot be entered; no keyboard focus model; no screen-reader fallback
- [BLOCKING] Accessibility: Z6 focus rule, focus during resolve, Z7 trap vs F6, live regions
- [BLOCKING] Places panel: map-mode data with no text form
- [BLOCKING] Acceptance Criteria: about 25 rules untested; contradictory criteria; thin screenshot evidence
- [BLOCKING] Design decision: free actions while an event blocks End turn
- [RECOMMENDED] Cross-document inconsistencies, click-lock precedence, window-size loose ends, hotkeys during text
  input, map pan keys, resolve model, alerts/history/outliner model, tooltip details, autopilot loop, free-vs-focus
  list, screen-reader details, reduced-motion list, smaller consistency items
Reviewed-Content-Hash: not stamped (the reviewed text was revised the same day and is not kept)

## Review — 2026-11-22 — Verdict: NEEDS REVISION (`/design-review --review full`, round 3)
Review mode: full · Workflow: standard
Scope signal: L
Specialists: ux-designer, ui-programmer, accessibility-specialist, game-designer, qa-lead, godot-specialist,
creative-director (senior)
Blocking items: 10 | Recommended: about 30, plus engine notes
Summary: Not major and clearly closer to approval: the remaining problems are the spec contradicting itself, each a
one- or two-sentence fix needing no new user decision; creative-director expects APPROVED after the 10-item minimum
fix set. The user chose to apply the fix set and the recommended items, then a full re-review.
Prior verdict resolved: Partly (Places resolved; blockers 1–4 partial)
Findings:
- [BLOCKING] Tooltips: the 0.3 s grace closes locked tooltips too, so a lock does nothing
- [BLOCKING] Platform: Q (and V) are lost when single-letter hotkeys are turned off
- [BLOCKING] The turn / Platform: Stop can be discarded mid-resolve; no complete Esc order
- [BLOCKING] The turn: Enter scope ignores rows, sliders and lists that consume Enter
- [BLOCKING] The turn / Accessibility: focus after a resolve contradicts the summary taking focus
- [BLOCKING] Platform: the automatic factor uses height only (fails on tall windows); AC "106 % (±1)" admits 107 %
- [BLOCKING] Layout / Visual Budget: Z7 has no height cap; `centre_width_max` untested
- [BLOCKING] Feedback / Acceptance Criteria: banner before summary contradicts "summary the frame after resolving"
- [BLOCKING] The turn: preview "no random numbers" vs trial fights; "…" lets End turn skip Check focus; baseline not
  keyed or saved; preview may leak hidden information
- [BLOCKING] Feedback: events on full screens open "on that screen", but full screens hide Z7
- [RECOMMENDED] Lock boundary table, stop lists, baseline edge cases, autopilot, save-scum, tooltip roots, blocking
  card and hotkeys, full-screen focus, Z7 in the F6 ring, refusals, gamepad, colour-only cues, hit targets, engine
  notes (scaling, tooltip words, Esc router, dual focus, IME), acceptance-criteria fixes, document consistency
Reviewed-Content-Hash: design/ux/hud.md cd99c4b45b26291908e162007034151870158852
Reviewed-Content-Hash: design/accessibility-requirements.md 3d3e6bc45cf93556c8163632380246a42eb361ff
Reviewed-Content-Hash: design/registry/entities.yaml 9c8ccd8d9f8519113bd176457bf89bd281314189
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f

## Review — 2026-11-22 — Verdict: NEEDS REVISION (`/design-review --review full`, round 4)
Review mode: full · Workflow: standard
Scope signal: L
Specialists: ux-designer, ui-programmer, accessibility-specialist, game-designer, qa-lead, godot-specialist, creative-director (senior)
Blocking items: 9 mechanical + 4 user decisions | Recommended: about 40 (most deferred to build stories)
Summary: Not major. Batch 6 resolved 4 of the 10, left 5 partial and introduced 4 contradictions (tooltip Esc vs the ranked list, the unreachable Esc AC, the preview seed vs determinism, the baseline fallback). Nine sentence-level fixes plus four small user decisions (Esc model, baseline, preview refuse/queue, summary vs End turn) are expected to bring APPROVED at re-review 5.
Prior verdict resolved: Partly (4 of 10 resolved; 5 partial; 1 holds for the setting)
Findings:
- [BLOCKING] Platform / Tooltips: Esc list lacks a modal rank, succession, gamepad B; L264-265 contradicts it
- [BLOCKING] Acceptance Criteria: the five-press Esc AC is unreachable
- [BLOCKING] Platform / The turn / Places: Enter worded three ways
- [BLOCKING] The turn: preview seed includes a revision counter, defeating determinism
- [BLOCKING] The turn: baseline fallback, first set, succession reset, known-only band
- [BLOCKING] The turn: gate has a hole during the banner and the queue; cooldown start; focus across the queue
- [BLOCKING] Layout Zones / Acceptance Criteria: Z7 height cap omits Z3 and Z4
- [BLOCKING] The turn: "Continue" suppression can skip a blocking event
- [BLOCKING] Platform / Visual Budget / Acceptance Criteria: Q/V in text, ±1 frame rule, "complete list" claim, dismiss wording
- [DECISION] Esc fixed rank vs focus-owning layer; baseline follow-down; refuse vs queue during recompute; summary vs End turn
- [RECOMMENDED] can-kill measure, reminders, allow-list locks, save-scum, tooltip lock details, comparison form at 40 % width, announcements, injected clock, integer scale maths, split bundled ACs
Reviewed-Content-Hash: design/ux/hud.md a1b886ae83a0eaee960bb2fe0126168ec6eeba9e
Reviewed-Content-Hash: design/accessibility-requirements.md cfbdc397dbd8cbe39d692a8adfcacc76a22dd251
Reviewed-Content-Hash: design/registry/entities.yaml 9c8ccd8d9f8519113bd176457bf89bd281314189
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f

## Review — 2026-11-22 — Verdict: NEEDS REVISION (`/design-review --review lean`, round 5)
Review mode: lean · Workflow: standard
Specialists: none (lean)
Blocking items: 2 | Recommended: 2 (cosmetic)
Summary: Diff check of batch 7: all 9 fixes and the 4 user decisions (Q1 Esc on the focused window first; Q2 ending a season sets the baseline; Q3 refuse while the preview computes; Q4 the summary refuses End turn) landed. Two sentences still contradicted a decision; the reviewer gave exact replacements, applied the same day.
Prior verdict resolved: Yes (all 9 fixes landed)
Findings:
- [BLOCKING] The turn (Cost): "End turn waits for it" contradicts Q3 (refused, not queued)
- [BLOCKING] Acceptance Criteria (Esc cases): tooltip-over-summary order contradicts Q1 (the summary holds focus)
- [RECOMMENDED] The turn: "two key presses" holds only for single press (three with press, then confirm)
- [RECOMMENDED] Information Architecture / Feedback: "dismissible" / "dismissed" wording for snooze
Reviewed-Content-Hash: design/ux/hud.md f408b1d808ee4fdbf421352cb3c4c7b6938cf448
Reviewed-Content-Hash: design/accessibility-requirements.md cfbdc397dbd8cbe39d692a8adfcacc76a22dd251
Reviewed-Content-Hash: design/registry/entities.yaml 9c8ccd8d9f8519113bd176457bf89bd281314189
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f

## Review — 2026-11-22 — Verdict: APPROVED (`/design-review --review lean`, round 6)
Review mode: lean · Workflow: standard
Specialists: none (lean)
Blocking items: 0 | Recommended: 0
Summary: Both round-5 sentence fixes landed (End turn refused, not queued, while the preview computes; the summary closes first on Esc and takes its tooltip chain with it) and the cosmetic notes were applied; no new contradiction. Status set to Approved. The receipt below stamps the approved text (only the status line changed after the review read it).
Prior verdict resolved: Yes
Findings:
- none
Reviewed-Content-Hash: design/ux/hud.md fa2bccbb275f3800193d1f47cc8a9bc9f98e2a3b
Reviewed-Content-Hash: design/registry/entities.yaml 9c8ccd8d9f8519113bd176457bf89bd281314189
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f

## Review — 2026-11-22 — Verdict: NEEDS REVISION (`/design-review --review lean`, round 7: the map bubbles added after approval)
Review mode: lean · Workflow: standard
Specialists: none (lean)
Blocking items: 6 | Recommended: 10
Summary: The bubble addition (elements 30–32, user request) is structurally sound and the counts are consistent, but it clashed with approved rules: a bubble set the focus around the comparison, Enter on a focused bubble would end the turn, Tab had two meanings on the map, free versus season actions were undefined, remote counts broke known-information-only, and the blocking-event lock contradicted itself. All fixes sentence-level; the user approved applying all 16 the same day.
Prior verdict resolved: n/a (new addition)
Findings:
- [BLOCKING] Map bubbles / The turn: bubble click sets the focus around the comparison
- [BLOCKING] Places panel / The turn: Enter rule not updated for focused bubbles
- [BLOCKING] Places panel / Map bubbles: Tab on the map has two meanings; no gamepad route
- [BLOCKING] Map bubbles: free versus season actions per kind undefined
- [BLOCKING] Map bubbles: "people there now" and quest counts at remote places break known-information-only
- [BLOCKING] Map bubbles / Acceptance Criteria: blocking-event lock contradicts itself
- [RECOMMENDED] bubble tooltips; inert during multi-season commands; bubbles under zones; clutter determinism; Places panel actions; element 17/30 tidy; reduced motion and legend; clue-area anchor; hover priority; missing criteria
Reviewed-Content-Hash: design/ux/hud.md de03997a2bbee9cbfd2907e0c3825de2aa05a781
Reviewed-Content-Hash: design/registry/entities.yaml 9c8ccd8d9f8519113bd176457bf89bd281314189
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f

## Review — 2026-11-22 — Verdict: NEEDS REVISION (`/design-review --review lean`, round 8: map bubbles re-check)
Review mode: lean · Workflow: standard
Specialists: none (lean)
Blocking items: 2 | Recommended: 0
Summary: All 16 round-7 fixes landed. Two new sentence-level contradictions, with exact replacements given and applied the same day: the Places panel travel criterion lacked the comparison confirm, and a season-action bubble during a blocking event would queue its comparison behind the event card.
Prior verdict resolved: Yes (16 of 16)
Findings:
- [BLOCKING] Acceptance Criteria (Places travel): "Travel here, End turn" skips the comparison confirm
- [BLOCKING] Map bubbles / Layout Zones (Z7): the comparison queues behind a blocking event card
Reviewed-Content-Hash: design/ux/hud.md 106663bec97467321189ee6614c78dc73921ce46
Reviewed-Content-Hash: design/registry/entities.yaml 9c8ccd8d9f8519113bd176457bf89bd281314189
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f

## Review — 2026-11-22 — Verdict: APPROVED (`/design-review --review lean`, round 9: map bubbles)
Review mode: lean · Workflow: standard
Specialists: none (lean)
Blocking items: 0 | Recommended: 0
Summary: Both round-8 fixes landed (the Places travel criterion confirms in the comparison; a season-action bubble during a blocking event minimises the card and opens the comparison, restoring the card on close), cross-checked against rule 2, Esc, F6 and the window keys. The map bubbles addition is approved. The receipt stamps the approved text (only the status line changed after the review read it).
Prior verdict resolved: Yes
Findings:
- none
Reviewed-Content-Hash: design/ux/hud.md 300b53a883d742035e31ab83a0803df9e98be16e
Reviewed-Content-Hash: design/registry/entities.yaml 9c8ccd8d9f8519113bd176457bf89bd281314189
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f

## Review — 2026-11-22 — Verdict: NEEDS REVISION (`/design-review --review lean`, round 10: person-window changes)
Review mode: lean · Workflow: standard · Run headless (`claude -p`, Sonnet), read-only
Specialists: none (lean)
Blocking items: 2 | Recommended: 5
Summary: Scoped to the post-approval changes for the person window (people bubbles and outliner pins at current places,
the Focus preview's share-of-season line, the number-format sentence, gamepad X on a person). Two stale sentences
contradicted them; five gaps (missing criteria, preview seed, Travel with a shortened season, people in transit and dead
pins, X details). All applied the same day with the user's defaults.
Prior verdict resolved: Yes (round 9)
Findings:
- [BLOCKING] Acceptance Criteria (Map bubbles): a remote bubble's count read last-seen data, contradicting the true people count
- [BLOCKING] person.md Entry points: the outliner pin still said "where they were last seen"
- [RECOMMENDED] criteria for the share line, the number formatter, gamepad X and pins; the preview seed and the selector stop include the season share; Travel at 75 % arrives a season later; transit and dead pins; X on a dead person and inside a tooltip
Reviewed-Content-Hash: design/ux/hud.md 0f3c080c74796f2d3793ee2f1e6d7efed6838e6a

## Review — 2026-11-22 — Verdict: APPROVED (`/design-review --review lean`, round 11: person-window changes)
Review mode: lean · Workflow: standard · Run headless (`claude -p`, Sonnet), read-only
Specialists: none (lean)
Blocking items: 0 | Recommended: 5
Summary: All round-10 fixes confirmed. Five small recommendations applied the same day: the share-of-season criterion
also covers Travel never refused, the lifespan count, the seed and the selector stop; the X criterion covers the tooltip
case; a dead person is not counted in a people bubble; the status line names the person-window changes; bubbles measure
reach from a full season.
Prior verdict resolved: Yes (2 of 2 blocking, 5 of 5 recommended)
Findings:
- none blocking
Reviewed-Content-Hash: design/ux/hud.md 9e0d12361c8936123f722b5db435dd76cbf72f56
Reviewed-Content-Hash: design/registry/entities.yaml acf70ca4dfedbd7b57e9b1a67c96cc254154dcad
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
