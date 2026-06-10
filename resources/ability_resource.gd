extends Resource
class_name AbilityResource

# D&D Ability Score as a Godot Resource
# Represents the six core abilities: Strength, Dexterity, Constitution, Intelligence, Wisdom, Charisma

@export var id: String = ""
@export var ability_name: String = ""
@export var description: String = ""
@export var modifier: int = 0  # Ability modifier (usually (score - 10) / 2)
@export var base_score: int = 10  # Base ability score
@export var is_core_ability: bool = true  # True for the 6 core abilities, false for derived abilities

# Associated skills and activities
@export var associated_skills: Array[String] = []
@export var associated_activities: Array[String] = []

# Ability-specific properties
@export var saving_throw_proficiency: bool = false
@export var is_spellcasting_ability: bool = false

func _init():
	pass

func get_modifier() -> int:
	"""Calculate ability modifier from base score"""
	return (base_score - 10) / 2

func get_score() -> int:
	"""Get current ability score"""
	return base_score + modifier

func get_modifier_bonus() -> int:
	"""Get modifier bonus for rolls"""
	return get_modifier()

func is_core() -> bool:
	"""Check if this is one of the six core abilities"""
	return is_core_ability

func get_description() -> String:
	"""Get formatted description"""
	return ability_name + ": " + description
