extends GutTest

# Test suite for the inventory system

var inventory_system: InventorySystem
var test_character: Character

func before_each():
    inventory_system = InventorySystem.new()
    test_character = Character.new()
    test_character.name = "TestCharacter"

func test_inventory_initialization():
    """Test that inventory system initializes correctly"""
    assert_not_null(inventory_system, "Inventory system should be created")

    var inventory = inventory_system.get_character_inventory(test_character)
    assert_not_null(inventory, "Character inventory should be created")
    assert_eq(inventory["max_slots"], 30, "Default max slots should be 30")
    assert_eq(inventory["used_slots"], 0, "Initial used slots should be 0")
    assert_true(inventory["items"].is_empty(), "Initial inventory should be empty")

func test_add_stackable_item():
    """Test adding stackable items to inventory"""
    var potion = {
        "id": "healing_potion",
        "name": "Healing Potion",
        "type": "potion",
        "weight": 0.5,
        "value": 50.0
    }

    # Add first potion
    var result = inventory_system.add_item(test_character, potion, 1)
    assert_true(result, "Should successfully add first potion")

    var inventory = inventory_system.get_character_inventory(test_character)
    assert_eq(inventory["used_slots"], 1, "Should use 1 slot")
    assert_true(inventory["items"].has("healing_potion"), "Should have healing potion")
    assert_eq(inventory["items"]["healing_potion"]["quantity"], 1, "Should have quantity 1")

    # Add more potions to same stack
    result = inventory_system.add_item(test_character, potion, 3)
    assert_true(result, "Should successfully add more potions")
    assert_eq(inventory["items"]["healing_potion"]["quantity"], 4, "Should have quantity 4")
    assert_eq(inventory["used_slots"], 1, "Should still use only 1 slot")

func test_add_unique_item():
    """Test adding unique items to inventory"""
    var sword = {
        "id": "longsword",
        "name": "Longsword",
        "type": "weapon",
        "weight": 3.0,
        "value": 15.0
    }

    # Add first sword
    var result = inventory_system.add_item(test_character, sword, 1)
    assert_true(result, "Should successfully add first sword")

    var inventory = inventory_system.get_character_inventory(test_character)
    assert_eq(inventory["used_slots"], 1, "Should use 1 slot")

    # Add second sword (should create separate entry)
    result = inventory_system.add_item(test_character, sword, 1)
    assert_true(result, "Should successfully add second sword")
    assert_eq(inventory["used_slots"], 2, "Should use 2 slots")

func test_remove_item():
    """Test removing items from inventory"""
    var potion = {
        "id": "healing_potion",
        "name": "Healing Potion",
        "type": "potion",
        "weight": 0.5,
        "value": 50.0
    }

    # Add items first
    inventory_system.add_item(test_character, potion, 5)

    # Remove some items
    var result = inventory_system.remove_item(test_character, "healing_potion", 2)
    assert_true(result, "Should successfully remove items")

    var inventory = inventory_system.get_character_inventory(test_character)
    assert_eq(inventory["items"]["healing_potion"]["quantity"], 3, "Should have 3 remaining")

    # Remove all remaining items
    result = inventory_system.remove_item(test_character, "healing_potion", 3)
    assert_true(result, "Should successfully remove all items")
    assert_false(inventory["items"].has("healing_potion"), "Should not have potion anymore")
    assert_eq(inventory["used_slots"], 0, "Should use 0 slots")

func test_use_item():
    """Test using items from inventory"""
    var potion = {
        "id": "healing_potion",
        "name": "Healing Potion",
        "type": "potion",
        "weight": 0.5,
        "value": 50.0,
        "healing": 10
    }

    # Add potion
    inventory_system.add_item(test_character, potion, 3)

    # Set up character with low HP
    test_character.hit_points = 5
    test_character.max_hit_points = 20

    # Use potion
    var result = inventory_system.use_item(test_character, "healing_potion", 1)
    assert_true(result, "Should successfully use potion")
    assert_eq(test_character.hit_points, 15, "Should heal 10 HP")

    var inventory = inventory_system.get_character_inventory(test_character)
    assert_eq(inventory["items"]["healing_potion"]["quantity"], 2, "Should have 2 remaining")

