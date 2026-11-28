# To do (as of 2026-11-28)

The working list. Tick items off or delete them; newest decisions go in `production/session-logs/decision-log.md`.
Sources: `production/session-state/active.md`, `design/gdd/systems-index.md`,
`production/qa/evidence/world-depth-stage11/stage11-balance-and-review.md`,
`production/gate-checks/gate-systems-design-2026-11-15.md`.

## 1. Waiting on you (decisions only you can make)

- [ ] **Tree Effects engine choices**: review `design/dao-do/tree-effects-engine.md`, the rule details settled when a
      keystone's text left them open (e.g. Glass Meridians +40 on top of 41.6; "N % less" read as `dmg_more`). Both
      fight engines run on them now; 4 out-of-fight tree Effects remain Pending non-combat hosts.
- [ ] **Đạo Đồ content review**: your one review of the whole filled tree (7,289 Dao marks on live v5 export;
      decisions log `design/dao-do/content-decisions.md` #1–34). Playable in `DaoDoScreen` and debug terminal (`tree`,
      `tree targets`, `tree map`).
- [x] **Đạo Đồ node icons**: committed (`10f7509f`). Polish deferred to release (user 2026-11-20), listed in art
      bible 7.9 "Deferred to release": brightness, crafts vs fortune, F8 fight icons, per-icon pass, engine wiring.
- [x] **Map / art style**: decided 2026-11-22 — carved hardwood & brass illustrated windows + painted far paper
      campaign map + painted near diorama terrain, installed across the Godot UI.
- [ ] **Small tree calls**:
  - Metal holds 6 of the 200 breakthrough notables (Wood 49): even it out by land, or leave it?
  - 38 scoped tree lines apply to every hit because their engine key reads without hit context (`33 × linh_luc_on_hit_pct`,
    `5 × leech_linh_luc_pct`): keep them that broad?
  - 2 remaining non-Darkness unscoped modifier lines in `depth_gap.py` (`stack_effect_pct [bleed]` on `red-debt-rite`,
    `pierce_pct [sword]` on `lone-branch-sword`): wait or rescope?
- [ ] **Power Rankings calibration (Track 1 in progress)**: Stage 11 (`408fc35a`) raised `k_max = 256` (`23/27` Nguyên
      Anh inside ladder). Track 1 is currently refreshing `combat_reference_fighters.json` to post-Đạo-Đồ typicals,
      recalibrating `combat_rankings.json`, precomputing `assets/data/cast_ratings.json`, and syncing
      `design/gdd/power-rankings.md`.

## 2. GDD sync

- [x] **Đạo Đồ GDD (`design/gdd/dao-do.md`)**: rewrote Known gaps for the shipped v5 map loader (`dao_do_map.json`,
      `DaoDoTree.load_map()`, 55 tree Effects, optimized NPC allocator, `DaoDoScreen` UI), synced stale tool/file
      references, and added frozen v5 map measurements alongside `AC-KMD-60` (2026-11-28).
