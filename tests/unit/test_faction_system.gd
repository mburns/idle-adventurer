extends SceneTree

# Unit tests for the faction system

# Preload required scripts
const FactionSystem = preload("res://scripts/faction_system.gd")
const Character = preload("res://scripts/character.gd")

var test_results: Dictionary = {}
var total_tests: int = 0
var passed_tests: int = 0
var failed_tests: int = 0

func _init():
    print("🧪 Faction System Test Suite")
    print("============================")
    print()

    run_faction_tests()
    print_test_summary()
    quit()

func run_faction_tests():
    test_faction_creation()
    test_reputation_system()
    test_faction_relationships()
    test_quest_system()
    test_membership_system()

func test_faction_creation():
    print("Testing Faction Creation...")

    var faction_system = FactionSystem.new()

    # Test that default factions are created
    assert_gt(faction_system.factions.size(), 0, "Should have default factions")
    assert_true("Harpers" in faction_system.factions, "Should have Harpers faction")
    assert_true("Zhentarim" in faction_system.factions, "Should have Zhentarim faction")
    assert_true("Emerald Enclave" in faction_system.factions, "Should have Emerald Enclave faction")
    assert_true("Lord's Alliance" in faction_system.factions, "Should have Lord's Alliance faction")
    assert_true("Order of the Gauntlet" in faction_system.factions, "Should have Order of the Gauntlet faction")

    # Test faction data
    var harpers = faction_system.factions["Harpers"]
    assert_equals(harpers.name, "Harpers", "Harpers name should be correct")
    assert_equals(harpers.alignment, "chaotic_good", "Harpers alignment should be correct")
    assert_gt(harpers.primary_goals.size(), 0, "Harpers should have goals")

    print("✅ Faction creation tests passed")
    print()

func test_reputation_system():
    print("Testing Reputation System...")

    var faction_system = FactionSystem.new()

    # Test initial reputation
    assert_equals(faction_system.character_reputation["Harpers"], 0, "Initial reputation should be 0")

    # Test reputation level calculation
    assert_equals(faction_system.get_reputation_level_name(0), "Neutral", "0 reputation should be Neutral")
    assert_equals(faction_system.get_reputation_level_name(25), "Friendly", "25 reputation should be Friendly")
    assert_equals(faction_system.get_reputation_level_name(60), "Honored", "60 reputation should be Honored")
    assert_equals(faction_system.get_reputation_level_name(85), "Exalted", "85 reputation should be Exalted")
    assert_equals(faction_system.get_reputation_level_name(-30), "Unfriendly", "-30 reputation should be Unfriendly")
    assert_equals(faction_system.get_reputation_level_name(-75), "Hostile", "-75 reputation should be Hostile")

    # Test reputation change
    faction_system.change_reputation("Harpers", 15, "Test quest")
    assert_equals(faction_system.character_reputation["Harpers"], 15, "Reputation should increase by 15")

    # Test reputation clamping
    faction_system.change_reputation("Harpers", 200, "Massive gain")
    assert_equals(faction_system.character_reputation["Harpers"], 100, "Reputation should be clamped to 100")

    faction_system.change_reputation("Harpers", -300, "Massive loss")
    assert_equals(faction_system.character_reputation["Harpers"], -100, "Reputation should be clamped to -100")

    print("✅ Reputation system tests passed")
    print()

func test_faction_relationships():
    print("Testing Faction Relationships...")

    var faction_system = FactionSystem.new()

    # Test faction relationships
    var harpers_zhentarim = faction_system.get_faction_relationship("Harpers", "Zhentarim")
    assert_equals(faction_system.get_relationship_name(harpers_zhentarim), "Hostile", "Harpers and Zhentarim should be hostile")

    var lords_alliance_harper = faction_system.get_faction_relationship("Lord's Alliance", "Harpers")
    assert_equals(faction_system.get_relationship_name(lords_alliance_harper), "Friendly", "Lord's Alliance and Harpers should be friendly")

    var order_gauntlet_lords = faction_system.get_faction_relationship("Order of the Gauntlet", "Lord's Alliance")
    assert_equals(faction_system.get_relationship_name(order_gauntlet_lords), "Allied", "Order of the Gauntlet and Lord's Alliance should be allied")

    # Test neutral relationships
    var enclave_harper = faction_system.get_faction_relationship("Emerald Enclave", "Harpers")
    assert_equals(faction_system.get_relationship_name(enclave_harper), "Neutral", "Emerald Enclave and Harpers should be neutral")

    print("✅ Faction relationships tests passed")
    print()