func test_inventory_weight_calculation():
    """Test inventory weight calculation"""
    var items = [
        {
            "id": "sword",
            "name": "Sword",
            "type": "weapon",
            "weight": 3.0,
            "value": 15.0
        },
        {
            "id": "potion",
            "name": "Potion",
            "type": "potion",
            "weight": 0.5,
            "value": 50.0
        }
    ]

    # Add items
    inventory_system.add_item(test_character, items[0], 1) # 3.0 weight
    inventory_system.add_item(test_character, items[1], 4) # 2.0 weight (0.5 * 4)

    var total_weight = inventory_system.get_inventory_weight(test_character)
    assert_eq(total_weight, 5.0, "Total weight should be 5.0")

func test_inventory_value_calculation():
    """Test inventory value calculation"""
    var items = [
        {
            "id": "sword",
            "name": "Sword",
            "type": "weapon",
            "weight": 3.0,
            "value": 15.0
        },
        {
            "id": "potion",
            "name": "Potion",
            "type": "potion",
            "weight": 0.5,
            "value": 50.0
        }
    ]

    # Add items
    inventory_system.add_item(test_character, items[0], 1) # 15.0 value
    inventory_system.add_item(test_character, items[1], 2) # 100.0 value (50.0 * 2)

    var total_value = inventory_system.get_inventory_value(test_character)
    assert_eq(total_value, 115.0, "Total value should be 115.0")

func test_item_categories():
    """Test item categorization"""
    var items = [
        {"type": "weapon", "name": "Sword"},
        {"type": "armor", "name": "Chain Mail"},
        {"type": "potion", "name": "Healing Potion"},
        {"type": "tool", "name": "Thieves' Tools"},
        {"type": "adventuring_gear", "name": "Backpack"},
        {"type": "treasure", "name": "Gold Coin"},
        {"type": "spell_component", "name": "Bat Guano"},
        {"type": "misc", "name": "Random Item"}
    ]

    for item in items:
        var category = inventory_system.get_item_category(item)
        assert_true(category >= 0, "Category should be valid for " + item["name"])
        assert_true(category <= 7, "Category should be within range for " + item["name"])

func test_search_inventory():
    """Test inventory search functionality"""
    var items = [
        {
            "id": "healing_potion",
            "name": "Healing Potion",
            "description": "Restores hit points"
        },
        {
            "id": "magic_sword",
            "name": "Magic Sword",
            "description": "A magical weapon"
        },
        {
            "id": "health_elixir",
            "name": "Health Elixir",
            "description": "Another healing item"
        }
    ]

    # Add items
    for item in items:
        inventory_system.add_item(test_character, item, 1)

    # Search by name
    var results = inventory_system.search_inventory(test_character, "healing")
    assert_eq(results.size(), 1, "Should find 1 healing item")
    assert_true(results.has("healing_potion"), "Should find healing potion")

    # Search by description
    results = inventory_system.search_inventory(test_character, "magical")
    assert_eq(results.size(), 1, "Should find 1 magical item")
    assert_true(results.has("magic_sword"), "Should find magic sword")

func test_sort_inventory():
    """Test inventory sorting functionality"""
    var items = [
        {"name": "Zebra", "value": 100, "weight": 5.0, "quantity": 1},
        {"name": "Apple", "value": 50, "weight": 2.0, "quantity": 3},
        {"name": "Banana", "value": 200, "weight": 1.0, "quantity": 2}
    ]

    # Add items
    for item in items:
        inventory_system.add_item(test_character, item, item["quantity"])

    # Test name sorting
    var sorted_items = inventory_system.sort_inventory(test_character, "name")
    assert_eq(sorted_items[0]["name"], "Apple", "First item should be Apple")
    assert_eq(sorted_items[1]["name"], "Banana", "Second item should be Banana")
    assert_eq(sorted_items[2]["name"], "Zebra", "Third item should be Zebra")

    # Test value sorting
    sorted_items = inventory_system.sort_inventory(test_character, "value")
    assert_eq(sorted_items[0]["name"], "Banana", "First item should be Banana (highest value)")
    assert_eq(sorted_items[1]["name"], "Zebra", "Second item should be Zebra")
    assert_eq(sorted_items[2]["name"], "Apple", "Third item should be Apple (lowest value)")

