extends GutTest

# Unit tests for YAMLToResourceConverter
# Tests the YAML to Resource conversion functionality (used for data migration)

var converter: YAMLToResourceConverter

func before_each():
	converter = YAMLToResourceConverter.new()
	add_child(converter)

func after_each():
	if converter:
		converter.queue_free()

# Test ActivityResource conversion
func test_yaml_to_activity_resource():
	var yaml_data = {
		"name": "Strength Training",
		"ability": "strength",
		"description": "Physical exercise to build muscle",
		"base_duration": 30.0,
		"base_xp": 50,
		"base_gold": 0,
		"daily_progress": 0.1,
		"cost_per_day": 0.0,
		"requirements": {},
		"rewards": {},
		"activity_type": "training",
		"category": "physical",
		"scales_with_level": true,
		"max_level": 20,
		"xp_scaling_factor": 1.0,
		"gold_scaling_factor": 1.0,
		"requires_tools": false,
		"requires_materials": false,
		"can_be_interrupted": true,
		"requires_location": "",
		"weather_dependent": false,
		"faction_requirements": {},
		"reputation_gain": {},
		"social_activity": false,
		"risk_level": "low",
		"failure_consequences": {},
		"success_bonuses": {}
	}

	var resource = converter.yaml_to_activity_resource(yaml_data)

	assert_not_null(resource, "ActivityResource should be created")
	assert_eq(resource.activity_name, "Strength Training", "Activity name should match")
	assert_eq(resource.ability, "strength", "Ability should match")
	assert_eq(resource.description, "Physical exercise to build muscle", "Description should match")
	assert_eq(resource.base_duration, 30.0, "Base duration should match")
	assert_eq(resource.base_xp, 50, "Base XP should match")
	assert_eq(resource.activity_type, "training", "Activity type should match")

# Test SpellResource conversion
func test_yaml_to_spell_resource():
	var yaml_data = {
		"name": "Fireball",
		"level": 3,
		"school": "evocation",
		"casting_time": "1 action",
		"range": "150 feet",
		"components": "V, S, M",
		"duration": "instantaneous",
		"description": "A bright streak flashes from your pointing finger to a point you choose within range and then blossoms with a low roar into an explosion of flame.",
		"at_higher_levels": "When you cast this spell using a spell slot of 4th level or higher, the damage increases by 1d6 for each slot level above 3rd.",
		"ritual": false,
		"concentration": false,
		"classes": ["wizard", "sorcerer"],
		"damage_dice": "8d6",
		"damage_type": "fire",
		"saving_throw": "Dexterity",
		"attack_roll": false,
		"area_of_effect": "20-foot-radius sphere",
		"scales_with_level": true,
		"scaling_dice": "1d6",
		"scaling_levels": [5, 11, 17]
	}

	var resource = converter.yaml_to_spell_resource(yaml_data)

	assert_not_null(resource, "SpellResource should be created")
	assert_eq(resource.spell_name, "Fireball", "Spell name should match")
	assert_eq(resource.level, 3, "Spell level should match")
	assert_eq(resource.school, "evocation", "Spell school should match")
	assert_eq(resource.casting_time, "1 action", "Casting time should match")
	assert_eq(resource.spell_range, "150 feet", "Spell range should match")
	assert_eq(resource.components, "V, S, M", "Components should match")
	assert_eq(resource.duration, "instantaneous", "Duration should match")
	assert_eq(resource.damage_dice, "8d6", "Damage dice should match")
	assert_eq(resource.damage_type, "fire", "Damage type should match")

