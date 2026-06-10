extends Resource
class_name SkillResource

# D&D Skill as a Godot Resource
# Represents individual skills like Athletics, Acrobatics, etc.

@export var id: String = ""
@export var skill_name: String = ""
@export var description: String = ""
@export var ability_resource: AbilityResource  # The ability this skill is based on
@export var is_proficient: bool = false
@export var proficiency_bonus: int = 0

# Skill-specific properties
@export var is_armor_penalty: bool = false  # Some skills have penalties in armor
@export var is_passive: bool = false  # Some skills are always "on" (like Perception)

func _init():
	pass

func get_ability_name() -> String:
	"""Get the name of the associated ability"""
	if ability_resource:
		return ability_resource.ability_name
	return ""

func get_ability_modifier() -> int:
	"""Get the ability modifier for this skill"""
	if ability_resource:
		return ability_resource.get_modifier()
	return 0

func get_total_bonus() -> int:
	"""Get total skill bonus (ability modifier + proficiency bonus)"""
	var total = get_ability_modifier()
	if is_proficient:
		total += proficiency_bonus
	return total

func get_passive_score() -> int:
	"""Get passive skill score (10 + total bonus)"""
	return 10 + get_total_bonus()

func is_armor_restricted() -> bool:
	"""Check if this skill has armor penalties"""
	return is_armor_penalty
