extends GutTest

# Unit tests for Resource Managers
# Tests the Resource-based management functionality using .tres files

var activity_manager: ActivityResourceManager
var spell_manager: SpellResourceManager
var class_manager: ClassResourceManager
var race_manager: RaceResourceManager
var monster_manager: MonsterResourceManager
var equipment_manager: EquipmentResourceManager
var magic_item_manager: MagicItemResourceManager
var language_manager: LanguageResourceManager
var currency_manager: CurrencyResourceManager
var achievement_manager: AchievementResourceManager
var lifestyle_manager: LifestyleResourceManager
var name_manager: NameResourceManager
var level_requirement_manager: LevelRequirementResourceManager

func before_each():
	activity_manager = ActivityResourceManager.new()
	spell_manager = SpellResourceManager.new()
	class_manager = ClassResourceManager.new()
	race_manager = RaceResourceManager.new()
	monster_manager = MonsterResourceManager.new()
	equipment_manager = EquipmentResourceManager.new()
	magic_item_manager = MagicItemResourceManager.new()
	language_manager = LanguageResourceManager.new()
	currency_manager = CurrencyResourceManager.new()
	achievement_manager = AchievementResourceManager.new()
	lifestyle_manager = LifestyleResourceManager.new()
	name_manager = NameResourceManager.new()
	level_requirement_manager = LevelRequirementResourceManager.new()

	add_child(activity_manager)
	add_child(spell_manager)
	add_child(class_manager)
	add_child(race_manager)
	add_child(monster_manager)
	add_child(equipment_manager)
	add_child(magic_item_manager)
	add_child(language_manager)
	add_child(currency_manager)
	add_child(achievement_manager)
	add_child(lifestyle_manager)
	add_child(name_manager)
	add_child(level_requirement_manager)

func after_each():
	if activity_manager:
		activity_manager.queue_free()
	if spell_manager:
		spell_manager.queue_free()
	if class_manager:
		class_manager.queue_free()
	if race_manager:
		race_manager.queue_free()
	if monster_manager:
		monster_manager.queue_free()
	if equipment_manager:
		equipment_manager.queue_free()
	if magic_item_manager:
		magic_item_manager.queue_free()
	if language_manager:
		language_manager.queue_free()
	if currency_manager:
		currency_manager.queue_free()
	if achievement_manager:
		achievement_manager.queue_free()
	if lifestyle_manager:
		lifestyle_manager.queue_free()
	if name_manager:
		name_manager.queue_free()
	if level_requirement_manager:
		level_requirement_manager.queue_free()

# Test ActivityResourceManager
func test_activity_manager_initialization():
	assert_not_null(activity_manager, "ActivityResourceManager should be created")
	assert_not_null(activity_manager.data_loader, "Should have data loader")

func test_activity_manager_public_api():
	# Test getting activities
	var activity = activity_manager.get_activity("test_activity")
	assert_null(activity, "Non-existent activity should return null")

	var all_activities = activity_manager.get_all_activities()
	assert_not_null(all_activities, "Should return activities array")
	assert_true(all_activities is Array, "Should return Array")

	var strength_activities = activity_manager.get_activities_by_ability("strength")
	assert_not_null(strength_activities, "Should return strength activities array")
	assert_true(strength_activities is Array, "Should return Array")

# Test SpellResourceManager
func test_spell_manager_initialization():
	assert_not_null(spell_manager, "SpellResourceManager should be created")
	assert_not_null(spell_manager.data_loader, "Should have data loader")

