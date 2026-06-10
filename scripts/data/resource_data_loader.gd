extends Resource

# Resource-based Data Loader
# Replaces YAML parsing with direct .tres file loading
# Provides type-safe data access with better performance

class_name ResourceDataLoader

# Resource storage - now using proper Resource types
var activities: Dictionary = {} # ability -> Array[ActivityResource]
var races: Dictionary = {} # race_name -> RaceResource
var classes: Dictionary = {} # class_name -> CharacterClassResource
var spells: Dictionary = {} # spell_name -> SpellResource
var monsters: Dictionary = {} # monster_name -> MonsterResource
var equipment: Dictionary = {} # item_name -> EquipmentResource
var magic_items: Dictionary = {} # item_name -> MagicItemResource
var languages: Dictionary = {} # language_name -> LanguageResource
var currencies: Dictionary = {} # currency_name -> CurrencyResource
var alignments: Dictionary = {} # alignment_name -> AlignmentResource
var achievements: Dictionary = {} # achievement_id -> AchievementResource
var lifestyles: Dictionary = {} # lifestyle_id -> LifestyleResource
var level_requirements: Dictionary = {} # level -> LevelRequirementResource
var names: Dictionary = {} # name -> NameResource

signal data_loaded(data_type: String, count: int)

func _ready() -> void:
	load_all_data()

func load_all_data() -> void:
	"""Load all data from .tres files"""
	print("Loading data from .tres files...")

	load_activities()
	load_races()
	load_classes()
	load_spells()
	load_monsters()
	load_equipment()
	load_magic_items()
	load_languages()
	load_currencies()
	load_alignments()
	load_achievements()
	load_lifestyles()
	load_level_requirements()
	load_names()

	print("Data loading complete!")

func load_activities() -> void:
	"""Load activities from individual .tres files"""
	var activities_dir = "res://data/activities/"
	var dir = DirAccess.open(activities_dir)
	if not dir:
		print("Error: Could not open activities directory")
		return

	# Initialize ability arrays
	var abilities = ["strength", "dexterity", "constitution", "intelligence", "wisdom", "charisma", "general"]
	for ability in abilities:
		activities[ability] = []

	var files = dir.get_files()
	for file_name in files:
		if file_name.ends_with(".tres"):
			var file_path = activities_dir + file_name
			var activity_resource = null

			# Load as generic Resource and convert
			var generic_resource = load(file_path) as Resource
			if generic_resource:
				activity_resource = _convert_resource_to_activity(generic_resource)

			if activity_resource:
				# Determine ability from activity name or default to general
				var ability_name = _determine_ability_from_name(activity_resource.activity_name)
				if ability_name in activities:
					activities[ability_name].append(activity_resource)
				else:
					activities["general"].append(activity_resource)
			else:
				print("Failed to load activity: ", file_name)

	var total_count = 0
	for ability in activities.keys():
		total_count += activities[ability].size()

	print("Loaded ", total_count, " activities")
	data_loaded.emit("activities", total_count)

