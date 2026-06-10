extends Node

# Spell Resource Manager
# Manages spells using .tres Resource files for type safety

class_name SpellResourceManager

# Resource storage
var spells: Dictionary = {} # spell_name -> SpellResource
var spells_by_level: Dictionary = {} # level -> Array[SpellResource]
var spells_by_school: Dictionary = {} # school -> Array[SpellResource]
var spells_by_class: Dictionary = {} # class -> Array[SpellResource]

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
		

	load_all_spells()

func _init():
	# Initialize data loader early for immediate use
	data_loader = ResourceDataLoader.new()

# Load all spells from .tres files
func load_all_spells() -> void:
	if not data_loader:
		print("Error: Data loader not initialized")
		return

	# Wait for data loader to finish loading
	await data_loader.data_loaded

	# Get spells from data loader
	var all_spells = data_loader.get_all_spells()

	# Populate our storage
	for spell_resource in all_spells:
		spells[spell_resource.name] = spell_resource

	# Organize spells by level, school, and class
	organize_spells()

	print("Loaded " + str(spells.size()) + " spell resources")


# Organize spells by various criteria
func organize_spells() -> void:
	# Clear existing organization
	spells_by_level.clear()
	spells_by_school.clear()
	spells_by_class.clear()

	# Initialize arrays for each level (0-9)
	for level in range(10):
		spells_by_level[level] = []

	# Organize spells
	for spell in spells.values():
		# By level
		var level = spell.level
		if spells_by_level.has(level):
			spells_by_level[level].append(spell)

		# By school
		var school = spell.school.to_lower()
		if not spells_by_school.has(school):
			spells_by_school[school] = []
		spells_by_school[school].append(spell)

		# By class
		for class_type in spell.classes:
			if not spells_by_class.has(class_type):
				spells_by_class[class_type] = []
			spells_by_class[class_type].append(spell)

# Public API

func get_spell(spell_name: String) -> SpellResource:
	"""Get spell resource by name"""
	return spells.get(spell_name, null)

func get_spells_by_level(level: int) -> Array[SpellResource]:
	"""Get all spells of a specific level"""
	return spells_by_level.get(level, [])

func get_spells_by_school(school: String) -> Array[SpellResource]:
	"""Get all spells of a specific school"""
	return spells_by_school.get(school.to_lower(), [])

func get_spells_by_class(class_type: String) -> Array[SpellResource]:
	"""Get all spells available to a specific class"""
	return spells_by_class.get(class_type, [])

func get_cantrips() -> Array[SpellResource]:
	"""Get all cantrips (level 0 spells)"""
	return get_spells_by_level(0)

func get_spells_for_character(character: Character) -> Array[SpellResource]:
	"""Get all spells available to a character based on their class and level"""
	var available_spells: Array[SpellResource] = []

	# Get character's class spells
	var class_spells = get_spells_by_class(character.character_class)

	for spell in class_spells:
		# Check if character is high enough level
		if character.level >= get_minimum_level_for_spell(spell):
			available_spells.append(spell)

	return available_spells

func get_minimum_level_for_spell(spell: SpellResource) -> int:
	"""Get minimum character level required to cast a spell"""
	if spell.is_cantrip():
		return 1  # Cantrips available from level 1

	# Standard D&D spell level progression
	match spell.level:
		1: return 1
		2: return 3
		3: return 5
		4: return 7
		5: return 9
		6: return 11
		7: return 13
		8: return 15
		9: return 17
		_: return 1

# Spell casting and management

func can_character_cast_spell(character: Character, spell: SpellResource) -> bool:
	"""Check if character can cast a specific spell"""
	# Check level requirement
	if character.level < get_minimum_level_for_spell(spell):
		return false

	# Check if character knows the spell
	if spell.spell_name not in character.known_spells:
		return false

	# Check spell slots
	if not spell.is_cantrip():
		var required_slots = spell.get_spell_slot_cost()
		if not has_available_spell_slots(character, required_slots):
			return false

	return true

func has_available_spell_slots(character: Character, required_level: int) -> bool:
	"""Check if character has available spell slots of the required level"""
	if character.spell_slots.size() <= required_level - 1:
		return false

	return character.spell_slots[required_level - 1] > 0

