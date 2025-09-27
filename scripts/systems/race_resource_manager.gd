extends Node

# Race Resource Manager
# Manages races using .tres Resource files for type safety

class_name RaceResourceManager

# Resource storage
var races: Dictionary = {} # race_name -> RaceResource
var races_by_size: Dictionary = {} # size -> Array[RaceResource]
var races_by_speed: Dictionary = {} # speed -> Array[RaceResource]

# Resource data loader
var data_loader: ResourceDataLoader

func _ready() -> void:
	# Use global data loader if available
	if Engine.has_singleton("AutoloadManager"):
		var autoload_manager = Engine.get_singleton("AutoloadManager")
		if autoload_manager and autoload_manager.data_loader:
			data_loader = autoload_manager.data_loader
		else:
			data_loader = ResourceDataLoader.new()

	else:
		data_loader = ResourceDataLoader.new()

	# Connect to data loaded signal
	if data_loader and data_loader.has_signal("data_loaded"):
		data_loader.data_loaded.connect(_on_data_loaded)

	load_all_races()

# Signal handler for data loading
func _on_data_loaded(data_type: String, count: int) -> void:
	if data_type == "races":
		_load_races_from_data_loader()

# Load all races from .tres files
func load_all_races() -> void:
	if not data_loader:
		print("Error: Data loader not initialized")
		return

	# Try to load races immediately if data is already available
	_load_races_from_data_loader()

# Internal method to load races from data loader
func _load_races_from_data_loader() -> void:
	if not data_loader:
		return

	# Get races from data loader
	var all_races = data_loader.get_all_races()
	if all_races.is_empty():
		return

	# Populate our storage
	for race_resource in all_races:
		races[race_resource.name] = race_resource

	# Organize races by various criteria
	organize_races()

	print("Loaded " + str(races.size()) + " race resources")

# Organize races by various criteria
func organize_races() -> void:
	# Clear existing organization
	races_by_size.clear()
	races_by_speed.clear()

	# Organize races
	for race_resource in races.values():
		# By size
		var size = race_resource.size.to_lower()
		if not races_by_size.has(size):
			races_by_size[size] = []
		races_by_size[size].append(race_resource)

		# By speed
		var speed = race_resource.speed
		if not races_by_speed.has(speed):
			races_by_speed[speed] = []
		races_by_speed[speed].append(race_resource)

# Public API

func get_race(race_name: String) -> RaceResource:
	"""Get race resource by name"""
	return races.get(race_name, null)

func get_all_races() -> Array[RaceResource]:
	"""Get all race resources"""
	var all_races: Array[RaceResource] = []
	for race_resource in races.values():
		all_races.append(race_resource)
	return all_races

func get_races_by_size(size: String) -> Array[RaceResource]:
	"""Get all races of a specific size"""
	return races_by_size.get(size.to_lower(), [])

func get_races_by_speed(speed: int) -> Array[RaceResource]:
	"""Get all races with a specific speed"""
	return races_by_speed.get(speed, [])

func get_medium_races() -> Array[RaceResource]:
	"""Get all medium-sized races"""
	return get_races_by_size("medium")

func get_small_races() -> Array[RaceResource]:
	"""Get all small-sized races"""
	return get_races_by_size("small")

func get_large_races() -> Array[RaceResource]:
	"""Get all large-sized races"""
	return get_races_by_size("large")

func get_races_with_darkvision() -> Array[RaceResource]:
	"""Get all races with darkvision"""
	var darkvision_races: Array[RaceResource] = []
	for race_resource in races.values():
		if race_resource.has_darkvision():
			darkvision_races.append(race_resource)
	return darkvision_races

func get_races_with_resistance(damage_type: String) -> Array[RaceResource]:
	"""Get all races with resistance to a specific damage type"""
	var resistant_races: Array[RaceResource] = []
	for race_resource in races.values():
		if race_resource.has_resistance(damage_type):
			resistant_races.append(race_resource)
	return resistant_races

# Character race management