func _determine_ability_from_name(activity_name: String) -> String:
	"""Determine ability from activity name"""
	var name_lower = activity_name.to_lower()

    # TODO remove this hacky mapping.

	# Strength-based activities
	if "athletics" in name_lower or "physical" in name_lower or "combat" in name_lower or "blacksmith" in name_lower or "strongman" in name_lower or "log" in name_lower or "wrestling" in name_lower:
		return "strength"
	# Dexterity-based activities
	elif "acrobatics" in name_lower or "sleight" in name_lower or "stealth" in name_lower or "jewelry" in name_lower or "parkour" in name_lower or "archery" in name_lower or "pick" in name_lower or "instrument" in name_lower or "kickflip" in name_lower:
		return "dexterity"
	# Intelligence-based activities
	elif "arcana" in name_lower or "history" in name_lower or "investigation" in name_lower or "nature" in name_lower or "religion" in name_lower or "academic" in name_lower or "alchemy" in name_lower or "chess" in name_lower or "codebreaking" in name_lower or "invention" in name_lower or "study" in name_lower or "research" in name_lower or "investigate" in name_lower or "forge" in name_lower:
		return "intelligence"
	# Wisdom-based activities
	elif "animal" in name_lower or "insight" in name_lower or "medicine" in name_lower or "perception" in name_lower or "survival" in name_lower or "spiritual" in name_lower:
		return "wisdom"
	# Charisma-based activities
	elif "performance" in name_lower or "deception" in name_lower or "intimidation" in name_lower or "persuasion" in name_lower or "social" in name_lower or "entertainment" in name_lower or "comedy" in name_lower or "court" in name_lower or "merchant" in name_lower or "royal" in name_lower:
		return "charisma"
	# Constitution-based activities
	elif "endurance" in name_lower or "fasting" in name_lower or "conditioning" in name_lower or "resistance" in name_lower or "breath" in name_lower or "ale" in name_lower:
		return "constitution"
	# Rest activities
	elif "rest" in name_lower or "meditation" in name_lower or "exercise" in name_lower or "reading" in name_lower or "relaxation" in name_lower:
		return "general"
	# Training activities
	elif "language" in name_lower or "tool" in name_lower or "skill" in name_lower:
		return "intelligence"
	# Crafting activities
	elif "leatherworking" in name_lower or "pottery" in name_lower or "weaving" in name_lower or "woodworking" in name_lower:
		return "dexterity"
	# Profession activities
	elif "artisan" in name_lower or "merchant" in name_lower or "scholar" in name_lower or "guard" in name_lower or "priest" in name_lower or "entertainer" in name_lower:
		if "artisan" in name_lower or "scholar" in name_lower: return "intelligence"
		if "merchant" in name_lower or "entertainer" in name_lower: return "charisma"
		if "guard" in name_lower: return "strength"
		if "priest" in name_lower: return "wisdom"

	return "general"

func _convert_resource_to_activity(resource: Resource) -> ActivityResource:
	"""Convert a generic Resource to ActivityResource by parsing the file content"""
	var activity_resource = ActivityResource.new()

	# Get the file path from the resource
	var file_path = resource.resource_path
	print("DEBUG: Converting resource with path: ", file_path)
	if file_path == "":
		print("No resource path available")
		return activity_resource

	# Read the file content as text
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		print("Failed to open file: ", file_path)
		return activity_resource

	var content = file.get_as_text()
	file.close()

	print("DEBUG: File content length: ", content.length())

	# Parse the content to extract properties
	var lines = content.split("\n")
	for line in lines:
		line = line.strip_edges()
		if line.begins_with("activity_name = "):
			activity_resource.activity_name = line.substr(15).strip_edges().trim_prefix('"').trim_suffix('"')
			print("DEBUG: Found activity_name: ", activity_resource.activity_name)
		elif line.begins_with("ability_name = "):
			activity_resource.ability_name = line.substr(15).strip_edges().trim_prefix('"').trim_suffix('"')
			print("DEBUG: Found ability_name: ", activity_resource.ability_name)
		elif line.begins_with("skill = "):
			activity_resource.skill = line.substr(8).strip_edges().trim_prefix('"').trim_suffix('"')
		elif line.begins_with("description = "):
			activity_resource.description = line.substr(14).strip_edges().trim_prefix('"').trim_suffix('"')
		elif line.begins_with("cycle_duration = "):
			activity_resource.cycle_duration = float(line.substr(17))
		elif line.begins_with("cycle_xp = "):
			activity_resource.cycle_xp = int(line.substr(11))
		elif line.begins_with("cycle_gold = "):
			activity_resource.cycle_gold = int(line.substr(13))
		elif line.begins_with("cycle_cost = "):
			activity_resource.cycle_cost = float(line.substr(13))
		elif line.begins_with("daily_progress = "):
			activity_resource.daily_progress = float(line.substr(17))
		elif line.begins_with("cost_per_day = "):
			activity_resource.cost_per_day = float(line.substr(15))

	print("DEBUG: Final activity_name: ", activity_resource.activity_name)
	print("DEBUG: Final ability_name: ", activity_resource.ability_name)

	# Load ability resource based on ability_name or skill
	var ability_resource = null
	if activity_resource.ability_name != "":
		# Direct ability mapping
		ability_resource = _load_ability_by_name(activity_resource.ability_name)
	elif activity_resource.skill != "":
		# Skill-based mapping
		ability_resource = _get_ability_for_skill(activity_resource.skill)
	else:
		# Fallback: determine from activity name
		var ability_name = _determine_ability_from_name(activity_resource.activity_name)
		ability_resource = _load_ability_by_name(ability_name)

	activity_resource.ability_resource = ability_resource

	return activity_resource

