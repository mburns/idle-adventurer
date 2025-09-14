extends Node

# Starting equipment system
# Handles assignment of starting equipment based on class and background

class_name StartingEquipment

signal equipment_assigned(character: Character, equipment: Dictionary)

# Assign starting equipment to character
func assign_starting_equipment(character: Character, class_type: String, _background: String) -> void:
	# Add basic starting items
	add_starting_items(character, class_type)

	# Add class-specific equipment from data
	var class_data = {}
	var starting_equipment_data = {}

	if Engine.has_singleton("DataLoader"):
		var data_loader = Engine.get_singleton("DataLoader")
		class_data = data_loader.get_class_data(class_type)
		starting_equipment_data = class_data.get("starting_equipment", {})
	else:
		# Fallback for headless mode - use basic equipment
		starting_equipment_data = get_basic_starting_equipment(class_type)

	# Load equipment from structured data
	if starting_equipment_data is Dictionary:
		load_class_starting_equipment(character, starting_equipment_data)
	else:
		print("Warning: starting_equipment_data is not a Dictionary, got: ", typeof(starting_equipment_data))
		# Create empty dictionary to avoid type errors
		starting_equipment_data = {}

	equipment_assigned.emit(character, starting_equipment_data)

# Add basic starting items to character inventory
func add_starting_items(character: Character, _class_type: String) -> void:
	#TODO this should use the inventory system
	var _inventory_system = get_inventory_system()

	# Basic items all characters start with
	var basic_items = [
		{"name": "Backpack", "type": "container", "weight": 5.0, "value": 2.0},
		{"name": "Bedroll", "type": "gear", "weight": 7.0, "value": 1.0},
		{"name": "Rations (1 day)", "type": "consumable", "weight": 2.0, "value": 0.5},
		{"name": "Torch", "type": "tool", "weight": 1.0, "value": 0.01},
		{"name": "Waterskin", "type": "container", "weight": 5.0, "value": 2.0}
	]

	for item_data in basic_items:
		add_item_to_character(character, item_data)

	# Class-specific starting items
	# Class-specific equipment is now loaded from data files

# Load class starting equipment from data
func load_class_starting_equipment(character: Character, starting_equipment_data: Dictionary) -> void:
	"""Load starting equipment from class data"""

	# Defensive check to ensure we have a valid Dictionary
	if not starting_equipment_data is Dictionary:
		print("Warning: starting_equipment_data is not a Dictionary, got: ", typeof(starting_equipment_data))
		return

	# Load armor
	var armor_list = starting_equipment_data.get("armor", [])
	for armor_name in armor_list:
		var armor_data = create_item_from_name(armor_name)
		add_item_to_character(character, armor_data)

	# Load weapons
	var weapons_list = starting_equipment_data.get("weapons", [])
	for weapon_name in weapons_list:
		var weapon_data = create_item_from_name(weapon_name)
		add_item_to_character(character, weapon_data)

	# Load focus items
	var focus_list = starting_equipment_data.get("focus", [])
	for focus_name in focus_list:
		var focus_data = create_item_from_name(focus_name)
		add_item_to_character(character, focus_data)

	# Load packs
	var packs_list = starting_equipment_data.get("packs", [])
	for pack_name in packs_list:
		var pack_data = create_item_from_name(pack_name)
		add_item_to_character(character, pack_data)

		# Add pack contents
		var pack_contents = pack_data.get("contents", [])
		for content_item_name in pack_contents:
			var content_data = create_item_from_name(content_item_name)
			add_item_to_character(character, content_data)

	# Load other equipment
	var other_equipment = starting_equipment_data.get("other", [])
	for equipment_name in other_equipment:
		var equipment_data = create_item_from_name(equipment_name)
		add_item_to_character(character, equipment_data)

# Create item data from item name
func create_item_from_name(item_name: String) -> Dictionary:
	# This would typically load from a comprehensive item database
	# For now, return basic item data
	return {
		"name": item_name,
		"type": "misc",
		"weight": 1.0,
		"value": 1.0
	}

# Add item to character's inventory
func add_item_to_character(character: Character, item_data: Dictionary) -> void:
	var inventory_system = get_inventory_system()
	inventory_system.add_item(character, item_data, 1)

# Get inventory system instance
func get_inventory_system() -> InventorySystem:
	# Try to access AutoloadManager, fallback to new instance if not available
	var autoload_manager = null
	if Engine.has_singleton("AutoloadManager"):
		autoload_manager = Engine.get_singleton("AutoloadManager")

	if autoload_manager and autoload_manager.inventory_system:
		return autoload_manager.inventory_system
	# Fallback: create new instance if singleton not available
	return InventorySystem.new()

# Get basic starting equipment for headless mode
func get_basic_starting_equipment(class_type: String) -> Dictionary:
	"""Get basic starting equipment when DataLoader is not available"""
	var basic_equipment = {
		"armor": [],
		"weapons": [],
		"tools": [],
		"gear": []
	}

	match class_type.to_lower():
		"fighter":
			basic_equipment["armor"] = ["Chain Mail"]
			basic_equipment["weapons"] = ["Longsword", "Shield"]
		"wizard":
			basic_equipment["weapons"] = ["Quarterstaff"]
			basic_equipment["gear"] = ["Component Pouch"]
		"rogue":
			basic_equipment["armor"] = ["Leather Armor"]
			basic_equipment["weapons"] = ["Rapier", "Shortbow"]
		"cleric":
			basic_equipment["armor"] = ["Chain Mail"]
			basic_equipment["weapons"] = ["Mace", "Shield"]
		_:
			basic_equipment["weapons"] = ["Shortsword"]

	return basic_equipment

# Get starting equipment options for a class
func get_starting_equipment_options(class_type: String) -> Dictionary:
	var class_data = {}
	if Engine.has_singleton("DataLoader"):
		var data_loader = Engine.get_singleton("DataLoader")
		class_data = data_loader.get_class_data(class_type)

	if class_data.is_empty():
		return {}

	return class_data.get("starting_equipment", {})

# Validate starting equipment assignment
func validate_starting_equipment(character: Character, class_type: String) -> bool:
	if character == null:
		return false

	var class_data = {}
	if Engine.has_singleton("DataLoader"):
		var data_loader = Engine.get_singleton("DataLoader")
		class_data = data_loader.get_class_data(class_type)

	if class_data.is_empty():
		return false

	# Check if character has required proficiencies for equipment
	var _starting_equipment_data = class_data.get("starting_equipment", {})
	# This would check if character can use the equipment
	# For now, just return true

	return true

# Get equipment weight for character
func get_character_equipment_weight(_character: Character) -> float:
	var total_weight = 0.0

	# This would iterate through character's inventory
	# For now, return 0
	return total_weight

# Check if character is encumbered
func is_character_encumbered(character: Character) -> bool:
	var equipment_weight = get_character_equipment_weight(character)
	var strength_score = character.strength

	# Encumbered if carrying more than 5 * strength score pounds
	return equipment_weight > (strength_score * 5.0)
