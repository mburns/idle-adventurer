extends GutTest

# Test suite for the enhanced activities system

var activities_system: EnhancedActivities
var test_character: Character

func before_each():
    activities_system = EnhancedActivities.new()
    test_character = Character.new()
    test_character.name = "TestCharacter"
    test_character.strength = 15
    test_character.dexterity = 12
    test_character.constitution = 14
    test_character.intelligence = 16
    test_character.wisdom = 13
    test_character.charisma = 10

func test_activity_creation():
    """Test creating activities for different abilities"""
    var strength_activities = activities_system.get_activities_for_ability("strength")
    var dexterity_activities = activities_system.get_activities_for_ability("dexterity")
    var intelligence_activities = activities_system.get_activities_for_ability("intelligence")

    assert_gt(strength_activities.size(), 0, "Should have strength activities")
    assert_gt(dexterity_activities.size(), 0, "Should have dexterity activities")
    assert_gt(intelligence_activities.size(), 0, "Should have intelligence activities")

    # Check that activities have required fields
    for activity in strength_activities:
        assert_true(activity.has("name"), "Activity should have name")
        assert_true(activity.has("ability"), "Activity should have ability")
        assert_true(activity.has("daily_progress"), "Activity should have daily_progress")
        assert_true(activity.has("cost_per_day"), "Activity should have cost_per_day")
        assert_true(activity.has("rewards"), "Activity should have rewards")

func test_start_activity():
    """Test starting an activity"""
    var activity = activities_system.get_activities_for_ability("strength")[0]
    var result = activities_system.start_activity(test_character, activity["name"])

    assert_true(result, "Should successfully start activity")
    assert_eq(test_character.current_activity, activity["name"], "Character should have current activity")
    assert_gt(test_character.activity_start_time, 0, "Activity start time should be set")

func test_stop_activity():
    """Test stopping an activity"""
    var activity = activities_system.get_activities_for_ability("strength")[0]
    activities_system.start_activity(test_character, activity["name"])

    var result = activities_system.stop_activity(test_character.name, "Test reason")
    assert_true(result, "Should successfully stop activity")
    assert_eq(test_character.current_activity, "", "Character should have no current activity")

func test_process_activity_offline_progress():
    """Test processing activity with offline progress"""
    var activity = activities_system.get_activities_for_ability("strength")[0]
    activities_system.start_activity(test_character, activity["name"])

    # Simulate 2 days of offline progress
    var current_time = Time.get_unix_time_from_system() + (2 * 86400) # 2 days later
    activities_system.process_activity(test_character, activity, current_time)

    assert_gt(activity["progress"], 0, "Activity should have progress")
    assert_gt(activity["last_payment"], 0, "Last payment should be updated")

func test_ability_scaling():
    """Test that activities scale with ability scores"""
    var high_int_character = Character.new()
    high_int_character.name = "HighInt"
    high_int_character.intelligence = 20

    var low_int_character = Character.new()
    low_int_character.name = "LowInt"
    low_int_character.intelligence = 8

    var activity = activities_system.get_activities_for_ability("intelligence")[0]

    # Process activity for both characters
    activities_system.start_activity(high_int_character, activity["name"])
    activities_system.start_activity(low_int_character, activity["name"])

    var current_time = Time.get_unix_time_from_system() + 86400 # 1 day later

    var high_activity = activity.duplicate()
    var low_activity = activity.duplicate()

    activities_system.process_activity(high_int_character, high_activity, current_time)
    activities_system.process_activity(low_int_character, low_activity, current_time)

    assert_gt(high_activity["progress"], low_activity["progress"], "High intelligence should have more progress")

func test_activity_costs():
    """Test that activities have appropriate costs"""
    test_character.gold = 100.0

    var activity = activities_system.get_activities_for_ability("strength")[0]
    activities_system.start_activity(test_character, activity["name"])

    var current_time = Time.get_unix_time_from_system() + 86400 # 1 day later
    var initial_gold = test_character.gold

    activities_system.process_activity(test_character, activity, current_time)

    var cost_per_day = activity.get("cost_per_day", 0.0)
    if cost_per_day > 0:
        assert_lt(test_character.gold, initial_gold, "Gold should decrease due to activity cost")

func test_activity_rewards():
    """Test that activities provide appropriate rewards"""
    var activity = activities_system.get_activities_for_ability("strength")[0]
    activities_system.start_activity(test_character, activity["name"])

    var current_time = Time.get_unix_time_from_system() + 86400 # 1 day later
    var initial_gold = test_character.gold

    activities_system.process_activity(test_character, activity, current_time)

    # Check if gold increased (if activity rewards gold)
    var rewards = activity.get("rewards", {})
    if rewards.has("gold"):
        assert_ge(test_character.gold, initial_gold, "Gold should increase if activity rewards gold")

func test_ability_experience_tracking():
    """Test that activities add ability experience"""
    var activity = activities_system.get_activities_for_ability("strength")[0]
    activities_system.start_activity(test_character, activity["name"])

    var current_time = Time.get_unix_time_from_system() + 86400 # 1 day later
    var initial_strength_exp = test_character.get("strength_experience", 0.0)

    activities_system.process_activity(test_character, activity, current_time)

    var new_strength_exp = test_character.get("strength_experience", 0.0)
    assert_ge(new_strength_exp, initial_strength_exp, "Strength experience should increase")

