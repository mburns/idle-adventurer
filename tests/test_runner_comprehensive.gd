extends Node

# Comprehensive test runner for Idle Adventurer
# Runs all tests and provides detailed reporting

var test_results = []
var total_tests = 0
var passed_tests = 0
var failed_tests = 0

func _ready():
    print("=== Idle Adventurer Test Suite ===")
    print("Starting comprehensive test run...")

    # Run all test categories
    run_character_tests()
    run_system_tests()
    run_data_tests()
    run_integration_tests()

    # Print results
    print_test_summary()

func run_character_tests():
    """Run all character-related tests"""
    print("\n--- Character Tests ---")

    # Test character creation
    test_character_creation()

    # Test character progression
    test_character_progression()

    # Test character saving/loading
    test_character_persistence()

func run_system_tests():
    """Run all system tests"""
    print("\n--- System Tests ---")

    # Test idle mechanics
    test_idle_mechanics()

    # Test equipment system
    test_equipment_system()

    # Test faction system
    test_faction_system()

    # Test quest system
    test_quest_system()

func run_data_tests():
    """Run all data loading tests"""
    print("\n--- Data Tests ---")

    # Test data loading
    test_data_loading()

    # Test data validation
    test_data_validation()

func run_integration_tests():
    """Run integration tests"""
    print("\n--- Integration Tests ---")

    # Test full game flow
    test_full_game_flow()

func test_character_creation():
    """Test character creation functionality"""
    var test_name = "Character Creation"

    # Test basic character creation
    var character = Character.new()
    assert(character != null, "Character should be created")

    # Test character with class
    character.set_class("Fighter")
    assert(character.character_class == "Fighter", "Character class should be set")

    # Test character with race
    character.set_race("Human")
    assert(character.race == "Human", "Character race should be set")

    record_test_result(test_name, true, "Character creation successful")

func test_character_progression():
    """Test character progression system"""
    var test_name = "Character Progression"

    var character = Character.new()
    character.set_class("Fighter")
    character.set_race("Human")

    # Test leveling up
    var initial_level = character.level
    character.add_experience(1000)
    assert(character.level > initial_level, "Character should level up")

    # Test ability score improvements
    var initial_strength = character.ability_scores["Strength"]
    character.improve_ability_score("Strength", 2)
    assert(character.ability_scores["Strength"] > initial_strength, "Ability score should improve")

    record_test_result(test_name, true, "Character progression successful")

func test_character_persistence():
    """Test character saving and loading"""
    var test_name = "Character Persistence"

    var character = Character.new()
    character.set_class("Wizard")
    character.set_race("Elf")
    character.add_experience(500)

    # Test saving
    var save_data = character.to_dict()
    assert(save_data != null, "Character should save to dict")

    # Test loading
    var new_character = Character.new()
    new_character.from_dict(save_data)
    assert(new_character.character_class == "Wizard", "Character should load correctly")
    assert(new_character.race == "Elf", "Character race should load correctly")

    record_test_result(test_name, true, "Character persistence successful")

func test_idle_mechanics():
    """Test idle mechanics system"""
    var test_name = "Idle Mechanics"

    var idle_mechanics = IdleMechanics.new()
    assert(idle_mechanics != null, "Idle mechanics should be created")

    # Test activity processing
    var character = Character.new()
    character.set_class("Fighter")

    var activity = idle_mechanics.get_activity("Strength Training")
    assert(activity != null, "Activity should be found")

    # Test activity completion
    var result = idle_mechanics.complete_activity(character, "Strength Training", 1.0)
    assert(result != null, "Activity should complete successfully")

    record_test_result(test_name, true, "Idle mechanics successful")

func test_equipment_system():
    """Test equipment system"""
    var test_name = "Equipment System"

    var equipment_system = EquipmentSystem.new()
    assert(equipment_system != null, "Equipment system should be created")

    # Test equipment loading
    var sword = equipment_system.get_equipment("Longsword")
    assert(sword != null, "Equipment should be loaded")

    # Test equipment stats
    assert(sword.has("damage"), "Equipment should have damage")
    assert(sword.has("cost"), "Equipment should have cost")

    record_test_result(test_name, true, "Equipment system successful")

