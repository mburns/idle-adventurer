extends Node

# General Store and Bank system for item management and wealth storage using Resource system

class_name GeneralStore

signal item_purchased(character, item: EquipmentResource, cost: float)
signal item_sold(character, item: EquipmentResource, value: float)
signal bank_deposit(character, amount: float)
signal bank_withdrawal(character, amount: float)

# Store inventory using Resource system
var equipment_manager: EquipmentResourceManager
var store_inventory: Dictionary = {} # item_name -> EquipmentResource

func _ready():
	# Initialize equipment manager
	equipment_manager = EquipmentResourceManager.new()
	add_child(equipment_manager)

	load_store_inventory()

func load_store_inventory() -> void:
	"""Load store inventory using Resource manager"""
	store_inventory.clear()

	# Equipment is already loaded by EquipmentResourceManager
	store_inventory = equipment_manager.equipment.duplicate()

	# Add some consumables that might not be in the main item files
	add_consumable_items()

	print("Loaded ", store_inventory.size(), " items for general store using Resource system")

func load_items_from_file(file_path: String) -> void:
	"""Load items from a specific .tres file"""
	var resource = load(file_path)
	if resource == null:
		print("Warning: Could not load items from ", file_path)
		return

	var resource_data = resource.get("metadata/yaml_data")
	if resource_data == null:
		resource_data = {}
	var items = resource_data.get("items", [])

	for item in items:
		var item_id = generate_item_id(item["name"])
		store_inventory[item_id] = item

	print("Loaded ", items.size(), " items from ", file_path)

func parse_items_yaml(yaml_content: String) -> Array:
	"""Parse YAML content to extract items"""
	var items = []
	var lines = yaml_content.split("\n")
	var current_item = {}
	var in_item = false
	var in_items_section = false

	for line in lines:
		line = line.strip_edges()

		# Skip empty lines and comments
		if line.is_empty() or line.begins_with("#"):
			continue

		# Check if we're in the items section
		if line == "items:":
			in_items_section = true
			continue

		# Check if we're starting a new item
		if in_items_section and line.begins_with("- name:"):
			# Save previous item if exists
			if in_item and current_item.size() > 0:
				items.append(current_item)

			# Start new item
			current_item = {}
			in_item = true
			current_item["name"] = line.substr(7).strip_edges()
			continue

		# Parse key-value pairs within items
		if in_item and ":" in line:
			var parts = line.split(":", 1)
			var key = parts[0].strip_edges()
			var value = parts[1].strip_edges()

			# Skip empty values
			if value.is_empty():
				continue

			# Parse value based on type
			if value.is_valid_int():
				current_item[key] = value.to_int()
			elif value.is_valid_float():
				current_item[key] = value.to_float()
			elif value == "true":
				current_item[key] = true
			elif value == "false":
				current_item[key] = false
			else:
				current_item[key] = value

	# Add the last item
	if in_item and current_item.size() > 0:
		items.append(current_item)

	return items

func generate_item_id(item_name: String) -> String:
	"""Generate a unique ID for an item"""
	return item_name.to_lower().replace(" ", "_").replace("(", "").replace(")", "").replace(",", "").replace(".", "")

func add_consumable_items() -> void:
	"""Add consumable items that might not be in the main item files"""
	# TODO items should be from data/items, add them if they are missing
	var consumables = [
		{
			"name": "Healing Potion",
			"type": "consumable",
			"cost": 50,
			"description": "Restores 2d4+2 hit points",
			"rarity": "common",
			"weight": 0.5
		},
		{
			"name": "Antitoxin",
			"type": "consumable",
			"cost": 50,
			"description": "Grants advantage on saving throws against poison for 1 hour",
			"rarity": "common",
			"weight": 0.1
		},
		{
			"name": "Potion of Healing (Greater)",
			"type": "consumable",
			"cost": 150,
			"description": "Restores 4d4+4 hit points",
			"rarity": "uncommon",
			"weight": 0.5
		},
		{
			"name": "Potion of Healing (Superior)",
			"type": "consumable",
			"cost": 450,
			"description": "Restores 8d4+8 hit points",
			"rarity": "rare",
			"weight": 0.5
		},
		{
			"name": "Potion of Healing (Supreme)",
			"type": "consumable",
			"cost": 1350,
			"description": "Restores 10d4+20 hit points",
			"rarity": "very_rare",
			"weight": 0.5
		}
	]

	for consumable_data in consumables:
		var consumable_resource = EquipmentResource.new()
		consumable_resource.item_name = consumable_data.get("name", "")
		consumable_resource.item_type = consumable_data.get("type", "")
		consumable_resource.cost = consumable_data.get("cost", 0)
		consumable_resource.description = consumable_data.get("description", "")
		consumable_resource.rarity = consumable_data.get("rarity", "")
		consumable_resource.weight = consumable_data.get("weight", 0.0)
		store_inventory[consumable_resource.item_name] = consumable_resource

# Bank accounts for characters
var bank_accounts: Dictionary = {} # character_name -> balance

func _init():
    setup_general_store()

func setup_general_store():
    """Initialize the general store system"""
    print("General Store initialized with " + str(store_inventory.size()) + " items")

func get_store_inventory() -> Dictionary:
    """Get the store's current inventory"""
    return store_inventory.duplicate()

func get_character_bank_balance(character: Character) -> float:
    """Get character's bank balance"""
    return bank_accounts.get(character.name, 0.0)

