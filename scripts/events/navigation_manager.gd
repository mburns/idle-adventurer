extends Node
class_name NavigationManager

## Centralized navigation management for scene transitions
## Provides consistent navigation patterns and history tracking

# Scene paths
const SCENES = {
	"main": "res://scenes/main.tscn",
	"start": "res://scenes/start_screen.tscn",
	"character_creation": "res://scenes/character_creation.tscn",
	"character_selection": "res://scenes/character_selection.tscn",
	"character_display": "res://scenes/character_display.tscn",
	"character_sheet": "res://scenes/character_sheet.tscn",
	"character_profile": "res://scenes/character_profile.tscn",
	# Activities are now integrated into main screen
	"equipment": "res://scenes/equipment_screen.tscn",
	"inventory": "res://scenes/inventory_screen.tscn",
	"spellbook": "res://scenes/spellbook_screen.tscn",
	"leveling": "res://scenes/leveling_screen.tscn",
	"faction": "res://scenes/faction_screen.tscn",
	"achievements": "res://scenes/achievements_screen.tscn",
	"monster_glossary": "res://scenes/monster_glossary_screen.tscn",
	"general_store": "res://scenes/general_store_screen.tscn",
	"journal": "res://scenes/journal_screen.tscn",
	"settings": "res://scenes/settings_screen.tscn"
}

# Navigation history
var navigation_history: Array[String] = []
var max_history_size: int = 10

# Signals
signal scene_changed(from_scene: String, to_scene: String)
signal navigation_history_updated(history: Array[String])

func _ready() -> void:
	"""Initialize navigation manager"""
	# Add current scene to history
	var current_scene = get_current_scene_name()
	if current_scene != "":
		navigation_history.append(current_scene)

func get_current_scene_name() -> String:
	"""Get the name of the current scene"""
	var current_scene = get_tree().current_scene
	if current_scene:
		return current_scene.scene_file_path.get_file().get_basename()
	return ""

func navigate_to(scene_key: String, should_add_to_history: bool = true) -> bool:
	"""Navigate to a scene by key"""
	if not SCENES.has(scene_key):
		push_error("Unknown scene key: %s" % scene_key)
		return false

	var scene_path = SCENES[scene_key]
	return navigate_to_path(scene_path, should_add_to_history)

func navigate_to_path(scene_path: String, should_add_to_history: bool = true) -> bool:
	"""Navigate to a scene by path"""
	var from_scene = get_current_scene_name()

	# Add to history if requested
	if should_add_to_history and from_scene != "":
		add_to_history(from_scene)

	# Change scene
	var result = get_tree().change_scene_to_file(scene_path)

	if result == OK:
		scene_changed.emit(from_scene, scene_path.get_file().get_basename())
		return true
	else:
		push_error("Failed to change scene to: %s" % scene_path)
		return false

func navigate_back() -> bool:
	"""Navigate back to the previous scene in history"""
	if navigation_history.size() < 2:
		# No history, go to main
		return navigate_to("main", false)

	# Remove current scene from history
	navigation_history.pop_back()

	# Get previous scene
	var previous_scene = navigation_history[-1]
	return navigate_to_path(SCENES.get(previous_scene, SCENES["main"]), false)

func navigate_to_main() -> bool:
	"""Navigate to main screen"""
	return navigate_to("main")

func navigate_to_start() -> bool:
	"""Navigate to start screen"""
	return navigate_to("start")

func add_to_history(scene_name: String) -> void:
	"""Add a scene to navigation history"""
	# Don't add duplicates
	if navigation_history.size() > 0 and navigation_history[-1] == scene_name:
		return

	navigation_history.append(scene_name)

	# Limit history size
	if navigation_history.size() > max_history_size:
		navigation_history.pop_front()

	navigation_history_updated.emit(navigation_history)

func clear_history() -> void:
	"""Clear navigation history"""
	navigation_history.clear()
	navigation_history_updated.emit(navigation_history)

func get_history() -> Array[String]:
	"""Get navigation history"""
	return navigation_history.duplicate()

func can_go_back() -> bool:
	"""Check if we can go back"""
	return navigation_history.size() > 1

func get_previous_scene() -> String:
	"""Get the previous scene name"""
	if navigation_history.size() < 2:
		return ""
	return navigation_history[-2]

func get_scene_path(scene_key: String) -> String:
	"""Get the path for a scene key"""
	return SCENES.get(scene_key, "")

func get_available_scenes() -> Array[String]:
	"""Get all available scene keys"""
	return SCENES.keys()

# Convenience methods for common navigation patterns
func go_to_character_creation() -> bool:
	"""Go to character creation screen"""
	return navigate_to("character_creation")

func go_to_character_selection() -> bool:
	"""Go to character selection screen"""
	return navigate_to("character_selection")

func go_to_character_display() -> bool:
	"""Go to character display screen"""
	return navigate_to("character_display")

func go_to_character_sheet() -> bool:
	"""Go to character sheet screen"""
	return navigate_to("character_sheet")

# Activities are now integrated into main screen - no separate screen needed

func go_to_equipment() -> bool:
	"""Go to equipment screen"""
	return navigate_to("equipment")

func go_to_inventory() -> bool:
	"""Go to inventory screen"""
	return navigate_to("inventory")

func go_to_spellbook() -> bool:
	"""Go to spellbook screen"""
	return navigate_to("spellbook")

func go_to_leveling() -> bool:
	"""Go to leveling screen"""
	return navigate_to("leveling")

func go_to_faction() -> bool:
	"""Go to faction screen"""
	return navigate_to("faction")

func go_to_achievements() -> bool:
	"""Go to achievements screen"""
	return navigate_to("achievements")

func go_to_settings() -> bool:
	"""Go to settings screen"""
	return navigate_to("settings")
