extends Control

var character: Character
var selected_item_index = -1

func _ready():
	# Get current character from the singleton
	character = CharacterManager.get_current_character()

	if character == null:
		print("Error: No character found")
		return

	update_ui()

func update_ui():
	if character == null:
		return

	# Update equipped items
	update_equipped_items()

	# Update inventory
	update_inventory()

func update_equipped_items():
	# Update equipment slots
	%HeadItem.text = character.equipment.get("head", "None")
	%ChestItem.text = character.equipment.get("chest", "None")
	%HandsItem.text = character.equipment.get("hands", "None")
	%FeetItem.text = character.equipment.get("feet", "None")
	%MainHandItem.text = character.equipment.get("main_hand", "None")
	%OffHandItem.text = character.equipment.get("off_hand", "None")

func update_inventory():
	%InventoryList.clear()

	# Add some sample items for now
	%InventoryList.add_item("Leather Armor")
	%InventoryList.add_item("Longsword")
	%InventoryList.add_item("Shield")
	%InventoryList.add_item("Healing Potion")
	%InventoryList.add_item("Rope (50 ft)")

func _on_inventory_item_selected(index: int):
	selected_item_index = index
	var item_name = %InventoryList.get_item_text(index)

	# Update item details
	%ItemName.text = item_name
	%ItemDescription.text = get_item_description(item_name)

	# Enable/disable action buttons
	%EquipButton.disabled = false
	%UnequipButton.disabled = true

func get_item_description(item_name: String) -> String:
	# Return item descriptions based on name
	match item_name:
		"Leather Armor":
			return "Light armor that provides protection without restricting movement.\nAC: 11 + Dex modifier"
		"Longsword":
			return "A versatile melee weapon that can be used one-handed or two-handed.\nDamage: 1d8 slashing"
		"Shield":
			return "A defensive item that can be used to block attacks.\nAC: +2"
		"Healing Potion":
			return "A magical potion that restores hit points when consumed.\nHeals: 2d4 + 2 HP"
		"Rope (50 ft)":
			return "A length of sturdy rope useful for climbing, binding, or other tasks.\nLength: 50 feet"
		_:
			return "A mysterious item with unknown properties."

func _on_equip_button_pressed():
	if selected_item_index < 0:
		return

	var item_name = %InventoryList.get_item_text(selected_item_index)
	equip_item(item_name)

func _on_unequip_button_pressed():
	if selected_item_index < 0:
		return

	var item_name = %InventoryList.get_item_text(selected_item_index)
	unequip_item(item_name)

func equip_item(item_name: String):
	# Determine equipment slot based on item type
	var slot = get_item_slot(item_name)
	if slot == "":
		print("Cannot determine equipment slot for: " + item_name)
		return

	# Equip the item
	character.equipment[slot] = item_name
	update_equipped_items()

	print("Equipped " + item_name + " in " + slot + " slot")

func unequip_item(item_name: String):
	# Find which slot the item is in
	for slot in character.equipment.keys():
		if character.equipment[slot] == item_name:
			character.equipment[slot] = "None"
			update_equipped_items()
			print("Unequipped " + item_name + " from " + slot + " slot")
			return

	print("Item not found in equipment: " + item_name)

func get_item_slot(item_name: String) -> String:
	# Determine equipment slot based on item name
	if "armor" in item_name.to_lower():
		return "chest"
	elif "sword" in item_name.to_lower() or "axe" in item_name.to_lower():
		return "main_hand"
	elif "shield" in item_name.to_lower():
		return "off_hand"
	elif "helmet" in item_name.to_lower() or "hat" in item_name.to_lower():
		return "head"
	elif "gloves" in item_name.to_lower():
		return "hands"
	elif "boots" in item_name.to_lower() or "shoes" in item_name.to_lower():
		return "feet"
	else:
		return ""

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")
