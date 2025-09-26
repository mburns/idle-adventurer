extends Node

# Unified YAML parser utility class
# Replaces custom YAML parsing code scattered across multiple files

class_name YAMLParser

signal parse_error(file_path: String, error_message: String)


# Parse a simple YAML file into a Dictionary
func parse_yaml_file(file_path: String) -> Dictionary:
	"""Parse a YAML file and return a Dictionary"""
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		var error_msg = "Could not open file: " + file_path
		print("Error: " + error_msg)
		parse_error.emit(file_path, error_msg)
		return {}

	var yaml_string = file.get_as_text()
	file.close()

	var result = parse_yaml_string(yaml_string)
	if result == null:
		var error_msg = "Failed to parse YAML content"
		print("Error: " + error_msg + " in " + file_path)
		parse_error.emit(file_path, error_msg)
		return {}

	return result

# Parse YAML string into Dictionary
func parse_yaml_string(yaml_string: String) -> Dictionary:
	"""Parse YAML string into Dictionary with proper nested structure support"""
	var lines = yaml_string.split("\n")
	var result = {}
	var stack = []  # Stack to track nested structures

	for line in lines:
		var original_line = line
		line = line.strip_edges()
		if line.is_empty() or line.begins_with("#"):
			continue

		var line_indent = get_indent_level(original_line)

		# Adjust stack based on indentation
		while stack.size() > 0 and stack[-1].indent >= line_indent:
			stack.pop_back()

		# Handle key-value pairs
		if ":" in line and not line.begins_with("-"):
			var parts = line.split(":", 1)
			var key = parts[0].strip_edges()
			var value = parts[1].strip_edges()

			# Determine where to store this key-value pair
			var target_dict = result
			if stack.size() > 0:
				target_dict = stack[-1].dict

			# If value is empty, this starts a nested structure
			if value.is_empty():
				var new_dict = {}
				target_dict[key] = new_dict
				stack.append({"dict": new_dict, "key": key, "indent": line_indent})
			else:
				target_dict[key] = parse_value(value)

		# Handle array items
		elif line.begins_with("-"):
			var item = line.substr(1).strip_edges()

			# Find the parent key for this array
			var parent_key = ""
			if stack.size() > 0:
				parent_key = stack[-1].key

			# Determine where to store this array item
			var target_dict = result
			if stack.size() > 0:
				target_dict = stack[-1].dict

			# Create array if it doesn't exist
			if not target_dict.has(parent_key):
				target_dict[parent_key] = []

			# Add item to array
			target_dict[parent_key].append(parse_value(item))

	return result

# Parse YAML activities array format
func parse_yaml_activities(yaml_string: String) -> Array:
	"""Parse YAML activities array format"""
	var lines = yaml_string.split("\n")
	var activities = []
	var current_activity = {}
	var current_key = ""
	var in_multiline = false
	var in_dict = false
	var current_dict = {}
	var dict_key = ""
	var indent_level = 0

	for line in lines:
		var original_line = line
		line = line.strip_edges()
		if line.is_empty() or line.begins_with("#"):
			continue

		var line_indent = get_indent_level(original_line)

		# Handle array items (activities)
		if line.begins_with("-") and line_indent == 0:
			# Save previous activity if exists
			if not current_activity.is_empty():
				activities.append(current_activity)

			# Start new activity
			current_activity = {}
			var item_line = line.substr(1).strip_edges()  # Remove the "-" character
			if ":" in item_line:
				var parts = item_line.split(":", 1)
				current_key = parts[0].strip_edges()
				var value = parts[1].strip_edges()
				if value.is_empty():
					in_multiline = true
				else:
					current_activity[current_key] = parse_value(value)
			indent_level = 0
			in_dict = false
		elif line.begins_with("-") and line_indent > 0:
			# Handle nested array items
			var item = line.substr(1).strip_edges()
			if not current_activity.has(current_key):
				current_activity[current_key] = []
			elif not current_activity[current_key] is Array:
				# Don't overwrite existing non-array values - this is likely a parsing error
				print("Warning: Attempting to append to non-array value for key '", current_key, "'")
				continue
			current_activity[current_key].append(parse_value(item))
		elif ":" in line and line_indent > 0:
			# Handle key-value pairs within activity
			if in_multiline and current_key != "":
				current_activity[current_key] = current_activity.get(current_key, "").strip_edges()
				in_multiline = false

			var parts = line.split(":", 1)
			var key = parts[0].strip_edges()
			var value = parts[1].strip_edges()

			# Check if this is a dictionary key (no value, or empty value)
			if value.is_empty() or value == "":
				# If we were in a dict, save it
				if in_dict and dict_key != "":
					current_activity[dict_key] = current_dict

				# Start new dictionary
				dict_key = key
				current_dict = {}
				in_dict = true
				continue

			# If we're in a dictionary, add to current dict
			if in_dict and original_line.begins_with("  "):
				# This is a nested key-value pair
				var dict_value = parse_value(value)
				current_dict[key] = dict_value
				continue

			# Regular key-value pair
			current_activity[key] = parse_value(value)
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

	# Save any remaining dictionary
	if in_dict and dict_key != "":
		current_activity[dict_key] = current_dict

	# Save last activity
	if not current_activity.is_empty():
		activities.append(current_activity)

	return activities