func _load_ability_by_name(ability_name: String) -> AbilityResource:
	"""Load ability resource by name"""
	var ability_path = "res://data/abilities/" + ability_name + ".tres"
	var ability_resource = load(ability_path)
	if ability_resource:
		# Convert generic Resource to AbilityResource
		var converted_ability = AbilityResource.new()
		converted_ability.id = ability_resource.get("id") if ability_resource.get("id") != null else ""
		converted_ability.ability_name = ability_resource.get("ability_name") if ability_resource.get("ability_name") != null else ""
		converted_ability.description = ability_resource.get("description") if ability_resource.get("description") != null else ""
		converted_ability.modifier = ability_resource.get("modifier") if ability_resource.get("modifier") != null else 0
		converted_ability.base_score = ability_resource.get("base_score") if ability_resource.get("base_score") != null else 10
		converted_ability.is_core_ability = ability_resource.get("is_core_ability") if ability_resource.get("is_core_ability") != null else true

		# Create properly typed arrays
		var skills_array: Array[String] = []
		var activities_array: Array[String] = []
		converted_ability.associated_skills = skills_array
		converted_ability.associated_activities = activities_array

		converted_ability.saving_throw_proficiency = ability_resource.get("saving_throw_proficiency") if ability_resource.get("saving_throw_proficiency") != null else false
		converted_ability.is_spellcasting_ability = ability_resource.get("is_spellcasting_ability") if ability_resource.get("is_spellcasting_ability") != null else false
		return converted_ability
	else:
		print("Failed to load ability: ", ability_name)
		return null

func _get_ability_for_skill(skill_name: String) -> AbilityResource:
	"""Get ability resource for a skill"""
	# Convert skill name to file name (e.g., "Animal Handling" -> "animal_handling")
	var skill_file_name = skill_name.to_lower().replace(" ", "_")
	var skill_path = "res://data/skills/" + skill_file_name + ".tres"

	var skill_resource = load(skill_path)
	if skill_resource and skill_resource is SkillResource:
		# If skill has ability_resource, use it
		if skill_resource.ability_resource:
			return skill_resource.ability_resource
		else:
			# Fallback: determine ability from skill name
			var ability_name = _skill_to_ability_name(skill_name)
			return _load_ability_by_name(ability_name)
	else:
		# Fallback: determine ability from skill name
		var ability_name = _skill_to_ability_name(skill_name)
		return _load_ability_by_name(ability_name)

func _skill_to_ability_name(skill_name: String) -> String:
	"""Map skill name to ability name"""
	var skill_lower = skill_name.to_lower()

	# Strength-based skills
	if skill_lower in ["athletics"]:
		return "strength"
	# Dexterity-based skills
	elif skill_lower in ["acrobatics", "sleight_of_hand", "stealth"]:
		return "dexterity"
	# Intelligence-based skills
	elif skill_lower in ["arcana", "history", "investigation", "nature", "religion"]:
		return "intelligence"
	# Wisdom-based skills
	elif skill_lower in ["animal_handling", "insight", "medicine", "perception", "survival"]:
		return "wisdom"
	# Charisma-based skills
	elif skill_lower in ["deception", "intimidation", "performance", "persuasion"]:
		return "charisma"
	else:
		return "general"

