extends Node

# NPC and social interaction system for idle D&D gameplay
# Handles NPCs, relationships, and social activities

class_name NPCSystem

signal relationship_changed(npc: NPC, character: Character, new_relationship: int)
signal npc_interaction(npc: NPC, character: Character, interaction_type: String)
signal social_event_triggered(event: SocialEvent)

# Relationship levels
enum RelationshipLevel {
	HOSTILE = -100, # -100 to -51
	UNFRIENDLY = -50, # -50 to -21
	NEUTRAL = -20, # -20 to 20
	FRIENDLY = 21, # 21 to 50
	CLOSE_FRIEND = 51, # 51 to 80
	BEST_FRIEND = 81 # 81 to 100
}

# NPC types
enum NPCType {
	MERCHANT, # Shopkeepers, traders
	CRAFTSMAN, # Blacksmiths, artisans
	SCHOLAR, # Librarians, sages
	NOBLE, # Aristocrats, officials
	GUARD, # Town guards, soldiers
	PRIEST, # Clergy, religious figures
	ENTERTAINER, # Bards, performers
	INFORMANT, # Spies, information brokers
	MENTOR, # Teachers, trainers
	COMPANION # Potential party members
}

# Interaction types
enum InteractionType {
	GREETING, # Basic greeting
	SMALL_TALK, # Casual conversation
	DEEP_CONVERSATION, # Meaningful discussion
	BUSINESS, # Commercial transactions
	TRAINING, # Skill training
	QUEST_GIVING, # Quest assignment
	ROMANCE, # Romantic interest
	CONFLICT, # Disagreement or argument
	HELP_REQUEST, # Asking for assistance
	GOSSIP # Sharing information
}

# Social event types
enum SocialEventType {
	PARTY, # Social gatherings
	FESTIVAL, # Town celebrations
	MEETING, # Business meetings
	TRAINING_SESSION, # Group training
	RELIGIOUS_SERVICE, # Church services
	MARKET_DAY, # Market activities
	TOWN_HALL, # Civic meetings
	TAVERN_NIGHT, # Evening socializing
	GUILD_MEETING, # Professional gatherings
	ROYAL_AUDIENCE # Noble audiences
}

# NPC data structure
class NPC:
	var id: String
	var name: String
	var npc_type: NPCType
	var description: String
	var personality: Array[String] = [] # Personality traits
	var interests: Array[String] = [] # Things they care about
	var location: String = "" # Where they can be found
	var schedule: Dictionary = {} # Daily schedule
	var relationships: Dictionary = {} # Relationships with characters
	var quests_given: Array[String] = [] # Quests they can give
	var services: Array[String] = [] # Services they provide
	var gossip_knowledge: Array[String] = [] # Information they know

	func _init(npc_id: String, npc_name: String, npc_type: NPCType):
		id = npc_id
		name = npc_name
		npc_type = npc_type

# Social event data structure
class SocialEvent:
	var id: String
	var name: String
	var event_type: SocialEventType
	var description: String
	var location: String
	var participants: Array[String] = [] # NPC IDs
	var requirements: Dictionary = {}
	var rewards: Dictionary = {}
	var duration_hours: int = 1
	var frequency_days: int = 7 # How often it occurs

	func _init(event_id: String, event_name: String, event_type: SocialEventType):
		id = event_id
		name = event_name
		event_type = event_type

var npcs: Dictionary = {} # npc_id -> NPC
var social_events: Dictionary = {} # event_id -> SocialEvent
var character_relationships: Dictionary = {} # character_id -> npc_id -> relationship_level

func _init():
	setup_default_npcs()
	setup_social_events()

func setup_default_npcs():
	"""Initialize default NPCs for the town"""
	create_merchant_npcs()
	create_craftsman_npcs()
	create_scholar_npcs()
	create_noble_npcs()
	create_guard_npcs()
	create_priest_npcs()
	create_entertainer_npcs()
	create_informant_npcs()
	create_mentor_npcs()
	create_companion_npcs()

