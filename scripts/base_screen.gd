extends Control
class_name BaseScreen

## Base class for all screen UIs with common functionality
## Provides standardized navigation, character management, and UI patterns

# Character management
var character: Character
var character_manager: CharacterManager

# Common UI elements
@onready var back_button: Button

# Signals
signal screen_closed
signal character_updated(character: Character)

func _ready() -> void:
	"""Initialize the base screen with common setup"""
	setup_character_manager()
	setup_ui_references()
	connect_signals()
	on_screen_ready()

func setup_character_manager() -> void:
	"""Setup character manager and get current character"""
	character_manager = CharacterManager
	character = character_manager.get_current_character()

	if character:
		character_updated.emit(character)

func setup_ui_references() -> void:
	"""Setup common UI references - override in subclasses for specific elements"""
	back_button = %BackButton if has_node("%BackButton") else null

func connect_signals() -> void:
	"""Connect common signals - override in subclasses for additional signals"""
	if back_button:
		back_button.pressed.connect(_on_back_button_pressed)

	# Connect to character changes
	if character_manager:
		character_manager.character_changed.connect(_on_character_changed)

func on_screen_ready() -> void:
	"""Override this method in subclasses for screen-specific initialization"""
	pass

func _on_back_button_pressed() -> void:
	"""Default back button behavior - override in subclasses for custom behavior"""
	navigate_back()

func navigate_back() -> void:
	"""Navigate back to the previous screen"""
	screen_closed.emit()
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func navigate_to_scene(scene_path: String) -> void:
	"""Navigate to a specific scene"""
	screen_closed.emit()
	get_tree().change_scene_to_file(scene_path)

func _on_character_changed(new_character: Character) -> void:
	"""Handle character changes - override in subclasses for specific behavior"""
	character = new_character
	character_updated.emit(character)
	on_character_updated()

func on_character_updated() -> void:
	"""Override this method in subclasses to handle character updates"""
	pass

func show_notification(message: String, _duration: float = 3.0) -> void:
	"""Show a notification to the user"""
	print("Notification: %s" % message)
	# TODO: Implement proper notification system

func show_error(message: String) -> void:
	"""Show an error message to the user"""
	print("Error: %s" % message)
	# TODO: Implement proper error display system

func validate_character() -> bool:
	"""Validate that a character is available"""
	if character == null:
		show_error("No character available")
		return false
	return true

func get_character_summary() -> String:
	"""Get a summary of the current character"""
	if not validate_character():
		return "No character"

	return "%s (Level %d %s %s)" % [
		character.name,
		character.level,
		character.race,
		character.character_class
	]