func load_races() -> void:
	"""Load races from .tres files"""
	var races_dir = "res://data/races/"
	var dir = DirAccess.open(races_dir)
	if not dir:
		print("Error: Could not open races directory")
		return

	var files = dir.get_files()
	for file_name in files:
		if file_name.ends_with(".tres"):
			var file_path = races_dir + file_name
			var race_resource = load(file_path) as RaceResource
			if race_resource and race_resource.name != "":
				# Fix type conversion issues
				if race_resource.speed is String:
					race_resource.speed = int(race_resource.speed)
				races[race_resource.name] = race_resource

	print("Loaded ", races.size(), " races")
	data_loaded.emit("races", races.size())

func load_classes() -> void:
	"""Load classes from .tres files"""
	var classes_dir = "res://data/classes/"
	var dir = DirAccess.open(classes_dir)
	if not dir:
		print("Error: Could not open classes directory")
		return

	var files = dir.get_files()
	for file_name in files:
		if file_name.ends_with(".tres"):
			var file_path = classes_dir + file_name
			var class_resource = load(file_path) as CharacterClassResource
			if class_resource and class_resource.name != "":
				classes[class_resource.name] = class_resource

	print("Loaded ", classes.size(), " classes")
	data_loaded.emit("classes", classes.size())

func load_spells() -> void:
	"""Load spells from .tres files"""
	var spells_dir = "res://data/spells/"
	var dir = DirAccess.open(spells_dir)
	if not dir:
		print("Error: Could not open spells directory")
		return

	var files = dir.get_files()
	for file_name in files:
		if file_name.ends_with(".tres"):
			var file_path = spells_dir + file_name
			var spell_resource = load(file_path) as SpellResource
			if spell_resource and spell_resource.spell_name != "":
				spells[spell_resource.spell_name] = spell_resource

	print("Loaded ", spells.size(), " spells")
	data_loaded.emit("spells", spells.size())

func load_monsters() -> void:
	"""Load monsters from .tres files"""
	var monsters_dir = "res://data/monsters/"
	var dir = DirAccess.open(monsters_dir)
	if not dir:
		print("Error: Could not open monsters directory")
		return

	var files = dir.get_files()
	for file_name in files:
		if file_name.ends_with(".tres"):
			var file_path = monsters_dir + file_name
			var monster_resource = load(file_path) as MonsterResource
			if monster_resource and monster_resource.name != "":
				monsters[monster_resource.name] = monster_resource

	print("Loaded ", monsters.size(), " monsters")
	data_loaded.emit("monsters", monsters.size())

func load_equipment() -> void:
	"""Load equipment from .tres files"""
	var equipment_dir = "res://data/equipment/"
	print("DEBUG: Attempting to open equipment directory: ", equipment_dir)
	var dir = DirAccess.open(equipment_dir)
	if not dir:
		print("Error: Could not open equipment directory: ", equipment_dir)
		print("DEBUG: DirAccess.open() returned null")
		return

	var files = dir.get_files()
	print("DEBUG: Found ", files.size(), " files in equipment directory")
	for file_name in files:
		if file_name.ends_with(".tres"):
			var file_path = equipment_dir + file_name
			print("DEBUG: Loading equipment file: ", file_path)
			var equipment_set_resource = load(file_path)
			if equipment_set_resource and equipment_set_resource.has_method("get") and equipment_set_resource.get("set_name") != "":
				# Convert EquipmentSetResource to EquipmentResource for compatibility
				var equipment_resource = EquipmentResource.new()
				equipment_resource.item_name = equipment_set_resource.get("set_name")
				equipment_resource.description = equipment_set_resource.get("description")
				equipment_resource.item_type = EquipmentResource.EquipmentType.ARMOR  # Equipment sets are typically armor
				equipment_resource.rarity = equipment_set_resource.get("rarity")
				equipment[equipment_resource.item_name] = equipment_resource

	print("Loaded ", equipment.size(), " equipment items")
	data_loaded.emit("equipment", equipment.size())

