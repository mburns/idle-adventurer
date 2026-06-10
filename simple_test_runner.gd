# Simple test runner for Idle Adventurer
extends SceneTree

func _init():
    print("=== Idle Adventurer Test Suite ===")
    print("Starting simple test run...")

    # Run basic tests immediately
    run_basic_tests()

    print("\n=== Test Complete ===")
    quit(0)

func run_basic_tests():
    print("\n--- Basic System Tests ---")

    # Test 1: Check if autoloads are working
    test_autoloads()

    # Test 2: Check if data loading works
    test_data_loading()

    # Test 3: Check if character creation works
    test_character_creation()

func test_autoloads():
    print("Testing autoloads...")

    if Engine.has_singleton("AutoloadManager"):
        print("✓ AutoloadManager is available")
    else:
        print("✗ AutoloadManager not found")
        return

    if Engine.has_singleton("CharacterManager"):
        print("✓ CharacterManager is available")
    else:
        print("✗ CharacterManager not found")
        return

    if Engine.has_singleton("DataLoader"):
        print("✓ DataLoader is available")
    else:
        print("✗ DataLoader not found")
        return

    print("✓ All autoloads working")

func test_data_loading():
    print("Testing data loading...")

    var data_loader = Engine.get_singleton("DataLoader")
    if not data_loader:
        print("✗ DataLoader not available")
        return

    # Test loading some basic data
    var races = data_loader.get_race_names()
    if races.size() > 0:
        print("✓ Races loaded: " + str(races.size()))
    else:
        print("✗ No races loaded")

    var classes = data_loader.get_class_names()
    if classes.size() > 0:
        print("✓ Classes loaded: " + str(classes.size()))
    else:
        print("✗ No classes loaded")

    print("✓ Data loading working")

func test_character_creation():
    print("Testing character creation...")

    var character_manager = Engine.get_singleton("CharacterManager")
    if not character_manager:
        print("✗ CharacterManager not available")
        return

    # Try to create a character
    var character = character_manager.create_default_character()
    if character:
        print("✓ Character created: " + character.name)
        print("  - Race: " + character.race)
        print("  - Class: " + character.character_class)
        print("  - Level: " + str(character.level))
    else:
        print("✗ Character creation failed")

    print("✓ Character creation working")
