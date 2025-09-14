extends Node

# Character persistence system
# Handles saving and loading character data

class_name CharacterPersistence

signal character_saved(character: Character)
signal character_loaded(character: Character)
signal save_error(error_message: String)
signal load_error(error_message: String)

var save_file_path: String = "user://character_save.dat"

# Save character to file
func save_character(character: Character) -> bool:
	if character == null:
		save_error.emit("No character to save")
		return false

	var save_data = serialize_character(character)

	var file = FileAccess.open(save_file_path, FileAccess.WRITE)
	if file == null:
		save_error.emit("Could not open save file for writing")
		return false

	file.store_string(JSON.stringify(save_data))
	file.close()

	character_saved.emit(character)
	print("Character saved successfully")
	return true

# Load character from specific file path
func load_character_from_path(file_path: String) -> Character:
	if not FileAccess.file_exists(file_path):
		load_error.emit("No save file found at " + file_path)
		return null

	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		load_error.emit("Could not open save file for reading")
		return null

	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		load_error.emit("Failed to parse save file JSON")
		return null

	var character_data = json.data
	var character = deserialize_character(character_data)

	if character != null:
		character_loaded.emit(character)
		print("Character loaded successfully")

	return character

# Load character from file
func load_character() -> Character:
	if not has_save_file():
		load_error.emit("No save file found")
		return null

	var file = FileAccess.open(save_file_path, FileAccess.READ)
	if file == null:
		load_error.emit("Could not open save file for reading")
		return null

	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_string)

	if parse_result != OK:
		load_error.emit("Failed to parse save file JSON")
		return null

	var character_data = json.data
	if not character_data is Dictionary:
		load_error.emit("Save file does not contain valid character data")
		return null

	var character = deserialize_character(character_data)
	if character == null:
		load_error.emit("Failed to deserialize character data")
		return null

	character_loaded.emit(character)
	print("Character loaded successfully")
	return character

# Serialize character to Dictionary
func serialize_character(character: Character) -> Dictionary:
	# TODO can this be simplified?
	return {
		"name": character.name,
		"race": character.race,
		"character_class": character.character_class,
		"background": character.background,
		"level": character.level,
		"experience": character.experience_points,
		"strength": character.strength,
		"dexterity": character.dexterity,
		"constitution": character.constitution,
		"intelligence": character.intelligence,
		"wisdom": character.wisdom,
		"charisma": character.charisma,
		"hit_points": character.hit_points,
		"max_hit_points": character.max_hit_points,
		"armor_class": character.armor_class,
		"proficiency_bonus": character.proficiency_bonus,
		"gold": character.gold,
		"equipment": character.equipment,
		"current_activity": character.current_activity,
		"activity_start_time": character.activity_start_time,
		"activity_duration": character.activity_duration,
		"faction_reputation": character.faction_reputation,
		"size": character.size,
		"speed": character.speed,
		"spellbook": character.spellbook,
		"skill_proficiencies": character.skill_proficiencies,
		"tool_proficiencies": character.tool_proficiencies,
		"language_proficiencies": character.language_proficiencies,
		"weapon_proficiencies": character.weapon_proficiencies,
		"armor_proficiencies": character.armor_proficiencies,
		"saving_throw_proficiencies": character.saving_throw_proficiencies,
		"racial_traits": character.racial_traits,
		"known_spells": character.known_spells,
		"active_buffs": character.active_buffs
	}

# Deserialize character from Dictionary
func deserialize_character(character_data: Dictionary) -> Character:
	var character = Character.new()

	# Basic character info
	character.name = character_data.get("name", "")
	character.race = character_data.get("race", "")
	character.character_class = character_data.get("character_class", "")
	character.background = character_data.get("background", "")
	character.level = character_data.get("level", 1)
	character.experience_points = character_data.get("experience", 0)

	# Ability scores
	character.strength = character_data.get("strength", 10)
	character.dexterity = character_data.get("dexterity", 10)
	character.constitution = character_data.get("constitution", 10)
	character.intelligence = character_data.get("intelligence", 10)
	character.wisdom = character_data.get("wisdom", 10)
	character.charisma = character_data.get("charisma", 10)

	# Combat stats
	character.hit_points = character_data.get("hit_points", 0)
	character.max_hit_points = character_data.get("max_hit_points", 0)
	character.armor_class = character_data.get("armor_class", 10)
	character.proficiency_bonus = character_data.get("proficiency_bonus", 2)

	# Resources
	character.gold = character_data.get("gold", 0)
	character.equipment = character_data.get("equipment", {})

	# Activity state
	character.current_activity = character_data.get("current_activity", "")
	character.activity_start_time = character_data.get("activity_start_time", 0.0)
	character.activity_duration = character_data.get("activity_duration", 0.0)

	# Reputation and physical traits
	character.faction_reputation = character_data.get("faction_reputation", {})
	character.size = character_data.get("size", "Medium")
	character.speed = character_data.get("speed", 30)

	# Magic and spellcasting
	character.spellbook = character_data.get("spellbook", {})

	# Proficiencies
	character.skill_proficiencies = character_data.get("skill_proficiencies", [])
	character.tool_proficiencies = character_data.get("tool_proficiencies", [])
	character.language_proficiencies = character_data.get("language_proficiencies", [])
	character.weapon_proficiencies = character_data.get("weapon_proficiencies", [])
	character.armor_proficiencies = character_data.get("armor_proficiencies", [])
	character.saving_throw_proficiencies = character_data.get("saving_throw_proficiencies", [])

	# Traits and abilities
	character.racial_traits = character_data.get("racial_traits", [])
	character.known_spells = character_data.get("known_spells", [])
	character.active_buffs = character_data.get("active_buffs", [])

	return character

# Check if save file exists
func has_save_file() -> bool:
	return FileAccess.file_exists(save_file_path)

# Delete save file
func delete_save_file() -> bool:
	if not has_save_file():
		return false

	var dir = DirAccess.open("user://")
	if dir == null:
		return false

	var result = dir.remove(save_file_path)
	return result == OK

# Get save file info
func get_save_file_info() -> Dictionary:
	if not has_save_file():
		return {}

	var file = FileAccess.open(save_file_path, FileAccess.READ)
	if file == null:
		return {}

	var file_size = file.get_length()
	file.close()

	return {
		"path": save_file_path,
		"size": file_size,
		"exists": true
	}

# Backup save file
func backup_save_file() -> bool:
	if not has_save_file():
		return false

	var backup_path = save_file_path + ".backup"
	var file = FileAccess.open(save_file_path, FileAccess.READ)
	if file == null:
		return false

	var content = file.get_as_text()
	file.close()

	var backup_file = FileAccess.open(backup_path, FileAccess.WRITE)
	if backup_file == null:
		return false

	backup_file.store_string(content)
	backup_file.close()

	return true

# Restore from backup
func restore_from_backup() -> bool:
	var backup_path = save_file_path + ".backup"
	if not FileAccess.file_exists(backup_path):
		return false

	var backup_file = FileAccess.open(backup_path, FileAccess.READ)
	if backup_file == null:
		return false

	var content = backup_file.get_as_text()
	backup_file.close()

	var file = FileAccess.open(save_file_path, FileAccess.WRITE)
	if file == null:
		return false

	file.store_string(content)
	file.close()

	return true

# Set custom save file path
func set_save_file_path(path: String) -> void:
	save_file_path = path

# Get current save file path
func get_save_file_path() -> String:
	return save_file_path
