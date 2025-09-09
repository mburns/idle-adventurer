extends Node

# General Store and Bank system for item management and wealth storage

class_name GeneralStore

signal item_purchased(character: Character, item: Dictionary, cost: float)
signal item_sold(character: Character, item: Dictionary, value: float)
signal bank_deposit(character: Character, amount: float)
signal bank_withdrawal(character: Character, amount: float)

# Store inventory with basic items
var store_inventory = {
    "healing_potion": {
        "name": "Healing Potion",
        "type": "consumable",
        "cost": 50, # 50 gp
        "description": "Restores 2d4+2 hit points",
        "rarity": "common"
    },
    "antitoxin": {
        "name": "Antitoxin",
        "type": "consumable",
        "cost": 50,
        "description": "Grants advantage on saving throws against poison for 1 hour",
        "rarity": "common"
    },
    "potion_of_healing_greater": {
        "name": "Potion of Healing (Greater)",
        "type": "consumable",
        "cost": 150,
        "description": "Restores 4d4+4 hit points",
        "rarity": "uncommon"
    },
    "potion_of_healing_superior": {
        "name": "Potion of Healing (Superior)",
        "type": "consumable",
        "cost": 450,
        "description": "Restores 8d4+8 hit points",
        "rarity": "rare"
    },
    "potion_of_healing_supreme": {
        "name": "Potion of Healing (Supreme)",
        "type": "consumable",
        "cost": 1350,
        "description": "Restores 10d4+20 hit points",
        "rarity": "very_rare"
    },
    "rope_hempen": {
        "name": "Rope, hempen (50 feet)",
        "type": "adventuring_gear",
        "cost": 2,
        "description": "50 feet of strong rope",
        "rarity": "common"
    },
    "rope_silk": {
        "name": "Rope, silk (50 feet)",
        "type": "adventuring_gear",
        "cost": 10,
        "description": "50 feet of silk rope",
        "rarity": "common"
    },
    "lantern_bullseye": {
        "name": "Lantern, bullseye",
        "type": "adventuring_gear",
        "cost": 10,
        "description": "Casts bright light in a 60-foot cone and dim light for an additional 60 feet",
        "rarity": "common"
    },
    "lantern_hooded": {
        "name": "Lantern, hooded",
        "type": "adventuring_gear",
        "cost": 5,
        "description": "Casts bright light in a 30-foot radius and dim light for an additional 30 feet",
        "rarity": "common"
    },
    "lock_picks": {
        "name": "Thieves' Tools",
        "type": "tool",
        "cost": 25,
        "description": "A set of tools for picking locks and disarming traps",
        "rarity": "common"
    },
    "disguise_kit": {
        "name": "Disguise Kit",
        "type": "tool",
        "cost": 25,
        "description": "A kit for creating disguises",
        "rarity": "common"
    },
    "healers_kit": {
        "name": "Healer's Kit",
        "type": "tool",
        "cost": 5,
        "description": "A kit for stabilizing dying creatures",
        "rarity": "common"
    },
    "spellbook": {
        "name": "Spellbook",
        "type": "tool",
        "cost": 50,
        "description": "A book for recording spells",
        "rarity": "common"
    },
    "component_pouch": {
        "name": "Component Pouch",
        "type": "tool",
        "cost": 25,
        "description": "A pouch for spell components",
        "rarity": "common"
    },
    "backpack": {
        "name": "Backpack",
        "type": "adventuring_gear",
        "cost": 2,
        "description": "A backpack for carrying equipment",
        "rarity": "common"
    },
    "bedroll": {
        "name": "Bedroll",
        "type": "adventuring_gear",
        "cost": 1,
        "description": "A bedroll for sleeping",
        "rarity": "common"
    },
    "rations": {
        "name": "Rations (1 day)",
        "type": "consumable",
        "cost": 0.5,
        "description": "One day's worth of food",
        "rarity": "common"
    },
    "waterskin": {
        "name": "Waterskin",
        "type": "adventuring_gear",
        "cost": 2,
        "description": "A container for water",
        "rarity": "common"
    }
}

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