func create_merchant_npcs():
	"""Create merchant NPCs"""
	var general_store = NPC.new("general_store", "Marcus the Merchant", NPCType.MERCHANT)
	general_store.description = "A friendly merchant who runs the general store"
	general_store.personality = ["friendly", "honest", "business-minded"]
	general_store.interests = ["trade", "profit", "town_growth"]
	general_store.location = "Market Square"
	general_store.services = ["buy_items", "sell_items", "trade_goods"]
	general_store.schedule = {"morning": "Market Square", "afternoon": "Market Square", "evening": "Home"}
	npcs["general_store"] = general_store

	var luxury_merchant = NPC.new("luxury_merchant", "Lady Elara", NPCType.MERCHANT)
	luxury_merchant.description = "An elegant noblewoman who deals in luxury goods"
	luxury_merchant.personality = ["refined", "proud", "selective"]
	luxury_merchant.interests = ["fine_art", "luxury", "noble_culture"]
	luxury_merchant.location = "Noble District"
	luxury_merchant.services = ["luxury_items", "art_commission", "noble_introductions"]
	luxury_merchant.schedule = {"morning": "Noble District", "afternoon": "Art Gallery", "evening": "Noble Manor"}
	npcs["luxury_merchant"] = luxury_merchant

func create_craftsman_npcs():
	"""Create craftsman NPCs"""
	var blacksmith = NPC.new("blacksmith", "Thorin Ironforge", NPCType.CRAFTSMAN)
	blacksmith.description = "A skilled dwarven blacksmith with decades of experience"
	blacksmith.personality = ["gruff", "skilled", "traditional"]
	blacksmith.interests = ["metalwork", "quality_craftsmanship", "dwarven_culture"]
	blacksmith.location = "Smithy District"
	blacksmith.services = ["weapon_crafting", "armor_repair", "tool_making"]
	blacksmith.schedule = {"morning": "Smithy", "afternoon": "Smithy", "evening": "Tavern"}
	npcs["blacksmith"] = blacksmith

	var jeweler = NPC.new("jeweler", "Gemma Sparkle", NPCType.CRAFTSMAN)
	jeweler.description = "A talented halfling jeweler known for intricate designs"
	jeweler.personality = ["cheerful", "perfectionist", "artistic"]
	jeweler.interests = ["gems", "fine_craftsmanship", "beauty"]
	jeweler.location = "Artisan Quarter"
	jeweler.services = ["jewelry_crafting", "gem_appraisal", "custom_designs"]
	jeweler.schedule = {"morning": "Jewelry Shop", "afternoon": "Jewelry Shop", "evening": "Home"}
	npcs["jeweler"] = jeweler

func create_scholar_npcs():
	"""Create scholar NPCs"""
	var librarian = NPC.new("librarian", "Master Aldric", NPCType.SCHOLAR)
	librarian.description = "An elderly human scholar who maintains the town library"
	librarian.personality = ["wise", "patient", "knowledgeable"]
	librarian.interests = ["books", "history", "learning"]
	librarian.location = "Town Library"
	librarian.services = ["research_assistance", "book_access", "language_teaching"]
	librarian.schedule = {"morning": "Library", "afternoon": "Library", "evening": "Library"}
	npcs["librarian"] = librarian

func create_noble_npcs():
	"""Create noble NPCs"""
	var mayor = NPC.new("mayor", "Lord Reginald", NPCType.NOBLE)
	mayor.description = "The town's mayor, a fair but demanding leader"
	mayor.personality = ["authoritative", "fair", "ambitious"]
	mayor.interests = ["town_governance", "law", "prosperity"]
	mayor.location = "Town Hall"
	mayor.services = ["legal_advice", "town_permissions", "noble_introductions"]
	mayor.schedule = {"morning": "Town Hall", "afternoon": "Town Hall", "evening": "Noble Manor"}
	npcs["mayor"] = mayor