func cast_spell(character: Character, spell: SpellResource) -> Dictionary:
	"""Cast a spell and return results"""
	if not can_character_cast_spell(character, spell):
		return {"success": false, "message": "Cannot cast spell"}

	# Consume spell slot if not a cantrip
	if not spell.is_cantrip():
		var slot_level = spell.get_spell_slot_cost()
		character.spell_slots[slot_level - 1] -= 1

	# Apply spell effects
	var results = apply_spell_effects(character, spell)

	print(character.name + " cast " + spell.spell_name)
	return results

func apply_spell_effects(character: Character, spell: SpellResource) -> Dictionary:
	"""Apply the effects of a spell"""
	var results = {
		"success": true,
		"spell_name": spell.spell_name,
		"effects": []
	}

	# Basic spell effects based on school
	match spell.school.to_lower():
		"evocation":
			results.effects.append("Dealt damage")
		"abjuration":
			results.effects.append("Applied protection")
		"conjuration":
			results.effects.append("Summoned creature")
		"divination":
			results.effects.append("Gained information")
		"enchantment":
			results.effects.append("Affected target's mind")
		"illusion":
			results.effects.append("Created illusion")
		"necromancy":
			results.effects.append("Manipulated life force")
		"transmutation":
			results.effects.append("Transformed target")
		_:
			results.effects.append("Cast spell")

	return results

# Spell learning and management

func learn_spell_for_character(character: Character, spell: SpellResource) -> bool:
	"""Learn a spell for a character"""
	if spell.spell_name in character.known_spells:
		return false  # Already known

	# Check if character can learn this spell
	if not can_character_learn_spell(character, spell):
		return false

	character.learn_spell(spell.spell_name, _spell_resource_to_dict(spell))
	return true

func can_character_learn_spell(character: Character, spell: SpellResource) -> bool:
	"""Check if character can learn a spell"""
	# Check class restrictions
	if character.character_class not in spell.classes:
		return false

	# Check level requirement
	if character.level < get_minimum_level_for_spell(spell):
		return false

	# Check if already known
	if spell.spell_name in character.known_spells:
		return false

	return true

func forget_spell_for_character(character: Character, spell_name: String) -> bool:
	"""Forget a spell for a character"""
	if spell_name not in character.known_spells:
		return false

	character.forget_spell(spell_name)
	return true

# Utility functions

func get_spell_statistics() -> Dictionary:
	"""Get statistics about loaded spells"""
	var stats = {
		"total_spells": spells.size(),
		"by_level": {},
		"by_school": {},
		"by_class": {}
	}

	# Count by level
	for level in range(10):
		stats.by_level[level] = spells_by_level[level].size()

	# Count by school
	for school in spells_by_school.keys():
		stats.by_school[school] = spells_by_school[school].size()

	# Count by class
	for class_type in spells_by_class.keys():
		stats.by_class[class_type] = spells_by_class[class_type].size()

	return stats

func print_spell_summary() -> void:
	"""Print summary of loaded spells"""
	var stats = get_spell_statistics()
	print("=== Spell Summary ===")
	print("Total spells: " + str(stats.total_spells))
	print("By level: " + str(stats.by_level))
	print("By school: " + str(stats.by_school))
	print("By class: " + str(stats.by_class))

# Helper functions

func _spell_resource_to_dict(spell_resource: SpellResource) -> Dictionary:
	"""Convert SpellResource to legacy Dictionary format"""
	return {
		"name": spell_resource.spell_name,
		"level": spell_resource.level,
		"school": spell_resource.school,
		"casting_time": spell_resource.casting_time,
		"range": spell_resource.spell_range,
		"components": spell_resource.components,
		"duration": spell_resource.duration,
		"description": spell_resource.description,
		"higher_levels": spell_resource.higher_levels,
		"ritual": spell_resource.ritual,
		"concentration": spell_resource.concentration,
		"classes": spell_resource.classes,
		"damage_dice": spell_resource.damage_dice,
		"damage_type": spell_resource.damage_type,
		"saving_throw": spell_resource.saving_throw,
		"attack_roll": spell_resource.attack_roll,
		"area_of_effect": spell_resource.area_of_effect
	}