func test_spell_manager_public_api():
	# Test getting spells
	var spell = spell_manager.get_spell("test_spell")
	assert_null(spell, "Non-existent spell should return null")

	var all_spells = spell_manager.get_all_spells()
	assert_not_null(all_spells, "Should return spells array")
	assert_true(all_spells is Array, "Should return Array")

	var level_1_spells = spell_manager.get_spells_by_level(1)
	assert_not_null(level_1_spells, "Should return level 1 spells array")
	assert_true(level_1_spells is Array, "Should return Array")

	var evocation_spells = spell_manager.get_spells_by_school("evocation")
	assert_not_null(evocation_spells, "Should return evocation spells array")
	assert_true(evocation_spells is Array, "Should return Array")

	var wizard_spells = spell_manager.get_spells_by_class("wizard")
	assert_not_null(wizard_spells, "Should return wizard spells array")
	assert_true(wizard_spells is Array, "Should return Array")

	var cantrips = spell_manager.get_cantrips()
	assert_not_null(cantrips, "Should return cantrips array")
	assert_true(cantrips is Array, "Should return Array")

func test_spell_manager_character_interaction():
	# Create a mock character
	var character = Character.new()
	character.name = "Test Character"
	character.level = 1
	character.character_class = "wizard"
	character.known_spells = []

	# Test learning spells
	var test_spell_data = {
		"name": "Test Spell",
		"level": 1,
		"school": "evocation",
		"casting_time": "1 action",
		"range": "60 feet",
		"components": "V, S",
		"duration": "instantaneous",
		"description": "A test spell",
		"classes": ["wizard"]
	}

	# Create a test spell resource directly
	var test_spell = SpellResource.new()
	test_spell.name = "Test Spell"
	test_spell.level = 1
	test_spell.school = "evocation"
	test_spell.casting_time = "1 action"
	test_spell.range = "60 feet"
	test_spell.components = "V, S"
	test_spell.duration = "instantaneous"
	test_spell.description = "A test spell"
	test_spell.classes = ["wizard"]
	spell_manager.spells["Test Spell"] = test_spell

	var can_learn = spell_manager.can_character_learn_spell(character, test_spell)
	assert_true(can_learn, "Character should be able to learn spell")

	var learned = spell_manager.learn_spell_for_character(character, test_spell)
	assert_true(learned, "Character should learn spell successfully")
	assert_true(character.known_spells.has("Test Spell"), "Character should have learned spell")

# Test ClassResourceManager
func test_class_manager_initialization():
	assert_not_null(class_manager, "ClassResourceManager should be created")
	assert_not_null(class_manager.data_loader, "Should have data loader")

func test_class_manager_public_api():
	# Test getting classes
	var class_resource = class_manager.get_class_resource("test_class")
	assert_null(class_resource, "Non-existent class should return null")

	var all_classes = class_manager.get_all_classes()
	assert_not_null(all_classes, "Should return classes array")
	assert_true(all_classes is Array, "Should return Array")

	var hit_die_classes = class_manager.get_classes_by_hit_die(8)
	assert_not_null(hit_die_classes, "Should return hit die classes array")
	assert_true(hit_die_classes is Array, "Should return Array")

	var spellcasting_classes = class_manager.get_spellcasting_classes_all()
	assert_not_null(spellcasting_classes, "Should return spellcasting classes array")
	assert_true(spellcasting_classes is Array, "Should return Array")

func test_class_manager_character_interaction():
	# Create a mock character
	var character = Character.new()
	character.name = "Test Character"
	character.level = 1
	character.character_class = ""
	character.strength = 15
	character.dexterity = 14
	character.constitution = 13
	character.intelligence = 12
	character.wisdom = 11
	character.charisma = 10

	# Test class assignment
	var test_class_data = {
		"name": "Fighter",
		"hit_dice": "1d10",
		"primary_ability": "strength",
		"proficiencies": {
			"saving_throws": ["strength", "constitution"],
			"skills": ["athletics", "intimidation"],
			"armor": ["light_armor", "medium_armor", "heavy_armor", "shields"],
			"weapons": ["simple_weapons", "martial_weapons"],
			"tools": []
		},
		"skill_choices": 2,
		"equipment": {},
		"features": {},
		"spellcasting": {"ability": "", "spell_slots": {}}
	}

	# Create a test class resource directly
	var test_class = CharacterClassResource.new()
	test_class.name = "Fighter"
	test_class.hit_die = 10
	test_class.primary_ability = "strength"
	test_class.saving_throws = ["strength", "constitution"]
	test_class.skill_choices = 2
	test_class.skill_options = ["athletics", "intimidation"]
	test_class.armor_proficiencies = ["light_armor", "medium_armor", "heavy_armor", "shields"]
	test_class.weapon_proficiencies = ["simple_weapons", "martial_weapons"]
	test_class.tool_proficiencies = []
	test_class.starting_equipment = {}
	test_class.features = {}
	test_class.spellcasting_ability = ""
	test_class.spell_slots_per_level = {}
	test_class.level_features = {}
	class_manager.classes["Fighter"] = test_class

	var can_choose = class_manager.can_character_choose_class(character, "Fighter")
	assert_true(can_choose, "Character should be able to choose Fighter class")

	var assigned = class_manager.assign_class_to_character(character, "Fighter")
	assert_true(assigned, "Character should be assigned Fighter class")
	assert_eq(character.character_class, "Fighter", "Character class should be set")

