extends Node

# Comprehensive faction system with reputation tracking and relationships

class_name FactionSystem

signal reputation_changed(faction: String, new_reputation: int)
signal faction_relationship_changed(faction1: String, faction2: String, relationship: String)
signal faction_quest_completed(faction: String, quest: String, reputation_gained: int)

# Faction data structure
class Faction extends RefCounted:
	var name: String
	var description: String
	var alignment: String  # "lawful_good", "chaotic_evil", etc.
	var primary_goals: Array[String]
	var headquarters: String
	var leader: String
	var membership_requirements: Array[String]
	var benefits: Dictionary  # Benefits for different reputation levels
	var quests: Array[String]  # Available quests
	var relationships: Dictionary  # Relationships with other factions

	func _init(faction_name: String):
		name = faction_name
		description = ""
		alignment = "neutral"
		primary_goals = []
		headquarters = ""
		leader = ""
		membership_requirements = []
		benefits = {}
		quests = []
		relationships = {}

# Reputation levels
enum ReputationLevel {
	HOSTILE = -100,      # -100 to -51
	UNFRIENDLY = -50,    # -50 to -21
	NEUTRAL = -20,       # -20 to 20
	FRIENDLY = 21,       # 21 to 50
	HONORED = 51,        # 51 to 80
	EXALTED = 81         # 81 to 100
}

# Relationship types
enum RelationshipType {
	ALLIED,
	FRIENDLY,
	NEUTRAL,
	UNFRIENDLY,
	HOSTILE,
	WAR
}

var factions: Dictionary = {}
var character_reputation: Dictionary = {}  # Character's reputation with each faction
var character_faction_membership: Array[String] = []  # Factions the character belongs to

func _init():
	setup_default_factions()

func setup_default_factions():
	"""Initialize default D&D factions"""
	create_faction("Harpers", "A secret organization dedicated to preserving knowledge and fighting evil")
	create_faction("Zhentarim", "A mercenary organization focused on profit and power")
	create_faction("Emerald Enclave", "Druids and rangers protecting nature")
	create_faction("Lord's Alliance", "Nobles and rulers maintaining order")
	create_faction("Order of the Gauntlet", "Paladins and clerics fighting evil")

	# Set up faction details
	setup_harper_faction()
	setup_zhentarim_faction()
	setup_emerald_enclave_faction()
	setup_lords_alliance_faction()
	setup_order_gauntlet_faction()

	# Set up relationships
	setup_faction_relationships()

func create_faction(faction_name: String, description: String) -> Faction:
	"""Create a new faction"""
	var faction = Faction.new(faction_name)
	faction.description = description
	factions[faction_name] = faction
	character_reputation[faction_name] = 0  # Start at neutral
	return faction

func setup_harper_faction():
	"""Setup Harper faction details"""
	var harpers = factions.get("Harpers")
	if not harpers:
		print("Warning: Harpers faction not found")
		return

	harpers.alignment = "chaotic_good"
	harpers.primary_goals = ["Preserve knowledge", "Fight tyranny", "Protect the innocent"] as Array[String]
	harpers.headquarters = "Twilight Hall, Berdusk"
	harpers.leader = "Remallia Haventree"
	harpers.membership_requirements = ["Good alignment", "Dedication to justice"] as Array[String]
	harpers.benefits = {
		"friendly": ["Access to safe houses", "Information network"],
		"honored": ["Magical assistance", "Training opportunities"],
		"exalted": ["Leadership position", "Special missions"]
	}
	harpers.quests = ["Investigate corruption", "Protect scholars", "Gather intelligence"] as Array[String]

func setup_zhentarim_faction():
	"""Setup Zhentarim faction details"""
	var zhentarim = factions.get("Zhentarim")
	if not zhentarim:
		print("Warning: Zhentarim faction not found")
		return

	zhentarim.alignment = "lawful_evil"
	zhentarim.primary_goals = ["Accumulate power", "Control trade routes", "Eliminate rivals"] as Array[String]
	zhentarim.headquarters = "Darkhold"
	zhentarim.leader = "Manshoon"
	zhentarim.membership_requirements = ["Proven loyalty", "Useful skills"] as Array[String]
	zhentarim.benefits = {
		"friendly": ["Mercenary contracts", "Black market access"],
		"honored": ["Weapon training", "Assassination contracts"],
		"exalted": ["Territory control", "High-value missions"]
	}
	zhentarim.quests = ["Eliminate rivals", "Secure trade routes", "Gather blackmail"] as Array[String]

