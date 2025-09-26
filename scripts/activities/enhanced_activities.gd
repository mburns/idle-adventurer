extends Node

# Enhanced activities system with multiple activities per ability score
# Based on D&D 5e rules and idle game mechanics
# Now uses hybrid YAML + Resource approach for type safety and performance

class_name EnhancedActivities

signal activity_started(activity: ActivityResource, character: Character, ability: String)
signal activity_completed(activity: ActivityResource, character: Character, rewards: Dictionary)
signal activity_progress(activity: ActivityResource, character: Character, progress: float)

# Resource-based activity management
var activity_manager: ActivityResourceManager
var active_activities: Dictionary = {} # character_id -> activity_data

func _init():
	# Don't initialize activity manager here - wait for _ready()
	setup_activity_system()

func _ready():
	print("DEBUG: EnhancedActivities._ready() called")
	# Initialize activity manager after autoloads are ready
	if Engine.has_singleton("AutoloadManager"):
		print("DEBUG: AutoloadManager singleton available")
		var autoload_manager = Engine.get_singleton("AutoloadManager")
		if autoload_manager:
			print("DEBUG: AutoloadManager instance retrieved")
			if autoload_manager.activity_manager:
				activity_manager = autoload_manager.activity_manager
				print("DEBUG: EnhancedActivities using global activity manager")
				print("DEBUG: Global activity manager has ", activity_manager.get_activity_count(), " activities")
			else:
				print("DEBUG: AutoloadManager available but activity_manager is null")
		else:
			print("DEBUG: AutoloadManager singleton returned null")
	else:
		print("DEBUG: AutoloadManager singleton not available, creating fallback activity manager")
		activity_manager = ActivityResourceManager.new()
		var data_loader = ResourceDataLoader.new()
		data_loader.load_activities()
		activity_manager.data_loader = data_loader
		activity_manager.load_all_activities()
		add_child(activity_manager)
		print("DEBUG: Fallback activity manager created with ", activity_manager.get_activity_count(), " activities")
		print("DEBUG: Available activity names: ", activity_manager.get_all_activity_names())

func setup_activity_system():
	"""Initialize the enhanced activities system"""
	var timer = Timer.new()
	timer.wait_time = 1.0 # Check every second
	timer.timeout.connect(_process_activities)
	timer.autostart = true
	add_child(timer)

func get_activities_for_ability(ability: String) -> Array[ActivityResource]:
	"""Get all activities for a specific ability score using Resources"""
	return activity_manager.get_activities_by_ability(ability)

func get_all_activities() -> Dictionary:
	"""Get all available activities organized by ability (legacy compatibility)"""
	# Convert Resource-based activities to legacy Dictionary format
	var activities = {
		"strength": {},
		"dexterity": {},
		"intelligence": {},
		"wisdom": {},
		"charisma": {},
		"constitution": {},
		"general": {}
	}

	for ability in activities.keys():
		var ability_activities = activity_manager.get_activities_by_ability(ability)
		for activity_resource in ability_activities:
			var activity_id = _generate_activity_id(activity_resource)
			activities[ability][activity_id] = _resource_to_dict(activity_resource)

	return activities

# Helper functions for Resource integration
func _generate_activity_id(activity_resource: ActivityResource) -> String:
	"""Generate unique ID for activity resource"""
	return activity_resource.ability + "_" + activity_resource.activity_name.to_lower().replace(" ", "_")

func _resource_to_dict(activity_resource: ActivityResource) -> Dictionary:
	"""Convert ActivityResource to legacy Dictionary format"""
	return {
		"id": _generate_activity_id(activity_resource),
		"name": activity_resource.activity_name,
		"ability": activity_resource.ability,
		"description": activity_resource.description,
		"daily_progress": activity_resource.daily_progress,
		"cost_per_day": activity_resource.cost_per_day,
		"rewards": activity_resource.rewards,
		"requirements": activity_resource.requirements,
		"activity_type": activity_resource.activity_type,
		"category": activity_resource.category,
		"risk_level": activity_resource.risk_level
	}


