extends Node

# NPC interactions system
# Handles NPC interactions, relationship management, and dialogue processing

class_name NPCInteractions

# NPC data manager reference
var npc_data_manager: NPCDataManager

# Character relationship data storage
var character_relationships: Dictionary = {} # character_name -> {npc_id -> relationship_value}

func _init():
	npc_data_manager = NPCDataManager.new()

# Interact with an NPC
func interact_with_npc(character: Character, npc_id: String, interaction_type: String) -> Dictionary:
	"""Interact with an NPC and return results"""
	var npc = npc_data_manager.get_npc(npc_id)
	if npc == null:
		return {"success": false, "message": "NPC not found"}

	# Check if character meets NPC requirements
	if not meets_npc_requirements(character, npc):
		return {"success": false, "message": "Requirements not met"}

	# Get current relationship
	var relationship = get_relationship(character, npc)

	# Process the interaction
	var result = process_interaction(character, npc, interaction_type, relationship)

	# Update relationship based on interaction
	if result["success"]:
		var relationship_change = result.get("relationship_change", 0)
		if relationship_change != 0:
			update_relationship(character, npc, relationship_change)

	return result

# Process an interaction
func process_interaction(character: Character, npc: NPCResource, interaction_type: String, relationship: int) -> Dictionary:
	"""Process a specific type of interaction"""
	match interaction_type:
		InteractionType.GREETING:
			return process_greeting(character, npc, relationship)
		InteractionType.SMALL_TALK:
			return process_small_talk(character, npc, relationship)
		InteractionType.DEEP_CONVERSATION:
			return process_deep_conversation(character, npc, relationship)
		InteractionType.BUSINESS:
			return process_business(character, npc, relationship)
		InteractionType.TRAINING:
			return process_training(character, npc, relationship)
		InteractionType.QUEST_GIVING:
			return process_quest_giving(character, npc, relationship)
		InteractionType.ROMANCE:
			return process_romance(character, npc, relationship)
		InteractionType.CONFLICT:
			return process_conflict(character, npc, relationship)
		InteractionType.HELP_REQUEST:
			return process_help_request(character, npc, relationship)
		InteractionType.GOSSIP:
			return process_gossip(character, npc, relationship)
		_:
			return {"success": false, "message": "Unknown interaction type"}

# Process greeting interaction
func process_greeting(_character: Character, npc: NPCResource, relationship: int) -> Dictionary:
	"""Process a greeting interaction"""
	var relationship_level = get_relationship_level(relationship)
	var response = npc.get_dialogue_for_relationship(relationship_level, "greeting")

	return {
		"success": true,
		"message": response,
		"relationship_change": 1,
		"interaction_type": "greeting"
	}

# Process small talk interaction
func process_small_talk(_character: Character, npc: NPCResource, relationship: int) -> Dictionary:
	"""Process a small talk interaction"""
	var relationship_level = get_relationship_level(relationship)
	var response = npc.get_dialogue_for_relationship(relationship_level, "small_talk")

	return {
		"success": true,
		"message": response,
		"relationship_change": 2,
		"interaction_type": "small_talk"
	}

# Process deep conversation interaction
func process_deep_conversation(character: Character, npc: NPCResource, relationship: int) -> Dictionary:
	"""Process a deep conversation interaction"""
	var relationship_level = get_relationship_level(relationship)
	var response = npc.get_dialogue_for_relationship(relationship_level, "deep_conversation")

	return {
		"success": true,
		"message": response,
		"relationship_change": 5,
		"interaction_type": "deep_conversation"
	}

# Process business interaction
func process_business(character: Character, npc: NPCResource, relationship: int) -> Dictionary:
	"""Process a business interaction"""
	var relationship_level = get_relationship_level(relationship)
	var response = npc.get_dialogue_for_relationship(relationship_level, "business")

	return {
		"success": true,
		"message": response,
		"relationship_change": 1,
		"interaction_type": "business"
	}

# Process training interaction
func process_training(character: Character, npc: NPCResource, relationship: int) -> Dictionary:
	"""Process a training interaction"""
	var relationship_level = get_relationship_level(relationship)
	var response = npc.get_dialogue_for_relationship(relationship_level, "training")

	return {
		"success": true,
		"message": response,
		"relationship_change": 3,
		"interaction_type": "training"
	}

# Process quest giving interaction
func process_quest_giving(character: Character, npc: NPCResource, relationship: int) -> Dictionary:
	"""Process a quest giving interaction"""
	var relationship_level = get_relationship_level(relationship)
	var response = npc.get_dialogue_for_relationship(relationship_level, "quest_giving")

	return {
		"success": true,
		"message": response,
		"relationship_change": 2,
		"interaction_type": "quest_giving"
	}

