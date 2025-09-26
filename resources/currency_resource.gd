extends Resource

# D&D Currency as a Godot Resource for better editor integration

class_name CurrencyResource

@export var id: String = ""
@export var name: String = ""
@export var plural: String = ""
@export var abbreviation: String = ""
@export var weight: float = 0.02
@export var value_base: int = 1
@export var description: String = ""
@export var rarity: String = "common"
@export var material: String = ""

func get_weight_for_amount(amount: int) -> float:
	return weight * amount

func get_value_in_copper() -> int:
	return value_base

func get_value_in_gold() -> float:
	return value_base / 100.0

func is_precious_metal() -> bool:
	return material in ["gold", "silver", "platinum", "electrum"]

func is_common() -> bool:
	return rarity == "common"

func get_display_name(amount: int = 1) -> String:
	if amount == 1:
		return name
	else:
		return plural
