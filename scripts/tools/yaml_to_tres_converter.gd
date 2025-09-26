extends Node

# YAML to .tres Converter
# Converts existing YAML files to Godot Resource files (.tres)
# This is a one-time migration tool

class_name YAMLToTresConverter

var yaml_parser: YAMLParser
var converter: YAMLToResourceConverter

func _ready():
	yaml_parser = YAMLParser.new()
	converter = YAMLToResourceConverter.new()

	# Run conversion
	convert_all_data()

func convert_all_data():
	"""Convert all YAML data files to .tres files"""
	print("Starting YAML to .tres conversion...")

	# Create output directories
	create_output_directories()

	# Convert different data types
	convert_activities()
	convert_races()
	convert_classes()
	convert_spells()
	convert_monsters()
	convert_equipment()
	convert_magic_items()
	convert_languages()
	convert_currencies()
	convert_alignments()
	convert_achievements()
	convert_lifestyles()
	convert_level_requirements()
	convert_names()

	print("Conversion complete!")

func create_output_directories():
	"""Create output directories for .tres files"""
	var dir = DirAccess.open("res://data/")
	if not dir:
		print("Error: Could not access data directory")
		return

	# Create .tres subdirectories
	var tres_dirs = [
		"activities_tres",
		"races_tres",
		"classes_tres",
		"spells_tres",
		"monsters_tres",
		"equipment_tres",
		"magic_items_tres",
		"languages_tres",
		"currencies_tres",
		"alignments_tres",
		"achievements_tres",
		"lifestyles_tres",
		"level_requirements_tres",
		"names_tres"
	]

	for tres_dir in tres_dirs:
		var path = "res://data/" + tres_dir
		if not dir.dir_exists(path):
			dir.make_dir(path)

func convert_activities():
	"""Convert activity YAML files to .tres files"""
	print("Converting activities...")
	var activities_dir = "res://data/activities/"
	var output_dir = "res://data/activities_tres/"

	var dir = DirAccess.open(activities_dir)
	if not dir:
		print("Error: Could not open activities directory")
		return

	var files = dir.get_files()
	for file_name in files:
		if file_name.ends_with(".yaml"):
			var input_path = activities_dir + file_name
			var output_path = output_dir + file_name.replace(".yaml", ".tres")
			convert_activity_file(input_path, output_path)

func convert_activity_file(input_path: String, output_path: String):
	"""Convert a single activity YAML file to .tres"""
	var file = FileAccess.open(input_path, FileAccess.READ)
	if not file:
		print("Warning: Could not open file: " + input_path)
		return

	var yaml_string = file.get_as_text()
	file.close()

	var activities_array = yaml_parser.parse_yaml_activities(yaml_string)
	if activities_array.is_empty():
		print("Warning: No activities found in " + input_path)
		return

	for activity_data in activities_array:
		var activity_resource = converter.yaml_to_activity_resource(activity_data)
		if activity_resource.activity_name != "":
			var resource_path = output_path.replace(".tres", "_" + activity_resource.activity_name.to_lower().replace(" ", "_") + ".tres")
			ResourceSaver.save(activity_resource, resource_path)
			print("Saved: " + resource_path)

func convert_races():
	"""Convert race YAML files to .tres files"""
	print("Converting races...")
	var races_dir = "res://data/races/"
	var output_dir = "res://data/races_tres/"

	var dir = DirAccess.open(races_dir)
	if not dir:
		print("Error: Could not open races directory")
		return

	var files = dir.get_files()
	for file_name in files:
		if file_name.ends_with(".yaml"):
			var input_path = races_dir + file_name
			var output_path = output_dir + file_name.replace(".yaml", ".tres")
			convert_race_file(input_path, output_path)

func convert_race_file(input_path: String, output_path: String):
	"""Convert a single race YAML file to .tres"""
	var file = FileAccess.open(input_path, FileAccess.READ)
	if not file:
		print("Warning: Could not open file: " + input_path)
		return

	var yaml_string = file.get_as_text()
	file.close()

	var yaml_data = yaml_parser.parse_yaml_string(yaml_string)
	if yaml_data.is_empty():
		print("Warning: No race data found in " + input_path)
		return

	var race_resource = converter.yaml_to_race_resource(yaml_data)
	if race_resource.name != "":
		ResourceSaver.save(race_resource, output_path)
		print("Saved: " + output_path)

func convert_classes():
	"""Convert class YAML files to .tres files"""
	print("Converting classes...")
	var classes_dir = "res://data/classes/"
	var output_dir = "res://data/classes_tres/"

	var dir = DirAccess.open(classes_dir)
	if not dir:
		print("Error: Could not open classes directory")
		return

	var files = dir.get_files()
	for file_name in files:
		if file_name.ends_with(".yaml"):
			var input_path = classes_dir + file_name
			var output_path = output_dir + file_name.replace(".yaml", ".tres")
			convert_class_file(input_path, output_path)

