extends GutTest

var test_character: Character

func before_each():
	test_character = Character.new()
	test_character.name = "TestCharacter"

func after_each():
	if test_character:
		test_character.queue_free()

func test_load_class_features_for_level():
	test_character.character_class = "Fighter"
	test_character.level = 2

	var features = test_character.load_class_features_for_level("Fighter", 2)
	assert_true(features is Array, "Should return array of features")
	# Should contain "Action Surge" for Fighter level 2

func test_load_class_features_for_level_5():
	test_character.character_class = "Fighter"
	test_character.level = 5

	var features = test_character.load_class_features_for_level("Fighter", 5)
	assert_true(features is Array, "Should return array of features")
	# Should contain "Extra Attack" for Fighter level 5

func test_load_class_features_invalid_class():
	var features = test_character.load_class_features_for_level("InvalidClass", 2)
	assert_eq(features.size(), 0, "Should return empty array for invalid class")

func test_parse_class_yaml_for_level_features():
	# This test is deprecated since we now use .tres resources instead of YAML parsing
	pending("YAML parsing removed - now using .tres resources")
	return
	var yaml_content = """
level_features:
  1:
    - Fighting Style
    - Second Wind
  2:
    - Action Surge
  3:
    - Martial Archetype
  4:
    - Ability Score Improvement
  5:
    - Extra Attack
"""

	var features = test_character.parse_class_yaml_for_level_features(yaml_content, 2)
	assert_eq(features.size(), 1, "Should find one feature for level 2")
	assert_eq(features[0], "Action Surge", "Should find Action Surge")

func test_parse_class_yaml_for_level_features_multiple():
	# This test is deprecated since we now use .tres resources instead of YAML parsing
	pending("YAML parsing removed - now using .tres resources")
	return
	var yaml_content = """
level_features:
  1:
    - Fighting Style
    - Second Wind
  2:
    - Action Surge
  3:
    - Martial Archetype
  4:
    - Ability Score Improvement
  5:
    - Extra Attack
"""

	var features = test_character.parse_class_yaml_for_level_features(yaml_content, 1)
	assert_eq(features.size(), 2, "Should find two features for level 1")
	assert_true(features.has("Fighting Style"), "Should contain Fighting Style")
	assert_true(features.has("Second Wind"), "Should contain Second Wind")

func test_parse_class_yaml_no_features():
	# This test is deprecated since we now use .tres resources instead of YAML parsing
	pending("YAML parsing removed - now using .tres resources")
	return
	var yaml_content = """
level_features:
  1:
    - Fighting Style
  2:
    - Action Surge
"""

	var features = test_character.parse_class_yaml_for_level_features(yaml_content, 5)
	assert_eq(features.size(), 0, "Should return empty array for level with no features")

func test_apply_class_feature():
	test_character.name = "TestFighter"
	test_character.apply_class_feature("Action Surge")
	# Should print "TestFighter gains Action Surge!"

func test_apply_class_feature_ability_score_improvement():
	test_character.name = "TestFighter"
	test_character.apply_class_feature("Ability Score Improvement")
	# Should print about ability score improvement

func test_apply_class_feature_extra_attack():
	test_character.name = "TestFighter"
	test_character.apply_class_feature("Extra Attack")
	# Should print about extra attack

func test_apply_class_feature_spell_slots():
	test_character.character_class = "Wizard"
	test_character.level = 3
	test_character.apply_class_feature("Spell Slots")
	# Should update spell slots

func test_update_spell_slots_for_level_wizard():
	test_character.character_class = "Wizard"
	test_character.level = 3
	test_character.update_spell_slots_for_level()
	assert_true(test_character.spell_slots.size() > 0, "Wizard should have spell slots")

func test_update_spell_slots_for_level_fighter():
	test_character.character_class = "Fighter"
	test_character.level = 3
	test_character.update_spell_slots_for_level()
	assert_eq(test_character.spell_slots.size(), 0, "Fighter should not have spell slots")

func test_calculate_spell_slots_for_level():
	var slots = test_character.calculate_spell_slots_for_level(1)
	assert_eq(slots.size(), 1, "Level 1 should have 1st level slots")
	assert_eq(slots[0], 2, "Level 1 should have 2 first level slots")

	var slots_3 = test_character.calculate_spell_slots_for_level(3)
	assert_eq(slots_3.size(), 2, "Level 3 should have 1st and 2nd level slots")

	var slots_5 = test_character.calculate_spell_slots_for_level(5)
	assert_eq(slots_5.size(), 3, "Level 5 should have 1st, 2nd, and 3rd level slots")

func test_apply_class_level_up_features():
	test_character.character_class = "Fighter"
	test_character.level = 2
	test_character.apply_class_level_up_features()
	# Should load and apply features for Fighter level 2

func test_apply_class_level_up_features_no_features():
	test_character.character_class = "Fighter"
	test_character.level = 25  # Invalid level
	test_character.apply_class_level_up_features()
	# Should handle gracefully when no features found