func setup_emerald_enclave_faction():
	"""Setup Emerald Enclave faction details"""
	var enclave = factions.get("Emerald Enclave")
	if not enclave:
		print("Warning: Emerald Enclave faction not found")
		return

	enclave.alignment = "neutral_good"
	enclave.primary_goals = ["Protect nature", "Balance civilization and wilderness", "Fight unnatural threats"] as Array[String]
	enclave.headquarters = "Goldenfields"
	enclave.leader = "Omin Dran"
	enclave.membership_requirements = ["Nature affinity", "Wilderness survival skills"] as Array[String]
	enclave.benefits = {
		"friendly": ["Nature magic training", "Wilderness supplies"],
		"honored": ["Druid spells", "Animal companions"],
		"exalted": ["Sacred grove access", "Elemental allies"]
	}
	enclave.quests = ["Protect sacred sites", "Fight unnatural creatures", "Restore balance"] as Array[String]

func setup_lords_alliance_faction():
	"""Setup Lord's Alliance faction details"""
	var alliance = factions.get("Lord's Alliance")
	if not alliance:
		print("Warning: Lord's Alliance faction not found")
		return

	alliance.alignment = "lawful_good"
	alliance.primary_goals = ["Maintain order", "Protect civilization", "Foster trade"] as Array[String]
	alliance.headquarters = "Waterdeep"
	alliance.leader = "Dagult Neverember"
	alliance.membership_requirements = ["Noble birth or proven service", "Lawful alignment"] as Array[String]
	alliance.benefits = {
		"friendly": ["Legal protection", "Trade privileges"],
		"honored": ["Noble titles", "Land grants"],
		"exalted": ["Council position", "Royal audience"]
	}
	alliance.quests = ["Enforce laws", "Protect trade routes", "Diplomatic missions"] as Array[String]

func setup_order_gauntlet_faction():
	"""Setup Order of the Gauntlet faction details"""
	var order = factions.get("Order of the Gauntlet")
	if not order:
		print("Warning: Order of the Gauntlet faction not found")
		return

	order.alignment = "lawful_good"
	order.primary_goals = ["Fight evil", "Protect the innocent", "Uphold justice"] as Array[String]
	order.headquarters = "Summit Hall"
	order.leader = "Ontharr Frume"
	order.membership_requirements = ["Good alignment", "Combat training", "Divine connection"] as Array[String]
	order.benefits = {
		"friendly": ["Divine blessings", "Combat training"],
		"honored": ["Sacred weapons", "Divine spells"],
		"exalted": ["Paladin training", "Divine intervention"]
	}
	order.quests = ["Smite evil", "Protect temples", "Investigate corruption"] as Array[String]

func setup_faction_relationships():
	"""Setup relationships between factions"""
	# Harpers vs Zhentarim (hostile)
	factions["Harpers"].relationships["Zhentarim"] = RelationshipType.HOSTILE
	factions["Zhentarim"].relationships["Harpers"] = RelationshipType.HOSTILE

	# Lord's Alliance vs Zhentarim (unfriendly)
	factions["Lord's Alliance"].relationships["Zhentarim"] = RelationshipType.UNFRIENDLY
	factions["Zhentarim"].relationships["Lord's Alliance"] = RelationshipType.UNFRIENDLY

	# Order of the Gauntlet vs Zhentarim (hostile)
	factions["Order of the Gauntlet"].relationships["Zhentarim"] = RelationshipType.HOSTILE
	factions["Zhentarim"].relationships["Order of the Gauntlet"] = RelationshipType.HOSTILE

	# Harpers and Lord's Alliance (friendly)
	factions["Harpers"].relationships["Lord's Alliance"] = RelationshipType.FRIENDLY
	factions["Lord's Alliance"].relationships["Harpers"] = RelationshipType.FRIENDLY

	# Order of the Gauntlet and Lord's Alliance (allied)
	factions["Order of the Gauntlet"].relationships["Lord's Alliance"] = RelationshipType.ALLIED
	factions["Lord's Alliance"].relationships["Order of the Gauntlet"] = RelationshipType.ALLIED

	# Emerald Enclave (neutral with most)
	for faction_name in factions:
		if faction_name != "Emerald Enclave":
			factions["Emerald Enclave"].relationships[faction_name] = RelationshipType.NEUTRAL
			factions[faction_name].relationships["Emerald Enclave"] = RelationshipType.NEUTRAL

