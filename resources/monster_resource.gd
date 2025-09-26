extends Resource

class_name MonsterResource

# D&D Monster as a Godot Resource for better editor integration

@export var name: String = ""
@export var size: String = "Medium"
@export var type: String = "humanoid"
@export var alignment: String = "neutral"
@export var armor_class: int = 10
@export var hit_points: int = 10
@export var speed: String = "30 ft."
@export var abilities: Dictionary = {}  # {"strength": 10, "dexterity": 10, ...}
@export var saving_throws: Array[String] = []
@export var skills: Array[String] = []
@export var damage_immunities: Array[String] = []
@export var damage_resistances: Array[String] = []
@export var damage_vulnerabilities: Array[String] = []
@export var condition_immunities: Array[String] = []
@export var senses: String = ""
@export var languages: Array[String] = []
@export var challenge_rating: String = "1/4"
@export var xp: int = 0
@export var traits: Array[Dictionary] = []  # [{"name": String, "description": String}]
@export var actions: Array[Dictionary] = []  # [{"name": String, "description": String}]
@export var reactions: Array[Dictionary] = []  # [{"name": String, "description": String}]
@export var legendary_actions: Array[Dictionary] = []  # [{"name": String, "description": String}]

# Combat statistics
@export var proficiency_bonus: int = 2
@export var passive_perception: int = 10

func get_ability_modifier(ability: String) -> int:
	"""Get ability modifier from ability score"""
	var score = abilities.get(ability, 10)
	return floor((score - 10) / 2.0)

func get_armor_class_value() -> int:
	"""Get numeric armor class value"""
	return armor_class

func get_hit_points_value() -> int:
	"""Get numeric hit points value"""
	return hit_points

func get_challenge_rating_value() -> float:
	"""Get numeric challenge rating value"""
	match challenge_rating:
		"0": return 0.0
		"1/8": return 0.125
		"1/4": return 0.25
		"1/2": return 0.5
		"1": return 1.0
		"2": return 2.0
		"3": return 3.0
		"4": return 4.0
		"5": return 5.0
		"6": return 6.0
		"7": return 7.0
		"8": return 8.0
		"9": return 9.0
		"10": return 10.0
		"11": return 11.0
		"12": return 12.0
		"13": return 13.0
		"14": return 14.0
		"15": return 15.0
		"16": return 16.0
		"17": return 17.0
		"18": return 18.0
		"19": return 19.0
		"20": return 20.0
		"21": return 21.0
		"22": return 22.0
		"23": return 23.0
		"24": return 24.0
		"25": return 25.0
		"26": return 26.0
		"27": return 27.0
		"28": return 28.0
		"29": return 29.0
		"30": return 30.0
		_: return 0.0

func get_experience_points() -> int:
	"""Get experience points for defeating this monster"""
	if xp > 0:
		return xp

	# Calculate XP based on challenge rating
	var cr = get_challenge_rating_value()
	match cr:
		0.0: return 0
		0.125: return 25
		0.25: return 50
		0.5: return 100
		1.0: return 200
		2.0: return 450
		3.0: return 700
		4.0: return 1100
		5.0: return 1800
		6.0: return 2300
		7.0: return 2900
		8.0: return 3900
		9.0: return 5000
		10.0: return 5900
		11.0: return 7200
		12.0: return 8400
		13.0: return 10000
		14.0: return 11500
		15.0: return 13000
		16.0: return 15000
		17.0: return 18000
		18.0: return 20000
		19.0: return 22000
		20.0: return 25000
		21.0: return 33000
		22.0: return 41000
		23.0: return 50000
		24.0: return 62000
		25.0: return 75000
		_: return 0

func has_trait(trait_name: String) -> bool:
	"""Check if monster has a specific trait"""
	for i in range(traits.size()):
		var trait_data = traits[i]
		if trait_data.get("name", "") == trait_name:
			return true
	return false

