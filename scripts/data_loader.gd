extends Node

# Load D&D data from individual YAML files
var races_data: Dictionary = {} # race_name -> race_data
var classes_data: Dictionary = {} # class_name -> class_data
var backgrounds_data: Dictionary = {} # background_name -> background_data
var activities_data: Dictionary = {}

func _ready() -> void:
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
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		print("Error: Could not open file: " + file_path)
		return {}

	var yaml_string = file.get_as_text()
	file.close()

	# Parse YAML using a simple parser
	var yaml_data = parse_yaml(yaml_string)
	if yaml_data == null:
		print("Error parsing " + file_path)
		return {}

	return yaml_data

# Simple YAML parser for basic YAML structures
func parse_yaml(yaml_string: String) -> Dictionary:
	var lines = yaml_string.split("\n")
	var result = {}
	var current_key = ""
	var current_value = ""
	var in_multiline = false
	var indent_level = 0

	for line in lines:
		line = line.strip_edges()
		if line.is_empty() or line.begins_with("#"):
			continue

		var line_indent = get_indent_level(line)

		# Handle key-value pairs
		if ":" in line and not line.begins_with("-"):
			if in_multiline and current_key != "":
				result[current_key] = current_value.strip_edges()
				in_multiline = false

			var parts = line.split(":", 1)
			current_key = parts[0].strip_edges()
			current_value = parts[1].strip_edges()

			if current_value.is_empty():
				in_multiline = true
				current_value = ""
			else:
				result[current_key] = parse_value(current_value)
		elif in_multiline and line_indent > indent_level:
			current_value += "\n" + line
		elif line.begins_with("-"):
			# Handle array items - for now, treat as simple values
			var item = line.substr(1).strip_edges()
			if not result.has("items"):
				result["items"] = []
			result["items"].append(parse_value(item))

	# Handle last key-value pair
	if in_multiline and current_key != "":
		result[current_key] = current_value.strip_edges()

	return result

func get_indent_level(line: String) -> int:
	var indent = 0
	for i in range(line.length()):
		if line[i] == " ":
			indent += 1
		elif line[i] == "\t":
			indent += 4
		else:
			break
	return indent

func parse_value(value: String) -> Variant:
	# Try to parse as number
	if value.is_valid_int():
		return value.to_int()
	elif value.is_valid_float():
		return value.to_float()
	# Try to parse as boolean
	elif value == "true":
		return true
	elif value == "false":
		return false
	# Try to parse as null/empty
	elif value == "null" or value == "~" or value == "":
		return null
	# Return as string
	else:
		return value

# Load YAML data by name (generic function for any YAML file)
func load_yaml_data(data_name: String) -> Dictionary:
	"""Load YAML data by name from the data directory"""
	var file_path = "res://data/" + data_name + ".yaml"
	return load_yaml_file(file_path)

# Parse YAML activities array format
func parse_yaml_activities(yaml_string: String) -> Array:
	var lines = yaml_string.split("\n")
	var activities = []
	var current_activity = {}
	var current_key = ""
	var in_multiline = false
	var indent_level = 0

	for line in lines:
		line = line.strip_edges()
		if line.is_empty() or line.begins_with("#"):
			continue

		var line_indent = get_indent_level(line)

		# Handle array items (activities)
		if line.begins_with("- ") and line_indent == 0:
			# Save previous activity if exists
			if not current_activity.is_empty():
				activities.append(current_activity)

			# Start new activity
			current_activity = {}
			var item_line = line.substr(2).strip_edges()
			if ":" in item_line:
				var parts = item_line.split(":", 1)
				current_key = parts[0].strip_edges()
				var value = parts[1].strip_edges()
				if value.is_empty():
					in_multiline = true
				else:
					current_activity[current_key] = parse_value(value)
			indent_level = 0
		elif line.begins_with("-") and line_indent > 0:
			# Handle nested array items
			var item = line.substr(1).strip_edges()
			if not current_activity.has(current_key):
				current_activity[current_key] = []
			current_activity[current_key].append(parse_value(item))
		elif ":" in line and line_indent > 0:
			# Handle key-value pairs within activity
			if in_multiline and current_key != "":
				current_activity[current_key] = current_activity.get(current_key, "").strip_edges()
				in_multiline = false

			var parts = line.split(":", 1)
			current_key = parts[0].strip_edges()
			var value = parts[1].strip_edges()

			if value.is_empty():
				in_multiline = true
				current_activity[current_key] = ""
			else:
				current_activity[current_key] = parse_value(value)
		elif in_multiline and line_indent > indent_level:
			# Continue multiline value
			current_activity[current_key] += "\n" + line
		elif line_indent == 0 and not line.begins_with("-"):
			# Handle top-level key-value pairs
			if in_multiline and current_key != "":
				current_activity[current_key] = current_activity.get(current_key, "").strip_edges()
				in_multiline = false

			var parts = line.split(":", 1)
			current_key = parts[0].strip_edges()
			var value = parts[1].strip_edges()

			if value.is_empty():
				in_multiline = true
				current_activity[current_key] = ""
			else:
				current_activity[current_key] = parse_value(value)

	# Save last activity
	if not current_activity.is_empty():
		activities.append(current_activity)

	return activities

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
