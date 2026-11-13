class_name WardShieldDef
extends RefCounted
## A ward shield as compiled (Combat Defence & Healing rules 1, 9; R25 floor; AC-CD-82 pieces), mirroring the sim's
## [code]Shield[/code]. Read-only once loaded; a fight keeps the bar's state in [FighterState.ShieldState].

## Bar size as a share of the owner's qi_base.
var size: float = 0.0
## Kept for the sim's record shape; the engine does not read it.
var body: bool = false
## A standing shield recharges after a quiet spell; a cast shield's bar lasts its window only.
var standing: bool = true
## Share of each damage type it stops, by type; the key "ticks" overrides for ticks. A type not listed: 1.0 for
## hits, 0.0 for ticks and Soul.
var stops: Dictionary = {}
## Pieces: each piece soaks at most size / pieces of one hit part (AC-CD-82).
var pieces: int = 1
## After the bar is spent it keeps stopping this share (R25).
var floor_share: float = 0.0