func test_inventory_summary():
    """Test inventory summary generation"""
    var items = [
        {"name": "Sword", "type": "weapon", "value": 15.0, "weight": 3.0},
        {"name": "Potion", "type": "potion", "value": 50.0, "weight": 0.5}
    ]

    # Add items
    inventory_system.add_item(test_character, items[0], 1)
    inventory_system.add_item(test_character, items[1], 3)

    var summary = inventory_system.get_inventory_summary(test_character)
    assert_eq(summary["total_items"], 4, "Should have 4 total items")
    assert_eq(summary["total_value"], 165.0, "Should have correct total value")
    assert_eq(summary["total_weight"], 4.5, "Should have correct total weight")
    assert_eq(summary["used_slots"], 2, "Should use 2 slots")
    assert_eq(summary["max_slots"], 30, "Should have 30 max slots")

func test_clear_inventory():
    """Test clearing entire inventory"""
    var items = [
        {"name": "Sword", "type": "weapon"},
        {"name": "Potion", "type": "potion"}
    ]

    # Add items
    for item in items:
        inventory_system.add_item(test_character, item, 1)

    var inventory = inventory_system.get_character_inventory(test_character)
    assert_eq(inventory["used_slots"], 2, "Should have 2 used slots")

    # Clear inventory
    inventory_system.clear_inventory(test_character)
    assert_eq(inventory["used_slots"], 0, "Should have 0 used slots")
    assert_true(inventory["items"].is_empty(), "Items should be empty")

func test_transfer_item():
    """Test transferring items between characters"""
    var other_character = Character.new()
    other_character.name = "OtherCharacter"

    var potion = {
        "id": "healing_potion",
        "name": "Healing Potion",
        "type": "potion",
        "weight": 0.5,
        "value": 50.0
    }

    # Add potion to first character
    inventory_system.add_item(test_character, potion, 3)

    # Transfer potion
    var result = inventory_system.transfer_item(test_character, other_character, "healing_potion", 2)
    assert_true(result, "Should successfully transfer items")

    # Check both inventories
    var test_inventory = inventory_system.get_character_inventory(test_character)
    var other_inventory = inventory_system.get_character_inventory(other_character)

    assert_eq(test_inventory["items"]["healing_potion"]["quantity"], 1, "Test character should have 1 potion")
    assert_eq(other_inventory["items"]["healing_potion"]["quantity"], 2, "Other character should have 2 potions")

func test_can_stack_item():
    """Test item stacking logic"""
    var stackable_item = {"type": "potion"}
    var unique_item = {"type": "weapon"}

    assert_true(inventory_system.can_stack_item(stackable_item), "Potion should be stackable")
    assert_false(inventory_system.can_stack_item(unique_item), "Weapon should not be stackable")

func test_get_max_stack_size():
    """Test maximum stack size calculation"""
    var potion = {"type": "potion"}
    var ammunition = {"type": "ammunition"}
    var weapon = {"type": "weapon"}

    assert_eq(inventory_system.get_max_stack_size(potion), 10, "Potion should stack to 10")
    assert_eq(inventory_system.get_max_stack_size(ammunition), 50, "Ammunition should stack to 50")
    assert_eq(inventory_system.get_max_stack_size(weapon), 1, "Weapon should not stack")

func test_inventory_signals():
    """Test that inventory signals are emitted correctly"""
    var item_added_called = false
    var inventory_changed_called = false

    inventory_system.item_added.connect(func(_char, _item, _qty): item_added_called = true)
    inventory_system.inventory_changed.connect(func(_char): inventory_changed_called = true)

    var potion = {"id": "potion", "name": "Potion", "type": "potion"}
    inventory_system.add_item(test_character, potion, 1)

    assert_true(item_added_called, "item_added signal should be emitted")
    assert_true(inventory_changed_called, "inventory_changed signal should be emitted")
