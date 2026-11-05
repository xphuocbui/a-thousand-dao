extends SceneTree
## Exports the generated Kinh Mạch Đồ as JSON for viewers and analysis. It reports the map as
## generated and judges nothing.
##
##   Godot_console.exe --headless --path . -s res://tools/balance/export_tree.gd -- <out.json>


func _init() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var out_path: String = args[0] if args.size() > 0 else "user://meridian_map.json"
	var gd := GameData.load_from("res://assets/data")
	var tree := MeridianTree.generate(gd)
	var nodes: Array = []
	for id in tree.nodes.keys():
		var n: Dictionary = tree.nodes[id]
		var mods: Array = []
		for m in n.mods:
			mods.append(gd.format_mod(str(m.stat), float(m.value)))
		nodes.append({"id": id, "name": n.name, "kind": n.kind, "sector": n.sector, "depth": n.depth, "angle": n.angle,
			"links": n.links, "mods": mods, "cluster": int(n.get("cluster", -1)), "variant": str(n.get("variant", "")),
			"capability": int(n.get("capability", 0)), "desc": str(n.get("desc", ""))})
	var clusters: Array = []
	for k in tree.clusters.values():
		var cap: Dictionary = gd.capability(int(k.capability))
		clusters.append({"id": k.id, "name": k.name, "theme": gd.tree_config().themes[k.theme].name, "sector": k.sector, "location": k.location,
			"kind": k.kind, "seal": k.seal.type, "gate": gd.realm(int(k.gate)).name, "size": k.size, "capability": str(cap.get("name", "")), "capability_desc": str(cap.get("desc", ""))})
	var variants: Array = []
	for v in gd.variant_defs():
		variants.append({"id": v.id, "name": gd.element_label(str(v.id)), "origin": v.origin, "sector": tree.sectors.get(v.id, "")})
	var elements: Array = []
	for e in gd.element_cycle():
		elements.append({"id": e, "name": gd.element_label(str(e))})
	var f := FileAccess.open(out_path, FileAccess.WRITE)
	f.store_string(JSON.stringify({"nodes": nodes, "clusters": clusters, "variants": variants, "elements": elements, "regions": tree.regions, "groups": tree.groups}))
	f.close()
	print("wrote %d nodes, %d clusters to %s" % [nodes.size(), clusters.size(), out_path])
	quit()
