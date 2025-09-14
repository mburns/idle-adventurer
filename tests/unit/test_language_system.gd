extends GutTest

# Test suite for the language learning system

var language_system: LanguageSystem
var test_character: Character

func before_each():
    language_system = LanguageSystem.new()
    test_character = Character.new()
    test_character.name = "TestCharacter"
    test_character.known_languages = ["Common"]

func test_language_system_initialization():
    """Test that language system initializes correctly"""
    assert_not_null(language_system, "Language system should be created")

    var languages = language_system.get_all_languages()
    assert_gt(languages.size(), 0, "Should have languages available")

    # Check that Common is available
    var common_language = language_system.get_language_data("Common")
    assert_not_null(common_language, "Common language should be available")

func test_get_all_languages():
    """Test getting all available languages"""
    var languages = language_system.get_all_languages()

    assert_gt(languages.size(), 10, "Should have many languages available")

    # Check that we have different types of languages
    var has_common = false
    var has_exotic = false
    var has_racial = false

    for language in languages:
        if language["name"] == "Common":
            has_common = true
        if language["type"] == "exotic":
            has_exotic = true
        if language["type"] == "racial":
            has_racial = true

    assert_true(has_common, "Should have Common language")
    assert_true(has_exotic, "Should have exotic languages")
    assert_true(has_racial, "Should have racial languages")

func test_get_language_data():
    """Test getting specific language data"""
    var common = language_system.get_language_data("Common")
    var draconic = language_system.get_language_data("Draconic")
    var invalid = language_system.get_language_data("InvalidLanguage")

    assert_not_null(common, "Common language should exist")
    assert_not_null(draconic, "Draconic language should exist")
    assert_null(invalid, "Invalid language should not exist")

    if common:
        assert_eq(common["name"], "Common", "Common language should have correct name")
        assert_eq(common["difficulty"], "common", "Common should be common difficulty")

    if draconic:
        assert_eq(draconic["name"], "Draconic", "Draconic language should have correct name")
        assert_eq(draconic["difficulty"], "exotic", "Draconic should be exotic difficulty")

func test_can_learn_language():
    """Test language learning eligibility"""
    # Character with Common only
    assert_true(language_system.can_learn_language(test_character, "Elvish"), "Should be able to learn Elvish")
    assert_true(language_system.can_learn_language(test_character, "Dwarvish"), "Should be able to learn Dwarvish")
    assert_false(language_system.can_learn_language(test_character, "Common"), "Should not be able to relearn Common")

    # Character that already knows the language
    test_character.known_languages.append("Elvish")
    assert_false(language_system.can_learn_language(test_character, "Elvish"), "Should not be able to relearn Elvish")

func test_learn_language():
    """Test learning a new language"""
    var initial_languages = test_character.known_languages.size()

    var result = language_system.learn_language(test_character, "Elvish")
    assert_true(result, "Should successfully learn Elvish")
    assert_true("Elvish" in test_character.known_languages, "Elvish should be in known languages")
    assert_eq(test_character.known_languages.size(), initial_languages + 1, "Should have one more language")

    # Try to learn same language again
    result = language_system.learn_language(test_character, "Elvish")
    assert_false(result, "Should not be able to learn same language twice")

func test_learn_language_requirements():
    """Test language learning requirements"""
    # Test intelligence requirement for exotic languages
    test_character.intelligence = 8 # Low intelligence

    var result = language_system.learn_language(test_character, "Draconic")
    assert_false(result, "Should not be able to learn exotic language with low intelligence")

    test_character.intelligence = 15 # High intelligence
    result = language_system.learn_language(test_character, "Draconic")
    assert_true(result, "Should be able to learn exotic language with high intelligence")

func test_get_learning_progress():
    """Test getting language learning progress"""
    var progress = language_system.get_learning_progress(test_character, "Elvish")
    assert_ge(progress, 0.0, "Progress should be non-negative")
    assert_le(progress, 1.0, "Progress should be at most 1.0")

    # Progress should be 0 for unknown language
    assert_eq(progress, 0.0, "Progress should be 0 for unknown language")

func test_add_learning_progress():
    """Test adding learning progress"""
    var initial_progress = language_system.get_learning_progress(test_character, "Elvish")

    language_system.add_learning_progress(test_character, "Elvish", 0.3)
    var new_progress = language_system.get_learning_progress(test_character, "Elvish")

    assert_gt(new_progress, initial_progress, "Progress should increase")
    assert_eq(new_progress, 0.3, "Progress should be exactly 0.3")

func test_auto_learn_on_completion():
    """Test automatic learning when progress reaches 100%"""
    language_system.add_learning_progress(test_character, "Elvish", 0.9)
    assert_false("Elvish" in test_character.known_languages, "Should not know Elvish yet")

    language_system.add_learning_progress(test_character, "Elvish", 0.1)
    assert_true("Elvish" in test_character.known_languages, "Should automatically learn Elvish at 100%")

func test_get_available_languages():
    """Test getting languages available to learn"""
    var available = language_system.get_available_languages(test_character)

    assert_gt(available.size(), 0, "Should have available languages")
    assert_false("Common" in available, "Common should not be available (already known)")

    # Learn a language and check it's no longer available
    language_system.learn_language(test_character, "Elvish")
    available = language_system.get_available_languages(test_character)
    assert_false("Elvish" in available, "Elvish should not be available after learning")

