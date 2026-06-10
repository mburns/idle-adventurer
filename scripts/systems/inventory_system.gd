extends Node

# Inventory system for managing character items with stacking

class_name InventorySystem

# Preload required classes
const Character = preload("res://scripts/core/character.gd")

signal item_added(character: Character, item: Dictionary, quantity: int)
signal item_removed(character: Character, item: Dictionary, quantity: int)
signal item_used(character: Character, item: Dictionary, quantity: int)
signal inventory_changed(character: Character)

# Item categories for organization
enum ItemCategory {
	WEAPONS,
	ARMOR,
	CONSUMABLES,
	TOOLS,
	ADVENTURING_GEAR,
	TREASURE,
	SPELL_COMPONENTS,
	MISC
}

# Item types loaded dynamically from data/types/item_types.tres
var stackable_types: Array = []
var unique_types: Array = []
var item_types_data: Dictionary = {}

var character_inventories: Dictionary = {} # character_name -> inventory_data

func _init() -> void:
	setup_inventory_system()

func setup_inventory_system() -> void:
	"""Initialize the inventory system"""
	# print("Inventory System initialized")
	load_item_types()

func load_item_types() -> void:
	"""Load item types dynamically from data/types/item_types.tres"""
	var resource_path = "res://data/types/item_types.tres"
	var resource = load(resource_path)

	if resource == null:
		print("Warning: Could not load item types from ", resource_path, ". Using defaults.")
		load_default_item_types()
		return

	# Try to get data from resource
	var resource_data = resource.get("metadata/yaml_data")
	if resource_data == null:
		resource_data = {}
	if resource_data.size() > 0:
		item_types_data = resource_data
		populate_item_type_arrays()
		print("Loaded item types from .tres successfully")
	else:
		print("Failed to parse item types from .tres, using defaults")
		load_default_item_types()

func parse_item_types_yaml(yaml_content: String) -> Dictionary:
	"""Parse item types YAML content"""
	var result = {}
	var lines = yaml_content.split("\n")
	var current_section = ""
	var current_array = []
	var in_array = false

	for line in lines:
		line = line.strip_edges()

		# Skip empty lines and comments
		if line.is_empty() or line.begins_with("#"):
			continue

		# Check for section headers
		if line.ends_with(":"):
			# Save previous section
			if current_section != "" and current_array.size() > 0:
				result[current_section] = current_array

			# Start new section
			current_section = line.rstrip(":")
			current_array = []
			in_array = true
			continue

		# Parse array items
		if in_array and line.begins_with("- "):
			var item_content = line.substr(2).strip_edges()
			var item_data = parse_yaml_item(item_content)
			if item_data.size() > 0:
				current_array.append(item_data)

	# Save last section
	if current_section != "" and current_array.size() > 0:
		result[current_section] = current_array

	return result

func parse_yaml_item(item_line: String) -> Dictionary:
	"""Parse a single YAML item line"""
	var item_data = {}

	# Simple parsing for basic key-value pairs
	if "id:" in item_line:
		var parts = item_line.split("id:", 1)
		if parts.size() > 1:
			item_data["id"] = parts[1].strip_edges()

	return item_data

func populate_item_type_arrays() -> void:
	"""Populate stackable_types and unique_types from parsed data"""
	stackable_types.clear()
	unique_types.clear()

	# Extract item categories and determine which are stackable/unique
	if item_types_data.has("item_categories"):
		var categories_data = item_types_data["item_categories"]
		# Handle both array and object formats
		var categories = []
		if categories_data is Array:
			categories = categories_data
		elif categories_data is Dictionary and categories_data.has("item_categories"):
			categories = categories_data["item_categories"]

		for category in categories:
			var category_id = ""
			if category is String:
				category_id = category.replace("id: ", "")
			elif category is Dictionary and category.has("id"):
				category_id = category["id"]

			# Determine if this category should be stackable or unique
			if category_id != "":
				match category_id:
					"CONSUMABLE", "AMMUNITION", "SPELL_COMPONENT", "TOOL", "GEAR":
						stackable_types.append(category_id.to_lower())
					"ARMOR", "WEAPON", "SHIELD", "ACCESSORY", "ARTIFACT":
						unique_types.append(category_id.to_lower())

	# If no categories found, use item properties
	if item_types_data.has("item_properties"):
		var properties = item_types_data["item_properties"]
		for prop in properties:
			var prop_id = ""
			if prop is String:
				prop_id = prop
			elif prop is Dictionary and prop.has("id"):
				prop_id = prop["id"]
				if "stackable" in prop_id.to_lower():
					stackable_types.append(prop_id.to_lower())
				elif "unique" in prop_id.to_lower():
					unique_types.append(prop_id.to_lower())

	print("Loaded ", stackable_types.size(), " stackable types and ", unique_types.size(), " unique types from YAML")

