# Autoload manager for global game state
extends Node

# Global game managers
var inventory_system: InventorySystem
# TODO: Implement these managers
# var settings_manager: SettingsManager
# var achievement_manager: AchievementManager
# var sound_manager: SoundManager

# Game state
var current_scene: String = ""
var game_time: float = 0.0
var is_paused: bool = false

func _ready():
    # Initialize global managers
    inventory_system = InventorySystem.new()
    # TODO: Initialize these managers when implemented
    # settings_manager = SettingsManager.new()
    # achievement_manager = AchievementManager.new()
    # sound_manager = SoundManager.new()

    # Add as children
    add_child(inventory_system)
    # TODO: Add these managers when implemented
    # add_child(settings_manager)
    # add_child(achievement_manager)
    # add_child(sound_manager)

    # Connect signals
    CharacterManager.character_changed.connect(_on_character_changed)
    # TODO: Connect these signals when managers are implemented
    # settings_manager.settings_changed.connect(_on_settings_changed)

    # TODO: Load settings when manager is implemented
    # settings_manager.load_settings()

func _process(delta):
    if not is_paused:
        game_time += delta

func _on_character_changed(_character: Character):
    # Notify all systems of character changes
    # TODO: Implement achievement checking when manager is available
    # achievement_manager.check_achievements(character)
    pass

func _on_settings_changed():
    # Apply settings changes globally
    # TODO: Implement settings application when managers are available
    # sound_manager.apply_settings(settings_manager.get_settings())
    pass

func pause_game():
    is_paused = true
    get_tree().paused = true

func resume_game():
    is_paused = false
    get_tree().paused = false

func get_game_time() -> float:
    return game_time
