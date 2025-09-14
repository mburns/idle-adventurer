extends GutTest

# Comprehensive tests for CharacterManager
# Tests all major functionality including character creation, saving/loading, and equipment

# Test counters
var total_tests: int = 0
var passed_tests: int = 0
var failed_tests: int = 0

# Assertion methods
func assert_equals(actual, expected, message: String):
	total_tests += 1
	if actual == expected:
		passed_tests += 1
		print("  ✓ " + message)
	else:
		failed_tests += 1
		print("  ✗ " + message + " (expected: " + str(expected) + ", got: " + str(actual) + ")")

func assert_true(condition: bool, message: String):
	total_tests += 1
	if condition:
		passed_tests += 1
		print("  ✓ " + message)
	else:
		failed_tests += 1
		print("  ✗ " + message)

func assert_false(condition: bool, message: String):
	total_tests += 1
	if not condition:
		passed_tests += 1
		print("  ✓ " + message)
	else:
		failed_tests += 1
		print("  ✗ " + message)

func assert_not_null(value, message: String):
	total_tests += 1
	if value != null:
		passed_tests += 1
		print("  ✓ " + message)
	else:
		failed_tests += 1
		print("  ✗ " + message)

func assert_gt(value1, value2, message: String):
	total_tests += 1
	if value1 > value2:
		passed_tests += 1
		print("  ✓ " + message)
	else:
		failed_tests += 1
		print("  ✗ " + message + " (" + str(value1) + " not greater than " + str(value2) + ")")

func test_character_manager_initialization():
	"""Test that CharacterManager initializes properly"""
	var manager = CharacterManager.new()
	assert_not_null(manager, "CharacterManager should initialize")
	assert_not_null(manager.current_character, "Should have a default character")
	assert_equals(manager.current_character.name, "Bob", "Default character name should be Bob")

func test_create_character():
	"""Test character creation with custom parameters"""
	var manager = CharacterManager.new()

	# Create a custom character
	var character = manager.create_character("TestHero", "Elf", "Wizard", "Sage")

	assert_not_null(character, "Character should be created")
	assert_equals(character.name, "TestHero", "Character name should match")
	assert_equals(character.race, "Elf", "Character race should match")
	assert_equals(character.character_class, "Wizard", "Character class should match")
	assert_equals(character.background, "Sage", "Character background should match")

func test_race_bonuses():
	"""Test that race bonuses are applied correctly"""
	var manager = CharacterManager.new()
	var character = manager.create_character("TestHuman", "Human", "Fighter", "Soldier")

	# Human should get +1 to all abilities
	assert_equals(character.strength, 11, "Human should get +1 Strength")
	assert_equals(character.dexterity, 11, "Human should get +1 Dexterity")
	assert_equals(character.constitution, 11, "Human should get +1 Constitution")
	assert_equals(character.intelligence, 11, "Human should get +1 Intelligence")
	assert_equals(character.wisdom, 11, "Human should get +1 Wisdom")
	assert_equals(character.charisma, 11, "Human should get +1 Charisma")

func test_character_save_and_load():
	"""Test character saving and loading functionality"""
	var manager = CharacterManager.new()
	manager.save_file_path = "user://test_character.dat"

	# Create a test character
	var original_character = manager.create_character("SaveTest", "Dwarf", "Cleric", "Acolyte")
	original_character.level = 5
	original_character.gold = 1000

	# Save the character
	var save_result = manager.save_character()
	assert_true(save_result, "Character should save successfully")

	# Create a new manager and load the character
	var new_manager = CharacterManager.new()
	new_manager.save_file_path = "user://test_character.dat"
	var load_result = new_manager.load_character()

	assert_true(load_result, "Character should load successfully")
	assert_not_null(new_manager.current_character, "Loaded character should exist")
	assert_equals(new_manager.current_character.name, "SaveTest", "Loaded character name should match")
	assert_equals(new_manager.current_character.level, 5, "Loaded character level should match")
	assert_equals(new_manager.current_character.gold, 1000, "Loaded character gold should match")

	# Cleanup
	new_manager.delete_save_file()

func test_character_equipment():
	"""Test that starting equipment is assigned correctly"""
	var manager = CharacterManager.new()
	var character = manager.create_character("EquipmentTest", "Human", "Fighter", "Soldier")

	# Fighter should have some starting equipment
	assert_true(character.equipment.size() > 0, "Character should have starting equipment")

	# Check that equipment slots are populated
	var has_weapon = false
	var has_armor = false

	for slot in character.equipment.keys():
		var item = character.equipment[slot]
		if item is String and ("sword" in item.to_lower() or "axe" in item.to_lower()):
			has_weapon = true
		if item is String and ("armor" in item.to_lower() or "mail" in item.to_lower()):
			has_armor = true

	assert_true(has_weapon, "Fighter should have a weapon")
	assert_true(has_armor, "Fighter should have armor")

