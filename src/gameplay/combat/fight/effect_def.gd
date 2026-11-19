class_name EffectDef
extends RefCounted
## One Effect record compiled for the fight engine (ADR-0001 decision 3; Effects GDD rules 5, 6, 8, 16): the sim's
## record shape ({"id", "on", "filter", "if", "scale", "limit", "chance", "held", "do"}) read once at load into typed
## parts, so the fight loop never parses JSON. Read-only once compiled. [EffectCompiler] builds and validates it.


## A readable (Effects rule 5), parsed once: which side it reads and what.
class ReadDef extends RefCounted:
	## 0: own, 1: foe, 2: no side (time, event.*).
	var side: int = 0
	## The part after "own." / "foe." (or the whole key for time and event.*).
	var key: String = ""
	## The parameter after a prefix (buff.<el>, status.<id>, counter.<id>, event.<field>, since.<art>...).
	var param: String = ""
	## fired_within: the window in ms, what it counts (all, tag, group, art) and the value.
	var window_ms: int = 0
	var what: String = ""


## A condition: a read compared with a value, or "any" of a list.
class CondDef extends RefCounted:
	## True for an "any" condition (an empty list never holds, as in the sim).
	var is_any: bool = false
	var any: Array = []
	var read: ReadDef = null
	var op: String = ">="
	var value: float = 0.0


## Scaling (Effects rule 8): the read divided by per, floored unless told not to, capped, at least 0.
class ScaleDef extends RefCounted:
	var read: ReadDef
	var per: float = 1.0
	var do_floor: bool = true
	var has_cap: bool = false
	var cap: float = 0.0


## One action: its verb and argument as given (the sim's {"verb": arg}).
class ActionDef extends RefCounted:
	var verb: String = ""
	var arg: Variant = null
	## consume's "then" actions, compiled.
	var then: Array = []


var id: String = ""
## The event it listens to, or "always".
var on: String = ""
## Matched against the event (the sim's match()); empty matches everything.
var filter: Dictionary = {}
var conds: Array[CondDef] = []
var scale: ScaleDef = null
## Limits: per fight, per pulse (-1: none), cooldown seconds (-1: none).
var per_fight: int = -1
var per_pulse: int = -1
var cooldown: float = -1.0
## per_firing: firings per art firing (-1 none); scale_per_pulse: the summed scale a pulse may give (-1 none).
var per_firing: int = -1
var scale_per_pulse: float = -1.0
var chance: float = 1.0
## A held payload (Effects rule 16): banked on its event, spent on "until"; cap -1 for none.
var held: bool = false
var held_until: String = ""
var held_cap: float = -1.0
var actions: Array[ActionDef] = []
