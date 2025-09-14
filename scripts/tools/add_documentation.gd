extends Node

# Script to add basic documentation to functions

func _ready():
    print("📝 Adding Documentation")
    print("=====================")

    add_documentation_to_file("res://scripts/core/character.gd")
    add_documentation_to_file("res://scripts/core/character_manager.gd")
    add_documentation_to_file("res://scripts/data/data_loader.gd")

    print("Documentation added!")
    get_tree().quit()

func add_documentation_to_file(file_path: String):
    print("Adding docs to: " + file_path)

    var file = FileAccess.open(file_path, FileAccess.READ)
    if file == null:
        return

    var content = file.get_as_text()
    file.close()

    var lines = content.split("\n")
    var new_lines: Array[String] = []

    for i in range(lines.size()):
        var line = lines[i]
        new_lines.append(line)

        # Check if this is a public function that needs documentation
        if line.strip_edges().begins_with("func ") and not line.strip_edges().begins_with("func _"):
            var func_name = extract_function_name(line)
            if func_name != "" and not has_documentation(lines, i):
                var doc = generate_documentation(func_name)
                new_lines.insert(new_lines.size() - 1, doc)

    var new_content = "\n".join(new_lines)

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
    for i in range(max(0, func_index - 3), func_index):
        var line = lines[i].strip_edges()
        if line.begins_with("#") and ("function" in line or "method" in line):
            return true
    return false

func generate_documentation(func_name: String) -> String:
    return "\t# " + func_name.replace("_", " ").capitalize() + " function"
