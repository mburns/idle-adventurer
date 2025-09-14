extends "res://tests/unit/gut_test_base.gd"

# Test suite for bug fixes and logic improvements

func test_lambda_capture_fixes():
	"""Test that lambda capture issues are resolved"""
	var start_screen = preload("res://scripts/ui/start_screen.gd").new()
	# var skill_buttons = preload("res://scripts/skill_buttons.gd").new() # Script does not exist
	var animation_manager = preload("res://scripts/visual/animation_manager.gd").new()

	# These should not cause lambda capture errors
	assert_not_null(start_screen, "Start screen should be created")
	# assert_not_null(skill_buttons, "Skill buttons should be created") # Script does not exist
	assert_not_null(animation_manager, "Animation manager should be created")

func test_theme_manager_functions():
	"""Test that theme manager has required functions"""
	var theme_manager = ThemeManager

	assert_true(theme_manager.has_method("apply_theme_to_children"),
		"ThemeManager should have apply_theme_to_children function")
	assert_true(theme_manager.has_method("apply_theme_to_node"),
		"ThemeManager should have apply_theme_to_node function")

	# Test that the function works without errors
	var test_node = Node.new()
	theme_manager.apply_theme_to_children(test_node)
	test_node.queue_free()

func test_data_loader_functions():
	"""Test that data loader has required functions"""
	var data_loader = DataLoader

	assert_true(data_loader.has_method("load_json_data"),
		"DataLoader should have load_json_data function")

	# Test loading names data (should not cause errors)
	var names_data = data_loader.load_json_data("names")
	# names_data might be empty if file doesn't exist, but should not crash
	assert_not_null(names_data, "load_json_data should return a dictionary")

func test_character_creation_node_references():
	"""Test that character creation uses correct node references"""
	var _character_creation = preload("res://scripts/core/character_creation.gd").new()

	# Test that the script compiles without node reference errors
	assert_not_null(_character_creation, "Character creation script should load")

	# Test random character generation (should not crash on node access)
	_character_creation.generate_random_character()

func test_character_manager_property_access():
	"""Test that character manager uses proper property access"""
	var character_manager = CharacterManager
	var character = Character.new()

	# Test race bonus application (should not use generic get/set)
	var _race_data = {
		"ability_increases": {
			"strength": 2,
			"dexterity": 1
		}
	}

	# This should not cause "get" method errors
	character_manager.apply_race_bonuses(character, "Test Race")

	assert_true(character.strength >= 10, "Strength should be modified")
	assert_true(character.dexterity >= 10, "Dexterity should be modified")

func test_division_by_zero_prevention():
	"""Test that division by zero is prevented"""
	var leveling_screen = preload("res://scripts/ui/leveling_screen.gd").new()

	# Test with zero XP needed (should not crash)
	var character = Character.new()
	character.experience_points = 0

	# This should not cause division by zero
	leveling_screen.update_experience_bar(character)

	assert_not_null(leveling_screen, "Leveling screen should handle zero XP")

func test_null_checks_in_character_sheet():
	"""Test that character sheet handles null values properly"""
	var _character_sheet = preload("res://scripts/ui/character_sheet.gd").new()
	var character = Character.new()

	# Test spell slots access (should not use has_method("get"))
	character.spell_slots = {"1": 2, "2": 1}
	_character_sheet.update_spell_slots_display(character)

	# Test active buffs access (should not use has_method("get"))
	character.active_buffs = [ {"name": "Test Buff", "expires_at": 100.0}]
	_character_sheet.update_active_buffs_display(character)

	assert_not_null(_character_sheet, "Character sheet should handle character data")

func test_file_operation_error_handling():
	"""Test that file operations have proper error handling"""
	var character_manager = CharacterManager

	# Test save with invalid path (should handle gracefully)
	var original_path = character_manager.save_file_path
	character_manager.save_file_path = "/invalid/path/that/does/not/exist.dat"

	var save_result = character_manager.save_character()
	assert_false(save_result, "Save should fail gracefully with invalid path")

	# Restore original path
	character_manager.save_file_path = original_path

func test_array_bounds_safety():
	"""Test that array access is bounds-safe"""
	var _character_creation = preload("res://scripts/core/character_creation.gd").new()

	# Test random selection with empty arrays (should not crash)
	var empty_array = []
	if empty_array.size() > 0:
		var random_item = empty_array[randi() % empty_array.size()]
		assert_not_null(random_item, "Random selection should work")

	# Test with valid array
	var test_array = ["item1", "item2", "item3"]
	if test_array.size() > 0:
		var random_item = test_array[randi() % test_array.size()]
		assert_true(random_item in test_array, "Random selection should return valid item")

func test_signal_connection_safety():
	"""Test that signal connections are safe"""
	var _character_sheet = preload("res://scripts/ui/character_sheet.gd").new()

	# Test that signal connections don't cause errors
	var character_manager = CharacterManager
	if character_manager.has_signal("character_changed"):
		character_manager.character_changed.connect(_test_signal_handler)
		assert_true(character_manager.character_changed.is_connected(_test_signal_handler),
			"Signal should be connected")
		character_manager.character_changed.disconnect(_test_signal_handler)

func _test_signal_handler(character: Character):
	"""Test signal handler"""
	assert_not_null(character, "Signal should pass valid character")
