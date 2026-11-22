## Architecture Review Report
Date: 2026-11-22
Mode: full
Workflow: standard
Engine: Godot 4.7 (4.7.1 installed)
GDDs Reviewed: 34 (31 carry a `## Summary`; `game-concept`, `systems-index` and the cross-review record are not systems)
ADRs Reviewed: 6

Reviewed-Content-Hash: docs/architecture/adr-0001-combat-engine-in-godot.md dc7b5d5862dde96805da495cd19227ab500258b3
Reviewed-Content-Hash: docs/architecture/adr-0002-random-streams.md 61b3238ab4b82de62a35fb2d98f29ed011cf4c57
Reviewed-Content-Hash: docs/architecture/adr-0003-fight-based-power-ratings.md 7a0aabd234c0245800eba65fdaa779fec559be3a
Reviewed-Content-Hash: docs/architecture/adr-0004-dao-do-from-the-drawn-map.md 2f616ecb6e3cfdbff33d7a3a1d3b8ac80840d291
Reviewed-Content-Hash: docs/architecture/adr-0005-tooltip-layer.md efcc44c055045f6181ad7d57557a01f5e21e7d24
Reviewed-Content-Hash: docs/architecture/adr-0006-game-session-facade.md 8c515a8911a34eaff03c8871d8e5e71e6f74c81f
Reviewed-Content-Hash: design/gdd/alchemy.md 6e56a89a572e94440e69b618a5f25ac818413d03
Reviewed-Content-Hash: design/gdd/canh-gioi.md c8ae4f305d1c42ce24da5873f1133394a0652175
Reviewed-Content-Hash: design/gdd/cave-abode.md 7b3e2e805560d761f4a301c6f31bf57c9a641de8
Reviewed-Content-Hash: design/gdd/character-stats.md 78520f32564589b434d0eeac4815ad53684ea63d
Reviewed-Content-Hash: design/gdd/codex-karmic-carryover.md a6d28669e52eb507e5e6f7b703197e93a3841135
Reviewed-Content-Hash: design/gdd/combat-damage-types.md 3e4670e5c0a7e0798c088ee6099d6ed2e7db3662
Reviewed-Content-Hash: design/gdd/combat-defence.md e24c4a755c34f485ea14030b8d8b4f8ca4118dca
Reviewed-Content-Hash: design/gdd/combat.md f01e96cdb6a8dcd47fd0bbb11cad19969fa53b0b
Reviewed-Content-Hash: design/gdd/cong-phap.md f4c00b6a38f6319130123a35e1568338d5ba67c0
Reviewed-Content-Hash: design/gdd/dao-do.md f29e5b7165d5b1e586a0366eac91c04b9ab6d3fc
Reviewed-Content-Hash: design/gdd/dao.md ddfef8f83dca19037763d96f3dc31fbf6125c54c
Reviewed-Content-Hash: design/gdd/effects.md ec0fbe863c6c543522c6351448b591b3dd45da32
Reviewed-Content-Hash: design/gdd/event-engine.md 9fc6ce45397c170ccddece7e7596ee3ecffcccb2
Reviewed-Content-Hash: design/gdd/formations.md ce010b074bbcfd5d90ace66a2db8c34ad268857f
Reviewed-Content-Hash: design/gdd/game-concept.md b497f52abf8ff59cc59b08839a90ad20b0a36572
Reviewed-Content-Hash: design/gdd/gdd-cross-review-2026-11-05.md 38354eddb0586d34b024e781910689c9b02d4e5f
Reviewed-Content-Hash: design/gdd/item-database.md ec553379489fd19353c568d7143e918b3d6cc355
Reviewed-Content-Hash: design/gdd/linh-can.md dd9cc8515c196464f9b3236d9a8874a52a1739f0
Reviewed-Content-Hash: design/gdd/living-world-tick.md c089bdf5555a47febdc1ef9a5c2fd3d77142e41c
Reviewed-Content-Hash: design/gdd/modifiers.md 97129c6bb39712985feae09e865c38f64922899a
Reviewed-Content-Hash: design/gdd/npc-interaction-dialogue.md d67329faf21a8547935f184a8d252850ee07c6a7
Reviewed-Content-Hash: design/gdd/npc-relationships.md cc3c5918ac1a8fc3b244669ac731784317136df4
Reviewed-Content-Hash: design/gdd/npc-traits-catalogue.md 79f8f8866ebe45611a09ea81b77ec62aa8172f83
Reviewed-Content-Hash: design/gdd/npc-traits.md b1a212dafb0bdfc31d28a2c413e39ce0e9c0e26e
Reviewed-Content-Hash: design/gdd/power-rankings.md 08dc9aab576fb493c3710b4a8ce8a3a00183cbfc
Reviewed-Content-Hash: design/gdd/quests.md f2c453ea4c62167305380cd019e96ebd6899d9d7
Reviewed-Content-Hash: design/gdd/regional-economy-trade.md e3ff33f97ac76bd0b352eeeb7d2328f3a3e97ed4
Reviewed-Content-Hash: design/gdd/sects.md 444e2d7275b81756dc72a2147cef0ea64a23202d
Reviewed-Content-Hash: design/gdd/spirit-herbs.md 7d7d2f703e290887fa7890fb3b530d36b86af4d5
Reviewed-Content-Hash: design/gdd/systems-index.md 133e4b62e696c8ec05029a28759b523b35801d0d
Reviewed-Content-Hash: design/gdd/thien-kiep.md f8054d52a9fc6f79e63217677119dfe3b79425f0
Reviewed-Content-Hash: design/gdd/trade-goods.md 4114de5549c4bfffef3fe811c59a175c6cac4188
Reviewed-Content-Hash: design/gdd/travel-map.md fd379bb34ca47285ac7e1f5d7c683773b67ef040
Reviewed-Content-Hash: design/gdd/world-generation.md 3c3cbabf8a09015e4292ccd69782c20da1d4538f
Reviewed-Content-Hash: docs/architecture/tr-registry.yaml b6c1a64839b1dec59002904c0a712c20225e4a6e
Reviewed-Content-Hash: docs/architecture/architecture.md 9b4516758e4a346e9858bc9c35d3c20a3324c6ea
Reviewed-Content-Hash: docs/engine-reference/godot/VERSION.md ba0a8a691aebdaf86d4b75284ecc602ff6a7951f
Reviewed-Content-Hash: docs/engine-reference/godot/breaking-changes.md c01fad937ab444eeb872a94549355eeb4f4ee216
Reviewed-Content-Hash: docs/engine-reference/godot/current-best-practices.md f8813a42751708fc57825b3c48db1af3c215ec8f
Reviewed-Content-Hash: docs/engine-reference/godot/deprecated-apis.md 6a1353983e1db0d7bc0cc41a568b039495b5413c
Reviewed-Content-Hash: docs/engine-reference/godot/modules/animation.md ee51f50a46f8c63b771f62fe438947d4d84c59e3
Reviewed-Content-Hash: docs/engine-reference/godot/modules/audio.md c72af247505908a04f84a1dd3e765939efe700bd
Reviewed-Content-Hash: docs/engine-reference/godot/modules/input.md 3406b1b813858898696e510ea0accfcc7df98af8
Reviewed-Content-Hash: docs/engine-reference/godot/modules/navigation.md 7ae18ffbd2c3230cb19d610373225bfba187a472
Reviewed-Content-Hash: docs/engine-reference/godot/modules/networking.md 6606880462a2241014f77feb9610c5611e659ec6
Reviewed-Content-Hash: docs/engine-reference/godot/modules/physics.md 3b6ac8947f3f3e8c9ac9e6e0ff6cac06fdb8d805
Reviewed-Content-Hash: docs/engine-reference/godot/modules/rendering.md 37e29e3eb4e0ca5aba4e8f3600800d0d183890f9
Reviewed-Content-Hash: docs/engine-reference/godot/modules/ui.md 30ad166ab8c4e92c15aa37ed3464483b92b7845b
Reviewed-Content-Hash: project.yaml 35992098a53656393da9da3fe84a0953e8b3d57b
Reviewed-Content-Hash: .claude/docs/technical-preferences.md 113febf6fcab40846c1d5cc6412bca7080b3b4b9
Reviewed-Content-Hash: docs/consistency-failures.md 0c945ea7970d63d1b02399a552cafce1690128bd
Reviewed-Content-Hash: .claude/skills/architecture-review/SKILL.md 8c1dd9d6f27f396e3b769b939de27d780d7c486a
Reviewed-Content-Hash: .claude/skills/architecture-review/references/1-load.md 9a65759ebdbb2cb1f9744775bfed18cb25e76347
Reviewed-Content-Hash: .claude/skills/architecture-review/references/2-extract-requirements.md d08ea0b0e9ab9760b0d8bfe0cd9115f0bc40f8e2
Reviewed-Content-Hash: .claude/skills/architecture-review/references/3-traceability.md bb7b6b65c5e5e5b8869fa692413aa831615dede7
Reviewed-Content-Hash: .claude/skills/architecture-review/references/4-conflicts.md 0d30f8173b23248a32523a365b606dd1ce9642ab
Reviewed-Content-Hash: .claude/skills/architecture-review/references/5-engine.md 9a0de3ccca214e473e9433450462e0c6e57f9de2
Reviewed-Content-Hash: .claude/skills/architecture-review/references/6-document-coverage.md dcce78482ec2ce60048989b6f9d1f797dd0a9a0e
Reviewed-Content-Hash: .claude/skills/architecture-review/references/7-report.md a43e17378df952791974dab5f10d7a98c16156fe
Reviewed-Content-Hash: .claude/skills/architecture-review/references/8-write.md bf6d8946fc7b9e19eda7f65503a5c8f593a0d2b1
Reviewed-Content-Hash: .claude/skills/architecture-review/references/9-handoff.md ade419da14b200ae3bc8d00ed3f2c04707a6275b
Reviewed-Content-Hash: .claude/skills/architecture-review/references/lens-engine.md d7770f2737d185cf51a338aaf550fa01b773fb07

