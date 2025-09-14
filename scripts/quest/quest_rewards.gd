extends Node

# Quest rewards system
# Handles distribution of quest rewards including experience, gold, items, and reputation

class_name QuestRewards

# Give quest rewards to a character
func give_quest_rewards(character: Character, rewards: Dictionary) -> void:
	"""Give all quest rewards to a character"""
	for reward_type in rewards:
		var reward_value = rewards[reward_type]
		give_quest_reward(character, reward_type, reward_value)

# Give a specific quest reward
func give_quest_reward(character: Character, reward_type: String, amount: int) -> void:
	"""Give a specific type of quest reward to a character"""
	match reward_type:
		"experience":
			give_experience_reward(character, amount)
		"gold":
			give_gold_reward(character, amount)
		"items":
			give_item_rewards(character, amount)
		"reputation":
			give_reputation_rewards(character, amount)
		"spells":
			give_spell_rewards(character, amount)
		"equipment":
			give_equipment_rewards(character, amount)
		_:
			print("Unknown reward type: " + reward_type)

# Give experience reward
func give_experience_reward(character: Character, amount: int) -> void:
	"""Give experience points to character"""
	character.experience += amount
	print("Gained " + str(amount) + " experience points")

# Give gold reward
func give_gold_reward(character: Character, amount: int) -> void:
	"""Give gold to character"""
	character.gold += amount
	print("Gained " + str(amount) + " gold")

# Give item rewards
func give_item_rewards(character: Character, items_data) -> void:
	"""Give items to character"""
	if items_data is Array:
		for item_data in items_data:
			give_single_item_reward(character, item_data)
	elif items_data is Dictionary:
		give_single_item_reward(character, items_data)
	else:
		print("Invalid item reward data type")

# Give a single item reward
func give_single_item_reward(character: Character, item_data) -> void:
	"""Give a single item to character"""
	if item_data is String:
		# Simple item name
		var item_dict = {"name": item_data, "type": "misc", "weight": 1.0, "value": 1.0}
		add_item_to_character(character, item_dict)
	elif item_data is Dictionary:
		# Detailed item data
		add_item_to_character(character, item_data)
	else:
		print("Invalid item data format")

# Give reputation rewards
func give_reputation_rewards(character: Character, reputation_data) -> void:
	"""Give reputation rewards to character"""
	if reputation_data is Dictionary:
		for faction in reputation_data:
			var reputation_amount = reputation_data[faction]
			give_faction_reputation(character, faction, reputation_amount)
	elif reputation_data is int:
		# Default faction reputation
		give_faction_reputation(character, "general", reputation_data)
	else:
		print("Invalid reputation reward data")

# Give faction reputation
func give_faction_reputation(character: Character, faction: String, amount: int) -> void:
	"""Give reputation with a specific faction"""
	if not character.faction_reputation.has(faction):
		character.faction_reputation[faction] = 0

	character.faction_reputation[faction] += amount
	print("Gained " + str(amount) + " " + faction + " reputation")

# Give spell rewards
func give_spell_rewards(character: Character, spells_data) -> void:
	"""Give spells to character"""
	if spells_data is Array:
		for spell_name in spells_data:
			give_spell_to_character(character, spell_name)
	elif spells_data is String:
		give_spell_to_character(character, spells_data)
	else:
		print("Invalid spell reward data")

# Give a spell to character
func give_spell_to_character(character: Character, spell_name: String) -> void:
	"""Give a spell to character's spellbook"""
	if not character.spellbook.has(spell_name):
		character.spellbook[spell_name] = {
			"level": 1,
			"prepared": false,
			"uses": 0
		}
		print("Learned spell: " + spell_name)

# Give equipment rewards
func give_equipment_rewards(character: Character, equipment_data) -> void:
	"""Give equipment to character"""
	if equipment_data is Array:
		for equipment_item in equipment_data:
			give_equipment_to_character(character, equipment_item)
	elif equipment_data is Dictionary:
		give_equipment_to_character(character, equipment_data)
	else:
		print("Invalid equipment reward data")