# Process romance interaction
func process_romance(character: Character, npc: NPCResource, relationship: int) -> Dictionary:
	"""Process a romance interaction"""
	var relationship_level = get_relationship_level(relationship)
	var response = npc.get_dialogue_for_relationship(relationship_level, "romance")

	return {
		"success": true,
		"message": response,
		"relationship_change": 1,
		"interaction_type": "romance"
	}

# Process conflict interaction
func process_conflict(character: Character, npc: NPCResource, relationship: int) -> Dictionary:
	"""Process a conflict interaction"""
	var relationship_level = get_relationship_level(relationship)
	var response = npc.get_dialogue_for_relationship(relationship_level, "conflict")

	return {
		"success": true,
		"message": response,
		"relationship_change": -5,
		"interaction_type": "conflict"
	}

# Process help request interaction
func process_help_request(character: Character, npc: NPCResource, relationship: int) -> Dictionary:
	"""Process a help request interaction"""
	var relationship_level = get_relationship_level(relationship)
	var response = npc.get_dialogue_for_relationship(relationship_level, "help_request")

	return {
		"success": true,
		"message": response,
		"relationship_change": 2,
		"interaction_type": "help_request"
	}

# Process gossip interaction
func process_gossip(_character: Character, npc: NPCResource, relationship: int) -> Dictionary:
	"""Process a gossip interaction"""
	var relationship_level = get_relationship_level(relationship)
	var response = npc.get_dialogue_for_relationship(relationship_level, "gossip")

	return {
		"success": true,
		"message": response,
		"relationship_change": 1,
		"interaction_type": "gossip"
	}

# Check if character meets NPC requirements
func meets_npc_requirements(character: Character, npc: NPCResource) -> bool:
	"""Check if character meets NPC requirements"""
	return npc.meets_requirements(character)

# Get relationship between character and NPC
func get_relationship(character: Character, npc: NPCResource) -> int:
	"""Get relationship value between character and NPC"""
	if not character_relationships.has(character.name):
		character_relationships[character.name] = {}

	return character_relationships[character.name].get(npc.npc_id, 0)

# Update relationship between character and NPC
func update_relationship(character: Character, npc: NPCResource, change: int) -> void:
	"""Update relationship between character and NPC"""
	if not character_relationships.has(character.name):
		character_relationships[character.name] = {}

	var current_relationship = character_relationships[character.name].get(npc.npc_id, 0)
	var new_relationship = clamp(current_relationship + change, -100, 100)
	character_relationships[character.name][npc.npc_id] = new_relationship

	print("Relationship with " + npc.name + " changed by " + str(change) + " to " + str(new_relationship))

# Get relationship level from relationship value
func get_relationship_level(relationship: int) -> String:
	"""Get relationship level string from relationship value"""
	if relationship <= -51:
		return "hostile"
	elif relationship <= -21:
		return "unfriendly"
	elif relationship <= 20:
		return "neutral"
	elif relationship <= 50:
		return "friendly"
	elif relationship <= 80:
		return "close_friend"
	else:
		return "best_friend"

# Get available NPCs for character
func get_available_npcs(character: Character) -> Array[NPCResource]:
	"""Get NPCs available to a character"""
	var available_npcs: Array[NPCResource] = []
	var all_npcs = npc_data_manager.get_all_npcs()

	for npc in all_npcs.values():
		if meets_npc_requirements(character, npc):
			available_npcs.append(npc)

	return available_npcs

# Get NPCs by type for character
func get_npcs_by_type(character: Character, npc_type: NPCType.Type) -> Array[NPCResource]:
	"""Get NPCs of a specific type available to a character"""
	var available_npcs: Array[NPCResource] = []
	var npcs_by_type = npc_data_manager.get_npcs_by_type(npc_type)

	for npc in npcs_by_type:
		if meets_npc_requirements(character, npc):
			available_npcs.append(npc)

	return available_npcs

# Get NPCs by location for character
func get_npcs_by_location(character: Character, location: String) -> Array[NPCResource]:
	"""Get NPCs at a specific location available to a character"""
	var available_npcs: Array[NPCResource] = []
	var npcs_by_location = npc_data_manager.get_npcs_by_location(location)

	for npc in npcs_by_location:
		if meets_npc_requirements(character, npc):
			available_npcs.append(npc)

	return available_npcs

# Get relationship text
func get_relationship_text(relationship: int) -> String:
	"""Get human-readable relationship text"""
	if relationship <= -51:
		return "Hostile"
	elif relationship <= -21:
		return "Unfriendly"
	elif relationship <= 20:
		return "Neutral"
	elif relationship <= 50:
		return "Friendly"
	elif relationship <= 80:
		return "Close Friend"
	else:
		return "Best Friend"

# Get NPC data manager
func get_npc_data_manager() -> NPCDataManager:
	"""Get the NPC data manager instance"""
	return npc_data_manager
