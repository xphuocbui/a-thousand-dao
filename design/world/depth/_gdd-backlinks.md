# GDD amendments 2026-11-25: back-links, registry entries and index rows owed (collected for the final pass)

## Done (amended in place)
- linh-can.md (R1) - by the orchestrator
- provinces.md (rules 2a, 3a; OQ 11-12; AC-PV-28/29) - by the orchestrator
- item-database.md (rules 20f, 20g, 22; Formulas J1-J3; AC-ID-98..109; OQ 26-31)
- sects.md (rules 3a, 19b, 20b-20d; F20-F22; AC-SM-59..68; OQ 12-20)
- world-generation.md (rules 3a, 5, 5a, 6, 6a, 8a, 16, 16a; Formulas B, E, F, G; AC-WG-40..55; OQ 8-14)
- combat.md (rules 1, 10, 12, 19, 25, 26; Formulas I, L; AC-CB-92..103; OQ 29-33) and effects.md (rules 1, 2, 5, 6, 8, 9,
  13, 16, 17-19; duel statuses; AC-EF-81..87; OQ 12-15)

## Back-links owed
- Item DB -> World Generation (rule 6: sets sized to the gear list; signature items start with holders; export refuses a
  wrong-length gear list); Effects System (full-set Effects; rule 20g limits); Modifier System (`set:<id>` lines);
  Combat (reads set lines when compiling the loadout); NPC Builds (re-equip step, once it has a GDD).
- Sects -> World Generation; Cultivation Techniques (lineages, 180 proposals); Living World Tick (Formulas D; rule 5:
  a member's child needs the outer test); NPC Relationships; Đạo Đồ (lineage tree_route); Travel & Map (founder's
  array as ΔD2p in Formula B); Character Stats; NPC Build Generation.
- Linh Căn -> Provinces (done in provinces.md), World Generation (birthplace), Living World Tick (birthplace of births),
  Travel & Map (tile qi source), Sects (admission reads the root).
- Provinces -> Linh Căn (done), World Generation (seat moves).

- World Gen -> Sects (admission, membership); Travel & Map (place density adds seat_array_density); Event Engine (array
  hooks); Realms (world floor vs N_cast 4,947); NPC Traits (v2 kinds).

- Combat/Effects -> modifiers.md (new tags; L4/W4/B4 sources still list "ground tags"); combat-defence.md (body payloads
  to you; Rooted = evade 0); event-engine.md, thien-kiep.md, travel-map.md (they send place tags); formations.md
  (diagram_laid read only: OWNED BY THE FORMATIONS SESSION, skip unless the user says); cong-phap.md (time-of-day and
  place-gate rulings).

## Fixes owed in depth content
- Seven moved minor sects' pages say "no founder's array": the ruling (group 2) gives every moved sect one; update
  their pages' section 2 and the export sizes them (World Gen Formula G).

## Questions for the user (collect, ask at the end)
- World Gen OQ 8: the authored cast needs a world of >= 4,947 cultivators (it fills the realm distribution's top: NA
  27/27...), against the 3,000 floor.
- World Gen OQ 9: 264 dated new events (not ~150); kind -> landmark/annal mapping needs an OK.
- Item DB OQ 26: does the set growth goal (sets complete at Trúc Cơ) bind the player too? (the player has 5 base slots
  + 2 extra at Luyện Khí; the 1 + realm index count is the cast/NPC gear list only).

- Combat OQ 30: existing place tags in fights (own_abode, tribulation, vein) vs the no-environment ruling: keep as
  exceptions or remove?

## Registry entries introduced
- Linh Căn: land_k 1.0, land_factor_min 0.25, land_factor_max 3, land_purity_shift 6, variant_parts_tilt 0.5,
  variant_land_k 1.0, variant_land_max 5, land_element_means {moc 31.1, hoa 15.1, tho 20.1, kim 13.7, thuy 20.0}.
- Item DB: set_W_share 0.5 (guess), set_bonus_min_pieces 2, set_size_min 2, set_size_max 5, items_sets.json (data
  file); artifacts_max 3 (World Generation owns, Item DB reads).
- Sects: admit_min 30, admit_core 45, head_min 50, kin_bonus 1000, home_bonus 500, variant_bonus 100,
  lineage_share_min 0.80, array_round 0.05, recruit_by, lineage (field); titles thai_thuong, chan_truyen, chap_su,
  khach_khanh, tap_dich; exceptions root_changed, before_relean, head_outside_line. seat_array_density (World Gen).
- Combat: companion_share 0.5, spread_share 0.5, act_window 1 s, still_after 2 s, moving_after 1 s, range_open 3 s,
  range_refresh 1 s, displace_delay 0.3 / 0.5 s, displaced_time 2 s, rooted_delay_share 0.5, rooted_moment 1 s,
  broken_threshold 0.25. Effects: statuses Displaced, Rooted, Pinned, Planted.
- World Gen: local_recruit 0.75, admit_tries 8 (guess), seat_array_density per seat 0-0.65, N_cast 4,947, seat-fit bars
  25 % / 15 % / 5.

## Systems index rows to update
- #6 Linh Căn, #13 Item DB, #26 Sects, #48 Provinces, #27 World Generation, #42 NPC Traits, #21 Combat, #41 Effects:
  note "Amended 2026-11-25 (world-depth rulings)".