func convert_class_file(input_path: String, output_path: String):
	"""Convert a single class YAML file to .tres"""
	var file = FileAccess.open(input_path, FileAccess.READ)
	if not file:
		print("Warning: Could not open file: " + input_path)
		return

	var yaml_string = file.get_as_text()
	file.close()

	var yaml_data = yaml_parser.parse_yaml_string(yaml_string)
	if yaml_data.is_empty():
		print("Warning: No class data found in " + input_path)
		return

	var class_resource = converter.yaml_to_class_resource(yaml_data)
	if class_resource.name != "":
		ResourceSaver.save(class_resource, output_path)
		print("Saved: " + output_path)

func convert_spells():
	"""Convert spell YAML files to .tres files"""
	print("Converting spells...")
	var spells_dir = "res://data/spells/"
	var output_dir = "res://data/spells_tres/"

	var dir = DirAccess.open(spells_dir)
	if not dir:
		print("Error: Could not open spells directory")
		return

	var files = dir.get_files()
	for file_name in files:
		if file_name.ends_with(".yaml"):
			var input_path = spells_dir + file_name
			var output_path = output_dir + file_name.replace(".yaml", ".tres")
			convert_spell_file(input_path, output_path)

func convert_spell_file(input_path: String, output_path: String):
	"""Convert a single spell YAML file to .tres"""
	var file = FileAccess.open(input_path, FileAccess.READ)
	if not file:
		print("Warning: Could not open file: " + input_path)
		return

	var yaml_string = file.get_as_text()
	file.close()

	var yaml_data = yaml_parser.parse_yaml_string(yaml_string)
	if yaml_data.is_empty():
		print("Warning: No spell data found in " + input_path)
		return

	var spell_resource = converter.yaml_to_spell_resource(yaml_data)
	if spell_resource.spell_name != "":
		ResourceSaver.save(spell_resource, output_path)
		print("Saved: " + output_path)

func convert_monsters():
	"""Convert monster YAML files to .tres files"""
	print("Converting monsters...")
	var monsters_dir = "res://data/monsters/"
	var output_dir = "res://data/monsters_tres/"

	var dir = DirAccess.open(monsters_dir)
	if not dir:
		print("Error: Could not open monsters directory")
		return

	var files = dir.get_files()
	for file_name in files:
		if file_name.ends_with(".yaml"):
			var input_path = monsters_dir + file_name
			var output_path = output_dir + file_name.replace(".yaml", ".tres")
			convert_monster_file(input_path, output_path)

func convert_monster_file(input_path: String, output_path: String):
	"""Convert a single monster YAML file to .tres"""
	var file = FileAccess.open(input_path, FileAccess.READ)
	if not file:
		print("Warning: Could not open file: " + input_path)
		return

	var yaml_string = file.get_as_text()
	file.close()

	var yaml_data = yaml_parser.parse_yaml_string(yaml_string)
	if yaml_data.is_empty():
		print("Warning: No monster data found in " + input_path)
		return

	var monster_resource = converter.yaml_to_monster_resource(yaml_data)
	if monster_resource.name != "":
		ResourceSaver.save(monster_resource, output_path)
		print("Saved: " + output_path)

func convert_equipment():
	"""Convert equipment YAML files to .tres files"""
	print("Converting equipment...")
	var equipment_dir = "res://data/equipment/"
	var output_dir = "res://data/equipment_tres/"

	var dir = DirAccess.open(equipment_dir)
	if not dir:
		print("Error: Could not open equipment directory")
		return

	var files = dir.get_files()
	for file_name in files:
		if file_name.ends_with(".yaml"):
			var input_path = equipment_dir + file_name
			var output_path = output_dir + file_name.replace(".yaml", ".tres")
			convert_equipment_file(input_path, output_path)

func convert_equipment_file(input_path: String, output_path: String):
	"""Convert a single equipment YAML file to .tres"""
	var file = FileAccess.open(input_path, FileAccess.READ)
	if not file:
		print("Warning: Could not open file: " + input_path)
		return

	var yaml_string = file.get_as_text()
	file.close()

	var yaml_data = yaml_parser.parse_yaml_string(yaml_string)
	if yaml_data.is_empty():
		print("Warning: No equipment data found in " + input_path)
		return

	var equipment_resource = converter.yaml_to_equipment_resource(yaml_data)
	if equipment_resource.item_name != "":
		ResourceSaver.save(equipment_resource, output_path)
		print("Saved: " + output_path)

