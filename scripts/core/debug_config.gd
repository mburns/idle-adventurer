# Debug configuration for Idle Adventurer
# This file controls debug output throughout the application

extends Node

# Singleton instance
static var instance: Node

# Debug flags
var debug_enabled: bool = false
var debug_character: bool = false
var debug_activities: bool = false
var debug_ui: bool = false
var debug_loading: bool = false

# Initialize debug settings
func _ready():
	instance = self

	# Check for debug flag in command line arguments
	var args = OS.get_cmdline_args()
	for arg in args:
		if arg == "--debug" or arg == "-d":
			debug_enabled = true
			break

	# Check for debug environment variable
	if OS.get_environment("IDLE_ADVENTURER_DEBUG") == "true":
		debug_enabled = true

	# Enable specific debug categories if general debug is enabled
	if debug_enabled:
		debug_character = true
		debug_activities = true
		debug_ui = true
		debug_loading = true

# Static debug print functions
static func debug_print(message: String, category: String = "general"):
	if not instance or not instance.debug_enabled:
		return

	match category:
		"character":
			if instance.debug_character:
				print("DEBUG [CHARACTER]: ", message)
		"activities":
			if instance.debug_activities:
				print("DEBUG [ACTIVITIES]: ", message)
		"ui":
			if instance.debug_ui:
				print("DEBUG [UI]: ", message)
		"loading":
			if instance.debug_loading:
				print("DEBUG [LOADING]: ", message)
		_:
			print("DEBUG: ", message)

# Static convenience functions for common debug categories
static func debug_character_msg(message: String):
	debug_print(message, "character")

static func debug_activities_msg(message: String):
	debug_print(message, "activities")

static func debug_ui_msg(message: String):
	debug_print(message, "ui")

static func debug_loading_msg(message: String):
	debug_print(message, "loading")

# Enable/disable debug categories at runtime
static func set_debug_enabled(enabled: bool):
	if instance:
		instance.debug_enabled = enabled

static func set_debug_character(enabled: bool):
	if instance:
		instance.debug_character = enabled

static func set_debug_activities(enabled: bool):
	if instance:
		instance.debug_activities = enabled

static func set_debug_ui(enabled: bool):
	if instance:
		instance.debug_ui = enabled

static func set_debug_loading(enabled: bool):
	if instance:
		instance.debug_loading = enabled