- [x] **Reconciled ACs**: Realms `AC-CG-19`, `AC-CG-25`, `AC-CG-68` synced to the live Đạo Đồ breakthrough curve &
      `cultivation_rules.gd` pill floor; Character Stats `AC-CS-56` & rule 14 reconciled against the v5 tree's 158
      filled (131 post-#34 small/notable + 1 keystone `Sun That Never Sets`) `lifespan_pct` lines (2026-11-28).
- [x] **Realms Open Question 23 (`design/gdd/canh-gioi.md`)**: recorded both the v5 loader baseline (`77 / 73 / 37 / 20 %`)
      and Stage 11B re-validation under land roll + Traits v2 (`70% / 72% / 28% / 19%`, confirming no Realms retune
      needed; 2026-11-28).
- [x] **`design/gdd/game-concept.md`**: synced from the old one-province LLM loop to the shipped fixed-continent
      non-LLM authored engine, Đạo Đồ v5, and Godot HUD & illustrated UI while preserving all 5 pillars (2026-11-28).
- [x] **`design/gdd/systems-index.md`**: synced system statuses, Overview, Progress Tracker and Next Steps to the
      shipped 2026-11-28 codebase (2026-11-28).
- [x] **Darkness (`am`) combat GDD sync (`design/gdd/effects.md`, `design/gdd/combat-damage-types.md`)**: synced for
      `Shadow Veil` + `Shadow Erosion` stacks (2026-11-28).
- [ ] **Power Rankings GDD (`design/gdd/power-rankings.md`)**: in progress via Track 1 alongside post-Đạo-Đồ
      `combat_reference_fighters.json` & offline `cast_ratings.json` precompute.

## 3. Still to design (your plan: all GDDs first, then one review pass)

- [x] `#46` NPC Relationships (Approved 2026-11-21 & implemented).
- [x] `#12` Codex & Karmic Carryover (Approved 2026-11-21 & implemented, `5804f812`).
- [x] World Generation authoring: shipped in World Depth Stage 8 (`bfc48f75`, `world_history.json`: 50 active / 11
      fallen sects, 56 depth owners, 1,909 authored people, 965 events, 2,054 ties, 21 beasts).
- [ ] `#34` Localization & Hán-Việt Glossary (not started).
- [ ] GDDs for built systems that still have none (`/reverse-document`: Foundation `#1–5`, `#11`, `#16`, `#18–20`,
      `#24`, `#32–33`, `#35–36`).
- [ ] Then the one review pass over all GDDs (`/consistency-check` + `/review-all-gdds`), then the Systems Design gate.

## 4. Build items (shipped & remaining)

- [x] **Game UI in Godot (`#37`)**: map-centric HUD, carved hardwood & brass illustrated windows (`CharacterWindow`
      with C3 talent grades & live `Interact` tab, `SectWindow`, `ProvinceWindow`, `InventoryWindow`, `QuestsWindow`,
      `RankingsWindow`, `RelationshipsWindow`, `NewsWindow`, `CodexWindow`, `WikiWindow`, `GameMenu`), full-screen
      `DaoDoScreen`, `AbodeScreen`, `TribulationScreen`, `SuccessionScreen`, and B2 fight screen.
- [x] **Fixed continent (`#25` Travel & Map, `#27` World Gen, `#48` Provinces)**: `world_continent.json` (705
      provinces, painted far/near map), `world_history.json` (56 depth owners, 1,909 people, 965 events, 2,054 ties, 21
      beasts), province land-roll births & F20/F21 sect admission (`c75beac2`).
- [x] **Sects (`#26`), Regional Economy & Trade (`#43`), Trade Goods (`#45`), Cave Abode (`#47`), NPC Relationships (`#46`)**.
- [x] **Event Engine (`#23`, `facc5a41`), Template Quests (`#31`, `facc5a41`), NPC Interaction & Dialogue (`#30`,
      `86fac3cd`), NPC Traits v2 (`#42`, `c5e2ecec`)**.
- [x] **Heavenly Tribulation (`#22`, `5804f812`, default-on playthrough toggle in `GameMenu`) & Codex / Karmic Carryover
      (`#12`, `5804f812`)**.
- [x] **Sect war attrition retune** (Track 2 W1-A, 2026-11-28): `sects_members.json` + `sect_politics.gd` weariness
      knobs; 3-seed 50y probe (`production/qa/evidence/sect-war-retune/probe-50y-seeds.txt`) passed all 6 acceptance
      bands.
- [x] **Combat & Formations quick wins** (Track 2 W1-B/W1-C, 2026-11-28): real-fight-only `save_fight_meters`
      writeback, `diagram_always` (`mf-carried-array` / `Diagrams`), and `curse_reflect` (`A Fair Copy`, `thien_xu`,
      `t34_curse_reflect_exact`).
- [x] **Darkness (`am`) element stacks** (2026-11-28): `Shadow Veil` buff + `Shadow Erosion` debuff (`equalfit --dark`
      `+0.000`), `The Banner Is Raised` + all 9 `attack_pct [am]` lines wired, `t35_darkness_erosion_exact` parity green.
- [ ] **Power Rankings offline precompute (Track 1, in progress)**: post-Đạo-Đồ `combat_reference_fighters.json`,
      `combat_rankings.json` recalibration, `assets/data/cast_ratings.json` precompute, and `design/gdd/power-rankings.md`
      sync.
- [ ] **Unbuilt systems**: The Way (`#39`), Audio (`#38`), Localization (`#34`), spirit insects (`#19`), and the
      side-tree tab for techniques & items.
- [ ] **Deferred combat records**: 31 multi-fighter / ally-counting records remain parked in
      `design/world/depth/builds/postponed-2026-11-26.json` until multi-fighter combat is built.
- [ ] **Art backlog (parallel art session — do not touch here)**: 21 Spirit Beast portraits + 80 v2 trait medallions
      (currently rendered cleanly with `PlaceholderArt`).
- [ ] **Non-blocking Stage 11 minor advisories**: legacy `"still"` tag on `the-pivot-does-not-turn`; Stage 2 minor
      follow-ups (Băng Tâm island seat levels & 12 unmoved minor seats).

## 5. Housekeeping

- [ ] `production/session-state/active.md` needs rotation into `production/session-logs/`
      (`bash .claude/scripts/rotate-session-state.sh`) once the active tracks settle.