func convert_magic_items():
	"""Convert magic item YAML files to .tres files"""
	print("Converting magic items...")
	var magic_items_dir = "res://data/magic_items/"
	var output_dir = "res://data/magic_items_tres/"

	var dir = DirAccess.open(magic_items_dir)
	if not dir:
		print("Error: Could not open magic items directory")
		return

	var files = dir.get_files()
	for file_name in files:
		if file_name.ends_with(".yaml"):
			var input_path = magic_items_dir + file_name
			var output_path = output_dir + file_name.replace(".yaml", ".tres")
			convert_magic_item_file(input_path, output_path)

func convert_magic_item_file(input_path: String, output_path: String):
	"""Convert a single magic item YAML file to .tres"""
	var file = FileAccess.open(input_path, FileAccess.READ)
	if not file:
		print("Warning: Could not open file: " + input_path)
		return

	var yaml_string = file.get_as_text()
	file.close()

	var yaml_data = yaml_parser.parse_yaml_string(yaml_string)
	if yaml_data.is_empty():
		print("Warning: No magic item data found in " + input_path)
		return

	var magic_item_resource = converter.yaml_to_magic_item_resource(yaml_data)
	if magic_item_resource.name != "":
		ResourceSaver.save(magic_item_resource, output_path)
		print("Saved: " + output_path)

func convert_languages():
	"""Convert language YAML files to .tres files"""
	print("Converting languages...")
	var languages_dir = "res://data/languages/"
	var output_dir = "res://data/languages_tres/"

	var dir = DirAccess.open(languages_dir)
	if not dir:
		print("Error: Could not open languages directory")
		return

	var files = dir.get_files()
	for file_name in files:
		if file_name.ends_with(".yaml"):
			var input_path = languages_dir + file_name
			var output_path = output_dir + file_name.replace(".yaml", ".tres")
			convert_language_file(input_path, output_path)

func convert_language_file(input_path: String, output_path: String):
	"""Convert a single language YAML file to .tres"""
	var file = FileAccess.open(input_path, FileAccess.READ)
	if not file:
		print("Warning: Could not open file: " + input_path)
		return

	var yaml_string = file.get_as_text()
	file.close()

	var yaml_data = yaml_parser.parse_yaml_string(yaml_string)
	if yaml_data.is_empty():
		print("Warning: No language data found in " + input_path)
		return

	var language_resource = converter.yaml_to_language_resource(yaml_data)
	if language_resource.name != "":
		ResourceSaver.save(language_resource, output_path)
		print("Saved: " + output_path)

func convert_currencies():
	"""Convert currency YAML files to .tres files"""
	print("Converting currencies...")
	var currencies_dir = "res://data/currency/"
	var output_dir = "res://data/currencies_tres/"

	var dir = DirAccess.open(currencies_dir)
	if not dir:
		print("Error: Could not open currencies directory")
		return

	var files = dir.get_files()
	for file_name in files:
		if file_name.ends_with(".yaml"):
			var input_path = currencies_dir + file_name
			var output_path = output_dir + file_name.replace(".yaml", ".tres")
			convert_currency_file(input_path, output_path)

func convert_currency_file(input_path: String, output_path: String):
	"""Convert a single currency YAML file to .tres"""
	var file = FileAccess.open(input_path, FileAccess.READ)
	if not file:
		print("Warning: Could not open file: " + input_path)
		return

	var yaml_string = file.get_as_text()
	file.close()

	var yaml_data = yaml_parser.parse_yaml_string(yaml_string)
	if yaml_data.is_empty():
		print("Warning: No currency data found in " + input_path)
		return

	var currency_resource = converter.yaml_to_currency_resource(yaml_data)
	if currency_resource.name != "":
		ResourceSaver.save(currency_resource, output_path)
		print("Saved: " + output_path)

func convert_alignments():
	"""Convert alignment YAML files to .tres files"""
	print("Converting alignments...")
	var alignments_dir = "res://data/alignments/"
	var output_dir = "res://data/alignments_tres/"

	var dir = DirAccess.open(alignments_dir)
	if not dir:
		print("Error: Could not open alignments directory")
		return

	var files = dir.get_files()
	for file_name in files:
		if file_name.ends_with(".yaml"):
			var input_path = alignments_dir + file_name
			var output_path = output_dir + file_name.replace(".yaml", ".tres")
			convert_alignment_file(input_path, output_path)

func convert_alignment_file(input_path: String, output_path: String):
	"""Convert a single alignment YAML file to .tres"""
	var file = FileAccess.open(input_path, FileAccess.READ)
	if not file:
		print("Warning: Could not open file: " + input_path)
		return

	var yaml_string = file.get_as_text()
	file.close()

	var yaml_data = yaml_parser.parse_yaml_string(yaml_string)
	if yaml_data.is_empty():
		print("Warning: No alignment data found in " + input_path)
		return

	var alignment_resource = converter.yaml_to_alignment_resource(yaml_data)
	if alignment_resource.name != "":
		ResourceSaver.save(alignment_resource, output_path)
		print("Saved: " + output_path)

