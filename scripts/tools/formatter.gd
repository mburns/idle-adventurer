extends Node

# GDScript formatter to fix common code style issues

var processed_files: int = 0
var fixed_issues: int = 0

func _ready():
    print("🔧 GDScript Formatter")
    print("====================")
    print()

    # Format all GDScript files
    format_all_scripts()

    print("Formatting complete!")
    print("Processed files: " + str(processed_files))
    print("Fixed issues: " + str(fixed_issues))
    get_tree().quit()

func format_all_scripts():
    # Get all GDScript files
    var script_files = get_all_gdscript_files()

    for file_path in script_files:
        format_file(file_path)

func get_all_gdscript_files() -> Array[String]:
    var files: Array[String] = []

    # Get scripts directory
    var scripts_dir = DirAccess.open("res://scripts/")
    if scripts_dir:
        scan_directory(scripts_dir, "res://scripts/", files)

    # Get tests directory
    var tests_dir = DirAccess.open("res://tests/")
    if tests_dir:
        scan_directory(tests_dir, "res://tests/", files)

    return files

func scan_directory(dir: DirAccess, base_path: String, files: Array[String]):
    dir.list_dir_begin()
    var file_name = dir.get_next()

    while file_name != "":
        if file_name.ends_with(".gd"):
            files.append(base_path + file_name)
        elif dir.current_is_dir() and not file_name.begins_with("."):
            var sub_dir = DirAccess.open(base_path + file_name + "/")
            if sub_dir:
                scan_directory(sub_dir, base_path + file_name + "/", files)

        file_name = dir.get_next()

func format_file(file_path: String):
    print("Formatting: " + file_path)
    processed_files += 1

    var file = FileAccess.open(file_path, FileAccess.READ)
    if file == null:
        print("  ❌ Could not read file")
        return

    var content = file.get_as_text()
    file.close()

    var original_content = content
    content = format_content(content)

    if content != original_content:
        var write_file = FileAccess.open(file_path, FileAccess.WRITE)
        if write_file:
            write_file.store_string(content)
            write_file.close()
            fixed_issues += 1
            print("  ✅ Fixed formatting issues")
        else:
            print("  ❌ Could not write file")
    else:
        print("  ✓ No changes needed")

func format_content(content: String) -> String:
    var lines = content.split("\n")
    var formatted_lines: Array[String] = []

    for line in lines:
        var formatted_line = format_line(line)
        formatted_lines.append(formatted_line)

    return "\n".join(formatted_lines)

func format_line(line: String) -> String:
    # Remove trailing whitespace
    line = line.rstrip(" \t")

    # Convert tabs to spaces (4 spaces per tab)
    line = line.replace("\t", "    ")

    # Fix line length (break long lines)
    if line.length() > 120:
        line = break_long_line(line)

    return line

func break_long_line(line: String) -> String:
    # Simple line breaking for common patterns
    var indent = get_line_indent(line)
    var content = line.strip_edges()

    # Break at common operators
    var break_points = [", ", " and ", " or ", " + ", " - ", " * ", " / ", " = ", " == ", " != "]

    for break_point in break_points:
        if content.find(break_point) > 80:  # Only break if it's past 80 characters
            var parts = content.split(break_point)
            if parts.size() > 1:
                var result = parts[0] + break_point
                for i in range(1, parts.size()):
                    result += "\n" + indent + "    " + parts[i]
                return result

    return line

func get_line_indent(line: String) -> String:
    var indent = ""
    for i in range(line.length()):
        if line[i] == " " or line[i] == "\t":
            indent += line[i]
        else:
            break
    return indent

# Add basic documentation to functions
func add_documentation_to_file(file_path: String):
    var file = FileAccess.open(file_path, FileAccess.READ)
    if file == null:
        return

    var content = file.get_as_text()
    file.close()

    var lines = content.split("\n")
    var formatted_lines: Array[String] = []

    for i in range(lines.size()):
        var line = lines[i]
        formatted_lines.append(line)

        # Check if this is a function declaration that needs documentation
        if line.strip_edges().begins_with("func ") and not line.strip_edges().begins_with("func _"):
            var func_name = extract_function_name(line)
            if func_name != "" and not has_documentation(lines, i):
                var doc = generate_function_documentation(func_name)
                formatted_lines.insert(formatted_lines.size() - 1, doc)

    var new_content = "\n".join(formatted_lines)

    var write_file = FileAccess.open(file_path, FileAccess.WRITE)
    if write_file:
        write_file.store_string(new_content)
        write_file.close()

func extract_function_name(line: String) -> String:
    var func_pattern = RegEx.new()
    func_pattern.compile("func\\s+([a-zA-Z_][a-zA-Z0-9_]*)")
    var result = func_pattern.search(line)
    if result:
        return result.get_string(1)
    return ""

func has_documentation(lines: Array[String], func_index: int) -> bool:
    # Check if there's documentation before the function
    for i in range(max(0, func_index - 3), func_index):
        var line = lines[i].strip_edges()
        if line.begins_with("#") and ("function" in line or "method" in line or "description" in line):
            return true
    return false

func generate_function_documentation(func_name: String) -> String:
    return "\t# " + func_name.replace("_", " ").capitalize() + " function"
