extends Node

# Class Resource Manager
# Manages character classes using .tres Resource files for type safety

class_name ClassResourceManager

# Resource storage
var classes: Dictionary = {} # class_name -> CharacterClassResource
var classes_by_hit_die: Dictionary = {} # hit_die -> Array[CharacterClassResource]
var classes_by_spellcasting: Dictionary = {} # spellcasting_ability -> Array[CharacterClassResource]

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


	load_all_classes()

func _init() -> void:
	# Initialize data loader early for immediate use
	data_loader = ResourceDataLoader.new()

# Load all classes from .tres files
func load_all_classes() -> void:
	if not data_loader:
		print("Error: Data loader not initialized")
		return

	# Wait for data loader to finish loading
	await data_loader.data_loaded

	# Get classes from data loader
	var all_classes = data_loader.get_all_classes()

	# Populate our storage
	for class_resource in all_classes:
		classes[class_resource.name] = class_resource

	# Organize classes by various criteria
	organize_classes()

	print("Loaded " + str(classes.size()) + " class resources")

# Organize classes by various criteria
func organize_classes() -> void:
	# Clear existing organization
	classes_by_hit_die.clear()
	classes_by_spellcasting.clear()

	# Organize classes
	for class_resource in classes.values():
		# By hit die
		var hit_die = class_resource.hit_die
		if not classes_by_hit_die.has(hit_die):
			classes_by_hit_die[hit_die] = []
		classes_by_hit_die[hit_die].append(class_resource)

		# By spellcasting ability
		var spellcasting_ability = class_resource.spellcasting_ability
		if spellcasting_ability != "":
			if not classes_by_spellcasting.has(spellcasting_ability):
				classes_by_spellcasting[spellcasting_ability] = []
			classes_by_spellcasting[spellcasting_ability].append(class_resource)

# Public API

func get_class_resource(class_type: String) -> CharacterClassResource:
	"""Get class resource by name"""
	return classes.get(class_type, null)

func get_all_classes() -> Array[CharacterClassResource]:
	"""Get all class resources"""
	var all_classes: Array[CharacterClassResource] = []
	for class_resource in classes.values():
		all_classes.append(class_resource)
	return all_classes

func get_classes_by_hit_die(hit_die: int) -> Array[CharacterClassResource]:
	"""Get all classes with a specific hit die"""
	return classes_by_hit_die.get(hit_die, [])

func get_spellcasting_classes(spellcasting_ability: String) -> Array[CharacterClassResource]:
	"""Get all classes that use a specific spellcasting ability"""
	return classes_by_spellcasting.get(spellcasting_ability, [])

func get_martial_classes() -> Array[CharacterClassResource]:
	"""Get all martial (non-spellcasting) classes"""
	var martial_classes: Array[CharacterClassResource] = []
	for class_resource in classes.values():
		if class_resource.spellcasting_ability == "":
			martial_classes.append(class_resource)
	return martial_classes

func get_spellcasting_classes_all() -> Array[CharacterClassResource]:
	"""Get all spellcasting classes"""
	var spellcasting_classes: Array[CharacterClassResource] = []
	for class_resource in classes.values():
		if class_resource.spellcasting_ability != "":
			spellcasting_classes.append(class_resource)
	return spellcasting_classes

# Character class management

func can_character_choose_class(character: Character, class_type: String) -> bool:
	"""Check if character can choose a specific class"""
	var class_resource = get_class_resource(class_type)
	if class_resource == null:
		return false

	# For now, any character can choose any class
	# In a full implementation, this would check:
	# - Race restrictions
	# - Alignment restrictions
	# - Prerequisites

	return true

func assign_class_to_character(character: Character, class_type: String) -> bool:
	"""Assign a class to a character"""
	var class_resource = get_class_resource(class_type)
	if class_resource == null:
		print("Class not found: " + class_type)
		return false

	if not can_character_choose_class(character, class_type):
		print("Character cannot choose class: " + class_type)
		return false

	# Assign the class
	character.character_class = class_type

	# Apply class benefits
	apply_class_benefits(character, class_resource)

	print(character.name + " chose class: " + class_type)
	return true

func apply_class_benefits(character: Character, class_resource: CharacterClassResource) -> void:
	"""Apply class benefits to a character"""
	# Set hit points
	var constitution_modifier = get_ability_modifier(character.constitution)
	character.max_hit_points = class_resource.get_hit_points_at_level(character.level, constitution_modifier)
	character.hit_points = character.max_hit_points

	# Set proficiencies
	character.saving_throw_proficiencies = class_resource.saving_throws.duplicate()

	# Add skill proficiencies (character chooses from options)
	# This would be handled by the character creation UI

	# Set armor and weapon proficiencies
	# These would be stored in character data for equipment system

	# Set spellcasting ability
	if class_resource.spellcasting_ability != "":
		# Initialize spell slots
		character.update_spell_slots_for_level()

func calculate_spell_slots_for_class(character: Character, class_resource: CharacterClassResource) -> Dictionary:
	"""Calculate spell slots for a character based on their class and level"""
	var spell_slots = {}

	# Get spell slots per level from class
	var slots_per_level = class_resource.spell_slots_per_level

	# Calculate slots for current level
	for level in range(1, character.level + 1):
		if level <= slots_per_level.size():
			spell_slots[level] = slots_per_level[level - 1]
		else:
			spell_slots[level] = 0

	return spell_slots

