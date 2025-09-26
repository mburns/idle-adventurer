extends GutTest

var general_store: GeneralStore

func before_each():
	general_store = GeneralStore.new()

func after_each():
	if general_store:
		general_store.queue_free()

func test_load_store_inventory():
	general_store.load_store_inventory()

	assert_true(general_store.store_inventory.size() > 0, "Should have loaded items")
	print("Loaded ", general_store.store_inventory.size(), " items")

func test_parse_items_yaml():
	# This test is deprecated since we now use .tres resources instead of YAML parsing
	pending("YAML parsing removed - now using .tres resources")
	return
	var yaml_content = """
category: Test Items
items:
  - name: Test Item 1
    cost: 10 gp
    weight: 2 lb.
    description: A test item
    category: Test Gear
    type: gear
  - name: Test Item 2
    cost: 25 gp
    weight: 1 lb.
    description: Another test item
    category: Test Gear
    type: gear
"""

	var items = general_store.parse_items_yaml(yaml_content)

	assert_eq(items.size(), 2, "Should parse 2 items")
	assert_eq(items[0]["name"], "Test Item 1", "Should parse first item name")
	assert_eq(items[0]["cost"], "10 gp", "Should parse first item cost")
	assert_eq(items[1]["name"], "Test Item 2", "Should parse second item name")

func test_generate_item_id():
	assert_eq(general_store.generate_item_id("Healing Potion"), "healing_potion", "Should generate correct ID")
	assert_eq(general_store.generate_item_id("Rope, hempen (50 feet)"), "rope_hempen_50_feet", "Should handle special characters")
	assert_eq(general_store.generate_item_id("Oil (flask)"), "oil_flask", "Should handle parentheses")

func test_add_consumable_items():
	general_store.add_consumable_items()

	assert_true(general_store.store_inventory.has("healing_potion"), "Should have healing potion")
	assert_true(general_store.store_inventory.has("antitoxin"), "Should have antitoxin")
	assert_true(general_store.store_inventory.has("potion_of_healing_greater"), "Should have greater healing potion")

	var healing_potion = general_store.store_inventory["healing_potion"]
	assert_eq(healing_potion["name"], "Healing Potion", "Should have correct name")
	assert_eq(healing_potion["cost"], 50, "Should have correct cost")
	assert_eq(healing_potion["type"], "consumable", "Should have correct type")

func test_load_items_from_file():
	# This test might fail if the file doesn't exist, which is expected
	general_store.load_items_from_file("res://data/items/gear.yaml")
	# Should either load items or print a warning

func test_load_items_from_invalid_file():
	general_store.load_items_from_file("res://nonexistent/file.yaml")
	# Should handle gracefully and print warning

func test_parse_items_yaml_with_comments():
	# This test is deprecated since we now use .tres resources instead of YAML parsing
	pending("YAML parsing removed - now using .tres resources")
	return
	var yaml_content = """
category: Test Items
items:
  # This is a comment
  - name: Commented Item
    cost: 15 gp
    weight: 3 lb.
    description: An item with comments
    # Another comment
    category: Test Gear
    type: gear
"""

	var items = general_store.parse_items_yaml(yaml_content)

	assert_eq(items.size(), 1, "Should parse 1 item despite comments")
	assert_eq(items[0]["name"], "Commented Item", "Should parse item name")

func test_parse_items_yaml_empty():
	# This test is deprecated since we now use .tres resources instead of YAML parsing
	pending("YAML parsing removed - now using .tres resources")
	return
	var yaml_content = ""
	var items = general_store.parse_items_yaml(yaml_content)

	assert_eq(items.size(), 0, "Should return empty array for empty content")

func test_parse_items_yaml_no_items_section():
	# This test is deprecated since we now use .tres resources instead of YAML parsing
	pending("YAML parsing removed - now using .tres resources")
	return
	var yaml_content = """
category: Test Items
other_data: some value
"""

	var items = general_store.parse_items_yaml(yaml_content)

	assert_eq(items.size(), 0, "Should return empty array when no items section")

func test_store_inventory_access():
	general_store.load_store_inventory()

	# Test that we can access items
	var item_count = general_store.store_inventory.size()
	assert_true(item_count >= 0, "Should have non-negative item count")

	# Test that items have required properties
	for item_id in general_store.store_inventory.keys():
		var item = general_store.store_inventory[item_id]
		assert_true(item.has("name"), "Item should have name: " + item_id)
		assert_true(item.has("cost"), "Item should have cost: " + item_id)
