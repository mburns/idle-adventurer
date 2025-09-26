extends Resource

# D&D Name as a Godot Resource for better editor integration

class_name NameResource

@export var name: String = ""
@export var category: String = "general"
@export var gender: String = "neutral"
@export var culture: String = "common"
@export var rarity: String = "common"

func is_masculine() -> bool:
	return gender == "masculine"

func is_feminine() -> bool:
	return gender == "feminine"

func is_neutral() -> bool:
	return gender == "neutral"

func is_common() -> bool:
	return rarity == "common"

func is_uncommon() -> bool:
	return rarity == "uncommon"

func is_rare() -> bool:
	return rarity == "rare"

func get_display_name() -> String:
	return name
