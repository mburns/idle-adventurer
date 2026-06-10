extends Node

class_name CharacterCreation

signal character_created(character: Character)

# Resource managers for type-safe character creation
var class_manager: ClassResourceManager
var race_manager: RaceResourceManager

func _init():
	# Use global managers from AutoloadManager if available
	if Engine.has_singleton("AutoloadManager"):
		var autoload_manager = Engine.get_singleton("AutoloadManager")
		if autoload_manager:
			class_manager = autoload_manager.class_manager
			race_manager = autoload_manager.race_manager
			print("DEBUG: Character creation - using AutoloadManager managers")
		else:
			_create_fallback_managers()
	else:
		_create_fallback_managers()

func _create_fallback_managers():
	"""Create fallback managers if AutoloadManager is not available"""
	class_manager = ClassResourceManager.new()
	race_manager = RaceResourceManager.new()
	add_child(class_manager)
	add_child(race_manager)

	# Ensure data is loaded since _ready() might not be called immediately
	class_manager.load_all_classes()
	race_manager.load_all_races()

	# Force load races directly if the race manager has no races
	if race_manager.get_all_races().is_empty():
		_load_races_directly()

	# Force load classes directly if the class manager has no classes
	if class_manager.get_all_classes().is_empty():
		_load_classes_directly()

func _load_races_directly():
	"""Load races directly from .tres files as a fallback"""
	var races_dir = "res://data/races/"
	var dir = DirAccess.open(races_dir)
	if not dir:
		return

	var files = dir.get_files()
	for file_name in files:
		if file_name.ends_with(".tres"):
			var file_path = races_dir + file_name
			var race_resource = load(file_path) as RaceResource
			if race_resource and race_resource.name != "":
				# Add directly to the race manager's storage
				race_manager.races[race_resource.name] = race_resource

func _load_classes_directly():
	"""Load classes directly from .tres files as a fallback"""
	var classes_dir = "res://data/classes/"
	var dir = DirAccess.open(classes_dir)
	if not dir:
		return

	var files = dir.get_files()
	for file_name in files:
		if file_name.ends_with(".tres"):
			var file_path = classes_dir + file_name
			var class_resource = load(file_path) as CharacterClassResource
			if class_resource and class_resource.name != "":
				# Add directly to the class manager's storage
				class_manager.classes[class_resource.name] = class_resource

func _ready():
	"""Try to use AutoloadManager managers if they're now available"""
	if not Engine.has_singleton("AutoloadManager"):
		return

	var autoload_manager = Engine.get_singleton("AutoloadManager")
	if autoload_manager and autoload_manager.class_manager and autoload_manager.race_manager:
		# Remove fallback managers if we created them
		if class_manager and is_instance_valid(class_manager) and class_manager.get_parent() == self:
			remove_child(class_manager)
			class_manager.queue_free()
		if race_manager and is_instance_valid(race_manager) and race_manager.get_parent() == self:
			remove_child(race_manager)
			race_manager.queue_free()

		# Use AutoloadManager managers
		class_manager = autoload_manager.class_manager
		race_manager = autoload_manager.race_manager

func create_character(character_name: String, race: String, character_class: String, background: String) -> Character:
	var character = Character.new()
	character.name = character_name
	character.race = race
	character.character_class = character_class
	character.background = background

	# Apply race benefits using Resource
	var race_resource = get_race_resource(race)
	if race_resource != null:
		apply_racial_benefits(character, race_resource)

	# Apply class benefits using Resource
	var class_resource = class_manager.get_class_resource(character_class)
	if class_resource != null:
		class_manager.apply_class_benefits(character, class_resource)

	character_created.emit(character)
	return character

func create_random_character() -> Character:
	# Use class resource manager for type-safe class selection
	var races = get_available_races()
	var classes = get_available_classes()
	var backgrounds = get_available_backgrounds()

	# Check for empty arrays to prevent modulo by zero errors
	if races.is_empty():
		print("Error: No races available for random character creation")
		return null
	if classes.is_empty():
		print("Error: No classes available for random character creation")
		return null
	if backgrounds.is_empty():
		print("Error: No backgrounds available for random character creation")
		return null

	var random_race = races[randi() % races.size()]
	var random_class = classes[randi() % classes.size()]
	var random_background = backgrounds[randi() % backgrounds.size()]

	var random_name = "TestCharacter" + str(randi() % 1000)

	return create_character(random_name, random_race, random_class, random_background)

func validate_character_creation(character_name: String, _race: String, _class_type: String, _background: String) -> bool:
	if character_name.is_empty():
		return false
	return true

func get_available_races() -> Array[String]:
	# Try to use AutoloadManager race manager first
	if Engine.has_singleton("AutoloadManager"):
		var autoload_manager = Engine.get_singleton("AutoloadManager")
		if autoload_manager and autoload_manager.race_manager:
			var race_names: Array[String] = []
			var all_races = autoload_manager.race_manager.get_all_races()
			if all_races.size() > 0:
				for race_resource in all_races:
					race_names.append(race_resource.name)
				return race_names

	# Fallback to local race manager
	var race_names: Array[String] = []
	var all_races = race_manager.get_all_races()
	for race_resource in all_races:
		race_names.append(race_resource.name)
	return race_names

