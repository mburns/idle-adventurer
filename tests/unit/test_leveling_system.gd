extends GutTest

# Test suite for the leveling system

var leveling_system: LevelingSystem
var test_character: Character

func before_each():
    leveling_system = LevelingSystem.new()
    test_character = Character.new()
    test_character.name = "TestCharacter"
    test_character.level = 1
    test_character.experience_points = 0

func test_leveling_system_initialization():
    """Test that leveling system initializes correctly"""
    assert_not_null(leveling_system, "Leveling system should be created")

    var max_level = leveling_system.get_max_level()
    assert_eq(max_level, 20, "Max level should be 20")

func test_experience_requirements():
    """Test experience point requirements for each level"""
    # Test level 1 (starting level)
    var xp_for_level_1 = leveling_system.get_experience_for_level(1)
    assert_eq(xp_for_level_1, 0, "Level 1 should require 0 XP")

    # Test level 2
    var xp_for_level_2 = leveling_system.get_experience_for_level(2)
    assert_gt(xp_for_level_2, 0, "Level 2 should require XP")

    # Test level 20 (max level)
    var xp_for_level_20 = leveling_system.get_experience_for_level(20)
    assert_gt(xp_for_level_20, 0, "Level 20 should require XP")
    assert_gt(xp_for_level_20, xp_for_level_2, "Higher levels should require more XP")

    # Test that XP requirements increase exponentially
    var xp_for_level_10 = leveling_system.get_experience_for_level(10)
    var xp_for_level_15 = leveling_system.get_experience_for_level(15)
    assert_gt(xp_for_level_15, xp_for_level_10, "XP requirements should increase")

func test_can_level_up():
    """Test level up eligibility"""
    # Character with no XP should not be able to level up
    assert_false(leveling_system.can_level_up(test_character), "Character with no XP should not level up")

    # Character with enough XP should be able to level up
    test_character.experience_points = leveling_system.get_experience_for_level(2)
    assert_true(leveling_system.can_level_up(test_character), "Character with enough XP should level up")

    # Character at max level should not be able to level up
    test_character.level = 20
    test_character.experience_points = 999999
    assert_false(leveling_system.can_level_up(test_character), "Max level character should not level up")

func test_level_up():
    """Test leveling up a character"""
    test_character.experience_points = leveling_system.get_experience_for_level(2)
    test_character.hit_points = 10
    test_character.max_hit_points = 10

    var initial_level = test_character.level
    var result = leveling_system.level_up(test_character)

    assert_true(result, "Level up should succeed")
    assert_eq(test_character.level, initial_level + 1, "Level should increase by 1")
    assert_gt(test_character.max_hit_points, 10, "Max hit points should increase")

func test_hit_point_increase():
    """Test hit point increase on level up"""
    test_character.constitution = 14 # +2 modifier
    test_character.level = 1
    test_character.max_hit_points = 10
    test_character.experience_points = leveling_system.get_experience_for_level(2)

    var initial_max_hp = test_character.max_hit_points
    leveling_system.level_up(test_character)

    var hp_increase = test_character.max_hit_points - initial_max_hp
    assert_gt(hp_increase, 0, "Hit points should increase")
    # Should be at least 1 + constitution modifier
    assert_ge(hp_increase, 3, "Hit point increase should include constitution bonus")

func test_class_feature_unlocks():
    """Test that class features unlock at appropriate levels"""
    test_character.character_class = "Fighter"
    test_character.level = 1
    test_character.experience_points = leveling_system.get_experience_for_level(2)

    var initial_features = test_character.get("class_features", []).size()
    leveling_system.level_up(test_character)

    var new_features = test_character.get("class_features", []).size()
    assert_ge(new_features, initial_features, "Should have same or more class features")

func test_ability_score_improvements():
    """Test ability score improvements at certain levels"""
    test_character.level = 3
    test_character.experience_points = leveling_system.get_experience_for_level(4)
    test_character.strength = 15

    var initial_strength = test_character.strength
    leveling_system.level_up(test_character)

    # Some classes get ability score improvements at level 4
    if test_character.character_class == "Fighter":
        assert_ge(test_character.strength, initial_strength, "Strength should potentially increase")

func test_proficiency_bonus():
    """Test proficiency bonus calculation"""
    var level_1_bonus = leveling_system.get_proficiency_bonus(1)
    var level_5_bonus = leveling_system.get_proficiency_bonus(5)
    var level_10_bonus = leveling_system.get_proficiency_bonus(10)
    var level_20_bonus = leveling_system.get_proficiency_bonus(20)

    assert_eq(level_1_bonus, 2, "Level 1 should have +2 proficiency bonus")
    assert_eq(level_5_bonus, 3, "Level 5 should have +3 proficiency bonus")
    assert_eq(level_10_bonus, 4, "Level 10 should have +4 proficiency bonus")
    assert_eq(level_20_bonus, 6, "Level 20 should have +6 proficiency bonus")

