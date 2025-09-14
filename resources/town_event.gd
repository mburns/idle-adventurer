class_name TownEvent
extends Resource

# Events that occur in towns

@export var event_id: String = ""
@export var name: String = ""
@export var description: String = ""
@export var town_id: String = ""
@export var location_id: String = ""
@export var duration: int = 1
@export var frequency: String = "once"
@export var triggers: Array[String] = []
@export var requirements: Dictionary = {}
@export var outcomes: Dictionary = {}
@export var participants: Array[String] = []
@export var consequences: Dictionary = {}

func can_trigger(character: Character) -> bool:
	if requirements.is_empty():
		return true

	for req_type in requirements.keys():
		var required_value = requirements[req_type]
		match req_type:
			"level":
				if character.level < required_value:
					return false
			"gold":
				if character.gold < required_value:
					return false
	return true