func create_guard_npcs():
	"""Create guard NPCs"""
	var captain = NPC.new("guard_captain", "Captain Steel", NPCType.GUARD)
	captain.description = "The town guard captain, a veteran soldier"
	captain.personality = ["disciplined", "loyal", "protective"]
	captain.interests = ["security", "training", "justice"]
	captain.location = "Guard Barracks"
	captain.services = ["combat_training", "security_advice", "patrol_duty"]
	captain.schedule = {"morning": "Guard Barracks", "afternoon": "Patrol", "evening": "Guard Barracks"}
	npcs["guard_captain"] = captain

func create_priest_npcs():
	"""Create priest NPCs"""
	var priest = NPC.new("priest", "Father Marcus", NPCType.PRIEST)
	priest.description = "The town's priest, a kind and devoted cleric"
	priest.personality = ["kind", "devout", "helpful"]
	priest.interests = ["faith", "healing", "community_service"]
	priest.location = "Temple"
	priest.services = ["healing", "spiritual_guidance", "religious_services"]
	priest.schedule = {"morning": "Temple", "afternoon": "Temple", "evening": "Temple"}
	npcs["priest"] = priest

func create_entertainer_npcs():
	"""Create entertainer NPCs"""
	var bard = NPC.new("bard", "Lyra Songweaver", NPCType.ENTERTAINER)
	bard.description = "A talented bard who performs at the local tavern"
	bard.personality = ["charismatic", "artistic", "social"]
	bard.interests = ["music", "stories", "entertainment"]
	bard.location = "The Golden Harp Tavern"
	bard.services = ["entertainment", "storytelling", "music_lessons"]
	bard.schedule = {"morning": "Tavern", "afternoon": "Practice", "evening": "Tavern"}
	npcs["bard"] = bard

func create_informant_npcs():
	"""Create informant NPCs"""
	var spy = NPC.new("spy", "Whisper", NPCType.INFORMANT)
	spy.description = "A mysterious figure who knows many secrets"
	spy.personality = ["secretive", "observant", "cunning"]
	spy.interests = ["information", "secrets", "underground_activities"]
	spy.location = "Back Alley"
	spy.services = ["information_brokering", "secret_delivery", "underground_contacts"]
	spy.schedule = {"morning": "Back Alley", "afternoon": "Various", "evening": "Tavern"}
	npcs["spy"] = spy

func create_mentor_npcs():
	"""Create mentor NPCs"""
	var wizard = NPC.new("wizard", "Archmage Elara", NPCType.MENTOR)
	wizard.description = "A retired wizard who teaches magic to promising students"
	wizard.personality = ["wise", "patient", "mysterious"]
	wizard.interests = ["magic", "teaching", "arcane_knowledge"]
	wizard.location = "Wizard's Tower"
	wizard.services = ["magic_training", "spell_research", "arcane_advice"]
	wizard.schedule = {"morning": "Tower", "afternoon": "Tower", "evening": "Tower"}
	npcs["wizard"] = wizard

func create_companion_npcs():
	"""Create potential companion NPCs"""
	var ranger = NPC.new("ranger", "Kael Wildheart", NPCType.COMPANION)
	ranger.description = "A skilled ranger who offers companionship and adventure"
	ranger.personality = ["loyal", "independent", "nature-loving"]
	ranger.interests = ["nature", "hunting", "exploration"]
	ranger.location = "Forest Edge"
	ranger.services = ["companionship", "wilderness_guidance", "hunting"]
	ranger.schedule = {"morning": "Forest", "afternoon": "Forest", "evening": "Tavern"}
	npcs["ranger"] = ranger

func setup_social_events():
	"""Initialize social events"""
	create_tavern_events()
	create_festival_events()
	create_guild_events()
	create_noble_events()

func create_tavern_events():
	"""Create tavern-based social events"""
	var tavern_night = SocialEvent.new("tavern_night", "Tavern Night", SocialEventType.TAVERN_NIGHT)
	tavern_night.description = "An evening of music, stories, and socializing at the tavern"
	tavern_night.location = "The Golden Harp Tavern"
	tavern_night.participants = ["bard", "spy", "ranger"]
	tavern_night.rewards = {"social_connections": 2, "gossip_knowledge": 1}
	tavern_night.duration_hours = 3
	tavern_night.frequency_days = 1 # Daily
	social_events["tavern_night"] = tavern_night