# Give equipment to character
func give_equipment_to_character(character: Character, equipment_item) -> void:
	"""Give equipment to character"""
	if equipment_item is String:
		# Simple equipment name
		var equipment_dict = {
			"name": equipment_item,
			"type": "equipment",
			"weight": 1.0,
			"value": 10.0
		}
		add_item_to_character(character, equipment_dict)
	elif equipment_item is Dictionary:
		# Detailed equipment data
		add_item_to_character(character, equipment_item)
	else:
		print("Invalid equipment data format")

# Add item to character's inventory
func add_item_to_character(character: Character, item_data: Dictionary) -> void:
	"""Add item to character's inventory"""
	var inventory_system = get_inventory_system()
	if inventory_system:
		inventory_system.add_item(character, item_data, 1)
		print("Received item: " + item_data.get("name", "Unknown Item"))
	else:
		print("Warning: Could not access inventory system")

# Get inventory system instance
func get_inventory_system() -> InventorySystem:
	"""Get the inventory system instance"""
	# Try to access AutoloadManager, fallback to new instance if not available
	var autoload_manager = null
	if Engine.has_singleton("AutoloadManager"):
		autoload_manager = Engine.get_singleton("AutoloadManager")

	if autoload_manager and autoload_manager.inventory_system:
		return autoload_manager.inventory_system
	return InventorySystem.new()

# Calculate reward value
func calculate_reward_value(rewards: Dictionary) -> int:
	"""Calculate total value of rewards"""
	var total_value = 0

	for reward_type in rewards:
		var reward_value = rewards[reward_type]
		match reward_type:
			"gold":
				total_value += reward_value
			"experience":
				total_value += reward_value / 10  # Experience worth less than gold
			"items":
				if reward_value is Array:
					total_value += reward_value.size() * 5  # Estimate item value
				else:
					total_value += 5
			"reputation":
				if reward_value is Dictionary:
					for faction in reward_value:
						total_value += reward_value[faction] * 2
				else:
					total_value += reward_value * 2
			_:
				total_value += 1  # Unknown reward types

	return total_value

# Validate reward data
func validate_reward_data(rewards: Dictionary) -> bool:
	"""Validate quest reward data structure"""
	for reward_type in rewards:
		var reward_value = rewards[reward_type]

		match reward_type:
			"experience", "gold":
				if not reward_value is int or reward_value < 0:
					print("Invalid " + reward_type + " reward: " + str(reward_value))
					return false
			"items", "spells":
				if not (reward_value is Array or reward_value is String):
					print("Invalid " + reward_type + " reward: " + str(reward_value))
					return false
			"reputation":
				if not (reward_value is Dictionary or reward_value is int):
					print("Invalid reputation reward: " + str(reward_value))
					return false
			_:
				print("Unknown reward type: " + reward_type)
				return false

	return true

# Get reward description
func get_reward_description(rewards: Dictionary) -> String:
	"""Get human-readable description of rewards"""
	var description = "Rewards: "
	var reward_parts: Array[String] = []

	for reward_type in rewards:
		var reward_value = rewards[reward_type]
		match reward_type:
			"experience":
				reward_parts.append(str(reward_value) + " XP")
			"gold":
				reward_parts.append(str(reward_value) + " gold")
			"items":
				if reward_value is Array:
					reward_parts.append(str(reward_value.size()) + " items")
				else:
					reward_parts.append("1 item")
			"reputation":
				if reward_value is Dictionary:
					for faction in reward_value:
						reward_parts.append(str(reward_value[faction]) + " " + faction + " reputation")
				else:
					reward_parts.append(str(reward_value) + " reputation")
			"spells":
				if reward_value is Array:
					reward_parts.append(str(reward_value.size()) + " spells")
				else:
					reward_parts.append("1 spell")
			_:
				reward_parts.append(reward_type + ": " + str(reward_value))

	if reward_parts.is_empty():
		return "No rewards"

	return description + ", ".join(reward_parts)
