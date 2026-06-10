extends GutTest

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

func test_achievement_initialization():
	# Test that achievements are initialized
	var all_achievements = achievement_manager.get_all_achievements()
	assert_true(all_achievements.size() > 0, "Should have achievements initialized")

	# Test specific achievements exist
	assert_not_null(achievement_manager.get_achievement_by_id("level_5"), "Should have level_5 achievement")
	assert_not_null(achievement_manager.get_achievement_by_id("level_10"), "Should have level_10 achievement")
	assert_not_null(achievement_manager.get_achievement_by_id("level_20"), "Should have level_20 achievement")

func test_achievement_categories():
	# Test achievement categories
	var level_achievements = achievement_manager.get_achievements_by_category("CHARACTER_LEVEL")
	assert_true(level_achievements.size() > 0, "Should have character level achievements")

	var character_achievements = achievement_manager.get_achievements_by_category("CHARACTER_DEVELOPMENT")
	assert_true(character_achievements.size() > 0, "Should have character development achievements")

	var collection_achievements = achievement_manager.get_achievements_by_category("COLLECTION")
	assert_true(collection_achievements.size() > 0, "Should have collection achievements")

func test_achievement_rarity():
	# Test achievement rarity
	var common_achievements = achievement_manager.get_achievements_by_rarity("COMMON")
	assert_true(common_achievements.size() > 0, "Should have common achievements")

	var legendary_achievements = achievement_manager.get_achievements_by_rarity("LEGENDARY")
	assert_true(legendary_achievements.size() > 0, "Should have legendary achievements")

func test_achievement_progress():
	# Test achievement progress tracking
	var first_kill = achievement_manager.get_achievement_by_id("first_kill")
	assert_not_null(first_kill, "Should have first_kill achievement")

	var progress = achievement_manager.get_achievement_progress("first_kill")
	assert_true(progress.has("monsters_defeated"), "Should track monsters_defeated progress")
	assert_eq(progress["monsters_defeated"]["current"], 0, "Should start with 0 monsters defeated")
	assert_eq(progress["monsters_defeated"]["required"], 1, "Should require 1 monster defeated")

func test_achievement_unlocking():
	# Test achievement unlocking
	var first_kill = achievement_manager.get_achievement_by_id("first_kill")
	assert_false(first_kill.unlocked, "First kill should not be unlocked initially")

	# Simulate character progress
	mock_character.level = 2
	achievement_manager.check_achievements(mock_character)

	# Check if first_level achievement is unlocked
	var first_level = achievement_manager.get_achievement_by_id("first_level")
	assert_true(first_level.unlocked, "First level achievement should be unlocked")

func test_achievement_completion_percentage():
	# Test completion percentage calculation
	var initial_percentage = achievement_manager.get_completion_percentage()
	assert_eq(initial_percentage, 0.0, "Should start with 0% completion")

	# Unlock an achievement
	var first_level = achievement_manager.get_achievement_by_id("first_level")
	first_level.unlocked = true
	first_level.unlocked_at = Time.get_unix_time_from_system()

	var new_percentage = achievement_manager.get_completion_percentage()
	assert_true(new_percentage > 0.0, "Completion percentage should increase after unlocking achievement")

func test_unlocked_achievements():
	# Test getting unlocked achievements
	var unlocked = achievement_manager.get_unlocked_achievements()
	assert_eq(unlocked.size(), 0, "Should start with no unlocked achievements")

	# Unlock an achievement
	var first_level = achievement_manager.get_achievement_by_id("first_level")
	first_level.unlocked = true
	first_level.unlocked_at = Time.get_unix_time_from_system()

	unlocked = achievement_manager.get_unlocked_achievements()
	assert_eq(unlocked.size(), 1, "Should have 1 unlocked achievement")

func test_locked_achievements():
	# Test getting locked achievements
	var locked = achievement_manager.get_locked_achievements()
	var total = achievement_manager.get_total_achievements()
	assert_eq(locked.size(), total, "All achievements should be locked initially")

func test_recent_achievements():
	# Test getting recent achievements
	var recent = achievement_manager.get_recent_achievements(5)
	assert_eq(recent.size(), 0, "Should have no recent achievements initially")

	# Unlock some achievements
	var first_level = achievement_manager.get_achievement_by_id("first_level")
	first_level.unlocked = true
	first_level.unlocked_at = Time.get_unix_time_from_system()

	var first_kill = achievement_manager.get_achievement_by_id("first_kill")
	first_kill.unlocked = true
	first_kill.unlocked_at = Time.get_unix_time_from_system() + 1

	recent = achievement_manager.get_recent_achievements(5)
	assert_eq(recent.size(), 2, "Should have 2 recent achievements")

	# Most recent should be first_kill
	assert_eq(recent[0].id, "first_kill", "Most recent should be first_kill")

func test_achievement_reset():
	# Test resetting achievements
	var first_level = achievement_manager.get_achievement_by_id("first_level")
	first_level.unlocked = true
	first_level.unlocked_at = Time.get_unix_time_from_system()

	achievement_manager.reset_achievements()

	assert_false(first_level.unlocked, "Achievement should be locked after reset")
	assert_eq(first_level.unlocked_at, 0.0, "Unlocked time should be reset")

