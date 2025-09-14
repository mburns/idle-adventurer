extends GutTest

# Test suite for D&D Character Sheet functionality

var character_sheet: Control
var character: Character

func before_each():
    # Create a test character
    character = Character.new()
    character.name = "Test Character"
    character.race = "Human"
    character.character_class = "Fighter"
    character.background = "Soldier"
    character.strength = 16
    character.dexterity = 14
    character.constitution = 15
    character.intelligence = 12
    character.wisdom = 13
    character.charisma = 10
    character.update_derived_stats()

    # Create character sheet instance
    character_sheet = preload("res://scripts/character_sheet.gd").new()
    character_sheet.character = character

func test_ability_score_display():
    # Test that ability scores are displayed correctly
    character_sheet.update_ability_scores()

    assert_eq(character_sheet.ability_values["strength"].text, "16")
    assert_eq(character_sheet.ability_values["dexterity"].text, "14")
    assert_eq(character_sheet.ability_values["constitution"].text, "15")
    assert_eq(character_sheet.ability_values["intelligence"].text, "12")
    assert_eq(character_sheet.ability_values["wisdom"].text, "13")
    assert_eq(character_sheet.ability_values["charisma"].text, "10")

func test_ability_modifiers():
    # Test that ability modifiers are calculated correctly
    character_sheet.update_ability_scores()

    assert_eq(character_sheet.ability_modifiers["strength"].text, "(+3)")
    assert_eq(character_sheet.ability_modifiers["dexterity"].text, "(+2)")
    assert_eq(character_sheet.ability_modifiers["constitution"].text, "(+2)")
    assert_eq(character_sheet.ability_modifiers["intelligence"].text, "(+1)")
    assert_eq(character_sheet.ability_modifiers["wisdom"].text, "(+1)")
    assert_eq(character_sheet.ability_modifiers["charisma"].text, "(+0)")

func test_dice_rolling():
    # Test basic dice rolling functionality
    var result = character_sheet.roll_dice("1d20+5")

    assert_true(result.has("total"))
    assert_true(result.has("rolls"))
    assert_true(result.has("modifier"))
    assert_eq(result.modifier, 5)
    assert_eq(result.rolls.size(), 1)
    assert_true(result.total >= 6)  # 1 + 5
    assert_true(result.total <= 25)  # 20 + 5

func test_ability_check_rolling():
    # Test ability check rolling
    var result = character_sheet.roll_ability_check("strength")

    assert_true(result.has("total"))
    assert_eq(result.modifier, 3)  # STR modifier
    assert_true(result.total >= 4)  # 1 + 3
    assert_true(result.total <= 23)  # 20 + 3

func test_attack_roll():
    # Test attack roll calculation
    var result = character_sheet.roll_attack_roll()

    var expected_bonus = character.get_strength_modifier() + character.proficiency_bonus
    assert_eq(result.modifier, expected_bonus)
    assert_true(result.total >= expected_bonus + 1)
    assert_true(result.total <= expected_bonus + 20)

func test_damage_roll():
    # Test damage roll calculation
    var result = character_sheet.roll_damage_roll()

    var expected_bonus = character.get_strength_modifier()
    assert_eq(result.modifier, expected_bonus)
    assert_true(result.total >= expected_bonus + 1)
    assert_true(result.total <= expected_bonus + 8)

func test_saving_throw():
    # Test saving throw calculation
    var result = character_sheet.roll_saving_throw("constitution")

    var expected_bonus = character.get_constitution_modifier()
    assert_eq(result.modifier, expected_bonus)
    assert_true(result.total >= expected_bonus + 1)
    assert_true(result.total <= expected_bonus + 20)

func test_initiative_roll():
    # Test initiative roll calculation
    var result = character_sheet.roll_initiative()

    var expected_bonus = character.get_dexterity_modifier()
    assert_eq(result.modifier, expected_bonus)
    assert_true(result.total >= expected_bonus + 1)
    assert_true(result.total <= expected_bonus + 20)

func test_skill_modifier_calculation():
    # Test skill modifier calculation
    character.skill_proficiencies = ["athletics", "perception"]

    var athletics_mod = character_sheet.get_skill_modifier("athletics")
    var expected_athletics = character.get_strength_modifier() + character.proficiency_bonus
    assert_eq(athletics_mod, expected_athletics)

    var perception_mod = character_sheet.get_skill_modifier("perception")
    var expected_perception = character.get_wisdom_modifier() + character.proficiency_bonus
    assert_eq(perception_mod, expected_perception)

    var stealth_mod = character_sheet.get_skill_modifier("stealth")
    var expected_stealth = character.get_dexterity_modifier()  # No proficiency
    assert_eq(stealth_mod, expected_stealth)

func test_dice_history():
    # Test that dice rolls are stored in history
    character_sheet.roll_dice("1d20+5")
    character_sheet.roll_dice("2d6+3")

    assert_eq(character_sheet.dice_history.size(), 2)
    assert_eq(character_sheet.dice_history[0].dice_string, "1d20+5")
    assert_eq(character_sheet.dice_history[1].dice_string, "2d6+3")

func test_invalid_dice_string():
    # Test handling of invalid dice strings
    var result = character_sheet.roll_dice("invalid")

    assert_true(result.has("error"))
    assert_eq(result.error, "Invalid dice format")

func test_combat_stats_display():
    # Test combat stats display
    character_sheet.update_combat_stats()

    assert_eq(character_sheet.hit_points_value.text, "%d/%d" % [character.hit_points, character.max_hit_points])
    assert_eq(character_sheet.armor_class_value.text, str(character.armor_class))
    assert_eq(character_sheet.initiative_value.text, "%+d" % character.get_dexterity_modifier())
    assert_eq(character_sheet.proficiency_value.text, "%+d" % character.proficiency_bonus)

func test_character_info_display():
    # Test character info display
    character_sheet.update_character_info()

    assert_eq(character_sheet.name_label.text, "Test Character")
    assert_eq(character_sheet.level_class_label.text, "Level 1 Fighter")
    assert_eq(character_sheet.race_background_label.text, "Human • Soldier")
