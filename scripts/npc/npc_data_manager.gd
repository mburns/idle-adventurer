extends Node

# NPC data management system
# Handles NPC creation, loading, and data structures

class_name NPCDataManager

# NPC storage
var npcs: Dictionary = {} # npc_id -> NPCResource
var social_events: Dictionary = {} # event_id -> SocialEvent

# YAML parser instance
var yaml_parser: YAMLParser

func _init():
	yaml_parser = YAMLParser.new()

# Load all NPC data
func load_npc_data() -> void:
	"""Load all NPC data from YAML files"""
	load_npcs_from_yaml()
	load_social_events_from_yaml()
	print("Loaded " + str(npcs.size()) + " NPCs and " + str(social_events.size()) + " social events")

# Load NPCs from YAML
func load_npcs_from_yaml() -> void:
	"""Load NPCs from YAML file"""
	var file_path = "res://data/npcs/npcs.yaml"
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		print("Warning: Could not open NPCs file: " + file_path)
		return

	var yaml_string = file.get_as_text()
	file.close()

	var npcs_data = yaml_parser.parse_yaml_file(file_path)
	if npcs_data.is_empty():
		print("Error: Could not parse NPCs data")
		return

	var npcs_list = npcs_data.get("npcs", [])
	for npc_data in npcs_list:
		var npc_id = npc_data.get("id", "")
		if npc_id != "":
			var npc = create_npc_from_data(npc_id, npc_data)
			npcs[npc_id] = npc

	print("Loaded " + str(npcs_list.size()) + " NPCs")

# Load social events from YAML
func load_social_events_from_yaml() -> void:
	"""Load social events from YAML file"""
	var file_path = "res://data/npcs/social_events.yaml"
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		print("Warning: Could not open social events file: " + file_path)
		return

	var yaml_string = file.get_as_text()
	file.close()

	var events_data = yaml_parser.parse_yaml_file(file_path)
	if events_data.is_empty():
		print("Error: Could not parse social events data")
		return

	var events_list = events_data.get("events", [])
	for event_data in events_list:
		var event_id = event_data.get("id", "")
		if event_id != "":
			var event = create_social_event_from_data(event_id, event_data)
			social_events[event_id] = event

	print("Loaded " + str(events_list.size()) + " social events")

# Create NPC from data
func create_npc_from_data(npc_id: String, data: Dictionary) -> NPCResource:
	"""Create an NPCResource object from data"""
	var npc_resource = NPCResource.new()
	npc_resource.npc_id = npc_id
	npc_resource.name = data.get("name", "")
	npc_resource.description = data.get("description", "")
	npc_resource.npc_type = get_npc_type_from_string(data.get("type", "MERCHANT"))
	npc_resource.location = data.get("location", "")
	npc_resource.level = data.get("level", 1)

	# Set schedule with type safety
	var schedule = data.get("schedule", {})
	if schedule is Dictionary:
		npc_resource.schedule = schedule
	else:
		print("Warning: schedule is not a Dictionary for NPC ", npc_id)
		npc_resource.schedule = {}

	# Set personality with type safety
	var personality = data.get("personality", {})
	if personality is Dictionary:
		npc_resource.personality = personality
	else:
		print("Warning: personality is not a Dictionary for NPC ", npc_id)
		npc_resource.personality = {}

	# Set interests
	var interests = data.get("interests", [])
	if interests is Array:
		npc_resource.interests = interests
	else:
		print("Warning: interests is not an Array for NPC ", npc_id)
		npc_resource.interests = []

	# Set quests
	var quests = data.get("quests", [])
	if quests is Array:
		npc_resource.quests = quests
	else:
		print("Warning: quests is not an Array for NPC ", npc_id)
		npc_resource.quests = []

	# Set services
	var services = data.get("services", [])
	if services is Array:
		npc_resource.services = services
	else:
		print("Warning: services is not an Array for NPC ", npc_id)
		npc_resource.services = []

	# Set dialogue with type safety
	var dialogue = data.get("dialogue", {})
	if dialogue is Dictionary:
		npc_resource.dialogue = dialogue
	else:
		print("Warning: dialogue is not a Dictionary for NPC ", npc_id)
		npc_resource.dialogue = {}

	# Set requirements with type safety
	var requirements = data.get("requirements", {})
	if requirements is Dictionary:
		npc_resource.requirements = requirements
	else:
		print("Warning: requirements is not a Dictionary for NPC ", npc_id)
		npc_resource.requirements = {}

	# Set additional properties
	npc_resource.interests = data.get("interests", [])
	npc_resource.dislikes = data.get("dislikes", [])
	npc_resource.fears = data.get("fears", [])
	npc_resource.training_skills = data.get("training_skills", [])
	npc_resource.items_for_sale = data.get("items_for_sale", [])
	npc_resource.items_bought = data.get("items_bought", [])
	npc_resource.faction = data.get("faction", "")
	npc_resource.faction_rank = data.get("faction_rank", "")
	npc_resource.wealth_level = data.get("wealth_level", "modest")
	npc_resource.voice_type = data.get("voice_type", "normal")
	npc_resource.speech_pattern = data.get("speech_pattern", "formal")

	return npc_resource