func load_magic_items() -> void:
	"""Load magic items from .tres files"""
	var magic_items_dir = "res://data/magic_items/"
	var dir = DirAccess.open(magic_items_dir)
	if not dir:
		print("Error: Could not open magic items directory")
		return

	var files = dir.get_files()
	for file_name in files:
		if file_name.ends_with(".tres"):
			var file_path = magic_items_dir + file_name
			var magic_item_resource = load(file_path) as MagicItemResource
			if magic_item_resource and magic_item_resource.name != "":
				magic_items[magic_item_resource.name] = magic_item_resource

	print("Loaded ", magic_items.size(), " magic items")
	data_loaded.emit("magic_items", magic_items.size())

func load_languages() -> void:
	"""Load languages from .tres files"""
	var languages_dir = "res://data/languages/"
	var dir = DirAccess.open(languages_dir)
	if not dir:
		print("Error: Could not open languages directory")
		return

	var files = dir.get_files()
	for file_name in files:
		if file_name.ends_with(".tres"):
			var file_path = languages_dir + file_name
			var language_resource = load(file_path) as LanguageResource
			if language_resource and language_resource.name != "":
				languages[language_resource.name] = language_resource

	print("Loaded ", languages.size(), " languages")
	data_loaded.emit("languages", languages.size())

func load_currencies() -> void:
	"""Load currencies from .tres files"""
	var currencies_dir = "res://data/currency/"
	var dir = DirAccess.open(currencies_dir)
	if not dir:
		print("Error: Could not open currencies directory")
		return

	var files = dir.get_files()
	for file_name in files:
		if file_name.ends_with(".tres"):
			var file_path = currencies_dir + file_name
			var currency_resource = load(file_path) as CurrencyResource
			if currency_resource and currency_resource.name != "":
				currencies[currency_resource.name] = currency_resource

	print("Loaded ", currencies.size(), " currencies")
	data_loaded.emit("currencies", currencies.size())

func load_alignments() -> void:
	"""Load alignments from .tres files"""
	var alignments_dir = "res://data/alignments/"
	var dir = DirAccess.open(alignments_dir)
	if not dir:
		print("Error: Could not open alignments directory")
		return

	var files = dir.get_files()
	for file_name in files:
		if file_name.ends_with(".tres"):
			var file_path = alignments_dir + file_name
			var resource = load(file_path) as Resource
			if resource and resource.has_meta("yaml_data"):
				var alignment_data = resource.get_meta("yaml_data")
				if alignment_data is Dictionary and alignment_data.has("name"):
					var alignment_resource = AlignmentResource.new()
					alignment_resource.name = alignment_data.get("name")
					alignment_resource.abbreviation = alignment_data.get("abbreviation")
					alignment_resource.description = alignment_data.get("description")
					alignment_resource.moral_axis = alignment_data.get("morality")
					alignment_resource.ethical_axis = alignment_data.get("attitude")
					alignments[alignment_resource.name] = alignment_resource

	print("Loaded ", alignments.size(), " alignments")
	data_loaded.emit("alignments", alignments.size())

func load_achievements() -> void:
	"""Load achievements from .tres files"""
	var achievements_file = "res://data/achievements.tres"
	if not FileAccess.file_exists(achievements_file):
		print("Error: Could not find achievements file")
		return

	var resource = load(achievements_file) as Resource
	if not resource or not resource.has_meta("yaml_data"):
		print("Error: Invalid achievements file format")
		return

	var achievements_data = resource.get_meta("yaml_data")
	if achievements_data is Array:
		for achievement_data in achievements_data:
			if achievement_data is Dictionary and achievement_data.has("id"):
				# Create a simple dictionary entry for now
				achievements[achievement_data["id"]] = achievement_data

	print("Loaded ", achievements.size(), " achievements")
	data_loaded.emit("achievements", achievements.size())

