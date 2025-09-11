extends Node

# Random events system for idle D&D gameplay
# Handles random encounters, events, and dynamic content

class_name RandomEventsSystem

signal random_event_triggered(event: RandomEvent, character: Character)
signal event_resolved(event: RandomEvent, character: Character, outcome: EventOutcome)
signal event_choice_made(event: RandomEvent, character: Character, choice: String)

# Event types
enum EventType {
	SOCIAL, # Social encounters and interactions
	ECONOMIC, # Economic opportunities and challenges
	MYSTICAL, # Magical or supernatural events
	CRIMINAL, # Crime-related events
	POLITICAL, # Political events and intrigue
	NATURAL, # Weather and natural events
	PROFESSIONAL, # Work-related events
	PERSONAL, # Personal character development
	COMMUNITY, # Town/community events
	ADVENTURE_HOOK # Hooks for future adventures
}

# Event outcomes
enum EventOutcome {
	SUCCESS, # Positive outcome
	FAILURE, # Negative outcome
	NEUTRAL, # No significant change
	MIXED, # Both positive and negative results
	CRITICAL_SUCCESS, # Exceptional positive outcome
	CRITICAL_FAILURE # Exceptional negative outcome
}

# Event rarity
enum EventRarity {
	COMMON, # Happens frequently
	UNCOMMON, # Occasional events
	RARE, # Infrequent events
	EPIC, # Very rare events
	LEGENDARY # Extremely rare events
}

# Random event data structure
class RandomEvent:
	var id: String
	var name: String
	var event_type: EventType
	var rarity: EventRarity
	var description: String
	var choices: Array[Dictionary] = [] # Available choices
	var requirements: Dictionary = {} # Requirements to trigger
	var consequences: Dictionary = {} # Possible consequences
	var duration_hours: int = 1 # How long the event lasts
	var cooldown_days: int = 0 # Days before event can trigger again

	func _init(event_id: String, event_name: String, event_type: EventType):
		id = event_id
		name = event_name
		event_type = event_type

# Event choice data structure
class EventChoice:
	var id: String
	var description: String
	var requirements: Dictionary = {}
	var consequences: Dictionary = {}
	var skill_check: String = "" # Skill required for this choice
	var difficulty: int = 10 # DC for skill check

	func _init(choice_id: String, choice_description: String):
		id = choice_id
		description = choice_description

var events: Dictionary = {} # event_id -> RandomEvent
var event_history: Dictionary = {} # character_id -> Array[event_data]
var active_events: Dictionary = {} # character_id -> RandomEvent
var event_cooldowns: Dictionary = {} # character_id -> event_id -> cooldown_end_time

func _init():
	setup_random_events()

func setup_random_events():
	"""Initialize random events"""
	create_social_events()
	create_economic_events()
	create_mystical_events()
	create_criminal_events()
	create_political_events()
	create_natural_events()
	create_professional_events()
	create_personal_events()
	create_community_events()
	create_adventure_hook_events()

func create_social_events():
	"""Create social random events"""
	var noble_party = RandomEvent.new("noble_party", "Noble's Party Invitation", EventType.SOCIAL)
	noble_party.rarity = EventRarity.UNCOMMON
	noble_party.description = "You receive an invitation to a noble's party. This could be a great opportunity to make connections."
	noble_party.requirements = {"charisma": 12, "noble_reputation": 20}
	noble_party.choices = [
		{"id": "accept", "description": "Accept the invitation", "skill_check": "persuasion", "difficulty": 12},
		{"id": "decline", "description": "Politely decline", "skill_check": "", "difficulty": 0},
		{"id": "send_gift", "description": "Send a gift instead", "skill_check": "insight", "difficulty": 10}
	]
	noble_party.consequences = {
		"accept": {"noble_reputation": 15, "social_connections": 3, "gold": - 25},
		"decline": {"noble_reputation": - 5},
		"send_gift": {"noble_reputation": 10, "gold": - 50}
	}
	noble_party.duration_hours = 4
	noble_party.cooldown_days = 30
	events["noble_party"] = noble_party

	var tavern_brawl = RandomEvent.new("tavern_brawl", "Tavern Brawl", EventType.SOCIAL)
	tavern_brawl.rarity = EventRarity.COMMON
	tavern_brawl.description = "A fight breaks out in the tavern. How do you respond?"
	tavern_brawl.choices = [
		{"id": "join_fight", "description": "Join the brawl", "skill_check": "athletics", "difficulty": 14},
		{"id": "break_up", "description": "Try to break up the fight", "skill_check": "persuasion", "difficulty": 16},
		{"id": "leave", "description": "Leave quietly", "skill_check": "stealth", "difficulty": 10},
		{"id": "watch", "description": "Watch from a safe distance", "skill_check": "", "difficulty": 0}
	]
	tavern_brawl.consequences = {
		"join_fight": {"hit_points": - 5, "tavern_reputation": 10, "combat_exp": 10},
		"break_up": {"tavern_reputation": 20, "charisma_exp": 15, "hit_points": - 2},
		"leave": {"tavern_reputation": - 5},
		"watch": {"tavern_reputation": 0}
	}
	tavern_brawl.duration_hours = 1
	tavern_brawl.cooldown_days = 7
	events["tavern_brawl"] = tavern_brawl