func load_default_item_types() -> void:
	"""Load default item types if YAML loading fails"""
	# TODO can this be done dynamically to support more item types?
	stackable_types = [
		"consumable",
		"ammunition",
		"spell_component",
		"treasure",
		"food",
		"potion",
		"scroll"
	]

	unique_types = [
		"weapon",
		"armor",
		"tool",
		"adventuring_gear",
		"magic_item",
		"equipment"
	]
func get_character_inventory(character: Character) -> Dictionary:
	"""Get character's inventory"""
	if not character_inventories.has(character.name):
		character_inventories[character.name] = {
			"items": {}, # item_id -> item_data
			"max_slots": 30, # Default inventory size
			"used_slots": 0
		}
	return character_inventories[character.name]

func add_item(character: Character, item: Dictionary, quantity: int = 1) -> bool:
	"""Add item to character's inventory"""
	var inventory = get_character_inventory(character)
	var item_id = item.get("id", item.get("name", "unknown"))

	# Check if item can stack
	if can_stack_item(item):
		return add_stackable_item(character, item, quantity)
	else:
		return add_unique_item(character, item, quantity)

func add_stackable_item(character: Character, item: Dictionary, quantity: int) -> bool:
	"""Add a stackable item to inventory"""
	var inventory = get_character_inventory(character)
	var item_id = item.get("id", item.get("name", "unknown"))

	if inventory["items"].has(item_id):
		# Add to existing stack
		inventory["items"][item_id]["quantity"] += quantity
	else:
		# Create new stack
		var item_data = item.duplicate()
		item_data["quantity"] = quantity
		item_data["max_stack"] = get_max_stack_size(item)
		inventory["items"][item_id] = item_data
		inventory["used_slots"] += 1

	item_added.emit(character, item, quantity)
	inventory_changed.emit(character)
	print(character.name + " received " + str(quantity) + "x " + item.get("name", "Unknown Item"))
	return true

func add_unique_item(character: Character, item: Dictionary, quantity: int) -> bool:
	"""Add a unique item to inventory"""
	var inventory = get_character_inventory(character)

	# Check if inventory has space
	if inventory["used_slots"] >= inventory["max_slots"]:
		print(character.name + " inventory is full!")
		return false

	# Add each item as a separate entry
	for i in range(quantity):
		var item_id = item.get("id", item.get("name", "unknown")) + "_" + str(Time.get_unix_time_from_system()) + "_" + str(i)
		var item_data = item.duplicate()
		item_data["quantity"] = 1
		item_data["max_stack"] = 1
		item_data["unique_id"] = item_id
		inventory["items"][item_id] = item_data
		inventory["used_slots"] += 1

	item_added.emit(character, item, quantity)
	inventory_changed.emit(character)
	print(character.name + " received " + str(quantity) + "x " + item.get("name", "Unknown Item"))
	return true

func remove_item(character: Character, item_id: String, quantity: int = 1) -> bool:
	"""Remove item from character's inventory"""
	var inventory = get_character_inventory(character)

	if not inventory["items"].has(item_id):
		return false

	var item_data = inventory["items"][item_id]
	var current_quantity = item_data.get("quantity", 1)

	if current_quantity <= quantity:
		# Remove entire stack
		inventory["items"].erase(item_id)
		inventory["used_slots"] -= 1
		item_removed.emit(character, item_data, current_quantity)
	else:
		# Reduce quantity
		inventory["items"][item_id]["quantity"] -= quantity
		item_removed.emit(character, item_data, quantity)

	inventory_changed.emit(character)
	return true

