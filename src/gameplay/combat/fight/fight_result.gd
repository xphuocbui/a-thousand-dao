class_name FightResult
extends RefCounted
## What a [Fight] returns (Combat AC-CB-06; ADR-0001 Key Interfaces). Slice 1 fills the winner, ending, time, both
## end states and the log; life costs and the deciding layer come with later slices.
## The log is [member log_rows], not [code]log[/code], which would shadow GDScript's [code]log()[/code].

enum Winner { A, B, DRAW }
enum Ending { KNOCKOUT, DRAW, FLIGHT }

var winner: Winner
var ending: Ending
## True when the time limit ended the fight (a DRAW).
var timed_out: bool = false
var t_ms: int
var seconds: float
var a_end: FighterEnd
var b_end: FighterEnd
## Combat AC-CB-06; -1 for a soul win, a draw or a flight (set by a later slice).
var deciding_layer: int = -1
## Empty unless the log was on.
var log_rows: Array[FightLogRow] = []


## The sim's win code: "A", "B", "draw" (both down) or "time" (the limit).
func win_code() -> String:
	if timed_out:
		return "time"
	if ending == Ending.FLIGHT:
		return "flight"
	match winner:
		Winner.A:
			return "A"
		Winner.B:
			return "B"
	return "draw"
