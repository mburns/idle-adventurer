extends GutTest

# Comprehensive test for FactionSystem
class_name TestFactionSystemComprehensive

var faction_system: FactionSystem
var test_character: Character

func before_each():
	faction_system = FactionSystem.new()
	test_character = Character.new()
	test_character.name = "TestCharacter"
	test_character.faction_reputation = {}

func test_faction_system_creation():
	"""Test that FactionSystem can be created"""
	assert_not_null(faction_system, "FactionSystem should be created")
	assert_true(faction_system is FactionSystem, "Should be a FactionSystem instance")

func test_add_reputation():
	"""Test adding reputation to a faction"""
	var result = faction_system.add_reputation(test_character, "merchants_guild", 50)

	assert_true(result["success"], "Should successfully add reputation")
	assert_eq(test_character.faction_reputation["merchants_guild"], 50, "Reputation should be 50")

func test_add_reputation_multiple_times():
	"""Test adding reputation multiple times"""
	faction_system.add_reputation(test_character, "merchants_guild", 30)
	faction_system.add_reputation(test_character, "merchants_guild", 20)

	assert_eq(test_character.faction_reputation["merchants_guild"], 50, "Reputation should accumulate")

func test_reputation_cap():
	"""Test that reputation is capped at maximum values"""
	faction_system.add_reputation(test_character, "merchants_guild", 200)

	assert_eq(test_character.faction_reputation["merchants_guild"], 100, "Reputation should be capped at 100")

func test_reputation_floor():
	"""Test that reputation cannot go below minimum values"""
	faction_system.add_reputation(test_character, "merchants_guild", 50)
	faction_system.add_reputation(test_character, "merchants_guild", -200)

	assert_eq(test_character.faction_reputation["merchants_guild"], -100, "Reputation should be floored at -100")

func test_get_reputation():
	"""Test getting reputation from a faction"""
	faction_system.add_reputation(test_character, "merchants_guild", 75)

	var reputation = faction_system.get_reputation(test_character, "merchants_guild")
	assert_eq(reputation, 75, "Should return correct reputation")

	# Test non-existent faction
	var unknown_reputation = faction_system.get_reputation(test_character, "unknown_faction")
	assert_eq(unknown_reputation, 0, "Unknown faction should return 0")

func test_get_reputation_level():
	"""Test getting reputation level (hostile, neutral, friendly, etc.)"""
	# Test hostile
	faction_system.add_reputation(test_character, "merchants_guild", -50)
	var level = faction_system.get_reputation_level(test_character, "merchants_guild")
	assert_eq(level, "hostile", "Should be hostile")

	# Test neutral
	faction_system.add_reputation(test_character, "merchants_guild", 0)
	level = faction_system.get_reputation_level(test_character, "merchants_guild")
	assert_eq(level, "neutral", "Should be neutral")

	# Test friendly
	faction_system.add_reputation(test_character, "merchants_guild", 50)
	level = faction_system.get_reputation_level(test_character, "merchants_guild")
	assert_eq(level, "friendly", "Should be friendly")

	# Test revered
	faction_system.add_reputation(test_character, "merchants_guild", 90)
	level = faction_system.get_reputation_level(test_character, "merchants_guild")
	assert_eq(level, "revered", "Should be revered")

func test_faction_benefits():
	"""Test faction benefits based on reputation level"""
	faction_system.add_reputation(test_character, "merchants_guild", 75)

	var benefits = faction_system.get_faction_benefits(test_character, "merchants_guild")
	assert_true(benefits.has("discount"), "Should have discount benefit")
	assert_true(benefits.has("access"), "Should have access benefit")

	# Test hostile faction
	faction_system.add_reputation(test_character, "thieves_guild", -50)
	benefits = faction_system.get_faction_benefits(test_character, "thieves_guild")
	assert_true(benefits.has("penalty"), "Should have penalty")
	assert_false(benefits.has("discount"), "Should not have discount")

