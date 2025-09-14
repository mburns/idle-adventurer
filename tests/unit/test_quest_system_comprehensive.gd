extends GutTest

# Comprehensive test for QuestSystem
class_name TestQuestSystemComprehensive

var quest_system: QuestSystem
var test_character: Character

func before_each():
	quest_system = QuestSystem.new()
	test_character = Character.new()
	test_character.name = "TestCharacter"
	test_character.level = 5
	test_character.gold = 1000

func test_quest_system_creation():
	"""Test that QuestSystem can be created"""
	assert_not_null(quest_system, "QuestSystem should be created")
	assert_true(quest_system is QuestSystem, "Should be a QuestSystem instance")

func test_create_quest():
	"""Test creating a new quest"""
	var quest_data = {
		"id": "test_quest_001",
		"title": "Test Quest",
		"description": "A test quest for unit testing",
		"type": "fetch",
		"level": 5,
		"rewards": {
			"gold": 100,
			"xp": 200,
			"items": ["healing_potion"]
		},
		"objectives": [
			{
				"id": "obj_001",
				"description": "Collect 5 test items",
				"type": "collect",
				"target": "test_item",
				"quantity": 5
			}
		]
	}

	var quest = quest_system.create_quest(quest_data)

	assert_not_null(quest, "Quest should be created")
	assert_eq(quest["id"], "test_quest_001")
	assert_eq(quest["title"], "Test Quest")
	assert_eq(quest["status"], "available")

func test_accept_quest():
	"""Test accepting a quest"""
	var quest_data = {
		"id": "accept_test_001",
		"title": "Accept Test Quest",
		"description": "Test accepting a quest",
		"level": 3,
		"rewards": {"gold": 50, "xp": 100},
		"objectives": []
	}

	var quest = quest_system.create_quest(quest_data)
	var result = quest_system.accept_quest(test_character, quest)

	assert_true(result["success"], "Should successfully accept quest")
	assert_eq(quest["status"], "active")
	assert_true(test_character.active_quests.has(quest["id"]))

func test_complete_quest_objective():
	"""Test completing quest objectives"""
	var quest_data = {
		"id": "objective_test_001",
		"title": "Objective Test Quest",
		"description": "Test completing objectives",
		"level": 4,
		"rewards": {"gold": 75, "xp": 150},
		"objectives": [
			{
				"id": "obj_001",
				"description": "Kill 3 goblins",
				"type": "kill",
				"target": "goblin",
				"quantity": 3,
				"completed": 0
			}
		]
	}

	var quest = quest_system.create_quest(quest_data)
	quest_system.accept_quest(test_character, quest)

	# Complete objective
	var result = quest_system.complete_objective(test_character, quest["id"], "obj_001", 3)

	assert_true(result["success"], "Should successfully complete objective")
	assert_eq(quest["objectives"][0]["completed"], 3, "Objective should be completed")

func test_complete_quest():
	"""Test completing an entire quest"""
	var quest_data = {
		"id": "complete_test_001",
		"title": "Complete Test Quest",
		"description": "Test completing a quest",
		"level": 2,
		"rewards": {
			"gold": 100,
			"xp": 200,
			"items": ["magic_sword"]
		},
		"objectives": [
			{
				"id": "obj_001",
				"description": "Simple objective",
				"type": "talk",
				"target": "npc",
				"quantity": 1,
				"completed": 1
			}
		]
	}

	var quest = quest_system.create_quest(quest_data)
	quest_system.accept_quest(test_character, quest)

	var initial_gold = test_character.gold
	var initial_xp = test_character.experience_points

	var result = quest_system.complete_quest(test_character, quest)

	assert_true(result["success"], "Should successfully complete quest")
	assert_eq(quest["status"], "completed")
	assert_eq(test_character.gold, initial_gold + 100, "Should receive gold reward")
	assert_eq(test_character.experience_points, initial_xp + 200, "Should receive XP reward")
	assert_false(test_character.active_quests.has(quest["id"]), "Quest should be removed from active quests")

func test_quest_requirements():
	"""Test quest requirement checking"""
	var quest_data = {
		"id": "requirement_test_001",
		"title": "Requirement Test Quest",
		"description": "Test quest requirements",
		"level": 10,
		"requirements": {
			"level": 8,
			"gold": 500,
			"faction_reputation": {
				"merchants_guild": 50
			}
		},
		"rewards": {"gold": 200, "xp": 400},
		"objectives": []
	}

	test_character.level = 5
	test_character.gold = 200
	test_character.faction_reputation = {"merchants_guild": 25}

	var quest = quest_system.create_quest(quest_data)
	var can_accept = quest_system.can_accept_quest(test_character, quest)

	assert_false(can_accept, "Should not be able to accept quest without meeting requirements")

	# Meet requirements
	test_character.level = 10
	test_character.gold = 1000
	test_character.faction_reputation = {"merchants_guild": 75}

	can_accept = quest_system.can_accept_quest(test_character, quest)
	assert_true(can_accept, "Should be able to accept quest when requirements are met")

