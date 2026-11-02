# PROTOTYPE - NOT FOR PRODUCTION
# Question: Does drafting/fusing fragments into a chain engine make players rework builds, and can a local LLM narrate it within engine budgets?
# Date: 2026-11-02
extends SceneTree

# Scripted playthrough of main.tscn: godot --headless --path . -s smoke.gd

func _init() -> void:
	var main = load("res://main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	for stage in 3:
		for k in 3:
			main._on_offer(0)
		print("stage %d build: %s" % [stage + 1, ", ".join(main.build.map(func(f): return f.name))])
		main._on_fight()
		print("  status: %s" % main.status_label.text)
		if main.run_over:
			break
	main.slot_list.select(0)
	main.slot_list.select(1, false)
	main._on_fuse()
	main._on_move(1)
	main._on_discard()
	print("rework actions: %d, build size %d" % [main.rework_actions, main.build.size()])
	main.new_run()
	print("SMOKE DONE runs=%d" % main.runs_started)
	quit()
