extends SceneTree
## Font check for the art bible 7.11 candidates: every Vietnamese letter (lower and upper, all tones) and the tnum
## (tabular figures) OpenType feature. Prints observations only (a script emits observations, never verdicts).
## usage: godot --headless --path . -s res://tools/asset-pipeline/ui/font_check.gd

const FONTS := ["res://assets/fonts/literata/literata_vf.ttf",
	"res://assets/fonts/literata/literata_italic_vf.ttf",
	"res://assets/fonts/cormorant_garamond/cormorant_garamond_vf.ttf"]
const VI := "aàáảãạăằắẳẵặâầấẩẫậeèéẻẽẹêềếểễệiìíỉĩịoòóỏõọôồốổỗộơờớởỡợuùúủũụưừứửữựyỳýỷỹỵđ"


func _init() -> void:
	var letters: String = VI + VI.to_upper()
	for path in FONTS:
		var f := FontFile.new()
		var err: int = f.load_dynamic_font(ProjectSettings.globalize_path(path))
		if err != OK:
			print("FONT ", path, " load error ", err)
			continue
		var missing: PackedStringArray = []
		for ch in letters:
			if not f.has_char(ch.unicode_at(0)):
				missing.append(ch)
		var widths: Dictionary = {}
		for d in "0123456789":
			widths[d] = snappedf(f.get_string_size(d, HORIZONTAL_ALIGNMENT_LEFT, -1, 32).x, 0.01)
		var tab_feat := {TextServerManager.get_primary_interface().name_to_tag("tnum"): 1}
		var widths_t: Dictionary = {}
		var fv := FontVariation.new()
		fv.base_font = f
		fv.opentype_features = tab_feat
		for d in "0123456789":
			widths_t[d] = snappedf(fv.get_string_size(d, HORIZONTAL_ALIGNMENT_LEFT, -1, 32).x, 0.01)
		print("FONT ", path.get_file(), ": digit widths at 32 px default ", widths.values(), " with tnum ", widths_t.values(),
			" (equal widths = tabular)")
		print("FONT ", path.get_file(), ": vietnamese letters checked ", letters.length(), ", missing ", missing.size(),
			" ", "".join(missing), "; variation axes ", f.get_supported_variation_list().size())
	quit()
