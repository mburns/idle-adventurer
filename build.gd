# Build script for Idle Adventurer
# This script handles automated building and packaging

extends Node

var build_configs = {
	"linux": {
		"platform": "Linux/X11",
		"output": "builds/idle-adventurer-linux.x86_64",
		"preset": 0
	},
	"windows": {
		"platform": "Windows Desktop", 
		"output": "builds/idle-adventurer-windows.exe",
		"preset": 1
	},
	"macos": {
		"platform": "macOS",
		"output": "builds/idle-adventurer-macos.zip",
		"preset": 2
	}
}

func _ready():
	# Parse command line arguments
	var args = OS.get_cmdline_args()
	
	if args.size() > 0:
		var command = args[0]
		match command:
			"build":
				if args.size() > 1:
					build_platform(args[1])
				else:
					build_all_platforms()
			"test":
				run_tests()
			"clean":
				clean_builds()
			_:
				print_help()
	else:
		print_help()

func build_platform(platform: String):
	if not build_configs.has(platform):
		print("Error: Unknown platform: " + platform)
		return

	var config = build_configs[platform]
	print("Building for " + platform + "...")

	# Create builds directory
	var dir = DirAccess.open("res://")
	if not dir.dir_exists("builds"):
		dir.make_dir("builds")
	
	# Export the project
	var export_preset = config.preset
	var export_path = config.output
	
	# This would normally use the Godot export system
	# For now, we'll just print the command that would be run
	print("Export command: godot --headless --export-release \"%s\" --path . --output \"%s\"" % [config.platform, export_path])

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

func print_help():
	print("Idle Adventurer Build Script")
	print("Usage: godot --script build.gd <command> [platform]")
	print("")
	print("Commands:")
	print("  build [platform]  - Build for specified platform (linux, windows, macos)")
	print("  build             - Build for all platforms")
	print("  test              - Run test suite")
	print("  clean             - Clean build directory")
	print("  help              - Show this help message")
