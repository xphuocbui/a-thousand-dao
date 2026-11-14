extends DaoTestSuite
## RngUtils.stable_hash (ADR-0002 decision 4): the project-owned hash keyed streams use. The pinned values are the
## published 32-bit FNV-1a test vectors plus keys in the game's own shape; if one changes, keyed values in saves move.


func test_stable_hash_matches_the_fnv1a_test_vectors() -> void:
	# boundary values: the exact numbers are the point
	assert_eq(RngUtils.stable_hash(""), 2166136261, "empty string is the offset basis")
	assert_eq(RngUtils.stable_hash("a"), 3826002220, "'a' is 0xe40c292c")
	assert_eq(RngUtils.stable_hash("foobar"), 3214735720, "'foobar' is 0xbf9cf968")


func test_stable_hash_pins_game_keys_including_vietnamese_text() -> void:
	assert_eq(RngUtils.stable_hash("variant:thien_kiep"), 1474574704, "a map variant key")
	assert_eq(RngUtils.stable_hash("2:Kim"), 3311430612, "a market par key")
	assert_eq(RngUtils.stable_hash("Tông môn"), 1665069007, "UTF-8 bytes, not code points")


func test_stable_hash_stays_in_32_bits_for_long_keys() -> void:
	var h: int = RngUtils.stable_hash("x".repeat(10000))
	assert_true(h >= 0 and h <= 0xFFFFFFFF, "in range: %d" % h)