---

### Scope limit (what this run did not do)
- The 15 GDDs in `architecture.md`'s baseline were **not re-read**; their requirements are the 21 provisional rows
  already there (the baseline says 20 and lists 21).
- The other 19 GDDs were **scanned only for performance, persistence and determinism lines**, not read in full.
  The matrix is at system-contract level, so the gap count is a lower bound.
- No `production/epics/` exists: the RTM story and test chain (Phase 3b) did not run.
- Phase 5's specialist look was taken inline from `references/lens-engine.md`; no agent was spawned.
- No prior report existed (`RECEIPT: NONE`), so no freshness comparison was possible.

### Traceability Summary
Total requirements: 30
✅ Covered (Accepted ADR): 9
🟡 Covered by a Proposed ADR: 2 (not a pass state)
⚠️ Partial: 5
❌ Gaps: 12
➖ Parked (LLM, deprecated in the registry): 2

Full matrix: `docs/architecture/requirements-traceability.md`.

### Coverage Gaps (no ADR exists)
- ❌ TR-save-002, TR-save-003 (Foundation): save versions and what a save stores → `/architecture-decision save format and migration policy, including the profile record` · Engine risk LOW
- ❌ TR-realms-001, TR-stats-001 (Core): realm ladder contract and the stats provider interface → `/architecture-decision stat sheet and provider interface` · LOW
- ❌ TR-world-001, TR-world-002, TR-world-003, TR-world-004, TR-items-001: world scale, tick budget, season order, callee budgets → `/architecture-decision world scale and simulation budget` · MEDIUM (threading is not in the engine reference)
- ❌ TR-travel-001, TR-dao-001: authored map and the 94 Ways → `/architecture-decision fixed-world map pipeline` · LOW
- ❌ TR-codex-001: the Codex lives on a profile outside any save → fold into the save-format ADR · LOW
- ⚠️ Partial: TR-sim-002, TR-save-001, TR-modifiers-001, TR-meridian-001, TR-ui-001

