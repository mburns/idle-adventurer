extends Node

# Load D&D data from JSON files
var races_data: Array[Dictionary] = []
var classes_data: Array[Dictionary] = []
var backgrounds_data: Array[Dictionary] = []
var activities_data: Dictionary = {}

func _ready():
	load_all_data()

# Load all data from JSON files
func load_all_data():
	load_races()
	load_classes()
	load_backgrounds()
	load_activities()

# Load race data
func load_races():
	var file = FileAccess.open("res://data/races.json", FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			races_data = json.data
		else:
			print("Error parsing races.json: ", json.error_string)
	else:
		print("Error opening races.json")

# Load class data
func load_classes():
	var file = FileAccess.open("res://data/classes.json", FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			classes_data = json.data
		else:
			print("Error parsing classes.json: ", json.error_string)
	else:
		print("Error opening classes.json")

# Load background data
func load_backgrounds():
	var file = FileAccess.open("res://data/backgrounds.json", FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			backgrounds_data = json.data
		else:
			print("Error parsing backgrounds.json: ", json.error_string)
	else:
		print("Error opening backgrounds.json")

# Get race names
func get_race_names() -> Array[String]:
	var names: Array[String] = []
	for race in races_data:
		names.append(race.get("name", ""))
	return names

# Get class names
func get_class_names() -> Array[String]:
	var names: Array[String] = []
	for class_data in classes_data:
		names.append(class_data.get("name", ""))
	return names

# Get background names
func get_background_names() -> Array[String]:
	var names: Array[String] = []
	for background in backgrounds_data:
		names.append(background.get("name", ""))
	return names

# Get race data by name
func get_race_data(race_name: String) -> Dictionary:
	for race in races_data:
		if race.get("name", "") == race_name:
			return race
	return {}

# Get class data by name
func get_class_data(class_name_param: String) -> Dictionary:
	for class_data in classes_data:
		if class_data.get("name", "") == class_name_param:
			return class_data
	return {}

# Get background data by name
func get_background_data(background_name: String) -> Dictionary:
	for background in backgrounds_data:
		if background.get("name", "") == background_name:
			return background
	return {}

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
