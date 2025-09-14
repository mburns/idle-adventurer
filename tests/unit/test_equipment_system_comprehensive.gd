extends GutTest

# Comprehensive test for EquipmentSystem
class_name TestEquipmentSystemComprehensive

var equipment_system: EquipmentSystem
var test_character: Character

func before_each():
	equipment_system = EquipmentSystem.new()
	test_character = Character.new()
	test_character.name = "TestCharacter"

func test_equipment_system_creation():
	"""Test that EquipmentSystem can be created"""
	assert_not_null(equipment_system, "EquipmentSystem should be created")
	assert_true(equipment_system is EquipmentSystem, "Should be an EquipmentSystem instance")

func test_equip_weapon():
	"""Test equipping a weapon"""
	var weapon_data = {
		"name": "Iron Sword",
		"type": "weapon",
		"subtype": "sword",
		"damage": "1d8+2",
		"properties": ["versatile"],
		"weight": 3.0,
		"value": 25
	}

	var result = equipment_system.equip_item(test_character, weapon_data, "main_hand")

	assert_true(result["success"], "Should successfully equip weapon")
	assert_eq(test_character.equipment["main_hand"]["name"], "Iron Sword")
	assert_eq(test_character.equipment["main_hand"]["damage"], "1d8+2")

func test_equip_armor():
	"""Test equipping armor"""
	var armor_data = {
		"name": "Leather Armor",
		"type": "armor",
		"subtype": "light",
		"ac": 11,
		"weight": 10.0,
		"value": 10
	}

	var result = equipment_system.equip_item(test_character, armor_data, "armor")

	assert_true(result["success"], "Should successfully equip armor")
	assert_eq(test_character.equipment["armor"]["name"], "Leather Armor")
	assert_eq(test_character.equipment["armor"]["ac"], 11)

func test_equip_shield():
	"""Test equipping a shield"""
	var shield_data = {
		"name": "Wooden Shield",
		"type": "shield",
		"ac_bonus": 2,
		"weight": 6.0,
		"value": 10
	}

	var result = equipment_system.equip_item(test_character, shield_data, "off_hand")

	assert_true(result["success"], "Should successfully equip shield")
	assert_eq(test_character.equipment["off_hand"]["name"], "Wooden Shield")
	assert_eq(test_character.equipment["off_hand"]["ac_bonus"], 2)

func test_unequip_item():
	"""Test unequipping an item"""
	var weapon_data = {
		"name": "Iron Sword",
		"type": "weapon",
		"damage": "1d8+2"
	}

	# First equip the item
	equipment_system.equip_item(test_character, weapon_data, "main_hand")
	assert_not_null(test_character.equipment["main_hand"], "Item should be equipped")

	# Then unequip it
	var result = equipment_system.unequip_item(test_character, "main_hand")

	assert_true(result["success"], "Should successfully unequip item")
	assert_null(test_character.equipment["main_hand"], "Equipment slot should be empty")

func test_calculate_ac():
	"""Test AC calculation with different equipment combinations"""
	# Base AC (10 + Dex modifier)
	test_character.dexterity = 14  # +2 modifier
	assert_eq(equipment_system.calculate_ac(test_character), 12, "Base AC should be 12")

	# Add armor
	var armor_data = {
		"name": "Leather Armor",
		"type": "armor",
		"ac": 11
	}
	equipment_system.equip_item(test_character, armor_data, "armor")
	assert_eq(equipment_system.calculate_ac(test_character), 11, "AC should be armor AC")

	# Add shield
	var shield_data = {
		"name": "Wooden Shield",
		"type": "shield",
		"ac_bonus": 2
	}
	equipment_system.equip_item(test_character, shield_data, "off_hand")
	assert_eq(equipment_system.calculate_ac(test_character), 13, "AC should include shield bonus")

