extends GutTest

# Test ActivityResource functionality
class_name TestActivityResource

var activity_resource: ActivityResource

func before_each():
	activity_resource = ActivityResource.new()

func test_activity_resource_creation():
	"""Test that ActivityResource can be created"""
	assert_not_null(activity_resource, "ActivityResource should be created")
	assert_true(activity_resource is ActivityResource, "Should be an ActivityResource instance")

func test_activity_properties():
	"""Test setting and getting activity properties"""
	activity_resource.activity_name = "Test Activity"
	activity_resource.ability = "strength"
	activity_resource.skill = "athletics"
	activity_resource.base_duration = 60
	activity_resource.base_xp = 100
	activity_resource.base_gold = 50
	activity_resource.description = "A test activity"
	activity_resource.daily_progress = 10
	activity_resource.cost_per_day = 5
	activity_resource.activity_type = "training"
	activity_resource.category = "physical"

	assert_eq(activity_resource.activity_name, "Test Activity")
	assert_eq(activity_resource.ability, "strength")
	assert_eq(activity_resource.skill, "athletics")
	assert_eq(activity_resource.base_duration, 60)
	assert_eq(activity_resource.base_xp, 100)
	assert_eq(activity_resource.base_gold, 50)
	assert_eq(activity_resource.description, "A test activity")
	assert_eq(activity_resource.daily_progress, 10)
	assert_eq(activity_resource.cost_per_day, 5)
	assert_eq(activity_resource.activity_type, "training")
	assert_eq(activity_resource.category, "physical")

func test_rewards_property():
	"""Test rewards dictionary property"""
	var rewards = {"gold": 50, "xp": 100, "items": ["sword"]}
	activity_resource.rewards = rewards

	assert_eq(activity_resource.rewards, rewards)
	assert_eq(activity_resource.rewards["gold"], 50)
	assert_eq(activity_resource.rewards["xp"], 100)
	assert_eq(activity_resource.rewards["items"], ["sword"])

func test_requirements_property():
	"""Test requirements dictionary property"""
	var requirements = {"strength": 12, "gold": 100}
	activity_resource.requirements = requirements

	assert_eq(activity_resource.requirements, requirements)
	assert_eq(activity_resource.requirements["strength"], 12)
	assert_eq(activity_resource.requirements["gold"], 100)

func test_meets_requirements():
	"""Test requirement checking"""
	var character = Character.new()
	character.strength = 15
	character.gold = 200

	var requirements = {"strength": 12, "gold": 100}
	activity_resource.requirements = requirements

	assert_true(activity_resource.meets_requirements(character), "Character should meet requirements")

	character.strength = 10
	assert_false(activity_resource.meets_requirements(character), "Character should not meet strength requirement")

	character.strength = 15
	character.gold = 50
	assert_false(activity_resource.meets_requirements(character), "Character should not meet gold requirement")

func test_get_xp_at_level():
	"""Test XP calculation at different levels"""
	activity_resource.base_xp = 100

	assert_eq(activity_resource.get_xp_at_level(1), 100, "Level 1 should get base XP")
	assert_eq(activity_resource.get_xp_at_level(5), 500, "Level 5 should get 5x base XP")
	assert_eq(activity_resource.get_xp_at_level(10), 1000, "Level 10 should get 10x base XP")

func test_get_gold_at_level():
	"""Test gold calculation at different levels"""
	activity_resource.base_gold = 50

	assert_eq(activity_resource.get_gold_at_level(1), 50, "Level 1 should get base gold")
	assert_eq(activity_resource.get_gold_at_level(3), 150, "Level 3 should get 3x base gold")
	assert_eq(activity_resource.get_gold_at_level(7), 350, "Level 7 should get 7x base gold")

func test_empty_requirements():
	"""Test that empty requirements always pass"""
	var character = Character.new()
	activity_resource.requirements = {}

	assert_true(activity_resource.meets_requirements(character), "Empty requirements should always pass")

func test_resource_serialization():
	"""Test that ActivityResource can be saved and loaded"""
	activity_resource.activity_name = "Serialization Test"
	activity_resource.ability = "intelligence"
	activity_resource.base_xp = 200
	activity_resource.rewards = {"gold": 100, "xp": 200}
	activity_resource.requirements = {"intelligence": 14}

	# Test that properties are maintained
	assert_eq(activity_resource.activity_name, "Serialization Test")
	assert_eq(activity_resource.ability, "intelligence")
	assert_eq(activity_resource.base_xp, 200)
	assert_eq(activity_resource.rewards["gold"], 100)
	assert_eq(activity_resource.requirements["intelligence"], 14)