func can_start_activity(character: Character, activity_id: String, ability: String) -> bool:
	"""Check if character can start a specific activity using Resources"""
	var activity_resource = activity_manager.get_activity_by_name(activity_id)
	if activity_resource == null:
		print("DEBUG: Activity resource not found: ", activity_id)
		print("DEBUG: Available activities: ", activity_manager.get_all_activity_names())
		return false

	# Use the resource's built-in requirement checking
	var can_start = activity_resource.meets_requirements(character)
	print("DEBUG: Activity '", activity_id, "' requirements check: ", can_start)
	return can_start

func start_activity(character: Character, activity_id: String, ability: String):
	"""Start a new activity for a character using Resources"""
	print("DEBUG: EnhancedActivities.start_activity called with activity_id: '", activity_id, "', ability: '", ability, "'")

	if not can_start_activity(character, activity_id, ability):
		print("DEBUG: Character cannot start activity: " + activity_id)
		return false

	var activity_resource = activity_manager.get_activity_by_name(activity_id)
	if activity_resource == null:
		print("DEBUG: Activity resource not found: " + activity_id)
		print("DEBUG: Available activities: ", activity_manager.get_all_activity_names())
		return false

	var activity_data = {
		"id": activity_id,
		"resource": activity_resource,
		"name": activity_resource.activity_name,
		"ability": ability,
		"description": activity_resource.description,
		"daily_progress": activity_resource.daily_progress,
		"cost_per_day": activity_resource.cost_per_day,
		"rewards": activity_resource.rewards,
		"progress": 0.0,
		"start_time": Time.get_unix_time_from_system(),
		"last_payment": Time.get_unix_time_from_system()
	}

	active_activities[character.name] = activity_data
	activity_started.emit(activity_resource, character, ability)

	print("Started " + activity_resource.activity_name + " for " + character.name)
	return true

func _process_activities():
	"""Process all active activities"""
	var current_time = Time.get_unix_time_from_system()

	for character_name in active_activities.keys():
		var activity = active_activities[character_name]
		var character = get_character_by_name(character_name)

		if not character:
			continue

		process_activity(character, activity, current_time)

func process_activity(character: Character, activity: Dictionary, current_time: float):
	"""Process a single activity with offline progress tracking"""
	var days_elapsed = (current_time - activity.last_payment) / 86400.0

	# Process all elapsed time, not just daily chunks
	if days_elapsed > 0:
		# Calculate ability-based scaling
		var ability = activity.get("ability", "general")
		var ability_score = 10
		if ability != "general":
			ability_score = character.get(ability)
		var level_scaling = 1.0 + (ability_score - 10) * 0.1 # 10% bonus per point above 10

		# Handle costs for elapsed time
		var daily_cost = activity.get("cost_per_day", 0.0)
		var total_cost = daily_cost * days_elapsed
		if total_cost > 0:
			if character.gold >= total_cost:
				character.gold -= total_cost
			else:
				stop_activity(character.name, "Insufficient funds")
				return

		# Calculate progress with level scaling
		var base_daily_progress = activity.get("daily_progress", 0.0)
		var scaled_progress = base_daily_progress * level_scaling * days_elapsed
		activity["progress"] += scaled_progress

		# Apply rewards with level scaling
		apply_scaled_rewards(character, activity, days_elapsed, level_scaling)

		activity["last_payment"] = current_time
		activity_progress.emit(activity["name"], character, activity["progress"])

		# Check for completion (100% progress)
		if activity["progress"] >= 1.0:
			complete_activity(character, activity)