func create_economic_events():
	"""Create economic random events"""
	var investment_opportunity = RandomEvent.new("investment_opportunity", "Investment Opportunity", EventType.ECONOMIC)
	investment_opportunity.rarity = EventRarity.RARE
	investment_opportunity.description = "A merchant offers you a chance to invest in a promising venture."
	investment_opportunity.requirements = {"gold": 100, "merchant_reputation": 30}
	investment_opportunity.choices = [
		{"id": "invest_small", "description": "Invest a small amount", "skill_check": "insight", "difficulty": 12},
		{"id": "invest_large", "description": "Invest a large amount", "skill_check": "insight", "difficulty": 15},
		{"id": "decline", "description": "Decline the opportunity", "skill_check": "", "difficulty": 0}
	]
	investment_opportunity.consequences = {
		"invest_small": {"gold": 0, "merchant_reputation": 5}, # Will be modified by skill check
		"invest_large": {"gold": 0, "merchant_reputation": 10}, # Will be modified by skill check
		"decline": {"merchant_reputation": - 2}
	}
	investment_opportunity.duration_hours = 2
	investment_opportunity.cooldown_days = 60
	events["investment_opportunity"] = investment_opportunity

	var market_crash = RandomEvent.new("market_crash", "Market Crash", EventType.ECONOMIC)
	market_crash.rarity = EventRarity.EPIC
	market_crash.description = "The local market crashes, affecting all traders and merchants."
	market_crash.choices = [
		{"id": "buy_cheap", "description": "Buy goods at low prices", "skill_check": "insight", "difficulty": 14},
		{"id": "sell_quick", "description": "Sell your goods quickly", "skill_check": "persuasion", "difficulty": 12},
		{"id": "wait", "description": "Wait for the market to recover", "skill_check": "", "difficulty": 0}
	]
	market_crash.consequences = {
		"buy_cheap": {"gold": - 50, "inventory": 5},
		"sell_quick": {"gold": 25, "inventory": - 3},
		"wait": {"gold": 0}
	}
	market_crash.duration_hours = 24
	market_crash.cooldown_days = 365
	events["market_crash"] = market_crash

func create_mystical_events():
	"""Create mystical random events"""
	var mysterious_stranger = RandomEvent.new("mysterious_stranger", "Mysterious Stranger", EventType.MYSTICAL)
	mysterious_stranger.rarity = EventRarity.RARE
	mysterious_stranger.description = "A mysterious figure approaches you with an offer that seems too good to be true."
	mysterious_stranger.choices = [
		{"id": "listen", "description": "Listen to their offer", "skill_check": "insight", "difficulty": 16},
		{"id": "decline", "description": "Politely decline", "skill_check": "persuasion", "difficulty": 12},
		{"id": "investigate", "description": "Try to learn more about them", "skill_check": "investigation", "difficulty": 14}
	]
	mysterious_stranger.consequences = {
		"listen": {"gold": 100, "mystical_knowledge": 1, "charisma_exp": 20},
		"decline": {"charisma_exp": 5},
		"investigate": {"investigation_exp": 15, "mystical_knowledge": 1}
	}
	mysterious_stranger.duration_hours = 1
	mysterious_stranger.cooldown_days = 90
	events["mysterious_stranger"] = mysterious_stranger

