extends GutTest

var idle_mechanics: IdleMechanics

func before_each():
	idle_mechanics = IdleMechanics.new()

func after_each():
	if idle_mechanics:
		idle_mechanics.queue_free()

func test_load_rest_activities():
	idle_mechanics.load_rest_activities()

	# Should have loaded rest activities
	assert_true(idle_mechanics.activities.size() > 0, "Should have loaded activities")

	# Check for specific rest activities
	assert_true(idle_mechanics.activities.has("Short Rest"), "Should have Short Rest activity")
	assert_true(idle_mechanics.activities.has("Long Rest"), "Should have Long Rest activity")

func test_parse_rest_yaml():
	# This test is deprecated since we now use .tres resources instead of YAML parsing
	pending("YAML parsing removed - now using .tres resources")
	return
	var yaml_content = """
- id: short_rest
  name: Short Rest
  description: Take a short rest to recover
  ability: general
  base_duration: 20.0
  base_xp: 5
  rewards:
    xp: 5
    hit_points: 10
  requirements: {}
  activity_type: rest

- id: long_rest
  name: Long Rest
  description: Take a long rest to fully recover
  ability: general
  base_duration: 60.0
  base_xp: 10
  rewards:
    xp: 10
    hit_points: 50
  requirements: {}
  activity_type: rest
"""

	var activities = idle_mechanics.parse_rest_yaml(yaml_content)

	assert_eq(activities.size(), 2, "Should parse 2 activities")
	assert_eq(activities[0]["id"], "short_rest", "Should parse first activity id")
	assert_eq(activities[0]["name"], "Short Rest", "Should parse first activity name")
	assert_eq(activities[0]["base_duration"], 20.0, "Should parse duration as float")
	assert_eq(activities[0]["base_xp"], 5, "Should parse xp as int")
	assert_eq(activities[1]["id"], "long_rest", "Should parse second activity id")

func test_parse_simple_dict():
	var dict_string = "{xp: 5, hit_points: 10, gold: 0}"
	var result = idle_mechanics.parse_simple_dict(dict_string)

	assert_eq(result.size(), 3, "Should parse 3 key-value pairs")
	assert_eq(result["xp"], 5, "Should parse xp as int")
	assert_eq(result["hit_points"], 10, "Should parse hit_points as int")
	assert_eq(result["gold"], 0, "Should parse gold as int")

func test_parse_simple_dict_with_strings():
	var dict_string = "{name: Test, type: rest, category: general}"
	var result = idle_mechanics.parse_simple_dict(dict_string)

	assert_eq(result.size(), 3, "Should parse 3 key-value pairs")
	assert_eq(result["name"], "Test", "Should parse name as string")
	assert_eq(result["type"], "rest", "Should parse type as string")
	assert_eq(result["category"], "general", "Should parse category as string")

func test_create_activity_resource_from_data():
	var activity_data = {
		"name": "Test Rest",
		"ability": "general",
		"skill": "Test Skill",
		"base_duration": 30.0,
		"base_xp": 8,
		"base_gold": 0,
		"description": "A test rest activity",
		"daily_progress": 0.15,
		"cost_per_day": 1.0,
		"rewards": {"xp": 8, "hit_points": 15},
		"requirements": {"constitution": 12},
		"activity_type": "rest",
		"category": "test"
	}

	var activity_resource = idle_mechanics.create_activity_resource_from_data(activity_data)

	assert_not_null(activity_resource, "Should create activity resource")
	assert_eq(activity_resource.activity_name, "Test Rest", "Should set activity name")
	assert_eq(activity_resource.ability, "general", "Should set ability")
	assert_eq(activity_resource.skill, "Test Skill", "Should set skill")
	assert_eq(activity_resource.base_duration, 30.0, "Should set base duration")
	assert_eq(activity_resource.base_xp, 8, "Should set base xp")
	assert_eq(activity_resource.base_gold, 0, "Should set base gold")
	assert_eq(activity_resource.description, "A test rest activity", "Should set description")
	assert_eq(activity_resource.daily_progress, 0.15, "Should set daily progress")
	assert_eq(activity_resource.cost_per_day, 1.0, "Should set cost per day")
	assert_eq(activity_resource.rewards["xp"], 8, "Should set rewards")
	assert_eq(activity_resource.requirements["constitution"], 12, "Should set requirements")
	assert_eq(activity_resource.activity_type, "rest", "Should set activity type")
	assert_eq(activity_resource.category, "test", "Should set category")

func test_load_default_rest_activities():
	idle_mechanics.load_default_rest_activities()

	assert_true(idle_mechanics.activities.has("Short Rest"), "Should have Short Rest")
	assert_true(idle_mechanics.activities.has("Long Rest"), "Should have Long Rest")

	var short_rest = idle_mechanics.activities["Short Rest"]
	assert_eq(short_rest.activity_name, "Short Rest", "Should have correct name")
	assert_eq(short_rest.base_duration, 20.0, "Should have correct duration")
	assert_eq(short_rest.base_xp, 5, "Should have correct xp")

	var long_rest = idle_mechanics.activities["Long Rest"]
	assert_eq(long_rest.activity_name, "Long Rest", "Should have correct name")
	assert_eq(long_rest.base_duration, 60.0, "Should have correct duration")
	assert_eq(long_rest.base_xp, 10, "Should have correct xp")

func test_parse_rest_yaml_with_comments():
	# This test is deprecated since we now use .tres resources instead of YAML parsing
	pending("YAML parsing removed - now using .tres resources")
	return
	var yaml_content = """
# This is a comment
- id: meditation
  name: Meditation
  description: Focused meditation for mental clarity
  ability: wisdom
  base_duration: 30.0
  base_xp: 8
  # Another comment
  rewards:
    wisdom_exp: 8
    mental_clarity: 1
  requirements: {}
  activity_type: rest
"""

	var activities = idle_mechanics.parse_rest_yaml(yaml_content)

	assert_eq(activities.size(), 1, "Should parse 1 activity despite comments")
	assert_eq(activities[0]["id"], "meditation", "Should parse activity id")
	assert_eq(activities[0]["name"], "Meditation", "Should parse activity name")

func test_parse_rest_yaml_empty():
	# This test is deprecated since we now use .tres resources instead of YAML parsing
	pending("YAML parsing removed - now using .tres resources")
	return
	var yaml_content = ""
	var activities = idle_mechanics.parse_rest_yaml(yaml_content)

	assert_eq(activities.size(), 0, "Should return empty array for empty content")

func test_parse_rest_yaml_whitespace():
	# This test is deprecated since we now use .tres resources instead of YAML parsing
	pending("YAML parsing removed - now using .tres resources")
	return
	var yaml_content = """

- id: test_activity
  name: Test Activity
  description: A test activity with whitespace
  ability: general
  base_duration: 25.0
  base_xp: 6
  rewards: {}
  requirements: {}
  activity_type: rest

"""

	var activities = idle_mechanics.parse_rest_yaml(yaml_content)

	assert_eq(activities.size(), 1, "Should parse activity despite whitespace")
	assert_eq(activities[0]["id"], "test_activity", "Should parse activity id")
	assert_eq(activities[0]["name"], "Test Activity", "Should parse activity name")
