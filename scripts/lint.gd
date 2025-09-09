# Linting script for Idle Adventurer
extends SceneTree

var lint_errors = []
var lint_warnings = []

func _init():
	print("Starting code linting...")
	
	# Lint all GDScript files
	lint_scripts("res://scripts/")
	lint_scripts("res://tests/")
	
	# Print results
	print_lint_results()
	
	# Exit with error code if there are errors
	if lint_errors.size() > 0:
		quit(1)
	else:
		quit(0)

func lint_scripts(directory: String):
	var dir = DirAccess.open(directory)
	if dir == null:
		return
	
	# Lint all .gd files in directory
	for file_name in dir.get_files():
		if file_name.ends_with(".gd"):
			lint_file(directory + file_name)
	
	# Recursively lint subdirectories
	for subdir in dir.get_directories():
		lint_scripts(directory + subdir + "/")

func lint_file(file_path: String):
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		return
	
	var content = file.get_as_text()
	file.close()
	
	var lines = content.split("\n")
	
	# Check each line
	for i in range(lines.size()):
		var line = lines[i]
		var line_number = i + 1
		
		# Check for common issues
		check_line_length(line, file_path, line_number)
		check_trailing_whitespace(line, file_path, line_number)
		check_tab_usage(line, file_path, line_number)
		check_missing_documentation(line, file_path, line_number)
		check_naming_conventions(line, file_path, line_number)
		check_unused_variables(line, file_path, line_number)

func check_line_length(line: String, file_path: String, line_number: int):
	if line.length() > 120:
		lint_warnings.append("%s:%d: Line too long (%d characters)" % [file_path, line_number, line.length()])

func check_trailing_whitespace(line: String, file_path: String, line_number: int):
	if line.ends_with(" ") or line.ends_with("\t"):
		lint_warnings.append("%s:%d: Trailing whitespace" % [file_path, line_number])

func check_tab_usage(line: String, file_path: String, line_number: int):
	if line.begins_with("\t"):
		lint_errors.append("%s:%d: Use spaces instead of tabs" % [file_path, line_number])

func check_missing_documentation(line: String, file_path: String, line_number: int):
	# Check for public functions without documentation
	if line.begins_with("func ") and not line.contains("#"):
		var func_name = line.split("func ")[1].split("(")[0].strip_edges()
		if not func_name.begins_with("_"):
			lint_warnings.append("%s:%d: Public function '%s' should have documentation" % [file_path, line_number, func_name])

func check_naming_conventions(line: String, file_path: String, line_number: int):
	# Check for snake_case variables
	var variable_pattern = RegEx.new()
	variable_pattern.compile("var\\s+([a-zA-Z_][a-zA-Z0-9_]*)\\s*=")
	var result = variable_pattern.search(line)
	if result:
		var var_name = result.get_string(1)
		if not is_snake_case(var_name):
			lint_errors.append("%s:%d: Variable '%s' should use snake_case" % [file_path, line_number, var_name])
	
	# Check for PascalCase classes
	var class_pattern = RegEx.new()
	class_pattern.compile("class_name\\s+([a-zA-Z_][a-zA-Z0-9_]*)")
	var class_result = class_pattern.search(line)
	if class_result:
		var class_name = class_result.get_string(1)
		if not is_pascal_case(class_name):
			lint_errors.append("%s:%d: Class '%s' should use PascalCase" % [file_path, line_number, class_name])

func check_unused_variables(line: String, file_path: String, line_number: int):
	# This is a simplified check - in a real implementation, you'd need to parse the entire file
	# to determine if variables are actually used
	pass

func is_snake_case(text: String) -> bool:
	var pattern = RegEx.new()
	pattern.compile("^[a-z][a-z0-9_]*$")
	return pattern.search(text) != null

func is_pascal_case(text: String) -> bool:
	var pattern = RegEx.new()
	pattern.compile("^[A-Z][a-zA-Z0-9]*$")
	return pattern.search(text) != null

func print_lint_results():
	print("\n=== LINT RESULTS ===")
	
	if lint_errors.size() > 0:
		print("\nErrors:")
		for error in lint_errors:
			print("  " + error)
	
	if lint_warnings.size() > 0:
		print("\nWarnings:")
		for warning in lint_warnings:
			print("  " + warning)
	
	print("\nTotal: %d errors, %d warnings" % [lint_errors.size(), lint_warnings.size()])