func create_criminal_events():
	"""Create criminal random events"""
	var pickpocket_attempt = RandomEvent.new("pickpocket_attempt", "Pickpocket Attempt", EventType.CRIMINAL)
	pickpocket_attempt.rarity = EventRarity.COMMON
	pickpocket_attempt.description = "You notice someone trying to pick your pocket in the crowded market."
	pickpocket_attempt.choices = [
		{"id": "catch_thief", "description": "Catch the pickpocket", "skill_check": "athletics", "difficulty": 12},
		{"id": "alert_guards", "description": "Alert the town guards", "skill_check": "persuasion", "difficulty": 10},
		{"id": "ignore", "description": "Ignore and move on", "skill_check": "", "difficulty": 0}
	]
	pickpocket_attempt.consequences = {
		"catch_thief": {"guard_reputation": 10, "gold": 5, "combat_exp": 5},
		"alert_guards": {"guard_reputation": 5},
		"ignore": {"gold": - 10} # Lost money
	}
	pickpocket_attempt.duration_hours = 0.5
	pickpocket_attempt.cooldown_days = 14
	events["pickpocket_attempt"] = pickpocket_attempt

func create_political_events():
	"""Create political random events"""
	var town_meeting = RandomEvent.new("town_meeting", "Town Meeting", EventType.POLITICAL)
	town_meeting.rarity = EventRarity.UNCOMMON
	town_meeting.description = "The mayor calls a town meeting to discuss important issues."
	town_meeting.requirements = {"town_reputation": 10}
	town_meeting.choices = [
		{"id": "attend", "description": "Attend the meeting", "skill_check": "persuasion", "difficulty": 12},
		{"id": "speak_up", "description": "Speak up on an issue", "skill_check": "persuasion", "difficulty": 16},
		{"id": "skip", "description": "Skip the meeting", "skill_check": "", "difficulty": 0}
	]
	town_meeting.consequences = {
		"attend": {"town_reputation": 5, "political_knowledge": 1},
		"speak_up": {"town_reputation": 15, "political_connections": 2, "charisma_exp": 20},
		"skip": {"town_reputation": - 2}
	}
	town_meeting.duration_hours = 2
	town_meeting.cooldown_days = 30
	events["town_meeting"] = town_meeting

func create_natural_events():
	"""Create natural random events"""
	var severe_storm = RandomEvent.new("severe_storm", "Severe Storm", EventType.NATURAL)
	severe_storm.rarity = EventRarity.UNCOMMON
	severe_storm.description = "A severe storm hits the town, causing damage and disruption."
	severe_storm.choices = [
		{"id": "help_others", "description": "Help others during the storm", "skill_check": "athletics", "difficulty": 14},
		{"id": "find_shelter", "description": "Find safe shelter", "skill_check": "survival", "difficulty": 10},
		{"id": "continue_work", "description": "Continue working despite the storm", "skill_check": "constitution", "difficulty": 16}
	]
	severe_storm.consequences = {
		"help_others": {"town_reputation": 20, "hit_points": - 5, "charisma_exp": 15},
		"find_shelter": {"hit_points": 0},
		"continue_work": {"gold": 10, "hit_points": - 10, "constitution_exp": 10}
	}
	severe_storm.duration_hours = 8
	severe_storm.cooldown_days = 60
	events["severe_storm"] = severe_storm

func create_professional_events():
	"""Create professional random events"""
	var guild_invitation = RandomEvent.new("guild_invitation", "Guild Invitation", EventType.PROFESSIONAL)
	guild_invitation.rarity = EventRarity.UNCOMMON
	guild_invitation.description = "A professional guild invites you to join their ranks."
	guild_invitation.requirements = {"level": 3, "craft_reputation": 25}
	guild_invitation.choices = [
		{"id": "join", "description": "Join the guild", "skill_check": "persuasion", "difficulty": 12},
		{"id": "negotiate", "description": "Negotiate membership terms", "skill_check": "persuasion", "difficulty": 16},
		{"id": "decline", "description": "Decline the invitation", "skill_check": "", "difficulty": 0}
	]
	guild_invitation.consequences = {
		"join": {"guild_membership": 1, "craft_reputation": 20, "gold": - 50},
		"negotiate": {"guild_membership": 1, "craft_reputation": 25, "gold": - 25},
		"decline": {"craft_reputation": - 5}
	}
	guild_invitation.duration_hours = 1
	guild_invitation.cooldown_days = 90
	events["guild_invitation"] = guild_invitation

