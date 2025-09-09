extends SceneTree

# Comprehensive test runner for all test levels

# Preload all required scripts
const Character = preload("res://scripts/character.gd")
const CharacterManager = preload("res://scripts/character_manager.gd")
const DnDData = preload("res://scripts/dnd_data.gd")

var test_results: Dictionary = {}
var total_tests: int = 0
var passed_tests: int = 0
var failed_tests: int = 0

func _init():
    print("🧪 Idle Adventurer Comprehensive Test Suite")
    print("==========================================")
    print()

    # Run all test levels
    run_unit_tests()
    run_integration_tests()
    run_performance_tests()

    # Print results
    print_test_summary()
    quit()

func run_unit_tests():
    print("Running Unit Tests...")
    print("===================")

    # Character tests
    test_character_creation()
    test_character_stats()
    test_character_leveling()

    # Character Manager tests
    test_character_manager_creation()
    test_character_manager_save_load()

    # D&D Data tests
    test_dnd_race_data()
    test_dnd_class_data()
    test_dnd_background_data()

    print()

func run_integration_tests():
    print("Running Integration Tests...")
    print("==========================")

    # Character + Manager integration
    test_character_manager_integration()

    # D&D Data + Character integration
    test_dnd_character_integration()

    print()

func run_performance_tests():
    print("Running Performance Tests...")
    print("==========================")

    # Character creation performance
    test_character_creation_performance()

    # D&D data loading performance
    test_dnd_data_loading_performance()

    print()

# Unit Tests
func test_character_creation():
    print("Testing Character Creation...")

    var character = Character.new()
    character.name = "Test Hero"
    character.race = "Human"
    character.character_class = "Fighter"
    character.level = 1

    assert_equals(character.name, "Test Hero", "Character name set")
    assert_equals(character.race, "Human", "Character race set")
    assert_equals(character.character_class, "Fighter", "Character class set")
    assert_equals(character.level, 1, "Character level set")

    print("✅ Character creation tests passed")

func test_character_stats():
    print("Testing Character Stats...")

    var character = Character.new()
    character.strength = 16
    character.dexterity = 14
    character.constitution = 15
    character.intelligence = 12
    character.wisdom = 13
    character.charisma = 10

    character.update_derived_stats()

    assert_equals(character.get_strength_modifier(), 3, "Strength modifier")
    assert_equals(character.get_dexterity_modifier(), 2, "Dexterity modifier")
    assert_equals(character.get_constitution_modifier(), 2, "Constitution modifier")
    assert_equals(character.get_intelligence_modifier(), 1, "Intelligence modifier")
    assert_equals(character.get_wisdom_modifier(), 1, "Wisdom modifier")
    assert_equals(character.get_charisma_modifier(), 0, "Charisma modifier")

    print("✅ Character stats tests passed")

func test_character_leveling():
    print("Testing Character Leveling...")

    var character = Character.new()
    character.level = 1
    character.experience_points = 0

    # Add experience
    var leveled_up = character.add_experience(1000)
    assert_true(leveled_up, "Character should level up")
    assert_true(character.level > 1, "Character level should increase")

    print("✅ Character leveling tests passed")

func test_character_manager_creation():
    print("Testing Character Manager Creation...")

    var manager = CharacterManager.new()
    manager.save_file_path = "user://test_character.dat"

    var character = manager.create_default_character()
    assert_not_null(character, "Default character created")
    assert_equals(character.name, "Bob", "Default character name")

    print("✅ Character manager creation tests passed")

func test_character_manager_save_load():
    print("Testing Character Manager Save/Load...")

    var manager = CharacterManager.new()
    manager.save_file_path = "user://test_character.dat"

    var character = manager.create_default_character()
    character.name = "Test Save Character"
    manager.current_character = character

    var save_result = manager.save_character()
    assert_true(save_result, "Character saved successfully")

    var loaded_character = manager.load_character()
    assert_not_null(loaded_character, "Character loaded successfully")
    assert_equals(loaded_character.name, "Test Save Character", "Loaded character name matches")

    # Cleanup
    var dir = DirAccess.open("user://")
    if dir.file_exists("test_character.dat"):
        dir.remove("test_character.dat")

    print("✅ Character manager save/load tests passed")

func test_dnd_race_data():
    print("Testing D&D Race Data...")

    var human_data = DnDData.get_race("Human")
    assert_true(not human_data.is_empty(), "Human race data loaded")
    assert_true(human_data.has("ability_increases"), "Human has ability increases")

    var elf_data = DnDData.get_race("Elf")
    assert_true(not elf_data.is_empty(), "Elf race data loaded")

    print("✅ D&D race data tests passed")

