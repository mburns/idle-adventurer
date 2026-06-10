extends Resource

# D&D Lifestyle as a Godot Resource for better editor integration

class_name LifestyleResource

@export var id: String = ""
@export var name: String = ""
@export var daily_cost: int = 0
@export var description: String = ""
@export var benefits: Array[String] = []
@export var profession_modifiers: Dictionary = {}

func get_cost_per_month() -> int:
	return daily_cost * 30

func get_cost_per_year() -> int:
	return daily_cost * 365

func has_benefit(benefit_id: String) -> bool:
	return benefit_id in benefits

func get_profession_modifier(profession: String) -> float:
	return profession_modifiers.get(profession, 0.0)

func is_affordable_for_character(character: Character) -> bool:
	return character.get_gold() >= daily_cost

func get_quality_level() -> String:
	if daily_cost <= 1:
		return "Wretched"
	elif daily_cost <= 2:
		return "Squalid"
	elif daily_cost <= 4:
		return "Poor"
	elif daily_cost <= 10:
		return "Modest"
	elif daily_cost <= 20:
		return "Comfortable"
	elif daily_cost <= 50:
		return "Wealthy"
	else:
		return "Aristocratic"
