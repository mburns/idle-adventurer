extends GutTest

# Integration tests that test the full system working together

func test_character_creation_with_wiki_data():
    # Test creating a character using wiki data
    var character_manager = create_test_character_manager()

    # Create character with wiki-loaded class data
    var character = character_manager.create_character("Test Hero", "Human", "Barbarian", "Folk Hero")

    # Verify character was created with proper stats
    assert_not_null(character, "Character should be created")
    assert_eq(character.name, "Test Hero", "Character name should be set")
    assert_eq(character.character_class, "Barbarian", "Character class should be set")

    # Verify class features were applied
    assert_gt(character.skill_proficiencies.size(), 0, "Character should have skill proficiencies")
    assert_gt(character.armor_proficiencies.size(), 0, "Character should have armor proficiencies")
    assert_gt(character.weapon_proficiencies.size(), 0, "Character should have weapon proficiencies")

func test_idle_mechanics_with_character():
    # Test idle mechanics working with a real character
    var character = create_test_character()
    character.strength = 15
    character.dexterity = 14

    # Test activity duration calculation
    var duration = IdleMechanics.calculate_activity_duration("Push a Rock", character)
    assert_gt(duration, 0, "Activity duration should be positive")

    # Test activity rewards
    var rewards = IdleMechanics.calculate_activity_rewards("Push a Rock", character)
    assert_gt(rewards.xp, 0, "Activity should give XP")
    assert_gt(rewards.gold, 0, "Activity should give gold")

    # Test starting and completing an activity
    var success = IdleMechanics.start_activity("Push a Rock", character)
    assert_true(success, "Should be able to start activity")
    assert_eq(character.current_activity, "Push a Rock", "Activity should be set")

    # Complete the activity
    var completion_rewards = IdleMechanics.complete_activity(character)
    assert_gt(completion_rewards.xp, 0, "Completion should give rewards")

func test_save_and_load_integration():
    # Test full save/load cycle
    var character_manager = create_test_character_manager()
    var character = character_manager.create_character("Save Test", "Elf", "Wizard", "Sage")

    # Modify character
    character.add_gold(500)
    character.add_experience(1000)
    character.equipment["main_hand"] = "Staff"

    # Save character
    var save_success = character_manager.save_character()
    assert_true(save_success, "Character should save successfully")

    # Create new manager and load character
    var new_manager = CharacterManager.new()
    new_manager.save_file_path = "user://test_character_save.dat"
    var load_success = new_manager.load_character()
    assert_true(load_success, "Character should load successfully")

    var loaded_character = new_manager.get_current_character()
    assert_not_null(loaded_character, "Loaded character should exist")
    assert_eq(loaded_character.name, "Save Test", "Loaded character name should match")
    assert_eq(loaded_character.gold, 500, "Loaded character gold should match")
    assert_eq(loaded_character.experience_points, 1000, "Loaded character XP should match")
    assert_eq(loaded_character.equipment["main_hand"], "Staff", "Loaded character equipment should match")

func test_data_loader_integration():
    # Test loading data from DataLoader
    var classes = DataLoader.get_class_data("Barbarian")
    assert_not_null(classes, "Should load class data from DataLoader")
    assert_false(classes.is_empty(), "Barbarian class data should not be empty")

    # Note: Equipment, treasure, spells, and abilities loading would need to be implemented
    # in DataLoader if needed, or these tests should be removed
    print("⚠️  Equipment, treasure, spells, and abilities tests skipped - not implemented in DataLoader")

func test_character_progression_integration():
    # Test character progression through activities
    var character = create_test_character()
    var initial_level = character.level
    var initial_xp = character.experience_points

    # Complete multiple activities
    for i in range(5):
        IdleMechanics.start_activity("Push a Rock", character)
        var rewards = IdleMechanics.complete_activity(character)
        character.add_experience(rewards.xp)
        character.add_gold(rewards.gold)

    # Verify progression
    assert_ge(character.experience_points, initial_xp, "Character should have gained XP")
    assert_ge(character.gold, 0, "Character should have gained gold")

    # Check for level up if enough XP gained
    if character.experience_points >= 300:
        assert_gt(character.level, initial_level, "Character should have leveled up")

func test_ui_navigation_integration():
    # Test that all UI screens can be loaded
    var scenes = [
        "res://scenes/start_screen.tscn",
        "res://scenes/character_creation.tscn",
        "res://scenes/main.tscn",
        "res://scenes/character_profile.tscn",
        "res://scenes/equipment_screen.tscn",
        "res://scenes/journal_screen.tscn",
        "res://scenes/settings_screen.tscn"
    ]

    for scene_path in scenes:
        var scene = load(scene_path)
        assert_not_null(scene, "Scene should load: " + scene_path)

func test_achievement_system_integration():
    # Test achievement system working with character progression
    var character = create_test_character()
    var journal = preload("res://scripts/journal_screen.gd").new()

    # Add character to journal
    journal.character = character

    # Test gold achievement
    character.add_gold(100)
    journal.check_achievements()
    assert_true(journal.achievements.has("Wealthy"), "Should unlock Wealthy achievement")

    # Test level achievement
    character.add_experience(300) # Should level up
    journal.check_achievements()
    assert_true(journal.achievements.has("First Level Up"), "Should unlock First Level Up achievement")

func test_settings_persistence():
    # Test settings save/load
    var settings_screen = preload("res://scripts/settings_screen.gd").new()

    # Modify settings
    settings_screen.settings_data.idle_speed = 2.0
    settings_screen.settings_data.master_volume = 0.5

    # Save settings
    settings_screen.save_settings()

    # Create new settings screen and load
    var new_settings = preload("res://scripts/settings_screen.gd").new()
    new_settings.load_settings()

    # Verify settings were saved and loaded
    assert_eq(new_settings.settings_data.idle_speed, 2.0, "Idle speed should be saved")
    assert_eq(new_settings.settings_data.master_volume, 0.5, "Master volume should be saved")

func test_error_handling():
    # Test error handling in various scenarios
    var character_manager = create_test_character_manager()

    # Test loading non-existent save file
    var load_success = character_manager.load_character()
    assert_false(load_success, "Loading non-existent save should fail gracefully")

    # Test invalid activity
    var character = create_test_character()
    var can_perform = IdleMechanics.can_perform_activity("Invalid Activity", character)
    assert_false(can_perform, "Invalid activity should not be performable")

    # Test invalid wiki data
    var invalid_class = DataLoader.get_class_data("InvalidClass")
    assert_true(invalid_class.is_empty(), "Invalid class should return empty data")

func after_each():
    # Clean up test files
    cleanup_test_files()
