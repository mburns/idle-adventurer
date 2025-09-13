extends GutTest

## Test suite for NavigationManager class

const NavigationManagerClass = preload("res://scripts/navigation_manager.gd")

var navigation_manager: NavigationManagerClass

func before_each():
	"""Setup test environment before each test"""
	navigation_manager = NavigationManagerClass.new()
	add_child(navigation_manager)

func after_each():
	"""Cleanup after each test"""
	if navigation_manager:
		navigation_manager.queue_free()

func test_navigation_manager_initialization():
	"""Test that NavigationManager initializes correctly"""
	assert_not_null(navigation_manager, "NavigationManager should be created")
	assert_true(navigation_manager is NavigationManager, "Should be instance of NavigationManager")

func test_scene_paths():
	"""Test that all scene paths are defined"""
	var scenes = navigation_manager.get_available_scenes()

	# Test that key scenes are available
	assert_true(scenes.has("main"), "Should have main scene")
	assert_true(scenes.has("start"), "Should have start scene")
	assert_true(scenes.has("character_creation"), "Should have character creation scene")
	assert_true(scenes.has("character_selection"), "Should have character selection scene")
	assert_true(scenes.has("character_display"), "Should have character display scene")
	assert_true(scenes.has("character_sheet"), "Should have character sheet scene")
	assert_true(scenes.has("activities"), "Should have activities scene")
	assert_true(scenes.has("equipment"), "Should have equipment scene")
	assert_true(scenes.has("inventory"), "Should have inventory scene")
	assert_true(scenes.has("spellbook"), "Should have spellbook scene")
	assert_true(scenes.has("leveling"), "Should have leveling scene")
	assert_true(scenes.has("faction"), "Should have faction scene")
	assert_true(scenes.has("achievements"), "Should have achievements scene")
	assert_true(scenes.has("settings"), "Should have settings scene")

func test_get_scene_path():
	"""Test getting scene path by key"""
	var main_path = navigation_manager.get_scene_path("main")
	assert_eq(main_path, "res://scenes/main.tscn", "Should return correct main scene path")

	var invalid_path = navigation_manager.get_scene_path("invalid")
	assert_eq(invalid_path, "", "Should return empty string for invalid scene")

func test_navigation_history():
	"""Test navigation history functionality"""
	var history = navigation_manager.get_history()
	assert_eq(history.size(), 0, "Initial history should be empty")

	# Test adding to history
	navigation_manager.add_to_history("test_scene")
	history = navigation_manager.get_history()
	assert_eq(history.size(), 1, "History should have one item")
	assert_eq(history[0], "test_scene", "History should contain added scene")

	# Test history size limit
	for i in range(15):  # Add more than max_history_size
		navigation_manager.add_to_history("scene_" + str(i))

	history = navigation_manager.get_history()
	assert_le(history.size(), 10, "History should not exceed max size")

func test_can_go_back():
	"""Test can_go_back functionality"""
	assert_false(navigation_manager.can_go_back(), "Should not be able to go back with empty history")

	navigation_manager.add_to_history("scene1")
	navigation_manager.add_to_history("scene2")
	assert_true(navigation_manager.can_go_back(), "Should be able to go back with history")

func test_get_previous_scene():
	"""Test getting previous scene"""
	assert_eq(navigation_manager.get_previous_scene(), "", "Should return empty string with no history")

	navigation_manager.add_to_history("scene1")
	navigation_manager.add_to_history("scene2")
	assert_eq(navigation_manager.get_previous_scene(), "scene1", "Should return previous scene")

func test_clear_history():
	"""Test clearing navigation history"""
	navigation_manager.add_to_history("scene1")
	navigation_manager.add_to_history("scene2")
	assert_gt(navigation_manager.get_history().size(), 0, "History should have items")

	navigation_manager.clear_history()
	assert_eq(navigation_manager.get_history().size(), 0, "History should be empty after clear")

func test_navigate_to_invalid_scene():
	"""Test navigation to invalid scene"""
	var result = navigation_manager.navigate_to("invalid_scene")
	assert_false(result, "Should return false for invalid scene")

func test_navigation_signals():
	"""Test navigation signal emission"""
	var _scene_changed_emitted = false
	var history_updated_emitted = false

	navigation_manager.scene_changed.connect(func(_from, _to): _scene_changed_emitted = true)
	navigation_manager.navigation_history_updated.connect(func(_history): history_updated_emitted = true)

	# Test history update signal
	navigation_manager.add_to_history("test_scene")
	assert_true(history_updated_emitted, "navigation_history_updated signal should be emitted")

	# Reset for next test
	history_updated_emitted = false

	# Test scene change signal (this would need to be mocked in a real test)
	# For now, just test that the method exists and doesn't crash
	navigation_manager.navigate_to("main")
	assert_true(true, "navigate_to should not crash")

func test_convenience_methods():
	"""Test convenience navigation methods"""
	# Test that convenience methods exist and don't crash
	# These would need to be mocked in a real implementation
	navigation_manager.go_to_character_creation()
	navigation_manager.go_to_character_selection()
	navigation_manager.go_to_character_display()
	navigation_manager.go_to_character_sheet()
	navigation_manager.go_to_activities()
	navigation_manager.go_to_equipment()
	navigation_manager.go_to_inventory()
	navigation_manager.go_to_spellbook()
	navigation_manager.go_to_leveling()
	navigation_manager.go_to_faction()
	navigation_manager.go_to_achievements()
	navigation_manager.go_to_settings()

	assert_true(true, "All convenience methods should not crash")
