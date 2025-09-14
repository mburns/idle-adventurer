extends Node

# Town events system
# Handles town events, triggering, and rewards

class_name TownEvents

# Town data manager reference
var town_data_manager: TownDataManager

func _init():
	town_data_manager = TownDataManager.new()

# Trigger a town event
func trigger_town_event(event_id: String, character: Character) -> bool:
	"""Trigger a town event for a character"""
	var event = town_data_manager.get_event(event_id)
	if event == null:
		print("Event not found: " + event_id)
		return false

	# Check if character meets event requirements
	if not meets_event_requirements(character, event):
		print("Character does not meet event requirements")
		return false

	# Give event rewards
	give_town_event_rewards(character, event.rewards)

	print("Triggered town event: " + event.name)
	return true

# Check if character meets event requirements
func meets_event_requirements(character: Character, event: TownEvent) -> bool:
	"""Check if character meets event requirements"""
	var requirements = event.requirements

	# Check level requirement
	if requirements.has("level"):
		if character.level < requirements["level"]:
			return false

	# Check gold requirement
	if requirements.has("gold"):
		if character.gold < requirements["gold"]:
			return false

	# Check item requirements
	if requirements.has("items"):
		var required_items = requirements["items"]
		if required_items is Array:
			for item in required_items:
				# This would check if character has the item
				# For now, just return true
				pass

	# Check skill requirements
	if requirements.has("skills"):
		var required_skills = requirements["skills"]
		if required_skills is Array:
			for skill in required_skills:
				if skill not in character.skill_proficiencies:
					return false

	# Check reputation requirements
	if requirements.has("reputation"):
		var reputation_reqs = requirements["reputation"]
		if reputation_reqs is Dictionary:
			for faction in reputation_reqs:
				var required_rep = reputation_reqs[faction]
				var current_rep = character.faction_reputation.get(faction, 0)
				if current_rep < required_rep:
					return false

	# Check location requirement
	if requirements.has("location"):
		var required_location = requirements["location"]
		# This would check if character is at the required location
		# For now, just return true
		pass

	return true

# Give town event rewards
func give_town_event_rewards(character: Character, rewards: Dictionary) -> void:
	"""Give all rewards from a town event to a character"""
	for reward_type in rewards:
		var reward_value = rewards[reward_type]
		give_town_event_reward(character, reward_type, reward_value)

# Give a specific town event reward
func give_town_event_reward(character: Character, reward_type: String, amount: int) -> void:
	"""Give a specific type of town event reward to a character"""
	match reward_type:
		"experience":
			give_experience_reward(character, amount)
		"gold":
			give_gold_reward(character, amount)
		"reputation":
			give_reputation_reward(character, amount)
		"items":
			give_item_reward(character, amount)
		"information":
			give_information_reward(character, amount)
		"access":
			give_access_reward(character, amount)
		"discount":
			give_discount_reward(character, amount)
		_:
			print("Unknown town event reward type: " + reward_type)

# Give experience reward
func give_experience_reward(character: Character, amount: int) -> void:
	"""Give experience points to character"""
	character.experience += amount
	print("Gained " + str(amount) + " experience from town event")

# Give gold reward
func give_gold_reward(character: Character, amount: int) -> void:
	"""Give gold to character"""
	character.gold += amount
	print("Gained " + str(amount) + " gold from town event")

# Give reputation reward
func give_reputation_reward(character: Character, amount) -> void:
	"""Give reputation rewards to character"""
	if amount is Dictionary:
		for faction in amount:
			var reputation_amount = amount[faction]
			give_faction_reputation(character, faction, reputation_amount)
	elif amount is int:
		# Default faction reputation
		give_faction_reputation(character, "general", amount)
	else:
		print("Invalid reputation reward data")

# Give faction reputation
func give_faction_reputation(character: Character, faction: String, amount: int) -> void:
	"""Give reputation with a specific faction"""
	if not character.faction_reputation.has(faction):
		character.faction_reputation[faction] = 0

	character.faction_reputation[faction] += amount
	print("Gained " + str(amount) + " " + faction + " reputation from town event")

# Give item reward
func give_item_reward(character: Character, amount) -> void:
	"""Give items to character"""
	if amount is Array:
		for item_data in amount:
			give_single_item_reward(character, item_data)
	elif amount is Dictionary:
		give_single_item_reward(character, amount)
	else:
		print("Invalid item reward data")

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