func use_item(character: Character, item_id: String, quantity: int = 1) -> bool:
	"""Use an item from inventory"""
	var inventory = get_character_inventory(character)

	if not inventory["items"].has(item_id):
		return false

	var item_data = inventory["items"][item_id]
	var current_quantity = item_data.get("quantity", 1)

	if current_quantity < quantity:
		return false

	# Apply item effects
	apply_item_effects(character, item_data, quantity)

	# Remove used quantity
	remove_item(character, item_id, quantity)

	item_used.emit(character, item_data, quantity)
	print(character.name + " used " + str(quantity) + "x " + item_data.get("name", "Unknown Item"))
	return true

func apply_item_effects(character: Character, item: Dictionary, quantity: int) -> void:
	"""Apply the effects of using an item"""
	var item_type = item.get("type", "")
	var item_name = item.get("name", "")

	match item_type:
		"consumable", "potion":
			apply_consumable_effects(character, item, quantity)
		"food":
			apply_food_effects(character, item, quantity)
		"scroll":
			apply_scroll_effects(character, item, quantity)
		_:
			print("Used " + item_name + " (no special effects)")

func apply_consumable_effects(character: Character, item: Dictionary, quantity: int) -> void:
	"""Apply effects of consumable items"""
	var item_name = item.get("name", "").to_lower()

	if "healing" in item_name:
		var healing_amount = item.get("healing", 0)
		if healing_amount > 0:
			character.hit_points = min(character.max_hit_points, character.hit_points + (healing_amount * quantity))
			print(character.name + " healed for " + str(healing_amount * quantity) + " hit points")

	if "antitoxin" in item_name:
		# Add poison resistance buff
		var buff = {
			"name": "Antitoxin",
			"effect": "poison_resistance",
			"duration": 3600, # 1 hour
			"expires_at": Time.get_unix_time_from_system() + 3600
		}
		character.active_buffs.append(buff)
		print(character.name + " gained poison resistance for 1 hour")

func apply_food_effects(character: Character, item: Dictionary, quantity: int) -> void:
	"""Apply effects of food items"""
	var item_name = item.get("name", "").to_lower()

	if "rations" in item_name:
		# Rations provide sustenance (tracked separately)
		print(character.name + " ate " + str(quantity) + " days of rations")

func apply_scroll_effects(character: Character, item: Dictionary, quantity: int) -> void:
	"""Apply effects of scroll items"""
	var spell_name = item.get("spell", "")
	if spell_name != "":
		print(character.name + " used scroll of " + spell_name)

func can_stack_item(item: Dictionary) -> bool:
	"""Check if an item can stack"""
	var item_type = item.get("type", "")
	return item_type in stackable_types

func get_max_stack_size(item: Dictionary) -> int:
	"""Get maximum stack size for an item"""
	var item_type = item.get("type", "")

	match item_type:
		"consumable", "potion":
			return 10
		"ammunition":
			return 50
		"spell_component":
			return 100
		"treasure", "food":
			return 20
		"scroll":
			return 5
		_:
			return 1

func get_items_by_category(character: Character, category: ItemCategory) -> Dictionary:
	"""Get items filtered by category"""
	var inventory = get_character_inventory(character)
	var filtered_items = {}

	for item_id in inventory["items"].keys():
		var item = inventory["items"][item_id]
		var item_category = get_item_category(item)

		if item_category == category:
			filtered_items[item_id] = item

	return filtered_items

func get_item_category(item: Dictionary) -> ItemCategory:
	"""Get the category of an item"""
	var item_type = item.get("type", "")
	var item_name = item.get("name", "").to_lower()

	match item_type:
		"weapon":
			return ItemCategory.WEAPONS
		"armor":
			return ItemCategory.ARMOR
		"consumable", "potion", "food":
			return ItemCategory.CONSUMABLES
		"tool":
			return ItemCategory.TOOLS
		"adventuring_gear":
			return ItemCategory.ADVENTURING_GEAR
		"treasure":
			return ItemCategory.TREASURE
		"spell_component":
			return ItemCategory.SPELL_COMPONENTS
		_:
			return ItemCategory.MISC

