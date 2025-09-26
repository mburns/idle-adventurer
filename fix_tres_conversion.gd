# fix_tres_conversion.gd
extends Node

const YAMLParser = preload("res://scripts/data/yaml_parser.gd")

var yaml_parser: YAMLParser

func _ready():
	yaml_parser = YAMLParser.new()
	print("Fixing .tres conversion - converting YAML to proper Godot resources...")
	fix_all_tres_files()
	print("Conversion complete!")
	get_tree().quit()

func fix_all_tres_files():
	var data_path = "res://data/"
	fix_directory_recursive(data_path)

func fix_directory_recursive(path: String):
	var dir = DirAccess.open(path)
	if not dir:
		print("Error: Could not open directory: " + path)
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			# Recursively process subdirectories
			fix_directory_recursive(path + file_name + "/")
		elif file_name.ends_with(".tres"):
			# Check if this .tres file is actually a YAML copy
			var tres_path = path + file_name
			var yaml_path = tres_path.replace(".tres", ".yaml")

			# If corresponding YAML file exists, convert it properly
			if FileAccess.file_exists(yaml_path):
				convert_yaml_to_proper_tres(yaml_path, tres_path)
		file_name = dir.get_next()
	dir.list_dir_end()

func convert_yaml_to_proper_tres(yaml_path: String, tres_path: String):
	print("Converting: " + yaml_path + " -> " + tres_path)

	# Read the YAML file
	var file = FileAccess.open(yaml_path, FileAccess.READ)
	if not file:
		print("Error: Could not open YAML file: " + yaml_path)
		return

	var yaml_string = file.get_as_text()
	file.close()

	# Parse YAML
	var yaml_data = yaml_parser.parse_yaml_string(yaml_string)
	if yaml_data.is_empty():
		print("Warning: No data found in YAML file: " + yaml_path)
		return

	# Create a proper Godot resource
	var resource = Resource.new()

	# Store the parsed data as a dictionary in the resource
	resource.set_meta("data", yaml_data)

	# Save as proper .tres file
	var error = ResourceSaver.save(resource, tres_path)
	if error != OK:
		print("Error saving resource to " + tres_path + ": " + error_string(error))
	else:
		print("Fixed: " + tres_path)