# Test RaceResourceManager
func test_race_manager_initialization():
	assert_not_null(race_manager, "RaceResourceManager should be created")
	assert_not_null(race_manager.data_loader, "Should have data loader")

func test_race_manager_public_api():
	# Test getting races
	var race = race_manager.get_race("test_race")
	assert_null(race, "Non-existent race should return null")

	var all_races = race_manager.get_all_races()
	assert_not_null(all_races, "Should return races array")
	assert_true(all_races is Array, "Should return Array")

	var medium_races = race_manager.get_races_by_size("Medium")
	assert_not_null(medium_races, "Should return medium races array")
	assert_true(medium_races is Array, "Should return Array")

	var speed_30_races = race_manager.get_races_by_speed(30)
	assert_not_null(speed_30_races, "Should return speed 30 races array")
	assert_true(speed_30_races is Array, "Should return Array")

func test_race_manager_character_interaction():
	# Create a mock character
	var character = Character.new()
	character.name = "Test Character"
	character.level = 1
	character.race = ""
	character.strength = 15
	character.dexterity = 14
	character.constitution = 13
	character.intelligence = 12
	character.wisdom = 11
	character.charisma = 10

	# Test race assignment
	var test_race_data = {
		"name": "Human",
		"ability_increases": {"strength": 1, "dexterity": 1, "constitution": 1, "intelligence": 1, "wisdom": 1, "charisma": 1},
		"size": "Medium",
		"speed": 30,
		"height_range": {"min": 56, "max": 76},
		"weight_range": {"min": 110, "max": 200},
		"languages": ["common"],
		"racial_traits": [],
		"darkvision": 0,
		"resistances": [],
		"immunities": [],
		"vulnerabilities": [],
		"subraces": []
	}

	# Create a test race resource directly
	var test_race = RaceResource.new()
	test_race.name = "Human"
	test_race.ability_increases = {"strength": 1, "dexterity": 1, "constitution": 1, "intelligence": 1, "wisdom": 1, "charisma": 1}
	test_race.size = "Medium"
	test_race.speed = 30
	test_race.height_range = {"min": 56, "max": 76}
	test_race.weight_range = {"min": 110, "max": 200}
	test_race.languages = ["common"]
	test_race.racial_traits = []
	test_race.darkvision = 0
	test_race.resistances = []
	test_race.immunities = []
	test_race.vulnerabilities = []
	test_race.subraces = []
	race_manager.races["Human"] = test_race

	var can_choose = race_manager.can_character_choose_race(character, "Human")
	assert_true(can_choose, "Character should be able to choose Human race")

	race_manager.apply_racial_benefits(character, test_race)
	# Racial benefits should be applied (void function)
	assert_eq(character.race, "Human", "Character race should be set")

# Test MonsterResourceManager
func test_monster_manager_initialization():
	assert_not_null(monster_manager, "MonsterResourceManager should be created")
	assert_not_null(monster_manager.data_loader, "Should have data loader")

