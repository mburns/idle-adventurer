extends TestBase

func test_load_class_from_wiki():
    # Test loading a class from wiki
    var class_data = WikiDataLoader.load_class_from_wiki("Barbarian")

    # Should have basic class structure
    assert_true(class_data.has("name"), "Class data should have name")
    assert_true(class_data.has("hit_die"), "Class data should have hit_die")
    assert_true(class_data.has("saving_throws"), "Class data should have saving_throws")

    # Barbarian should have d12 hit die
    assert_eq(class_data.hit_die, 12, "Barbarian should have d12 hit die")

    # Test invalid class
    var invalid_data = WikiDataLoader.load_class_from_wiki("InvalidClass")
    assert_true(invalid_data.is_empty(), "Invalid class should return empty data")

func test_load_equipment_from_wiki():
    # Test loading equipment from wiki
    var equipment = WikiDataLoader.load_equipment_from_wiki()

    # Should have equipment categories
    assert_true(equipment.has("armor"), "Should have armor category")
    assert_true(equipment.has("weapons"), "Should have weapons category")

    # Equipment should be arrays
    assert_true(equipment.armor is Array, "Armor should be an array")
    assert_true(equipment.weapons is Array, "Weapons should be an array")

func test_load_treasure_from_wiki():
    # Test loading treasure from wiki
    var treasure = WikiDataLoader.load_treasure_from_wiki()

    # Should have treasure items
    assert_gt(treasure.size(), 0, "Should have treasure items")

    # Each treasure item should have required fields
    for item_name in treasure.keys():
        var item = treasure[item_name]
        assert_true(item.has("name"), "Treasure item should have name")
        assert_true(item.has("type"), "Treasure item should have type")
        assert_true(item.has("rarity"), "Treasure item should have rarity")

func test_load_spells_from_wiki():
    # Test loading spells from wiki
    var spells = WikiDataLoader.load_spells_from_wiki()

    # Should have spells
    assert_gt(spells.size(), 0, "Should have spells")

    # Each spell should have required fields
    for spell_name in spells.keys():
        var spell = spells[spell_name]
        assert_true(spell.has("name"), "Spell should have name")
        assert_true(spell.has("level"), "Spell should have level")
        assert_true(spell.has("school"), "Spell should have school")

func test_load_abilities_from_wiki():
    # Test loading abilities from wiki
    var abilities = WikiDataLoader.load_abilities_from_wiki()

    # Should have all 6 abilities
    assert_eq(abilities.size(), 6, "Should have 6 abilities")

    # Should have all ability names
    var expected_abilities = ["strength", "dexterity", "constitution", "intelligence", "wisdom", "charisma"]
    for ability in expected_abilities:
        assert_true(abilities.has(ability), "Should have " + ability + " ability")

    # Each ability should have required fields
    for ability_name in abilities.keys():
        var ability = abilities[ability_name]
        assert_true(ability.has("name"), "Ability should have name")
        assert_true(ability.has("skills"), "Ability should have skills")
        assert_true(ability.skills is Array, "Skills should be an array")

func test_parse_class_markdown():
    # Test parsing class markdown
    var sample_markdown = """
# Barbarian

### Class Features

**Hit Dice:** 1d12 per barbarian level

**Saving Throws:** Strength, Constitution

**Skills:** Choose two from Animal Handling, Athletics, Intimidation, Nature, Perception, and Survival

**Armor:** Light armor, medium armor, shields

**Weapons:** Simple weapons, martial weapons

**Tools:** None
"""

    var class_data = WikiDataLoader.parse_class_markdown(sample_markdown, "Barbarian")

    assert_eq(class_data.name, "Barbarian", "Class name should be parsed")
    assert_eq(class_data.hit_die, 12, "Hit die should be parsed")
    assert_true(class_data.saving_throws.has("Strength"), "Saving throws should be parsed")
    assert_true(class_data.skill_options.has("Athletics"), "Skill options should be parsed")

func test_parse_equipment_markdown():
    # Test parsing equipment markdown
    var sample_markdown = """
| Item | Cost | Weight | Description |
|------|------|--------|-------------|
| Longsword | 15 gp | 3 lb | A versatile melee weapon |
| Shield | 10 gp | 6 lb | A defensive item |
"""

    var equipment = WikiDataLoader.parse_equipment_markdown(sample_markdown)

    assert_gt(equipment.size(), 0, "Should parse equipment items")
    assert_eq(equipment[0].name, "Longsword", "First item name should be parsed")
    assert_eq(equipment[0].cost, "15 gp", "First item cost should be parsed")

func test_parse_treasure_markdown():
    # Test parsing treasure markdown
    var sample_markdown = """
# Amulet of Health

**Type:** Wondrous item
**Rarity:** Rare

This amulet increases your Constitution score by 2, to a maximum of 20.
"""

    var treasure = WikiDataLoader.parse_treasure_markdown(sample_markdown)

    assert_eq(treasure.name, "Amulet of Health", "Treasure name should be parsed")
    assert_eq(treasure.type, "Wondrous item", "Treasure type should be parsed")
    assert_eq(treasure.rarity, "Rare", "Treasure rarity should be parsed")

func test_parse_spell_markdown():
    # Test parsing spell markdown
    var sample_markdown = """
# Fireball

**Level:** 3
**School:** Evocation
**Casting Time:** 1 action
**Range:** 150 feet
**Components:** V, S, M
**Duration:** Instantaneous

A bright streak flashes from your pointing finger to a point you choose within range.
"""

    var spell = WikiDataLoader.parse_spell_markdown(sample_markdown)

    assert_eq(spell.name, "Fireball", "Spell name should be parsed")
    assert_eq(spell.level, 3, "Spell level should be parsed")
    assert_eq(spell.school, "Evocation", "Spell school should be parsed")
    assert_eq(spell.casting_time, "1 action", "Casting time should be parsed")

func test_parse_ability_markdown():
    # Test parsing ability markdown
    var sample_markdown = """
### Strength

Strength measures bodily power, athletic training, and the extent to which you can exert raw physical force.

***Athletics***. Your Strength (Athletics) check covers difficult situations you encounter
    while climbing, jumping, or swimming.

***Other Strength Checks***. The GM might also call for a Strength check when you try to
    accomplish tasks like the following:
"""

    var ability = WikiDataLoader.parse_ability_markdown(sample_markdown)

    assert_eq(ability.name, "Strength", "Ability name should be parsed")
    assert_true(ability.skills.has("Athletics"), "Athletics skill should be parsed")
    assert_true(ability.description.length() > 0, "Description should be parsed")