# Test CharacterClassResource conversion
func test_yaml_to_class_resource():
	var yaml_data = {
		"name": "Fighter",
		"hit_dice": "1d10",
		"primary_ability": "strength",
		"proficiencies": {
			"saving_throws": ["strength", "constitution"],
			"skills": ["acrobatics", "animal_handling", "athletics", "history", "insight", "intimidation", "perception", "survival"],
			"armor": ["light_armor", "medium_armor", "heavy_armor", "shields"],
			"weapons": ["simple_weapons", "martial_weapons"],
			"tools": []
		},
		"skill_choices": 2,
		"equipment": {
			"starting_equipment": ["chain_mail", "leather_armor", "longbow", "20_arrows"],
			"starting_gold": "5d4 * 10"
		},
		"features": {
			"fighting_style": "Choose a fighting style",
			"second_wind": "You have a limited well of stamina that you can draw on to protect yourself from harm"
		},
		"spellcasting": {
			"ability": "",
			"spell_slots": {}
		}
	}

	var resource = converter.yaml_to_class_resource(yaml_data)

	assert_not_null(resource, "CharacterClassResource should be created")
	assert_eq(resource.name, "Fighter", "Class name should match")
	assert_eq(resource.hit_die, 10, "Hit die should be parsed correctly")
	assert_eq(resource.primary_ability, "strength", "Primary ability should match")
	assert_eq(resource.skill_choices, 2, "Skill choices should match")
	assert_true(resource.saving_throws.has("strength"), "Should have strength saving throw")
	assert_true(resource.saving_throws.has("constitution"), "Should have constitution saving throw")

# Test RaceResource conversion
func test_yaml_to_race_resource():
	var yaml_data = {
		"name": "Human",
		"ability_increases": {"strength": 1, "dexterity": 1, "constitution": 1, "intelligence": 1, "wisdom": 1, "charisma": 1},
		"size": "Medium",
		"speed": 30,
		"height_range": {"min": 56, "max": 76},
		"weight_range": {"min": 110, "max": 200},
		"languages": ["common"],
		"racial_traits": [
			{"name": "Extra Language", "description": "You can speak, read, and write one additional language of your choice."}
		],
		"darkvision": 0,
		"resistances": [],
		"immunities": [],
		"vulnerabilities": [],
		"subraces": []
	}

	var resource = converter.yaml_to_race_resource(yaml_data)

	assert_not_null(resource, "RaceResource should be created")
	assert_eq(resource.name, "Human", "Race name should match")
	assert_eq(resource.size, "Medium", "Size should match")
	assert_eq(resource.speed, 30, "Speed should match")
	assert_eq(resource.get_ability_modifier("strength"), 1, "Strength modifier should match")
	assert_eq(resource.get_ability_modifier("dexterity"), 1, "Dexterity modifier should match")
	assert_false(resource.has_darkvision(), "Humans should not have darkvision")

# Test MonsterResource conversion
func test_yaml_to_monster_resource():
	var yaml_data = {
		"name": "Goblin",
		"size": "Small",
		"type": "humanoid",
		"alignment": "neutral evil",
		"armor_class": 15,
		"hit_points": 7,
		"speed": "30 ft.",
		"abilities": {"strength": 8, "dexterity": 14, "constitution": 10, "intelligence": 10, "wisdom": 8, "charisma": 8},
		"saving_throws": [],
		"skills": ["stealth +6"],
		"damage_immunities": [],
		"damage_resistances": [],
		"damage_vulnerabilities": [],
		"condition_immunities": [],
		"senses": "darkvision 60 ft., passive Perception 9",
		"languages": ["Common", "Goblin"],
		"challenge_rating": "1/4",
		"xp": 50,
		"traits": [],
		"actions": [
			{"name": "Scimitar", "description": "Melee Weapon Attack: +4 to hit, reach 5 ft., one target. Hit: 5 (1d6 + 2) slashing damage."}
		],
		"reactions": [],
		"legendary_actions": []
	}

	var resource = converter.yaml_to_monster_resource(yaml_data)

	assert_not_null(resource, "MonsterResource should be created")
	assert_eq(resource.name, "Goblin", "Monster name should match")
	assert_eq(resource.size, "Small", "Size should match")
	assert_eq(resource.type, "humanoid", "Type should match")
	assert_eq(resource.alignment, "neutral evil", "Alignment should match")
	assert_eq(resource.armor_class, 15, "Armor class should match")
	assert_eq(resource.hit_points, 7, "Hit points should match")
	assert_eq(resource.challenge_rating, "1/4", "Challenge rating should match")
	assert_eq(resource.xp, 50, "XP should match")

