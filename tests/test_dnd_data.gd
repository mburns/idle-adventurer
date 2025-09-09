extends TestBase

func test_race_data():
	# Test getting race data
	var human_data = DnDData.get_race("Human")
	assert_not_null(human_data, "Human race data should exist")
	assert_true(human_data.has("ability_increases"), "Race data should have ability_increases")
	assert_eq(human_data.ability_increases.strength, 1, "Human should get +1 to all abilities")
	
	# Test invalid race
	var invalid_data = DnDData.get_race("InvalidRace")
	assert_true(invalid_data.is_empty(), "Invalid race should return empty data")

func test_class_data():
	# Test getting class data
	var barbarian_data = DnDData.get_class("Barbarian")
	assert_not_null(barbarian_data, "Barbarian class data should exist")
	assert_eq(barbarian_data.hit_die, 12, "Barbarian should have d12 hit die")
	assert_true(barbarian_data.saving_throws.has("strength"), "Barbarian should have Strength saving throw")
	
	# Test invalid class
	var invalid_data = DnDData.get_class("InvalidClass")
	assert_true(invalid_data.is_empty(), "Invalid class should return empty data")

func test_background_data():
	# Test getting background data
	var acolyte_data = DnDData.get_background("Acolyte")
	assert_not_null(acolyte_data, "Acolyte background data should exist")
	assert_true(acolyte_data.skill_proficiencies.has("Insight"), "Acolyte should have Insight proficiency")
	assert_true(acolyte_data.skill_proficiencies.has("Religion"), "Acolyte should have Religion proficiency")

func test_skill_data():
	# Test getting skill data
	var athletics_data = DnDData.get_skill("Athletics")
	assert_not_null(athletics_data, "Athletics skill data should exist")
	assert_eq(athletics_data.ability, "strength", "Athletics should be based on Strength")
	assert_true(athletics_data.description.length() > 0, "Skill should have description")

func test_data_arrays():
	# Test getting all data arrays
	var races = DnDData.get_race_names()
	assert_gt(races.size(), 0, "Should have race names")
	assert_true(races.has("Human"), "Should include Human race")
	
	var classes = DnDData.get_class_names()
	assert_gt(classes.size(), 0, "Should have class names")
	assert_true(classes.has("Barbarian"), "Should include Barbarian class")
	
	var backgrounds = DnDData.get_background_names()
	assert_gt(backgrounds.size(), 0, "Should have background names")
	assert_true(backgrounds.has("Acolyte"), "Should include Acolyte background")
	
	var skills = DnDData.get_skill_names()
	assert_gt(skills.size(), 0, "Should have skill names")
	assert_true(skills.has("Athletics"), "Should include Athletics skill")