func test_quest_types():
	"""Test different quest types"""
	var quest_types = ["fetch", "kill", "escort", "delivery", "exploration", "social"]

	for quest_type in quest_types:
		var quest_data = {
			"id": "type_test_" + quest_type,
			"title": "Type Test Quest",
			"description": "Test " + quest_type + " quest type",
			"type": quest_type,
			"level": 3,
			"rewards": {"gold": 50, "xp": 100},
			"objectives": []
		}

		var quest = quest_system.create_quest(quest_data)
		assert_eq(quest["type"], quest_type, "Quest type should be " + quest_type)

func test_quest_rewards():
	"""Test different types of quest rewards"""
	var quest_data = {
		"id": "reward_test_001",
		"title": "Reward Test Quest",
		"description": "Test quest rewards",
		"level": 5,
		"rewards": {
			"gold": 150,
			"xp": 300,
			"items": ["healing_potion", "magic_ring"],
			"faction_reputation": {
				"merchants_guild": 25
			}
		},
		"objectives": []
	}

	var quest = quest_system.create_quest(quest_data)
	quest_system.accept_quest(test_character, quest)

	var initial_gold = test_character.gold
	var initial_xp = test_character.experience_points
	var initial_reputation = test_character.faction_reputation.get("merchants_guild", 0)

	quest_system.complete_quest(test_character, quest)

	assert_eq(test_character.gold, initial_gold + 150, "Should receive gold reward")
	assert_eq(test_character.experience_points, initial_xp + 300, "Should receive XP reward")
	assert_eq(test_character.faction_reputation["merchants_guild"], initial_reputation + 25, "Should receive reputation reward")

func test_quest_chains():
	"""Test quest chains and dependencies"""
	var quest1_data = {
		"id": "chain_quest_001",
		"title": "First Quest in Chain",
		"description": "First quest",
		"level": 3,
		"rewards": {"gold": 50, "xp": 100},
		"objectives": [],
		"next_quest": "chain_quest_002"
	}

	var quest2_data = {
		"id": "chain_quest_002",
		"title": "Second Quest in Chain",
		"description": "Second quest",
		"level": 4,
		"rewards": {"gold": 75, "xp": 150},
		"objectives": [],
		"prerequisite_quest": "chain_quest_001"
	}

	var quest1 = quest_system.create_quest(quest1_data)
	var quest2 = quest_system.create_quest(quest2_data)

	# Complete first quest
	quest_system.accept_quest(test_character, quest1)
	quest_system.complete_quest(test_character, quest1)

	# Check if second quest is now available
	var available_quests = quest_system.get_available_quests(test_character)
	var quest2_available = false
	for quest in available_quests:
		if quest["id"] == "chain_quest_002":
			quest2_available = true
			break

	assert_true(quest2_available, "Second quest in chain should be available after completing first")

func test_quest_failure():
	"""Test quest failure conditions"""
	var quest_data = {
		"id": "failure_test_001",
		"title": "Failure Test Quest",
		"description": "Test quest failure",
		"level": 3,
		"rewards": {"gold": 50, "xp": 100},
		"objectives": [
			{
				"id": "obj_001",
				"description": "Time-limited objective",
				"type": "delivery",
				"target": "package",
				"quantity": 1,
				"time_limit": 24
			}
		]
	}

	var quest = quest_system.create_quest(quest_data)
	quest_system.accept_quest(test_character, quest)

	# Simulate time passing beyond limit
	quest_system.process_quest_timers(test_character, 48)  # 48 hours

	var result = quest_system.check_quest_failure(test_character, quest)
	assert_true(result["failed"], "Quest should fail due to time limit")

func test_quest_system_integration():
	"""Test integration with other game systems"""
	var quest_data = {
		"id": "integration_test_001",
		"title": "Integration Test Quest",
		"description": "Test quest system integration",
		"level": 5,
		"rewards": {"gold": 100, "xp": 200},
		"objectives": []
	}

	var quest = quest_system.create_quest(quest_data)
	quest_system.accept_quest(test_character, quest)

	# Test with faction system
	var faction_system = FactionSystem.new()
	faction_system.add_reputation(test_character, "merchants_guild", 50)

	var faction_quests = quest_system.get_faction_quests(test_character, "merchants_guild")
	assert_gt(faction_quests.size(), 0, "Should have faction-specific quests")

	# Test with equipment system
	var equipment_system = EquipmentSystem.new()
	var quest_rewards = quest_system.get_quest_rewards(test_character, quest)
	assert_true(quest_rewards.has("items"), "Quest should have item rewards")
