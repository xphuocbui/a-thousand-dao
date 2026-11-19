class_name DaoTestSuite
extends GdUnitTestSuite
## Base suite for this project's gdUnit4 tests. Adds the four message-first helpers the
## suites were written with (assert_eq, assert_near, assert_true, assert_false), each
## reported through gdUnit4's own assertions, plus shared fixtures. Equality uses
## GDScript `==` (so 1 == 1.0 and dictionaries compare by content), as before the move.
##
## Usage:
## [codeblock]
## extends DaoTestSuite
## func test_addition_sums() -> void:
##     assert_eq(1 + 1, 2, "sum")
## [/codeblock]


## Asserts equality with a message.
func assert_eq(actual: Variant, expected: Variant, msg: String = "") -> void:
	assert_bool(same(actual, expected)).override_failure_message("%s: expected <%s> got <%s>" % [msg, str(expected), str(actual)]).is_true()


## GDScript `==`, except that inside dictionaries and arrays an int and a float of the same value are equal too
## (purities became floats, ADR-0004), as they are at the top level.
static func same(a: Variant, b: Variant) -> bool:
	if a is Dictionary and b is Dictionary:
		if a.size() != b.size():
			return false
		for k in a:
			if not b.has(k) or not same(a[k], b[k]):
				return false
		return true
	if a is Array and b is Array:
		if a.size() != b.size():
			return false
		for i in a.size():
			if not same(a[i], b[i]):
				return false
		return true
	if (a is int or a is float) and (b is int or b is float):
		return float(a) == float(b)
	return a == b


## Asserts a float is within [param tolerance] of [param expected].
func assert_near(actual: float, expected: float, tolerance: float, msg: String = "") -> void:
	assert_bool(absf(actual - expected) <= tolerance).override_failure_message("%s: expected %s ± %s got %s" % [msg, str(expected), str(tolerance), str(actual)]).is_true()


## Asserts a condition is true.
func assert_true(condition: bool, msg: String = "") -> void:
	assert_bool(condition).override_failure_message("%s: expected true" % msg).is_true()


## Asserts a condition is false.
func assert_false(condition: bool, msg: String = "") -> void:
	assert_bool(condition).override_failure_message("%s: expected false" % msg).is_false()


## The real game data, loaded once per process (shared, read-only).
static func game_data() -> GameData:
	return TestFixtures.game_data()


## A seeded RNG for deterministic tests.
static func rng(seed_value: int = 12345) -> RandomNumberGenerator:
	var r := RandomNumberGenerator.new()
	r.seed = seed_value
	return r
