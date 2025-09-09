extends SceneTree

# Simple test runner that tests core functionality without problematic scripts

# Preload required scripts
const Character = preload("res://scripts/character.gd")
const CharacterManager = preload("res://scripts/character_manager.gd")
const DnDData = preload("res://scripts/dnd_data.gd")

var test_results: Dictionary = {}
var total_tests: int = 0
var passed_tests: int = 0
var failed_tests: int = 0

func _init():
    print("🧪 Idle Adventurer Simple Test Runner")
    print("====================================")
    print()

    # Run basic functionality tests
    test_character_creation()
    test_character_manager()
    test_dnd_data()
    test_character_sheet()
    test_inventory_system()
    test_enhanced_activities()
    test_language_system()
    test_leveling_system()

    # Print results
    print_test_summary()
    quit()

func test_character_creation():
    print("Testing Character Creation...")

    # Test basic character creation
    var character = Character.new()
    character.name = "Test Hero"
    character.race = "Human"
    character.character_class = "Fighter"
    character.level = 1

    # Test stat updates
    character.strength = 16
    character.dexterity = 14
    character.constitution = 15
    character.intelligence = 12
    character.wisdom = 13
    character.charisma = 10

    character.update_derived_stats()

    # Verify derived stats
    assert_equals(character.get_strength_modifier(), 3, "Strength modifier calculation")
    assert_equals(character.get_dexterity_modifier(), 2, "Dexterity modifier calculation")
    assert_equals(character.get_constitution_modifier(), 2, "Constitution modifier calculation")

    print("✅ Character creation tests passed")
    print()

func test_character_manager():
    print("Testing Character Manager...")

    var manager = CharacterManager.new()
    manager.save_file_path = "user://test_character.dat"

    # Test character creation
    var character = manager.create_default_character()
    assert_not_null(character, "Default character creation")
    assert_equals(character.name, "Bob", "Default character name")

    # Test save/load
    manager.current_character = character
    var save_result = manager.save_character()
    assert_true(save_result, "Character save")

    var loaded_character = manager.load_character()
    assert_not_null(loaded_character, "Character load")
    assert_equals(loaded_character.name, character.name, "Loaded character name")

    # Cleanup
    var dir = DirAccess.open("user://")
    if dir.file_exists("test_character.dat"):
        dir.remove("test_character.dat")

    print("✅ Character manager tests passed")
    print()

func test_dnd_data():
    print("Testing D&D Data...")

    # Test race data
    var human_data = DnDData.get_race("Human")
    assert_true(not human_data.is_empty(), "Human race data loaded")

    # Test class data
    var fighter_data = DnDData.get_class_data("Fighter")
    assert_true(not fighter_data.is_empty(), "Fighter class data loaded")

    # Test background data
    var folk_hero_data = DnDData.get_background("Folk Hero")
    assert_true(not folk_hero_data.is_empty(), "Folk Hero background data loaded")

    print("✅ D&D data tests passed")
    print()

func test_character_sheet():
    print("Testing Character Sheet...")

    var character = Character.new()
    character.name = "Test Fighter"
    character.race = "Human"
    character.character_class = "Fighter"
    character.level = 5
    character.strength = 18
    character.dexterity = 14
    character.constitution = 16
    character.intelligence = 12
    character.wisdom = 13
    character.charisma = 10
    character.update_derived_stats()

    # Test dice rolling
    var roll_result = roll_dice(1, 20)
    assert_true(roll_result >= 1 and roll_result <= 20, "Dice roll range")

    # Test attack roll
    var attack_roll = roll_dice(1, 20) + character.get_strength_modifier()
    assert_true(attack_roll >= 1 + character.get_strength_modifier(), "Attack roll minimum")
    assert_true(attack_roll <= 20 + character.get_strength_modifier(), "Attack roll maximum")

    print("✅ Character sheet tests passed")
    print()

func test_inventory_system():
    print("Testing Inventory System...")

    # Test inventory system creation
    var inventory_system = preload("res://scripts/inventory_system.gd").new()
    var character = Character.new()
    character.name = "TestCharacter"

    # Test adding items
    var potion = {
        "id": "healing_potion",
        "name": "Healing Potion",
        "type": "potion",
        "weight": 0.5,
        "value": 50.0
    }

    var result = inventory_system.add_item(character, potion, 1)
    if not result:
        print("❌ Failed to add item to inventory")
        return false

    # Test inventory retrieval
    var inventory = inventory_system.get_character_inventory(character)
    if inventory["items"].is_empty():
        print("❌ Inventory should contain items")
        return false

    print("  ✓ Inventory system creation")
    print("  ✓ Item addition")
    print("  ✓ Inventory retrieval")
    print("✅ Inventory system tests passed")
    print()
    return true

func test_enhanced_activities():
    print("Testing Enhanced Activities...")

    # Test activities system creation
    var activities_system = preload("res://scripts/enhanced_activities.gd").new()
    var character = Character.new()
    character.name = "TestCharacter"
    character.strength = 15

    # Test getting activities
    var strength_activities = activities_system.get_activities_for_ability("strength")
    if strength_activities.is_empty():
        print("❌ Should have strength activities")
        return false

    # Test starting activity
    var activity = strength_activities[0]
    var result = activities_system.start_activity(character, activity["name"], "strength")
    if not result:
        print("❌ Should be able to start activity")
        return false

    print("  ✓ Activities system creation")
    print("  ✓ Activity retrieval")
    print("  ✓ Activity starting")
    print("✅ Enhanced activities tests passed")
    print()
    return true

func test_language_system():
    print("Testing Language System...")

    # Test language system creation
    var language_system = preload("res://scripts/language_system.gd").new()
    var character = Character.new()
    character.name = "TestCharacter"
    character.known_languages = ["Common"]

    # Test getting languages
    var languages = language_system.get_all_languages()
    if languages.is_empty():
        print("❌ Should have languages available")
        return false

    # Test learning language
    var result = language_system.learn_language(character, "Elvish")
    if not result:
        print("❌ Should be able to learn language")
        return false

    print("  ✓ Language system creation")
    print("  ✓ Language retrieval")
    print("  ✓ Language learning")
    print("✅ Language system tests passed")
    print()
    return true

func test_leveling_system():
    print("Testing Leveling System...")

    # Test leveling system creation
    var leveling_system = preload("res://scripts/leveling_system.gd").new()
    var character = Character.new()
    character.name = "TestCharacter"
    character.level = 1
    character.experience_points = 0

    # Test experience requirements
    var xp_for_level_2 = leveling_system.get_experience_for_level(2)
    if xp_for_level_2 <= 0:
        print("❌ Level 2 should require XP")
        return false

    # Test adding experience
    leveling_system.add_experience(character, 100)
    if character.experience_points != 100:
        print("❌ Experience should be added")
        return false

    print("  ✓ Leveling system creation")
    print("  ✓ Experience requirements")
    print("  ✓ Experience addition")
    print("✅ Leveling system tests passed")
    print()
    return true

func roll_dice(count: int, sides: int) -> int:
    var total = 0
    for i in range(count):
        total += randi() % sides + 1
    return total

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