# Parse YAML quest configuration
func parse_yaml_quest_config(yaml_string: String) -> Dictionary:
	"""Parse YAML quest configuration"""
	var lines = yaml_string.split("\n")
	var result = {}
	var current_section = ""
	var current_array = []
	var current_object = {}
	var in_object = false
	var object_key = ""
	var in_multiline = false
	var indent_level = 0

	for line in lines:
		line = line.strip_edges()
		if line.is_empty() or line.begins_with("#"):
			continue

		var line_indent = get_indent_level(line)

		# Handle top-level sections
		if line_indent == 0 and ":" in line and not line.begins_with("-"):
			# Save previous section if exists
			if current_section != "" and current_array.size() > 0:
				result[current_section] = current_array

			var parts = line.split(":", 1)
			current_section = parts[0].strip_edges()
			current_array = []
			continue

		# Handle array items within sections
		if line.begins_with("- ") and line_indent == 0:
			# Save previous object if exists
			if in_object and current_object.size() > 0:
				current_array.append(current_object)

			# Start new object
			current_object = {}
			in_object = true
			continue
		elif line.begins_with("-") and line_indent > 0:
			# Handle nested array items
			var item = line.substr(1).strip_edges()
			if not current_object.has(object_key):
				current_object[object_key] = []
			current_object[object_key].append(parse_value(item))
		elif ":" in line and line_indent > 0:
			# Handle key-value pairs within objects
			if in_multiline and object_key != "":
				current_object[object_key] = current_object.get(object_key, "").strip_edges()
				in_multiline = false

			var parts = line.split(":", 1)
			object_key = parts[0].strip_edges()
			var value = parts[1].strip_edges()

			if value.is_empty():
				in_multiline = true
				current_object[object_key] = ""
			else:
				current_object[object_key] = parse_value(value)
		elif in_multiline and line_indent > indent_level:
			# Continue multiline value
			current_object[object_key] += "\n" + line

	# Add last object and section
	if in_object and current_object.size() > 0:
		current_array.append(current_object)
	if current_section != "" and current_array.size() > 0:
		result[current_section] = current_array

	return result

# Helper function to get indentation level
func get_indent_level(line: String) -> int:
	"""Get the indentation level of a line"""
	var indent = 0
	for i in range(line.length()):
		if line[i] == " ":
			indent += 1
		elif line[i] == "\t":
			indent += 4
		else:
			break
	return indent

# Parse a YAML value string into appropriate type
func parse_value(value: String) -> Variant:
	"""Parse a YAML value string into appropriate type"""
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
	# Try to parse as empty array - return as Array[String] for consistency
	elif value == "[]":
		return [] as Array[String]
	# Return as string
	else:
		return value

# Validate YAML file exists and is readable
func validate_yaml_file(file_path: String) -> bool:
	"""Validate that a YAML file exists and is readable"""
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		return false
	file.close()
	return true

# Get list of YAML files in a directory
func get_yaml_files_in_directory(directory_path: String) -> Array[String]:
	"""Get list of YAML files in a directory"""
	var yaml_files: Array[String] = []
	var dir = DirAccess.open(directory_path)
	if dir == null:
		print("Error: Could not open directory: " + directory_path)
		return yaml_files

	var files = dir.get_files()
	for file_name in files:
		if file_name.ends_with(".yaml"):
			yaml_files.append(directory_path + file_name)

	return yaml_files
