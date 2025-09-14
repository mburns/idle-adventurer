extends Node

# Social events system
# Handles social events, triggering, and rewards

class_name SocialEvents

# NPC data manager reference
var npc_data_manager: NPCDataManager

func _init():
	npc_data_manager = NPCDataManager.new()

# Trigger a social event
func trigger_social_event(event_id: String, character: Character) -> bool:
	"""Trigger a social event for a character"""
	var event = npc_data_manager.get_social_event(event_id)
	if event == null:
		print("Social event not found: " + event_id)
		return false

	# Check if character meets event requirements
	if not meets_event_requirements(character, event):
		print("Character does not meet social event requirements")
		return false

	# Give event rewards
	give_social_event_rewards(character, event.rewards)

	print("Triggered social event: " + event.name)
	return true

# Check if character meets event requirements
func meets_event_requirements(character: Character, event: SocialEvent) -> bool:
	"""Check if character meets social event requirements"""
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

	# Check relationship requirements
	if requirements.has("relationships"):
		var relationship_reqs = requirements["relationships"]
		if relationship_reqs is Dictionary:
			for npc_id in relationship_reqs:
				var required_relationship = relationship_reqs[npc_id]
				# This would check character's relationship with the NPC
				# For now, just return true
				pass

	return true

# Give social event rewards
func give_social_event_rewards(character: Character, rewards: Dictionary) -> void:
	"""Give all rewards from a social event to a character"""
	for reward_type in rewards:
		var reward_value = rewards[reward_type]
		give_social_reward(character, reward_type, reward_value)

# Give a specific social reward
func give_social_reward(character: Character, reward_type: String, amount: int) -> void:
	"""Give a specific type of social reward to a character"""
	match reward_type:
		"experience":
			give_experience_reward(character, amount)
		"gold":
			give_gold_reward(character, amount)
		"reputation":
			give_reputation_reward(character, amount)
		"relationships":
			give_relationship_reward(character, amount)
		"information":
			give_information_reward(character, amount)
		"access":
			give_access_reward(character, amount)
		"social_status":
			give_social_status_reward(character, amount)
		_:
			print("Unknown social reward type: " + reward_type)

# Give experience reward
func give_experience_reward(character: Character, amount: int) -> void:
	"""Give experience points to character"""
	character.experience += amount
	print("Gained " + str(amount) + " experience from social event")

# Give gold reward
func give_gold_reward(character: Character, amount: int) -> void:
	"""Give gold to character"""
	character.gold += amount
	print("Gained " + str(amount) + " gold from social event")

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
	print("Gained " + str(amount) + " " + faction + " reputation from social event")

# Give relationship reward
func give_relationship_reward(character: Character, amount) -> void:
	"""Give relationship rewards to character"""
	if amount is Dictionary:
		for npc_id in amount:
			var relationship_amount = amount[npc_id]
			give_npc_relationship(character, npc_id, relationship_amount)
	elif amount is int:
		# Default relationship boost
		print("Gained general relationship boost from social event")
	else:
		print("Invalid relationship reward data")

# Give NPC relationship
func give_npc_relationship(character: Character, npc_id: String, amount: int) -> void:
	"""Give relationship boost with a specific NPC"""
	var npc = npc_data_manager.get_npc(npc_id)
	if npc:
		# This would update the character's relationship with the NPC
		# For now, just print a message
		print("Gained " + str(amount) + " relationship with " + npc.name + " from social event")

# Give information reward
func give_information_reward(character: Character, amount: int) -> void:
	"""Give information rewards to character"""
	# This would unlock quests, locations, or other information
	print("Received valuable information from social event")

# Give access reward
func give_access_reward(character: Character, amount: int) -> void:
	"""Give access rewards to character"""
	# This would unlock new locations or services
	print("Gained access to new areas from social event")

# Give social status reward
func give_social_status_reward(character: Character, amount: int) -> void:
	"""Give social status rewards to character"""
	# This would improve character's social standing
	print("Improved social status from social event")

# Get available social events for character
func get_available_social_events(character: Character) -> Array[SocialEvent]:
	"""Get social events available to a character"""
	var available_events: Array[SocialEvent] = []
	var all_events = npc_data_manager.get_all_social_events()

	for event in all_events.values():
		if meets_event_requirements(character, event):
			available_events.append(event)

	return available_events

# Get social events by type for character
func get_social_events_by_type(character: Character, event_type: SocialEventType) -> Array[SocialEvent]:
	"""Get social events of a specific type available to a character"""
	var available_events: Array[SocialEvent] = []
	var events_by_type = npc_data_manager.get_social_events_by_type(event_type)

	for event in events_by_type:
		if meets_event_requirements(character, event):
			available_events.append(event)

	return available_events

# Get social events by location for character
func get_social_events_by_location(character: Character, location: String) -> Array[SocialEvent]:
	"""Get social events at a specific location available to a character"""
	var available_events: Array[SocialEvent] = []
	var events_by_location = npc_data_manager.get_social_events_by_location(location)

	for event in events_by_location:
		if meets_event_requirements(character, event):
			available_events.append(event)

	return available_events

# Get social event description
func get_social_event_description(event_id: String) -> String:
	"""Get description of a social event"""
	var event = npc_data_manager.get_social_event(event_id)
	if event:
		return event.description
	return "Social event not found"

# Get social event requirements text
func get_social_event_requirements_text(event_id: String) -> String:
	"""Get human-readable requirements text for a social event"""
	var event = npc_data_manager.get_social_event(event_id)
	if not event:
		return "Social event not found"

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

	if requirements.has("relationships"):
		var relationships = requirements["relationships"]
		if relationships is Dictionary:
			for npc_id in relationships:
				requirements_text += str(relationships[npc_id]) + " relationship with " + npc_id + " required\n"

	return requirements_text

# Get social event rewards text
func get_social_event_rewards_text(event_id: String) -> String:
	"""Get human-readable rewards text for a social event"""
	var event = npc_data_manager.get_social_event(event_id)
	if not event:
		return "Social event not found"

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
			"relationships":
				if reward_value is Dictionary:
					for npc_id in reward_value:
						rewards_text += "Gains " + str(reward_value[npc_id]) + " relationship with " + npc_id + "\n"
				else:
					rewards_text += "Gains relationship boost\n"
			"information":
				rewards_text += "Gains valuable information\n"
			"access":
				rewards_text += "Gains access to new areas\n"
			"social_status":
				rewards_text += "Improves social status\n"
			_:
				rewards_text += reward_type + ": " + str(reward_value) + "\n"

	return rewards_text

# Get NPC data manager
func get_npc_data_manager() -> NPCDataManager:
	"""Get the NPC data manager instance"""
	return npc_data_manager