func can_character_choose_race(character: Character, race_name: String) -> bool:
	"""Check if character can choose a specific race"""
	var race_resource = get_race(race_name)
	if race_resource == null:
		return false

	# For now, any character can choose any race
	# In a full implementation, this would check:
	# - Class restrictions
	# - Alignment restrictions
	# - Prerequisites

	return true

func assign_race_to_character(character: Character, race_name: String) -> bool:
	"""Assign a race to a character"""
	var race_resource = get_race(race_name)
	if race_resource == null:
		print("Race not found: " + race_name)
		return false

	if not can_character_choose_race(character, race_name):
		print("Character cannot choose race: " + race_name)
		return false

	# Assign the race
	character.race = race_name

	# Apply racial benefits
	apply_racial_benefits(character, race_resource)

	print(character.name + " chose race: " + race_name)
	return true

func apply_racial_benefits(character: Character, race_resource: RaceResource) -> void:
	"""Apply racial benefits to a character"""
	# Apply ability score increases
	for ability in race_resource.ability_increases.keys():
		var current_score = character.get(ability)
		var increase = race_resource.ability_increases[ability]
		character.set(ability, current_score + increase)

	# Set size and speed
	character.size = race_resource.size
	character.speed = race_resource.speed

	# Add languages
	for language in race_resource.languages:
		if language not in character.known_languages:
			character.known_languages.append(language)

	# Store racial traits
	character.racial_traits = race_resource.racial_traits.duplicate()

	# Apply other racial benefits
	if race_resource.has_darkvision():
		# This would be handled by the vision system
		pass

	# Apply resistances, immunities, vulnerabilities
	# These would be stored in character data for the combat system

# Race comparison and analysis

func compare_races(race1_name: String, race2_name: String) -> Dictionary:
	"""Compare two races and return differences"""
	var race1 = get_race(race1_name)
	var race2 = get_race(race2_name)

	if race1 == null or race2 == null:
		return {"error": "One or both races not found"}

	return {
		"size_difference": race1.size != race2.size,
		"speed_difference": race1.speed - race2.speed,
		"ability_increases_difference": _compare_ability_increases(race1.ability_increases, race2.ability_increases),
		"darkvision_difference": race1.darkvision - race2.darkvision,
		"trait_count_difference": race1.racial_traits.size() - race2.racial_traits.size()
	}

func _compare_ability_increases(increases1: Dictionary, increases2: Dictionary) -> Dictionary:
	"""Compare ability increases between two races"""
	var comparison = {}
	var all_abilities = ["strength", "dexterity", "constitution", "intelligence", "wisdom", "charisma"]

	for ability in all_abilities:
		var increase1 = increases1.get(ability, 0)
		var increase2 = increases2.get(ability, 0)
		comparison[ability] = increase1 - increase2

	return comparison

func get_race_recommendations_for_character(character: Character) -> Array[RaceResource]:
	"""Get race recommendations based on character's intended class"""
	var recommendations: Array[RaceResource] = []

	# Get character's class to determine optimal race
	var class_type = character.character_class
	if class_type == "":
		# If no class selected, recommend based on ability scores
		return get_race_recommendations_for_abilities(character)

	# Find races that complement the class
	for race_resource in races.values():
		var match_score = calculate_race_class_match_score(race_resource, class_type)
		if match_score > 0:
			recommendations.append(race_resource)

	# Sort by match score
	recommendations.sort_custom(func(a, b): return calculate_race_class_match_score(a, class_type) > calculate_race_class_match_score(b, class_type))

	return recommendations