# Create social event from data
func create_social_event_from_data(event_id: String, data: Dictionary) -> SocialEvent:
	"""Create a SocialEvent object from data"""
	var event = SocialEvent.new()
	event.id = event_id
	event.name = data.get("name", "")
	event.description = data.get("description", "")
	event.event_type = get_social_event_type_from_string(data.get("type", "TAVERN_GATHERING"))
	event.requirements = data.get("requirements", {})
	event.rewards = data.get("rewards", {})
	event.duration = data.get("duration", 3600)
	event.location = data.get("location", "")
	event.participants = data.get("participants", [])
	return event

# Get NPC type from string
func get_npc_type_from_string(type_str: String) -> NPCType.Type:
	"""Convert string to NPCType enum"""
	match type_str.to_upper():
		"MERCHANT":
			return NPCType.Type.MERCHANT
		"CRAFTSMAN":
			return NPCType.Type.ARTISAN
		"SCHOLAR":
			return NPCType.Type.SAGE
		"NOBLE":
			return NPCType.Type.NOBLE
		"GUARD":
			return NPCType.Type.GUARD
		"PRIEST":
			return NPCType.Type.CLERIC
		"ENTERTAINER":
			return NPCType.Type.ENTERTAINER
		"INFORMANT":
			return NPCType.Type.ROGUE
		"MENTOR":
			return NPCType.Type.TRAINER
		"COMPANION":
			return NPCType.Type.ADVENTURER
		"QUEST_GIVER":
			return NPCType.Type.QUEST_GIVER
		"TRAINER":
			return NPCType.Type.TRAINER
		"INNKEEPER":
			return NPCType.Type.INNKEEPER
		"BLACKSMITH":
			return NPCType.Type.BLACKSMITH
		"LIBRARIAN":
			return NPCType.Type.LIBRARIAN
		"COMMONER":
			return NPCType.Type.COMMONER
		"ADVENTURER":
			return NPCType.Type.ADVENTURER
		"CLERIC":
			return NPCType.Type.CLERIC
		"WIZARD":
			return NPCType.Type.WIZARD
		"ROGUE":
			return NPCType.Type.ROGUE
		"SOLDIER":
			return NPCType.Type.SOLDIER
		"FARMER":
			return NPCType.Type.FARMER
		"ARTISAN":
			return NPCType.Type.ARTISAN
		"HERMIT":
			return NPCType.Type.HERMIT
		"SAGE":
			return NPCType.Type.SAGE
		"CRIMINAL":
			return NPCType.Type.CRIMINAL
		_:
			return NPCType.Type.COMMONER

# Get social event type from string
func get_social_event_type_from_string(type_str: String) -> SocialEventType.Type:
	"""Convert string to SocialEventType enum"""
	match type_str.to_upper():
		"TAVERN_GATHERING":
			return SocialEventType.Type.TAVERN_GATHERING
		"FESTIVAL":
			return SocialEventType.Type.FESTIVAL
		"GUILD_MEETING":
			return SocialEventType.Type.GUILD_MEETING
		"NOBLE_PARTY":
			return SocialEventType.Type.NOBLE_PARTY
		"RELIGIOUS_CEREMONY":
			return SocialEventType.Type.RELIGIOUS_CEREMONY
		"MARKET_DAY":
			return SocialEventType.Type.MARKET_DAY
		"TOURNAMENT":
			return SocialEventType.Type.TOURNAMENT
		"WEDDING":
			return SocialEventType.Type.WEDDING
		"FUNERAL":
			return SocialEventType.Type.FUNERAL
		"COUNCIL_MEETING":
			return SocialEventType.Type.COUNCIL_MEETING
		_:
			return SocialEventType.Type.TAVERN_GATHERING

# Get NPC by ID
func get_npc(npc_id: String) -> NPCResource:
	"""Get NPC by ID"""
	return npcs.get(npc_id, null)

# Get social event by ID
func get_social_event(event_id: String) -> SocialEvent:
	"""Get social event by ID"""
	return social_events.get(event_id, null)

# Get all NPCs
func get_all_npcs() -> Dictionary:
	"""Get all NPCs"""
	return npcs.duplicate()

# Get all social events
func get_all_social_events() -> Dictionary:
	"""Get all social events"""
	return social_events.duplicate()

# Get NPCs by type
func get_npcs_by_type(npc_type: NPCType.Type) -> Array[NPCResource]:
	"""Get NPCs filtered by type"""
	var filtered_npcs: Array[NPCResource] = []
	for npc in npcs.values():
		if npc.npc_type == npc_type:
			filtered_npcs.append(npc)
	return filtered_npcs

