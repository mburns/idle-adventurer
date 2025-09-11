extends Node

# Singleton for managing the current character
var current_character: Character
var save_file_path: String = "user://character_save.dat"

# Signal emitted when character changes
signal character_changed(character: Character)
signal character_created(character: Character)
signal character_loaded(character: Character)

# Initialize with a default character
func _ready() -> void:
	# Wait for DataLoader to finish loading
	await get_tree().process_frame
	if current_character == null:
		create_default_character()

# Create a new character with default values
func create_character(character_name: String, race: String, character_class: String, background: String) -> Character:
	var character = Character.new()
	character.name = character_name
	character.race = race
	character.character_class = character_class
	character.background = background

	# Apply race bonuses/traits
	apply_race_bonuses(character, race)
	apply_racial_traits(character, race)

	# Apply class features and starting spell slots
	apply_class_features(character, character_class)
	apply_starting_spell_slots(character, character_class)

	# Apply background features and starting equipment
	apply_background_features(character, background)
	assign_starting_equipment(character, character_class, background)

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
func apply_race_bonuses(character: Character, race: String) -> void:
	var race_data = DataLoader.get_race_data(race)
	if race_data.is_empty():
		return

	var ability_increases = race_data.get("ability_increases", {})
	for ability in ability_increases.keys():
		var increase = ability_increases[ability]
		# Use proper property access instead of generic get/set
		match ability:
			"strength":
				character.strength += increase
			"dexterity":
				character.dexterity += increase
			"constitution":
				character.constitution += increase
			"intelligence":
				character.intelligence += increase
			"wisdom":
				character.wisdom += increase
			"charisma":
				character.charisma += increase

	# Add languages
	var languages = race_data.get("languages", [])
	for language in languages:
		character.known_languages.append(str(language))

	# Size and speed
	character.size = race_data.get("size", "Medium")
	character.speed = race_data.get("speed", 30)

func apply_racial_traits(character: Character, race: String) -> void:
	"""Apply racial traits based on race data"""
	var race_data = DataLoader.get_race_data(race)
	if race_data.is_empty():
		print("No race data found for: " + race)
		return

	# Apply ability score increases
	apply_ability_score_increases(character, race_data)

	# Apply size and speed
	apply_size_and_speed(character, race_data)

	# Apply racial traits
	apply_racial_abilities(character, race_data)

	# Apply languages
	apply_racial_languages(character, race_data)

func apply_ability_score_increases(_character: Character, _race_data: Dictionary) -> void:
	"""Apply ability score increases from race - this function is redundant since ability_increases are handled in apply_race_bonuses()"""
	# This function is no longer needed as ability score increases are handled
	# directly in apply_race_bonuses() using the ability_increases field
	pass

func apply_size_and_speed(_character: Character, _race_data: Dictionary) -> void:
	"""Apply size and speed from race"""
	# Size and speed are already handled in apply_race_bonuses() using the size and speed fields
	# This function is redundant since size and speed are stored directly in the race data
	pass

func apply_racial_abilities(character: Character, race_data: Dictionary) -> void:
	"""Apply racial abilities and traits"""
	var traits = race_data.get("traits", [])
	var racial_abilities: Array[Dictionary] = []

	for race_trait in traits:
		# traits are stored as strings, not dictionaries
		var trait_name = str(race_trait)

		# Skip ability score increases, size, speed, and languages
		if "ability score increase" in trait_name.to_lower() or "size" in trait_name.to_lower() or "speed" in trait_name.to_lower() or "languages" in trait_name.to_lower():
			continue

		# Add racial trait with basic description
		racial_abilities.append({
			"name": trait_name,
			"description": "Racial trait: " + trait_name,
			"type": "racial"
		})

	character.racial_traits = racial_abilities

func apply_racial_languages(_character: Character, _race_data: Dictionary) -> void:
	"""Apply racial languages"""
	# Languages are already handled in apply_race_bonuses() using the languages field
	# This function is redundant since languages are stored directly in the race data
	pass

