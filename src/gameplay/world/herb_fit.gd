class_name HerbFit
extends RefCounted

## Herb fit (design/gdd/travel-map.md rule 18, Formula G): how well a herb grows at a place.
## fit = f_e * f_T * f_R * f_D, with f_e = e_floor + (1 - e_floor) * min(1, s'_e / s_full) on the place's share of the
## herb's element (layer pushes included), f_T = clamp(1 - max(0, |T - T_i| - tol_T) / fall_T, 0, 1) on the temperature
## index (f_R the same on rainfall), and f_D = min(1, D / D_need)^2 by the herb's rarity. Growth runs at g_max * fit;
## below plant_floor the herb cannot be planted, but one already in the ground keeps growing at g_max * fit (AC-TM-74). A place without qi or climate (the old generated world) grows at x1.
##
## Data: items_herbs.json "fit" (the keys) and each herb's temp_ideal, temp_tol, rain_ideal, rain_tol (first guesses);
## world_map.json "climate_index" turns degrees and millimetres into the 0-100 indexes.
##
## Usage:
## [codeblock]
## var f: Dictionary = HerbFit.fit(gd, gd.herb("hoa_linh_chi"), place)
## print(f.fit, " ", f.label, " ", f.lines)
## [/codeblock]

const HERBS_FILE := "items_herbs"


static func _cfg(gd: GameData) -> Dictionary:
	return gd.file(HERBS_FILE).get("fit", {})


## The temperature and rainfall indexes (0-100) of [param place] ({} without climate).
static func climate(gd: GameData, place: Dictionary) -> Dictionary:
	if not place.has("temp_c") or not place.has("rain_mm"):
		return {}
	var ci: Dictionary = gd.file(LandQi.DATA_FILE).get("climate_index", {"t_c": [-20.0, 30.0], "r_mm": [0.0, 4000.0]})
	var t: Array = ci.t_c
	var r: Array = ci.r_mm
	return {"T": clampf((float(place.temp_c) - float(t[0])) / (float(t[1]) - float(t[0])) * 100.0, 0.0, 100.0),
		"R": clampf((float(place.rain_mm) - float(r[0])) / (float(r[1]) - float(r[0])) * 100.0, 0.0, 100.0)}


static func _band(x: float, ideal: float, tol: float, fall: float) -> float:
	return clampf(1.0 - maxf(0.0, absf(x - ideal) - tol) / fall, 0.0, 1.0)


## Formula G at [param place] for [param herb] (an items_herbs.json template): {fit, growth, plantable, label, lines}.
static func fit(gd: GameData, herb: Dictionary, place: Dictionary) -> Dictionary:
	var cfg: Dictionary = _cfg(gd)
	var qi: Dictionary = place.get("qi", {})
	var cl: Dictionary = climate(gd, place)
	if qi.is_empty() or cl.is_empty() or not herb.has("temp_ideal"):
		return {"fit": -1.0, "growth": 1.0, "plantable": true, "label": "", "lines": ["no land qi here: grows as it always has"]}
	var e: String = str(herb.get("element", ""))
	var share: float = float(qi.get("shares", {}).get(e, qi.get("variants", {}).get(e, 0.0)))
	for item in LandQi.active_layer3(qi):
		share += float(item.get("push", {}).get(e, 0.0))
	var variant: bool = not qi.get("shares", {}).has(e)
	var s_full: float = float(cfg.get("elem_full_share_variant", 20.0)) if variant else float(cfg.get("elem_full_share", 40.0))
	var e_floor: float = float(cfg.get("elem_floor", 0.3))
	var f_e: float = e_floor + (1.0 - e_floor) * minf(1.0, share / s_full)
	var fall: float = float(cfg.get("fall", 30.0))
	var f_t: float = _band(float(cl.T), float(herb.temp_ideal), float(herb.temp_tol), fall)
	var f_r: float = _band(float(cl.R), float(herb.rain_ideal), float(herb.rain_tol), fall)
	var needs: Array = cfg.get("density_need_by_rarity", [0, 0, 0, 1.0, 1.2, 1.5, 1.8])
	var need: float = float(needs[clampi(int(herb.get("rarity", 1)), 0, needs.size() - 1)])
	var d: float = float(place.get("density", 1.0)) + LandQi.layer3_density(gd, qi)
	var f_d: float = 1.0 if need <= 0.0 else pow(minf(1.0, d / need), 2.0)
	var f: float = f_e * f_t * f_r * f_d
	var floor_v: float = float(cfg.get("plant_floor", 0.2))
	var lines: Array = [
		"element %s share %.0f -> x%.2f" % [e, share, f_e],
		"temperature %.0f (ideal %d +/- %d) -> x%.2f" % [cl.T, int(herb.temp_ideal), int(herb.temp_tol), f_t],
		"rainfall %.0f (ideal %d +/- %d) -> x%.2f" % [cl.R, int(herb.rain_ideal), int(herb.rain_tol), f_r],
	]
	if need > 0.0:
		lines.append("density %.2f (needs %.1f) -> x%.2f" % [d, need, f_d])
	return {"fit": f, "growth": float(cfg.get("growth_max", 1.2)) * f, "plantable": f >= floor_v,
		"label": label(gd, f), "lines": lines}


## Formula G's word for a fit (each band includes its lower bound).
static func label(gd: GameData, f: float) -> String:
	var bands: Array = _cfg(gd).get("labels", [[0.8, "excellent"], [0.6, "good"], [0.4, "fair"], [0.2, "poor"]])
	for b in bands:
		if f >= float(b[0]):
			return str(b[1])
	return "unplantable"
