class_name CharacterManager
extends Node

# Singleton for managing the current character
var current_character: Character
var save_file_path = "user://character_save.dat"

# Signal emitted when character changes
signal character_changed(character: Character)
signal character_created(character: Character)
signal character_loaded(character: Character)

# Initialize with a default character
func _ready():
	if current_character == null:
		create_default_character()

# Create a new character with default values
func create_character(name: String, race: String, character_class: String, background: String) -> Character:
	var character = Character.new()
	character.name = name
	character.race = race
	character.character_class = character_class
	character.background = background
	
	# Apply race bonuses
	apply_race_bonuses(character, race)
	
	# Apply class features
	apply_class_features(character, character_class)
	
	# Apply background features
	apply_background_features(character, background)
	
	# Update derived stats
	character.update_derived_stats()
	
	current_character = character
	character_created.emit(character)
	character_changed.emit(character)
	
	return character

# Create a default character for testing
func create_default_character() -> Character:
	return create_character("Bob", "Human", "Barbarian", "Folk Hero")

# Apply race bonuses to character
func apply_race_bonuses(character: Character, race: String):
	var race_data = DnDData.get_race(race)
	if race_data.is_empty():
		return
	
	var ability_increases = race_data.get("ability_increases", {})
	for ability in ability_increases.keys():
		var increase = ability_increases[ability]
		character.set(ability, character.get(ability) + increase)
	
	# Add languages
	var languages = race_data.get("languages", [])
	for language in languages:
		character.language_proficiencies.append(language)

# Apply class features to character
func apply_class_features(character: Character, class_name: String):
	var class_data = DnDData.get_class(class_name)
	if class_data.is_empty():
		return
	
	# Add skill proficiencies
	var skill_options = class_data.get("skill_options", [])
	var skill_choices = class_data.get("skill_choices", 0)
	
	# For now, just add the first few skills (in a real game, player would choose)
	for i in range(min(skill_choices, skill_options.size())):
		character.skill_proficiencies.append(skill_options[i])
	
	# Add armor proficiencies
	var armor_proficiencies = class_data.get("armor_proficiencies", [])
	for armor in armor_proficiencies:
		character.armor_proficiencies.append(armor)
	
	# Add weapon proficiencies
	var weapon_proficiencies = class_data.get("weapon_proficiencies", [])
	for weapon in weapon_proficiencies:
		character.weapon_proficiencies.append(weapon)
	
	# Add tool proficiencies
	var tool_proficiencies = class_data.get("tool_proficiencies", [])
	for tool in tool_proficiencies:
		character.tool_proficiencies.append(tool)

# Apply background features to character
func apply_background_features(character: Character, background: String):
	var background_data = DnDData.get_background(background)
	if background_data.is_empty():
		return
	
	# Add skill proficiencies
	var skill_proficiencies = background_data.get("skill_proficiencies", [])
	for skill in skill_proficiencies:
		character.skill_proficiencies.append(skill)
	
	# Add tool proficiencies
	var tool_proficiencies = background_data.get("tool_proficiencies", [])
	for tool in tool_proficiencies:
		character.tool_proficiencies.append(tool)
	
	# Add languages
	var languages = background_data.get("languages", [])
	for language in languages:
		character.language_proficiencies.append(language)

# Save character to file
func save_character() -> bool:
	if current_character == null:
		return false
	
	var file = FileAccess.open(save_file_path, FileAccess.WRITE)
	if file == null:
		print("Error: Could not open save file for writing")
		return false
	
	# Convert character to dictionary for saving
	var character_data = {
		"name": current_character.name,
		"race": current_character.race,
		"character_class": current_character.character_class,
		"background": current_character.background,
		"level": current_character.level,
		"experience_points": current_character.experience_points,
		"strength": current_character.strength,
		"dexterity": current_character.dexterity,
		"constitution": current_character.constitution,
		"intelligence": current_character.intelligence,
		"wisdom": current_character.wisdom,
		"charisma": current_character.charisma,
		"hit_points": current_character.hit_points,
		"max_hit_points": current_character.max_hit_points,
		"armor_class": current_character.armor_class,
		"proficiency_bonus": current_character.proficiency_bonus,
		"gold": current_character.gold,
		"spell_slots": current_character.spell_slots,
		"skill_proficiencies": current_character.skill_proficiencies,
		"tool_proficiencies": current_character.tool_proficiencies,
		"language_proficiencies": current_character.language_proficiencies,
		"weapon_proficiencies": current_character.weapon_proficiencies,
		"armor_proficiencies": current_character.armor_proficiencies,
		"equipment": current_character.equipment,
		"current_activity": current_character.current_activity,
		"activity_start_time": current_character.activity_start_time,
		"activity_duration": current_character.activity_duration,
		"faction_reputation": current_character.faction_reputation
	}
	
	file.store_string(JSON.stringify(character_data))
	file.close()
	
	print("Character saved successfully")
	return true

# Load character from file
func load_character() -> bool:
	var file = FileAccess.open(save_file_path, FileAccess.READ)
	if file == null:
		print("No save file found")
		return false
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		print("Error parsing save file: ", json.get_error_message())
		return false
	
	var character_data = json.get_data()
	if not character_data is Dictionary:
		print("Error: Save file does not contain valid character data")
		return false
	
	# Create new character and populate with saved data
	var character = Character.new()
	character.name = character_data.get("name", "")
	character.race = character_data.get("race", "")
	character.character_class = character_data.get("character_class", "")
	character.background = character_data.get("background", "")
	character.level = character_data.get("level", 1)
	character.experience_points = character_data.get("experience_points", 0)
	character.strength = character_data.get("strength", 10)
	character.dexterity = character_data.get("dexterity", 10)
	character.constitution = character_data.get("constitution", 10)
	character.intelligence = character_data.get("intelligence", 10)
	character.wisdom = character_data.get("wisdom", 10)
	character.charisma = character_data.get("charisma", 10)
	character.hit_points = character_data.get("hit_points", 0)
	character.max_hit_points = character_data.get("max_hit_points", 0)
	character.armor_class = character_data.get("armor_class", 10)
	character.proficiency_bonus = character_data.get("proficiency_bonus", 2)
	character.gold = character_data.get("gold", 0)
	character.spell_slots = character_data.get("spell_slots", [])
	character.skill_proficiencies = character_data.get("skill_proficiencies", [])
	character.tool_proficiencies = character_data.get("tool_proficiencies", [])
	character.language_proficiencies = character_data.get("language_proficiencies", [])
	character.weapon_proficiencies = character_data.get("weapon_proficiencies", [])
	character.armor_proficiencies = character_data.get("armor_proficiencies", [])
	character.equipment = character_data.get("equipment", {})
	character.current_activity = character_data.get("current_activity", "")
	character.activity_start_time = character_data.get("activity_start_time", 0.0)
	character.activity_duration = character_data.get("activity_duration", 0.0)
	character.faction_reputation = character_data.get("faction_reputation", {})
	
	current_character = character
	character_loaded.emit(character)
	character_changed.emit(character)
	
	print("Character loaded successfully")
	return true

# Check if save file exists
func has_save_file() -> bool:
	return FileAccess.file_exists(save_file_path)

# Delete save file
func delete_save_file() -> bool:
	if has_save_file():
		var dir = DirAccess.open("user://")
		return dir.remove(save_file_path) == OK
	return false

# Get current character
func get_current_character() -> Character:
	return current_character

# Set current character
func set_current_character(character: Character):
	current_character = character
	character_changed.emit(character)
