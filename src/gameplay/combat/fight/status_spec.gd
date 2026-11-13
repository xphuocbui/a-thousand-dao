class_name StatusSpec
extends RefCounted
## A status an art applies on hit (Effects GDD, Status Catalogue), as the sim's spec dicts:
## {"id", "stacks", "chance", and optionally "dur", "cap", "layer", "tag", "crossing", "no_lockout"}.
## Read-only once loaded.

var id: String = ""
var stacks: int = 1
## 1 applies it surely (status resistance aside); below 1 it is rolled, clamped by Combat Formulas F.
var chance: float = 1.0
## The optional keys as given ("dur" or "cap" may be null: until cleansed, no cap). Absent keys fall back to the
## Status Catalogue.
var extra: Dictionary = {}
