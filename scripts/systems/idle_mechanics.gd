class_name IdleMechanics
extends Node

# Dynamic idle progression system for D&D activities
# Now uses JSON data instead of hardcoded activities!

# Activity definitions - loaded dynamically from JSON as Resources
static var activities: Dictionary = {}  # activity_name -> ActivityResource

# Initialize activities from JSON data
static func _static_init():
	load_activities_from_json()

static func load_activities_from_json():
	"""Load activities from JSON files as ActivityResource instances"""
	var enhanced_activities = EnhancedActivities.new()
	var all_activities = enhanced_activities.get_all_activities()

	# Convert JSON activity format to ActivityResource instances
	if all_activities is Dictionary:
		for ability in all_activities.keys():
			if all_activities[ability] is Dictionary:
				for activity_id in all_activities[ability].keys():
					var activity_data = all_activities[ability][activity_id]
					var activity_name = activity_data.get("name", "")

					if activity_name != "":
						# Create ActivityResource instance
						var activity_resource = ActivityResource.new()
						activity_resource.activity_name = activity_name
						activity_resource.ability = activity_data.get("ability", "general")
						activity_resource.skill = activity_data.get("name", "")
						activity_resource.description = activity_data.get("description", "")
						activity_resource.base_duration = 10.0  # Default duration
						activity_resource.base_xp = _calculate_base_xp(activity_data)
						activity_resource.base_gold = _calculate_base_gold(activity_data)
						activity_resource.daily_progress = activity_data.get("daily_progress", 0.1)
						activity_resource.cost_per_day = activity_data.get("cost_per_day", 0.0)

						# Set requirements and rewards with type safety
						var requirements = activity_data.get("requirements", {})
						var rewards = activity_data.get("rewards", {})

						if requirements is Dictionary:
							activity_resource.requirements = requirements
						else:
							print("Warning: requirements is not a Dictionary for activity ", activity_name)
							activity_resource.requirements = {}

						if rewards is Dictionary:
							activity_resource.rewards = rewards
						else:
							print("Warning: rewards is not a Dictionary for activity ", activity_name)
							activity_resource.rewards = {}

						# Set activity type and category
						activity_resource.activity_type = activity_data.get("activity_type", "training")
						activity_resource.category = activity_data.get("category", "general")

						# Store the resource
						activities[activity_name] = activity_resource
	else:
		print("Warning: all_activities is not a Dictionary, got: ", typeof(all_activities))

	# TODO rest activities should be dynamically loaded

	# Add rest activities manually as ActivityResource instances
	var short_rest = ActivityResource.new()
	short_rest.activity_name = "Short Rest"
	short_rest.ability = "general"
	short_rest.skill = "Short Rest"
	short_rest.base_duration = 20.0
	short_rest.base_xp = 5
	short_rest.base_gold = 0
	short_rest.description = "Take a short rest to recover"
	short_rest.daily_progress = 0.1
	short_rest.cost_per_day = 0.0
	short_rest.rewards = {"xp": 5}
	short_rest.requirements = {}
	short_rest.activity_type = "rest"
	short_rest.category = "general"
	activities["Short Rest"] = short_rest

	var long_rest = ActivityResource.new()
	long_rest.activity_name = "Long Rest"
	long_rest.ability = "general"
	long_rest.skill = "Long Rest"
	long_rest.base_duration = 60.0
	long_rest.base_xp = 10
	long_rest.base_gold = 0
	long_rest.description = "Take a long rest to fully recover"
	long_rest.daily_progress = 0.1
	long_rest.cost_per_day = 0.0
	long_rest.rewards = {"xp": 10}
	long_rest.requirements = {}
	long_rest.activity_type = "rest"
	long_rest.category = "general"
	activities["Long Rest"] = long_rest

	print("Loaded ", activities.size(), " activities from JSON data")

static func _calculate_base_xp(activity_data: Dictionary) -> int:
	"""Calculate base XP from activity rewards"""
	var rewards = activity_data.get("rewards", {})
	var total_xp = 0

	if rewards is Dictionary:
		for reward_type in rewards.keys():
			if reward_type.ends_with("_exp"):
				total_xp += rewards[reward_type]
	else:
		print("Warning: rewards is not a Dictionary, got: ", typeof(rewards))

	# Default to 10 if no XP rewards found
	return total_xp if total_xp > 0 else 10

static func _calculate_base_gold(activity_data: Dictionary) -> int:
	"""Calculate base gold from activity rewards"""
	var rewards = activity_data.get("rewards", {})
	if rewards is Dictionary:
		return rewards.get("gold", 0)
	else:
		print("Warning: rewards is not a Dictionary, got: ", typeof(rewards))
		return 0

# Rest of the idle mechanics functions remain the same...
# (keeping the existing functionality but using dynamic data)

static func start_activity(activity_name: String, character: Character) -> bool:
	"""Start an activity for a character"""
	if not activities.has(activity_name):
		print("Activity not found: ", activity_name)
		return false

	var activity = activities[activity_name]

	# Check requirements
	if not _check_requirements(character, activity):
		print("Character does not meet requirements for: ", activity_name)
		return false

	# Set character's current activity
	character.current_activity = activity_name
	character.activity_start_time = Time.get_unix_time_from_system()
	character.activity_duration = activity.base_duration

	print("Started activity: ", activity_name, " for ", character.name)
	return true

static func _check_requirements(character: Character, activity: ActivityResource) -> bool:
	"""Check if character meets activity requirements"""
	return activity.meets_requirements(character)

static func complete_activity(character: Character) -> Dictionary:
	"""Complete the current activity and return rewards"""
	if character.current_activity == "":
		return {"xp": 0, "gold": 0}

	var activity_name = character.current_activity
	var activity = activities.get(activity_name, null)

	if activity == null:
		return {"xp": 0, "gold": 0}

	# Calculate rewards using the resource's methods
	var xp_reward = activity.get_xp_at_level(character.level)
	var gold_reward = activity.get_gold_at_level(character.level)

	var rewards = {
		"xp": xp_reward,
		"gold": gold_reward
	}

	# Apply rewards to character
	character.experience_points += rewards.xp
	character.gold += rewards.gold

	# Clear activity
	character.current_activity = ""
	character.activity_start_time = 0
	character.activity_duration = 0

	print("Completed activity: ", activity_name, " - Gained ", rewards.xp, " XP and ", rewards.gold, " gold")
	return rewards

static func get_activity_data(activity_name: String) -> ActivityResource:
	"""Get activity data by name"""
	return activities.get(activity_name, null)

static func get_all_activities() -> Dictionary:
	"""Get all activities"""
	return activities.duplicate()

static func is_activity_complete(character: Character) -> bool:
	"""Check if character's current activity is complete"""
	if character.current_activity == "":
		return false

	var elapsed_time = Time.get_unix_time_from_system() - character.activity_start_time
	return elapsed_time >= character.activity_duration

static func get_activity_time_remaining(character: Character) -> float:
	"""Get remaining time for current activity"""
	if character.current_activity == "":
		return 0.0

	var elapsed_time = Time.get_unix_time_from_system() - character.activity_start_time
	var remaining = character.activity_duration - elapsed_time
	return max(0.0, remaining)