func test_monster_manager_public_api():
	# Test getting monsters
	var monster = monster_manager.get_monster("test_monster")
	assert_null(monster, "Non-existent monster should return null")

	var all_monsters = monster_manager.get_all_monsters()
	assert_not_null(all_monsters, "Should return monsters array")
	assert_true(all_monsters is Array, "Should return Array")

	var humanoid_monsters = monster_manager.get_monsters_by_type("humanoid")
	assert_not_null(humanoid_monsters, "Should return humanoid monsters array")
	assert_true(humanoid_monsters is Array, "Should return Array")

	var cr_monsters = monster_manager.get_monsters_by_challenge_rating("1/4")
	assert_not_null(cr_monsters, "Should return CR 1/4 monsters array")
	assert_true(cr_monsters is Array, "Should return Array")

	var search_results = monster_manager.search_monsters("goblin")
	assert_not_null(search_results, "Should return search results array")
	assert_true(search_results is Array, "Should return Array")

	var random_monster = monster_manager.get_random_monster()
	assert_null(random_monster, "Random monster should be null when no monsters loaded")

# Test EquipmentResourceManager
func test_equipment_manager_initialization():
	assert_not_null(equipment_manager, "EquipmentResourceManager should be created")
	assert_not_null(equipment_manager.data_loader, "Should have data loader")

func test_equipment_manager_public_api():
	# Test getting equipment
	var equipment = equipment_manager.get_equipment("test_equipment")
	assert_null(equipment, "Non-existent equipment should return null")

	var all_equipment = equipment_manager.get_all_equipment()
	assert_not_null(all_equipment, "Should return equipment array")
	assert_true(all_equipment is Array, "Should return Array")

	var weapon_equipment = equipment_manager.get_equipment_by_type(EquipmentResource.EquipmentType.WEAPON)
	assert_not_null(weapon_equipment, "Should return weapon equipment array")
	assert_true(weapon_equipment is Array, "Should return Array")

	var common_equipment = equipment_manager.get_equipment_by_rarity("common")
	assert_not_null(common_equipment, "Should return common equipment array")
	assert_true(common_equipment is Array, "Should return Array")

	var search_results = equipment_manager.search_equipment("sword")
	assert_not_null(search_results, "Should return search results array")
	assert_true(search_results is Array, "Should return Array")

# Test MagicItemResourceManager
func test_magic_item_manager_initialization():
	assert_not_null(magic_item_manager, "MagicItemResourceManager should be created")
	assert_not_null(magic_item_manager.data_loader, "Should have data loader")

func test_magic_item_manager_public_api():
	# Test getting magic items
	var magic_item = magic_item_manager.get_magic_item("test_magic_item")
	assert_null(magic_item, "Non-existent magic item should return null")

	var all_magic_items = magic_item_manager.get_all_magic_items()
	assert_not_null(all_magic_items, "Should return magic items array")
	assert_true(all_magic_items is Array, "Should return Array")

	var common_items = magic_item_manager.get_common_magic_items()
	assert_not_null(common_items, "Should return common magic items array")
	assert_true(common_items is Array, "Should return Array")

	var uncommon_items = magic_item_manager.get_uncommon_magic_items()
	assert_not_null(uncommon_items, "Should return uncommon magic items array")
	assert_true(uncommon_items is Array, "Should return Array")

	var rare_items = magic_item_manager.get_rare_magic_items()
	assert_not_null(rare_items, "Should return rare magic items array")
	assert_true(rare_items is Array, "Should return Array")

	var very_rare_items = magic_item_manager.get_very_rare_magic_items()
	assert_not_null(very_rare_items, "Should return very rare magic items array")
	assert_true(very_rare_items is Array, "Should return Array")

	var legendary_items = magic_item_manager.get_legendary_magic_items()
	assert_not_null(legendary_items, "Should return legendary magic items array")
	assert_true(legendary_items is Array, "Should return Array")

	var artifact_items = magic_item_manager.get_artifact_magic_items()
	assert_not_null(artifact_items, "Should return artifact magic items array")
	assert_true(artifact_items is Array, "Should return Array")

