class_name ActivityResource
extends Resource

# D&D Activity as a Godot Resource for better editor integration and type safety

@export var activity_name: String = ""
@export var ability: String = "general"
@export var skill: String = ""
@export var description: String = ""

# Activity mechanics
@export var base_duration: float = 10.0
@export var base_xp: int = 10
@export var base_gold: int = 0
@export var daily_progress: float = 0.1
@export var cost_per_day: float = 0.0

# Requirements and rewards
@export var requirements: Dictionary = {}
@export var rewards: Dictionary = {}

# Activity type and category
@export var activity_type: String = "training"  # training, rest, adventure, social, etc.
@export var category: String = "general"  # combat, magic, social, exploration, etc.

# Scaling and progression
@export var scales_with_level: bool = true
@export var max_level: int = 20
@export var xp_scaling_factor: float = 1.0
@export var gold_scaling_factor: float = 1.0

# Activity-specific properties
@export var requires_tools: bool = false
@export var requires_materials: bool = false
@export var can_be_interrupted: bool = true
@export var requires_location: String = ""  # specific location required
@export var weather_dependent: bool = false

# Social and faction aspects
@export var faction_requirements: Dictionary = {}  # {"faction_name": min_reputation}
@export var reputation_gain: Dictionary = {}  # {"faction_name": reputation_amount}
@export var social_activity: bool = false

# Risk and consequences
@export var risk_level: String = "low"  # low, medium, high, extreme
@export var failure_consequences: Dictionary = {}
@export var success_bonuses: Dictionary = {}

func get_xp_at_level(character_level: int) -> int:
	"""Calculate XP reward based on character level"""
	if not scales_with_level:
		return base_xp

	var scaled_xp = base_xp * (1.0 + (character_level - 1) * xp_scaling_factor * 0.1)
	return int(scaled_xp)

func get_gold_at_level(character_level: int) -> int:
	"""Calculate gold reward based on character level"""
	if not scales_with_level:
		return base_gold

	var scaled_gold = base_gold * (1.0 + (character_level - 1) * gold_scaling_factor * 0.1)
	return int(scaled_gold)

func get_duration_at_level(character_level: int) -> float:
	"""Calculate activity duration based on character level"""
	if not scales_with_level:
		return base_duration

	# Higher level characters complete activities faster
	var efficiency_bonus = 1.0 - (character_level - 1) * 0.05  # 5% faster per level
	return base_duration * max(0.5, efficiency_bonus)  # Minimum 50% of base duration

func meets_requirements(character: Character) -> bool:
	"""Check if character meets all activity requirements"""
	if requirements.is_empty():
		return true

	for req_type in requirements.keys():
		var required_value = requirements[req_type]

		match req_type:
			"strength", "dexterity", "constitution", "intelligence", "wisdom", "charisma":
				if character.get(req_type) < required_value:
					return false
			"gold":
				if character.gold < required_value:
					return false
			"level":
				if character.level < required_value:
					return false
			"tools":
				# Check if character has required tools
				if required_value and not _character_has_tools(character):
					return false
			"location":
				# Check if character is in required location
				if required_value != "" and not _character_in_location(character, required_value):
					return false

	return true

func get_requirements_text() -> String:
	"""Get human-readable requirements text"""
	if requirements.is_empty():
		return "None"

	var req_parts = []
	for req_type in requirements.keys():
		var required_value = requirements[req_type]

		match req_type:
			"strength", "dexterity", "constitution", "intelligence", "wisdom", "charisma":
				req_parts.append("%s %d+" % [req_type.capitalize(), required_value])
			"gold":
				req_parts.append("%d+ gold" % required_value)
			"level":
				req_parts.append("Level %d+" % required_value)
			"tools":
				if required_value:
					req_parts.append("Tools required")
			"location":
				if required_value != "":
					req_parts.append("Location: %s" % required_value)

	return ", ".join(req_parts)

func get_rewards_text() -> String:
	"""Get human-readable rewards text"""
	if rewards.is_empty():
		return "None"

	var reward_parts = []
	for reward_type in rewards.keys():
		var reward_value = rewards[reward_type]

		if reward_type.ends_with("_exp"):
			var ability_name = reward_type.replace("_exp", "").capitalize()
			reward_parts.append("%s XP" % ability_name)
		elif reward_type == "gold":
			reward_parts.append("%d gold" % reward_value)
		else:
			reward_parts.append("%s: %s" % [reward_type.capitalize(), str(reward_value)])

	return ", ".join(reward_parts)

func _character_has_tools(character: Character) -> bool:
	"""Check if character has required tools"""
	# For now, assume character has tools if they have enough gold
	return character.gold >= 50

func _character_in_location(character: Character, required_location: String) -> bool:
	"""Check if character is in required location"""
	# For now, assume character can be anywhere
	# This would integrate with location/town system
	return true

func get_risk_color() -> Color:
	"""Get color representing risk level"""
	match risk_level.to_lower():
		"low":
			return Color.GREEN
		"medium":
			return Color.YELLOW
		"high":
			return Color.ORANGE
		"extreme":
			return Color.RED
		_:
			return Color.WHITE

func is_rest_activity() -> bool:
	"""Check if this is a rest activity"""
	return activity_type == "rest"

func is_training_activity() -> bool:
	"""Check if this is a training activity"""
	return activity_type == "training"

func is_social_activity() -> bool:
	"""Check if this is a social activity"""
	return social_activity or activity_type == "social"

func get_category_color() -> Color:
	"""Get color representing activity category"""
	match category.to_lower():
		"combat":
			return Color.RED
		"magic":
			return Color.PURPLE
		"social":
			return Color.BLUE
		"exploration":
			return Color.GREEN
		"crafting":
			return Color.ORANGE
		_:
			return Color.WHITE
