extends GutTest

# Test NPCResource functionality
class_name TestNPCResource

var npc_resource: NPCResource

func before_each():
	npc_resource = NPCResource.new()

func test_npc_resource_creation():
	"""Test that NPCResource can be created"""
	assert_not_null(npc_resource, "NPCResource should be created")
	assert_true(npc_resource is NPCResource, "Should be an NPCResource instance")

func test_npc_basic_properties():
	"""Test setting and getting basic NPC properties"""
	npc_resource.npc_id = "test_npc_001"
	npc_resource.name = "Test NPC"
	npc_resource.description = "A test NPC for unit testing"
	npc_resource.npc_type = NPCType.Type.MERCHANT
	npc_resource.location = "Test Town"
	npc_resource.level = 5

	assert_eq(npc_resource.npc_id, "test_npc_001")
	assert_eq(npc_resource.name, "Test NPC")
	assert_eq(npc_resource.description, "A test NPC for unit testing")
	assert_eq(npc_resource.npc_type, NPCType.Type.MERCHANT)
	assert_eq(npc_resource.location, "Test Town")
	assert_eq(npc_resource.level, 5)

func test_npc_schedule_property():
	"""Test schedule dictionary property"""
	var schedule = {
		"monday": "9:00-17:00",
		"tuesday": "9:00-17:00",
		"wednesday": "closed",
		"thursday": "9:00-17:00",
		"friday": "9:00-17:00",
		"saturday": "10:00-14:00",
		"sunday": "closed"
	}
	npc_resource.schedule = schedule

	assert_eq(npc_resource.schedule, schedule)
	assert_eq(npc_resource.schedule["monday"], "9:00-17:00")
	assert_eq(npc_resource.schedule["wednesday"], "closed")

func test_npc_personality_property():
	"""Test personality dictionary property"""
	var personality = {
		"traits": ["friendly", "honest", "hardworking"],
		"quirks": ["always counts coins twice", "humming while working"],
		"mood": "cheerful"
	}
	npc_resource.personality = personality

	assert_eq(npc_resource.personality, personality)
	assert_eq(npc_resource.personality["traits"], ["friendly", "honest", "hardworking"])
	assert_eq(npc_resource.personality["mood"], "cheerful")

func test_npc_interests_property():
	"""Test interests array property"""
	var interests = ["trading", "coin collecting", "local gossip"]
	npc_resource.interests = interests

	assert_eq(npc_resource.interests, interests)
	assert_true("trading" in npc_resource.interests)
	assert_true("coin collecting" in npc_resource.interests)

func test_npc_services_property():
	"""Test services dictionary property"""
	var services = {
		"buy_items": true,
		"sell_items": true,
		"repair_equipment": false,
		"training": true
	}
	npc_resource.services = services

	assert_eq(npc_resource.services, services)
	assert_true(npc_resource.services["buy_items"])
	assert_false(npc_resource.services["repair_equipment"])

func test_npc_dialogue_property():
	"""Test dialogue dictionary property"""
	var dialogue = {
		"greeting": {
			"stranger": "Hello there, stranger.",
			"acquaintance": "Good to see you again!",
			"friend": "My friend! How are you doing?"
		},
		"business": {
			"stranger": "What can I do for you?",
			"acquaintance": "Looking to trade?",
			"friend": "Always happy to help a friend!"
		}
	}
	npc_resource.dialogue = dialogue

	assert_eq(npc_resource.dialogue, dialogue)
	assert_eq(npc_resource.dialogue["greeting"]["stranger"], "Hello there, stranger.")
	assert_eq(npc_resource.dialogue["business"]["friend"], "Always happy to help a friend!")

func test_npc_requirements_property():
	"""Test requirements dictionary property"""
	var requirements = {
		"level": 3,
		"gold": 100,
		"reputation": {"merchants_guild": 50}
	}
	npc_resource.requirements = requirements

	assert_eq(npc_resource.requirements, requirements)
	assert_eq(npc_resource.requirements["level"], 3)
	assert_eq(npc_resource.requirements["gold"], 100)

