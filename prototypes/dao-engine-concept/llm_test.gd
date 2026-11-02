# PROTOTYPE - NOT FOR PRODUCTION
# Question: Does drafting/fusing fragments into a chain engine make players rework builds, and can a local LLM narrate it within engine budgets?
# Date: 2026-11-02
extends SceneTree

# Headless check of llm.gd against an endpoint: godot --headless --path . -s llm_test.gd
# Optional user args after --: url model

const Llm := preload("res://llm.gd")

func _init() -> void:
	var llm = Llm.new()
	root.add_child(llm)
	var args := OS.get_cmdline_user_args()
	if args.size() >= 1:
		llm.url = args[0]
	if args.size() >= 2:
		llm.model = args[1]
	await process_frame
	for n in 10:
		var r: Dictionary = await llm.invent_event(n % 3, "test call %d" % n)
		print("event %d: ok=%s ms=%d strict=%s lenient=%s keys=%s clamped=%s %s" % [n, r.ok, r.ms, r.get("strict"), r.get("lenient"), r.get("keys"), r.get("was_clamped"), r.get("error", "")])
	print(llm.stats_text())
	for k in 2:
		var nr: Dictionary = await llm.narrate("Total damage 77 against HP 140. Round 1: Ember Palm dealt 77.", ["77", "140", "1"])
		print("narrate %d: ok=%s faithful=%s stray=%s ms=%d" % [k, nr.ok, nr.get("faithful"), nr.get("stray"), nr.ms])
	# failure path: nothing listening
	llm.url = "http://localhost:9/v1/chat/completions"
	var bad: Dictionary = await llm.invent_event(0, "unreachable")
	print("unreachable endpoint -> ok=%s error=%s" % [bad.ok, bad.get("error")])
	quit()