func create_personal_events():
	"""Create personal random events"""
	var old_friend = RandomEvent.new("old_friend", "Old Friend", EventType.PERSONAL)
	old_friend.rarity = EventRarity.UNCOMMON
	old_friend.description = "You run into an old friend from your past."
	old_friend.choices = [
		{"id": "catch_up", "description": "Catch up with them", "skill_check": "persuasion", "difficulty": 10},
		{"id": "ask_favor", "description": "Ask for a favor", "skill_check": "persuasion", "difficulty": 14},
		{"id": "avoid", "description": "Avoid the encounter", "skill_check": "stealth", "difficulty": 12}
	]
	old_friend.consequences = {
		"catch_up": {"social_connections": 1, "charisma_exp": 10},
		"ask_favor": {"gold": 25, "social_connections": 1, "charisma_exp": 15},
		"avoid": {"charisma_exp": 5}
	}
	old_friend.duration_hours = 1
	old_friend.cooldown_days = 60
	events["old_friend"] = old_friend

func create_community_events():
	"""Create community random events"""
	var festival = RandomEvent.new("festival", "Town Festival", EventType.COMMUNITY)
	festival.rarity = EventRarity.UNCOMMON
	festival.description = "The town is holding a festival with games, food, and entertainment."
	festival.choices = [
		{"id": "participate", "description": "Participate in festival activities", "skill_check": "performance", "difficulty": 12},
		{"id": "volunteer", "description": "Volunteer to help organize", "skill_check": "persuasion", "difficulty": 10},
		{"id": "enjoy", "description": "Simply enjoy the festival", "skill_check": "", "difficulty": 0}
	]
	festival.consequences = {
		"participate": {"town_reputation": 10, "gold": 15, "charisma_exp": 20},
		"volunteer": {"town_reputation": 20, "charisma_exp": 15},
		"enjoy": {"town_reputation": 5, "gold": - 5}
	}
	festival.duration_hours = 6
	festival.cooldown_days = 90
	events["festival"] = festival

func create_adventure_hook_events():
	"""Create adventure hook events"""
	var mysterious_map = RandomEvent.new("mysterious_map", "Mysterious Map", EventType.ADVENTURE_HOOK)
	mysterious_map.rarity = EventRarity.EPIC
	mysterious_map.description = "You find a mysterious map that seems to lead to hidden treasure."
	mysterious_map.choices = [
		{"id": "investigate", "description": "Investigate the map", "skill_check": "investigation", "difficulty": 16},
		{"id": "sell", "description": "Sell the map", "skill_check": "persuasion", "difficulty": 12},
		{"id": "ignore", "description": "Ignore the map", "skill_check": "", "difficulty": 0}
	]
	mysterious_map.consequences = {
		"investigate": {"adventure_hook": 1, "investigation_exp": 25},
		"sell": {"gold": 100, "merchant_reputation": 10},
		"ignore": {"gold": 0}
	}
	mysterious_map.duration_hours = 2
	mysterious_map.cooldown_days = 365
	events["mysterious_map"] = mysterious_map

func trigger_random_event(character: Character) -> RandomEvent:
	"""Trigger a random event for a character"""
	var available_events = get_available_events(character)
	if available_events.is_empty():
		return null

	# Weight events by rarity
	var weighted_events = []
	for event in available_events:
		var weight = get_event_weight(event.rarity)
		for i in range(weight):
			weighted_events.append(event)

	# Select random event
	var selected_event = weighted_events[randi() % weighted_events.size()]

	# Set cooldown
	if not event_cooldowns.has(character.name):
		event_cooldowns[character.name] = {}
	event_cooldowns[character.name][selected_event.id] = Time.get_unix_time_from_system() + (selected_event.cooldown_days * 24 * 60 * 60)

	# Add to active events
	active_events[character.name] = selected_event

	random_event_triggered.emit(selected_event, character)
	return selected_event

func get_available_events(character: Character) -> Array[RandomEvent]:
	"""Get events available to a character"""
	var available: Array[RandomEvent] = []

	for event in events.values():
		if can_trigger_event(character, event):
			available.append(event)

	return available

func can_trigger_event(character: Character, event: RandomEvent) -> bool:
	"""Check if an event can be triggered for a character"""
	# Check if event is on cooldown
	if event_cooldowns.has(character.name) and event_cooldowns[character.name].has(event.id):
		var cooldown_end = event_cooldowns[character.name][event.id]
		if Time.get_unix_time_from_system() < cooldown_end:
			return false

	# Check requirements
	for req_key in event.requirements.keys():
		var req_value = event.requirements[req_key]
		var char_value = character.get(req_key)
		if char_value < req_value:
			return false

	return true

