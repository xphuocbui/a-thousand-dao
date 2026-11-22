class_name UiScale
extends RefCounted
## The HUD's scaling rule (design/ux/hud.md, Platform Adaptation: Scaling rule; user decision 2026-11-22: UI scale
## 75-150 %): a smaller window gives less room, never smaller text; the layout area never drops below 1280×720.
## UI size = the UI scale setting × an automatic factor; the screen applies [method factor] as the window's content
## scale. Pure functions of the window size and the setting, so tests need no window.

## The layout area's floor, in layout pixels.
const MIN_W := 1280
const MIN_H := 720
## The base layout size the automatic factor grows from.
const BASE_W := 1920
const BASE_H := 1080
## The UI scale setting's range, in percent.
const MIN_PCT := 75
const MAX_PCT := 150


## The automatic factor: max(1, min(w / 1920, h / 1080)). It never shrinks the UI, and a tall or narrow window does not
## inflate it.
static func auto_factor(w: int, h: int) -> float:
	return maxf(1.0, minf(float(w) / float(BASE_W), float(h) / float(BASE_H)))


## The UI scale cap for a window, in whole percent: floor(100 × min(w / 1280, h / 720) ÷ the automatic factor), within
## 75-150 %. Integer arithmetic where it can be, so a cap that is exact (150 % at 2560×1440) never rounds to 149.
static func max_scale_pct(w: int, h: int) -> int:
	var a: float = auto_factor(w, h)
	var room: float = minf(float(w) / float(MIN_W), float(h) / float(MIN_H))
	var pct: int = int(floor(100.0 * room / a + 1e-9))
	return clampi(pct, MIN_PCT, MAX_PCT)


## The scale actually used for setting [param setting_pct] in a w×h window: the setting within 75 % and the window's cap.
## The saved setting itself is never changed by a resize.
static func effective_pct(setting_pct: int, w: int, h: int) -> int:
	return clampi(setting_pct, MIN_PCT, max_scale_pct(w, h))


## The content scale factor for setting [param setting_pct] in a w×h window: the effective scale × the automatic factor.
static func factor(setting_pct: int, w: int, h: int) -> float:
	return float(effective_pct(setting_pct, w, h)) / 100.0 * auto_factor(w, h)