# Apply class features to character
func apply_class_features(character: Character, class_type: String) -> void:
	var class_data = DataLoader.get_class_data(class_type)
	if class_data.is_empty():
		return

	# Add proficiencies from the new data structure
	var proficiencies = class_data.get("proficiencies", {})

	# Add skill proficiencies
	var skill_options = proficiencies.get("skills", [])
	# For now, just add the first few skills (in a real game, player would choose)
	for i in range(min(2, skill_options.size())): # Default to 2 skills
		character.skill_proficiencies.append(str(skill_options[i]))

	# Add armor proficiencies
	var armor_proficiencies = proficiencies.get("armor", [])
	for armor in armor_proficiencies:
		character.armor_proficiencies.append(armor)

	# Add weapon proficiencies
	var weapon_proficiencies = proficiencies.get("weapons", [])
	for weapon in weapon_proficiencies:
		character.weapon_proficiencies.append(weapon)

	# Add tool proficiencies
	var tool_proficiencies = proficiencies.get("tools", [])
	for tool in tool_proficiencies:
		character.tool_proficiencies.append(tool )

	# Saving throws
	var saving_throws = proficiencies.get("saving_throws", [])
	character.set("saving_throws", saving_throws)

func apply_starting_spell_slots(_character: Character, class_type: String) -> void:
	var class_data = DataLoader.get_class_data(class_type)
	if class_data.is_empty():
		return
	var slots = class_data.get("spell_slots_per_level", [])
	if slots.size() > 0:
		# spell_slots is already initialized as Array[int] in Character class
		pass

# Apply background features to character
func apply_background_features(character: Character, background: String) -> void:
	var background_data = DataLoader.get_background_data(background)
	if background_data.is_empty():
		return

	# Add skill proficiencies
	var skill_proficiencies = background_data.get("skill_proficiencies", [])
	for skill in skill_proficiencies:
		character.skill_proficiencies.append(skill)

	# Add tool proficiencies
	var tool_proficiencies = background_data.get("tool_proficiencies", [])
	for tool in tool_proficiencies:
		character.tool_proficiencies.append(tool )

	# Add languages
	var languages = background_data.get("languages", [])
	for language in languages:
		character.language_proficiencies.append(language)

func assign_starting_equipment(character: Character, class_type: String, background: String) -> void:
	# Pull starting equipment from class (and background if applicable)
	var class_data = DataLoader.get_class_data(class_type)
	if not class_data.is_empty():
		var starting_equipment = class_data.get("equipment", [])
		# Add equipment to character's equipment dictionary
		for i in range(starting_equipment.size()):
			var slot_name = "equipment_" + str(i)
			character.equipment[slot_name] = starting_equipment[i]

	var background_data = DataLoader.get_background_data(background)
	if not background_data.is_empty():
		var bg_equipment = background_data.get("equipment", [])
		if not character.equipment.has("pack") and bg_equipment.size() > 0:
			character.equipment["pack"] = bg_equipment

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
		"height": current_character.height,
		"weight": current_character.weight,
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
		"faction_reputation": current_character.faction_reputation,
		"size": current_character.size,
		"speed": current_character.speed,
		"racial_traits": current_character.racial_traits,
		"known_spells": current_character.known_spells,
		"spellbook": current_character.spellbook,
		"active_buffs": current_character.active_buffs
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
	character.height = character_data.get("height", 60)
	character.weight = character_data.get("weight", 150)
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
	# spell_slots is already initialized as Array[int] in Character class
	# Proficiency arrays are already initialized as Array[String] in Character class
	# character.skill_proficiencies = character_data.get("skill_proficiencies", [])
	# character.tool_proficiencies = character_data.get("tool_proficiencies", [])
	# character.language_proficiencies = character_data.get("language_proficiencies", [])
	# character.weapon_proficiencies = character_data.get("weapon_proficiencies", [])
	# character.armor_proficiencies = character_data.get("armor_proficiencies", [])
	character.equipment = character_data.get("equipment", {})
	character.current_activity = character_data.get("current_activity", "")
	character.activity_start_time = character_data.get("activity_start_time", 0.0)
	character.activity_duration = character_data.get("activity_duration", 0.0)
	character.faction_reputation = character_data.get("faction_reputation", {})
	character.size = character_data.get("size", "Medium")
	character.speed = character_data.get("speed", 30)
	# Typed arrays are already initialized in Character class
	# character.racial_traits = character_data.get("racial_traits", [])
	# character.known_spells = character_data.get("known_spells", [])
	character.spellbook = character_data.get("spellbook", {})
	# character.active_buffs = character_data.get("active_buffs", [])

	current_character = character
	character_loaded.emit(character)
	character_changed.emit(character)

	print("Character loaded successfully")
	return true

