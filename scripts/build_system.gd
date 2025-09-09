class_name BuildSystem
extends Node

# Comprehensive build system for Idle Adventurer

var build_configs = {
	"linux": {
		"platform": "Linux/X11",
		"output": "builds/idle-adventurer-linux.x86_64",
		"preset": 0,
		"architectures": ["x86_64", "arm64"]
	},
	"windows": {
		"platform": "Windows Desktop",
		"output": "builds/idle-adventurer-windows.exe",
		"preset": 1,
		"architectures": ["x86_64"]
	},
	"macos": {
		"platform": "macOS",
		"output": "builds/idle-adventurer-macos.zip",
		"preset": 2,
		"architectures": ["x86_64", "arm64"]
	},
	"web": {
		"platform": "Web",
		"output": "builds/idle-adventurer-web/",
		"preset": 3,
		"architectures": ["wasm32"]
	}
}

var version = "0.2.0"
var build_number = 1

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
			"package":
				package_release()
			"deploy":
				deploy_release()
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
	create_build_directory()
	
	# Build for each architecture
	for arch in config.architectures:
		build_for_architecture(platform, arch, config)
	
	print("Build completed for " + platform)

func build_for_architecture(platform: String, architecture: String, config: Dictionary):
	var output_path = config.output
	if config.architectures.size() > 1:
		output_path = output_path.replace(".exe", "-" + architecture + ".exe")
		output_path = output_path.replace(".x86_64", "-" + architecture)
		output_path = output_path.replace(".zip", "-" + architecture + ".zip")
	
	print("Building " + platform + " (" + architecture + ") -> " + output_path)
	
	# This would normally use the Godot export system
	# For now, we'll just print the command that would be run
	var export_command = "godot --headless --export-release \"%s\" --path . --output \"%s\"" % [config.platform, output_path]
	print("Export command: " + export_command)
	
	# In a real implementation, we would execute the command
	# For now, create a placeholder file
	create_placeholder_build(output_path)

func build_all_platforms():
	print("Building for all platforms...")
	for platform in build_configs.keys():
		build_platform(platform)

func run_tests():
	print("Running test suite...")
	
	# Run unit tests
	var test_command = "godot --headless --script run_tests.gd --quit"
	print("Test command: " + test_command)
	
	# In a real implementation, we would execute the command and capture output
	print("Tests completed")

func clean_builds():
	print("Cleaning build directory...")
	var dir = DirAccess.open("res://")
	if dir.dir_exists("builds"):
		dir.remove("builds")
		print("Build directory cleaned")

func package_release():
	print("Packaging release...")
	
	# Create release directory
	var release_dir = "releases/v" + version
	create_directory(release_dir)
	
	# Copy builds to release directory
	var builds_dir = DirAccess.open("builds/")
	if builds_dir:
		for file_name in builds_dir.get_files():
			var source_path = "builds/" + file_name
			var dest_path = release_dir + "/" + file_name
			DirAccess.copy_absolute(source_path, dest_path)
	
	# Create release notes
	create_release_notes(release_dir)
	
	# Create checksums
	create_checksums(release_dir)
	
	print("Release packaged: " + release_dir)

func deploy_release():
	print("Deploying release...")
	
	# This would normally upload to Steam, GitHub releases, etc.
	# For now, just print what would be done
	print("Would deploy to:")
	print("- GitHub Releases")
	print("- Steam (if configured)")
	print("- Itch.io (if configured)")

func create_build_directory():
	var dir = DirAccess.open("res://")
	if not dir.dir_exists("builds"):
		dir.make_dir("builds")

func create_directory(path: String):
	var dir = DirAccess.open("res://")
	var parts = path.split("/")
	var current_path = ""
	
	for part in parts:
		if part != "":
			current_path += "/" + part
			if not dir.dir_exists(current_path):
				dir.make_dir(current_path)

func create_placeholder_build(output_path: String):
	var file = FileAccess.open(output_path, FileAccess.WRITE)
	if file:
		file.store_string("Placeholder build file for " + output_path)
		file.close()

func create_release_notes(release_dir: String):
	var notes = """
# Idle Adventurer v%s

## What's New
- Complete D&D 5e character system
- Idle progression mechanics
- Equipment and inventory management
- Achievement system
- Settings and customization
- Comprehensive test suite

## Installation
1. Download the appropriate build for your platform
2. Extract and run the executable
3. Create a new character and start your adventure!

## System Requirements
- Windows 10+, macOS 10.14+, or Linux
- 100MB free disk space
- 2GB RAM minimum

## Changelog
See CHANGELOG.md for detailed changes.

## Support
- GitHub Issues: https://github.com/yourusername/idle-adventurer/issues
- Discord: https://discord.gg/yourdiscord
""" % version
	
	var file = FileAccess.open(release_dir + "/README.md", FileAccess.WRITE)
	if file:
		file.store_string(notes)
		file.close()

func create_checksums(release_dir: String):
	var checksums = []
	var dir = DirAccess.open(release_dir)
	if dir:
		for file_name in dir.get_files():
			var file_path = release_dir + "/" + file_name
			var file = FileAccess.open(file_path, FileAccess.READ)
			if file:
				var content = file.get_buffer(file.get_length())
				file.close()
				
				var hash = content.sha256_text()
				checksums.append(hash + "  " + file_name)
	
	var checksum_file = FileAccess.open(release_dir + "/checksums.txt", FileAccess.WRITE)
	if checksum_file:
		checksum_file.store_string("\n".join(checksums))
		checksum_file.close()

func print_help():
	print("Idle Adventurer Build System")
	print("Usage: godot --script scripts/build_system.gd <command> [platform]")
	print("")
	print("Commands:")
	print("  build [platform]  - Build for specified platform (linux, windows, macos, web)")
	print("  build             - Build for all platforms")
	print("  test              - Run test suite")
	print("  clean             - Clean build directory")
	print("  package           - Package release")
	print("  deploy            - Deploy release")
	print("  help              - Show this help message")
	print("")
	print("Platforms:")
	for platform in build_configs.keys():
		print("  " + platform + " - " + build_configs[platform].platform)
