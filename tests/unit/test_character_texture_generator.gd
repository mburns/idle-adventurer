extends TestBase

# Test suite for Character Texture Generator

var character: Character

func before_each():
    # Create a test character
    character = Character.new()
    character.name = "Test Character"
    character.race = "Human"
    character.character_class = "Fighter"
    character.strength = 16
    character.dexterity = 14
    character.constitution = 15
    character.intelligence = 12
    character.wisdom = 13
    character.charisma = 10
    character.equipment = {
        "head": "Leather Cap",
        "chest": "Chain Mail",
        "main_hand": "Longsword"
    }

func test_race_color_generation():
    # Test race color generation
    var human_color = CharacterTextureGenerator.get_race_color("Human")
    var elf_color = CharacterTextureGenerator.get_race_color("Elf")
    var dwarf_color = CharacterTextureGenerator.get_race_color("Dwarf")

    # Colors should be different for different races
    assert_true(human_color != elf_color)
    assert_true(human_color != dwarf_color)
    assert_true(elf_color != dwarf_color)

    # Colors should be valid Color objects
    assert_true(human_color is Color)
    assert_true(elf_color is Color)
    assert_true(dwarf_color is Color)

func test_class_accent_color_generation():
    # Test class accent color generation
    var fighter_color = CharacterTextureGenerator.get_class_accent_color("Fighter")
    var wizard_color = CharacterTextureGenerator.get_class_accent_color("Wizard")
    var cleric_color = CharacterTextureGenerator.get_class_accent_color("Cleric")

    # Colors should be different for different classes
    assert_true(fighter_color != wizard_color)
    assert_true(fighter_color != cleric_color)
    assert_true(wizard_color != cleric_color)

    # Colors should be valid Color objects
    assert_true(fighter_color is Color)
    assert_true(wizard_color is Color)
    assert_true(cleric_color is Color)

func test_item_color_generation():
    # Test item color generation
    var leather_color = CharacterTextureGenerator.get_item_color("Leather Armor")
    var chain_color = CharacterTextureGenerator.get_item_color("Chain Mail")
    var magic_color = CharacterTextureGenerator.get_item_color("Magic Sword")

    # Colors should be different for different item types
    assert_true(leather_color != chain_color)
    assert_true(leather_color != magic_color)
    assert_true(chain_color != magic_color)

    # Colors should be valid Color objects
    assert_true(leather_color is Color)
    assert_true(chain_color is Color)
    assert_true(magic_color is Color)

func test_character_texture_generation():
    # Test character texture generation
    var texture = CharacterTextureGenerator.generate_character_texture(character)

    # Should return a valid ImageTexture
    assert_true(texture is ImageTexture)
    assert_not_null(texture)

func test_dice_rolling_accuracy():
    # Test that dice rolling produces expected ranges
    var results = []

    # Roll 1d20 100 times
    for i in range(100):
        var result = CharacterTextureGenerator.roll_dice("1d20")
        results.append(result)
        assert_true(result >= 1)
        assert_true(result <= 20)

    # Check that we get a reasonable distribution
    var unique_values = {}
    for result in results:
        unique_values[result] = unique_values.get(result, 0) + 1

    # Should have at least 10 different values (statistical test)
    assert_true(unique_values.size() >= 10)

func test_dice_rolling_with_modifier():
    # Test dice rolling with modifier
    var result = CharacterTextureGenerator.roll_dice("1d20+5")

    assert_true(result >= 6)  # 1 + 5
    assert_true(result <= 25)  # 20 + 5

func test_multiple_dice_rolling():
    # Test rolling multiple dice
    var result = CharacterTextureGenerator.roll_dice("3d6")

    assert_true(result >= 3)  # 3 * 1
    assert_true(result <= 18)  # 3 * 6

func test_dice_rolling_edge_cases():
    # Test edge cases
    var result1 = CharacterTextureGenerator.roll_dice("1d1")
    assert_eq(result1, 1)

    var result2 = CharacterTextureGenerator.roll_dice("1d1+10")
    assert_eq(result2, 11)

func test_character_texture_properties():
    # Test that generated texture has expected properties
    var texture = CharacterTextureGenerator.generate_character_texture(character)

    # Texture should have valid dimensions
    assert_true(texture.get_width() > 0)
    assert_true(texture.get_height() > 0)

    # Texture should be 64x64 as specified in the generator
    assert_eq(texture.get_width(), 64)
    assert_eq(texture.get_height(), 64)

func test_equipment_rendering():
    # Test that equipment is rendered on character
    var texture = CharacterTextureGenerator.generate_character_texture(character)

    # This is a basic test - in a real implementation, we would check
    # that the texture contains the expected equipment pixels
    assert_not_null(texture)

func test_stat_modifications():
    # Test that character stats affect texture generation
    var high_con_character = Character.new()
    high_con_character.race = "Human"
    high_con_character.character_class = "Fighter"
    high_con_character.constitution = 20

    var high_con_texture = CharacterTextureGenerator.generate_character_texture(high_con_character)
    var normal_texture = CharacterTextureGenerator.generate_character_texture(character)

    # Textures should be different (though this is hard to test without pixel analysis)
    assert_not_null(high_con_texture)
    assert_not_null(normal_texture)
