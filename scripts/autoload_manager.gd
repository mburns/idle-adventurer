# Autoload manager for global game state
extends Node

# Global game managers
var character_manager: CharacterManager
var settings_manager: SettingsManager
var achievement_manager: AchievementManager
var sound_manager: SoundManager

# Game state
var current_scene: String = ""
var game_time: float = 0.0
var is_paused: bool = false

func _ready():
    # Initialize global managers
    character_manager = CharacterManager.new()
    settings_manager = SettingsManager.new()
    achievement_manager = AchievementManager.new()
    sound_manager = SoundManager.new()

    # Add as children
    add_child(character_manager)
    add_child(settings_manager)
    add_child(achievement_manager)
    add_child(sound_manager)

    # Connect signals
    character_manager.character_changed.connect(_on_character_changed)
    settings_manager.settings_changed.connect(_on_settings_changed)

    # Load settings
    settings_manager.load_settings()

func _process(delta):
    if not is_paused:
        game_time += delta

func _on_character_changed(character: Character):
    # Notify all systems of character changes
    achievement_manager.check_achievements(character)

func _on_settings_changed():
    # Apply settings changes globally
    sound_manager.apply_settings(settings_manager.get_settings())

func pause_game():
    is_paused = true
    get_tree().paused = true

func resume_game():
    is_paused = false
    get_tree().paused = false

func get_game_time() -> float:
    return game_time