# Get NPCs by location
func get_npcs_by_location(location: String) -> Array[NPCResource]:
	"""Get NPCs at a specific location"""
	var location_npcs: Array[NPCResource] = []
	for npc in npcs.values():
		if npc.location == location:
			location_npcs.append(npc)
	return location_npcs

# Get social events by type
func get_social_events_by_type(event_type: SocialEventType) -> Array[SocialEvent]:
	"""Get social events filtered by type"""
	var filtered_events: Array[SocialEvent] = []
	for event in social_events.values():
		if event.event_type == event_type:
			filtered_events.append(event)
	return filtered_events

# Get social events by location
func get_social_events_by_location(location: String) -> Array[SocialEvent]:
	"""Get social events at a specific location"""
	var location_events: Array[SocialEvent] = []
	for event in social_events.values():
		if event.location == location:
			location_events.append(event)
	return location_events

# Reload NPC data
func reload_npc_data() -> void:
	"""Reload all NPC data from files"""
	npcs.clear()
	social_events.clear()
	load_npc_data()

# Validate NPC data
func validate_npc_data(npc_data: Dictionary) -> bool:
	"""Validate NPC data structure"""
	var required_fields = ["id", "name", "type"]

	for field in required_fields:
		if not npc_data.has(field) or npc_data[field].is_empty():
			print("Invalid NPC data: missing " + field)
			return false

	return true

# Validate social event data
func validate_social_event_data(event_data: Dictionary) -> bool:
	"""Validate social event data structure"""
	var required_fields = ["id", "name", "type"]

	for field in required_fields:
		if not event_data.has(field) or event_data[field].is_empty():
			print("Invalid social event data: missing " + field)
			return false

	return true

# Search NPCs
func search_npcs(query: String) -> Array[NPCResource]:
	"""Search NPCs by name or description"""
	var results: Array[NPCResource] = []
	query = query.to_lower()

	for npc in npcs.values():
		if npc.name.to_lower().contains(query) or npc.description.to_lower().contains(query):
			results.append(npc)

	return results

# Get NPC count
func get_npc_count() -> int:
	"""Get total number of NPCs"""
	return npcs.size()

# Get social event count
func get_social_event_count() -> int:
	"""Get total number of social events"""
	return social_events.size()

# Get available NPC types
func get_available_npc_types() -> Array[String]:
	"""Get all available NPC types"""
	var npc_types: Array[String] = []
	for npc in npcs.values():
		var type_str = get_npc_type_string(npc.npc_type)
		if type_str not in npc_types:
			npc_types.append(type_str)
	return npc_types

# Get available social event types
func get_available_social_event_types() -> Array[String]:
	"""Get all available social event types"""
	var event_types: Array[String] = []
	for event in social_events.values():
		var type_str = get_social_event_type_string(event.event_type)
		if type_str not in event_types:
			event_types.append(type_str)
	return event_types

# Get NPC type as string
func get_npc_type_string(npc_type: NPCType) -> String:
	"""Convert NPCType enum to string"""
	match npc_type:
		NPCType.Type.MERCHANT:
			return "MERCHANT"
		NPCType.Type.CRAFTSMAN:
			return "CRAFTSMAN"
		NPCType.Type.SCHOLAR:
			return "SCHOLAR"
		NPCType.Type.NOBLE:
			return "NOBLE"
		NPCType.Type.GUARD:
			return "GUARD"
		NPCType.Type.PRIEST:
			return "PRIEST"
		NPCType.Type.ENTERTAINER:
			return "ENTERTAINER"
		NPCType.Type.INFORMANT:
			return "INFORMANT"
		NPCType.Type.MENTOR:
			return "MENTOR"
		NPCType.Type.COMPANION:
			return "COMPANION"
		_:
			return "MERCHANT"

# Get social event type as string
func get_social_event_type_string(event_type: SocialEventType) -> String:
	"""Convert SocialEventType enum to string"""
	match event_type:
		SocialEventType.Type.TAVERN_GATHERING:
			return "TAVERN_GATHERING"
		SocialEventType.Type.FESTIVAL:
			return "FESTIVAL"
		SocialEventType.Type.GUILD_MEETING:
			return "GUILD_MEETING"
		SocialEventType.Type.NOBLE_PARTY:
			return "NOBLE_PARTY"
		SocialEventType.Type.RELIGIOUS_CEREMONY:
			return "RELIGIOUS_CEREMONY"
		SocialEventType.Type.MARKET_DAY:
			return "MARKET_DAY"
		SocialEventType.Type.TOURNAMENT:
			return "TOURNAMENT"
		SocialEventType.Type.WEDDING:
			return "WEDDING"
		SocialEventType.Type.FUNERAL:
			return "FUNERAL"
		SocialEventType.Type.COUNCIL_MEETING:
			return "COUNCIL_MEETING"
		_:
			return "TAVERN_GATHERING"
