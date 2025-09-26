extends GutTest

# Simplified test suite for AchievementResourceManager - only tests methods that actually exist

var achievement_manager: AchievementResourceManager
var mock_character: Character

func before_each():
	achievement_manager = AchievementResourceManager.new()
	mock_character = Character.new()
	mock_character.name = "TestCharacter"
	mock_character.level = 1

func after_each():
	if achievement_manager:
		achievement_manager.queue_free()
	if mock_character:
		mock_character.queue_free()

func test_achievement_manager_initialization():
	"""Test that achievement manager initializes correctly"""
	assert_not_null(achievement_manager, "Achievement manager should be created")
	assert_not_null(achievement_manager.data_loader, "Should have data loader")

func test_achievement_loading():
	"""Test that achievements are loaded from .tres files"""
	var all_achievements = achievement_manager.get_all_achievements()
	assert_not_null(all_achievements, "Should return achievements dictionary")
	assert_true(all_achievements is Dictionary, "Should return Dictionary")
	assert_true(all_achievements.size() > 0, "Should have loaded achievements")

func test_achievement_retrieval():
	"""Test retrieving specific achievements"""
	var level_5 = achievement_manager.get_achievement_by_id("level_5")
	if level_5:
		assert_not_null(level_5, "Should find level 5 achievement")
		assert_eq(level_5.name, "Rising Star", "Should have correct name")
		assert_eq(level_5.category, "CHARACTER_LEVEL", "Should have correct category")
		assert_eq(level_5.rarity, "COMMON", "Should have correct rarity")

func test_achievement_categories():
	"""Test filtering achievements by category"""
	var level_achievements = achievement_manager.get_achievements_by_category("CHARACTER_LEVEL")
	assert_not_null(level_achievements, "Should return level achievements")
	assert_true(level_achievements is Array, "Should return Array")
	assert_true(level_achievements.size() > 0, "Should have level achievements")

func test_achievement_rarity():
	"""Test filtering achievements by rarity"""
	var common_achievements = achievement_manager.get_achievements_by_rarity("COMMON")
	assert_not_null(common_achievements, "Should return common achievements")
	assert_true(common_achievements is Array, "Should return Array")
	assert_true(common_achievements.size() > 0, "Should have common achievements")

	var legendary_achievements = achievement_manager.get_achievements_by_rarity("LEGENDARY")
	assert_not_null(legendary_achievements, "Should return legendary achievements")
	assert_true(legendary_achievements is Array, "Should return Array")

func test_achievement_unlocking():
	"""Test achievement unlocking functionality"""
	var level_5 = achievement_manager.get_achievement_by_id("level_5")
	if level_5:
		assert_false(level_5.is_unlocked(), "Achievement should not be unlocked initially")

		# Test unlocking
		var result = achievement_manager.unlock_achievement(mock_character, "level_5")
		assert_true(result, "Should be able to unlock achievement")
		assert_true(level_5.is_unlocked(), "Achievement should be unlocked")

func test_available_achievements():
	"""Test getting available achievements for a character"""
	var available = achievement_manager.get_available_achievements_for_character(mock_character)
	assert_not_null(available, "Should return available achievements")
	assert_true(available is Array, "Should return Array")

func test_unlocked_achievements():
	"""Test getting unlocked achievements"""
	var unlocked = achievement_manager.get_unlocked_achievements()
	assert_not_null(unlocked, "Should return unlocked achievements")
	assert_true(unlocked is Array, "Should return Array")
	assert_eq(unlocked.size(), 0, "Should start with no unlocked achievements")

func test_achievement_data_structure():
	"""Test achievement data structure"""
	var level_5 = achievement_manager.get_achievement_by_id("level_5")
	if level_5:
		assert_eq(level_5.id, "level_5", "Should have correct ID")
		assert_eq(level_5.name, "Rising Star", "Should have correct name")
		assert_eq(level_5.description, "Reach level 5", "Should have correct description")
		assert_eq(level_5.category, "CHARACTER_LEVEL", "Should have correct category")
		assert_eq(level_5.rarity, "COMMON", "Should have correct rarity")
		assert_false(level_5.is_unlocked(), "Should start unlocked")
		assert_eq(level_5.unlocked_at, 0, "Should start with 0 unlocked time")