func convert_achievements():
	"""Convert achievement YAML files to .tres files"""
	print("Converting achievements...")
	var achievements_file = "res://data/achievements.yaml"
	var output_dir = "res://data/achievements_tres/"

	var file = FileAccess.open(achievements_file, FileAccess.READ)
	if not file:
		print("Warning: Could not open achievements file")
		return

	var yaml_string = file.get_as_text()
	file.close()

	var yaml_data = yaml_parser.parse_yaml_string(yaml_string)
	if yaml_data.is_empty():
		print("Warning: No achievement data found")
		return

	# Parse achievements array
	var achievements_data = yaml_data.get("achievements", [])
	for achievement_data in achievements_data:
		var achievement_resource = converter.yaml_to_achievement_resource(achievement_data)
		if achievement_resource.name != "":
			var output_path = output_dir + achievement_resource.id + ".tres"
			ResourceSaver.save(achievement_resource, output_path)
			print("Saved: " + output_path)

func convert_lifestyles():
	"""Convert lifestyle YAML files to .tres files"""
	print("Converting lifestyles...")
	var lifestyles_file = "res://data/lifestyles.yaml"
	var output_dir = "res://data/lifestyles_tres/"

	var file = FileAccess.open(lifestyles_file, FileAccess.READ)
	if not file:
		print("Warning: Could not open lifestyles file")
		return

	var yaml_string = file.get_as_text()
	file.close()

	var yaml_data = yaml_parser.parse_yaml_string(yaml_string)
	if yaml_data.is_empty():
		print("Warning: No lifestyle data found")
		return

	# Parse lifestyles array
	var lifestyles_data = yaml_data.get("lifestyles", [])
	for lifestyle_data in lifestyles_data:
		var lifestyle_resource = converter.yaml_to_lifestyle_resource(lifestyle_data)
		if lifestyle_resource.name != "":
			var output_path = output_dir + lifestyle_resource.id + ".tres"
			ResourceSaver.save(lifestyle_resource, output_path)
			print("Saved: " + output_path)

func convert_level_requirements():
	"""Convert level requirement YAML files to .tres files"""
	print("Converting level requirements...")
	var level_reqs_file = "res://data/level_requirements.yaml"
	var output_dir = "res://data/level_requirements_tres/"

	var file = FileAccess.open(level_reqs_file, FileAccess.READ)
	if not file:
		print("Warning: Could not open level requirements file")
		return

	var yaml_string = file.get_as_text()
	file.close()

	var yaml_data = yaml_parser.parse_yaml_string(yaml_string)
	if yaml_data.is_empty():
		print("Warning: No level requirement data found")
		return

	# Parse level requirements array
	var level_reqs_data = yaml_data.get("level_requirements", [])
	for level_req_data in level_reqs_data:
		var level_req_resource = LevelRequirementResource.new()
		level_req_resource.level = level_req_data.get("level", 1)
		level_req_resource.experience_required = level_req_data.get("experience_required", 0)
		level_req_resource.description = level_req_data.get("description", "")

		var output_path = output_dir + "level_" + str(level_req_resource.level) + ".tres"
		ResourceSaver.save(level_req_resource, output_path)
		print("Saved: " + output_path)

func convert_names():
	"""Convert name YAML files to .tres files"""
	print("Converting names...")
	var names_file = "res://data/names.yaml"
	var output_dir = "res://data/names_tres/"

	var file = FileAccess.open(names_file, FileAccess.READ)
	if not file:
		print("Warning: Could not open names file")
		return

	var yaml_string = file.get_as_text()
	file.close()

	var yaml_data = yaml_parser.parse_yaml_string(yaml_string)
	if yaml_data.is_empty():
		print("Warning: No name data found")
		return

	# Parse first names
	var first_names_data = yaml_data.get("first_names", [])
	for name_string in first_names_data:
		var name_resource = NameResource.new()
		name_resource.name = str(name_string)
		name_resource.category = "first"
		name_resource.gender = "neutral"
		name_resource.culture = "common"
		name_resource.rarity = "common"

		var output_path = output_dir + "first_" + name_resource.name.to_lower().replace(" ", "_") + ".tres"
		ResourceSaver.save(name_resource, output_path)
		print("Saved: " + output_path)

	# Parse last names
	var last_names_data = yaml_data.get("last_names", [])
	for name_string in last_names_data:
		var name_resource = NameResource.new()
		name_resource.name = str(name_string)
		name_resource.category = "last"
		name_resource.gender = "neutral"
		name_resource.culture = "common"
		name_resource.rarity = "common"

		var output_path = output_dir + "last_" + name_resource.name.to_lower().replace(" ", "_") + ".tres"
		ResourceSaver.save(name_resource, output_path)
		print("Saved: " + output_path)
