class_name RngUtils
extends RefCounted
## Stateless helpers over an injected [RandomNumberGenerator].
##
## Every gameplay system takes its RNG as a parameter so runs are reproducible from a
## seed and tests can pin outcomes.
##
## Usage:
## [codeblock]
## var rng := RandomNumberGenerator.new()
## rng.seed = 42
## var i: int = RngUtils.weighted_index(rng, [50, 30, 20])
## var pick: Variant = RngUtils.pick(rng, ["a", "b"])
## [/codeblock]


## Returns an index chosen with probability proportional to [param weights].
## Returns -1 for an empty list or when all weights are zero.
static func weighted_index(rng: RandomNumberGenerator, weights: Array) -> int:
	var total: float = 0.0
	for w in weights:
		total += maxf(float(w), 0.0)
	if total <= 0.0:
		return -1
	var roll: float = rng.randf() * total
	for i in weights.size():
		roll -= maxf(float(weights[i]), 0.0)
		if roll < 0.0:
			return i
	return weights.size() - 1


## Picks an element of [param items] weighted by each item's [param key] field.
static func weighted_pick(rng: RandomNumberGenerator, items: Array, key: String = "weight") -> Variant:
	var weights: Array = []
	for item in items:
		weights.append(float(item.get(key, 1.0)))
	var i: int = weighted_index(rng, weights)
	return null if i < 0 else items[i]


## Picks a uniformly random element, or null for an empty array.
static func pick(rng: RandomNumberGenerator, items: Array) -> Variant:
	if items.is_empty():
		return null
	return items[rng.randi_range(0, items.size() - 1)]


## Returns true with probability [param p] (clamped to 0..1).
static func chance(rng: RandomNumberGenerator, p: float) -> bool:
	return rng.randf() < clampf(p, 0.0, 1.0)


## Uniform float from a two-element range array [lo, hi].
static func range_f(rng: RandomNumberGenerator, bounds: Array) -> float:
	return rng.randf_range(float(bounds[0]), float(bounds[1]))


## Normal sample clamped to [lo, hi].
static func normal_clamped(rng: RandomNumberGenerator, mean: float, sd: float, lo: float, hi: float) -> float:
	return clampf(rng.randfn(mean, sd), lo, hi)


## Returns a shuffled copy of [param items] (Fisher-Yates with the given RNG).
static func shuffled(rng: RandomNumberGenerator, items: Array) -> Array:
	var out: Array = items.duplicate()
	for i in range(out.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var tmp: Variant = out[i]
		out[i] = out[j]
		out[j] = tmp
	return out
