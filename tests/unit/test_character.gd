extends TestBase

var character: Character

func before_each():
    character = Character.new()

func test_character_initialization():
    assert_not_null(character, "Character should be initialized")
    assert_eq(character.name, "", "Character name should be empty initially")
    assert_eq(character.level, 1, "Character should start at level 1")
    assert_eq(character.experience_points, 0, "Character should start with 0 XP")

func test_ability_modifiers():
    # Test ability score modifiers
    character.strength = 15
    assert_eq(character.get_strength_modifier(), 2, "Strength 15 should have +2 modifier")

    character.dexterity = 8
    assert_eq(character.get_dexterity_modifier(), -1, "Dexterity 8 should have -1 modifier")

    character.constitution = 10
    assert_eq(character.get_constitution_modifier(), 0, "Constitution 10 should have +0 modifier")

func test_experience_and_leveling():
    # Test level calculation
    assert_eq(character.calculate_level_from_xp(0), 1, "0 XP should be level 1")
    assert_eq(character.calculate_level_from_xp(300), 2, "300 XP should be level 2")
    assert_eq(character.calculate_level_from_xp(900), 3, "900 XP should be level 3")

    # Test adding experience
    var leveled_up = character.add_experience(300)
    assert_true(leveled_up, "Adding 300 XP should level up")
    assert_eq(character.level, 2, "Character should be level 2 after adding 300 XP")

func test_activity_system():
    # Test starting an activity
    character.start_activity("Push a Rock", 60.0)
    assert_eq(character.current_activity, "Push a Rock", "Current activity should be set")
    assert_gt(character.activity_start_time, 0, "Activity start time should be set")
    assert_eq(character.activity_duration, 60.0, "Activity duration should be set")

    # Test activity completion check
    assert_false(character.is_activity_complete(), "Activity should not be complete immediately")

    # Test completing activity
    character.complete_activity()
    assert_eq(character.current_activity, "", "Activity should be cleared after completion")

func test_gold_management():
    # Test adding gold
    character.add_gold(100)
    assert_eq(character.gold, 100, "Gold should be added correctly")

    # Test spending gold
    var success = character.spend_gold(50)
    assert_true(success, "Should be able to spend 50 gold")
    assert_eq(character.gold, 50, "Gold should be reduced after spending")

    # Test insufficient gold
    success = character.spend_gold(100)
    assert_false(success, "Should not be able to spend more gold than available")
    assert_eq(character.gold, 50, "Gold should remain unchanged if insufficient")

func test_derived_stats_update():
    character.strength = 15
    character.constitution = 14
    character.level = 2
    character.update_derived_stats()

    assert_eq(character.proficiency_bonus, 2, "Proficiency bonus should be 2 at level 2")
    assert_gt(character.max_hit_points, 0, "Max hit points should be calculated")
    assert_gt(character.armor_class, 0, "Armor class should be calculated")