### Cross-ADR Conflicts
No hard conflict (data ownership, interface, state, pattern).

- **ADR-0005 and ADR-0006 depend on each other.** Both are Proposed. ADR-0005's Depends On row names "Required ADR #2"
  (this is ADR-0006) in prose, so `adr-dep-graph.sh` shows no cycle; it is a real cycle. Both say they can be Accepted
  together; ADR-0005's row should name ADR-0006.
- **ADR-0003 is internally inconsistent.** Decision 13 (amended 2026-11-22) moves rating batches to worker processes,
  but its Engine Compatibility row (Knowledge Risk, Verification Required) and its Fallback section still describe
  `WorkerThreadPool` as the mechanism.
- ADR-0001 Migration Plan step 5 is superseded by ADR-0003 and carries an inline amendment; not a conflict.

### ADR Dependency Order
`adr-dep-graph.sh` output: 6 ADRs; no `NO_DEPS_SECTION`, no `UNFILLED_DEPS`, no `CYCLE`, no `BLOCKED_BY_CYCLE`.
Edges: 0002→0001; 0003→0001, 0002; 0004→0001, 0002; 0006→0002, 0003, 0005.

Recommended order:
- Foundation: ADR-0001 (Accepted), ADR-0005 (Proposed; its dependency on ADR-0006 is in prose only)
- Depends on Foundation: ADR-0002, ADR-0003, ADR-0004 (all Accepted)
- Last: ADR-0006 (Proposed)

