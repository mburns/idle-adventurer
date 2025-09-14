# Build script for Idle Adventurer
# This script handles automated building and packaging

extends Node

var build_configs = {
    "web": {
        "platform": "Web",
        "output": "builds/web/idle-adventurer.zip",
        "preset": 0,
        "debug_output": "builds/web-debug/idle-adventurer.zip"
    }
}

var version = "0.1.0"
var build_number = 1

func _ready():
    # Parse command line arguments
    var args = OS.get_cmdline_args()

    if args.size() > 0:
        var command = args[0]
        match command:
            "build":
                if args.size() > 1:
                    var debug = args.size() > 2 and args[2] == "debug"
                    build_platform(args[1], debug)
                else:
                    build_all_platforms()
            "test":
                run_tests()
            "lint":
                run_linting()
            "clean":
                clean_builds()
            "package":
                package_release()
            "deploy":
                deploy_release()
            _:
                print_help()
    else:
        print_help()

func build_platform(platform: String, debug: bool = false):
    if not build_configs.has(platform):
        print("Error: Unknown platform: " + platform)
        return

    var config = build_configs[platform]
    var build_type = "debug" if debug else "release"
    print("Building for " + platform + " (" + build_type + ")...")

    # Create builds directory
    create_build_directories(platform, debug)

    # Export the project
    var export_path = config.debug_output if debug else config.output
    var export_mode = "debug" if debug else "release"

    print("Export command: godot --headless --export-" + export_mode + " \"%s\" --path . --output \"%s\"" % [config.platform, export_path])

    # In a real implementation, this would execute the export command
    # For now, we'll create a placeholder file
    create_placeholder_build(platform, export_path, debug)

func build_all_platforms():
    print("Building for all platforms...")
    for platform in build_configs.keys():
        build_platform(platform)

func run_tests():
    print("Running tests...")
    # This would run the test suite
    # For now, we'll just print the command
    print("Test command: godot --headless --script test_runner.gd --quit")

func clean_builds():
    print("Cleaning build directory...")
    var dir = DirAccess.open("res://")
    if dir.dir_exists("builds"):
        dir.remove("builds")
        print("Build directory cleaned")

func create_build_directories(platform: String, debug: bool):
    """Create necessary build directories"""
    var dir = DirAccess.open("res://")
    var build_dir = "builds/" + platform
    if debug:
        build_dir += "-debug"

    if not dir.dir_exists("builds"):
        dir.make_dir("builds")
    if not dir.dir_exists(build_dir):
        dir.make_dir(build_dir)

func create_placeholder_build(platform: String, output_path: String, debug: bool):
    """Create a placeholder build file for testing"""
    var file = FileAccess.open(output_path, FileAccess.WRITE)
    if file:
        file.store_string("Idle Adventurer " + version + " - " + platform + " (" + ("debug" if debug else "release") + ")\n")
        file.store_string("Build number: " + str(build_number) + "\n")
        file.store_string("Built on: " + Time.get_datetime_string_from_system() + "\n")
        file.close()
        print("Created placeholder build: " + output_path)
    else:
        print("Error: Could not create build file: " + output_path)

func run_linting():
    """Run code linting"""
    print("Running linting...")
    print("Lint command: godot --headless --script scripts/lint.gd --quit")

func package_release():
    """Package release builds"""
    print("Packaging release...")
    # This would create zip files for distribution
    print("Package command: zip -r idle-adventurer-" + version + ".zip builds/")

func deploy_release():
    """Deploy release to distribution platforms"""
    print("Deploying release...")
    # This would upload to Steam, itch.io, etc.
    print("Deploy command: steamcmd +login +app_build +quit")

func print_help():
    print("Idle Adventurer Build Script")
    print("Usage: godot --script build.gd <command> [platform] [debug]")
    print("")
    print("Commands:")
    print("  build [platform] [debug]  - Build for specified platform (linux, windows, macos)")
    print("  build                     - Build for all platforms")
    print("  test                      - Run test suite")
    print("  lint                      - Run code linting")
    print("  clean                     - Clean build directory")
    print("  package                   - Package release builds")
    print("  deploy                    - Deploy release")
    print("  help                      - Show this help message")
    print("")
    print("Examples:")
    print("  godot --script build.gd build linux")
    print("  godot --script build.gd build windows debug")
    print("  godot --script build.gd test")
    print("  godot --script build.gd package")
,