func apply_starting_equipment(character: Character, class_type: String, _background: String) -> void:
	"""Add starting equipment to character inventory"""
	# Add basic starting items
	add_starting_items(character, class_type)

	# Add class-specific equipment
	var class_data = DataLoader.get_class_data(class_type)
	var equipment_list = class_data.get("starting_equipment", [])

	for item_name in equipment_list:
		var item_data = create_item_from_name(item_name)
		if item_data:
			add_item_to_character(character, item_data)

func add_starting_items(character: Character, class_type: String) -> void:
	"""Add basic starting items to character inventory"""
	var inventory_system = get_inventory_system()

	# Basic items all characters start with
	var basic_items = [
		{
			"id": "backpack",
			"name": "Backpack",
			"type": "adventuring_gear",
			"description": "A backpack for carrying equipment",
			"weight": 5.0,
			"value": 2.0,
			"rarity": "common"
		},
		{
			"id": "bedroll",
			"name": "Bedroll",
			"type": "adventuring_gear",
			"description": "A bedroll for sleeping",
			"weight": 7.0,
			"value": 1.0,
			"rarity": "common"
		},
		{
			"id": "rations",
			"name": "Rations (1 day)",
			"type": "food",
			"description": "One day's worth of food",
			"weight": 2.0,
			"value": 0.5,
			"rarity": "common"
		},
		{
			"id": "waterskin",
			"name": "Waterskin",
			"type": "adventuring_gear",
			"description": "A container for water",
			"weight": 5.0,
			"value": 2.0,
			"rarity": "common"
		},
		{
			"id": "torch",
			"name": "Torch",
			"type": "adventuring_gear",
			"description": "A torch that burns for 1 hour",
			"weight": 1.0,
			"value": 0.01,
			"rarity": "common"
		}
	]

	# Add basic items
	for item in basic_items:
		inventory_system.add_item(character, item, 1)

	# Add class-specific starting items
	match class_type.to_lower():
		"fighter":
			add_fighter_starting_items(character)
		"wizard":
			add_wizard_starting_items(character)
		"rogue":
			add_rogue_starting_items(character)
		"cleric":
			add_cleric_starting_items(character)
		"ranger":
			add_ranger_starting_items(character)

func add_fighter_starting_items(character: Character) -> void:
	"""Add fighter-specific starting items"""
	var inventory_system = get_inventory_system()

	var fighter_items = [
		{
			"id": "chain_mail",
			"name": "Chain Mail",
			"type": "armor",
			"description": "Heavy armor that provides good protection",
			"weight": 55.0,
			"value": 75.0,
			"rarity": "common",
			"armor_class": 16
		},
		{
			"id": "shield",
			"name": "Shield",
			"type": "armor",
			"description": "A shield that provides +2 AC",
			"weight": 6.0,
			"value": 10.0,
			"rarity": "common",
			"armor_class_bonus": 2
		},
		{
			"id": "longsword",
			"name": "Longsword",
			"type": "weapon",
			"description": "A versatile melee weapon",
			"weight": 3.0,
			"value": 15.0,
			"rarity": "common",
			"damage": "1d8 slashing"
		}
	]

	for item in fighter_items:
		inventory_system.add_item(character, item, 1)

func add_wizard_starting_items(character: Character) -> void:
	"""Add wizard-specific starting items"""
	var inventory_system = get_inventory_system()

	var wizard_items = [
		{
			"id": "spellbook",
			"name": "Spellbook",
			"type": "tool",
			"description": "A book for recording spells",
			"weight": 3.0,
			"value": 50.0,
			"rarity": "common"
		},
		{
			"id": "component_pouch",
			"name": "Component Pouch",
			"type": "tool",
			"description": "A pouch for spell components",
			"weight": 2.0,
			"value": 25.0,
			"rarity": "common"
		},
		{
			"id": "quarterstaff",
			"name": "Quarterstaff",
			"type": "weapon",
			"description": "A simple melee weapon",
			"weight": 4.0,
			"value": 0.2,
			"rarity": "common",
			"damage": "1d6 bludgeoning"
		}
	]

	for item in wizard_items:
		inventory_system.add_item(character, item, 1)

