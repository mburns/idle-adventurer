extends Node

# Inventory system for managing character items with stacking

class_name InventorySystem

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

# Item types that can stack
var stackable_types = [
    "consumable",
    "ammunition",
    "spell_component",
    "treasure",
    "food",
    "potion",
    "scroll"
]

# Item types that don't stack (unique items)
var unique_types = [
    "weapon",
    "armor",
    "tool",
    "adventuring_gear",
    "magic_item",
    "equipment"
]

var character_inventories: Dictionary = {} # character_name -> inventory_data

func _init():
    setup_inventory_system()

func setup_inventory_system():
    """Initialize the inventory system"""
    print("Inventory System initialized")

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

func apply_item_effects(character: Character, item: Dictionary, quantity: int):
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

func apply_consumable_effects(character: Character, item: Dictionary, quantity: int):
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

func apply_food_effects(character: Character, item: Dictionary, quantity: int):
    """Apply effects of food items"""
    var item_name = item.get("name", "").to_lower()

    if "rations" in item_name:
        # Rations provide sustenance (tracked separately)
        print(character.name + " ate " + str(quantity) + " days of rations")

func apply_scroll_effects(character: Character, item: Dictionary, quantity: int):
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

func clear_inventory(character: Character):
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