func apply_scaled_rewards(character: Character, activity: Dictionary, days_elapsed: float, level_scaling: float):
	"""Apply scaled rewards from an activity based on time elapsed and ability level"""
	var rewards = activity.get("rewards", {})

	for reward_type in rewards.keys():
		var base_amount = rewards[reward_type]
		var scaled_amount = base_amount * days_elapsed * level_scaling

		match reward_type:
			"gold":
				character.gold += scaled_amount
			"strength_exp", "dexterity_exp", "constitution_exp", "intelligence_exp", "wisdom_exp", "charisma_exp":
				add_ability_experience(character, reward_type, scaled_amount)
			"language":
				learn_language(character, scaled_amount)
			_:
				# Other rewards would be handled by specific systems
				print(character.name + " gained " + str(scaled_amount) + " " + reward_type)

func apply_daily_rewards(character: Character, activity: Dictionary):
	"""Apply daily rewards from an activity (legacy function)"""
	apply_scaled_rewards(character, activity, 1.0, 1.0)

func add_ability_experience(character: Character, ability_exp_type: String, amount: float):
	"""Add experience to an ability score"""
	var ability = ability_exp_type.replace("_exp", "")
	var current_exp = character.get(ability + "_experience")
	if current_exp == null:
		current_exp = 0.0
	character.set(ability + "_experience", current_exp + amount)

	# Check for ability score increase (every 1000 exp = +1 ability score)
	var new_ability_score = int((current_exp + amount) / 1000)
	var current_ability_score = character.get(ability)
	if current_ability_score == null:
		current_ability_score = 10

	if new_ability_score > current_ability_score - 10: # -10 because base is 10
		var increase = new_ability_score - (current_ability_score - 10)
		character.set(ability, current_ability_score + increase)
		print(character.name + " gained " + str(increase) + " " + ability + " (now " + str(character.get(ability)) + ")")

func learn_language(character: Character, _progress: float):
	"""Learn a language based on progress"""
	# This would be implemented with specific language learning activities
	# For now, just track progress
	var language_progress = character.get("language_learning_progress")
	if language_progress == null:
		language_progress = {}
	# Language learning would be handled by specific language activities

func complete_activity(character: Character, activity: Dictionary):
	"""Complete an activity and apply final rewards using Resources"""
	var activity_resource = activity.get("resource", null)
	if activity_resource == null:
		print("Error: Activity resource not found")
		return

	var rewards = activity_resource.rewards

	# Apply completion rewards (usually higher than daily)
	for reward_type in rewards.keys():
		var amount = rewards[reward_type] * 10 # 10x daily reward for completion
		apply_daily_rewards(character, {reward_type: amount})

	activity_completed.emit(activity_resource, character, rewards)

	# Instead of stopping, restart the activity
	restart_activity(character, activity)

	print(character.name + " completed " + activity_resource.activity_name + " and restarted")

func restart_activity(character: Character, activity: Dictionary):
	"""Restart an activity by resetting its progress"""
	var _activity_id = activity.get("id", "")
	var _ability = activity.get("ability", "general")

	# Reset progress to 0
	activity["progress"] = 0.0
	activity["last_payment"] = Time.get_unix_time_from_system()

	# Keep the activity active
	active_activities[character.name] = activity

	print(character.name + " restarted " + activity["name"])

func stop_activity(character_name: String, reason: String = ""):
	"""Stop an activity for a character"""
	if character_name in active_activities:
		active_activities.erase(character_name)
		print("Stopped activity for " + character_name + " (" + reason + ")")

func get_character_by_name(character_name: String) -> Character:
	"""Get character by name using CharacterManager"""
	# Try to access AutoloadManager, fallback to null if not available
	var autoload_manager = null
	if Engine.has_singleton("AutoloadManager"):
		autoload_manager = Engine.get_singleton("AutoloadManager")

	if autoload_manager and autoload_manager.character_manager:
		var character = autoload_manager.character_manager.get_current_character()
		if character and character.name == character_name:
			return character
	return null

func get_active_activities() -> Dictionary:
	"""Get all active activities"""
	return active_activities.duplicate()

func get_character_activity(character_name: String) -> Dictionary:
	"""Get activity for specific character"""
	return active_activities.get(character_name, {})
