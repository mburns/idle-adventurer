# Global game events using Godot's signal system
extends Node

# Preload required classes
const Character = preload("res://scripts/core/character.gd")

# Character events
signal character_created(character: Character)
signal character_leveled_up(character: Character, new_level: int)
signal character_gained_experience(character: Character, amount: int)
signal character_gained_gold(character: Character, amount: int)
signal character_equipped_item(character: Character, item: String, slot: String)
signal character_unequipped_item(character: Character, item: String, slot: String)

# Activity events
signal activity_started(character: Character, activity: String)
signal activity_completed(character: Character, activity: String, rewards: Dictionary)
signal activity_failed(character: Character, activity: String, reason: String)

# Achievement events
signal achievement_unlocked(achievement: String)
signal achievement_progress_updated(achievement: String, progress: int, max_progress: int)

# UI events
signal screen_changed(from_screen: String, to_screen: String)
signal settings_changed(setting: String, value: Variant)
signal notification_shown(message: String, type: String)

# Game state events
signal game_paused()
signal game_resumed()
signal game_saved()
signal game_loaded()

# Combat events (for future expansion)
signal combat_started(participants: Array)
signal combat_ended(winner: String)
signal damage_dealt(attacker: String, target: String, amount: int)
signal healing_received(target: String, amount: int)

# Faction events (for future expansion)
signal faction_reputation_changed(faction: String, old_reputation: int, new_reputation: int)
signal faction_quest_completed(faction: String, quest: String)

# Magic events (for future expansion)
signal spell_cast(caster: Character, spell: String, target: String)
signal spell_learned(character: Character, spell: String)
signal magic_item_identified(item: String)

# Economy events (for future expansion)
signal item_purchased(character: Character, item: String, cost: int)
signal item_sold(character: Character, item: String, price: int)
signal shop_opened(shop_type: String)
signal shop_closed(shop_type: String)

# Time events
signal day_passed()
signal week_passed()
signal month_passed()
signal season_changed(season: String)

# Debug events
signal debug_message(message: String, level: String)
signal performance_warning(metric: String, value: float)

# Initialize the event system
func _ready():
    # Connect to autoload manager if it exists
    var autoload_manager = null
    if Engine.has_singleton("AutoloadManager"):
        autoload_manager = Engine.get_singleton("AutoloadManager")

    if autoload_manager:
        # Connect relevant signals
        pass

# Helper functions for common event patterns
func emit_character_progression(character: Character, old_level: int, new_level: int):
    if new_level > old_level:
        character_leveled_up.emit(character, new_level)

func emit_activity_result(character: Character, activity: String, success: bool, rewards: Dictionary = {}):
    if success:
        activity_completed.emit(character, activity, rewards)
    else:
        activity_failed.emit(character, activity, "Unknown error")

func emit_ui_feedback(message: String, type: String = "info"):
    notification_shown.emit(message, type)
