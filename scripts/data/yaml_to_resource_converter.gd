extends Node

# YAML to Resource converter utility
# Converts YAML data into typed Godot Resource instances at runtime

class_name YAMLToResourceConverter

signal conversion_error(resource_type: String, error_message: String)

# Field type definitions loaded from YAML
var field_types: Dictionary = {}

func _ready():
	"""Load field type definitions on initialization"""
	load_field_types()

func load_field_types():
	"""Load field type definitions from YAML file"""
	var file_path = "res://data/types/field_types.yaml"
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		print("Warning: Could not load field types from: " + file_path)
		return

	var yaml_string = file.get_as_text()
	file.close()

	var yaml_parser = YAMLParser.new()
	field_types = yaml_parser.parse_yaml_string(yaml_string)
	print("Loaded field types for ", field_types.keys().size(), " resource types")

func convert_value_with_type(value: Variant, expected_type: String) -> Variant:
	"""Convert a value to the expected type based on field type definition"""
	if value == null:
		# Return appropriate default based on type
		match expected_type:
			"String": return ""
			"int": return 0
			"float": return 0.0
			"bool": return false
			"Dictionary": return {}
			Array[String]: return [] as Array[String]
			Array[Dictionary]: return [] as Array[Dictionary]
			Array[int]: return [] as Array[int]
			_: return value

	# Handle array types
	if expected_type.begins_with(Array[):
		if value is Array:
			var array_type = expected_type.substr(6, expected_type.length() - 7)  # Remove Array[" and "]
			match array_type:
				"String":
					var result: Array[String] = []
					for item in value:
						result.append(str(item))
					return result
				"Dictionary":
					var result: Array[Dictionary] = []
					for item in value:
						if item is Dictionary:
							result.append(item)
						else:
							# Convert string to simple dictionary
							result.append({"name": str(item), "description": ""})
					return result
				"int":
					var result: Array[int] = []
					for item in value:
						if item is int:
							result.append(item)
						elif item is String and item.is_valid_int():
							result.append(item.to_int())
						else:
							result.append(0)
					return result
		return value

	# Handle basic types
	match expected_type:
		"String": return str(value)
		"int":
			if value is int: return value
			elif value is String and value.is_valid_int(): return value.to_int()
			else: return 0
		"float":
			if value is float: return value
			elif value is String and value.is_valid_float(): return value.to_float()
			else: return 0.0
		"bool": return bool(value)
		"Dictionary":
			if value is Dictionary: return value
			else: return {}

	return value

# Type hints for better IDE support and runtime validation
const SUPPORTED_RESOURCE_TYPES: Array[String] = [
	"ActivityResource",
	"SpellResource",
	"CharacterClassResource",
	"RaceResource",
	"MonsterResource",
	"EquipmentResource",
	"MagicItemResource"
]

# Convert YAML data to ActivityResource
func yaml_to_activity_resource(yaml_data: Dictionary) -> ActivityResource:
	"""Convert YAML activity data to ActivityResource instance"""
	var resource = ActivityResource.new()

	# Map YAML fields to resource properties
	resource.activity_name = yaml_data.get("name", "")
	resource.ability = yaml_data.get("ability", "general")
	resource.description = yaml_data.get("description", "")

	# Activity mechanics
	resource.base_duration = yaml_data.get("base_duration", 10.0)
	resource.base_xp = yaml_data.get("base_xp", 10)
	resource.base_gold = yaml_data.get("base_gold", 0)
	resource.daily_progress = yaml_data.get("daily_progress", 0.1)
	resource.cost_per_day = yaml_data.get("cost_per_day", 0.0)

	# Requirements and rewards
	resource.requirements = yaml_data.get("requirements", {})
	resource.rewards = yaml_data.get("rewards", {})

	# Activity type and category
	resource.activity_type = yaml_data.get("activity_type", "training")
	resource.category = yaml_data.get("category", "general")

	# Scaling and progression
	resource.scales_with_level = yaml_data.get("scales_with_level", true)
	resource.max_level = yaml_data.get("max_level", 20)
	resource.xp_scaling_factor = yaml_data.get("xp_scaling_factor", 1.0)
	resource.gold_scaling_factor = yaml_data.get("gold_scaling_factor", 1.0)

	# Activity-specific properties
	resource.requires_tools = yaml_data.get("requires_tools", false)
	resource.requires_materials = yaml_data.get("requires_materials", false)
	resource.can_be_interrupted = yaml_data.get("can_be_interrupted", true)
	resource.requires_location = yaml_data.get("requires_location", "")
	resource.weather_dependent = yaml_data.get("weather_dependent", false)

	# Social and faction aspects
	resource.faction_requirements = yaml_data.get("faction_requirements", {})
	resource.reputation_gain = yaml_data.get("reputation_gain", {})
	resource.social_activity = yaml_data.get("social_activity", false)

	# Risk and consequences
	resource.risk_level = yaml_data.get("risk_level", "low")
	resource.failure_consequences = yaml_data.get("failure_consequences", {})
	resource.success_bonuses = yaml_data.get("success_bonuses", {})

	return resource

# Convert YAML data to SpellResource
func yaml_to_spell_resource(yaml_data: Dictionary) -> SpellResource:
	"""Convert YAML spell data to SpellResource instance"""
	var resource = SpellResource.new()

	# Basic spell properties
	resource.spell_name = yaml_data.get("name", "")
	resource.level = yaml_data.get("level", 0)
	resource.school = yaml_data.get("school", "evocation")
	resource.casting_time = yaml_data.get("casting_time", "1 action")
	resource.spell_range = yaml_data.get("range", "60 feet")
	resource.components = yaml_data.get("components", "V, S")
	resource.duration = yaml_data.get("duration", "instantaneous")
	resource.description = yaml_data.get("description", "")
	resource.higher_levels = yaml_data.get("at_higher_levels", "")

	# Spell mechanics
	resource.ritual = yaml_data.get("ritual", false)
	resource.concentration = yaml_data.get("concentration", false)
	resource.classes = yaml_data.get("classes", [] as Array[String])

	# Spell effects
	resource.damage_dice = yaml_data.get("damage_dice", "1d6")
	resource.damage_type = yaml_data.get("damage_type", "acid")
	resource.saving_throw = yaml_data.get("saving_throw", "Dexterity")
	resource.attack_roll = yaml_data.get("attack_roll", false)
	resource.area_of_effect = yaml_data.get("area_of_effect", "")

	# Spell scaling
	resource.scales_with_level = yaml_data.get("scales_with_level", true)
	resource.scaling_dice = yaml_data.get("scaling_dice", "1d6")
	resource.scaling_levels = yaml_data.get("scaling_levels", [5, 11, 17] as Array[int])

	return resource

# Convert YAML data to CharacterClassResource
func yaml_to_class_resource(yaml_data: Dictionary) -> CharacterClassResource:
	"""Convert YAML class data to CharacterClassResource instance"""
	var resource = CharacterClassResource.new()

	# Basic class properties
	resource.name = yaml_data.get("name", "")
	resource.hit_die = _parse_hit_die(yaml_data.get("hit_dice", "1d8"))
	resource.primary_ability = yaml_data.get("primary_ability", "strength")

	# Proficiencies
	var proficiencies_data = yaml_data.get("proficiencies", {})
	var saving_throws_data = proficiencies_data.get("saving_throws", [])
	var saving_throws: Array[String] = []
	if saving_throws_data is Array:
		for throw in saving_throws_data:
			saving_throws.append(str(throw))
	elif saving_throws_data is Dictionary:
		# If it's a dict, extract the keys
		for key in saving_throws_data.keys():
			saving_throws.append(str(key))
	resource.saving_throws = saving_throws
	resource.skill_choices = yaml_data.get("skill_choices", 2)
	# Handle other proficiency arrays with proper type conversion
	var skill_options_data = proficiencies_data.get("skills", [])
	var skill_options: Array[String] = []
	if skill_options_data is Array:
		for skill in skill_options_data:
			skill_options.append(str(skill))
	resource.skill_options = skill_options

	var armor_data = proficiencies_data.get("armor", [])
	var armor_proficiencies: Array[String] = []
	if armor_data is Array:
		for armor in armor_data:
			armor_proficiencies.append(str(armor))
	resource.armor_proficiencies = armor_proficiencies

	var weapon_data = proficiencies_data.get("weapons", [])
	var weapon_proficiencies: Array[String] = []
	if weapon_data is Array:
		for weapon in weapon_data:
			weapon_proficiencies.append(str(weapon))
	resource.weapon_proficiencies = weapon_proficiencies

	var tool_data = proficiencies_data.get("tools", [])
	var tool_proficiencies: Array[String] = []
	if tool_data is Array:
		for tool in tool_data:
			tool_proficiencies.append(str(tool))
	resource.tool_proficiencies = tool_proficiencies

	# Equipment and features
	resource.starting_equipment = yaml_data.get("equipment", {})
	resource.features = _extract_features(yaml_data.get("features", {}))

	# Spellcasting
	resource.spellcasting_ability = yaml_data.get("spellcasting", {}).get("ability", "")
	resource.spell_slots_per_level = _parse_spell_slots(yaml_data.get("spellcasting", {}))

	# Level progression
	resource.level_features = _parse_level_features(yaml_data)

	return resource

# Convert YAML data to RaceResource
func yaml_to_race_resource(yaml_data: Dictionary) -> RaceResource:
	"""Convert YAML race data to RaceResource instance"""
	var resource = RaceResource.new()

	# Map YAML fields to resource properties
	resource.name = yaml_data.get("name", "")
	resource.ability_increases = yaml_data.get("ability_increases", {})
	resource.size = yaml_data.get("size", "Medium")
	resource.speed = yaml_data.get("speed", 30)
	resource.height_range = yaml_data.get("height_range", {})
	resource.weight_range = yaml_data.get("weight_range", {})
	var languages_data = yaml_data.get("languages", [])
	var languages: Array[String] = []
	if languages_data is Array:
		for item in languages_data:
			languages.append(str(item))
	elif languages_data is Dictionary:
		# If it's a dict, extract the keys or values
		for key in languages_data.keys():
			languages.append(str(key))
	resource.languages = languages

	var racial_traits_data = yaml_data.get("traits", [])
	var racial_traits: Array[Dictionary] = []
	if racial_traits_data is Array:
		for item in racial_traits_data:
			if item is Dictionary:
				racial_traits.append(item)
			else:
				# Convert non-dict items to simple dict
				racial_traits.append({"name": str(item), "description": ""})
	elif racial_traits_data is Dictionary:
		# Convert dict to array of dicts
		for key in racial_traits_data.keys():
			var value = racial_traits_data[key]
			if value is Dictionary:
				racial_traits.append(value)
			else:
				racial_traits.append({"name": str(key), "description": str(value)})
	resource.racial_traits = racial_traits

	# Racial features
	resource.darkvision = yaml_data.get("darkvision", 0)
	resource.resistances = yaml_data.get("resistances", [] as Array[String])
	resource.immunities = yaml_data.get("immunities", [] as Array[String])
	resource.vulnerabilities = yaml_data.get("vulnerabilities", [] as Array[String])
	resource.subraces = convert_value_with_type(yaml_data.get("subraces"), Array[Dictionary])

	return resource

# Convert YAML data to MonsterResource
func yaml_to_monster_resource(yaml_data: Dictionary) -> MonsterResource:
	"""Convert YAML monster data to MonsterResource instance"""
	var resource = MonsterResource.new()

	# Map YAML fields to resource properties
	resource.name = yaml_data.get("name", "")
	resource.size = yaml_data.get("size", "Medium")
	resource.type = yaml_data.get("type", "humanoid")
	resource.alignment = yaml_data.get("alignment", "neutral")
	resource.armor_class = yaml_data.get("armor_class", 10)
	resource.hit_points = yaml_data.get("hit_points", 10)
	resource.speed = yaml_data.get("speed", "30 ft.")
	resource.abilities = yaml_data.get("abilities", {})

	# Handle saving throws
	var saving_throws_data = yaml_data.get("saving_throws", [])
	var saving_throws: Array[String] = []
	if saving_throws_data is Array:
		for throw in saving_throws_data:
			saving_throws.append(str(throw))
	elif saving_throws_data is Dictionary:
		for key in saving_throws_data.keys():
			saving_throws.append(str(key))
	resource.saving_throws = saving_throws

	# Handle skills
	var skills_data = yaml_data.get("skills", [])
	var skills: Array[String] = []
	if skills_data is Array:
		for skill in skills_data:
			skills.append(str(skill))
	elif skills_data is Dictionary:
		for key in skills_data.keys():
			skills.append(str(key))
	resource.skills = skills

	# Handle damage immunities
	var damage_immunities_data = yaml_data.get("damage_immunities", [])
	var damage_immunities: Array[String] = []
	if damage_immunities_data is Array:
		for immunity in damage_immunities_data:
			damage_immunities.append(str(immunity))
	elif damage_immunities_data is Dictionary:
		for key in damage_immunities_data.keys():
			damage_immunities.append(str(key))
	resource.damage_immunities = damage_immunities

	# Handle damage resistances
	var damage_resistances_data = yaml_data.get("damage_resistances", [])
	var damage_resistances: Array[String] = []
	if damage_resistances_data is Array:
		for resistance in damage_resistances_data:
			damage_resistances.append(str(resistance))
	elif damage_resistances_data is Dictionary:
		for key in damage_resistances_data.keys():
			damage_resistances.append(str(key))
	resource.damage_resistances = damage_resistances

	# Handle damage vulnerabilities
	var damage_vulnerabilities_data = yaml_data.get("damage_vulnerabilities", [])
	var damage_vulnerabilities: Array[String] = []
	if damage_vulnerabilities_data is Array:
		for vulnerability in damage_vulnerabilities_data:
			damage_vulnerabilities.append(str(vulnerability))
	elif damage_vulnerabilities_data is Dictionary:
		for key in damage_vulnerabilities_data.keys():
			damage_vulnerabilities.append(str(key))
	resource.damage_vulnerabilities = damage_vulnerabilities

	# Handle condition immunities
	var condition_immunities_data = yaml_data.get("condition_immunities", [])
	var condition_immunities: Array[String] = []
	if condition_immunities_data is Array:
		for immunity in condition_immunities_data:
			condition_immunities.append(str(immunity))
	elif condition_immunities_data is Dictionary:
		for key in condition_immunities_data.keys():
			condition_immunities.append(str(key))
	resource.condition_immunities = condition_immunities

	resource.senses = yaml_data.get("senses", "")

	# Handle languages
	var languages_data = yaml_data.get("languages", [])
	var languages: Array[String] = []
	if languages_data is Array:
		for language in languages_data:
			languages.append(str(language))
	elif languages_data is String:
		if "," in languages_data:
			var language_list = languages_data.split(",")
			for lang in language_list:
				languages.append(lang.strip_edges())
		else:
			languages.append(languages_data.strip_edges())
	resource.languages = languages

	resource.challenge_rating = yaml_data.get("challenge_rating", "1/4")
	resource.xp = yaml_data.get("xp", 0)

	# Handle traits
	var traits_data = yaml_data.get("traits", [])
	var traits: Array[Dictionary] = []
	if traits_data is Array:
		for trait_item in traits_data:
			if trait_item is Dictionary:
				traits.append(trait_item)
			else:
				traits.append({"name": str(trait_item), "description": ""})
	resource.traits = traits

	# Handle actions
	var actions_data = yaml_data.get("actions", [])
	var actions: Array[Dictionary] = []
	if actions_data is Array:
		for action in actions_data:
			if action is Dictionary:
				actions.append(action)
			else:
				actions.append({"name": str(action), "description": ""})
	resource.actions = actions

	# Handle reactions
	var reactions_data = yaml_data.get("reactions", [])
	var reactions: Array[Dictionary] = []
	if reactions_data is Array:
		for reaction in reactions_data:
			if reaction is Dictionary:
				reactions.append(reaction)
			else:
				reactions.append({"name": str(reaction), "description": ""})
	resource.reactions = reactions

	# Handle legendary actions
	var legendary_actions_data = yaml_data.get("legendary_actions", [])
	var legendary_actions: Array[Dictionary] = []
	if legendary_actions_data is Array:
		for action in legendary_actions_data:
			if action is Dictionary:
				legendary_actions.append(action)
			else:
				legendary_actions.append({"name": str(action), "description": ""})
	resource.legendary_actions = legendary_actions

	# Calculate derived stats
	resource.proficiency_bonus = _calculate_proficiency_bonus(resource.challenge_rating)
	resource.passive_perception = _calculate_passive_perception(resource)

	return resource

# Convert YAML data to EquipmentResource
func yaml_to_equipment_resource(yaml_data: Dictionary) -> EquipmentResource:
	"""Convert YAML equipment data to EquipmentResource instance"""
	var resource = EquipmentResource.new()

	# Basic equipment properties
	resource.item_name = yaml_data.get("name", "")
	resource.cost = yaml_data.get("cost", 0)
	resource.weight = yaml_data.get("weight", 0.0)
	resource.description = yaml_data.get("description", "")
	resource.rarity = yaml_data.get("rarity", "common")

	# Equipment type
	resource.item_type = _parse_equipment_type(yaml_data.get("type", "adventuring_gear"))

	# Weapon properties
	if resource.item_type == EquipmentResource.EquipmentType.WEAPON:
		resource.weapon_type = _parse_weapon_type(yaml_data.get("weapon_type", "melee"))
		resource.damage_dice = yaml_data.get("damage", "1d4")
		resource.damage_type = yaml_data.get("damage_type", "bludgeoning")
		var properties_data = yaml_data.get("properties", [])
		var properties: Array[String] = []
		for item in properties_data:
			properties.append(str(item))
		resource.properties = properties
		resource.range_normal = yaml_data.get("range_normal", 0)
		resource.range_long = yaml_data.get("range_long", 0)
		resource.finesse = yaml_data.get("finesse", false)
		resource.two_handed = yaml_data.get("two_handed", false)
		resource.versatile = yaml_data.get("versatile", false)
		resource.ammunition = yaml_data.get("ammunition", false)

	# Armor properties
	elif resource.item_type == EquipmentResource.EquipmentType.ARMOR:
		resource.armor_type = _parse_armor_type(yaml_data.get("armor_type", "light"))
		resource.armor_class = yaml_data.get("armor_class", 10)
		resource.strength_requirement = yaml_data.get("strength_requirement", 0)
		resource.stealth_disadvantage = yaml_data.get("stealth_disadvantage", false)

	# Magic item properties
	elif resource.item_type == EquipmentResource.EquipmentType.MAGIC_ITEM:
		resource.requires_attunement = yaml_data.get("requires_attunement", false)
		resource.attunement_requirements = yaml_data.get("attunement_requirements", "")
		resource.charges = yaml_data.get("charges", 0)
		resource.recharge_rate = yaml_data.get("recharge_rate", "")

	# Equipment slots and stacking
	var equipment_slots_data = yaml_data.get("equipment_slots", [])
	var equipment_slots: Array[String] = []
	for item in equipment_slots_data:
		equipment_slots.append(str(item))
	resource.equipment_slots = equipment_slots
	resource.stackable = yaml_data.get("stackable", false)
	resource.max_stack_size = yaml_data.get("max_stack_size", 1)

	# Crafting and economy
	var crafting_materials_data = yaml_data.get("crafting_materials", [])
	var crafting_materials: Array[String] = []
	for item in crafting_materials_data:
		crafting_materials.append(str(item))
	resource.crafting_materials = crafting_materials
	resource.crafting_time = yaml_data.get("crafting_time", 0)
	resource.sell_value = yaml_data.get("sell_value", resource.cost / 2)

	# Stat modifications
	resource.ability_bonuses = yaml_data.get("ability_bonuses", {})
	resource.skill_bonuses = yaml_data.get("skill_bonuses", {})
	resource.saving_throw_bonuses = yaml_data.get("saving_throw_bonuses", {})
	resource.attack_bonus = yaml_data.get("attack_bonus", 0)
	resource.damage_bonus = yaml_data.get("damage_bonus", 0)

	return resource

# Convert YAML data to MagicItemResource
func yaml_to_magic_item_resource(yaml_data: Dictionary) -> MagicItemResource:
	"""Convert YAML magic item data to MagicItemResource instance"""
	var resource = MagicItemResource.new()

	# Basic magic item properties
	resource.name = yaml_data.get("name", "")
	resource.type = yaml_data.get("type", "wondrous item")
	resource.rarity = yaml_data.get("rarity", "common")
	resource.attunement = yaml_data.get("attunement", "")
	resource.description = yaml_data.get("description", "")
	var properties_data = yaml_data.get("properties", [])
	var properties: Array[String] = []
	for item in properties_data:
		properties.append(str(item))
	resource.properties = properties
	var effects_data = yaml_data.get("effects", [])
	var effects: Array[Dictionary] = []
	if effects_data is Array:
		for effect in effects_data:
			if effect is Dictionary:
				effects.append(effect)
			elif effect is String and not effect.is_empty():
				# Convert string to structured dictionary
				effects.append({
					"type": "description",
					"description": effect,
					"value": null
				})
			# Skip null/empty values
	resource.effects = effects
	resource.requirements = yaml_data.get("requirements", "")
	resource.weight = str(yaml_data.get("weight", "0.0"))
	resource.value = str(yaml_data.get("value", "0"))
	resource.category = yaml_data.get("category", "wondrous item")

	# Magic item mechanics
	resource.charges = yaml_data.get("charges", 0)
	resource.max_charges = yaml_data.get("max_charges", 0)
	resource.recharge_rate = yaml_data.get("recharge_rate", "")
	resource.spell_list = yaml_data.get("spell_list", [] as Array[String])
	resource.spell_level = yaml_data.get("spell_level", 0)
	resource.uses_per_day = yaml_data.get("uses_per_day", 0)
	resource.cursed = yaml_data.get("cursed", false)
	resource.sentient = yaml_data.get("sentient", false)

	# Combat bonuses
	resource.armor_class_bonus = yaml_data.get("armor_class_bonus", 0)
	resource.attack_bonus = yaml_data.get("attack_bonus", 0)
	resource.damage_bonus = yaml_data.get("damage_bonus", 0)
	resource.ability_bonuses = yaml_data.get("ability_bonuses", {})
	resource.skill_bonuses = yaml_data.get("skill_bonuses", {})
	resource.saving_throw_bonuses = yaml_data.get("saving_throw_bonuses", {})

	# Resistances and immunities
	resource.resistance_types = yaml_data.get("resistance_types", [] as Array[String])
	resource.immunity_types = yaml_data.get("immunity_types", [] as Array[String])
	resource.vulnerability_types = yaml_data.get("vulnerability_types", [] as Array[String])

	return resource

# Convert YAML data to LanguageResource
func yaml_to_language_resource(yaml_data: Dictionary) -> LanguageResource:
	"""Convert YAML language data to LanguageResource instance"""
	var resource = LanguageResource.new()

	# Map YAML fields to resource properties
	resource.id = yaml_data.get("id", "")
	resource.name = yaml_data.get("name", "")
	resource.description = yaml_data.get("description", "")
	resource.difficulty = yaml_data.get("difficulty", 1)
	resource.learning_time_days = yaml_data.get("learning_time_days", 250)
	resource.cost_per_day = yaml_data.get("cost_per_day", 1.0)
	resource.category = yaml_data.get("category", "standard")
	resource.writing_script = yaml_data.get("script", "")
	resource.speakers = yaml_data.get("speakers", "")

	return resource

# Convert YAML data to CurrencyResource
func yaml_to_currency_resource(yaml_data: Dictionary) -> CurrencyResource:
	"""Convert YAML currency data to CurrencyResource instance"""
	var resource = CurrencyResource.new()

	# Map YAML fields to resource properties
	resource.id = yaml_data.get("id", "")
	resource.name = yaml_data.get("name", "")
	resource.plural = yaml_data.get("plural", "")
	resource.abbreviation = yaml_data.get("abbreviation", "")
	resource.weight = yaml_data.get("weight", 0.02)
	resource.value_base = yaml_data.get("value_base", 1)
	resource.description = yaml_data.get("description", "")
	resource.rarity = yaml_data.get("rarity", "common")
	resource.material = yaml_data.get("material", "")

	return resource

# Convert YAML data to AlignmentResource
func yaml_to_alignment_resource(yaml_data: Dictionary) -> AlignmentResource:
	"""Convert YAML alignment data to AlignmentResource instance"""
	var resource = AlignmentResource.new()

	# Map YAML fields to resource properties
	resource.id = yaml_data.get("id", "")
	resource.name = yaml_data.get("name", "")
	resource.abbreviation = yaml_data.get("abbreviation", "")
	resource.description = yaml_data.get("description", "")
	resource.moral_axis = yaml_data.get("moral_axis", "neutral")
	resource.ethical_axis = yaml_data.get("ethical_axis", "neutral")
	resource.examples = yaml_data.get("examples", [] as Array[String])
	resource.restrictions = yaml_data.get("restrictions", [] as Array[String])
	resource.benefits = yaml_data.get("benefits", [] as Array[String])

	return resource

# Convert YAML data to AchievementResource
func yaml_to_achievement_resource(yaml_data: Dictionary) -> AchievementResource:
	"""Convert YAML achievement data to AchievementResource instance"""
	var resource = AchievementResource.new()

	# Map YAML fields to resource properties
	resource.id = yaml_data.get("id", "")
	resource.name = yaml_data.get("name", "")
	resource.description = yaml_data.get("description", "")
	resource.category = yaml_data.get("category", "")
	resource.rarity = yaml_data.get("rarity", "")
	resource.requirements = yaml_data.get("requirements", {})
	resource.rewards = yaml_data.get("rewards", {})
	resource.unlocked = false
	resource.progress = 0.0
	resource.unlocked_at = 0

	return resource

# Convert YAML data to LifestyleResource
func yaml_to_lifestyle_resource(yaml_data: Dictionary) -> LifestyleResource:
	"""Convert YAML lifestyle data to LifestyleResource instance"""
	var resource = LifestyleResource.new()

	# Map YAML fields to resource properties
	resource.id = yaml_data.get("id", "")
	resource.name = yaml_data.get("name", "")
	resource.daily_cost = yaml_data.get("daily_cost", 0)
	resource.description = yaml_data.get("description", "")
	resource.benefits = yaml_data.get("benefits", [] as Array[String])
	resource.profession_modifiers = yaml_data.get("profession_modifiers", {})

	return resource

# Helper functions for parsing complex data

func _parse_hit_die(hit_dice_string: String) -> int:
	"""Parse hit dice string like '1d12' to get the die size"""
	var regex = RegEx.new()
	regex.compile("\\d+d(\\d+)")
	var result = regex.search(hit_dice_string)
	if result:
		return int(result.get_string(1))
	return 8  # Default to d8

func _extract_features(features_dict: Dictionary) -> Array[String]:
	"""Extract feature names from features dictionary"""
	var features: Array[String] = []
	for feature_name in features_dict.keys():
		features.append(str(feature_name))
	return features

func _parse_spell_slots(_spellcasting_dict: Dictionary) -> Array[int]:
	"""Parse spell slots per level from spellcasting data"""
	# This would need to be implemented based on your spellcasting data structure
	return []

func _parse_level_features(_class_data: Dictionary) -> Array[Dictionary]:
	"""Parse level features from class data"""
	# This would need to be implemented based on your class data structure
	return []

func _calculate_proficiency_bonus(challenge_rating: String) -> int:
	"""Calculate proficiency bonus based on challenge rating"""
	var cr_value = _parse_challenge_rating(challenge_rating)
	return 2 + floor((cr_value - 1) / 4.0)

func _calculate_passive_perception(monster_resource: MonsterResource) -> int:
	"""Calculate passive perception for a monster"""
	var wisdom_modifier = floor((monster_resource.abilities.get("wisdom", 10) - 10) / 2.0)
	return 10 + wisdom_modifier

func _parse_challenge_rating(cr_string: String) -> float:
	"""Parse challenge rating string to float value"""
	match cr_string:
		"0": return 0.0
		"1/8": return 0.125
		"1/4": return 0.25
		"1/2": return 0.5
		"1": return 1.0
		"2": return 2.0
		"3": return 3.0
		"4": return 4.0
		"5": return 5.0
		"6": return 6.0
		"7": return 7.0
		"8": return 8.0
		"9": return 9.0
		"10": return 10.0
		"11": return 11.0
		"12": return 12.0
		"13": return 13.0
		"14": return 14.0
		"15": return 15.0
		"16": return 16.0
		"17": return 17.0
		"18": return 18.0
		"19": return 19.0
		"20": return 20.0
		"21": return 21.0
		"22": return 22.0
		"23": return 23.0
		"24": return 24.0
		"25": return 25.0
		"26": return 26.0
		"27": return 27.0
		"28": return 28.0
		"29": return 29.0
		"30": return 30.0
		_: return 0.0

func _parse_equipment_type(equipment_type_string: String) -> EquipmentResource.EquipmentType:
	"""Parse equipment type string to enum"""
	match equipment_type_string.to_lower():
		"weapon":
			return EquipmentResource.EquipmentType.WEAPON
		"armor":
			return EquipmentResource.EquipmentType.ARMOR
		"shield":
			return EquipmentResource.EquipmentType.SHIELD
		"tool":
			return EquipmentResource.EquipmentType.TOOL
		"magic_item":
			return EquipmentResource.EquipmentType.MAGIC_ITEM
		"consumable":
			return EquipmentResource.EquipmentType.CONSUMABLE
		_:
			return EquipmentResource.EquipmentType.ADVENTURING_GEAR

func _parse_weapon_type(weapon_type_string: String) -> EquipmentResource.WeaponType:
	"""Parse weapon type string to enum"""
	match weapon_type_string.to_lower():
		"ranged":
			return EquipmentResource.WeaponType.RANGED
		"thrown":
			return EquipmentResource.WeaponType.THROWN
		_:
			return EquipmentResource.WeaponType.MELEE

func _parse_armor_type(armor_type_string: String) -> EquipmentResource.ArmorType:
	"""Parse armor type string to enum"""
	match armor_type_string.to_lower():
		"medium":
			return EquipmentResource.ArmorType.MEDIUM
		"heavy":
			return EquipmentResource.ArmorType.HEAVY
		"shield":
			return EquipmentResource.ArmorType.SHIELD
		_:
			return EquipmentResource.ArmorType.LIGHT

# Batch conversion functions

func convert_activities_from_yaml(yaml_activities: Array) -> Array[ActivityResource]:
	"""Convert array of YAML activity data to ActivityResource array"""
	var resources: Array[ActivityResource] = []

	for activity_data in yaml_activities:
		if activity_data is Dictionary:
			var resource = yaml_to_activity_resource(activity_data)
			resources.append(resource)
		else:
			conversion_error.emit("ActivityResource", "Invalid activity data format")

	return resources

func convert_spells_from_yaml(yaml_spells: Array) -> Array[SpellResource]:
	"""Convert array of YAML spell data to SpellResource array"""
	var resources: Array[SpellResource] = []

	for spell_data in yaml_spells:
		if spell_data is Dictionary:
			var resource = yaml_to_spell_resource(spell_data)
			resources.append(resource)
		else:
			conversion_error.emit("SpellResource", "Invalid spell data format")

	return resources

func convert_classes_from_yaml(yaml_classes: Array) -> Array[CharacterClassResource]:
	"""Convert array of YAML class data to CharacterClassResource array"""
	var resources: Array[CharacterClassResource] = []

	for class_data in yaml_classes:
		if class_data is Dictionary:
			var resource = yaml_to_class_resource(class_data)
			resources.append(resource)
		else:
			conversion_error.emit("CharacterClassResource", "Invalid class data format")

	return resources

func convert_equipment_from_yaml(yaml_equipment: Array) -> Array[EquipmentResource]:
	"""Convert array of YAML equipment data to EquipmentResource array"""
	var resources: Array[EquipmentResource] = []

	for equipment_data in yaml_equipment:
		if equipment_data is Dictionary:
			var resource = yaml_to_equipment_resource(equipment_data)
			resources.append(resource)
		else:
			conversion_error.emit("EquipmentResource", "Invalid equipment data format")

	return resources

# Type validation and utility functions

func validate_yaml_data(yaml_data: Dictionary, required_fields: Array[String]) -> bool:
	"""Validate that YAML data contains required fields"""
	if not yaml_data is Dictionary:
		conversion_error.emit("Validation", "YAML data must be a Dictionary")
		return false

	for field in required_fields:
		if not yaml_data.has(field):
			conversion_error.emit("Validation", "Missing required field: " + field)
			return false

	return true

func get_resource_type_info(resource_type: String) -> Dictionary:
	"""Get information about a specific resource type"""
	match resource_type:
		"ActivityResource":
			return {
				"required_fields": ["name", "ability", "description"],
				"optional_fields": ["base_duration", "base_xp", "base_gold", "requirements", "rewards"],
				"description": "D&D Activity data for character progression"
			}
		"SpellResource":
			return {
				"required_fields": ["name", "level", "school", "casting_time"],
				"optional_fields": ["range", "components", "duration", "description", "damage_dice"],
				"description": "D&D Spell data for magic system"
			}
		"CharacterClassResource":
			return {
				"required_fields": ["name", "hit_dice", "primary_ability"],
				"optional_fields": ["proficiencies", "equipment", "features", "spellcasting"],
				"description": "D&D Character Class data"
			}
		"RaceResource":
			return {
				"required_fields": ["name", "size", "speed"],
				"optional_fields": ["ability_increases", "racial_traits", "darkvision", "languages"],
				"description": "D&D Race data for character creation"
			}
		"MonsterResource":
			return {
				"required_fields": ["name", "size", "type", "armor_class", "hit_points"],
				"optional_fields": ["abilities", "actions", "challenge_rating", "xp"],
				"description": "D&D Monster data for encounters"
			}
		"EquipmentResource":
			return {
				"required_fields": ["name", "type", "cost"],
				"optional_fields": ["weight", "description", "properties", "rarity"],
				"description": "D&D Equipment data for inventory system"
			}
		"MagicItemResource":
			return {
				"required_fields": ["name", "type", "rarity"],
				"optional_fields": ["attunement", "description", "properties", "charges"],
				"description": "D&D Magic Item data"
			}
		_:
			return {
				"required_fields": [],
				"optional_fields": [],
				"description": "Unknown resource type"
			}

func convert_yaml_with_validation(yaml_data: Dictionary, resource_type: String) -> Resource:
	"""Convert YAML data to Resource with validation"""
	var type_info = get_resource_type_info(resource_type)

	if not validate_yaml_data(yaml_data, type_info.required_fields):
		return null

	match resource_type:
		"ActivityResource":
			return yaml_to_activity_resource(yaml_data)
		"SpellResource":
			return yaml_to_spell_resource(yaml_data)
		"CharacterClassResource":
			return yaml_to_class_resource(yaml_data)
		"RaceResource":
			return yaml_to_race_resource(yaml_data)
		"MonsterResource":
			return yaml_to_monster_resource(yaml_data)
		"EquipmentResource":
			return yaml_to_equipment_resource(yaml_data)
		"MagicItemResource":
			return yaml_to_magic_item_resource(yaml_data)
		_:
			conversion_error.emit(resource_type, "Unsupported resource type")
			return null

func get_conversion_statistics() -> Dictionary:
	"""Get statistics about conversion operations"""
	return {
		"supported_types": SUPPORTED_RESOURCE_TYPES.size(),
		"total_conversions": 0,  # This would be tracked in a full implementation
		"conversion_errors": 0,  # This would be tracked in a full implementation
		"last_conversion_time": 0.0  # This would be tracked in a full implementation
	}