func load_lifestyles() -> void:
	"""Load lifestyles from .tres files"""
	var lifestyles_file = "res://data/lifestyles.tres"
	if not FileAccess.file_exists(lifestyles_file):
		print("Error: Could not find lifestyles file")
		return

	var resource = load(lifestyles_file) as Resource
	if not resource or not resource.has_meta("yaml_data"):
		print("Error: Invalid lifestyles file format")
		return

	var lifestyles_data = resource.get_meta("yaml_data")
	if lifestyles_data is Dictionary and lifestyles_data.has("lifestyles"):
		for lifestyle_data in lifestyles_data["lifestyles"]:
			if lifestyle_data is Dictionary and lifestyle_data.has("id"):
				lifestyles[lifestyle_data["id"]] = lifestyle_data

	print("Loaded ", lifestyles.size(), " lifestyles")
	data_loaded.emit("lifestyles", lifestyles.size())

func load_level_requirements() -> void:
	"""Load level requirements from .tres files"""
	var level_reqs_file = "res://data/level_requirements.tres"
	if not FileAccess.file_exists(level_reqs_file):
		print("Error: Could not find level requirements file")
		return

	var resource = load(level_reqs_file) as Resource
	if not resource or not resource.has_meta("yaml_data"):
		print("Error: Invalid level requirements file format")
		return

	var level_reqs_data = resource.get_meta("yaml_data")
	if level_reqs_data is Dictionary and level_reqs_data.has("level_requirements"):
		var level_reqs_dict = level_reqs_data["level_requirements"]
		if level_reqs_dict is Dictionary:
			for level_str in level_reqs_dict.keys():
				var level = int(level_str)
				var xp_required = level_reqs_dict[level_str]

				var requirement_resource = LevelRequirementResource.new()
				requirement_resource.level = level
				requirement_resource.experience_required = xp_required
				requirement_resource.config_name = "standard"

				level_requirements[level] = requirement_resource

	print("Loaded ", level_requirements.size(), " level requirements")
	data_loaded.emit("level_requirements", level_requirements.size())

func load_names() -> void:
	"""Load names from .tres files"""
	var names_file = "res://data/names.tres"
	if not FileAccess.file_exists(names_file):
		print("Error: Could not find names file")
		return

	var resource = load(names_file) as Resource
	if not resource or not resource.has_meta("yaml_data"):
		print("Error: Invalid names file format")
		return

	var names_data = resource.get_meta("yaml_data")
	if names_data is Dictionary:
		# Names file has first_names and last_names arrays of simple strings
		if names_data.has("first_names") and names_data["first_names"] is Array:
			for name_string in names_data["first_names"]:
				if name_string is String:
					var name_resource = NameResource.new()
					name_resource.name = name_string
					name_resource.category = "first_name"
					names[name_string] = name_resource
		if names_data.has("last_names") and names_data["last_names"] is Array:
			for name_string in names_data["last_names"]:
				if name_string is String:
					var name_resource = NameResource.new()
					name_resource.name = name_string
					name_resource.category = "last_name"
					names[name_string] = name_resource

	print("Loaded ", names.size(), " names")
	data_loaded.emit("names", names.size())

# Public API - Type-safe access methods

func get_activities_for_ability(ability: String) -> Array[ActivityResource]:
	"""Get all activities for a specific ability"""
	return activities.get(ability, [])

func get_all_activities() -> Dictionary:
	"""Get all activities organized by ability"""
	return activities.duplicate()

func get_activity_by_name(name: String) -> ActivityResource:
	"""Get a specific activity by name"""
	for ability_activities in activities.values():
		for activity in ability_activities:
			if activity.activity_name == name:
				return activity
	return null

func get_race_by_name(race_name: String) -> RaceResource:
	"""Get a race by name"""
	return races.get(race_name, null)