func get_trait_description(trait_name: String) -> String:
	"""Get description of a specific trait"""
	for i in range(traits.size()):
		var trait_data = traits[i]
		if trait_data.get("name", "") == trait_name:
			return trait_data.get("description", "")
	return ""

func has_action(action_name: String) -> bool:
	"""Check if monster has a specific action"""
	for i in range(actions.size()):
		var action_data = actions[i]
		if action_data.get("name", "") == action_name:
			return true
	return false

func get_action_description(action_name: String) -> String:
	"""Get description of a specific action"""
	for i in range(actions.size()):
		var action_data = actions[i]
		if action_data.get("name", "") == action_name:
			return action_data.get("description", "")
	return ""

func has_resistance(damage_type: String) -> bool:
	"""Check if monster has resistance to a damage type"""
	return damage_type in damage_resistances

func has_immunity(damage_type: String) -> bool:
	"""Check if monster has immunity to a damage type"""
	return damage_type in damage_immunities

func has_vulnerability(damage_type: String) -> bool:
	"""Check if monster has vulnerability to a damage type"""
	return damage_type in damage_vulnerabilities

func has_condition_immunity(condition: String) -> bool:
	"""Check if monster has immunity to a condition"""
	return condition in condition_immunities

func has_darkvision() -> bool:
	"""Check if monster has darkvision"""
	return "darkvision" in senses.to_lower()

func get_darkvision_range() -> int:
	"""Get darkvision range in feet"""
	if has_darkvision():
		var regex = RegEx.new()
		regex.compile("darkvision\\s+(\\d+)")
		var result = regex.search(senses)
		if result:
			return int(result.get_string(1))
	return 0

func get_passive_perception() -> int:
	"""Get passive perception score"""
	if passive_perception > 0:
		return passive_perception

	# Calculate from wisdom modifier
	var wisdom_mod = get_ability_modifier("wisdom")
	return 10 + wisdom_mod

func get_size_category() -> String:
	"""Get size category"""
	return size.split(" ")[0].to_lower()  # Extract size from "Small humanoid"

func get_creature_type() -> String:
	"""Get creature type"""
	var parts = size.split(" ")
	if parts.size() > 1:
		return parts[1].to_lower()  # Extract type from "Small humanoid"
	return type.to_lower()

func is_legendary() -> bool:
	"""Check if monster has legendary actions"""
	return not legendary_actions.is_empty()

func get_legendary_action_count() -> int:
	"""Get number of legendary actions per turn"""
	if is_legendary():
		return 3  # Default legendary action count
	return 0

func get_monster_summary() -> String:
	"""Get a summary of the monster"""
	var summary = name + ":\n"
	summary += "Size: " + size + "\n"
	summary += "Type: " + type + "\n"
	summary += "Alignment: " + alignment + "\n"
	summary += "AC: " + str(armor_class) + "\n"
	summary += "HP: " + str(hit_points) + "\n"
	summary += "CR: " + challenge_rating + "\n"
	summary += "XP: " + str(get_experience_points()) + "\n"

	if not traits.is_empty():
		summary += "Traits: " + str(traits.size()) + " special traits\n"

	if not actions.is_empty():
		summary += "Actions: " + str(actions.size()) + " actions\n"

	if is_legendary():
		summary += "Legendary: " + str(legendary_actions.size()) + " legendary actions\n"

	return summary

func get_combat_stats() -> Dictionary:
	"""Get combat-relevant statistics"""
	return {
		"armor_class": armor_class,
		"hit_points": hit_points,
		"challenge_rating": get_challenge_rating_value(),
		"experience_points": get_experience_points(),
		"proficiency_bonus": proficiency_bonus,
		"passive_perception": get_passive_perception(),
		"ability_modifiers": {
			"strength": get_ability_modifier("strength"),
			"dexterity": get_ability_modifier("dexterity"),
			"constitution": get_ability_modifier("constitution"),
			"intelligence": get_ability_modifier("intelligence"),
			"wisdom": get_ability_modifier("wisdom"),
			"charisma": get_ability_modifier("charisma")
		}
	}