# Test manager statistics and analysis functions
func test_manager_statistics():
	# Test spell manager statistics
	var spell_stats = spell_manager.get_spell_statistics()
	assert_not_null(spell_stats, "Should return spell statistics")
	assert_true(spell_stats.has("total_spells"), "Should have total_spells")
	assert_true(spell_stats.has("by_level"), "Should have by_level")
	assert_true(spell_stats.has("by_school"), "Should have by_school")
	assert_true(spell_stats.has("by_class"), "Should have by_class")

	# Test monster manager statistics
	var monster_stats = monster_manager.get_monster_statistics()
	assert_not_null(monster_stats, "Should return monster statistics")
	assert_true(monster_stats.has("total_monsters"), "Should have total_monsters")
	assert_true(monster_stats.has("by_type"), "Should have by_type")
	assert_true(monster_stats.has("by_challenge_rating"), "Should have by_challenge_rating")

	# Test equipment manager statistics
	var equipment_stats = equipment_manager.get_equipment_statistics()
	assert_not_null(equipment_stats, "Should return equipment statistics")
	assert_true(equipment_stats.has("total_items"), "Should have total_items")
	assert_true(equipment_stats.has("by_type"), "Should have by_type")
	assert_true(equipment_stats.has("by_rarity"), "Should have by_rarity")

	# Test magic item manager statistics
	var magic_item_stats = magic_item_manager.get_magic_item_statistics()
	assert_not_null(magic_item_stats, "Should return magic item statistics")
	assert_true(magic_item_stats.has("total_items"), "Should have total_items")
	assert_true(magic_item_stats.has("by_rarity"), "Should have by_rarity")
	assert_true(magic_item_stats.has("by_type"), "Should have by_type")
	assert_true(magic_item_stats.has("by_category"), "Should have by_category")

# Test error handling and edge cases
func test_manager_error_handling():
	# Test with null inputs
	var null_activity = activity_manager.get_activity("")
	assert_null(null_activity, "Empty string should return null")

	var null_spell = spell_manager.get_spell("")
	assert_null(null_spell, "Empty string should return null")

	var null_class = class_manager.get_class_resource("")
	assert_null(null_class, "Empty string should return null")

	var null_race = race_manager.get_race("")
	assert_null(null_race, "Empty string should return null")

	var null_monster = monster_manager.get_monster("")
	assert_null(null_monster, "Empty string should return null")

	var null_equipment = equipment_manager.get_equipment("")
	assert_null(null_equipment, "Empty string should return null")

	var null_magic_item = magic_item_manager.get_magic_item("")
	assert_null(null_magic_item, "Empty string should return null")

# Test manager integration
func test_manager_integration():
	# Test that all managers can work together
	var character = Character.new()
	character.name = "Test Character"
	character.level = 1
	character.character_class = "wizard"
	character.race = "human"
	character.known_spells = []

	# Test that managers can provide recommendations
	var class_recommendations = class_manager.get_class_recommendations_for_character(character)
	assert_not_null(class_recommendations, "Should return class recommendations")
	assert_true(class_recommendations is Array, "Should return Array")

	var race_recommendations = race_manager.get_race_recommendations_for_character(character)
	assert_not_null(race_recommendations, "Should return race recommendations")
	assert_true(race_recommendations is Array, "Should return Array")

	var equipment_recommendations = equipment_manager.get_equipment_recommendations_for_character(character)
	assert_not_null(equipment_recommendations, "Should return equipment recommendations")
	assert_true(equipment_recommendations is Dictionary, "Should return Dictionary")

	var magic_item_recommendations = magic_item_manager.get_magic_item_recommendations_for_character(character)
	assert_not_null(magic_item_recommendations, "Should return magic item recommendations")
	assert_true(magic_item_recommendations is Dictionary, "Should return Dictionary")

# Test LanguageResourceManager
func test_language_manager_initialization():
	assert_not_null(language_manager, "LanguageResourceManager should be created")
	assert_not_null(language_manager.data_loader, "Should have data loader")