# Test EquipmentResource conversion
func test_yaml_to_equipment_resource():
	var yaml_data = {
		"name": "Longsword",
		"type": "weapon",
		"cost": 15,
		"weight": 3.0,
		"description": "A versatile weapon that can be used one-handed or two-handed",
		"rarity": "common",
		"weapon_type": "melee",
		"damage": "1d8",
		"damage_type": "slashing",
		"properties": ["versatile"],
		"range_normal": 0,
		"range_long": 0,
		"finesse": false,
		"two_handed": false,
		"versatile": true,
		"ammunition": false,
		"equipment_slots": ["main_hand", "off_hand"],
		"stackable": false,
		"max_stack_size": 1,
		"crafting_materials": ["iron", "leather"],
		"crafting_time": 8,
		"sell_value": 7,
		"ability_bonuses": {},
		"skill_bonuses": {},
		"saving_throw_bonuses": {},
		"attack_bonus": 0,
		"damage_bonus": 0
	}

	var resource = converter.yaml_to_equipment_resource(yaml_data)

	assert_not_null(resource, "EquipmentResource should be created")
	assert_eq(resource.item_name, "Longsword", "Item name should match")
	assert_eq(resource.cost, 15, "Cost should match")
	assert_eq(resource.weight, 3.0, "Weight should match")
	assert_eq(resource.description, "A versatile weapon that can be used one-handed or two-handed", "Description should match")
	assert_eq(resource.rarity, "common", "Rarity should match")
	assert_eq(resource.item_type, EquipmentResource.EquipmentType.WEAPON, "Item type should be weapon")
	assert_eq(resource.weapon_type, EquipmentResource.WeaponType.MELEE, "Weapon type should be melee")
	assert_eq(resource.damage_dice, "1d8", "Damage dice should match")
	assert_eq(resource.damage_type, "slashing", "Damage type should match")
	assert_true(resource.versatile, "Should be versatile")

# Test MagicItemResource conversion
func test_yaml_to_magic_item_resource():
	var yaml_data = {
		"name": "Potion of Healing",
		"type": "potion",
		"rarity": "common",
		"attunement": "",
		"description": "A magical potion that restores hit points when consumed",
		"properties": ["consumable"],
		"effects": ["heal_2d4_plus_2"],
		"requirements": "",
		"weight": 0.5,
		"value": 50,
		"category": "consumable",
		"charges": 1,
		"max_charges": 1,
		"recharge_rate": "",
		"spell_list": [],
		"spell_level": 0,
		"uses_per_day": 0,
		"cursed": false,
		"sentient": false,
		"armor_class_bonus": 0,
		"attack_bonus": 0,
		"damage_bonus": 0,
		"ability_bonuses": {},
		"skill_bonuses": {},
		"saving_throw_bonuses": {},
		"resistance_types": [],
		"immunity_types": [],
		"vulnerability_types": []
	}

	var resource = converter.yaml_to_magic_item_resource(yaml_data)

	assert_not_null(resource, "MagicItemResource should be created")
	assert_eq(resource.name, "Potion of Healing", "Item name should match")
	assert_eq(resource.type, "potion", "Item type should match")
	assert_eq(resource.rarity, "common", "Rarity should match")
	assert_eq(resource.description, "A magical potion that restores hit points when consumed", "Description should match")
	assert_eq(resource.weight, 0.5, "Weight should match")
	assert_eq(resource.value, 50, "Value should match")
	assert_eq(resource.category, "consumable", "Category should match")
	assert_eq(resource.charges, 1, "Charges should match")
	assert_false(resource.cursed, "Should not be cursed")
	assert_false(resource.sentient, "Should not be sentient")

# Test validation functions
func test_validate_yaml_data():
	var valid_data = {"name": "Test", "level": 1, "description": "Test item"}
	var required_fields = ["name", "level"]

	assert_true(converter.validate_yaml_data(valid_data, required_fields), "Valid data should pass validation")

	var invalid_data = {"name": "Test"}
	assert_false(converter.validate_yaml_data(invalid_data, required_fields), "Invalid data should fail validation")

	var non_dict_data = "not a dictionary"
	assert_false(converter.validate_yaml_data(non_dict_data, required_fields), "Non-dictionary data should fail validation")

