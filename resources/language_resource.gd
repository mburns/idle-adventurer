extends Resource

# D&D Language as a Godot Resource for better editor integration

class_name LanguageResource

@export var id: String = ""
@export var name: String = ""
@export var description: String = ""
@export var difficulty: int = 1
@export var learning_time_days: int = 250
@export var cost_per_day: float = 1.0
@export var category: String = "standard"
@export var writing_script: String = ""
@export var speakers: String = ""

func get_difficulty_name() -> String:
	match difficulty:
		0: return "Native"
		1: return "Easy"
		2: return "Moderate"
		3: return "Hard"
		4: return "Extreme"
		_: return "Unknown"

func is_exotic() -> bool:
	return category == "exotic"

func is_standard() -> bool:
	return category == "standard"

func get_learning_cost() -> float:
	return learning_time_days * cost_per_day

func can_learn(character_level: int) -> bool:
	# Higher level characters can learn more difficult languages
	return character_level >= difficulty * 2