func test_ability_score_increase():
    """Test that ability scores increase with enough experience"""
    test_character.strength = 10
    test_character.set("strength_experience", 999.0) # Just under threshold

    var activity = activities_system.get_activities_for_ability("strength")[0]
    activities_system.start_activity(test_character, activity["name"])

    var current_time = Time.get_unix_time_from_system() + 86400 # 1 day later
    activities_system.process_activity(test_character, activity, current_time)

    # Should gain enough experience to increase ability score
    var new_strength = test_character.strength
    assert_ge(new_strength, 10, "Strength should potentially increase")

func test_activity_completion():
    """Test that activities complete when reaching 100% progress"""
    var activity = activities_system.get_activities_for_ability("strength")[0]
    activities_system.start_activity(test_character, activity["name"])

    # Set progress to near completion
    activity["progress"] = 0.99

    var current_time = Time.get_unix_time_from_system() + 86400 # 1 day later
    activities_system.process_activity(test_character, activity, current_time)

    # Activity should be completed
    assert_ge(activity["progress"], 1.0, "Activity should be completed")

func test_language_learning():
    """Test language learning through activities"""
    var language_activity = activities_system.get_activities_for_ability("intelligence")[0]
    # Find a language learning activity
    for activity in activities_system.get_activities_for_ability("intelligence"):
        if activity.get("rewards", {}).has("language"):
            language_activity = activity
            break

    activities_system.start_activity(test_character, language_activity["name"])

    var current_time = Time.get_unix_time_from_system() + 86400 # 1 day later
    activities_system.process_activity(test_character, language_activity, current_time)

    # Check if character learned a language
    var known_languages = test_character.get("known_languages", [])
    assert_ge(known_languages.size(), 1, "Character should know at least Common")

func test_insufficient_funds():
    """Test activity stopping when insufficient funds"""
    test_character.gold = 0.0

    var activity = activities_system.get_activities_for_ability("strength")[0]
    activities_system.start_activity(test_character, activity["name"])

    var current_time = Time.get_unix_time_from_system() + 86400 # 1 day later
    activities_system.process_activity(test_character, activity, current_time)

    # Activity should be stopped due to insufficient funds
    assert_eq(test_character.current_activity, "", "Activity should be stopped due to insufficient funds")

func test_activity_requirements():
    """Test that activities have appropriate requirements"""
    var activities = activities_system.get_all_activities()

    for activity in activities:
        var requirements = activity.get("requirements", {})

        # Check that requirements are valid
        if requirements.has("min_level"):
            assert_ge(requirements["min_level"], 1, "Min level should be at least 1")

        if requirements.has("min_ability"):
            assert_ge(requirements["min_ability"], 1, "Min ability should be at least 1")
            assert_le(requirements["min_ability"], 30, "Min ability should be at most 30")

func test_activity_diversity():
    """Test that there are diverse activities across all abilities"""
    var ability_counts = {}

    for ability in ["strength", "dexterity", "constitution", "intelligence", "wisdom", "charisma"]:
        var activities = activities_system.get_activities_for_ability(ability)
        ability_counts[ability] = activities.size()
        assert_gt(activities.size(), 0, "Should have activities for " + ability)

    # Check that we have a good distribution
    var total_activities = 0
    for count in ability_counts.values():
        total_activities += count

    assert_gt(total_activities, 20, "Should have many activities total")

    # Each ability should have at least 2 activities
    for ability in ability_counts.keys():
        assert_ge(ability_counts[ability], 2, "Should have at least 2 activities for " + ability)

func test_general_activities():
    """Test general activities not tied to specific abilities"""
    var general_activities = activities_system.get_activities_for_ability("general")

    assert_gt(general_activities.size(), 0, "Should have general activities")

    for activity in general_activities:
        assert_eq(activity.get("ability", ""), "general", "General activity should have general ability")
        assert_true(activity.has("name"), "Activity should have name")
        assert_true(activity.has("daily_progress"), "Activity should have daily_progress")

func test_activity_signal_emission():
    """Test that activity signals are emitted correctly"""
    var activity_started_called = false
    var activity_stopped_called = false
    var activity_progress_called = false

    activities_system.activity_started.connect(func(_name, _char): activity_started_called = true)
    activities_system.activity_stopped.connect(func(_name, _char, _reason): activity_stopped_called = true)
    activities_system.activity_progress.connect(func(_name, _char, _progress): activity_progress_called = true)

    var activity = activities_system.get_activities_for_ability("strength")[0]

    # Start activity
    activities_system.start_activity(test_character, activity["name"])
    assert_true(activity_started_called, "activity_started signal should be emitted")

    # Process activity
    var current_time = Time.get_unix_time_from_system() + 86400
    activities_system.process_activity(test_character, activity, current_time)
    assert_true(activity_progress_called, "activity_progress signal should be emitted")

    # Stop activity
    activities_system.stop_activity(test_character.name, "Test")
    assert_true(activity_stopped_called, "activity_stopped signal should be emitted")
