extends SceneTree

# Unit tests for the equipment system

# Preload required scripts
const EquipmentSystem = preload("res://scripts/equipment_system.gd")
const EquipmentResource = preload("res://resources/equipment_resource.gd")
const EquipmentFactory = preload("res://scripts/equipment_factory.gd")
const Character = preload("res://scripts/character.gd")

var test_results: Dictionary = {}
var total_tests: int = 0
var passed_tests: int = 0
var failed_tests: int = 0

func _init():
    print("🧪 Equipment System Test Suite")
    print("==============================")
    print()

    run_equipment_tests()
    print_test_summary()
    quit()

func run_equipment_tests():
    test_equipment_creation()
    test_equipment_stats()
    test_equipment_durability()
    test_equipment_sets()
    test_equipment_factory()

func test_equipment_creation():
    print("Testing Equipment Creation...")

    # Test basic equipment creation
    var factory = EquipmentFactory.new()
    var sword = factory.create_sword()
    assert_not_null(sword, "Sword should be created")
    assert_equals(sword.item_name, "Longsword", "Sword name should be correct")
    assert_equals(sword.item_type, EquipmentResource.EquipmentType.WEAPON, "Sword should be a weapon")
    assert_equals(sword.damage_dice, "1d8", "Sword damage should be correct")

    # Test armor creation
    var armor = factory.create_chain_mail()
    assert_not_null(armor, "Armor should be created")
    assert_equals(armor.item_name, "Chain Mail", "Armor name should be correct")
    assert_equals(armor.item_type, EquipmentResource.EquipmentType.ARMOR, "Armor should be armor type")
    assert_equals(armor.armor_class, 16, "Armor class should be correct")

    print("✅ Equipment creation tests passed")
    print()

func test_equipment_stats():
    print("Testing Equipment Stats...")

    # Test stat bonuses
    var factory = EquipmentFactory.new()
    var gloves = factory.create_gloves_of_dexterity()
    assert_equals(gloves.get_stat_bonus("dexterity"), 2, "Dexterity bonus should be 2")
    assert_equals(gloves.get_stat_bonus("strength"), 0, "Strength bonus should be 0")

    # Test skill bonuses
    var skill_bonuses = gloves.get_skill_bonuses()
    assert_true("acrobatics" in skill_bonuses, "Should have acrobatics bonus")
    assert_equals(skill_bonuses["acrobatics"], 1, "Acrobatics bonus should be 1")

    # Test attack and damage bonuses
    var sword = factory.create_sword()
    assert_equals(sword.get_attack_bonus(), 0, "Basic sword attack bonus should be 0")
    assert_equals(sword.get_damage_bonus(), 0, "Basic sword damage bonus should be 0")

    print("✅ Equipment stats tests passed")
    print()

func test_equipment_durability():
    print("Testing Equipment Durability...")

    var factory = EquipmentFactory.new()
    var sword = factory.create_sword()
    assert_equals(sword.get_current_durability(), 100, "Sword should start at full durability")
    assert_equals(sword.get_max_durability(), 100, "Sword max durability should be 100")
    assert_false(sword.is_broken(), "Sword should not be broken")
    assert_false(sword.is_damaged(), "Sword should not be damaged")

    # Test taking damage
    sword.take_damage(20)
    assert_equals(sword.get_current_durability(), 80, "Sword should have 80 durability after 20 damage")
    assert_true(sword.is_damaged(), "Sword should be damaged")
    assert_false(sword.is_broken(), "Sword should not be broken")

    # Test repair
    sword.repair(10)
    assert_equals(sword.get_current_durability(), 90, "Sword should have 90 durability after repair")

    # Test breaking
    sword.take_damage(100)
    assert_true(sword.is_broken(), "Sword should be broken")
    assert_equals(sword.get_current_durability(), 0, "Sword durability should be 0")

    # Test condition descriptions
    sword.repair(50)
    var condition = sword.get_condition_description()
    assert_true(condition in ["Good", "Fair", "Poor", "Damaged"], "Condition should be valid")

    print("✅ Equipment durability tests passed")
    print()

func test_equipment_sets():
    print("Testing Equipment Sets...")

    var equipment_system = EquipmentSystem.new()
    var character = Character.new()
    character.name = "Test Character"

    # Test leather armor set
    var factory = EquipmentFactory.new()
    var leather_set = factory.create_equipment_set("leather_armor_set")
    assert_gt(leather_set.size(), 0, "Leather set should have items")

    # Test equipping items
    var leather_armor = leather_set[0]
    var success = equipment_system.equip_item(character, leather_armor, "chest")
    assert_true(success, "Should be able to equip leather armor")

    # Test equipment summary
    var summary = equipment_system.get_equipment_summary(character)
    assert_true("equipped_items" in summary, "Summary should have equipped items")
    assert_true("total_weight" in summary, "Summary should have total weight")

    print("✅ Equipment sets tests passed")
    print()

func test_equipment_factory():
    print("Testing Equipment Factory...")

    # Test individual item creation
    var factory = EquipmentFactory.new()
    var sword = factory.create_sword()
    var armor = factory.create_chain_mail()
    var ring = factory.create_ring_of_protection()
    var gloves = factory.create_gloves_of_dexterity()
    var potion = factory.create_health_potion()

    assert_not_null(sword, "Sword should be created")
    assert_not_null(armor, "Armor should be created")
    assert_not_null(ring, "Ring should be created")
    assert_not_null(gloves, "Gloves should be created")
    assert_not_null(potion, "Potion should be created")

    # Test equipment sets
    var leather_set = factory.create_equipment_set("leather_armor_set")
    var chain_set = factory.create_equipment_set("chain_mail_set")
    var wizard_set = factory.create_equipment_set("wizard_set")

    assert_gt(leather_set.size(), 0, "Leather set should have items")
    assert_gt(chain_set.size(), 0, "Chain set should have items")
    assert_gt(wizard_set.size(), 0, "Wizard set should have items")

    print("✅ Equipment factory tests passed")
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
    print("Equipment System Test Summary")
    print("=============================")
    print("Total tests: " + str(total_tests))
    print("Passed: " + str(passed_tests))
    print("Failed: " + str(failed_tests))
    print("Success rate: " + str((float(passed_tests) / float(total_tests)) * 100) + "%")
    print()

    if failed_tests == 0:
        print("🎉 All equipment system tests passed!")
    else:
        print("❌ Some equipment system tests failed!")