func create_festival_events():
	"""Create festival social events"""
	var harvest_festival = SocialEvent.new("harvest_festival", "Harvest Festival", SocialEventType.FESTIVAL)
	harvest_festival.description = "A celebration of the harvest with food, music, and games"
	harvest_festival.location = "Town Square"
	harvest_festival.participants = ["bard", "mayor", "priest", "general_store"]
	harvest_festival.rewards = {"town_reputation": 10, "social_connections": 5, "gold": 25}
	harvest_festival.duration_hours = 8
	harvest_festival.frequency_days = 30 # Monthly
	social_events["harvest_festival"] = harvest_festival

func create_guild_events():
	"""Create guild-based social events"""
	var craftsman_guild = SocialEvent.new("craftsman_guild", "Craftsman Guild Meeting", SocialEventType.GUILD_MEETING)
	craftsman_guild.description = "A meeting of local craftsmen to discuss trade and techniques"
	craftsman_guild.location = "Guild Hall"
	craftsman_guild.participants = ["blacksmith", "jeweler"]
	craftsman_guild.rewards = {"craft_reputation": 15, "trade_opportunities": 3}
	craftsman_guild.duration_hours = 2
	craftsman_guild.frequency_days = 7 # Weekly
	social_events["craftsman_guild"] = craftsman_guild

func create_noble_events():
	"""Create noble social events"""
	var royal_audience = SocialEvent.new("royal_audience", "Royal Audience", SocialEventType.ROYAL_AUDIENCE)
	royal_audience.description = "An audience with the local nobility for important matters"
	royal_audience.location = "Noble Manor"
	royal_audience.participants = ["mayor", "luxury_merchant"]
	royal_audience.requirements = {"noble_reputation": 50}
	royal_audience.rewards = {"noble_reputation": 25, "political_connections": 5}
	royal_audience.duration_hours = 1
	royal_audience.frequency_days = 14 # Bi-weekly
	social_events["royal_audience"] = royal_audience

func interact_with_npc(character: Character, npc_id: String, interaction_type: InteractionType) -> Dictionary:
	"""Handle interaction between character and NPC"""
	var npc = npcs.get(npc_id)
	if npc == null:
		return {"success": false, "message": "NPC not found"}

	var relationship = get_relationship(character, npc)
	var result = process_interaction(character, npc, interaction_type, relationship)

	# Update relationship based on interaction
	update_relationship(character, npc, result.relationship_change)

	npc_interaction.emit(npc, character, InteractionType.keys()[interaction_type])
	return result

func process_interaction(character: Character, npc: NPC, interaction_type: InteractionType, relationship: int) -> Dictionary:
	"""Process the specific interaction type"""
	var result = {"success": true, "message": "", "relationship_change": 0, "rewards": {}}

	match interaction_type:
		InteractionType.GREETING:
			result = process_greeting(character, npc, relationship)
		InteractionType.SMALL_TALK:
			result = process_small_talk(character, npc, relationship)
		InteractionType.DEEP_CONVERSATION:
			result = process_deep_conversation(character, npc, relationship)
		InteractionType.BUSINESS:
			result = process_business(character, npc, relationship)
		InteractionType.TRAINING:
			result = process_training(character, npc, relationship)
		InteractionType.QUEST_GIVING:
			result = process_quest_giving(character, npc, relationship)
		InteractionType.ROMANCE:
			result = process_romance(character, npc, relationship)
		InteractionType.CONFLICT:
			result = process_conflict(character, npc, relationship)
		InteractionType.HELP_REQUEST:
			result = process_help_request(character, npc, relationship)
		InteractionType.GOSSIP:
			result = process_gossip(character, npc, relationship)

	return result

func process_greeting(character: Character, npc: NPC, relationship: int) -> Dictionary:
	"""Process a greeting interaction"""
	var result = {"success": true, "message": "", "relationship_change": 0, "rewards": {}}

	if relationship >= RelationshipLevel.FRIENDLY:
		result.message = "%s greets you warmly: 'Good to see you again, %s!'" % [npc.name, character.name]
		result.relationship_change = 1
	elif relationship >= RelationshipLevel.NEUTRAL:
		result.message = "%s nods politely: 'Hello there.'" % npc.name
		result.relationship_change = 0
	else:
		result.message = "%s gives you a cold look and barely acknowledges you." % npc.name
		result.relationship_change = -1

	return result