func test_faction_conflicts():
	"""Test faction conflicts and penalties"""
	faction_system.add_reputation(test_character, "merchants_guild", 50)
	faction_system.add_reputation(test_character, "thieves_guild", 30)

	var conflicts = faction_system.check_faction_conflicts(test_character)
	assert_true(conflicts.has("merchants_guild"), "Should detect conflict")
	assert_true(conflicts.has("thieves_guild"), "Should detect conflict")

	# Test reputation penalty for conflicts
	var penalty = faction_system.get_conflict_penalty(test_character, "merchants_guild")
	assert_gt(penalty, 0, "Should have conflict penalty")

func test_faction_quests():
	"""Test faction-specific quest availability"""
	faction_system.add_reputation(test_character, "merchants_guild", 25)

	var available_quests = faction_system.get_available_quests(test_character, "merchants_guild")
	assert_gt(available_quests.size(), 0, "Should have available quests")

	# Test quest requirements
	for quest in available_quests:
		assert_true(faction_system.can_accept_quest(test_character, quest), "Should be able to accept quest")

func test_faction_services():
	"""Test faction services based on reputation"""
	faction_system.add_reputation(test_character, "merchants_guild", 60)

	var services = faction_system.get_available_services(test_character, "merchants_guild")
	assert_true(services.has("trade"), "Should have trade service")
	assert_true(services.has("banking"), "Should have banking service")

	# Test service costs
	var trade_cost = faction_system.get_service_cost(test_character, "merchants_guild", "trade")
	assert_lt(trade_cost, 1.0, "Should have discounted trade cost")

func test_faction_events():
	"""Test faction events and random encounters"""
	faction_system.add_reputation(test_character, "merchants_guild", 40)

	var events = faction_system.get_faction_events(test_character, "merchants_guild")
	assert_gt(events.size(), 0, "Should have faction events")

	# Test event triggers
	for event in events:
		assert_true(faction_system.can_trigger_event(test_character, event), "Should be able to trigger event")

func test_faction_rank_system():
	"""Test faction ranking system"""
	faction_system.add_reputation(test_character, "merchants_guild", 100)

	var rank = faction_system.get_faction_rank(test_character, "merchants_guild")
	assert_not_null(rank, "Should have a faction rank")
	assert_true(rank.has("title"), "Rank should have a title")
	assert_true(rank.has("benefits"), "Rank should have benefits")

func test_faction_alliance_system():
	"""Test faction alliance and enemy relationships"""
	faction_system.add_reputation(test_character, "merchants_guild", 80)
	faction_system.add_reputation(test_character, "thieves_guild", -30)

	var alliances = faction_system.get_faction_alliances(test_character)
	assert_true(alliances.has("merchants_guild"), "Should have merchant alliance")

	var enemies = faction_system.get_faction_enemies(test_character)
	assert_true(enemies.has("thieves_guild"), "Should have thief enemies")

func test_faction_reputation_decay():
	"""Test reputation decay over time"""
	faction_system.add_reputation(test_character, "merchants_guild", 50)

	# Simulate time passing
	faction_system.process_reputation_decay(test_character, 30)  # 30 days

	var reputation = faction_system.get_reputation(test_character, "merchants_guild")
	assert_lt(reputation, 50, "Reputation should decay over time")

func test_faction_reputation_transfer():
	"""Test reputation transfer between related factions"""
	faction_system.add_reputation(test_character, "merchants_guild", 60)

	# Transfer reputation to allied faction
	faction_system.transfer_reputation(test_character, "merchants_guild", "traders_guild", 0.5)

	var traders_reputation = faction_system.get_reputation(test_character, "traders_guild")
	assert_eq(traders_reputation, 30, "Should transfer 50% reputation")

func test_faction_system_integration():
	"""Test integration with other game systems"""
	faction_system.add_reputation(test_character, "merchants_guild", 70)

	# Test with equipment system
	var equipment_system = EquipmentSystem.new()
	var faction_equipment = faction_system.get_faction_equipment(test_character, "merchants_guild")
	assert_gt(faction_equipment.size(), 0, "Should have faction-specific equipment")

	# Test with quest system
	var quest_system = QuestSystem.new()
	var faction_quests = faction_system.get_faction_quests(test_character, "merchants_guild")
	assert_gt(faction_quests.size(), 0, "Should have faction-specific quests")
