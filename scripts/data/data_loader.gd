extends Node

# Load D&D data from individual YAML files

# Preload required classes
const YAMLParser = preload("res://scripts/data/yaml_parser.gd")
var races_data: Dictionary = {} # race_name -> race_data
var classes_data: Dictionary = {} # class_name -> class_data
var backgrounds_data: Dictionary = {} # background_name -> background_data
var activities_data: Dictionary = {}

# YAML parser instance
var yaml_parser: YAMLParser

func _ready() -> void:
	yaml_parser = YAMLParser.new()
	load_all_data()

# Load all data from individual YAML files
func load_all_data() -> void:
	load_races()
	load_classes()
	load_backgrounds()
	load_activities()

# Load race data from individual files
func load_races() -> void:
	var races_dir = "res://data/races/"
	var dir = DirAccess.open(races_dir)
	if dir == null:
		print("Error: Could not open races directory")
		return

	var files = dir.get_files()
	for file_name in files:
		if file_name.ends_with(".yaml"):
			var race_name = file_name.replace(".yaml", "").capitalize()
			var file_path = races_dir + file_name
			var race_data = load_yaml_file(file_path)
			if not race_data.is_empty():
				races_data[race_name] = race_data
				print("Loaded race: " + race_name)

# Load class data from individual files
func load_classes() -> void:
	var classes_dir = "res://data/classes/"
	var dir = DirAccess.open(classes_dir)
	if dir == null:
		print("Error: Could not open classes directory")
		return

	var files = dir.get_files()
	for file_name in files:
		if file_name.ends_with(".yaml"):
			var class_name_str = file_name.replace(".yaml", "").capitalize()
			var file_path = classes_dir + file_name
			var class_data = load_yaml_file(file_path)
			if not class_data.is_empty():
				classes_data[class_name_str] = class_data
				print("Loaded class: " + class_name_str)

# Load background data from individual files
func load_backgrounds() -> void:
	var backgrounds_dir = "res://data/backgrounds/"
	var dir = DirAccess.open(backgrounds_dir)
	if dir == null:
		print("Error: Could not open backgrounds directory")
		return

	var files = dir.get_files()
	for file_name in files:
		if file_name.ends_with(".yaml"):
			var background_name = file_name.replace(".yaml", "").replace("_", " ").capitalize()
			var file_path = backgrounds_dir + file_name
			var background_data = load_yaml_file(file_path)
			if not background_data.is_empty():
				backgrounds_data[background_name] = background_data
				print("Loaded background: " + background_name)

# Helper function to load a YAML file
func load_yaml_file(file_path: String) -> Dictionary:
	return yaml_parser.parse_yaml_file(file_path)


# Load YAML data by name (generic function for any YAML file)
func load_yaml_data(data_name: String) -> Dictionary:
	"""Load YAML data by name from the data directory"""
	var file_path = "res://data/" + data_name + ".yaml"
	return load_yaml_file(file_path)

# Parse YAML activities array format
func parse_yaml_activities(yaml_string: String) -> Array:
	return yaml_parser.parse_yaml_activities(yaml_string)

# Get race names
func get_race_names() -> Array[String]:
	var names: Array[String] = []
	for key in races_data.keys():
		names.append(str(key))
	return names

# Get class names
func get_class_names() -> Array[String]:
	var names: Array[String] = []
	for key in classes_data.keys():
		names.append(str(key))
	return names

# Get background names
func get_background_names() -> Array[String]:
	var names: Array[String] = []
	for key in backgrounds_data.keys():
		names.append(str(key))
	return names

# Get race data by name
func get_race_data(race_name: String) -> Dictionary:
	return races_data.get(race_name, {})

# Get class data by name
func get_class_data(class_name_param: String) -> Dictionary:
	return classes_data.get(class_name_param, {})

# Get background data by name
func get_background_data(background_name: String) -> Dictionary:
	return backgrounds_data.get(background_name, {})

# Load activities data from all YAML files in the activities directory
func load_activities() -> void:
	# Initialize activities data structure by ability
	activities_data = {
		"strength": {},
		"dexterity": {},
		"intelligence": {},
		"wisdom": {},
		"charisma": {},
		"constitution": {},
		"general": {}
	}

	# Load all activity files from the activities directory
	var activities_dir = "res://data/activities/"
	var dir = DirAccess.open(activities_dir)
	if dir == null:
		print("Error: Could not open activities directory")
		return

	var files = dir.get_files()
	for file_name in files:
		if file_name.ends_with(".yaml"):
			var file_path = activities_dir + file_name
			_load_activities_from_file(file_path)

	print("Loaded ", _count_total_activities(), " activities from all YAML files")

func _load_activities_from_file(file_path: String) -> void:
	"""Load activities from a single YAML file"""
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		print("Error opening ", file_path)
		return

	var yaml_string = file.get_as_text()
	file.close()

	var activities_array = parse_yaml_activities(yaml_string)
	if not activities_array is Array:
		print("Error: ", file_path, " does not contain an array")
		return

	# Process each activity in the file
	for activity_data in activities_array:
		var activity_id = activity_data.get("id", "")
		var ability = activity_data.get("ability", "general")

		if activity_id == "":
			print("Activity missing ID in ", file_path)
			continue

		# Ensure ability is valid
		if not ability in activities_data:
			print("Invalid ability '", ability, "' for activity '", activity_id, "' in ", file_path)
			ability = "general"

		# Store the activity
		activities_data[ability][activity_id] = activity_data

# Count total activities loaded
func _count_total_activities() -> int:
	var count = 0
	for ability in activities_data.keys():
		count += activities_data[ability].size()
	return count

# Get activities for a specific ability
func get_activities_for_ability(ability: String) -> Dictionary:
	return activities_data.get(ability.to_lower(), {})

# Get all activities organized by ability
func get_all_activities() -> Dictionary:
	return activities_data.duplicate()

# Get activity data by ID
func get_activity_data(activity_id: String) -> Dictionary:
	for ability in activities_data.keys():
		if activity_id in activities_data[ability]:
			return activities_data[ability][activity_id]
	return {}

# Get activity data by ID and ability
func get_activity_data_by_ability(activity_id: String, ability: String) -> Dictionary:
	var ability_activities = activities_data.get(ability.to_lower(), {})
	return ability_activities.get(activity_id, {})
