extends GutTest

## Test runner for all refactored classes

const BaseScreenClass = preload("res://scripts/base_screen.gd")
const UIUtilsClass = preload("res://scripts/ui_utils.gd")
const NavigationManagerClass = preload("res://scripts/navigation_manager.gd")
const CharacterClass = preload("res://scripts/character.gd")

func test_all_classes_loaded():
	"""Test that all refactored classes can be instantiated"""
	assert_not_null(BaseScreenClass, "BaseScreen should be loadable")
	assert_not_null(UIUtilsClass, "UIUtils should be loadable")
	assert_not_null(NavigationManagerClass, "NavigationManager should be loadable")
	assert_not_null(CharacterClass, "Character should be loadable")

func test_base_screen_creation():
	"""Test BaseScreen can be created"""
	var base_screen = BaseScreenClass.new()
	assert_not_null(base_screen, "BaseScreen should be created")
	base_screen.queue_free()

func test_ui_utils_static_methods():
	"""Test UIUtils static methods work"""
	var label = UIUtilsClass.create_label("Test")
	assert_not_null(label, "UIUtilsClass.create_label should work")
	assert_eq(label.text, "Test", "Label text should be set")

	var button = UIUtilsClass.create_button("Test Button")
	assert_not_null(button, "UIUtilsClass.create_button should work")
	assert_eq(button.text, "Test Button", "Button text should be set")

func test_navigation_manager_creation():
	"""Test NavigationManager can be created"""
	var nav_manager = NavigationManagerClass.new()
	assert_not_null(nav_manager, "NavigationManager should be created")
	nav_manager.queue_free()

func test_character_creation():
	"""Test Character can be created"""
	var character = CharacterClass.new()
	assert_not_null(character, "Character should be created")
	character.queue_free()

func test_ui_utils_formatting():
	"""Test UIUtils formatting functions"""
	var ability_score = UIUtilsClass.format_ability_score(15)
	assert_eq(ability_score, "15 (+2)", "Should format ability score correctly")

	var currency = UIUtilsClass.format_currency(1500)
	assert_eq(currency, "1.5k gp", "Should format currency correctly")

	var time = UIUtilsClass.format_time(90)
	assert_eq(time, "1m 30s", "Should format time correctly")

func test_navigation_scenes():
	"""Test NavigationManager scene paths"""
	var nav_manager = NavigationManagerClass.new()
	var scenes = nav_manager.get_available_scenes()

	assert_true(scenes.has("main"), "Should have main scene")
	assert_true(scenes.has("start"), "Should have start scene")
	assert_true(scenes.has("character_creation"), "Should have character creation scene")

	nav_manager.queue_free()
