extends GutTest

## Test suite for BaseScreen class

const BaseScreenClass = preload("res://scripts/ui/base_screen.gd")
const CharacterClass = preload("res://scripts/core/character.gd")
const CharacterManagerClass = preload("res://scripts/core/character_manager.gd")

var base_screen: BaseScreenClass
var mock_character: CharacterClass
var mock_character_manager: CharacterManagerClass

func before_each():
	"""Setup test environment before each test"""
	base_screen = BaseScreenClass.new()
	add_child(base_screen)

	# Create mock character
	mock_character = CharacterClass.new()
	mock_character.name = "Test Character"
	mock_character.level = 5
	mock_character.race = "Human"
	mock_character.character_class = "Fighter"

	# Create mock character manager
	mock_character_manager = CharacterManagerClass.new()
	add_child(mock_character_manager)

func after_each():
	"""Cleanup after each test"""
	if base_screen:
		base_screen.queue_free()
	if mock_character_manager:
		mock_character_manager.queue_free()

func test_base_screen_initialization():
	"""Test that BaseScreen initializes correctly"""
	assert_not_null(base_screen, "BaseScreen should be created")
	assert_true(base_screen is BaseScreen, "Should be instance of BaseScreen")

func test_character_validation():
	"""Test character validation functionality"""
	# Test with null character
	base_screen.character = null
	assert_false(base_screen.validate_character(), "Should return false for null character")

	# Test with valid character
	base_screen.character = mock_character
	assert_true(base_screen.validate_character(), "Should return true for valid character")

func test_character_summary():
	"""Test character summary generation"""
	# Test with null character
	base_screen.character = null
	var summary = base_screen.get_character_summary()
	assert_eq(summary, "No character", "Should return 'No character' for null character")

	# Test with valid character
	base_screen.character = mock_character
	summary = base_screen.get_character_summary()
	assert_true(summary.find("Test Character") != -1, "Summary should contain character name")
	assert_true(summary.find("Level 5") != -1, "Summary should contain character level")
	assert_true(summary.find("Human") != -1, "Summary should contain character race")
	assert_true(summary.find("Fighter") != -1, "Summary should contain character class")

func test_navigation_back():
	"""Test navigation back functionality"""
	# This test would need to be mocked in a real implementation
	# For now, just test that the method exists and doesn't crash
	base_screen.navigate_back()
	assert_true(true, "navigate_back should not crash")

func test_navigate_to_scene():
	"""Test navigation to specific scene"""
	# This test would need to be mocked in a real implementation
	# For now, just test that the method exists and doesn't crash
	base_screen.navigate_to_scene("res://scenes/main.tscn")
	assert_true(true, "navigate_to_scene should not crash")

func test_show_notification():
	"""Test notification display"""
	# Test that notification method doesn't crash
	base_screen.show_notification("Test notification")
	assert_true(true, "show_notification should not crash")

func test_show_error():
	"""Test error display"""
	# Test that error method doesn't crash
	base_screen.show_error("Test error")
	assert_true(true, "show_error should not crash")

func test_character_updated_signal():
	"""Test character updated signal emission"""
	var signal_emitted = false
	base_screen.character_updated.connect(func(): signal_emitted = true)

	base_screen._on_character_changed(mock_character)

	assert_true(signal_emitted, "character_updated signal should be emitted")
	assert_eq(base_screen.character, mock_character, "Character should be updated")

func test_screen_closed_signal():
	"""Test screen closed signal emission"""
	var signal_emitted = false
	base_screen.screen_closed.connect(func(): signal_emitted = true)

	base_screen.navigate_back()

	assert_true(signal_emitted, "screen_closed signal should be emitted")
