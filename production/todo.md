# To do (as of 2026-11-20)

The working list. Tick items off or delete them; newest decisions go in `production/session-logs/decision-log.md`.
Sources: `production/session-state/active.md`, `design/gdd/systems-index.md`,
`production/gate-checks/gate-systems-design-2026-11-15.md`.

## 1. Waiting on you (decisions only you can make)

- [ ] **Tree Effects engine choices**: review `design/dao-do/tree-effects-engine.md`, the rule details I settled
      when a keystone's text left them open (e.g. Glass Meridians +40 on top of 41.6; "N % less" read as `dmg_more`).
      Both fight engines run on them now.
- [ ] **Đạo Đồ content review**: your one review of the whole filled tree (7,276 Dao marks; decisions log
      `design/dao-do/content-decisions.md` #1-34). Playable in the debug terminal: `tree`, `tree targets`, `tree map`.
- [x] **Đạo Đồ node icons**: committed (10f7509f). Polish deferred to release (user 2026-11-20), listed in art
      bible 7.9 "Deferred to release": brightness, crafts vs fortune, F8 fight icons, per-icon pass, engine wiring.
- [ ] **Map / art style**: pick one of the map style demos (pixel, parchment, ink-wash) for the art bible.
- [ ] **Small tree calls**:
  - Metal holds 6 of the 200 breakthrough notables (Wood 49): even it out by land, or leave it?
  - 257 scoped tree lines match nothing in fights yet (over time, Light, formation, Burn): wait for that content or
    re-tag?
  - 38 tree lines have no scope and apply to every hit: keep them that broad?
- [ ] **Power Rankings calibration**: median NPC win share against the typical fighter is 0.00 at Qi Refining and
      1.00 from Foundation up. Set a target, or accept it?

## 2. GDD sync (in `design/gdd/*`, the parallel session's files: say who does it)

- [ ] Đạo Đồ GDD: rewrite Known gaps for the v5 map in the game (loader plan step 14).
- [ ] Acceptance criteria the new behaviour contradicts: Realms AC-19, AC-25, AC-68 (numbers now come from the
      breakthrough curve); Character Stats AC-56 (lifespan bound against 158 tree lifespan lines); AC-KMD-60 (strict
      drawing thresholds against the frozen map).
- [ ] Realms: the gate calibration (its Open Question 23), now measured: with the edge 77 / 73 / 37 / 20 %
      (`production/qa/evidence/dao-do-v5-loader/06-balance-breakthrough-spread.txt`).
- [ ] `game-concept.md`: still describes the LLM game and the old one-province MVP (gate-check concern 2); unreviewed.
- [ ] Systems index: rows and Progress Tracker are stale (e.g. Combat "built only as the old duel").

## 3. Still to design (your plan: all GDDs first, then one review pass)

- [ ] #46 NPC Relationships (not started).
- [ ] #12 Codex & Karmic Carryover (not started).
- [ ] #34 Localization & Hán-Việt Glossary (not started).
- [ ] GDDs for built systems that have none: character, crafting, cultivation, events, items, session, world
      (`/reverse-document`).
- [ ] World Generation authoring: the fixed cast (60-100 people), the chronicle (150-250 landmarks, 300-500 annals),
      the sect start-state table (its Open Questions 1-3).
- [ ] Then the one review pass over all GDDs (`/review-all-gdds`), then the Systems Design gate.

## 4. Built in design, not yet in the game (the big build items)

- [ ] **Game UI in Godot** (#37): nothing player-facing yet beyond the debug terminal. Groundwork: fight-screen UX
      spec, replay viewer mock-up, painted icons.
- [ ] **Fixed continent** (#25 Travel & Map, #27 World Gen): the game still runs the old place graph and random
      generator.
- [ ] Sects redesign (#26, built thin), Regional Economy & Trade (#43), Trade Goods (#45).
- [ ] Event Engine chain/story layer (#23), Quests (#31), NPC Interaction verbs (#30), NPC Traits (#42).
- [ ] Heavenly Tribulation (#22), The Way (#39).
- [ ] **Sect war attrition** (own session; found 2026-11-24): great sects are at war in a third to four fifths of all
      seasons, and Sects F9's per-season losses (lowest realm first) kill ~700-1,100 of the biggest sect's members per
      50 years, about its whole Luyện Khí pool every 25-50 years. Same in the old code and with Formula H. Levers: how
      often wars start and last, and F9's loss share. Evidence and probe: `production/qa/evidence/formula-h/`.

## 5. Housekeeping

- [ ] A hung NPC cohort probe (Godot PID 28540) is left over; `taskkill /PID 28540 /T /F` if it is still there.
- [ ] `active.md` is 577 lines: rotate the narrative into `production/session-logs/`
      (`bash .claude/scripts/rotate-session-state.sh`).