func test_get_languages_by_difficulty():
    """Test getting languages by difficulty level"""
    var common_languages = language_system.get_languages_by_difficulty("common")
    var exotic_languages = language_system.get_languages_by_difficulty("exotic")
    var racial_languages = language_system.get_languages_by_difficulty("racial")

    assert_gt(common_languages.size(), 0, "Should have common languages")
    assert_gt(exotic_languages.size(), 0, "Should have exotic languages")
    assert_gt(racial_languages.size(), 0, "Should have racial languages")

    # Check that all returned languages have correct difficulty
    for language in common_languages:
        assert_eq(language["difficulty"], "common", "Should be common difficulty")

    for language in exotic_languages:
        assert_eq(language["difficulty"], "exotic", "Should be exotic difficulty")

func test_language_learning_time():
    """Test language learning time calculation"""
    var elvish = language_system.get_language_data("Elvish")
    var draconic = language_system.get_language_data("Draconic")

    if elvish and draconic:
        var elvish_time = language_system.get_learning_time(elvish, test_character)
        var draconic_time = language_system.get_learning_time(draconic, test_character)

        assert_gt(elvish_time, 0, "Elvish learning time should be positive")
        assert_gt(draconic_time, 0, "Draconic learning time should be positive")
        assert_gt(draconic_time, elvish_time, "Exotic language should take longer than common")

func test_racial_language_bonuses():
    """Test racial language bonuses"""
    # Test with different races
    test_character.race = "Elf"
    var elvish_bonus = language_system.get_racial_language_bonus(test_character, "Elvish")
    assert_gt(elvish_bonus, 0, "Elf should have bonus for Elvish")

    test_character.race = "Dwarf"
    var dwarvish_bonus = language_system.get_racial_language_bonus(test_character, "Dwarvish")
    assert_gt(dwarvish_bonus, 0, "Dwarf should have bonus for Dwarvish")

    # Non-racial language should have no bonus
    var common_bonus = language_system.get_racial_language_bonus(test_character, "Common")
    assert_eq(common_bonus, 0, "Common should have no racial bonus")

func test_class_language_bonuses():
    """Test class language bonuses"""
    test_character.character_class = "Wizard"
    var arcane_bonus = language_system.get_class_language_bonus(test_character, "Draconic")
    assert_gt(arcane_bonus, 0, "Wizard should have bonus for arcane languages")

    test_character.character_class = "Cleric"
    var divine_bonus = language_system.get_class_language_bonus(test_character, "Celestial")
    assert_gt(divine_bonus, 0, "Cleric should have bonus for divine languages")

func test_language_learning_activities():
    """Test language learning through activities"""
    var learning_activities = language_system.get_language_learning_activities()

    assert_gt(learning_activities.size(), 0, "Should have language learning activities")

    for activity in learning_activities:
        assert_true(activity.has("name"), "Activity should have name")
        assert_true(activity.has("language"), "Activity should specify language")
        assert_true(activity.has("daily_progress"), "Activity should have daily progress")
        assert_true(activity.has("cost_per_day"), "Activity should have cost")

func test_language_fluency_levels():
    """Test language fluency levels"""
    # Test different fluency levels
    var fluency_levels = language_system.get_fluency_levels()
    assert_gt(fluency_levels.size(), 0, "Should have fluency levels")

    # Test getting fluency level for character
    test_character.known_languages = ["Common", "Elvish"]
    var common_fluency = language_system.get_character_fluency(test_character, "Common")
    var elvish_fluency = language_system.get_character_fluency(test_character, "Elvish")
    var unknown_fluency = language_system.get_character_fluency(test_character, "Dwarvish")

    assert_gt(common_fluency, 0, "Known language should have fluency")
    assert_gt(elvish_fluency, 0, "Known language should have fluency")
    assert_eq(unknown_fluency, 0, "Unknown language should have no fluency")

func test_language_learning_signals():
    """Test that language learning signals are emitted correctly"""
    var language_learned_called = false
    var learning_progress_called = false

    language_system.language_learned.connect(func(_char, _lang): language_learned_called = true)
    language_system.learning_progress.connect(func(_char, _lang, _progress): learning_progress_called = true)

    # Add learning progress
    language_system.add_learning_progress(test_character, "Elvish", 0.5)
    assert_true(learning_progress_called, "learning_progress signal should be emitted")

    # Complete learning
    language_system.add_learning_progress(test_character, "Elvish", 0.5)
    assert_true(language_learned_called, "language_learned signal should be emitted")

func test_language_learning_limits():
    """Test language learning limits based on character level"""
    test_character.level = 1
    var max_languages = language_system.get_max_languages(test_character)
    assert_gt(max_languages, 1, "Should be able to learn more than 1 language")

    # Test that high-level characters can learn more languages
    test_character.level = 10
    var high_level_max = language_system.get_max_languages(test_character)
    assert_gt(high_level_max, max_languages, "Higher level should allow more languages")

func test_language_forgetting():
    """Test forgetting languages (if implemented)"""
    test_character.known_languages = ["Common", "Elvish", "Dwarvish"]
    var initial_count = test_character.known_languages.size()

    # Try to forget Common (should fail - can't forget Common)
    var result = language_system.forget_language(test_character, "Common")
    assert_false(result, "Should not be able to forget Common")
    assert_eq(test_character.known_languages.size(), initial_count, "Language count should not change")

    # Try to forget Elvish (should succeed if implemented)
    result = language_system.forget_language(test_character, "Elvish")
    # This test depends on whether forgetting is implemented
    if result:
        assert_lt(test_character.known_languages.size(), initial_count, "Language count should decrease")
        assert_false("Elvish" in test_character.known_languages, "Elvish should not be in known languages")