func get_event_weight(rarity: EventRarity) -> int:
	"""Get weight for event selection based on rarity"""
	match rarity:
		EventRarity.COMMON:
			return 10
		EventRarity.UNCOMMON:
			return 5
		EventRarity.RARE:
			return 2
		EventRarity.EPIC:
			return 1
		EventRarity.LEGENDARY:
			return 1
		_:
			return 1

func make_event_choice(character: Character, event: RandomEvent, choice_id: String) -> EventOutcome:
	"""Make a choice for a random event"""
	var choice_data = null
	for choice in event.choices:
		if choice["id"] == choice_id:
			choice_data = choice
			break

	if choice_data == null:
		return EventOutcome.FAILURE

	# Perform skill check if required
	var skill_check_result = 0
	if choice_data["skill_check"] != "":
		skill_check_result = perform_skill_check(character, choice_data["skill_check"], choice_data["difficulty"])

	# Apply consequences
	var consequences = event.consequences.get(choice_id, {})
	var outcome = apply_event_consequences(character, consequences, skill_check_result)

	# Remove from active events
	if active_events.has(character.name):
		active_events.erase(character.name)

	event_choice_made.emit(event, character, choice_id)
	event_resolved.emit(event, character, outcome)

	return outcome

func perform_skill_check(character: Character, skill: String, difficulty: int) -> int:
	"""Perform a skill check for an event"""
	# Simplified skill check - would integrate with proper skill system
	var ability_score = 10
	match skill:
		"athletics":
			ability_score = character.strength
		"persuasion":
			ability_score = character.charisma
		"insight":
			ability_score = character.wisdom
		"investigation":
			ability_score = character.intelligence
		"stealth":
			ability_score = character.dexterity
		"survival":
			ability_score = character.wisdom
		"constitution":
			ability_score = character.constitution
		"performance":
			ability_score = character.charisma

	var roll = randi() % 20 + 1
	var total = roll + character.get_ability_modifier(ability_score)

	if total >= difficulty:
		return total - difficulty # Success margin
	else:
		return - (difficulty - total) # Failure margin

func apply_event_consequences(character: Character, consequences: Dictionary, skill_check_result: int) -> EventOutcome:
	"""Apply consequences of an event choice"""
	var outcome = EventOutcome.NEUTRAL

	for consequence_type in consequences.keys():
		var amount = consequences[consequence_type]

		# Modify amount based on skill check result
		if skill_check_result > 0:
			amount = int(amount * (1.0 + skill_check_result * 0.1))
		elif skill_check_result < 0:
			amount = int(amount * (1.0 + skill_check_result * 0.1))

		# Apply consequence
		match consequence_type:
			"gold":
				if amount > 0:
					character.add_gold(amount)
					outcome = EventOutcome.SUCCESS
				else:
					character.spend_gold(-amount)
					outcome = EventOutcome.FAILURE
			"hit_points":
				character.hit_points = max(0, character.hit_points + amount)
				if amount < 0:
					outcome = EventOutcome.FAILURE
		"charisma_exp", "constitution_exp", "investigation_exp", "combat_exp":
			var exp_type = consequence_type.replace("_exp", "_experience")
			character.set(exp_type, character.get(exp_type) + amount)
			outcome = EventOutcome.SUCCESS
			"town_reputation", "noble_reputation", "guard_reputation", "merchant_reputation", "craft_reputation":
				var faction_name = consequence_type.replace("_reputation", "")
				if faction_name == "town":
					faction_name = "Town"
				elif faction_name == "noble":
					faction_name = "Lord's Alliance"
				elif faction_name == "guard":
					faction_name = "Town Guard"
				elif faction_name == "merchant":
					faction_name = "Merchant Guild"
				elif faction_name == "craft":
					faction_name = "Craftsman Guild"

				if not character.faction_reputation.has(faction_name):
					character.faction_reputation[faction_name] = 0
				character.faction_reputation[faction_name] += amount
				outcome = EventOutcome.SUCCESS
		"social_connections", "political_connections", "mystical_knowledge", "political_knowledge", "adventure_hook", "guild_membership":
			if not character.has_method("add_" + consequence_type):
				character.set(consequence_type, character.get(consequence_type) + amount)
			outcome = EventOutcome.SUCCESS
			"inventory":
				# Would integrate with inventory system
				pass

	return outcome

func get_active_event(character: Character) -> RandomEvent:
	"""Get character's active event"""
	return active_events.get(character.name, null)

func get_event_history(character: Character) -> Array:
	"""Get character's event history"""
	return event_history.get(character.name, [])
