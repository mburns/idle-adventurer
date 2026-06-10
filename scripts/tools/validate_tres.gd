extends SceneTree

# Validate .tres files
func _init():
    var file_path = OS.get_cmdline_args()[-1] if OS.get_cmdline_args().size() > 0 else ""

    if file_path == "":
        print("Usage: godot --headless --script validate_tres.gd -- <file_path>")
        quit(1)

    validate_tres_file(file_path)
    quit(0)

func validate_tres_file(file_path: String):
    """Validate a .tres file by attempting to load it"""
    var resource = load(file_path)

    if resource == null:
        print("ERROR: Failed to load resource")
        quit(1)

    # Check if it's a valid resource
    if not resource is Resource:
        print("ERROR: Not a valid Resource")
        quit(1)

    # Try to access basic properties
    if resource.has_method("get_script"):
        var script = resource.get_script()
        if script == null:
            print("WARNING: Resource has no script")

    print("SUCCESS: Resource loaded successfully")
