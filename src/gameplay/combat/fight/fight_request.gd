class_name FightRequest
extends RefCounted
## A request for one fight (ADR-0001 Key Interfaces; Combat GDD Event Engine row and rule 3). The caller compiles both
## fighters, derives the seed from the session stream (ADR-0002, Proposed: [code]fight_seed = session_rng.randi()[/code])
## and applies the result's costs itself.
##
## Deviation from the ADR's sketch: the seed field is [member fight_seed], since [code]seed[/code] would shadow
## GDScript's global [code]seed()[/code].

enum Situation { FORESEEN, AMBUSH, BLIND }

## The two compiled fighters; side A is the requester (the player or the event's actor).
var a: FighterProfile
var b: FighterProfile
## What preparation applies (Combat rule 12). Read when the fighters are compiled; the fight itself does not use it.
var situation: Situation = Situation.FORESEEN
## Request tags (rules 12, 26; AC-CB-104, 2026-11-26): those in combat_engine.json REQUEST_TAGS (tribulation) are kept
## and rules read them as tag.<name>; any other (own_abode, vein, a place or biome) applies nothing and is noted
## once in the result as ignored.
var ground_tags: Array[StringName] = []
## No healing in the fight (Combat Defence & Healing rule 19). Not run by either engine yet: true is refused.
var no_heal: bool = false
## Side A's starting shares of health and usable linh lực (Combat rule 3; Heavenly Tribulation waves). Both or
## neither: 1.0 and 1.0 is the usual full start.
var start_health_share: float = 1.0
var start_qi_share: float = 1.0
var fight_seed: int = 0
## The timeline log costs time; on for the debug terminal and replays.
var log_enabled: bool = false