func test_faction_system():
    """Test faction system"""
    var test_name = "Faction System"

    var faction_system = FactionSystem.new()
    assert(faction_system != null, "Faction system should be created")

    # Test faction loading
    var factions = faction_system.get_all_factions()
    assert(factions.size() > 0, "Factions should be loaded")

    # Test reputation tracking
    var character = Character.new()
    faction_system.add_reputation(character, "Guild of Merchants", 10)
    var reputation = faction_system.get_reputation(character, "Guild of Merchants")
    assert(reputation == 10, "Reputation should be tracked")

    record_test_result(test_name, true, "Faction system successful")

func test_quest_system():
    """Test quest system"""
    var test_name = "Quest System"

    var quest_system = QuestSystem.new()
    assert(quest_system != null, "Quest system should be created")

    # Test quest generation
    var character = Character.new()
    character.set_class("Fighter")
    character.set_level(5)

    var quests = quest_system.get_available_quests(character)
    assert(quests.size() > 0, "Quests should be available")

    # Test quest completion
    var quest = quests[0]
    var result = quest_system.complete_quest(character, quest)
    assert(result != null, "Quest should complete successfully")

    record_test_result(test_name, true, "Quest system successful")

func test_data_loading():
    """Test data loading from JSON files"""
    var test_name = "Data Loading"

    var data_loader = DataLoader.new()
    assert(data_loader != null, "Data loader should be created")

    # Test loading classes
    var classes = data_loader.get_class_names()
    assert(classes.size() > 0, "Classes should be loaded")

    # Test loading races
    var races = data_loader.get_race_names()
    assert(races.size() > 0, "Races should be loaded")

    # Test loading spells
    var spells = data_loader.get_spell_names()
    assert(spells.size() > 0, "Spells should be loaded")

    record_test_result(test_name, true, "Data loading successful")

func test_data_validation():
    """Test data validation"""
    var test_name = "Data Validation"

    var data_loader = DataLoader.new()

    # Test class data validation
    var fighter_data = data_loader.get_class_data("Fighter")
    assert(fighter_data.has("name"), "Class data should have name")
    assert(fighter_data.has("hit_dice"), "Class data should have hit_dice")
    assert(fighter_data.has("proficiencies"), "Class data should have proficiencies")

    # Test race data validation
    var human_data = data_loader.get_race_data("Human")
    assert(human_data.has("name"), "Race data should have name")
    assert(human_data.has("traits"), "Race data should have traits")

    record_test_result(test_name, true, "Data validation successful")

func test_full_game_flow():
    """Test complete game flow"""
    var test_name = "Full Game Flow"

    # Create character
    var character = Character.new()
    character.set_class("Wizard")
    character.set_race("Elf")

    # Add equipment
    var equipment_system = EquipmentSystem.new()
    var staff = equipment_system.get_equipment("Quarterstaff")
    character.equip_item(staff)

    # Complete activity
    var idle_mechanics = IdleMechanics.new()
    idle_mechanics.complete_activity(character, "Study Magic", 1.0)

    # Gain faction reputation
    var faction_system = FactionSystem.new()
    faction_system.add_reputation(character, "Arcane Society", 15)

    # Complete quest
    var quest_system = QuestSystem.new()
    var quests = quest_system.get_available_quests(character)
    if quests.size() > 0:
        quest_system.complete_quest(character, quests[0])

    # Save character
    var save_data = character.to_dict()
    assert(save_data != null, "Character should save successfully")

    record_test_result(test_name, true, "Full game flow successful")

func record_test_result(test_name: String, passed: bool, message: String):
    """Record the result of a test"""
    total_tests += 1
    if passed:
        passed_tests += 1
        print("✓ " + test_name + ": " + message)
    else:
        failed_tests += 1
        print("✗ " + test_name + ": " + message)

    test_results.append({
        "name": test_name,
        "passed": passed,
        "message": message
    })

func print_test_summary():
    """Print test summary"""
    print("\n=== Test Summary ===")
    print("Total Tests: " + str(total_tests))
    print("Passed: " + str(passed_tests))
    print("Failed: " + str(failed_tests))
    print("Success Rate: " + str((float(passed_tests) / float(total_tests)) * 100) + "%")

    if failed_tests > 0:
        print("\nFailed Tests:")
        for result in test_results:
            if not result.passed:
                print("  - " + result.name + ": " + result.message)

    print("\n=== Test Complete ===")
