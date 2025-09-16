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

func test_activity_starting():
    # Test starting an activity
    var success = IdleMechanics.start_activity("Push a Rock", character)
    assert_true(success, "Should be able to start activity")
    assert_eq(character.current_activity, "Push a Rock", "Character should have current activity set")

func test_activity_completion():
    # Test activity completion
    IdleMechanics.start_activity("Push a Rock", character)
    var rewards = IdleMechanics.complete_activity(character)

    assert_not_null(rewards, "Should return rewards")
    assert_eq(character.current_activity, "", "Activity should be cleared after completion")

func test_activity_data_retrieval():
    # Test getting activity data
    var activity_data = IdleMechanics.get_activity_data("Push a Rock")
    assert_not_null(activity_data, "Should return activity data")

func test_activity_completion_check():
    # Test checking if activity is complete
    assert_false(IdleMechanics.is_activity_complete(character), "Activity should not be complete initially")

    IdleMechanics.start_activity("Push a Rock", character)
    # Simulate time passing by setting activity start time in the past
    character.activity_start_time = Time.get_unix_time_from_system() - 1000
    assert_true(IdleMechanics.is_activity_complete(character), "Activity should be complete after time passes")

func test_activity_start_and_complete():
    # Test starting an activity
    var success = IdleMechanics.start_activity("Push a Rock", character)
    assert_true(success, "Should be able to start activity")
    assert_eq(character.current_activity, "Push a Rock", "Current activity should be set")

    # Test completing an activity
    var rewards = IdleMechanics.complete_activity(character)
    assert_gt(rewards.xp, 0, "Completing activity should give rewards")
    assert_eq(character.current_activity, "", "Activity should be cleared after completion")

func test_all_activities():
    # Test getting all activities
    var all_activities = IdleMechanics.get_all_activities()
    assert_gt(all_activities.size(), 0, "Should have activities")
    assert_true(all_activities is Dictionary, "Should return a dictionary")