func test_language_manager_loading():
	# Test that languages are loaded
	var all_languages = language_manager.get_all_languages()
	assert_not_null(all_languages, "Should return languages dictionary")
	assert_true(all_languages is Dictionary, "Should return Dictionary")

func test_language_manager_api():
	# Test language retrieval
	var common = language_manager.get_language_by_id("common")
	if common:
		assert_not_null(common, "Should find common language")
		assert_eq(common.name, "Common", "Should have correct name")
		assert_eq(common.difficulty, 0, "Should have correct difficulty")

	# Test category filtering
	var standard_languages = language_manager.get_languages_by_category("standard")
	assert_not_null(standard_languages, "Should return standard languages")
	assert_true(standard_languages is Array, "Should return Array")

	# Test difficulty filtering
	var easy_languages = language_manager.get_languages_by_difficulty(1)
	assert_not_null(easy_languages, "Should return easy languages")
	assert_true(easy_languages is Array, "Should return Array")

# Test CurrencyResourceManager
func test_currency_manager_initialization():
	assert_not_null(currency_manager, "CurrencyResourceManager should be created")
	assert_not_null(currency_manager.data_loader, "Should have data loader")

func test_currency_manager_loading():
	# Test that currencies are loaded
	var all_currencies = currency_manager.get_all_currencies()
	assert_not_null(all_currencies, "Should return currencies dictionary")
	assert_true(all_currencies is Dictionary, "Should return Dictionary")

func test_currency_manager_api():
	# Test currency retrieval
	var gold = currency_manager.get_currency_by_id("gp")
	if gold:
		assert_not_null(gold, "Should find gold piece")
		assert_eq(gold.name, "Gold Piece", "Should have correct name")
		assert_eq(gold.value_base, 100, "Should have correct value")

	# Test rarity filtering
	var common_currencies = currency_manager.get_currencies_by_rarity("common")
	assert_not_null(common_currencies, "Should return common currencies")
	assert_true(common_currencies is Array, "Should return Array")

	# Test material filtering
	var gold_currencies = currency_manager.get_currencies_by_material("gold")
	assert_not_null(gold_currencies, "Should return gold currencies")
	assert_true(gold_currencies is Array, "Should return Array")

	# Test currency conversion
	var converted_amount = currency_manager.convert_currency("gp", "cp", 1)
	assert_eq(converted_amount, 100, "Should convert 1 gp to 100 cp")

	# Test exchange rate
	var rate = currency_manager.get_exchange_rate("gp", "cp")
	assert_eq(rate, 100.0, "Should have correct exchange rate")

# Test AchievementResourceManager
func test_achievement_manager_initialization():
	assert_not_null(achievement_manager, "AchievementResourceManager should be created")
	assert_not_null(achievement_manager.data_loader, "Should have data loader")

func test_achievement_manager_loading():
	# Test that achievements are loaded
	var all_achievements = achievement_manager.get_all_achievements()
	assert_not_null(all_achievements, "Should return achievements dictionary")
	assert_true(all_achievements is Dictionary, "Should return Dictionary")

func test_achievement_manager_api():
	# Test achievement retrieval
	var level_5 = achievement_manager.get_achievement_by_id("level_5")
	if level_5:
		assert_not_null(level_5, "Should find level 5 achievement")
		assert_eq(level_5.name, "Rising Star", "Should have correct name")
		assert_eq(level_5.category, "CHARACTER_LEVEL", "Should have correct category")

	# Test category filtering
	var level_achievements = achievement_manager.get_achievements_by_category("CHARACTER_LEVEL")
	assert_not_null(level_achievements, "Should return level achievements")
	assert_true(level_achievements is Array, "Should return Array")

	# Test rarity filtering
	var common_achievements = achievement_manager.get_achievements_by_rarity("COMMON")
	assert_not_null(common_achievements, "Should return common achievements")
	assert_true(common_achievements is Array, "Should return Array")

