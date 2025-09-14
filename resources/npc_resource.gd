class_name NPCResource
extends Resource

# D&D NPC as a Godot Resource for better editor integration and type safety

# Use global NPCType enum from npc_type.gd

enum RelationshipLevel {
	HOSTILE = -2,
	UNFRIENDLY = -1,
	NEUTRAL = 0,
	FRIENDLY = 1,
	ALLIED = 2
}

@export var npc_id: String = ""
@export var name: String = ""
@export var description: String = ""
@export var npc_type: NPCType.Type = NPCType.Type.COMMONER
@export var location: String = ""
@export var level: int = 1

# Schedule and availability
@export var schedule: Dictionary = {}  # {"monday": {"start": 6, "end": 22}, ...}
@export var availability: String = "always"  # always, daytime, nighttime, specific_hours

# Personality and behavior
@export var personality: Dictionary = {}  # {"traits": [], "mood": "neutral", "attitude": "friendly"}
@export var interests: Array[String] = []
@export var dislikes: Array[String] = []
@export var fears: Array[String] = []

# Services and capabilities
@export var services: Array[String] = []  # ["buy", "sell", "train", "quest", "information"]
@export var quests: Array[String] = []  # Available quest IDs
@export var training_skills: Array[String] = []  # Skills this NPC can train
@export var items_for_sale: Array[String] = []  # Item IDs this NPC sells
@export var items_bought: Array[String] = []  # Item types this NPC buys

# Dialogue system
@export var dialogue: Dictionary = {}  # {"greeting": {}, "small_talk": {}, "business": {}, ...}
@export var dialogue_conditions: Dictionary = {}  # Conditions for different dialogue options
@export var relationship_dialogue: Dictionary = {}  # Dialogue based on relationship level

# Requirements and restrictions
@export var requirements: Dictionary = {}  # {"level": 5, "gold": 100, "reputation": "friendly"}
@export var restrictions: Dictionary = {}  # {"time": "daytime", "weather": "clear", "location": "tavern"}

# Combat and stats (for NPCs that can fight)
@export var combat_stats: Dictionary = {}  # {"hp": 50, "ac": 15, "attack": 5, "damage": "1d8+3"}
@export var combat_abilities: Array[String] = []
@export var loot_table: Dictionary = {}  # Items this NPC might drop

# Social and faction aspects
@export var faction: String = ""
@export var faction_rank: String = ""
@export var reputation_modifiers: Dictionary = {}  # How interactions affect faction reputation
@export var relationship_starting_value: int = 0  # Starting relationship level

# Visual and audio
@export var appearance: Dictionary = {}  # {"hair_color": "brown", "eye_color": "blue", "height": "medium"}
@export var voice_type: String = "normal"
@export var speech_pattern: String = "formal"  # formal, casual, rustic, scholarly, etc.

# Special abilities and features
@export var special_abilities: Array[String] = []
@export var unique_items: Array[String] = []  # Items only this NPC has
@export var knowledge_areas: Array[String] = []  # Topics this NPC knows about
@export var secrets: Array[String] = []  # Information this NPC might reveal

# Economic aspects
@export var wealth_level: String = "modest"  # poor, modest, wealthy, rich
@export var price_modifiers: Dictionary = {}  # {"buy_multiplier": 0.5, "sell_multiplier": 1.5}
@export var currency_preferences: Array[String] = ["gold"]  # Preferred currencies

# Relationship management
@export var relationship_decay_rate: float = 0.1  # How fast relationship deteriorates over time
@export var relationship_cap: int = 2  # Maximum relationship level
@export var relationship_minimum: int = -2  # Minimum relationship level

func get_npc_type_string() -> String:
	"""Get NPC type as string"""
	match npc_type:
		NPCType.Type.MERCHANT:
			return "Merchant"
		NPCType.Type.QUEST_GIVER:
			return "Quest Giver"
		NPCType.Type.TRAINER:
			return "Trainer"
		NPCType.Type.INNKEEPER:
			return "Innkeeper"
		NPCType.Type.BLACKSMITH:
			return "Blacksmith"
		NPCType.Type.LIBRARIAN:
			return "Librarian"
		NPCType.Type.GUARD:
			return "Guard"
		NPCType.Type.NOBLE:
			return "Noble"
		NPCType.Type.COMMONER:
			return "Commoner"
		NPCType.Type.ADVENTURER:
			return "Adventurer"
		NPCType.Type.CLERIC:
			return "Cleric"
		NPCType.Type.WIZARD:
			return "Wizard"
		NPCType.Type.ROGUE:
			return "Rogue"
		NPCType.Type.SOLDIER:
			return "Soldier"
		NPCType.Type.FARMER:
			return "Farmer"
		NPCType.Type.ARTISAN:
			return "Artisan"
		NPCType.Type.ENTERTAINER:
			return "Entertainer"
		NPCType.Type.HERMIT:
			return "Hermit"
		NPCType.Type.SAGE:
			return "Sage"
		NPCType.Type.CRIMINAL:
			return "Criminal"
		_:
			return "Unknown"

