extends SceneTree

# Comprehensive unit tests for the new idle game systems
# Tests Quest System, NPC System, Town System, Profession System, Lifestyle System, and Random Events System

# Preload required scripts
const QuestSystem = preload("res://scripts/quest_system.gd")
const NPCSystem = preload("res://scripts/npc_system.gd")
const TownSystem = preload("res://scripts/town_system.gd")
const ProfessionSystem = preload("res://scripts/profession_system.gd")
const LifestyleSystem = preload("res://scripts/lifestyle_system.gd")
const RandomEventsSystem = preload("res://scripts/random_events_system.gd")
const Character = preload("res://scripts/character.gd")

var test_results: Dictionary = {}
var total_tests: int = 0
var passed_tests: int = 0
var failed_tests: int = 0

func _init():
	print("🧪 New Systems Test Suite")
	print("========================")
	print()

	run_all_tests()
	print_test_summary()
	quit()

func run_all_tests():
	test_quest_system()
	test_npc_system()
	test_town_system()
	test_profession_system()
	test_lifestyle_system()
	test_random_events_system()

func test_quest_system():
	print("Testing Quest System...")

	var quest_system = QuestSystem.new()
	var character = create_test_character()

	# Test quest template creation
	assert_gt(quest_system.quest_templates.size(), 0, "Should have quest templates")
	assert_true("harper_intel" in quest_system.quest_templates, "Should have Harper intelligence quest")
	assert_true("smith_commission" in quest_system.quest_templates, "Should have smith commission quest")

	# Test quest generation
	var available_quests = quest_system.generate_available_quests(character)
	assert_gt(available_quests.size(), 0, "Should generate available quests")

	# Test quest starting
	var quest = quest_system.create_quest_from_template("harper_intel", character)
	assert_not_null(quest, "Should create quest from template")

	var started = quest_system.start_quest(character, quest)
	assert_true(started, "Should be able to start quest")

	# Test quest progress
	quest_system.update_quest_progress(character, QuestSystem.ObjectiveType.PERFORM_ACTIVITY, 1)

	print("✅ Quest System tests passed")
	print()

func test_npc_system():
	print("Testing NPC System...")

	var npc_system = NPCSystem.new()
	var character = create_test_character()

	# Test NPC creation
	assert_gt(npc_system.npcs.size(), 0, "Should have NPCs")
	assert_true("general_store" in npc_system.npcs, "Should have general store merchant")
	assert_true("blacksmith" in npc_system.npcs, "Should have blacksmith")
	assert_true("bard" in npc_system.npcs, "Should have bard")

	# Test NPC interaction
	var result = npc_system.interact_with_npc(character, "general_store", NPCSystem.InteractionType.GREETING)
	assert_true(result["success"], "Should be able to interact with NPC")

	# Test relationship tracking
	var relationship = npc_system.get_relationship(character, npc_system.npcs["general_store"])
	assert_equals(relationship, NPCSystem.RelationshipLevel.NEUTRAL, "Should start with neutral relationship")

	# Test social events
	assert_gt(npc_system.social_events.size(), 0, "Should have social events")
	assert_true("tavern_night" in npc_system.social_events, "Should have tavern night event")

	print("✅ NPC System tests passed")
	print()

func test_town_system():
	print("Testing Town System...")

	var town_system = TownSystem.new()
	var character = create_test_character()

	# Test location creation
	assert_gt(town_system.locations.size(), 0, "Should have locations")
	assert_true("market_square" in town_system.locations, "Should have market square")
	assert_true("golden_harp" in town_system.locations, "Should have Golden Harp tavern")
	assert_true("smithy" in town_system.locations, "Should have smithy")

	# Test location visiting
	var result = town_system.visit_location(character, "market_square")
	assert_true(result["success"], "Should be able to visit market square")

	# Test service usage
	var services = town_system.get_available_services(character, "market_square")
	assert_gt(services.size(), 0, "Should have available services")

	# Test town events
	assert_gt(town_system.town_events.size(), 0, "Should have town events")
	assert_true("market_day" in town_system.town_events, "Should have market day event")

	print("✅ Town System tests passed")
	print()

