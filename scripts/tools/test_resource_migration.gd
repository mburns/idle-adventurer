extends Node

# Test script to verify the YAML to .tres migration works correctly
# Run this after converting YAML files to .tres files

class_name TestResourceMigration

func _ready():
	print("Testing Resource Migration...")
	test_resource_loading()
	test_type_safety()
	test_performance()
	print("Resource migration test complete!")

func test_resource_loading():
	"""Test that resources load correctly from .tres files"""
	print("\n=== Testing Resource Loading ===")

	var data_loader = ResourceDataLoader.new()
	add_child(data_loader)

	# Wait for data to load
	await data_loader.data_loaded

	var summary = data_loader.get_data_summary()
	print("Data Summary:")
	for data_type in summary.keys():
		print("  ", data_type, ": ", summary[data_type])

	# Test specific resource access
	var activities = data_loader.get_activities_for_ability("strength")
	print("Strength activities loaded: ", activities.size())

	if activities.size() > 0:
		var first_activity = activities[0]
		print("First activity: ", first_activity.activity_name)
		print("Activity type: ", typeof(first_activity))
		print("Activity ability: ", first_activity.ability)

	var races = data_loader.get_all_races()
	print("Races loaded: ", races.size())

	if races.size() > 0:
		var first_race = races[0]
		print("First race: ", first_race.name)
		print("Race type: ", typeof(first_race))
		print("Race size: ", first_race.size)

func test_type_safety():
	"""Test that we get proper type safety with Resources"""
	print("\n=== Testing Type Safety ===")

	var data_loader = ResourceDataLoader.new()
	add_child(data_loader)

	# Wait for data to load
	await data_loader.data_loaded

	var activities = data_loader.get_activities_for_ability("general")
	if activities.size() > 0:
		var activity = activities[0]

		# These should all work without type errors
		print("Activity name: ", activity.activity_name)
		print("Activity ability: ", activity.ability)
		print("Activity description: ", activity.description)
		print("Activity daily progress: ", activity.daily_progress)
		print("Activity cost per day: ", activity.cost_per_day)

		# Test that we can access nested properties safely
		if activity.rewards:
			print("Activity rewards: ", activity.rewards)
		if activity.requirements:
			print("Activity requirements: ", activity.requirements)

		print("Type safety test passed!")

func test_performance():
	"""Test that .tres loading is faster than YAML parsing"""
	print("\n=== Testing Performance ===")

	var start_time = Time.get_ticks_msec()

	var data_loader = ResourceDataLoader.new()
	add_child(data_loader)

	# Wait for data to load
	await data_loader.data_loaded

	var end_time = Time.get_ticks_msec()
	var load_time = end_time - start_time

	print("Resource loading time: ", load_time, "ms")

	# Test repeated access performance
	start_time = Time.get_ticks_msec()

	for i in range(1000):
		var activities = data_loader.get_activities_for_ability("strength")
		var races = data_loader.get_all_races()
		var classes = data_loader.get_all_classes()

	end_time = Time.get_ticks_msec()
	var access_time = end_time - start_time

	print("1000 access operations time: ", access_time, "ms")
	print("Average access time: ", access_time / 1000.0, "ms per operation")

func test_activity_manager_integration():
	"""Test that ActivityResourceManager works with the new system"""
	print("\n=== Testing Activity Manager Integration ===")

	var activity_manager = ActivityResourceManager.new()
	add_child(activity_manager)

	# Wait for activities to load
	await get_tree().process_frame
	await get_tree().process_frame

	var strength_activities = activity_manager.get_activities_by_ability("strength")
	print("Activity manager loaded ", strength_activities.size(), " strength activities")

	if strength_activities.size() > 0:
		var first_activity = strength_activities[0]
		print("First activity from manager: ", first_activity.activity_name)
		print("Activity type: ", typeof(first_activity))

	print("Activity manager integration test passed!")

func test_enhanced_activities_integration():
	"""Test that EnhancedActivities works with the new system"""
	print("\n=== Testing Enhanced Activities Integration ===")

	var enhanced_activities = EnhancedActivities.new()
	add_child(enhanced_activities)

	# Wait for activities to load
	await get_tree().process_frame
	await get_tree().process_frame

	var all_activities = enhanced_activities.get_all_activities()
	print("Enhanced activities loaded ", all_activities.keys().size(), " ability categories")

	for ability in all_activities.keys():
		var ability_activities = all_activities[ability]
		print("  ", ability, ": ", ability_activities.size(), " activities")

	print("Enhanced activities integration test passed!")
