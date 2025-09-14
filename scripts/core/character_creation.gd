extends Node

class_name CharacterCreation

signal character_created(character: Character)

func create_character(character_name: String, race: String, character_class: String, background: String) -> Character:
	var character = Character.new()
	character.name = character_name
	character.race = race
	character.character_class = character_class
	character.background = background
	character_created.emit(character)
	return character

func create_random_character() -> Character:
	# Try to access DataLoader, fallback to default values if not available
	var races = []
	var classes = []
	var backgrounds = []

	if Engine.has_singleton("DataLoader"):
		var data_loader = Engine.get_singleton("DataLoader")
		races = data_loader.get_race_names()
		classes = data_loader.get_class_names()
		backgrounds = data_loader.get_background_names()
	else:
		# Fallback values for headless mode
		races = ["Human", "Elf", "Dwarf", "Halfling"]
		classes = ["Fighter", "Wizard", "Rogue", "Cleric"]
		backgrounds = ["Acolyte", "Criminal", "Folk Hero", "Noble"]

	var random_race = races[randi() % races.size()]
	var random_class = classes[randi() % classes.size()]
	var random_background = backgrounds[randi() % backgrounds.size()]

	var random_name = "TestCharacter" + str(randi() % 1000)

	return create_character(random_name, random_race, random_class, random_background)

func validate_character_creation(character_name: String, _race: String, _class_type: String, _background: String) -> bool:
	if character_name.is_empty():
		return false
	return true

func get_available_races() -> Array[String]:
	if Engine.has_singleton("DataLoader"):
		var data_loader = Engine.get_singleton("DataLoader")
		return data_loader.get_race_names()
	return ["Human", "Elf", "Dwarf", "Halfling"]

func get_available_classes() -> Array[String]:
	if Engine.has_singleton("DataLoader"):
		var data_loader = Engine.get_singleton("DataLoader")
		return data_loader.get_class_names()
	return ["Fighter", "Wizard", "Rogue", "Cleric"]

func get_available_backgrounds() -> Array[String]:
	if Engine.has_singleton("DataLoader"):
		var data_loader = Engine.get_singleton("DataLoader")
		return data_loader.get_background_names()
	return ["Acolyte", "Criminal", "Folk Hero", "Noble"]