func process_small_talk(character: Character, npc: NPC, relationship: int) -> Dictionary:
	"""Process small talk interaction"""
	var result = {"success": true, "message": "", "relationship_change": 0, "rewards": {}}

	# Check if character has high charisma
	if character.charisma >= 14:
		result.message = "Your charming conversation with %s goes well." % npc.name
		result.relationship_change = 2
		result.rewards["charisma_exp"] = 5
	else:
		result.message = "You have a pleasant but unremarkable conversation with %s." % npc.name
		result.relationship_change = 1

	return result

func process_deep_conversation(character: Character, npc: NPC, relationship: int) -> Dictionary:
	"""Process deep conversation interaction"""
	var result = {"success": true, "message": "", "relationship_change": 0, "rewards": {}}

	if relationship < RelationshipLevel.FRIENDLY:
		result.message = "%s seems uncomfortable with such personal conversation." % npc.name
		result.relationship_change = -1
		return result

	result.message = "You have a meaningful conversation with %s about %s." % [npc.name, npc.interests[0] if npc.interests.size() > 0 else "life"]
	result.relationship_change = 3
	result.rewards["charisma_exp"] = 10

	return result

func process_business(character: Character, npc: NPC, relationship: int) -> Dictionary:
	"""Process business interaction"""
	var result = {"success": true, "message": "", "relationship_change": 0, "rewards": {}}

	if npc.npc_type != NPCType.MERCHANT and npc.npc_type != NPCType.CRAFTSMAN:
		result.message = "%s doesn't seem interested in business matters." % npc.name
		result.relationship_change = -1
		return result

	result.message = "You discuss business opportunities with %s." % npc.name
	result.relationship_change = 1
	result.rewards["business_connections"] = 1

	return result

func process_training(character: Character, npc: NPC, relationship: int) -> Dictionary:
	"""Process training interaction"""
	var result = {"success": true, "message": "", "relationship_change": 0, "rewards": {}}

	if npc.npc_type != NPCType.MENTOR and npc.npc_type != NPCType.GUARD:
		result.message = "%s doesn't offer training services." % npc.name
		return result

	result.message = "%s agrees to train you in their area of expertise." % npc.name
	result.relationship_change = 2
	result.rewards["training_opportunity"] = 1

	return result

func process_quest_giving(character: Character, npc: NPC, relationship: int) -> Dictionary:
	"""Process quest giving interaction"""
	var result = {"success": true, "message": "", "relationship_change": 0, "rewards": {}}

	if relationship < RelationshipLevel.NEUTRAL:
		result.message = "%s doesn't trust you enough to give you important tasks." % npc.name
		return result

	result.message = "%s has a task that might interest you." % npc.name
	result.relationship_change = 1
	result.rewards["quest_opportunity"] = 1

	return result

func process_romance(character: Character, npc: NPC, relationship: int) -> Dictionary:
	"""Process romance interaction"""
	var result = {"success": true, "message": "", "relationship_change": 0, "rewards": {}}

	if relationship < RelationshipLevel.CLOSE_FRIEND:
		result.message = "%s seems uncomfortable with romantic advances." % npc.name
		result.relationship_change = -2
		return result

	result.message = "You express romantic interest in %s." % npc.name
	result.relationship_change = 5
	result.rewards["romantic_relationship"] = 1

	return result

func process_conflict(character: Character, npc: NPC, relationship: int) -> Dictionary:
	"""Process conflict interaction"""
	var result = {"success": true, "message": "", "relationship_change": 0, "rewards": {}}

	result.message = "You have a disagreement with %s." % npc.name
	result.relationship_change = -3
	result.rewards["conflict_resolution"] = 1

	return result

