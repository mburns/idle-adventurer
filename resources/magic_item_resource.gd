extends Resource

class_name MagicItemResource

# D&D Magic Item as a Godot Resource for better editor integration

@export var name: String = ""
@export var type: String = "wondrous item"
@export var rarity: String = "common"
@export var attunement: bool = false
@export var description: String = ""
@export var properties: Array[String] = []
@export var effects: Array[Dictionary] = []  # [{"type": String, "value": Variant, "description": String}]
@export var requirements: String = ""
@export var weight: String = ""
@export var value: String = ""
@export var category: String = "magic_item"

# Magic item specific properties
@export var charges: int = 0
@export var max_charges: int = 0
@export var recharge_rate: String = ""  # "dawn", "dusk", "daily", etc.
@export var spell_list: Array[String] = []  # Spells the item can cast
@export var spell_level: int = 0  # Level of spells cast by the item
@export var uses_per_day: int = 0  # Limited uses per day
@export var cursed: bool = false
@export var sentient: bool = false

# Combat and utility effects
@export var armor_class_bonus: int = 0
@export var attack_bonus: int = 0
@export var damage_bonus: int = 0
@export var ability_bonuses: Dictionary = {}  # {"strength": 2, "dexterity": 1}
@export var skill_bonuses: Dictionary = {}  # {"athletics": 1, "stealth": 2}
@export var saving_throw_bonuses: Dictionary = {}  # {"strength": 1, "constitution": 1}
@export var resistance_types: Array[String] = []
@export var immunity_types: Array[String] = []
@export var vulnerability_types: Array[String] = []

# Item identification and discovery
@export var requires_identification: bool = true
@export var identification_difficulty: int = 15  # DC for identify spell
@export var detect_magic_visible: bool = true

func get_rarity_value() -> int:
	"""Get numeric rarity value for sorting"""
	match rarity.to_lower():
		"common": return 1
		"uncommon": return 2
		"rare": return 3
		"very rare": return 4
		"legendary": return 5
		"artifact": return 6
		_: return 0

func get_rarity_color() -> Color:
	"""Get color associated with rarity"""
	match rarity.to_lower():
		"common": return Color.WHITE
		"uncommon": return Color.SILVER
		"rare": return Color.GOLD
		"very rare": return Color.PURPLE
		"legendary": return Color.MAGENTA
		"artifact": return Color.CYAN
		_: return Color.WHITE

func requires_attunement() -> bool:
	"""Check if item requires attunement"""
	return attunement

func can_attune_to(character: Character) -> bool:
	"""Check if character can attune to this item"""
	if not requires_attunement():
		return true

	# Check requirements
	if requirements != "":
		# Parse requirements (class, level, etc.)
		if "class" in requirements.to_lower():
			var required_class = _extract_class_requirement(requirements)
			if required_class != "" and character.character_class != required_class:
				return false

		if "level" in requirements.to_lower():
			var required_level = _extract_level_requirement(requirements)
			if required_level > 0 and character.level < required_level:
				return false

	return true

func _extract_class_requirement(req_string: String) -> String:
	"""Extract class requirement from requirements string"""
	# Simple parsing - would need more sophisticated parsing for complex requirements
	var regex = RegEx.new()
	regex.compile("class\\s+(\\w+)")
	var result = regex.search(req_string)
	if result:
		return result.get_string(1)
	return ""

func _extract_level_requirement(req_string: String) -> int:
	"""Extract level requirement from requirements string"""
	var regex = RegEx.new()
	regex.compile("level\\s+(\\d+)")
	var result = regex.search(req_string)
	if result:
		return int(result.get_string(1))
	return 0

func get_attunement_slots() -> int:
	"""Get number of attunement slots this item uses"""
	return 1 if requires_attunement() else 0

func has_charges() -> bool:
	"""Check if item has charges"""
	return max_charges > 0

func get_current_charges() -> int:
	"""Get current number of charges"""
	return charges

func can_use_charge() -> bool:
	"""Check if item can use a charge"""
	return charges > 0

func use_charge() -> bool:
	"""Use a charge from the item"""
	if can_use_charge():
		charges -= 1
		return true
	return false

func recharge_item() -> void:
	"""Recharge item based on recharge rate"""
	match recharge_rate.to_lower():
		"dawn", "daily":
			charges = max_charges
		"dusk":
			charges = max_charges
		"weekly":
			charges = max_charges
		"monthly":
			charges = max_charges

func can_cast_spell() -> bool:
	"""Check if item can cast spells"""
	return not spell_list.is_empty()

func get_spell_list() -> Array[String]:
	"""Get list of spells this item can cast"""
	return spell_list.duplicate()