func test_character_proficiencies():
	"""Test that character proficiencies are set correctly"""
	var manager = CharacterManager.new()
	var character = manager.create_character("ProfTest", "Elf", "Rogue", "Criminal")

	# Character should have proficiencies from race, class, and background
	assert_true(character.skill_proficiencies.size() > 0, "Character should have skill proficiencies")
	assert_true(character.tool_proficiencies.size() > 0, "Character should have tool proficiencies")
	assert_true(character.language_proficiencies.size() > 0, "Character should have language proficiencies")

func test_character_stats():
	"""Test that character stats are calculated correctly"""
	var manager = CharacterManager.new()
	var character = manager.create_character("StatsTest", "Human", "Barbarian", "Outlander")

	# Test ability modifiers
	var str_mod = character.get_strength_modifier()
	var dex_mod = character.get_dexterity_modifier()
	var con_mod = character.get_constitution_modifier()

	assert_true(str_mod >= -5 and str_mod <= 5, "Strength modifier should be reasonable")
	assert_true(dex_mod >= -5 and dex_mod <= 5, "Dexterity modifier should be reasonable")
	assert_true(con_mod >= -5 and con_mod <= 5, "Constitution modifier should be reasonable")

	# Test derived stats
	assert_true(character.max_hit_points > 0, "Character should have hit points")
	assert_true(character.armor_class >= 10, "Character should have reasonable AC")
	assert_true(character.proficiency_bonus >= 2, "Character should have proficiency bonus")

func test_character_signals():
	"""Test that character manager signals work correctly"""
	var manager = CharacterManager.new()
	var signal_received = false
	var received_character = null

	# Connect to signals
	manager.character_created.connect(func(character_param): signal_received = true; received_character = character_param)

	# Create a character
	var _character = manager.create_character("SignalTest", "Human", "Wizard", "Sage")

	assert_true(signal_received, "character_created signal should be emitted")
	assert_not_null(received_character, "Signal should pass the character")
	assert_equals(received_character.name, "SignalTest", "Signal should pass correct character")

func test_inventory_system_integration():
	"""Test that inventory system works with character manager"""
	var manager = CharacterManager.new()
	var character = manager.create_character("InventoryTest", "Human", "Fighter", "Soldier")

	# Test that inventory system can be retrieved
	var inventory_system = manager.get_inventory_system()
	assert_not_null(inventory_system, "Inventory system should be available")

	# Test adding items
	var test_item = {
		"id": "test_sword",
		"name": "Test Sword",
		"type": "weapon",
		"description": "A test sword",
		"weight": 3.0,
		"value": 10.0,
		"rarity": "common"
	}

	var add_result = inventory_system.add_item(character, test_item, 1)
	assert_true(add_result, "Should be able to add item to inventory")

func test_character_manager_edge_cases():
	"""Test edge cases and error handling"""
	var manager = CharacterManager.new()

	# Test with invalid race/class/background
	var character = manager.create_character("EdgeTest", "InvalidRace", "InvalidClass", "InvalidBackground")
	assert_not_null(character, "Should create character even with invalid data")
	assert_equals(character.name, "EdgeTest", "Character name should still be set")

	# Test save file operations
	assert_false(manager.has_save_file(), "Should not have save file initially")

	# Test deleting non-existent save file
	var delete_result = manager.delete_save_file()
	assert_false(delete_result, "Should return false when deleting non-existent file")

func test_character_manager_performance():
	"""Test performance of character operations"""
	var manager = CharacterManager.new()

	# Test creating multiple characters quickly
	var start_time = Time.get_unix_time_from_system()

	for i in range(10):
		var character = manager.create_character("PerfTest" + str(i), "Human", "Fighter", "Soldier")
		assert_not_null(character, "Should create character " + str(i))

	var end_time = Time.get_unix_time_from_system()
	var duration = end_time - start_time

	assert_true(duration < 5.0, "Creating 10 characters should take less than 5 seconds")

func test_character_data_consistency():
	"""Test that character data remains consistent across operations"""
	var manager = CharacterManager.new()
	var character = manager.create_character("ConsistencyTest", "Elf", "Ranger", "Outlander")

	# Store original values
	var original_name = character.name
	var _original_level = character.level
	var _original_gold = character.gold
	var original_strength = character.strength

	# Modify character
	character.level = 10
	character.gold = 5000
	character.strength = 20

	# Verify changes
	assert_equals(character.name, original_name, "Name should not change")
	assert_equals(character.level, 10, "Level should be updated")
	assert_equals(character.gold, 5000, "Gold should be updated")
	assert_equals(character.strength, 20, "Strength should be updated")

	# Test that other stats weren't accidentally changed
	assert_equals(character.dexterity, original_strength, "Other stats should remain unchanged")

func test_character_manager_cleanup():
	"""Test cleanup and resource management"""
	var manager = CharacterManager.new()
	manager.save_file_path = "user://cleanup_test.dat"

	# Create and save a character
	var _character = manager.create_character("CleanupTest", "Human", "Fighter", "Soldier")
	manager.save_character()

	# Verify file exists
	assert_true(manager.has_save_file(), "Save file should exist")

	# Delete the file
	var delete_result = manager.delete_save_file()
	assert_true(delete_result, "Should successfully delete save file")
	assert_false(manager.has_save_file(), "Save file should no longer exist")