func get_all_races() -> Array[RaceResource]:
	"""Get all races"""
	var race_array: Array[RaceResource] = []
	for race_resource in races.values():
		race_array.append(race_resource)
	return race_array

func get_class_by_name(class_type: String) -> CharacterClassResource:
	"""Get a class by name"""
	return classes.get(class_type, null)

func get_all_classes() -> Array[CharacterClassResource]:
	"""Get all classes"""
	return classes.values()

func get_spell_by_name(spell_name: String) -> SpellResource:
	"""Get a spell by name"""
	return spells.get(spell_name, null)

func get_all_spells() -> Array[SpellResource]:
	"""Get all spells"""
	return spells.values()

func get_monster_by_name(monster_name: String) -> MonsterResource:
	"""Get a monster by name"""
	return monsters.get(monster_name, null)

func get_all_monsters() -> Array[MonsterResource]:
	"""Get all monsters"""
	return monsters.values()

func get_equipment_by_name(item_name: String) -> EquipmentResource:
	"""Get equipment by name"""
	return equipment.get(item_name, null)

func get_all_equipment() -> Array[EquipmentResource]:
	"""Get all equipment"""
	return equipment.values()

func get_magic_item_by_name(item_name: String) -> MagicItemResource:
	"""Get a magic item by name"""
	return magic_items.get(item_name, null)

func get_all_magic_items() -> Array[MagicItemResource]:
	"""Get all magic items"""
	return magic_items.values()

func get_language_by_name(language_name: String) -> LanguageResource:
	"""Get a language by name"""
	return languages.get(language_name, null)

func get_all_languages() -> Array[LanguageResource]:
	"""Get all languages"""
	return languages.values()

func get_currency_by_name(currency_name: String) -> CurrencyResource:
	"""Get a currency by name"""
	return currencies.get(currency_name, null)

func get_all_currencies() -> Array[CurrencyResource]:
	"""Get all currencies"""
	return currencies.values()

func get_alignment_by_name(alignment_name: String) -> AlignmentResource:
	"""Get an alignment by name"""
	return alignments.get(alignment_name, null)

func get_all_alignments() -> Array[AlignmentResource]:
	"""Get all alignments"""
	return alignments.values()

func get_achievement_by_id(achievement_id: String) -> AchievementResource:
	"""Get an achievement by ID"""
	return achievements.get(achievement_id, null)

func get_all_achievements() -> Array[AchievementResource]:
	"""Get all achievements"""
	return achievements.values()

func get_lifestyle_by_id(lifestyle_id: String) -> LifestyleResource:
	"""Get a lifestyle by ID"""
	return lifestyles.get(lifestyle_id, null)

func get_all_lifestyles() -> Array[LifestyleResource]:
	"""Get all lifestyles"""
	return lifestyles.values()

func get_level_requirement(level: int) -> LevelRequirementResource:
	"""Get level requirement for a specific level"""
	return level_requirements.get(level, null)

func get_all_level_requirements() -> Array:
	"""Get all level requirements"""
	return level_requirements.values()

func get_name_by_name(name_string: String) -> NameResource:
	"""Get a name resource by name"""
	return names.get(name_string, null)

func get_all_names() -> Array:
	"""Get all names"""
	return names.values()

# Utility methods

func get_data_summary() -> Dictionary:
	"""Get summary of all loaded data"""
	return {
		"activities": _count_activities(),
		"races": races.size(),
		"classes": classes.size(),
		"spells": spells.size(),
		"monsters": monsters.size(),
		"equipment": equipment.size(),
		"magic_items": magic_items.size(),
		"languages": languages.size(),
		"currencies": currencies.size(),
		"alignments": alignments.size(),
		"achievements": achievements.size(),
		"lifestyles": lifestyles.size(),
		"level_requirements": level_requirements.size(),
		"names": names.size()
	}

func _count_activities() -> int:
	"""Count total activities across all abilities"""
	var count = 0
	for ability_activities in activities.values():
		count += ability_activities.size()
	return count