func get_spell_level() -> int:
	"""Get level of spells cast by this item"""
	return spell_level

func has_ability_bonus(ability: String) -> bool:
	"""Check if item provides bonus to specific ability"""
	return ability in ability_bonuses

func get_ability_bonus(ability: String) -> int:
	"""Get bonus to specific ability"""
	return ability_bonuses.get(ability, 0)

func has_skill_bonus(skill: String) -> bool:
	"""Check if item provides bonus to specific skill"""
	return skill in skill_bonuses

func get_skill_bonus(skill: String) -> int:
	"""Get bonus to specific skill"""
	return skill_bonuses.get(skill, 0)

func has_saving_throw_bonus(ability: String) -> bool:
	"""Check if item provides bonus to specific saving throw"""
	return ability in saving_throw_bonuses

func get_saving_throw_bonus(ability: String) -> int:
	"""Get bonus to specific saving throw"""
	return saving_throw_bonuses.get(ability, 0)

func has_resistance(damage_type: String) -> bool:
	"""Check if item provides resistance to damage type"""
	return damage_type in resistance_types

func has_immunity(damage_type: String) -> bool:
	"""Check if item provides immunity to damage type"""
	return damage_type in immunity_types

func has_vulnerability(damage_type: String) -> bool:
	"""Check if item provides vulnerability to damage type"""
	return damage_type in vulnerability_types

func is_cursed() -> bool:
	"""Check if item is cursed"""
	return cursed

func is_sentient() -> bool:
	"""Check if item is sentient"""
	return sentient

func get_value_in_gold() -> int:
	"""Get item value in gold pieces"""
	if value == "":
		return _calculate_value_from_rarity()

	# Parse value string (e.g., "500 gp", "1000 gold")
	var regex = RegEx.new()
	regex.compile("(\\d+)")
	var result = regex.search(value)
	if result:
		return int(result.get_string(1))

	return _calculate_value_from_rarity()

func _calculate_value_from_rarity() -> int:
	"""Calculate value based on rarity"""
	match rarity.to_lower():
		"common": return 100
		"uncommon": return 500
		"rare": return 5000
		"very rare": return 50000
		"legendary": return 500000
		"artifact": return 1000000
		_: return 100

func get_weight_value() -> float:
	"""Get numeric weight value"""
	if weight == "":
		return 1.0  # Default weight

	# Parse weight string (e.g., "1 lb", "2 pounds")
	var regex = RegEx.new()
	regex.compile("(\\d+(?:\\.\\d+)?)")
	var result = regex.search(weight)
	if result:
		return float(result.get_string(1))

	return 1.0

func get_item_summary() -> String:
	"""Get a summary of the magic item"""
	var summary = name + ":\n"
	summary += "Type: " + type + "\n"
	summary += "Rarity: " + rarity + "\n"

	if requires_attunement():
		summary += "Requires Attunement\n"

	if has_charges():
		summary += "Charges: " + str(charges) + "/" + str(max_charges) + "\n"

	if can_cast_spell():
		summary += "Spells: " + str(spell_list.size()) + " spells\n"

	if not ability_bonuses.is_empty():
		summary += "Ability Bonuses: " + str(ability_bonuses.size()) + " bonuses\n"

	if armor_class_bonus > 0:
		summary += "AC Bonus: +" + str(armor_class_bonus) + "\n"

	if attack_bonus > 0:
		summary += "Attack Bonus: +" + str(attack_bonus) + "\n"

	if damage_bonus > 0:
		summary += "Damage Bonus: +" + str(damage_bonus) + "\n"

	return summary

func get_combat_stats() -> Dictionary:
	"""Get combat-relevant statistics"""
	return {
		"armor_class_bonus": armor_class_bonus,
		"attack_bonus": attack_bonus,
		"damage_bonus": damage_bonus,
		"ability_bonuses": ability_bonuses.duplicate(),
		"skill_bonuses": skill_bonuses.duplicate(),
		"saving_throw_bonuses": saving_throw_bonuses.duplicate(),
		"resistance_types": resistance_types.duplicate(),
		"immunity_types": immunity_types.duplicate(),
		"vulnerability_types": vulnerability_types.duplicate()
	}

func get_magic_properties() -> Dictionary:
	"""Get all magic properties of the item"""
	return {
		"charges": charges,
		"max_charges": max_charges,
		"recharge_rate": recharge_rate,
		"spell_list": spell_list.duplicate(),
		"spell_level": spell_level,
		"uses_per_day": uses_per_day,
		"cursed": cursed,
		"sentient": sentient,
		"requires_identification": requires_identification,
		"identification_difficulty": identification_difficulty,
		"detect_magic_visible": detect_magic_visible
	}
