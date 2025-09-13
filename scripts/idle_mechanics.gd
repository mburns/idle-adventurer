class_name IdleMechanics
extends Node

# Dynamic idle progression system for D&D activities
# Now uses JSON data instead of hardcoded activities!

# Activity definitions - loaded dynamically from JSON
static var activities: Dictionary = {}

# Initialize activities from JSON data
static func _static_init():
	load_activities_from_json()

static func load_activities_from_json():
	"""Load activities from JSON files instead of hardcoded data"""
	var enhanced_activities = EnhancedActivities.new()
	var all_activities = enhanced_activities.get_all_activities()

	# Convert JSON activity format to idle mechanics format
	for ability in all_activities.keys():
		for activity_id in all_activities[ability].keys():
			var activity_data = all_activities[ability][activity_id]
			var activity_name = activity_data.get("name", "")

			if activity_name != "":
				# Convert JSON format to idle mechanics format
				activities[activity_name] = {
					"ability": activity_data.get("ability", "general"),
					"skill": activity_data.get("name", ""), # Use name as skill for now
					"base_duration": 10.0, # Default duration - could be made configurable
					"base_xp": _calculate_base_xp(activity_data),
					"base_gold": _calculate_base_gold(activity_data),
					"description": activity_data.get("description", ""),
					"daily_progress": activity_data.get("daily_progress", 0.1),
					"cost_per_day": activity_data.get("cost_per_day", 0.0),
					"rewards": activity_data.get("rewards", {}),
					"requirements": activity_data.get("requirements", {})
				}

	# Add rest activities manually
	activities["Short Rest"] = {
		"ability": "general",
		"skill": "Short Rest",
		"base_duration": 5.0,  # 5 seconds for short rest
		"base_xp": 5,
		"base_gold": 0,
		"description": "Take a short rest to recover",
		"daily_progress": 0.1,
		"cost_per_day": 0.0,
		"rewards": {"xp": 5},
		"requirements": {}
	}

	activities["Long Rest"] = {
		"ability": "general",
		"skill": "Long Rest",
		"base_duration": 10.0,  # 10 seconds for long rest
		"base_xp": 10,
		"base_gold": 0,
		"description": "Take a long rest to fully recover",
		"daily_progress": 0.1,
		"cost_per_day": 0.0,
		"rewards": {"xp": 10},
		"requirements": {}
	}

	print("Loaded ", activities.size(), " activities from JSON data")

static func _calculate_base_xp(activity_data: Dictionary) -> int:
	"""Calculate base XP from activity rewards"""
	var rewards = activity_data.get("rewards", {})
	var total_xp = 0

	for reward_type in rewards.keys():
		if reward_type.ends_with("_exp"):
			total_xp += rewards[reward_type]

	# Default to 10 if no XP rewards found
	return total_xp if total_xp > 0 else 10

static func _calculate_base_gold(activity_data: Dictionary) -> int:
	"""Calculate base gold from activity rewards"""
	var rewards = activity_data.get("rewards", {})
	return rewards.get("gold", 0)

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

static func _check_requirements(character: Character, activity: Dictionary) -> bool:
	"""Check if character meets activity requirements"""
	var requirements = activity.get("requirements", {})

	for req_type in requirements.keys():
		var required_value = requirements[req_type]

		match req_type:
			"strength", "dexterity", "constitution", "intelligence", "wisdom", "charisma":
				if character.get(req_type) < required_value:
					return false
			"gold":
				if character.gold < required_value:
					return false
			"tools":
				# For now, assume character has tools if they have enough gold
				if character.gold < 50:
					return false

	return true

static func complete_activity(character: Character) -> Dictionary:
	"""Complete the current activity and return rewards"""
	if character.current_activity == "":
		return {"xp": 0, "gold": 0}

	var activity_name = character.current_activity
	var activity = activities.get(activity_name, {})

	if activity.is_empty():
		return {"xp": 0, "gold": 0}

	# Calculate rewards
	var rewards = {
		"xp": activity.base_xp,
		"gold": activity.base_gold
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

static func get_activity_data(activity_name: String) -> Dictionary:
	"""Get activity data by name"""
	return activities.get(activity_name, {})

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
