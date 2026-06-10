extends Node

# Activity Resource Manager
# Manages activities using .tres Resource files for type safety

class_name ActivityResourceManager

# Resource storage
var activities: Dictionary = {} # activity_name -> ActivityResource
var activities_by_ability: Dictionary = {} # ability -> Array[ActivityResource]
var activities_by_type: Dictionary = {} # activity_type -> Array[ActivityResource]

# Resource data loader
var data_loader: ResourceDataLoader

func _ready() -> void:
	# Use global data loader if available
	if Engine.has_singleton("AutoloadManager"):
		var autoload_manager = Engine.get_singleton("AutoloadManager")
		if autoload_manager and autoload_manager.data_loader:
			data_loader = autoload_manager.data_loader
		else:
			data_loader = ResourceDataLoader.new()

	else:
		data_loader = ResourceDataLoader.new()

	# Only load activities if not already loaded by AutoloadManager
	if activities.size() == 0:
		load_all_activities()

func _init():
	# Initialize data loader early for immediate use
	data_loader = ResourceDataLoader.new()

# Helper function to convert dictionary to ActivityResource
func _dict_to_activity_resource(activity_dict: Dictionary) -> ActivityResource:
	"""Convert activity dictionary to ActivityResource object"""
	var activity_resource = ActivityResource.new()

	# Set basic properties
	activity_resource.activity_name = activity_dict.get("name", "unnamed")
	activity_resource.description = activity_dict.get("description", "")
	activity_resource.ability = activity_dict.get("ability", "general")
	activity_resource.daily_progress = activity_dict.get("daily_progress", 0.0)
	activity_resource.cost_per_day = activity_dict.get("cost_per_day", 0.0)

	# Set cycle-based fields (new system)
	activity_resource.cycle_duration = activity_dict.get("cycle_duration", 15.0)
	activity_resource.cycle_xp = activity_dict.get("cycle_xp", 5)
	activity_resource.cycle_gold = activity_dict.get("cycle_gold", 2)
	activity_resource.cycle_cost = activity_dict.get("cycle_cost", 0.0)

	# Set rewards
	var rewards = activity_dict.get("rewards", {})
	if rewards is Dictionary:
		activity_resource.rewards = rewards

	# Set requirements
	var requirements = activity_dict.get("requirements", {})
	if requirements is Dictionary:
		activity_resource.requirements = requirements

	# Set activity type (default to "training" if not specified)
	activity_resource.activity_type = activity_dict.get("activity_type", "training")

	return activity_resource

# Load all activities from .tres files
func load_all_activities() -> void:
	if not data_loader:
		print("ERROR: Data loader not initialized")
		return

	print("DEBUG: Loading activities from data loader...")
	# Get activities from data loader (data should already be loaded by AutoloadManager)
	var all_activities = data_loader.get_all_activities()
	print("DEBUG: Data loader returned activities: ", all_activities.keys())
	print("DEBUG: Data loader returned ", all_activities.size(), " ability categories")

	# Clear existing data
	activities.clear()
	activities_by_ability.clear()
	activities_by_type.clear()

	# Populate our storage
	for ability in all_activities.keys():
		var ability_activities = all_activities[ability]
		print("Processing ability: ", ability, " with ", ability_activities.size(), " activities")
		activities_by_ability[ability] = [] as Array[ActivityResource]

		# Activities are now ActivityResource objects directly
		for activity_resource in ability_activities:
			if activity_resource:
				activities_by_ability[ability].append(activity_resource)
				activities[activity_resource.activity_name] = activity_resource
				print("Loaded activity: ", activity_resource.activity_name)
			else:
				print("DEBUG: Failed to load activity resource")

	# Organize activities by various criteria
	organize_activities()

	print("Loaded " + str(activities.size()) + " activity resources")
	print("DEBUG: Activities dictionary keys: ", activities.keys())

# Organize activities by various criteria
func organize_activities() -> void:
	activities_by_ability.clear()
	activities_by_type.clear()

	for activity_name in activities:
		var activity = activities[activity_name]

		# Organize by ability
		if not activities_by_ability.has(activity.ability):
			activities_by_ability[activity.ability] = [] as Array[ActivityResource]
		activities_by_ability[activity.ability].append(activity)

		# Organize by type
		if not activities_by_type.has(activity.activity_type):
			activities_by_type[activity.activity_type] = [] as Array[ActivityResource]
		activities_by_type[activity.activity_type].append(activity)

# Public API methods
func get_activity_by_name(activity_name: String) -> ActivityResource:
	"""Get a specific activity by name"""
	return activities.get(activity_name, null)

func get_activities_by_ability(ability: String) -> Array[ActivityResource]:
	"""Get all activities for a specific ability"""
	return activities_by_ability.get(ability, [] as Array[ActivityResource])

func get_activities_by_type(activity_type: String) -> Array[ActivityResource]:
	"""Get all activities of a specific type"""
	return activities_by_type.get(activity_type, [] as Array[ActivityResource])

func get_all_activities() -> Dictionary:
	"""Get all activities"""
	return activities.duplicate()

func get_all_activity_names() -> Array[String]:
	"""Get all activity names"""
	var keys: Array[String] = []
	for key in activities.keys():
		keys.append(key)
	return keys

func get_activity_count() -> int:
	"""Get total number of activities"""
	return activities.size()

func get_activities_for_character(character: Character) -> Array[ActivityResource]:
	"""Get activities that the character can perform based on requirements"""
	var available_activities: Array[ActivityResource] = []

	for activity_name in activities:
		var activity = activities[activity_name]
		if activity.meets_requirements(character):
			available_activities.append(activity)

	return available_activities

func get_recommended_activities(character: Character, ability: String = "") -> Array[ActivityResource]:
	"""Get recommended activities for a character based on their stats and preferences"""
	var recommended: Array[ActivityResource] = []
	var character_activities = get_activities_for_character(character)

	if ability != "":
		# Filter by specific ability
		for activity in character_activities:
			if activity.ability == ability:
				recommended.append(activity)
	else:
		# Return all available activities
		recommended = character_activities

	# Sort by XP efficiency or other criteria
	recommended.sort_custom(func(a, b): return a.base_xp > b.base_xp)

	return recommended
