extends TestBase

var character: Character

func before_each():
    character = Character.new()
    character.name = "Test Character"
    character.strength = 15
    character.dexterity = 14
    character.constitution = 13
    character.intelligence = 12
    character.wisdom = 10
    character.charisma = 8

func test_activity_duration_calculation():
    # Test duration calculation with different ability scores
    var duration = IdleMechanics.calculate_activity_duration("Push a Rock", character)
    assert_gt(duration, 0, "Activity duration should be positive")

    # Test that higher ability scores reduce duration
    character.strength = 20
    var faster_duration = IdleMechanics.calculate_activity_duration("Push a Rock", character)
    assert_lt(faster_duration, duration, "Higher strength should reduce duration")

func test_activity_rewards_calculation():
    # Test reward calculation
    var rewards = IdleMechanics.calculate_activity_rewards("Push a Rock", character)
    assert_gt(rewards.xp, 0, "Activity should give XP")
    assert_gt(rewards.gold, 0, "Activity should give gold")

    # Test that higher ability scores increase rewards
    character.strength = 20
    var better_rewards = IdleMechanics.calculate_activity_rewards("Push a Rock", character)
    assert_gt(better_rewards.xp, rewards.xp, "Higher strength should give more XP")
    assert_gt(better_rewards.gold, rewards.gold, "Higher strength should give more gold")

func test_activity_availability():
    # Test that character can perform activity when idle
    assert_true(IdleMechanics.can_perform_activity("Push a Rock", character), "Character should be able to perform activity when idle")

    # Test that character cannot perform activity when busy
    character.start_activity("Test Activity", 60.0)
    assert_false(IdleMechanics.can_perform_activity("Push a Rock", character), "Character should not be able to perform activity when busy")

func test_activity_start_and_complete():
    # Test starting an activity
    var success = IdleMechanics.start_activity("Push a Rock", character)
    assert_true(success, "Should be able to start activity")
    assert_eq(character.current_activity, "Push a Rock", "Current activity should be set")

    # Test completing an activity
    var rewards = IdleMechanics.complete_activity(character)
    assert_gt(rewards.xp, 0, "Completing activity should give rewards")
    assert_eq(character.current_activity, "", "Activity should be cleared after completion")

func test_activities_for_ability():
    # Test getting activities for specific abilities
    var strength_activities = IdleMechanics.get_activities_for_ability("strength")
    assert_gt(strength_activities.size(), 0, "Should have strength activities")
    assert_true(strength_activities.has("Push a Rock"), "Should include Push a Rock activity")

    var dexterity_activities = IdleMechanics.get_activities_for_ability("dexterity")
    assert_gt(dexterity_activities.size(), 0, "Should have dexterity activities")
    assert_true(dexterity_activities.has("Practice Acrobatics"), "Should include acrobatics activity")

func test_activity_data():
    # Test getting activity data
    var activity_data = IdleMechanics.get_activity("Push a Rock")
    assert_not_null(activity_data, "Activity data should exist")
    assert_eq(activity_data.ability, "strength", "Push a Rock should be strength-based")
    assert_gt(activity_data.base_duration, 0, "Activity should have positive duration")
    assert_gt(activity_data.base_xp, 0, "Activity should give XP")

    # Test invalid activity
    var invalid_data = IdleMechanics.get_activity("Invalid Activity")
    assert_true(invalid_data.is_empty(), "Invalid activity should return empty data")

func test_all_activities():
    # Test getting all activities
    var all_activities = IdleMechanics.get_all_activities()
    assert_gt(all_activities.size(), 0, "Should have activities")
    assert_true(all_activities.has("Push a Rock"), "Should include Push a Rock")
    assert_true(all_activities.has("Study Arcana"), "Should include Study Arcana")
    assert_true(all_activities.has("Short Rest"), "Should include Short Rest")