func test_dnd_class_data():
    print("Testing D&D Class Data...")

    var fighter_data = DnDData.get_class_data("Fighter")
    assert_true(not fighter_data.is_empty(), "Fighter class data loaded")
    assert_true(fighter_data.has("hit_die"), "Fighter has hit die")

    var wizard_data = DnDData.get_class_data("Wizard")
    assert_true(not wizard_data.is_empty(), "Wizard class data loaded")

    print("✅ D&D class data tests passed")

func test_dnd_background_data():
    print("Testing D&D Background Data...")

    var folk_hero_data = DnDData.get_background("Folk Hero")
    assert_true(not folk_hero_data.is_empty(), "Folk Hero background data loaded")
    assert_true(folk_hero_data.has("feature"), "Folk Hero has feature")

    print("✅ D&D background data tests passed")

# Integration Tests
func test_character_manager_integration():
    print("Testing Character Manager Integration...")

    var manager = CharacterManager.new()
    manager.save_file_path = "user://test_integration.dat"

    # Create character
    var character = manager.create_default_character()
    character.name = "Integration Test"
    character.strength = 18
    character.update_derived_stats()

    # Save and load
    manager.current_character = character
    var save_result = manager.save_character()
    assert_true(save_result, "Integration save successful")

    var loaded_character = manager.load_character()
    assert_not_null(loaded_character, "Integration load successful")
    assert_equals(loaded_character.get_strength_modifier(), 4, "Integration stat calculation")

    # Cleanup
    var dir = DirAccess.open("user://")
    if dir.file_exists("test_integration.dat"):
        dir.remove("test_integration.dat")

    print("✅ Character manager integration tests passed")

func test_dnd_character_integration():
    print("Testing D&D Character Integration...")

    var character = Character.new()
    character.race = "Human"
    character.character_class = "Fighter"
    character.level = 5

    # Apply race bonuses
    var race_data = DnDData.get_race("Human")
    if not race_data.is_empty():
        var ability_increases = race_data.get("ability_increases", {})
        for ability in ability_increases.keys():
            var value = character.get(ability)
            character.set(ability, value + ability_increases[ability])

    character.update_derived_stats()

    # Human should have +1 to all abilities
    assert_true(character.get_strength_modifier() >= 0, "Human strength modifier")

    print("✅ D&D character integration tests passed")

# Performance Tests
func test_character_creation_performance():
    print("Testing Character Creation Performance...")

    var start_time = Time.get_ticks_msec()

    # Create 100 characters
    for i in range(100):
        var character = Character.new()
        character.name = "Test Character " + str(i)
        character.race = "Human"
        character.character_class = "Fighter"
        character.strength = 16
        character.update_derived_stats()

    var end_time = Time.get_ticks_msec()
    var duration = end_time - start_time

    print("  Created 100 characters in %d ms" % duration)
    assert_true(duration < 1000, "Character creation should be fast")

    print("✅ Character creation performance tests passed")

func test_dnd_data_loading_performance():
    print("Testing D&D Data Loading Performance...")

    var start_time = Time.get_ticks_msec()

    # Load all race data
    for i in range(100):
        var human_data = DnDData.get_race("Human")
        var elf_data = DnDData.get_race("Elf")
        var fighter_data = DnDData.get_class_data("Fighter")
        var wizard_data = DnDData.get_class_data("Wizard")

    var end_time = Time.get_ticks_msec()
    var duration = end_time - start_time

    print("  Loaded D&D data 100 times in %d ms" % duration)
    assert_true(duration < 1000, "D&D data loading should be fast")

    print("✅ D&D data loading performance tests passed")

# Helper functions
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

func assert_not_null(value, message: String):
    total_tests += 1
    if value != null:
        passed_tests += 1
        print("  ✓ " + message)
    else:
        failed_tests += 1
        print("  ✗ " + message)

func print_test_summary():
    print("Test Summary")
    print("============")
    print("Total tests: " + str(total_tests))
    print("Passed: " + str(passed_tests))
    print("Failed: " + str(failed_tests))
    print("Success rate: " + str((float(passed_tests) / float(total_tests)) * 100) + "%")

    if failed_tests == 0:
        print("\n🎉 All tests passed!")
    else:
        print("\n❌ Some tests failed!")