func test_equipment_conflicts():
	"""Test that incompatible equipment cannot be equipped simultaneously"""
	var sword_data = {
		"name": "Iron Sword",
		"type": "weapon",
		"subtype": "sword",
		"damage": "1d8+2"
	}

	var bow_data = {
		"name": "Shortbow",
		"type": "weapon",
		"subtype": "bow",
		"damage": "1d6"
	}

	# Equip sword first
	var result1 = equipment_system.equip_item(test_character, sword_data, "main_hand")
	assert_true(result1["success"], "Should equip sword")

	# Try to equip bow in same slot
	var result2 = equipment_system.equip_item(test_character, bow_data, "main_hand")
	assert_true(result2["success"], "Should replace sword with bow")
	assert_eq(test_character.equipment["main_hand"]["name"], "Shortbow")

func test_equipment_weight_calculation():
	"""Test total equipment weight calculation"""
	var sword_data = {
		"name": "Iron Sword",
		"type": "weapon",
		"weight": 3.0
	}

	var armor_data = {
		"name": "Chain Mail",
		"type": "armor",
		"weight": 55.0
	}

	var shield_data = {
		"name": "Steel Shield",
		"type": "shield",
		"weight": 6.0
	}

	equipment_system.equip_item(test_character, sword_data, "main_hand")
	equipment_system.equip_item(test_character, armor_data, "armor")
	equipment_system.equip_item(test_character, shield_data, "off_hand")

	var total_weight = equipment_system.calculate_equipment_weight(test_character)
	assert_eq(total_weight, 64.0, "Total weight should be 64.0")

func test_equipment_value_calculation():
	"""Test total equipment value calculation"""
	var sword_data = {
		"name": "Iron Sword",
		"type": "weapon",
		"value": 25
	}

	var armor_data = {
		"name": "Chain Mail",
		"type": "armor",
		"value": 75
	}

	equipment_system.equip_item(test_character, sword_data, "main_hand")
	equipment_system.equip_item(test_character, armor_data, "armor")

	var total_value = equipment_system.calculate_equipment_value(test_character)
	assert_eq(total_value, 100, "Total value should be 100")

func test_equipment_bonuses():
	"""Test equipment stat bonuses"""
	var magic_sword_data = {
		"name": "Magic Sword",
		"type": "weapon",
		"damage": "1d8+2",
		"bonuses": {
			"strength": 2,
			"attack": 1
		}
	}

	equipment_system.equip_item(test_character, magic_sword_data, "main_hand")

	var bonuses = equipment_system.get_equipment_bonuses(test_character)
	assert_eq(bonuses["strength"], 2, "Should have +2 strength bonus")
	assert_eq(bonuses["attack"], 1, "Should have +1 attack bonus")

func test_equipment_requirements():
	"""Test equipment requirement checking"""
	var heavy_armor_data = {
		"name": "Plate Armor",
		"type": "armor",
		"ac": 18,
		"requirements": {
			"strength": 15
		}
	}

	test_character.strength = 12
	var result = equipment_system.equip_item(test_character, heavy_armor_data, "armor")
	assert_false(result["success"], "Should not equip armor without meeting requirements")

	test_character.strength = 16
	result = equipment_system.equip_item(test_character, heavy_armor_data, "armor")
	assert_true(result["success"], "Should equip armor when requirements are met")

func test_equipment_durability():
	"""Test equipment durability system"""
	var fragile_sword_data = {
		"name": "Fragile Sword",
		"type": "weapon",
		"damage": "1d8",
		"durability": 10,
		"max_durability": 10
	}

	equipment_system.equip_item(test_character, fragile_sword_data, "main_hand")

	# Damage the weapon
	equipment_system.damage_equipment(test_character, "main_hand", 5)

	var equipment = test_character.equipment["main_hand"]
	assert_eq(equipment["durability"], 5, "Durability should be reduced")

	# Break the weapon
	equipment_system.damage_equipment(test_character, "main_hand", 10)
	equipment = test_character.equipment["main_hand"]
	assert_eq(equipment["durability"], 0, "Durability should be 0")
	assert_true(equipment.get("broken", false), "Equipment should be marked as broken")
