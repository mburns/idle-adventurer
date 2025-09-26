# test_yaml_parsing.gd
extends Node

const YAMLParser = preload("res://scripts/data/yaml_parser.gd")

func _ready():
	var yaml_parser = YAMLParser.new()

	# Test parsing a simple YAML file
	var file = FileAccess.open("res://data/activities/charisma.yaml", FileAccess.READ)
	if file:
		var yaml_string = file.get_as_text()
		file.close()

		print("YAML content:")
		print(yaml_string)
		print("\nParsed result:")
		var result = yaml_parser.parse_yaml_string(yaml_string)
		print(result)
		print("\nResult type: ", typeof(result))
		if result is Array:
			print("Array size: ", result.size())
			if result.size() > 0:
				print("First item: ", result[0])
				print("First item type: ", typeof(result[0]))
	else:
		print("Could not open file")

	get_tree().quit()
