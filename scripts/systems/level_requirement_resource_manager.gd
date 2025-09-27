extends Node

# Level Requirement Resource Manager
# Manages level requirements using the hybrid YAML + Resource approach

class_name LevelRequirementResourceManager

# Resource storage
var level_requirements: Dictionary = {} # level -> LevelRequirementResource
var alternative_configs: Dictionary = {} # config_name -> Dictionary
var current_config: String = "standard"

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

	# Connect to data loaded signal
	if data_loader and data_loader.has_signal("data_loaded"):
		data_loader.data_loaded.connect(_on_data_loaded)

	load_all_level_requirements()

func _init():
	# Initialize data loader early for immediate use
	data_loader = ResourceDataLoader.new()

# Signal handler for data loading
func _on_data_loaded(data_type: String, count: int) -> void:
	if data_type == "level_requirements":
		_load_level_requirements_from_data_loader()

# Load all level requirements from resource file
func load_all_level_requirements() -> void:
	if not data_loader:
		print("Error: Data loader not initialized")
		return

	# Try to load level requirements immediately if data is already available
	_load_level_requirements_from_data_loader()

# Internal method to load level requirements from data loader
func _load_level_requirements_from_data_loader() -> void:
	if not data_loader:
		return

	var level_requirements_data = data_loader.get_all_level_requirements()
	if level_requirements_data.is_empty():
		return

	# Process level requirements data - this should be an array of LevelRequirementResource objects
	if level_requirements_data is Array:
		for requirement_resource in level_requirements_data:
			if requirement_resource is LevelRequirementResource:
				level_requirements[requirement_resource.level] = requirement_resource

	print("Loaded " + str(level_requirements.size()) + " level requirements")

# Public API methods
func get_level_requirement(level: int) -> LevelRequirementResource:
	"""Get level requirement for a specific level"""
	return level_requirements.get(level, null)

func get_experience_required_for_level(level: int) -> int:
	"""Get experience required for a specific level"""
	var requirement = get_level_requirement(level)
	if requirement:
		return requirement.experience_required
	return 0

func get_level_for_experience(experience: int) -> int:
	"""Get the level a character would be at with given experience"""
	var highest_level = 1

	for level in level_requirements.keys():
		var requirement = level_requirements[level]
		if experience >= requirement.experience_required:
			highest_level = max(highest_level, level)

	return highest_level

func get_experience_to_next_level(current_level: int, current_xp: int) -> int:
	"""Get experience needed to reach the next level"""
	var next_level = current_level + 1
	if next_level > 20:
		return 0  # Max level reached

	var next_level_requirement = get_experience_required_for_level(next_level)
	return max(0, next_level_requirement - current_xp)

func get_all_level_requirements() -> Dictionary:
	"""Get all level requirements"""
	return level_requirements.duplicate()

func get_alternative_configs() -> Dictionary:
	"""Get all alternative configurations"""
	return alternative_configs.duplicate()

func set_configuration(config_name: String) -> bool:
	"""Set the active leveling configuration"""
	if not alternative_configs.has(config_name):
		return false

	current_config = config_name
	# Reload requirements with new configuration
	load_configuration(config_name)
	return true

func load_configuration(config_name: String):
	"""Load a specific configuration"""
	if not alternative_configs.has(config_name):
		return

	var config_data = alternative_configs[config_name]
	level_requirements.clear()

	for level_str in config_data.keys():
		var level = int(level_str)
		var xp_required = config_data[level_str]

		var requirement_resource = LevelRequirementResource.new()
		requirement_resource.level = level
		requirement_resource.experience_required = xp_required
		requirement_resource.config_name = config_name

		level_requirements[level] = requirement_resource

	print("Loaded configuration: " + config_name)