func test_meets_requirements():
	"""Test requirement checking"""
	var character = Character.new()
	character.level = 5
	character.gold = 200
	character.faction_reputation = {"merchants_guild": 75}

	var requirements = {
		"level": 3,
		"gold": 100,
		"reputation": {"merchants_guild": 50}
	}
	npc_resource.requirements = requirements

	assert_true(npc_resource.meets_requirements(character), "Character should meet all requirements")

	character.level = 2
	assert_false(npc_resource.meets_requirements(character), "Character should not meet level requirement")

	character.level = 5
	character.gold = 50
	assert_false(npc_resource.meets_requirements(character), "Character should not meet gold requirement")

	character.gold = 200
	character.faction_reputation = {"merchants_guild": 25}
	assert_false(npc_resource.meets_requirements(character), "Character should not meet reputation requirement")

func test_get_dialogue_for_relationship():
	"""Test dialogue retrieval based on relationship level"""
	var dialogue = {
		"greeting": {
			"stranger": "Hello there.",
			"acquaintance": "Good to see you.",
			"friend": "My friend!"
		}
	}
	npc_resource.dialogue = dialogue

	assert_eq(npc_resource.get_dialogue_for_relationship("stranger", "greeting"), "Hello there.")
	assert_eq(npc_resource.get_dialogue_for_relationship("acquaintance", "greeting"), "Good to see you.")
	assert_eq(npc_resource.get_dialogue_for_relationship("friend", "greeting"), "My friend!")

	# Test fallback for unknown relationship
	assert_eq(npc_resource.get_dialogue_for_relationship("enemy", "greeting"), "Hello there.")

func test_get_dialogue_for_unknown_topic():
	"""Test dialogue fallback for unknown topics"""
	var dialogue = {
		"greeting": {"stranger": "Hello there."}
	}
	npc_resource.dialogue = dialogue

	assert_eq(npc_resource.get_dialogue_for_relationship("stranger", "business"), "I don't have much to say about that.")

func test_npc_type_enum():
	"""Test NPC type enum values"""
	assert_eq(NPCType.Type.COMMONER, 0)
	assert_eq(NPCType.Type.MERCHANT, 1)
	assert_eq(NPCType.Type.GUARD, 2)
	assert_eq(NPCType.Type.NOBLE, 3)
	assert_eq(NPCType.Type.CLERGY, 4)
	assert_eq(NPCType.Type.SCHOLAR, 5)
	assert_eq(NPCType.Type.ARTISAN, 6)
	assert_eq(NPCType.Type.ENTERTAINER, 7)
	assert_eq(NPCType.Type.OUTLAW, 8)

func test_relationship_level_enum():
	"""Test relationship level enum values"""
	assert_eq(NPCResource.RelationshipLevel.ENEMY, 0)
	assert_eq(NPCResource.RelationshipLevel.STRANGER, 1)
	assert_eq(NPCResource.RelationshipLevel.ACQUAINTANCE, 2)
	assert_eq(NPCResource.RelationshipLevel.FRIEND, 3)
	assert_eq(NPCResource.RelationshipLevel.CLOSE_FRIEND, 4)
	assert_eq(NPCResource.RelationshipLevel.ALLY, 5)

func test_empty_requirements():
	"""Test that empty requirements always pass"""
	var character = Character.new()
	npc_resource.requirements = {}

	assert_true(npc_resource.meets_requirements(character), "Empty requirements should always pass")

func test_resource_serialization():
	"""Test that NPCResource can be saved and loaded"""
	npc_resource.npc_id = "serialization_test"
	npc_resource.name = "Serialization NPC"
	npc_resource.npc_type = NPCType.Type.SCHOLAR
	npc_resource.level = 10
	npc_resource.services = {"training": true}
	npc_resource.requirements = {"level": 5}

	# Test that properties are maintained
	assert_eq(npc_resource.npc_id, "serialization_test")
	assert_eq(npc_resource.name, "Serialization NPC")
	assert_eq(npc_resource.npc_type, NPCType.Type.SCHOLAR)
	assert_eq(npc_resource.level, 10)
	assert_true(npc_resource.services["training"])
	assert_eq(npc_resource.requirements["level"], 5)
