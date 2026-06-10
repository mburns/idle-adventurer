extends Resource

class_name ItemResource

@export var item_name: String = ""
@export var description: String = ""
@export var item_type: String = ""  # weapon, armor, tool, consumable, etc.
@export var rarity: String = "common"  # common, uncommon, rare, very_rare, legendary
@export var cost: int = 0  # Cost in gold pieces
@export var weight: float = 0.0  # Weight in pounds
@export var is_magical: bool = false
@export var is_consumable: bool = false
@export var stack_size: int = 1  # How many can stack together
@export var equipment_slot: String = ""  # head, chest, legs, feet, hands, weapon, shield, etc.
@export var armor_class_bonus: int = 0  # For armor items
@export var damage_dice: String = ""  # For weapons (e.g., "1d8")
@export var damage_type: String = ""  # For weapons (e.g., "slashing", "piercing", "bludgeoning")
@export var weapon_type: String = ""  # For weapons (e.g., "melee", "ranged", "thrown")
# TODO don't use reserved word for variables.
@export var range: int = 0  # For ranged weapons
@export var properties: Array[String] = []  # Special properties like "finesse", "versatile", etc.
@export var requirements: Dictionary = {}  # Ability score requirements, class restrictions, etc.
@export var effects: Array[String] = []  # Magical effects or special abilities
@export var crafting_materials: Array[String] = []  # Materials needed to craft this item
@export var crafting_difficulty: int = 0  # Difficulty level for crafting
@export var is_tradeable: bool = true  # Can this item be sold/traded
@export var vendor_price: int = 0  # Price when selling to vendors (usually cost/2)

func get_display_name() -> String:
	"""Get the display name for the item"""
	return item_name

func get_full_description() -> String:
	"""Get the full description including stats"""
	var desc = description
	if armor_class_bonus > 0:
		desc += "\nAC Bonus: +" + str(armor_class_bonus)
	if damage_dice != "":
		desc += "\nDamage: " + damage_dice
		if damage_type != "":
			desc += " " + damage_type
	if weight > 0:
		desc += "\nWeight: " + str(weight) + " lbs"
	if cost > 0:
		desc += "\nCost: " + str(cost) + " gp"
	return desc

func can_equip(character) -> bool:
	"""Check if a character can equip this item"""
	# Check ability score requirements
	for ability in requirements.keys():
		if character.get_ability_score(ability) < requirements[ability]:
			return false

	# Check class restrictions
	if "class_restriction" in requirements:
		var allowed_classes = requirements["class_restriction"]
		if not character.character_class in allowed_classes:
			return false

	return true

func get_sell_price() -> int:
	"""Get the price when selling this item"""
	return vendor_price if vendor_price > 0 else cost / 2
