extends GutTest

# Comprehensive test for NPCSystem
class_name TestNPCSystemComprehensive

var npc_system: NPCSystem
var npc_data_manager: NPCDataManager
var npc_interactions: NPCInteractions
var test_character: Character

func before_each():
	npc_system = NPCSystem.new()
	npc_data_manager = NPCDataManager.new()
	npc_interactions = NPCInteractions.new()
	test_character = Character.new()
	test_character.name = "TestCharacter"
	test_character.level = 5
	test_character.gold = 1000

func test_npc_system_creation():
	"""Test that NPCSystem can be created"""
	assert_not_null(npc_system, "NPCSystem should be created")
	assert_true(npc_system is NPCSystem, "Should be an NPCSystem instance")

func test_npc_data_manager_creation():
	"""Test that NPCDataManager can be created"""
	assert_not_null(npc_data_manager, "NPCDataManager should be created")
	assert_true(npc_data_manager is NPCDataManager, "Should be an NPCDataManager instance")

func test_npc_interactions_creation():
	"""Test that NPCInteractions can be created"""
	assert_not_null(npc_interactions, "NPCInteractions should be created")
	assert_true(npc_interactions is NPCInteractions, "Should be an NPCInteractions instance")

func test_create_npc():
	"""Test creating a new NPC"""
	var npc_data = {
		"name": "Test NPC",
		"description": "A test NPC for unit testing",
		"npc_type": "merchant",
		"location": "Test Town",
		"level": 5,
		"schedule": {
			"monday": "9:00-17:00",
			"tuesday": "9:00-17:00",
			"wednesday": "closed"
		},
		"personality": {
			"traits": ["friendly", "honest"],
			"mood": "cheerful"
		},
		"services": {
			"buy_items": true,
			"sell_items": true,
			"training": false
		},
		"dialogue": {
			"greeting": {
				"stranger": "Hello there, stranger.",
				"friend": "Good to see you again!"
			}
		},
		"requirements": {
			"level": 3,
			"gold": 100
		}
	}

	var npc = npc_data_manager.create_npc_from_data("test_npc_001", npc_data)

	assert_not_null(npc, "NPC should be created")
	assert_true(npc is NPCResource, "Should be an NPCResource instance")
	assert_eq(npc.npc_id, "test_npc_001")
	assert_eq(npc.name, "Test NPC")
	assert_eq(npc.npc_type, NPCType.Type.MERCHANT)

func test_npc_interaction():
	"""Test NPC interaction system"""
	var npc_data = {
		"name": "Interaction Test NPC",
		"description": "Test NPC for interactions",
		"npc_type": "merchant",
		"location": "Test Town",
		"level": 3,
		"dialogue": {
			"greeting": {
				"stranger": "Hello there!",
				"friend": "My friend!"
			}
		},
		"requirements": {}
	}

	var npc = npc_data_manager.create_npc_from_data("interaction_npc_001", npc_data)

	# Test greeting interaction
	var result = npc_interactions.interact_with_npc(test_character, npc.npc_id, "greeting")

	assert_true(result["success"], "Should successfully interact with NPC")
	assert_true(result.has("message"), "Should have interaction message")
	assert_true(result.has("relationship_change"), "Should have relationship change")

func test_npc_relationship_system():
	"""Test NPC relationship system"""
	var npc_data = {
		"name": "Relationship Test NPC",
		"description": "Test NPC for relationships",
		"npc_type": "commoner",
		"location": "Test Town",
		"level": 1,
		"dialogue": {
			"greeting": {
				"stranger": "Hello.",
				"acquaintance": "Good to see you.",
				"friend": "My friend!"
			}
		},
		"requirements": {}
	}

	var npc = npc_data_manager.create_npc_from_data("relationship_npc_001", npc_data)

	# Test initial relationship
	var initial_relationship = npc_interactions.get_relationship(test_character, npc)
	assert_eq(initial_relationship, 0, "Initial relationship should be 0")

	# Test relationship improvement
	npc_interactions.update_relationship(test_character, npc, 10)
	var new_relationship = npc_interactions.get_relationship(test_character, npc)
	assert_eq(new_relationship, 10, "Relationship should improve")

	# Test relationship deterioration
	npc_interactions.update_relationship(test_character, npc, -5)
	var final_relationship = npc_interactions.get_relationship(test_character, npc)
	assert_eq(final_relationship, 5, "Relationship should decrease")

func test_npc_requirements():
	"""Test NPC requirement checking"""
	var npc_data = {
		"name": "Requirement Test NPC",
		"description": "Test NPC for requirements",
		"npc_type": "scholar",
		"location": "Test Town",
		"level": 10,
		"requirements": {
			"level": 8,
			"gold": 500,
			"reputation": {
				"scholars_guild": 50
			}
		}
	}

	test_character.level = 5
	test_character.gold = 200
	test_character.faction_reputation = {"scholars_guild": 25}

	var npc = npc_data_manager.create_npc_from_data("requirement_npc_001", npc_data)

	# Test requirement checking
	var meets_requirements = npc_interactions.meets_npc_requirements(test_character, npc)
	assert_false(meets_requirements, "Should not meet requirements")

	# Meet requirements
	test_character.level = 10
	test_character.gold = 1000
	test_character.faction_reputation = {"scholars_guild": 75}

	meets_requirements = npc_interactions.meets_npc_requirements(test_character, npc)
	assert_true(meets_requirements, "Should meet requirements")