func test_spell_slot_progression():
    """Test spell slot progression for spellcasting classes"""
    test_character.character_class = "Wizard"
    test_character.level = 1
    test_character.experience_points = leveling_system.get_experience_for_level(2)

    var initial_spell_slots = test_character.get("spell_slots", {}).size()
    leveling_system.level_up(test_character)

    var new_spell_slots = test_character.get("spell_slots", {}).size()
    assert_ge(new_spell_slots, initial_spell_slots, "Spell slots should increase or stay same")

func test_experience_gain():
    """Test gaining experience points"""
    var initial_xp = test_character.experience_points
    var gained_xp = 100

    leveling_system.add_experience(test_character, gained_xp)

    assert_eq(test_character.experience_points, initial_xp + gained_xp, "Experience should increase")

    # Test that level up happens automatically if enough XP
    test_character.experience_points = leveling_system.get_experience_for_level(2) - 50
    var initial_level = test_character.level

    leveling_system.add_experience(test_character, 100)

    assert_gt(test_character.level, initial_level, "Should level up automatically")

func test_multiple_level_ups():
    """Test multiple level ups in sequence"""
    test_character.experience_points = leveling_system.get_experience_for_level(5)
    test_character.level = 1

    var initial_level = test_character.level
    leveling_system.process_level_ups(test_character)

    assert_gt(test_character.level, initial_level, "Should level up multiple times")
    assert_le(test_character.level, 5, "Should not exceed the XP level")

func test_level_cap_enforcement():
    """Test that level 20 cap is enforced"""
    test_character.level = 20
    test_character.experience_points = 999999

    var result = leveling_system.level_up(test_character)
    assert_false(result, "Should not be able to level up past 20")
    assert_eq(test_character.level, 20, "Level should remain 20")

func test_experience_overflow():
    """Test handling of experience overflow"""
    test_character.level = 20
    test_character.experience_points = leveling_system.get_experience_for_level(20)

    leveling_system.add_experience(test_character, 1000)

    # Experience should still be added even at max level
    assert_gt(test_character.experience_points, leveling_system.get_experience_for_level(20), "Should track excess XP")

func test_class_specific_leveling():
    """Test class-specific leveling features"""
    var classes = ["Fighter", "Wizard", "Rogue", "Cleric", "Ranger"]

    for class_name in classes:
        test_character.character_class = class_name
        test_character.level = 1
        test_character.experience_points = leveling_system.get_experience_for_level(2)

        var initial_level = test_character.level
        var result = leveling_system.level_up(test_character)

        assert_true(result, "Should level up " + class_name )
        assert_eq(test_character.level, initial_level + 1, "Level should increase for " + class_name )

func test_leveling_signals():
    """Test that leveling signals are emitted correctly"""
    var level_up_called = false
    var experience_gained_called = false

    leveling_system.level_up_completed.connect(func(_char, _new_level): level_up_called = true)
    leveling_system.experience_gained.connect(func(_char, _amount): experience_gained_called = true)

    # Add experience
    leveling_system.add_experience(test_character, 100)
    assert_true(experience_gained_called, "experience_gained signal should be emitted")

    # Level up
    test_character.experience_points = leveling_system.get_experience_for_level(2)
    leveling_system.level_up(test_character)
    assert_true(level_up_called, "level_up_completed signal should be emitted")

func test_leveling_requirements():
    """Test leveling requirements and prerequisites"""
    # Test that character meets basic requirements
    test_character.level = 1
    test_character.experience_points = leveling_system.get_experience_for_level(2)

    var can_level = leveling_system.check_leveling_requirements(test_character)
    assert_true(can_level, "Should meet leveling requirements")

    # Test with invalid character data
    test_character.level = 0
    can_level = leveling_system.check_leveling_requirements(test_character)
    assert_false(can_level, "Should not meet requirements with invalid level")

func test_experience_calculation():
    """Test experience calculation for different activities"""
    var combat_xp = leveling_system.calculate_experience("combat", 1, 1)
    var exploration_xp = leveling_system.calculate_experience("exploration", 1, 1)
    var social_xp = leveling_system.calculate_experience("social", 1, 1)

    assert_gt(combat_xp, 0, "Combat should give XP")
    assert_gt(exploration_xp, 0, "Exploration should give XP")
    assert_gt(social_xp, 0, "Social should give XP")

    # Higher level encounters should give more XP
    var high_level_xp = leveling_system.calculate_experience("combat", 5, 1)
    assert_gt(high_level_xp, combat_xp, "Higher level should give more XP")

func test_leveling_system_reset():
    """Test resetting character level"""
    test_character.level = 10
    test_character.experience_points = 50000

    leveling_system.reset_character_level(test_character)

    assert_eq(test_character.level, 1, "Level should reset to 1")
    assert_eq(test_character.experience_points, 0, "Experience should reset to 0")

func test_leveling_system_validation():
    """Test leveling system validation"""
    # Test valid character
    test_character.level = 5
    test_character.experience_points = 1000

    var is_valid = leveling_system.validate_character(test_character)
    assert_true(is_valid, "Valid character should pass validation")

    # Test invalid character
    test_character.level = -1
    is_valid = leveling_system.validate_character(test_character)
    assert_false(is_valid, "Invalid character should fail validation")