func get_reputation_level(reputation: int) -> ReputationLevel:
	"""Get reputation level from reputation score"""
	if reputation >= 81:
		return ReputationLevel.EXALTED
	elif reputation >= 51:
		return ReputationLevel.HONORED
	elif reputation >= 21:
		return ReputationLevel.FRIENDLY
	elif reputation >= -20:
		return ReputationLevel.NEUTRAL
	elif reputation >= -50:
		return ReputationLevel.UNFRIENDLY
	else:
		return ReputationLevel.HOSTILE

func get_reputation_level_name(reputation: int) -> String:
	"""Get reputation level name from reputation score"""
	match get_reputation_level(reputation):
		ReputationLevel.EXALTED:
			return "Exalted"
		ReputationLevel.HONORED:
			return "Honored"
		ReputationLevel.FRIENDLY:
			return "Friendly"
		ReputationLevel.NEUTRAL:
			return "Neutral"
		ReputationLevel.UNFRIENDLY:
			return "Unfriendly"
		ReputationLevel.HOSTILE:
			return "Hostile"
		_:
			return "Unknown"

func change_reputation(faction: String, amount: int, _reason: String = ""):
	"""Change character's reputation with a faction"""
	if faction not in character_reputation:
		character_reputation[faction] = 0

	var old_reputation = character_reputation[faction]
	character_reputation[faction] = clamp(character_reputation[faction] + amount, -100, 100)
	var new_reputation = character_reputation[faction]

	# Check if reputation level changed
	var old_level = get_reputation_level(old_reputation)
	var new_level = get_reputation_level(new_reputation)

	if old_level != new_level:
		print("Reputation with %s changed from %s to %s" % [faction, get_reputation_level_name(old_reputation), get_reputation_level_name(new_reputation)])

	reputation_changed.emit(faction, new_reputation)

	# Check for faction membership eligibility
	check_faction_membership(faction)

func check_faction_membership(faction: String):
	"""Check if character can join a faction based on reputation"""
	if faction not in factions:
		return

	var _faction_data = factions[faction]
	var reputation = character_reputation[faction]
	var reputation_level = get_reputation_level(reputation)

	# Check if character meets requirements
	if can_join_faction(faction) and faction not in character_faction_membership:
		print("You are now eligible to join %s!" % faction)
	elif faction in character_faction_membership and reputation_level < ReputationLevel.FRIENDLY:
		print("Your reputation with %s has fallen too low. You are no longer a member." % faction)
		character_faction_membership.erase(faction)

func can_join_faction(faction: String) -> bool:
	"""Check if character can join a faction"""
	if faction not in factions:
		return false

	var _faction_data = factions[faction]
	var reputation = character_reputation[faction]
	var reputation_level = get_reputation_level(reputation)

	# Must be at least friendly to join
	if reputation_level < ReputationLevel.FRIENDLY:
		return false

	# Check other requirements (alignment, skills, etc.)
	# This would be implemented based on character data

	return true

func join_faction(faction: String) -> bool:
	"""Join a faction"""
	if not can_join_faction(faction):
		return false

	if faction not in character_faction_membership:
		character_faction_membership.append(faction)
		print("You have joined %s!" % faction)
		return true

	return false

func leave_faction(faction: String) -> bool:
	"""Leave a faction"""
	if faction in character_faction_membership:
		character_faction_membership.erase(faction)
		print("You have left %s." % faction)
		return true

	return false

