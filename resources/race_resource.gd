extends Resource

class_name RaceResource

@export var name: String = ""
@export var ability_increases: Dictionary = {}
@export var size: String = "Medium"
@export var speed: int = 30
@export var height_range: Dictionary = {}
@export var weight_range: Dictionary = {}
@export var languages: Array[String] = []
@export var racial_traits: Array[Dictionary] = []
@export var darkvision: int = 0
@export var resistances: Array[String] = []
@export var immunities: Array[String] = []
@export var vulnerabilities: Array[String] = []
@export var subraces: Array[Dictionary] = []

func get_ability_modifier(ability: String) -> int:
	return ability_increases.get(ability, 0)

func get_height_range() -> Dictionary:
	return height_range

func get_weight_range() -> Dictionary:
	return weight_range

func get_trait_description(trait_name: String) -> String:
	for i in range(racial_traits.size()):
		var trait_data = racial_traits[i]
		if trait_data.get("name", "") == trait_name:
			return trait_data.get("description", "")
	return ""

func has_darkvision() -> bool:
	return darkvision > 0

func get_darkvision_range() -> int:
	return darkvision

func has_resistance(damage_type: String) -> bool:
	return damage_type in resistances

func has_immunity(damage_type: String) -> bool:
	return damage_type in immunities

func has_vulnerability(damage_type: String) -> bool:
	return damage_type in vulnerabilities

func get_available_languages() -> Array[String]:
	return languages.duplicate()

func get_size_category() -> String:
	return size

func get_movement_speed() -> int:
	return speed

func get_subrace_names() -> Array[String]:
	var subrace_names: Array[String] = []
	for i in range(subraces.size()):
		var subrace = subraces[i]
		subrace_names.append(subrace.get("name", ""))
	return subrace_names

func get_subrace(subrace_name: String) -> Dictionary:
	for i in range(subraces.size()):
		var subrace = subraces[i]
		if subrace.get("name", "") == subrace_name:
			return subrace
	return {}

func get_racial_bonuses() -> Dictionary:
	return {
		"ability_increases": ability_increases.duplicate(),
		"speed": speed,
		"darkvision": darkvision,
		"resistances": resistances.duplicate(),
		"immunities": immunities.duplicate(),
		"vulnerabilities": vulnerabilities.duplicate()
	}

func get_race_summary() -> String:
	var summary = name + ":\n"
	summary += "Size: " + size + "\n"
	summary += "Speed: " + str(speed) + " feet\n"
	if darkvision > 0:
		summary += "Darkvision: " + str(darkvision) + " feet\n"
	if not ability_increases.is_empty():
		summary += "Ability Increases: "
		var increases = []
		for ability in ability_increases.keys():
			increases.append(ability.capitalize() + " +" + str(ability_increases[ability]))
		summary += ", ".join(increases) + "\n"
	if not racial_traits.is_empty():
		summary += "Traits: " + str(racial_traits.size()) + " racial traits\n"
	return summary