func search_inventory(character: Character, query: String) -> Dictionary:
	"""Search character's inventory by name or description"""
	var inventory = get_character_inventory(character)
	var results = {}
	query = query.to_lower()

	for item_id in inventory["items"].keys():
		var item = inventory["items"][item_id]
		var name = item.get("name", "").to_lower()
		var description = item.get("description", "").to_lower()

		if name.find(query) != -1 or description.find(query) != -1:
			results[item_id] = item

	return results

func get_inventory_weight(character: Character) -> float:
	"""Calculate total weight of character's inventory"""
	var inventory = get_character_inventory(character)
	var total_weight = 0.0

	for item_id in inventory["items"].keys():
		var item = inventory["items"][item_id]
		var weight = item.get("weight", 0.0)
		var quantity = item.get("quantity", 1)
		total_weight += weight * quantity

	return total_weight

func get_inventory_value(character: Character) -> float:
	"""Calculate total value of character's inventory"""
	var inventory = get_character_inventory(character)
	var total_value = 0.0

	for item_id in inventory["items"].keys():
		var item = inventory["items"][item_id]
		var value = item.get("value", item.get("cost", 0.0))
		var quantity = item.get("quantity", 1)
		total_value += value * quantity

	return total_value

func sort_inventory(character: Character, sort_by: String = "name") -> Array:
	"""Sort inventory items by specified criteria"""
	var inventory = get_character_inventory(character)
	var items = []

	for item_id in inventory["items"].keys():
		var item = inventory["items"][item_id]
		item["inventory_id"] = item_id
		items.append(item)

	match sort_by:
		"name":
			items.sort_custom(func(a, b): return a.get("name", "") < b.get("name", ""))
		"type":
			items.sort_custom(func(a, b): return a.get("type", "") < b.get("type", ""))
		"value":
			items.sort_custom(func(a, b): return a.get("value", 0) > b.get("value", 0))
		"quantity":
			items.sort_custom(func(a, b): return a.get("quantity", 0) > b.get("quantity", 0))
		"weight":
			items.sort_custom(func(a, b): return a.get("weight", 0) > b.get("weight", 0))

	return items

func get_inventory_summary(character: Character) -> Dictionary:
	"""Get summary of character's inventory"""
	var inventory = get_character_inventory(character)
	var total_items = 0
	var total_value = 0.0
	var total_weight = 0.0
	var categories = {}

	for item_id in inventory["items"].keys():
		var item = inventory["items"][item_id]
		var quantity = item.get("quantity", 1)
		var value = item.get("value", item.get("cost", 0.0))
		var weight = item.get("weight", 0.0)
		var category = get_item_category(item)

		total_items += quantity
		total_value += value * quantity
		total_weight += weight * quantity

		var category_name = ItemCategory.keys()[category]
		if not categories.has(category_name):
			categories[category_name] = 0
		categories[category_name] += quantity

	return {
		"total_items": total_items,
		"total_value": total_value,
		"total_weight": total_weight,
		"used_slots": inventory["used_slots"],
		"max_slots": inventory["max_slots"],
		"categories": categories
	}

func clear_inventory(character: Character) -> void:
	"""Clear character's entire inventory"""
	var inventory = get_character_inventory(character)
	inventory["items"].clear()
	inventory["used_slots"] = 0
	inventory_changed.emit(character)
	print(character.name + " inventory cleared")

func transfer_item(from_character: Character, to_character: Character, item_id: String, quantity: int = 1) -> bool:
	"""Transfer item between characters"""
	if remove_item(from_character, item_id, quantity):
		var item_data = get_character_inventory(from_character)["items"].get(item_id, {})
		if add_item(to_character, item_data, quantity):
			print("Transferred " + str(quantity) + "x " + item_data.get("name", "Unknown Item") + " from " + from_character.name + " to " + to_character.name)
			return true
		else:
			# Return item if transfer failed
			add_item(from_character, item_data, quantity)
	return false