func get_race_recommendations_for_abilities(character: Character) -> Array[RaceResource]:
	"""Get race recommendations based on character's ability scores"""
	var recommendations: Array[RaceResource] = []

	# Find races that boost character's highest abilities
	var abilities = {
		"strength": character.strength,
		"dexterity": character.dexterity,
		"constitution": character.constitution,
		"intelligence": character.intelligence,
		"wisdom": character.wisdom,
		"charisma": character.charisma
	}

	# Sort abilities by score
	var sorted_abilities = []
	for ability in abilities.keys():
		sorted_abilities.append({"ability": ability, "score": abilities[ability]})
	sorted_abilities.sort_custom(func(a, b): return a.score > b.score)

	# Find races that boost top abilities
	for race_resource in races.values():
		var match_score = 0

		# Check if race boosts character's top abilities
		for ability_increase in race_resource.ability_increases.keys():
			for i in range(min(3, sorted_abilities.size())):  # Top 3 abilities
				if ability_increase == sorted_abilities[i].ability:
					match_score += (4 - i) * race_resource.ability_increases[ability_increase]

		if match_score > 0:
			recommendations.append(race_resource)

	# Sort by match score
	recommendations.sort_custom(func(a, b): return calculate_race_ability_match_score(a, character) > calculate_race_ability_match_score(b, character))

	return recommendations

func calculate_race_class_match_score(race_resource: RaceResource, class_type: String) -> float:
	"""Calculate how well a race matches a class"""
	var score = 0.0

	# This would be implemented based on your class-race synergy system
	# For now, return a basic score based on ability increases

	# Example: Fighters benefit from Strength and Constitution
	if class_type.to_lower() == "fighter":
		score += race_resource.get_ability_modifier("strength") * 2
		score += race_resource.get_ability_modifier("constitution") * 1.5

	# Example: Wizards benefit from Intelligence
	elif class_type.to_lower() == "wizard":
		score += race_resource.get_ability_modifier("intelligence") * 3

	# Example: Rogues benefit from Dexterity
	elif class_type.to_lower() == "rogue":
		score += race_resource.get_ability_modifier("dexterity") * 2.5

	return score

func calculate_race_ability_match_score(race_resource: RaceResource, character: Character) -> float:
	"""Calculate how well a race matches a character's abilities"""
	var score = 0.0

	# Boost score for races that increase character's highest abilities
	var abilities = {
		"strength": character.strength,
		"dexterity": character.dexterity,
		"constitution": character.constitution,
		"intelligence": character.intelligence,
		"wisdom": character.wisdom,
		"charisma": character.charisma
	}

	for ability in abilities.keys():
		var current_score = abilities[ability]
		var racial_bonus = race_resource.get_ability_modifier(ability)

		# Higher scores get more weight
		score += current_score * racial_bonus * 0.1

	return score

# Utility functions

func get_race_statistics() -> Dictionary:
	"""Get statistics about loaded races"""
	var stats = {
		"total_races": races.size(),
		"by_size": {},
		"by_speed": {},
		"with_darkvision": 0,
		"with_resistances": 0
	}

	# Count by size
	for size in races_by_size.keys():
		stats.by_size[size] = races_by_size[size].size()

	# Count by speed
	for speed in races_by_speed.keys():
		stats.by_speed[speed] = races_by_speed[speed].size()

	# Count special features
	for race_resource in races.values():
		if race_resource.has_darkvision():
			stats.with_darkvision += 1
		if not race_resource.resistances.is_empty():
			stats.with_resistances += 1

	return stats

func print_race_summary() -> void:
	"""Print summary of loaded races"""
	var stats = get_race_statistics()
	print("=== Race Summary ===")
	print("Total races: " + str(stats.total_races))
	print("By size: " + str(stats.by_size))
	print("By speed: " + str(stats.by_speed))
	print("With darkvision: " + str(stats.with_darkvision))
	print("With resistances: " + str(stats.with_resistances))

# Helper functions

func _race_resource_to_dict(race_resource: RaceResource) -> Dictionary:
	"""Convert RaceResource to legacy Dictionary format"""
	return {
		"name": race_resource.name,
		"ability_increases": race_resource.ability_increases,
		"size": race_resource.size,
		"speed": race_resource.speed,
		"height_range": race_resource.height_range,
		"weight_range": race_resource.weight_range,
		"languages": race_resource.languages,
		"traits": race_resource.racial_traits,
		"darkvision": race_resource.darkvision,
		"resistances": race_resource.resistances,
		"immunities": race_resource.immunities,
		"vulnerabilities": race_resource.vulnerabilities,
		"subraces": race_resource.subraces
	}