func test_force_unlock_achievement():
	# Test force unlocking an achievement
	var first_kill = achievement_manager.get_achievement_by_id("first_kill")
	assert_false(first_kill.unlocked, "Achievement should be locked initially")

	achievement_manager.force_unlock_achievement("first_kill")

	assert_true(first_kill.unlocked, "Achievement should be unlocked after force unlock")
	assert_true(first_kill.unlocked_at > 0.0, "Unlocked time should be set")

func test_achievement_requirements():
	# Test achievement requirements
	var monster_slayer = achievement_manager.get_achievement_by_id("monster_slayer")
	assert_not_null(monster_slayer, "Should have monster_slayer achievement")

	var progress = achievement_manager.get_achievement_progress("monster_slayer")
	assert_eq(progress["monsters_defeated"]["required"], 100, "Should require 100 monsters defeated")

func test_achievement_rewards():
	# Test achievement rewards
	var first_kill = achievement_manager.get_achievement_by_id("first_kill")
	assert_true(first_kill.reward.has("xp"), "Should have XP reward")
	assert_true(first_kill.reward.has("gold"), "Should have gold reward")
	assert_eq(first_kill.reward["xp"], 100, "Should give 100 XP")
	assert_eq(first_kill.reward["gold"], 50, "Should give 50 gold")

func test_achievement_signals():
	# Test achievement signals
	var signal_emitted = false
	var unlocked_achievement = null

	achievement_manager.achievement_unlocked.connect(func(achievement):
		signal_emitted = true
		unlocked_achievement = achievement
	)

	# Force unlock an achievement
	achievement_manager.force_unlock_achievement("first_kill")

	assert_true(signal_emitted, "Achievement unlocked signal should be emitted")
	assert_not_null(unlocked_achievement, "Signal should pass the achievement")
	assert_eq(unlocked_achievement.id, "first_kill", "Signal should pass correct achievement")

func test_achievement_categories_completion():
	# Test category completion
	var combat_achievements = achievement_manager.get_achievements_by_category("COMBAT")

	# Unlock all combat achievements
	for achievement in combat_achievements:
		achievement.unlocked = true
		achievement.unlocked_at = Time.get_unix_time_from_system()

	# Check if category completion signal would be emitted
	var category_completed = false
	achievement_manager.achievement_category_completed.connect(func(category):
		if category == "COMBAT":
			category_completed = true
	)

	# Trigger category completion check
	achievement_manager._check_category_completion("COMBAT")

	assert_true(category_completed, "Category completion signal should be emitted")

func test_achievement_data_structure():
	# Test achievement data structure
	var first_kill = achievement_manager.get_achievement_by_id("first_kill")

	assert_eq(first_kill.id, "first_kill", "Should have correct ID")
	assert_eq(first_kill.name, "First Blood", "Should have correct name")
	assert_eq(first_kill.description, "Defeat your first monster", "Should have correct description")
	assert_eq(first_kill.category, "COMBAT", "Should have correct category")
	assert_eq(first_kill.rarity, "COMMON", "Should have correct rarity")
	assert_false(first_kill.unlocked, "Should start unlocked")
	assert_eq(first_kill.unlocked_at, 0.0, "Should start with 0 unlocked time")

func test_achievement_progress_calculation():
	# Test progress calculation
	var monster_slayer = achievement_manager.get_achievement_by_id("monster_slayer")

	# Set some progress
	achievement_manager.progress_data["monsters_defeated"] = 50

	var progress = achievement_manager.get_achievement_progress("monster_slayer")
	assert_eq(progress["monsters_defeated"]["current"], 50, "Should track current progress")
	assert_eq(progress["monsters_defeated"]["required"], 100, "Should track required progress")
	assert_eq(progress["monsters_defeated"]["percentage"], 50.0, "Should calculate correct percentage")

func test_achievement_progress_capping():
	# Test that progress percentage is capped at 100%
	var first_kill = achievement_manager.get_achievement_by_id("first_kill")

	# Set progress beyond requirement
	achievement_manager.progress_data["monsters_defeated"] = 5

	var progress = achievement_manager.get_achievement_progress("first_kill")
	assert_eq(progress["monsters_defeated"]["percentage"], 100.0, "Percentage should be capped at 100%")

func test_achievement_availability():
	# Test that all achievements are available
	var available_achievements = [
		"first_kill", "monster_slayer", "dragon_slayer",
		"first_level", "level_10", "level_20",
		"first_item", "treasure_hunter", "hoarder",
		"first_quest", "quest_master",
		"idle_master", "perfectionist",
		"first_session", "dedicated_player"
	]

	for achievement_id in available_achievements:
		var achievement = achievement_manager.get_achievement_by_id(achievement_id)
		assert_not_null(achievement, "Should have achievement: " + achievement_id)

func test_achievement_counting():
	# Test achievement counting
	var total = achievement_manager.get_total_achievements()
	var unlocked = achievement_manager.get_unlocked_count()
	var locked = achievement_manager.get_locked_achievements().size()

	assert_eq(unlocked + locked, total, "Unlocked + locked should equal total")
	assert_eq(unlocked, 0, "Should start with 0 unlocked")
	assert_eq(locked, total, "Should start with all locked")