# Test LifestyleResourceManager
func test_lifestyle_manager_initialization():
	assert_not_null(lifestyle_manager, "LifestyleResourceManager should be created")
	assert_not_null(lifestyle_manager.data_loader, "Should have data loader")

func test_lifestyle_manager_loading():
	# Test that lifestyles are loaded
	var all_lifestyles = lifestyle_manager.get_all_lifestyles()
	assert_not_null(all_lifestyles, "Should return lifestyles dictionary")
	assert_true(all_lifestyles is Dictionary, "Should return Dictionary")

func test_lifestyle_manager_api():
	# Test lifestyle retrieval
	var wretched = lifestyle_manager.get_lifestyle_by_id("wretched")
	if wretched:
		assert_not_null(wretched, "Should find wretched lifestyle")
		assert_eq(wretched.name, "Wretched", "Should have correct name")
		assert_eq(wretched.daily_cost, 0, "Should have correct cost")

	# Test cost range filtering
	var poor_lifestyles = lifestyle_manager.get_lifestyles_by_cost_range("poor")
	assert_not_null(poor_lifestyles, "Should return poor lifestyles")
	assert_true(poor_lifestyles is Array, "Should return Array")

	# Test benefits
	var all_benefits = lifestyle_manager.get_all_benefits()
	assert_not_null(all_benefits, "Should return benefits dictionary")
	assert_true(all_benefits is Dictionary, "Should return Dictionary")

# Test NameResourceManager
func test_name_manager_initialization():
	assert_not_null(name_manager, "NameResourceManager should be created")
	assert_not_null(name_manager.data_loader, "Should have data loader")

func test_name_manager_loading():
	# Test that names are loaded
	var first_names = name_manager.get_all_first_names()
	var last_names = name_manager.get_all_last_names()
	assert_not_null(first_names, "Should return first names array")
	assert_not_null(last_names, "Should return last names array")
	assert_true(first_names is Array, "Should return Array")
	assert_true(last_names is Array, "Should return Array")

func test_name_manager_api():
	# Test name generation
	var random_first = name_manager.get_random_first_name()
	var random_last = name_manager.get_random_last_name()
	var random_full = name_manager.get_random_full_name()

	assert_not_null(random_first, "Should return random first name")
	assert_not_null(random_last, "Should return random last name")
	assert_not_null(random_full, "Should return random full name")
	assert_true(random_full.contains(" "), "Full name should contain space")

	# Test category filtering
	var first_names = name_manager.get_names_by_category("first")
	assert_not_null(first_names, "Should return first names")
	assert_true(first_names is Array, "Should return Array")

# Test LevelRequirementResourceManager
func test_level_requirement_manager_initialization():
	assert_not_null(level_requirement_manager, "LevelRequirementResourceManager should be created")
	assert_not_null(level_requirement_manager.data_loader, "Should have data loader")

func test_level_requirement_manager_loading():
	# Test that level requirements are loaded
	var all_requirements = level_requirement_manager.get_all_level_requirements()
	assert_not_null(all_requirements, "Should return level requirements dictionary")
	assert_true(all_requirements is Dictionary, "Should return Dictionary")

func test_level_requirement_manager_api():
	# Test level requirement retrieval
	var level_1 = level_requirement_manager.get_level_requirement(1)
	if level_1:
		assert_not_null(level_1, "Should find level 1 requirement")
		assert_eq(level_1.level, 1, "Should have correct level")
		assert_eq(level_1.experience_required, 0, "Should have correct XP requirement")

	# Test experience calculations
	var xp_for_level_2 = level_requirement_manager.get_experience_required_for_level(2)
	assert_true(xp_for_level_2 > 0, "Level 2 should require XP")

	var level_for_xp = level_requirement_manager.get_level_for_experience(1000)
	assert_true(level_for_xp > 0, "Should return a level for 1000 XP")

	# Test alternative configurations
	var configs = level_requirement_manager.get_alternative_configs()
	assert_not_null(configs, "Should return alternative configurations")
	assert_true(configs is Dictionary, "Should return Dictionary")
