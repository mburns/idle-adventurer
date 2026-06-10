class_name IdleMechanics
extends Node

# Dynamic idle progression system for D&D activities
# Now uses .tres Resource files instead of hardcoded activities!

# Activity definitions - loaded dynamically from .tres Resources
static var activities: Dictionary = {}  # activity_name -> ActivityResource
static var activity_manager: ActivityResourceManager

# Initialize activities from .tres Resources
static func _static_init():
	load_activities_from_resources()

static func load_activities_from_resources():
	"""Load activities from .tres files as ActivityResource instances"""
	activity_manager = ActivityResourceManager.new()

	# Activities are now loaded automatically by ActivityResourceManager
	# Convert to static dictionary for backward compatibility
	# Load abilities from resource configuration
	var all_abilities = load_abilities_from_resources()

	for ability in all_abilities:
		var ability_activities = activity_manager.get_activities_by_ability(ability)
		for activity_resource in ability_activities:
			var activity_name = activity_resource.activity_name
			if activity_name != "":
				activities[activity_name] = activity_resource

	print("Loaded ", activities.size(), " activities from .tres data using Resources")

static func load_abilities_from_resources() -> Array[String]:
	"""Load ability types from resource configuration"""
	# Try to load from resource file first
	var resource_path = "res://data/types/ability_types.tres"
	var resource = load(resource_path)

	if resource and resource.has_method("get"):
		var resource_data = resource.get("metadata/yaml_data")
		if resource_data != null:
			var abilities_data = resource_data.get("abilities", [])
			if not abilities_data.is_empty():
				var abilities: Array[String] = []
				for ability in abilities_data:
					abilities.append(str(ability))
				return abilities

	# Fallback to hardcoded abilities
	print("Warning: Could not load abilities from resources, using fallback")
	return ["strength", "dexterity", "constitution", "intelligence", "wisdom", "charisma", "general"]

static func load_rest_activities() -> void:
	"""Load rest activities from resource file"""
	var resource_path = "res://data/activities/rest.tres"
	var resource = load(resource_path)

	if resource and resource.has_method("get") and resource.get("metadata/yaml_data"):
		var rest_data = resource.get("metadata/yaml_data")
		if rest_data and rest_data.has("activities"):
			var rest_activities = rest_data["activities"]
			if rest_activities.size() > 0:
				for activity_data in rest_activities:
					var activity_resource = create_activity_resource_from_data(activity_data)
					if activity_resource:
						activities[activity_resource.activity_name] = activity_resource
				print("Loaded ", rest_activities.size(), " rest activities from .tres")
			else:
				print("No rest activities found in .tres, using defaults")
				load_default_rest_activities()
		else:
			print("No rest activities found in .tres, using defaults")
			load_default_rest_activities()
	else:
		print("Warning: Could not load rest activities from .tres, using defaults")
		load_default_rest_activities()