func test_profession_system():
	print("Testing Profession System...")

	var profession_system = ProfessionSystem.new()
	var character = create_test_character()

	# Test profession creation
	assert_gt(profession_system.professions.size(), 0, "Should have professions")
	assert_true("blacksmith" in profession_system.professions, "Should have blacksmith profession")
	assert_true("general_merchant" in profession_system.professions, "Should have general merchant profession")

	# Test profession starting
	var started = profession_system.start_profession(character, "general_merchant")
	assert_true(started, "Should be able to start profession")

	# Test professional work
	var work_result = profession_system.work_profession(character, 8)
	assert_true(work_result["success"], "Should be able to work profession")
	assert_gt(work_result["income"], 0, "Should earn income from work")

	# Test professional reputation
	var reputation = profession_system.get_professional_reputation(character, "general_merchant")
	assert_gt(reputation, 0, "Should gain professional reputation")

	print("✅ Profession System tests passed")
	print()

func test_lifestyle_system():
	print("Testing Lifestyle System...")

	var lifestyle_system = LifestyleSystem.new()
	var character = create_test_character()
	character.add_gold(100) # Give character some gold

	# Test lifestyle creation
	assert_gt(lifestyle_system.lifestyles.size(), 0, "Should have lifestyles")
	assert_true(LifestyleSystem.LifestyleLevel.POOR in lifestyle_system.lifestyles, "Should have poor lifestyle")
	assert_true(LifestyleSystem.LifestyleLevel.COMFORTABLE in lifestyle_system.lifestyles, "Should have comfortable lifestyle")

	# Test lifestyle setting
	var set_lifestyle = lifestyle_system.set_character_lifestyle(character, LifestyleSystem.LifestyleLevel.COMFORTABLE)
	assert_true(set_lifestyle, "Should be able to set comfortable lifestyle")

	# Test lifestyle expenses
	var paid_expenses = lifestyle_system.pay_lifestyle_expenses(character)
	assert_true(paid_expenses, "Should be able to pay lifestyle expenses")

	# Test available lifestyles
	var available = lifestyle_system.get_available_lifestyles(character)
	assert_gt(available.size(), 0, "Should have available lifestyles")

	print("✅ Lifestyle System tests passed")
	print()

func test_random_events_system():
	print("Testing Random Events System...")

	var events_system = RandomEventsSystem.new()
	var character = create_test_character()

	# Test event creation
	assert_gt(events_system.events.size(), 0, "Should have random events")
	assert_true("noble_party" in events_system.events, "Should have noble party event")
	assert_true("tavern_brawl" in events_system.events, "Should have tavern brawl event")

	# Test event triggering
	var event = events_system.trigger_random_event(character)
	# Note: Event might be null if no events are available due to requirements

	# Test event choices
	if event != null:
		var choices = event.choices
		assert_gt(choices.size(), 0, "Event should have choices")

		# Test making a choice
		var outcome = events_system.make_event_choice(character, event, choices[0]["id"])
		assert_true(outcome in RandomEventsSystem.EventOutcome.values(), "Should return valid outcome")

	print("✅ Random Events System tests passed")
	print()

func create_test_character() -> Character:
	"""Create a test character for testing"""
	var character = Character.new()
	character.name = "Test Character"
	character.race = "Human"
	character.character_class = "Fighter"
	character.level = 5
	character.strength = 15
	character.dexterity = 14
	character.constitution = 13
	character.intelligence = 12
	character.wisdom = 11
	character.charisma = 10
	character.gold = 50
	character.faction_reputation = {"Town": 20, "Harpers": 25}
	character.skill_proficiencies = ["athletics", "persuasion", "insight"]
	return character

func assert_true(condition: bool, message: String):
	total_tests += 1
	if condition:
		passed_tests += 1
		print("  ✅ " + message)
	else:
		failed_tests += 1
		print("  ❌ " + message)

func assert_false(condition: bool, message: String):
	assert_true(not condition, message)

func assert_equals(actual, expected, message: String):
	assert_true(actual == expected, message + " (expected: " + str(expected) + ", actual: " + str(actual) + ")")

func assert_not_null(value, message: String):
	assert_true(value != null, message)

func assert_gt(actual, expected, message: String):
	assert_true(actual > expected, message + " (expected > " + str(expected) + ", actual: " + str(actual) + ")")

func assert_lt(actual, expected, message: String):
	assert_true(actual < expected, message + " (expected < " + str(expected) + ", actual: " + str(actual) + ")")

func print_test_summary():
	print("📊 Test Summary")
	print("===============")
	print("Total Tests: " + str(total_tests))
	print("Passed: " + str(passed_tests))
	print("Failed: " + str(failed_tests))
	print("Success Rate: " + str((float(passed_tests) / float(total_tests)) * 100) + "%")
	print()

	if failed_tests == 0:
		print("🎉 All tests passed!")
	else:
		print("⚠️  Some tests failed. Please review the output above.")