func deposit_to_bank(character: Character, amount: float) -> bool:
    """Deposit gold to character's bank account"""
    if character.gold >= amount:
        character.gold -= amount
        bank_accounts[character.name] = bank_accounts.get(character.name, 0.0) + amount
        bank_deposit.emit(character, amount)
        print(character.name + " deposited " + str(amount) + " gp to bank")
        return true
    return false

func withdraw_from_bank(character: Character, amount: float) -> bool:
    """Withdraw gold from character's bank account"""
    var current_balance = bank_accounts.get(character.name, 0.0)
    if current_balance >= amount:
        bank_accounts[character.name] = current_balance - amount
        character.gold += amount
        bank_withdrawal.emit(character, amount)
        print(character.name + " withdrew " + str(amount) + " gp from bank")
        return true
    return false

func purchase_item(character: Character, item_id: String, quantity: int = 1) -> bool:
    """Purchase an item from the store"""
    if not store_inventory.has(item_id):
        print("Item not available: " + item_id)
        return false

    var item = store_inventory[item_id]
    var total_cost = item["cost"] * quantity

    if character.gold >= total_cost:
        character.gold -= total_cost

        # Add item to character's inventory (this would be implemented with inventory system)
        # For now, just track the purchase
        item_purchased.emit(character, item, total_cost)
        print(character.name + " purchased " + str(quantity) + "x " + item["name"] + " for " + str(total_cost) + " gp")
        return true
    else:
        print(character.name + " cannot afford " + item["name"])
        return false

func sell_item(character: Character, item: Dictionary, quantity: int = 1) -> bool:
    """Sell an item to the store"""
    var base_value = get_item_sell_value(item)
    var total_value = base_value * quantity

    # Add gold to character
    character.gold += total_value

    # Remove item from character's inventory (this would be implemented with inventory system)
    item_sold.emit(character, item, total_value)
    print(character.name + " sold " + str(quantity) + "x " + item.get("name", "Unknown Item") + " for " + str(total_value) + " gp")
    return true

func get_item_sell_value(item: Dictionary) -> float:
    """Get the sell value of an item (typically 50% of purchase price)"""
    var base_cost = item.get("cost", 0)
    var rarity = item.get("rarity", "common")

    # Adjust sell value based on rarity
    var sell_multiplier = 0.5 # Base 50% of purchase price

    match rarity:
        "common":
            sell_multiplier = 0.5
        "uncommon":
            sell_multiplier = 0.4
        "rare":
            sell_multiplier = 0.3
        "very_rare":
            sell_multiplier = 0.2
        "legendary":
            sell_multiplier = 0.1

    return base_cost * sell_multiplier

func get_character_wealth(character: Character) -> Dictionary:
    """Get character's total wealth breakdown"""
    var bank_balance = get_character_bank_balance(character)
    var pocket_gold = character.gold

    return {
        "pocket_gold": pocket_gold,
        "bank_balance": bank_balance,
        "total_wealth": pocket_gold + bank_balance
    }

func get_wealth_tier(character: Character) -> String:
    """Get character's wealth tier based on total wealth"""
    var wealth = get_character_wealth(character)
    var total = wealth["total_wealth"]

    if total < 100:
        return "Poor"
    elif total < 1000:
        return "Modest"
    elif total < 5000:
        return "Comfortable"
    elif total < 25000:
        return "Wealthy"
    elif total < 100000:
        return "Very Wealthy"
    else:
        return "Extremely Wealthy"

func get_store_recommendations(character: Character) -> Array[String]:
    """Get recommended items for character based on their class and level"""
    var recommendations = []
    var character_class = character.character_class.to_lower()
    var level = character.level

    # Basic recommendations for all characters
    recommendations.append("healing_potion")
    recommendations.append("rations")
    recommendations.append("waterskin")
    recommendations.append("backpack")
    recommendations.append("bedroll")

    # Class-specific recommendations
    match character_class:
        "rogue":
            recommendations.append("lock_picks")
            recommendations.append("disguise_kit")
        "wizard", "sorcerer", "warlock":
            recommendations.append("spellbook")
            recommendations.append("component_pouch")
        "cleric", "paladin":
            recommendations.append("healers_kit")
        "ranger", "druid":
            recommendations.append("rope_hempen")
            recommendations.append("lantern_hooded")

    # Level-based recommendations
    if level >= 5:
        recommendations.append("potion_of_healing_greater")
    if level >= 10:
        recommendations.append("potion_of_healing_superior")
    if level >= 15:
        recommendations.append("potion_of_healing_supreme")

    return recommendations

func search_items(query: String) -> Dictionary:
    """Search for items by name or description"""
    var results = {}
    query = query.to_lower()

    for item_id in store_inventory.keys():
        var item = store_inventory[item_id]
        var name = item.get("name", "").to_lower()
        var description = item.get("description", "").to_lower()

        if name.find(query) != -1 or description.find(query) != -1:
            results[item_id] = item

    return results

func get_items_by_type(item_type: String) -> Dictionary:
    """Get all items of a specific type"""
    var results = {}

    for item_id in store_inventory.keys():
        var item = store_inventory[item_id]
        if item.get("type", "") == item_type:
            results[item_id] = item

    return results

func get_items_by_rarity(rarity: String) -> Dictionary:
    """Get all items of a specific rarity"""
    var results = {}

    for item_id in store_inventory.keys():
        var item = store_inventory[item_id]
        if item.get("rarity", "") == rarity:
            results[item_id] = item

    return results
