extends Resource

# D&D Level Requirement as a Godot Resource for better editor integration

class_name LevelRequirementResource

@export var level: int = 1
@export var experience_required: int = 0
@export var config_name: String = "standard"

func get_experience_to_next_level() -> int:
	# This would need to be calculated based on the next level
	# For now, return a placeholder
	return experience_required * 2

func is_max_level() -> bool:
	return level >= 20

func get_level_title() -> String:
	match level:
		1: return "Novice"
		2-4: return "Apprentice"
		5-9: return "Journeyman"
		10-14: return "Expert"
		15-19: return "Master"
		20: return "Legend"
		_: return "Unknown"

func get_progress_percentage(current_xp: int) -> float:
	if experience_required <= 0:
		return 100.0
	return min(100.0, (float(current_xp) / float(experience_required)) * 100.0)
