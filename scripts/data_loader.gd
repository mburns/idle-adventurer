extends Node

# Load D&D data from individual JSON files
var races_data: Dictionary = {} # race_name -> race_data
var classes_data: Dictionary = {} # class_name -> class_data
var backgrounds_data: Dictionary = {} # background_name -> background_data
var activities_data: Dictionary = {}

func _ready():
	load_all_data()

# Load all data from individual JSON files
func load_all_data():
	load_races()
	load_classes()
	load_backgrounds()
	load_activities()

# Load race data from individual files
func load_races():
	var races_dir = "res://data/races/"
	var dir = DirAccess.open(races_dir)
	if dir == null:
		print("Error: Could not open races directory")
		return

	var files = dir.get_files()
	for file_name in files:
		if file_name.ends_with(".json"):
			var race_name = file_name.replace(".json", "").capitalize()
			var file_path = races_dir + file_name
			var race_data = load_json_file(file_path)
			if not race_data.is_empty():
				races_data[race_name] = race_data
				print("Loaded race: " + race_name)

# Load class data from individual files
func load_classes():
	var classes_dir = "res://data/classes/"
	var dir = DirAccess.open(classes_dir)
	if dir == null:
		print("Error: Could not open classes directory")
		return

	var files = dir.get_files()
	for file_name in files:
		if file_name.ends_with(".json"):
			var class_name_str = file_name.replace(".json", "").capitalize()
			var file_path = classes_dir + file_name
			var class_data = load_json_file(file_path)
			if not class_data.is_empty():
				classes_data[class_name_str] = class_data
				print("Loaded class: " + class_name_str)

# Load background data from individual files
func load_backgrounds():
	var backgrounds_dir = "res://data/backgrounds/"
	var dir = DirAccess.open(backgrounds_dir)
	if dir == null:
		print("Error: Could not open backgrounds directory")
		return

	var files = dir.get_files()
	for file_name in files:
		if file_name.ends_with(".json"):
			var background_name = file_name.replace(".json", "").replace("_", " ").capitalize()
			var file_path = backgrounds_dir + file_name
			var background_data = load_json_file(file_path)
			if not background_data.is_empty():
				backgrounds_data[background_name] = background_data
				print("Loaded background: " + background_name)

# Helper function to load a JSON file
func load_json_file(file_path: String) -> Dictionary:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		print("Error: Could not open file: " + file_path)
		return {}

	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		print("Error parsing " + file_path + ": " + json.get_error_message())
		return {}

	return json.get_data()

# Load JSON data by name (generic function for any JSON file)
func load_json_data(data_name: String) -> Dictionary:
	"""Load JSON data by name from the data directory"""
	var file_path = "res://data/" + data_name + ".json"
	return load_json_file(file_path)

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

# Load activities data from ability-based JSON files
func load_activities():
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

	# Load each ability's activities from their respective JSON files
	var abilities = ["strength", "dexterity", "intelligence", "wisdom", "charisma", "constitution", "general"]

	for ability in abilities:
		var file_path = "res://data/activities/" + ability + ".json"
		var file = FileAccess.open(file_path, FileAccess.READ)

		if file:
			var json_string = file.get_as_text()
			file.close()

			var json = JSON.new()
			var parse_result = json.parse(json_string)

			if parse_result == OK:
				var activities_array = json.data

				# Convert array to dictionary keyed by activity ID
				for activity_data in activities_array:
					var activity_id = activity_data.get("id", "")
					if activity_id != "":
						activities_data[ability][activity_id] = activity_data
					else:
						print("Activity missing ID in ", ability, ".json")
			else:
				print("Error parsing ", ability, ".json: ", json.error_string)
		else:
			print("Error opening ", ability, ".json")

	print("Loaded ", _count_total_activities(), " activities from ability-based JSON files")

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