func process_help_request(character: Character, npc: NPC, relationship: int) -> Dictionary:
	"""Process help request interaction"""
	var result = {"success": true, "message": "", "relationship_change": 0, "rewards": {}}

	if relationship >= RelationshipLevel.FRIENDLY:
		result.message = "%s is happy to help you with your request." % npc.name
		result.relationship_change = 1
		result.rewards["help_received"] = 1
	else:
		result.message = "%s seems reluctant to help someone they don't know well." % npc.name
		result.relationship_change = 0

	return result

func process_gossip(character: Character, npc: NPC, relationship: int) -> Dictionary:
	"""Process gossip interaction"""
	var result = {"success": true, "message": "", "relationship_change": 0, "rewards": {}}

	if relationship >= RelationshipLevel.FRIENDLY:
		result.message = "%s shares some interesting gossip with you." % npc.name
		result.relationship_change = 1
		result.rewards["gossip_knowledge"] = 1
	else:
		result.message = "%s doesn't trust you enough to share gossip." % npc.name
		result.relationship_change = 0

	return result

func get_relationship(character: Character, npc: NPC) -> int:
	"""Get relationship level between character and NPC"""
	if not character_relationships.has(character.name):
		character_relationships[character.name] = {}

	return character_relationships[character.name].get(npc.id, RelationshipLevel.NEUTRAL)

func update_relationship(character: Character, npc: NPC, change: int) -> void:
	"""Update relationship between character and NPC"""
	if not character_relationships.has(character.name):
		character_relationships[character.name] = {}

	var current_relationship = character_relationships[character.name].get(npc.id, RelationshipLevel.NEUTRAL)
	var new_relationship = clamp(current_relationship + change, RelationshipLevel.HOSTILE, RelationshipLevel.BEST_FRIEND)

	character_relationships[character.name][npc.id] = new_relationship
	relationship_changed.emit(npc, character, new_relationship)

func get_available_npcs(character: Character) -> Array[NPC]:
	"""Get NPCs available for interaction based on character's location and relationships"""
	var available: Array[NPC] = []

	for npc in npcs.values():
		# Check if NPC is available based on schedule
		var current_hour = Time.get_datetime_dict_from_system().hour
		var time_period = "morning" if current_hour < 12 else "afternoon" if current_hour < 18 else "evening"

		if npc.schedule.has(time_period):
			available.append(npc)

	return available

func trigger_social_event(event_id: String, character: Character) -> bool:
	"""Trigger a social event for a character"""
	var event = social_events.get(event_id)
	if event == null:
		return false

	# Check requirements
	for req_key in event.requirements.keys():
		var req_value = event.requirements[req_key]
		var char_value = character.get(req_key)
		if char_value < req_value:
			return false

	# Give rewards
	for reward_type in event.rewards.keys():
		var reward_amount = event.rewards[reward_type]
		give_social_reward(character, reward_type, reward_amount)

	social_event_triggered.emit(event)
	return true

func give_social_reward(character: Character, reward_type: String, amount: int) -> void:
	"""Give a social reward to a character"""
	match reward_type:
		"social_connections":
			# Add to character's social connections
			if not character.has_method("add_social_connection"):
				character.set("social_connections", character.get("social_connections") + amount)
		"gossip_knowledge":
			# Add to character's knowledge
			if not character.has_method("add_knowledge"):
				character.set("gossip_knowledge", character.get("gossip_knowledge") + amount)
		"town_reputation", "noble_reputation":
			var faction_name = reward_type.replace("_reputation", "")
			if faction_name == "town":
				faction_name = "Town"
			elif faction_name == "noble":
				faction_name = "Lord's Alliance"

			if not character.faction_reputation.has(faction_name):
				character.faction_reputation[faction_name] = 0
			character.faction_reputation[faction_name] += amount
		"gold":
			character.add_gold(amount)
		"craft_reputation":
			if not character.faction_reputation.has("Craftsman Guild"):
				character.faction_reputation["Craftsman Guild"] = 0
			character.faction_reputation["Craftsman Guild"] += amount
		"political_connections":
			if not character.has_method("add_political_connection"):
				character.set("political_connections", character.get("political_connections") + amount)