func get_class_features_for_level(class_type: String, level: int) -> Array[String]:
	"""Get class features available at a specific level"""
	var class_resource = get_class_resource(class_type)
	if class_resource == null:
		return []

	return class_resource.get_features_at_level(level)

func get_proficiency_bonus_for_level(level: int) -> int:
	"""Get proficiency bonus for a character level"""
	# Standard D&D proficiency bonus progression
	return 2 + floor((level - 1) / 4.0)

func get_hit_points_for_level(class_type: String, level: int, constitution_modifier: int) -> int:
	"""Get hit points for a character at a specific level"""
	var class_resource = get_class_resource(class_type)
	if class_resource == null:
		return 8 + constitution_modifier  # Default hit die

	return class_resource.get_hit_points_at_level(level, constitution_modifier)

# Class comparison and analysis

func compare_classes(class1_name: String, class2_name: String) -> Dictionary:
	"""Compare two classes and return differences"""
	var class1 = get_class_resource(class1_name)
	var class2 = get_class_resource(class2_name)

	if class1 == null or class2 == null:
		return {"error": "One or both classes not found"}

	return {
		"hit_die_difference": class1.hit_die - class2.hit_die,
		"spellcasting_difference": class1.spellcasting_ability != "" and class2.spellcasting_ability == "",
		"skill_choices_difference": class1.skill_choices - class2.skill_choices,
		"armor_proficiencies_difference": class1.armor_proficiencies.size() - class2.armor_proficiencies.size(),
		"weapon_proficiencies_difference": class1.weapon_proficiencies.size() - class2.weapon_proficiencies.size()
	}

func get_class_recommendations_for_character(character: Character) -> Array[CharacterClassResource]:
	"""Get class recommendations based on character's ability scores"""
	var recommendations: Array[CharacterClassResource] = []

	# Find classes that match character's highest abilities
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

	# Find classes that use the top abilities
	for class_resource in classes.values():
		var match_score = 0

		# Check if class uses character's top abilities
		if class_resource.primary_ability == sorted_abilities[0].ability:
			match_score += 3
		elif class_resource.primary_ability == sorted_abilities[1].ability:
			match_score += 2
		elif class_resource.primary_ability == sorted_abilities[2].ability:
			match_score += 1

		# Check saving throw proficiencies
		for saving_throw in class_resource.saving_throws:
			if saving_throw.to_lower() == sorted_abilities[0].ability:
				match_score += 1
			elif saving_throw.to_lower() == sorted_abilities[1].ability:
				match_score += 0.5

		if match_score > 0:
			recommendations.append(class_resource)

	# Sort by match score
	recommendations.sort_custom(func(a, b): return get_class_match_score(character, a) > get_class_match_score(character, b))

	return recommendations

func get_class_match_score(character: Character, class_resource: CharacterClassResource) -> float:
	"""Calculate how well a class matches a character"""
	var score = 0.0

	# Primary ability bonus
	var primary_ability_score = character.get(class_resource.primary_ability)
	score += primary_ability_score * 0.1

	# Saving throw proficiencies bonus
	for saving_throw in class_resource.saving_throws:
		var ability_score = character.get(saving_throw.to_lower())
		score += ability_score * 0.05

	return score

# Utility functions

func get_ability_modifier(ability_score: int) -> int:
	"""Get ability modifier from ability score"""
	return floor((ability_score - 10) / 2.0)

func get_class_statistics() -> Dictionary:
	"""Get statistics about loaded classes"""
	var stats = {
		"total_classes": classes.size(),
		"by_hit_die": {},
		"by_spellcasting": {},
		"martial_classes": 0,
		"spellcasting_classes": 0
	}

	# Count by hit die
	for hit_die in classes_by_hit_die.keys():
		stats.by_hit_die[hit_die] = classes_by_hit_die[hit_die].size()

	# Count by spellcasting ability
	for ability in classes_by_spellcasting.keys():
		stats.by_spellcasting[ability] = classes_by_spellcasting[ability].size()

	# Count martial vs spellcasting
	for class_resource in classes.values():
		if class_resource.spellcasting_ability == "":
			stats.martial_classes += 1
		else:
			stats.spellcasting_classes += 1

	return stats

func print_class_summary() -> void:
	"""Print summary of loaded classes"""
	var stats = get_class_statistics()
	print("=== Class Summary ===")
	print("Total classes: " + str(stats.total_classes))
	print("By hit die: " + str(stats.by_hit_die))
	print("By spellcasting: " + str(stats.by_spellcasting))
	print("Martial classes: " + str(stats.martial_classes))
	print("Spellcasting classes: " + str(stats.spellcasting_classes))

# Helper functions

func _class_resource_to_dict(class_resource: CharacterClassResource) -> Dictionary:
	"""Convert CharacterClassResource to legacy Dictionary format"""
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
		"starting_equipment": class_resource.starting_equipment,
		"features": class_resource.features,
		"spellcasting_ability": class_resource.spellcasting_ability,
		"spell_slots_per_level": class_resource.spell_slots_per_level,
		"level_features": class_resource.level_features
	}