static func parse_rest_yaml(yaml_content: String) -> Array:
	"""Parse YAML content to extract rest activities"""
	var activity_list = []
	var lines = yaml_content.split("\n")
	var current_activity = {}
	var in_activity = false
	var current_dict_key = ""
	var current_dict = {}
	var in_dict = false

	for i in range(lines.size()):
		var line = lines[i]
		var original_line = line
		line = line.strip_edges()

		# Skip empty lines and comments
		if line.is_empty() or line.begins_with("#"):
			continue

		# Check if we're starting a new activity
		if line.begins_with("- id:"):
			# Save previous activity if exists
			if in_activity and current_activity.size() > 0:
				activity_list.append(current_activity)

			# Start new activity
			current_activity = {}
			in_activity = true
			in_dict = false
			current_activity["id"] = line.substr(5).strip_edges()
			continue

		# Parse key-value pairs within activities
		if in_activity and ":" in line:
			var parts = line.split(":", 1)
			var key = parts[0].strip_edges()
			var value = parts[1].strip_edges()

			# Check if this is a dictionary key (no value, or empty value)
			if value.is_empty() or value == "":
				current_dict_key = key
				current_dict = {}
				in_dict = true
				continue

			# If we're in a dictionary, add to current dict
			if in_dict and original_line.begins_with("  "):
				# This is a nested key-value pair
				var dict_value = value
				if dict_value.is_valid_int():
					current_dict[key] = dict_value.to_int()
				elif dict_value.is_valid_float():
					current_dict[key] = dict_value.to_float()
				elif dict_value == "true":
					current_dict[key] = true
				elif dict_value == "false":
					current_dict[key] = false
				else:
					current_dict[key] = dict_value
				continue

			# Regular key-value pair
			if value.is_valid_int():
				current_activity[key] = value.to_int()
			elif value.is_valid_float():
				current_activity[key] = value.to_float()
			elif value == "true":
				current_activity[key] = true
			elif value == "false":
				current_activity[key] = false
			elif value == "{}":
				current_activity[key] = {}
			elif value.begins_with("{") and value.ends_with("}"):
				current_activity[key] = parse_simple_dict(value)
			else:
				current_activity[key] = value

		# Check if we're exiting a dictionary (next line is not indented)
		if in_dict and not original_line.begins_with("  ") and not line.is_empty():
			current_activity[current_dict_key] = current_dict
			in_dict = false
			current_dict = {}

	# Save any remaining dictionary
	if in_dict:
		current_activity[current_dict_key] = current_dict

	# Add the last activity
	if in_activity and current_activity.size() > 0:
		activity_list.append(current_activity)

	return activity_list

static func parse_simple_dict(dict_string: String) -> Dictionary:
	"""Parse simple dictionary strings like {key: value}"""
	var result = {}
	var content = dict_string.substr(1, dict_string.length() - 2)  # Remove {}
	var pairs = content.split(",")

	for pair in pairs:
		pair = pair.strip_edges()
		if ":" in pair:
			var key_value = pair.split(":", 1)
			var key = key_value[0].strip_edges()
			var value = key_value[1].strip_edges()

			# Parse value
			if value.is_valid_int():
				result[key] = value.to_int()
			elif value.is_valid_float():
				result[key] = value.to_float()
			else:
				result[key] = value

	return result

static func create_activity_resource_from_data(activity_data: Dictionary) -> ActivityResource:
	"""Create ActivityResource from parsed data"""
	var activity_resource = ActivityResource.new()

	activity_resource.activity_name = activity_data.get("name", "")
	activity_resource.ability = activity_data.get("ability", "general")
	activity_resource.skill = activity_data.get("skill", "")
	activity_resource.base_duration = activity_data.get("base_duration", 30.0)
	activity_resource.base_xp = activity_data.get("base_xp", 5)
	activity_resource.base_gold = activity_data.get("base_gold", 0)
	activity_resource.description = activity_data.get("description", "")
	activity_resource.daily_progress = activity_data.get("daily_progress", 0.1)
	activity_resource.cost_per_day = activity_data.get("cost_per_day", 0.0)
	activity_resource.rewards = activity_data.get("rewards", {})
	activity_resource.requirements = activity_data.get("requirements", {})
	activity_resource.activity_type = activity_data.get("activity_type", "rest")
	activity_resource.category = activity_data.get("category", "general")

	# Set cycle-based fields (new system)
	activity_resource.cycle_duration = activity_data.get("cycle_duration", 15.0)
	activity_resource.cycle_xp = activity_data.get("cycle_xp", 5)
	activity_resource.cycle_gold = activity_data.get("cycle_gold", 2)
	activity_resource.cycle_cost = activity_data.get("cycle_cost", 0.0)

	return activity_resource

static func load_default_rest_activities() -> void:
	"""Load default rest activities if YAML loading fails"""
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
	"""Get activity resource by name"""
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