func test_npc_services():
	"""Test NPC service system"""
	var npc_data = {
		"name": "Service Test NPC",
		"description": "Test NPC for services",
		"npc_type": "merchant",
		"location": "Test Town",
		"level": 5,
		"services": {
			"buy_items": true,
			"sell_items": true,
			"repair_equipment": true,
			"training": false
		},
		"requirements": {}
	}

	var npc = npc_data_manager.create_npc_from_data("service_npc_001", npc_data)

	# Test service availability
	assert_true(npc.services["buy_items"], "Should have buy_items service")
	assert_true(npc.services["sell_items"], "Should have sell_items service")
	assert_true(npc.services["repair_equipment"], "Should have repair_equipment service")
	assert_false(npc.services["training"], "Should not have training service")

func test_npc_dialogue_system():
	"""Test NPC dialogue system"""
	var npc_data = {
		"name": "Dialogue Test NPC",
		"description": "Test NPC for dialogue",
		"npc_type": "commoner",
		"location": "Test Town",
		"level": 3,
		"dialogue": {
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
		},
		"requirements": {}
	}

	var npc = npc_data_manager.create_npc_from_data("dialogue_npc_001", npc_data)

	# Test dialogue retrieval
	var greeting = npc.get_dialogue_for_relationship("stranger", "greeting")
	assert_eq(greeting, "Hello there, stranger.", "Should return correct greeting")

	var business = npc.get_dialogue_for_relationship("friend", "business")
	assert_eq(business, "Always happy to help a friend!", "Should return correct business dialogue")

func test_npc_schedule_system():
	"""Test NPC schedule system"""
	var npc_data = {
		"name": "Schedule Test NPC",
		"description": "Test NPC for schedules",
		"npc_type": "merchant",
		"location": "Test Town",
		"level": 4,
		"schedule": {
			"monday": "9:00-17:00",
			"tuesday": "9:00-17:00",
			"wednesday": "closed",
			"thursday": "9:00-17:00",
			"friday": "9:00-17:00",
			"saturday": "10:00-14:00",
			"sunday": "closed"
		},
		"requirements": {}
	}

	var npc = npc_data_manager.create_npc_from_data("schedule_npc_001", npc_data)

	# Test schedule checking
	assert_eq(npc.schedule["monday"], "9:00-17:00", "Should have correct Monday schedule")
	assert_eq(npc.schedule["wednesday"], "closed", "Should be closed on Wednesday")
	assert_eq(npc.schedule["saturday"], "10:00-14:00", "Should have limited Saturday hours")

func test_npc_personality_system():
	"""Test NPC personality system"""
	var npc_data = {
		"name": "Personality Test NPC",
		"description": "Test NPC for personality",
		"npc_type": "entertainer",
		"location": "Test Town",
		"level": 3,
		"personality": {
			"traits": ["charismatic", "optimistic", "creative"],
			"quirks": ["always humming", "taps fingers when thinking"],
			"mood": "cheerful",
			"fears": ["silence", "boredom"],
			"interests": ["music", "dancing", "storytelling"]
		},
		"requirements": {}
	}

	var npc = npc_data_manager.create_npc_from_data("personality_npc_001", npc_data)

	# Test personality traits
	assert_true("charismatic" in npc.personality["traits"], "Should have charismatic trait")
	assert_true("optimistic" in npc.personality["traits"], "Should have optimistic trait")
	assert_eq(npc.personality["mood"], "cheerful", "Should have cheerful mood")
	assert_true("music" in npc.personality["interests"], "Should be interested in music")

func test_npc_social_events():
	"""Test NPC social event system"""
	var npc_data = {
		"name": "Social Event Test NPC",
		"description": "Test NPC for social events",
		"npc_type": "noble",
		"location": "Test Town",
		"level": 8,
		"social_events": [
			{
				"id": "party_001",
				"name": "Noble Party",
				"type": "celebration",
				"frequency": "monthly",
				"requirements": {"reputation": 50}
			}
		],
		"requirements": {}
	}

	var npc = npc_data_manager.create_npc_from_data("social_npc_001", npc_data)

	# Test social event availability
	var social_events = npc.social_events
	assert_gt(social_events.size(), 0, "Should have social events")

	var party_event = social_events[0]
	assert_eq(party_event["name"], "Noble Party", "Should have correct event name")
	assert_eq(party_event["type"], "celebration", "Should have correct event type")

func test_npc_system_integration():
	"""Test NPC system integration with other systems"""
	var npc_data = {
		"name": "Integration Test NPC",
		"description": "Test NPC for system integration",
		"npc_type": "merchant",
		"location": "Test Town",
		"level": 5,
		"services": {
			"buy_items": true,
			"sell_items": true
		},
		"requirements": {}
	}

	var npc = npc_data_manager.create_npc_from_data("integration_npc_001", npc_data)

	# Test with faction system
	var faction_system = FactionSystem.new()
	faction_system.add_reputation(test_character, "merchants_guild", 50)

	var faction_npcs = npc_data_manager.get_npcs_by_faction("merchants_guild")
	assert_gt(faction_npcs.size(), 0, "Should have faction NPCs")

	# Test with town system
	var town_system = TownSystem.new()
	var town_npcs = npc_data_manager.get_npcs_by_location("Test Town")
	assert_gt(town_npcs.size(), 0, "Should have town NPCs")

	# Test with quest system
	var quest_system = QuestSystem.new()
	var quest_givers = npc_data_manager.get_npcs_by_type(NPCType.Type.MERCHANT)
	assert_gt(quest_givers.size(), 0, "Should have quest giver NPCs")