func test_quest_system():
    print("Testing Quest System...")

    var faction_system = FactionSystem.new()

    # Test quest availability based on reputation
    var quests = faction_system.get_available_quests("Harpers")
    assert_gt(quests.size(), 0, "Should have available quests at neutral reputation")

    # Test quest completion
    var initial_reputation = faction_system.character_reputation["Harpers"]
    var reputation_gain = faction_system.complete_faction_quest("Harpers", "Investigate corruption")
    assert_gt(reputation_gain, 0, "Quest completion should give reputation")
    assert_gt(faction_system.character_reputation["Harpers"], initial_reputation, "Reputation should increase after quest")

    # Test different quest types
    var harper_quests = faction_system.get_available_quests("Harpers")
    assert_true("Investigate corruption" in harper_quests, "Should have investigate corruption quest")
    assert_true("Protect scholars" in harper_quests, "Should have protect scholars quest")
    assert_true("Gather intelligence" in harper_quests, "Should have gather intelligence quest")

    print("✅ Quest system tests passed")
    print()

func test_membership_system():
    print("Testing Membership System...")

    var faction_system = FactionSystem.new()

    # Test initial membership
    assert_equals(faction_system.character_faction_membership.size(), 0, "Should start with no faction memberships")

    # Test joining faction (need friendly reputation)
    faction_system.change_reputation("Harpers", 25, "Gain reputation")
    var can_join = faction_system.can_join_faction("Harpers")
    assert_true(can_join, "Should be able to join Harpers with friendly reputation")

    # Test joining faction
    var join_success = faction_system.join_faction("Harpers")
    assert_true(join_success, "Should successfully join Harpers")
    assert_true("Harpers" in faction_system.character_faction_membership, "Should be member of Harpers")

    # Test benefits
    var benefits = faction_system.get_faction_benefits("Harpers")
    assert_gt(benefits.size(), 0, "Should have benefits at friendly reputation")

    # Test leaving faction
    var leave_success = faction_system.leave_faction("Harpers")
    assert_true(leave_success, "Should successfully leave Harpers")
    assert_false("Harpers" in faction_system.character_faction_membership, "Should not be member of Harpers")

    print("✅ Membership system tests passed")
    print()

# Test helper functions
func assert_equals(actual, expected, message: String = ""):
    total_tests += 1
    if actual == expected:
        passed_tests += 1
        print("  ✓ " + message)
    else:
        failed_tests += 1
        print("  ✗ " + message + " (Expected: " + str(expected) + ", Got: " + str(actual) + ")")

func assert_not_null(value, message: String = ""):
    total_tests += 1
    if value != null:
        passed_tests += 1
        print("  ✓ " + message)
    else:
        failed_tests += 1
        print("  ✗ " + message + " (Value is null)")

func assert_true(condition: bool, message: String = ""):
    total_tests += 1
    if condition:
        passed_tests += 1
        print("  ✓ " + message)
    else:
        failed_tests += 1
        print("  ✗ " + message + " (Condition is false)")

func assert_false(condition: bool, message: String = ""):
    total_tests += 1
    if not condition:
        passed_tests += 1
        print("  ✓ " + message)
    else:
        failed_tests += 1
        print("  ✗ " + message + " (Condition is true)")

func assert_gt(actual, expected, message: String = ""):
    total_tests += 1
    if actual > expected:
        passed_tests += 1
        print("  ✓ " + message)
    else:
        failed_tests += 1
        print("  ✗ " + message + " (Expected: > " + str(expected) + ", Got: " + str(actual) + ")")

func print_test_summary():
    print("Faction System Test Summary")
    print("===========================")
    print("Total tests: " + str(total_tests))
    print("Passed: " + str(passed_tests))
    print("Failed: " + str(failed_tests))
    print("Success rate: " + str((float(passed_tests) / float(total_tests)) * 100) + "%")
    print()

    if failed_tests == 0:
        print("🎉 All faction system tests passed!")
    else:
        print("❌ Some faction system tests failed!")