func is_available_at_time(hour: int) -> bool:
	"""Check if NPC is available at a specific hour"""
	if availability == "always":
		return true
	elif availability == "daytime":
		return hour >= 6 and hour <= 18
	elif availability == "nighttime":
		return hour < 6 or hour > 18
	elif availability == "specific_hours":
		# Check schedule for current day (simplified - would need day of week)
		if schedule.has("default"):
			var default_schedule = schedule["default"]
			if default_schedule.has("start") and default_schedule.has("end"):
				return hour >= default_schedule["start"] and hour <= default_schedule["end"]
	return true

func can_provide_service(service: String) -> bool:
	"""Check if NPC can provide a specific service"""
	return service in services

func can_train_skill(skill: String) -> bool:
	"""Check if NPC can train a specific skill"""
	return skill in training_skills

func get_dialogue_for_relationship(relationship_level: int, dialogue_type: String = "greeting") -> String:
	"""Get appropriate dialogue based on relationship level"""
	var dialogue_key = dialogue_type

	# Check for relationship-specific dialogue
	if relationship_dialogue.has(dialogue_key):
		var relationship_dialogue_data = relationship_dialogue[dialogue_key]

		match relationship_level:
			RelationshipLevel.HOSTILE:
				return relationship_dialogue_data.get("hostile", "I don't want to talk to you.")
			RelationshipLevel.UNFRIENDLY:
				return relationship_dialogue_data.get("unfriendly", "What do you want?")
			RelationshipLevel.NEUTRAL:
				return relationship_dialogue_data.get("neutral", "Hello.")
			RelationshipLevel.FRIENDLY:
				return relationship_dialogue_data.get("friendly", "Good to see you!")
			RelationshipLevel.ALLIED:
				return relationship_dialogue_data.get("allied", "My friend! How can I help?")

	# Fall back to regular dialogue
	if dialogue.has(dialogue_key):
		var dialogue_data = dialogue[dialogue_key]
		if dialogue_data is Dictionary:
			# Return first available dialogue option
			for key in dialogue_data.keys():
				return dialogue_data[key]
		elif dialogue_data is String:
			return dialogue_data

	return "Hello there."

func meets_requirements(character: Character) -> bool:
	"""Check if character meets NPC requirements"""
	if requirements.is_empty():
		return true

	for req_type in requirements.keys():
		var required_value = requirements[req_type]

		match req_type:
			"level":
				if character.level < required_value:
					return false
			"gold":
				if character.gold < required_value:
					return false
			"reputation":
				# Check faction reputation
				if character.faction_reputation.has(faction):
					var current_reputation = character.faction_reputation[faction]
					if current_reputation < required_value:
						return false
			"faction":
				# Check if character belongs to required faction
				if not character.faction_reputation.has(required_value):
					return false
			"quest_completed":
				# Check if character has completed required quest
				# This would integrate with quest system
				pass

	return true

func get_price_modifier(operation: String) -> float:
	"""Get price modifier for buy/sell operations"""
	if price_modifiers.has(operation + "_multiplier"):
		return price_modifiers[operation + "_multiplier"]

	# Default modifiers based on wealth level
	match wealth_level:
		"poor":
			return 0.8 if operation == "buy" else 1.2
		"modest":
			return 1.0
		"wealthy":
			return 1.1 if operation == "buy" else 0.9
		"rich":
			return 1.2 if operation == "buy" else 0.8

	return 1.0

func get_relationship_color(relationship_level: int) -> Color:
	"""Get color representing relationship level"""
	match relationship_level:
		RelationshipLevel.HOSTILE:
			return Color.RED
		RelationshipLevel.UNFRIENDLY:
			return Color.ORANGE
		RelationshipLevel.NEUTRAL:
			return Color.WHITE
		RelationshipLevel.FRIENDLY:
			return Color.GREEN
		RelationshipLevel.ALLIED:
			return Color.CYAN
		_:
			return Color.WHITE

func get_npc_type_color() -> Color:
	"""Get color representing NPC type"""
	match npc_type:
		NPCType.Type.MERCHANT:
			return Color.YELLOW
		NPCType.Type.QUEST_GIVER:
			return Color.BLUE
		NPCType.Type.TRAINER:
			return Color.PURPLE
		NPCType.Type.INNKEEPER:
			return Color.ORANGE
		NPCType.Type.BLACKSMITH:
			return Color.GRAY
		NPCType.Type.GUARD:
			return Color.RED
		NPCType.Type.NOBLE:
			return Color.GOLD
		NPCType.Type.CLERIC:
			return Color.WHITE
		NPCType.Type.WIZARD:
			return Color.PURPLE
		NPCType.Type.ROGUE:
			return Color.DARK_GRAY
		_:
			return Color.WHITE

func has_secret_information(topic: String) -> bool:
	"""Check if NPC has secret information about a topic"""
	return topic in secrets

func can_reveal_secret(character: Character, topic: String) -> bool:
	"""Check if NPC will reveal secret information to character"""
	if not has_secret_information(topic):
		return false

	# Check relationship requirements for revealing secrets
	# This would integrate with relationship system
	return true  # Simplified for now

func get_available_quests(character: Character) -> Array[String]:
	"""Get quests this NPC can offer to character"""
	var available_quests = []

	for quest_id in quests:
		# Check if character meets quest requirements
		# This would integrate with quest system
		available_quests.append(quest_id)

	return available_quests
