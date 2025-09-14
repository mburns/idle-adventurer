extends Node

# NPC system core - coordinates NPC data management, interactions, and social events
# Simplified version that delegates to specialized modules

class_name NPCSystem

# Module instances
var npc_data_manager: NPCDataManager
var npc_interactions: NPCInteractions
var social_events: SocialEvents

# Signals
signal relationship_changed(npc: NPCResource, character: Character, new_relationship: int)
signal npc_interaction(npc: NPCResource, character: Character, interaction_type: String)
signal social_event_triggered(event: SocialEvent)

func _init():
	# Initialize modules
	npc_data_manager = NPCDataManager.new()
	npc_interactions = NPCInteractions.new()
	social_events = SocialEvents.new()

func _ready():
	# Load NPC data
	npc_data_manager.load_npc_data()

# Interact with an NPC
func interact_with_npc(character: Character, npc_id: String, interaction_type: String) -> Dictionary:
	"""Interact with an NPC and return results"""
	var result = npc_interactions.interact_with_npc(character, npc_id, interaction_type)

	if result["success"]:
		var npc = npc_data_manager.get_npc(npc_id)
		if npc:
			npc_interaction.emit(npc, character, result.get("interaction_type", "unknown"))

	return result

# Trigger a social event
func trigger_social_event(event_id: String, character: Character) -> bool:
	"""Trigger a social event for a character"""
	var success = social_events.trigger_social_event(event_id, character)

	if success:
		var event = npc_data_manager.get_social_event(event_id)
		if event:
			social_event_triggered.emit(event)

	return success

# Get relationship between character and NPC
func get_relationship(character: Character, npc: NPCResource) -> int:
	"""Get relationship value between character and NPC"""
	return npc_interactions.get_relationship(character, npc)

# Update relationship between character and NPC
func update_relationship(character: Character, npc: NPCResource, change: int) -> void:
	"""Update relationship between character and NPC"""
	npc_interactions.update_relationship(character, npc, change)
	relationship_changed.emit(npc, character, npc_interactions.get_relationship(character, npc))

# Get available NPCs for character
func get_available_npcs(character: Character) -> Array[NPCResource]:
	"""Get NPCs available to a character"""
	return npc_interactions.get_available_npcs(character)

# Get available social events for character
func get_available_social_events(character: Character) -> Array[SocialEvent]:
	"""Get social events available to a character"""
	return social_events.get_available_social_events(character)

# Get NPC by ID
func get_npc(npc_id: String) -> NPCResource:
	"""Get NPC by ID"""
	return npc_data_manager.get_npc(npc_id)

# Get social event by ID
func get_social_event(event_id: String) -> SocialEvent:
	"""Get social event by ID"""
	return npc_data_manager.get_social_event(event_id)

# Get all NPCs
func get_all_npcs() -> Dictionary:
	"""Get all NPCs"""
	return npc_data_manager.get_all_npcs()

# Get all social events
func get_all_social_events() -> Dictionary:
	"""Get all social events"""
	return npc_data_manager.get_all_social_events()

# Get NPCs by type
func get_npcs_by_type(npc_type: NPCType.Type) -> Array[NPCResource]:
	"""Get NPCs filtered by type"""
	return npc_data_manager.get_npcs_by_type(npc_type)

# Get NPCs by location
func get_npcs_by_location(location: String) -> Array[NPCResource]:
	"""Get NPCs at a specific location"""
	return npc_data_manager.get_npcs_by_location(location)

# Get social events by type
func get_social_events_by_type(event_type: SocialEventType) -> Array[SocialEvent]:
	"""Get social events filtered by type"""
	return npc_data_manager.get_social_events_by_type(event_type)

# Get social events by location
func get_social_events_by_location(location: String) -> Array[SocialEvent]:
	"""Get social events at a specific location"""
	return npc_data_manager.get_social_events_by_location(location)

# Get NPCs by type for character
func get_npcs_by_type_for_character(character: Character, npc_type: NPCType.Type) -> Array[NPCResource]:
	"""Get NPCs of a specific type available to a character"""
	return npc_interactions.get_npcs_by_type(character, npc_type)

# Get NPCs by location for character
func get_npcs_by_location_for_character(character: Character, location: String) -> Array[NPCResource]:
	"""Get NPCs at a specific location available to a character"""
	return npc_interactions.get_npcs_by_location(character, location)

# Get social events by type for character
func get_social_events_by_type_for_character(character: Character, event_type: SocialEventType) -> Array[SocialEvent]:
	"""Get social events of a specific type available to a character"""
	return social_events.get_social_events_by_type(character, event_type)

# Get social events by location for character
func get_social_events_by_location_for_character(character: Character, location: String) -> Array[SocialEvent]:
	"""Get social events at a specific location available to a character"""
	return social_events.get_social_events_by_location(character, location)

# Search NPCs
func search_npcs(query: String) -> Array[NPCResource]:
	"""Search NPCs by name or description"""
	return npc_data_manager.search_npcs(query)

# Get relationship text
func get_relationship_text(relationship: int) -> String:
	"""Get human-readable relationship text"""
	return npc_interactions.get_relationship_text(relationship)

# Get social event description
func get_social_event_description(event_id: String) -> String:
	"""Get description of a social event"""
	return social_events.get_social_event_description(event_id)

# Get social event requirements text
func get_social_event_requirements_text(event_id: String) -> String:
	"""Get human-readable requirements text for a social event"""
	return social_events.get_social_event_requirements_text(event_id)

# Get social event rewards text
func get_social_event_rewards_text(event_id: String) -> String:
	"""Get human-readable rewards text for a social event"""
	return social_events.get_social_event_rewards_text(event_id)

# Reload NPC data
func reload_npc_data() -> void:
	"""Reload all NPC data from files"""
	npc_data_manager.reload_npc_data()

# Get NPC data manager (for advanced usage)
func get_npc_data_manager() -> NPCDataManager:
	"""Get the NPC data manager instance"""
	return npc_data_manager

# Get NPC interactions (for advanced usage)
func get_npc_interactions() -> NPCInteractions:
	"""Get the NPC interactions instance"""
	return npc_interactions

# Get social events (for advanced usage)
func get_social_events() -> SocialEvents:
	"""Get the social events instance"""
	return social_events
