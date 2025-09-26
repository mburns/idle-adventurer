extends Resource
class_name AlignmentResource

# Alignment Resource for D&D alignments
# Represents a character's moral and ethical stance

@export var id: String = ""
@export var name: String = ""
@export var abbreviation: String = ""
@export var description: String = ""
@export var moral_axis: String = "" # "lawful", "neutral", "chaotic"
@export var ethical_axis: String = "" # "good", "neutral", "evil"
@export var examples: Array[String] = []
@export var restrictions: Array[String] = []
@export var benefits: Array[String] = []

func _init():
	pass

func is_lawful() -> bool:
	return moral_axis == "lawful"

func is_chaotic() -> bool:
	return moral_axis == "chaotic"

func is_good() -> bool:
	return ethical_axis == "good"

func is_evil() -> bool:
	return ethical_axis == "evil"

func is_neutral_moral() -> bool:
	return moral_axis == "neutral"

func is_neutral_ethical() -> bool:
	return ethical_axis == "neutral"

func is_true_neutral() -> bool:
	return moral_axis == "neutral" and ethical_axis == "neutral"