# Give information reward
func give_information_reward(character: Character, amount: int) -> void:
	"""Give information rewards to character"""
	# This would unlock quests, locations, or other information
	print("Received valuable information from town event")

# Give access reward
func give_access_reward(character: Character, amount: int) -> void:
	"""Give access rewards to character"""
	# This would unlock new locations or services
	print("Gained access to new areas from town event")

# Give discount reward
func give_discount_reward(character: Character, amount: int) -> void:
	"""Give discount rewards to character"""
	# This would provide discounts on services
	print("Received discount on town services from town event")

# Add item to character's inventory
func add_item_to_character(character: Character, item_data: Dictionary) -> void:
	"""Add item to character's inventory"""
	var inventory_system = get_inventory_system()
	if inventory_system:
		inventory_system.add_item(character, item_data, 1)
		print("Received item from town event: " + item_data.get("name", "Unknown Item"))
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

# Get available events for character
func get_available_events(character: Character) -> Array[TownEvent]:
	"""Get events available to a character"""
	var available_events: Array[TownEvent] = []
	var all_events = town_data_manager.get_all_events()

	for event in all_events.values():
		if meets_event_requirements(character, event):
			available_events.append(event)

	return available_events

# Get events by type
func get_events_by_type(character: Character, event_type: TownEventType) -> Array[TownEvent]:
	"""Get events of a specific type available to a character"""
	var available_events: Array[TownEvent] = []
	var all_events = town_data_manager.get_all_events()

	for event in all_events.values():
		if event.event_type == event_type and meets_event_requirements(character, event):
			available_events.append(event)

	return available_events

# Get events for location
func get_events_for_location(character: Character, location_id: String) -> Array[TownEvent]:
	"""Get events available at a specific location"""
	var location_events: Array[TownEvent] = []
	var all_events = town_data_manager.get_all_events()

	for event in all_events.values():
		if event.location_id == location_id and meets_event_requirements(character, event):
			location_events.append(event)

	return location_events

# Get event description
func get_event_description(event_id: String) -> String:
	"""Get description of an event"""
	var event = town_data_manager.get_event(event_id)
	if event:
		return event.description
	return "Event not found"

# Get event requirements text
func get_event_requirements_text(event_id: String) -> String:
	"""Get human-readable requirements text for an event"""
	var event = town_data_manager.get_event(event_id)
	if not event:
		return "Event not found"

	var requirements = event.requirements
	var requirements_text = ""

	if requirements.has("level"):
		requirements_text += "Level " + str(requirements["level"]) + " required\n"

	if requirements.has("gold"):
		requirements_text += str(requirements["gold"]) + " gold required\n"

	if requirements.has("skills"):
		var skills = requirements["skills"]
		if skills is Array:
			requirements_text += "Skills required: " + ", ".join(skills) + "\n"

	if requirements.has("reputation"):
		var reputation = requirements["reputation"]
		if reputation is Dictionary:
			for faction in reputation:
				requirements_text += str(reputation[faction]) + " " + faction + " reputation required\n"

	if requirements.has("location"):
		requirements_text += "Must be at " + str(requirements["location"]) + "\n"

	return requirements_text

# Get event rewards text
func get_event_rewards_text(event_id: String) -> String:
	"""Get human-readable rewards text for an event"""
	var event = town_data_manager.get_event(event_id)
	if not event:
		return "Event not found"

	var rewards = event.rewards
	var rewards_text = ""

	for reward_type in rewards:
		var reward_value = rewards[reward_type]
		match reward_type:
			"experience":
				rewards_text += "Gains " + str(reward_value) + " experience\n"
			"gold":
				rewards_text += "Gains " + str(reward_value) + " gold\n"
			"reputation":
				if reward_value is Dictionary:
					for faction in reward_value:
						rewards_text += "Gains " + str(reward_value[faction]) + " " + faction + " reputation\n"
				else:
					rewards_text += "Gains " + str(reward_value) + " reputation\n"
			"items":
				if reward_value is Array:
					rewards_text += "Gains " + str(reward_value.size()) + " items\n"
				else:
					rewards_text += "Gains 1 item\n"
			"information":
				rewards_text += "Gains valuable information\n"
			"access":
				rewards_text += "Gains access to new areas\n"
			"discount":
				rewards_text += "Gains discount on services\n"
			_:
				rewards_text += reward_type + ": " + str(reward_value) + "\n"

	return rewards_text

# Get town data manager
func get_town_data_manager() -> TownDataManager:
	"""Get the town data manager instance"""
	return town_data_manager