func test_get_resource_type_info():
	var activity_info = converter.get_resource_type_info("ActivityResource")
	assert_not_null(activity_info, "Should return info for ActivityResource")
	assert_true(activity_info.has("required_fields"), "Should have required_fields")
	assert_true(activity_info.has("optional_fields"), "Should have optional_fields")
	assert_true(activity_info.has("description"), "Should have description")

	var unknown_info = converter.get_resource_type_info("UnknownResource")
	assert_not_null(unknown_info, "Should return info for unknown resource")
	assert_eq(unknown_info.required_fields.size(), 0, "Unknown resource should have empty required_fields")

func test_convert_yaml_with_validation():
	var valid_yaml = {
		"name": "Test Spell",
		"level": 1,
		"school": "evocation",
		"casting_time": "1 action"
	}

	var resource = converter.convert_yaml_with_validation(valid_yaml, "SpellResource")
	assert_not_null(resource, "Valid YAML should convert successfully")
	assert_true(resource is SpellResource, "Should return SpellResource instance")

	var invalid_yaml = {
		"name": "Test Spell"
		# Missing required fields: level, school, casting_time
	}

	var invalid_resource = converter.convert_yaml_with_validation(invalid_yaml, "SpellResource")
	assert_null(invalid_resource, "Invalid YAML should return null")

func test_get_conversion_statistics():
	var stats = converter.get_conversion_statistics()
	assert_not_null(stats, "Should return statistics")
	assert_true(stats.has("supported_types"), "Should have supported_types")
	assert_true(stats.has("total_conversions"), "Should have total_conversions")
	assert_true(stats.has("conversion_errors"), "Should have conversion_errors")
	assert_true(stats.has("last_conversion_time"), "Should have last_conversion_time")
	assert_eq(stats.supported_types, 7, "Should support 7 resource types")

# Test error handling
func test_conversion_error_signal():
	var error_emitted = false
	var error_type = ""
	var error_message = ""

	converter.conversion_error.connect(func(type: String, message: String):
		error_emitted = true
		error_type = type
		error_message = message
	)

	# Trigger an error by converting invalid data
	converter.convert_yaml_with_validation({}, "UnknownResource")

	assert_true(error_emitted, "Error signal should be emitted")
	assert_eq(error_type, "UnknownResource", "Error type should match")
	assert_true(error_message.contains("Unsupported"), "Error message should indicate unsupported type")

# Test batch conversion functions
func test_convert_activities_from_yaml():
	var yaml_activities = [
		{"name": "Activity 1", "ability": "strength", "description": "Test activity 1"},
		{"name": "Activity 2", "ability": "dexterity", "description": "Test activity 2"}
	]

	var resources = converter.convert_activities_from_yaml(yaml_activities)

	assert_eq(resources.size(), 2, "Should convert 2 activities")
	assert_true(resources[0] is ActivityResource, "First item should be ActivityResource")
	assert_true(resources[1] is ActivityResource, "Second item should be ActivityResource")
	assert_eq(resources[0].activity_name, "Activity 1", "First activity name should match")
	assert_eq(resources[1].activity_name, "Activity 2", "Second activity name should match")

func test_convert_spells_from_yaml():
	var yaml_spells = [
		{"name": "Spell 1", "level": 1, "school": "evocation", "casting_time": "1 action"},
		{"name": "Spell 2", "level": 2, "school": "illusion", "casting_time": "1 action"}
	]

	var resources = converter.convert_spells_from_yaml(yaml_spells)

	assert_eq(resources.size(), 2, "Should convert 2 spells")
	assert_true(resources[0] is SpellResource, "First item should be SpellResource")
	assert_true(resources[1] is SpellResource, "Second item should be SpellResource")
	assert_eq(resources[0].spell_name, "Spell 1", "First spell name should match")
	assert_eq(resources[1].spell_name, "Spell 2", "Second spell name should match")