func get_faction_benefits(faction: String) -> Array[String]:
	"""Get available benefits for a faction based on reputation"""
	if faction not in factions:
		return []

	var _faction_data = factions[faction]
	var reputation = character_reputation[faction]
	var reputation_level = get_reputation_level(reputation)
	var benefits = []

	# Add benefits based on reputation level
	if reputation_level >= ReputationLevel.FRIENDLY and "friendly" in _faction_data.benefits:
		benefits.append_array(_faction_data.benefits["friendly"])

	if reputation_level >= ReputationLevel.HONORED and "honored" in _faction_data.benefits:
		benefits.append_array(_faction_data.benefits["honored"])

	if reputation_level >= ReputationLevel.EXALTED and "exalted" in _faction_data.benefits:
		benefits.append_array(_faction_data.benefits["exalted"])

	return benefits

func get_available_quests(faction: String) -> Array[String]:
	"""Get available quests for a faction"""
	if faction not in factions:
		return []

	var _faction_data = factions[faction]
	var reputation = character_reputation[faction]
	var reputation_level = get_reputation_level(reputation)

	# Only show quests if reputation is at least neutral
	if reputation_level < ReputationLevel.NEUTRAL:
		return []

	return _faction_data.quests

func complete_faction_quest(faction: String, quest: String) -> int:
	"""Complete a faction quest and gain reputation"""
	if faction not in factions:
		return 0

	var reputation_gain = 0

	# Determine reputation gain based on quest type
	match quest:
		"Investigate corruption":
			reputation_gain = 10
		"Protect scholars":
			reputation_gain = 15
		"Gather intelligence":
			reputation_gain = 8
		"Eliminate rivals":
			reputation_gain = 20
		"Secure trade routes":
			reputation_gain = 12
		"Gather blackmail":
			reputation_gain = 5
		"Protect sacred sites":
			reputation_gain = 18
		"Fight unnatural creatures":
			reputation_gain = 15
		"Restore balance":
			reputation_gain = 12
		"Enforce laws":
			reputation_gain = 10
		"Protect trade routes":
			reputation_gain = 8
		"Diplomatic missions":
			reputation_gain = 15
		"Smite evil":
			reputation_gain = 20
		"Protect temples":
			reputation_gain = 12
		"Investigate corruption":
			reputation_gain = 10
		_:
			reputation_gain = 5

	change_reputation(faction, reputation_gain, "Completed quest: " + quest)
	faction_quest_completed.emit(faction, quest, reputation_gain)

	return reputation_gain

func get_faction_relationship(faction1: String, faction2: String) -> RelationshipType:
	"""Get relationship between two factions"""
	if faction1 not in factions or faction2 not in factions:
		return RelationshipType.NEUTRAL

	return factions[faction1].relationships.get(faction2, RelationshipType.NEUTRAL)

func get_relationship_name(relationship: RelationshipType) -> String:
	"""Get relationship name from relationship type"""
	match relationship:
		RelationshipType.ALLIED:
			return "Allied"
		RelationshipType.FRIENDLY:
			return "Friendly"
		RelationshipType.NEUTRAL:
			return "Neutral"
		RelationshipType.UNFRIENDLY:
			return "Unfriendly"
		RelationshipType.HOSTILE:
			return "Hostile"
		RelationshipType.WAR:
			return "At War"
		_:
			return "Unknown"

func get_faction_summary() -> Dictionary:
	"""Get summary of all faction relationships and reputation"""
	var summary = {
		"reputation": character_reputation.duplicate(),
		"memberships": character_faction_membership.duplicate(),
		"factions": {}
	}

	for faction_name in factions:
		var _faction_data = factions[faction_name]
		summary["factions"][faction_name] = {
			"reputation": character_reputation[faction_name],
			"reputation_level": get_reputation_level_name(character_reputation[faction_name]),
			"benefits": get_faction_benefits(faction_name),
			"quests": get_available_quests(faction_name),
			"is_member": faction_name in character_faction_membership
		}

	return summary
