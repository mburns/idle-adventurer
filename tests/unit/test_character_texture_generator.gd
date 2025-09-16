extends GutTest

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

func test_texture_generation_with_different_races():
    # Test texture generation for different races
    var races = ["Human", "Elf", "Dwarf", "Halfling"]

    for race in races:
        character.race = race
        var texture = CharacterTextureGenerator.generate_character_texture(character)

        assert_not_null(texture, "Texture should be generated for " + race)
        assert_true(texture is ImageTexture, "Should return ImageTexture for " + race)

func test_texture_generation_with_different_classes():
    # Test texture generation for different classes
    var class_list = ["Fighter", "Wizard", "Rogue", "Cleric"]

    for char_class in class_list:
        character.character_class = char_class
        var texture = CharacterTextureGenerator.generate_character_texture(character)

        assert_not_null(texture, "Texture should be generated for " + char_class)
        assert_true(texture is ImageTexture, "Should return ImageTexture for " + char_class)

func test_texture_generation_with_equipment():
    # Test texture generation with equipment
    character.equipment = {
        "head": "Helmet",
        "chest": "Chain Mail",
        "weapon": "Sword"
    }

    var texture = CharacterTextureGenerator.generate_character_texture(character)

    assert_not_null(texture, "Texture should be generated with equipment")
    assert_true(texture is ImageTexture, "Should return ImageTexture with equipment")

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