Unresolved dependency: ADR-0006 depends on ADR-0005, which is still Proposed, and the reverse holds in prose. It cannot be
safely implemented until ADR-0005 is Accepted. ADR-0005's conditions for Accepted: a screen-reader check of an open
tooltip and a release-export run of the demo steps.

### GDD Revision Flags
None. No GDD assumption contradicts verified engine behaviour or an Accepted ADR.

### Engine Compatibility Issues
Engine: Godot 4.7 (4.7.1 installed). ADRs with an Engine Compatibility section: 6 / 6.
- Versions: consistent (4.7 / 4.7.1). No stale version reference.
- Deprecated APIs: none cited in any ADR.
- `.duplicate(true)`: ADR-0006 relies on it for `GameQuery` copies. `deprecated-apis.md` lists `duplicate()` →
  `duplicate_deep()` (4.5) only for nested resources; behaviour on Dictionaries is **NOT SOURCEABLE** from the reference.
  ADR-0006 plans a mutation test for it (and `architecture.md` carries the same open item).
- NOT SOURCEABLE items named in the ADRs: threading and `WorkerThreadPool` (ADR-0003, 0006), `OS.create_process` and `-s`
  in a release export (ADR-0003), `Viewport.gui_get_hovered_control`, hover versus keyboard focus, `_input` ordering and
  AccessKit announcements (ADR-0005). Most were measured; ADR-0005's screen-reader and release-export checks are not yet
  done, which is why it stays Proposed.

#### Engine Specialist Findings
- No node-type, autoload or per-frame anti-patterns: gameplay is `RefCounted`, the tooltip layer is a `CanvasLayer`.
- The open engine risks are the unverified release-export behaviours above; none is a defect in a decision as written.
- ADR-0003's stale `WorkerThreadPool` rows (see Conflicts) should be reconciled with decision 13.

### Architecture Document Coverage
`docs/architecture/architecture.md` exists and is **stale** (version 1, 2026-11-13):
- Layer map omits #44 Power Rankings, #45 Trade Goods, #46 NPC Relationships and #47 Cave Abode.
- "GDDs Covered (15)" of 34; "ADRs Referenced" and the ADR Audit list only ADR-0001 (ADRs 0002 to 0006 are absent).
- Principle 1 and Module Ownership say "no thread"; ADR-0003 and ADR-0006 add background jobs and worker processes.
- #12 Codex is placed under Presentation although it keeps a profile outside any save.
- #29 LLM Game Master is still listed although parked 2026-11-15.
- Required ADRs #2 (now ADR-0006, Proposed) and #3 (ADR-0002, Accepted) are not marked as written (ADR-0006 is still only Proposed).
- `docs/architecture/control-manifest.md` does not exist.
No orphaned architecture (a system with no GDD) was found beyond the parked LLM Game Master.

---

### Verdict: FAIL

Foundation and Core requirements have no ADR (save format and versions, realm ladder contract, stats provider
interface), and two requirements rest on Proposed ADRs.

### Blocking Issues (must resolve before PASS)
1. No save-format and migration ADR, while `SAVE_VERSION` 4 is pending (TR-save-001 to 003, TR-codex-001).
2. No stat-sheet and provider-interface ADR (TR-modifiers-001, TR-stats-001, TR-realms-001).
3. No world-scale and simulation-budget ADR: the tick (AC-LW-26), callee budgets, 5,000 cultivators and 200,000 items
   have no decided budget (TR-world-001 to 004, TR-items-001).
4. ADR-0005 and ADR-0006 are Proposed; accept them together once ADR-0005's conditions are met.

### Required ADRs
1. Save format and migration policy, including the profile record outside the save.
2. Stat sheet and provider interface.
3. World scale and simulation budget, including season order S1 to S10.
4. Accept ADR-0005 and ADR-0006 together (`/architecture-decision accept ADR-NNNN`).
5. Fixed-world map pipeline.
6. Data loading and validation (`GameData`); then Game UI framework and combat presentation.

### Housekeeping owed (not done here)
- Update `architecture.md` (ADR Audit, layer map, GDDs covered, threading principle, Required ADRs).
- Reconcile ADR-0003's Engine Compatibility row with decision 13.
- Name ADR-0006 in ADR-0005's Depends On row.
- Registry notes: TR-combat-003 and TR-quests-001 were reworded; TR-llm-001 and TR-llm-002 are deprecated (parked 2026-11-15).
