extends GutTest

var character_manager: CharacterManager
var test_save_path = "user://test_character_save.dat"

func before_each():
    character_manager = CharacterManager.new()
    character_manager.save_file_path = test_save_path

func after_each():
    # Clean up test save file
    if FileAccess.file_exists(test_save_path):
        var dir = DirAccess.open("user://")
        dir.remove(test_save_path)

func test_character_creation():
    # Test creating a new character
    var character = character_manager.create_character("Test Hero", "Human", "Barbarian", "Folk Hero")

    assert_not_null(character, "Character should be created")
    assert_eq(character.name, "Test Hero", "Character name should be set")
    assert_eq(character.race, "Human", "Character race should be set")
    assert_eq(character.character_class, "Barbarian", "Character class should be set")
    assert_eq(character.background, "Folk Hero", "Character background should be set")

    # Test that character is set as current
    assert_eq(character_manager.get_current_character(), character, "Created character should be current")

func test_race_bonuses():
    # Test that race bonuses are applied
    var character = character_manager.create_character("Test", "Elf", "Barbarian", "Folk Hero")

    # Elf should get +2 to Dexterity
    assert_ge(character.dexterity, 12, "Elf should get dexterity bonus")

    # Test Human gets +1 to all abilities
    var human_character = character_manager.create_character("Test", "Human", "Barbarian", "Folk Hero")
    assert_ge(human_character.strength, 11, "Human should get strength bonus")
    assert_ge(human_character.dexterity, 11, "Human should get dexterity bonus")
    assert_ge(human_character.constitution, 11, "Human should get constitution bonus")

func test_class_features():
    # Test that class features are applied
    var character = character_manager.create_character("Test", "Human", "Barbarian", "Folk Hero")

    # Barbarian should have strength and constitution saving throws
    assert_true(character.skill_proficiencies.size() > 0, "Character should have skill proficiencies")

    # Test that character has armor proficiencies
    assert_gt(character.armor_proficiencies.size(), 0, "Character should have armor proficiencies")

func test_background_features():
    # Test that background features are applied
    var character = character_manager.create_character("Test", "Human", "Barbarian", "Acolyte")

    # Acolyte should have Insight and Religion proficiencies
    assert_true(character.skill_proficiencies.has("Insight"), "Acolyte should have Insight proficiency")
    assert_true(character.skill_proficiencies.has("Religion"), "Acolyte should have Religion proficiency")

func test_save_and_load():
    # Test saving character
    var character = character_manager.create_character("Save Test", "Human", "Barbarian", "Folk Hero")
    character.add_gold(100)
    character.add_experience(500)

    var save_success = character_manager.save_character()
    assert_true(save_success, "Character should save successfully")

    # Test loading character
    var new_manager = CharacterManager.new()
    new_manager.save_file_path = test_save_path
    var load_success = new_manager.load_character()

    assert_true(load_success, "Character should load successfully")
    var loaded_character = new_manager.get_current_character()

    assert_not_null(loaded_character, "Loaded character should exist")
    assert_eq(loaded_character.name, "Save Test", "Loaded character name should match")
    assert_eq(loaded_character.gold, 100, "Loaded character gold should match")
    assert_eq(loaded_character.experience_points, 500, "Loaded character XP should match")

func test_save_file_detection():
    # Test detecting save file existence
    assert_false(character_manager.has_save_file(), "Should not have save file initially")

    # Create and save a character
    var _character = character_manager.create_character("Test", "Human", "Barbarian", "Folk Hero")
    character_manager.save_character()

    assert_true(character_manager.has_save_file(), "Should have save file after saving")

func test_default_character():
    # Test creating default character
    var character = character_manager.create_default_character()

    assert_not_null(character, "Default character should be created")
    assert_eq(character.name, "Bob", "Default character should be named Bob")
    assert_eq(character.race, "Human", "Default character should be Human")
    assert_eq(character.character_class, "Barbarian", "Default character should be Barbarian")