func get_available_classes() -> Array[String]:
	# Use class resource manager for type-safe class names
	var class_names: Array[String] = []
	for class_resource in class_manager.get_all_classes():
		class_names.append(class_resource.name)
	return class_names

func get_available_backgrounds() -> Array[String]:
	# Use Resource manager for backgrounds (when implemented)
	# For now, return hardcoded backgrounds
	return ["Acolyte", "Criminal", "Folk Hero", "Noble"]

# New Resource-based functions

func get_class_resource(class_type: String) -> CharacterClassResource:
	"""Get class resource by name"""
	return class_manager.get_class_resource(class_type)

func get_class_recommendations_for_abilities(abilities: Dictionary) -> Array[CharacterClassResource]:
	"""Get class recommendations based on ability scores"""
	# Create temporary character for recommendations
	var temp_character = Character.new()
	temp_character.strength = abilities.get("strength", 10)
	temp_character.dexterity = abilities.get("dexterity", 10)
	temp_character.constitution = abilities.get("constitution", 10)
	temp_character.intelligence = abilities.get("intelligence", 10)
	temp_character.wisdom = abilities.get("wisdom", 10)
	temp_character.charisma = abilities.get("charisma", 10)

	return class_manager.get_class_recommendations_for_character(temp_character)

func get_class_details(class_type: String) -> Dictionary:
	"""Get detailed information about a class"""
	var class_resource = class_manager.get_class_resource(class_type)
	if class_resource == null:
		return {}

	return {
		"name": class_resource.name,
		"hit_die": class_resource.hit_die,
		"primary_ability": class_resource.primary_ability,
		"saving_throws": class_resource.saving_throws,
		"skill_choices": class_resource.skill_choices,
		"skill_options": class_resource.skill_options,
		"armor_proficiencies": class_resource.armor_proficiencies,
		"weapon_proficiencies": class_resource.weapon_proficiencies,
		"tool_proficiencies": class_resource.tool_proficiencies,
		"spellcasting_ability": class_resource.spellcasting_ability,
		"features": class_resource.features
	}

func validate_class_selection(class_type: String) -> bool:
	"""Validate if a class can be selected"""
	var class_resource = class_manager.get_class_resource(class_type)
	return class_resource != null

func validate_race_selection(race_name: String) -> bool:
	"""Validate if a race can be selected"""
	var race_resource = race_manager.get_race(race_name)
	return race_resource != null

# New Race-based functions

func get_race_resource(race_name: String) -> RaceResource:
	"""Get race resource by name, preferring AutoloadManager"""
	if Engine.has_singleton("AutoloadManager"):
		var autoload_manager = Engine.get_singleton("AutoloadManager")
		if autoload_manager and autoload_manager.race_manager:
			return autoload_manager.race_manager.get_race(race_name)

	# Fallback to local race manager
	return race_manager.get_race(race_name)

func apply_racial_benefits(character: Character, race_resource: RaceResource):
	"""Apply racial benefits to character"""
	if Engine.has_singleton("AutoloadManager"):
		var autoload_manager = Engine.get_singleton("AutoloadManager")
		if autoload_manager and autoload_manager.race_manager:
			autoload_manager.race_manager.apply_racial_benefits(character, race_resource)
			return

	# Fallback to local race manager
	race_manager.apply_racial_benefits(character, race_resource)

func get_race_recommendations_for_class(class_type: String) -> Array[RaceResource]:
	"""Get race recommendations based on class"""
	var temp_character = Character.new()
	temp_character.character_class = class_type
	return race_manager.get_race_recommendations_for_character(temp_character)

func get_race_details(race_name: String) -> Dictionary:
	"""Get detailed information about a race"""
	var race_resource = race_manager.get_race(race_name)
	if race_resource == null:
		return {}

	return {
		"name": race_resource.name,
		"ability_increases": race_resource.ability_increases,
		"size": race_resource.size,
		"speed": race_resource.speed,
		"height_range": race_resource.height_range,
		"weight_range": race_resource.weight_range,
		"languages": race_resource.languages,
		"traits": race_resource.traits,
		"darkvision": race_resource.darkvision,
		"resistances": race_resource.resistances,
		"immunities": race_resource.immunities,
		"vulnerabilities": race_resource.vulnerabilities,
		"subraces": race_resource.subraces
	}

func get_race_summary(race_name: String) -> String:
	"""Get a summary of a race"""
	var race_resource = race_manager.get_race(race_name)
	if race_resource == null:
		return "Race not found"

	return race_resource.get_race_summary()

func compare_races(race1_name: String, race2_name: String) -> Dictionary:
	"""Compare two races"""
	return race_manager.compare_races(race1_name, race2_name)