func add_rogue_starting_items(character: Character) -> void:
	"""Add rogue-specific starting items"""
	var inventory_system = get_inventory_system()

	var rogue_items = [
		{
			"id": "leather_armor",
			"name": "Leather Armor",
			"type": "armor",
			"description": "Light armor that doesn't restrict movement",
			"weight": 10.0,
			"value": 10.0,
			"rarity": "common",
			"armor_class": 11
		},
		{
			"id": "thieves_tools",
			"name": "Thieves' Tools",
			"type": "tool",
			"description": "A set of tools for picking locks and disarming traps",
			"weight": 1.0,
			"value": 25.0,
			"rarity": "common"
		},
		{
			"id": "shortsword",
			"name": "Shortsword",
			"type": "weapon",
			"description": "A light, finesse weapon",
			"weight": 2.0,
			"value": 10.0,
			"rarity": "common",
			"damage": "1d6 piercing"
		}
	]

	for item in rogue_items:
		inventory_system.add_item(character, item, 1)

func add_cleric_starting_items(character: Character) -> void:
	"""Add cleric-specific starting items"""
	var inventory_system = get_inventory_system()

	var cleric_items = [
		{
			"id": "scale_mail",
			"name": "Scale Mail",
			"type": "armor",
			"description": "Medium armor with good protection",
			"weight": 45.0,
			"value": 50.0,
			"rarity": "common",
			"armor_class": 14
		},
		{
			"id": "shield",
			"name": "Shield",
			"type": "armor",
			"description": "A shield that provides +2 AC",
			"weight": 6.0,
			"value": 10.0,
			"rarity": "common",
			"armor_class_bonus": 2
		},
		{
			"id": "mace",
			"name": "Mace",
			"type": "weapon",
			"description": "A simple melee weapon",
			"weight": 4.0,
			"value": 5.0,
			"rarity": "common",
			"damage": "1d6 bludgeoning"
		}
	]

	for item in cleric_items:
		inventory_system.add_item(character, item, 1)

func add_ranger_starting_items(character: Character) -> void:
	"""Add ranger-specific starting items"""
	var inventory_system = get_inventory_system()

	var ranger_items = [
		{
			"id": "leather_armor",
			"name": "Leather Armor",
			"type": "armor",
			"description": "Light armor that doesn't restrict movement",
			"weight": 10.0,
			"value": 10.0,
			"rarity": "common",
			"armor_class": 11
		},
		{
			"id": "longbow",
			"name": "Longbow",
			"type": "weapon",
			"description": "A powerful ranged weapon",
			"weight": 2.0,
			"value": 50.0,
			"rarity": "common",
			"damage": "1d8 piercing"
		},
		{
			"id": "arrow",
			"name": "Arrow",
			"type": "ammunition",
			"description": "Ammunition for bows",
			"weight": 0.05,
			"value": 0.05,
			"rarity": "common"
		}
	]

	for item in ranger_items:
		if item["id"] == "arrow":
			inventory_system.add_item(character, item, 20) # 20 arrows
		else:
			inventory_system.add_item(character, item, 1)

func create_item_from_name(item_name: String) -> Dictionary:
	"""Create item data from item name"""
	# This would be expanded to handle all D&D items
	# For now, return basic item data
	return {
		"id": item_name.to_lower().replace(" ", "_"),
		"name": item_name,
		"type": "misc",
		"description": "A " + item_name.to_lower(),
		"weight": 1.0,
		"value": 1.0,
		"rarity": "common"
	}

func add_item_to_character(character: Character, item_data: Dictionary) -> void:
	"""Add item to character's inventory"""
	var inventory_system = get_inventory_system()
	inventory_system.add_item(character, item_data, 1)

func get_inventory_system() -> InventorySystem:
	"""Get the inventory system instance"""
	# This would be implemented with proper singleton management
	return InventorySystem.new()

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
func set_current_character(character: Character) -> void:
	current_character = character
	character_changed.emit(character)
