extends Control

# Leveling screen for character progression

var character: Character
var leveling_system: LevelingSystem
var leveling_ui: LevelingUI

func _ready():
    # Apply theme
    ThemeManager.apply_theme_to_children(self)

    # Get current character
    character = CharacterManager.current_character

    # Initialize systems
    leveling_system = LevelingSystem.new()
    leveling_ui = LevelingUI.new()
    add_child(leveling_system)
    add_child(leveling_ui)

    # Connect to signals
    leveling_system.level_up_completed.connect(_on_level_up_completed)
    leveling_ui.level_up_completed.connect(_on_level_up_ui_completed)

    # Setup UI
    setup_character_info()
    update_experience_display()
    update_class_features()
    update_spell_slots()

func setup_character_info():
    """Setup character information display"""
    %CharacterName.text = character.name
    %CharacterLevel.text = "Level " + str(character.level)
    %CharacterClass.text = character.character_class.capitalize()

func update_experience_display():
    """Update experience points display"""
    var current_xp = character.experience_points
    var current_level = character.level
    var next_level = current_level + 1

    if next_level > 20:
        # Max level reached
        %ExperienceBar.value = 100.0
        %ExperienceText.text = "Max Level Reached!"
        %LevelUpButton.disabled = true
        return

    var xp_for_current = leveling_system.get_experience_for_level(current_level)
    var xp_for_next = leveling_system.get_experience_for_level(next_level)
    var xp_needed = xp_for_next - xp_for_current
    var xp_progress = current_xp - xp_for_current

    var progress_percent = 0.0
    if xp_needed > 0:
        progress_percent = (float(xp_progress) / float(xp_needed)) * 100.0
    %ExperienceBar.value = progress_percent
    %ExperienceText.text = str(xp_progress) + " / " + str(xp_needed) + " XP"

    # Enable level up button if enough XP
    %LevelUpButton.disabled = not leveling_system.can_level_up(character)

func update_class_features():
    """Update class features display"""
    var features_container = %ClassFeaturesList

    # Clear existing features
    for child in features_container.get_children():
        child.queue_free()

    # Get class features for current level
    var class_data = DataLoader.get_class_data(character.character_class)
    var all_features = class_data.get("features", {})

    # Show features up to current level
    for feature_name in all_features.keys():
        var feature_data = all_features[feature_name]
        var feature_level = feature_data.get("level", 1)

        if feature_level <= character.level:
            var feature_label = Label.new()
            feature_label.text = "Level " + str(feature_level) + ": " + feature_name
            feature_label.add_theme_font_size_override("font_size", 14)
            features_container.add_child(feature_label)

            var description_label = Label.new()
            description_label.text = "  " + feature_data.get("description", "")
            description_label.add_theme_font_size_override("font_size", 12)
            description_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
            description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
            features_container.add_child(description_label)

func update_spell_slots():
    """Update spell slots display"""
    var slots_container = %SpellSlotsList

    # Clear existing slots
    for child in slots_container.get_children():
        child.queue_free()

    # Check if character is a spellcaster
    var spellcasting_classes = ["wizard", "sorcerer", "cleric", "druid", "bard", "warlock"]
    if not character.character_class.to_lower() in spellcasting_classes:
        var no_spells_label = Label.new()
        no_spells_label.text = "Not a spellcasting class"
        no_spells_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
        slots_container.add_child(no_spells_label)
        return

    # Display spell slots
    var spell_slots = character.spell_slots
    if spell_slots.is_empty():
        # Calculate spell slots for current level
        spell_slots = leveling_system.calculate_spell_slots(character.character_class, character.level)

    for level in spell_slots.keys():
        var count = spell_slots[level]
        if count > 0:
            var slot_label = Label.new()
            slot_label.text = level + ": " + str(count)
            slot_label.add_theme_font_size_override("font_size", 14)
            slot_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
            slot_label.custom_minimum_size = Vector2(80, 30)
            slots_container.add_child(slot_label)

func _on_level_up_button_pressed():
    """Handle level up button press"""
    if leveling_system.can_level_up(character):
        leveling_ui.show_level_up_options(character, character.level + 1)

func _on_level_up_completed(character: Character, new_level: int):
    """Handle level up completion from leveling system"""
    # Update displays
    setup_character_info()
    update_experience_display()
    update_class_features()
    update_spell_slots()

    print(character.name + " reached level " + str(new_level) + "!")

func _on_level_up_ui_completed(_character: Character, _new_level: int):
    """Handle level up completion from leveling UI"""
    # Update displays
    setup_character_info()
    update_experience_display()
    update_class_features()
    update_spell_slots()

func _on_back_button_pressed():
    """Return to main screen"""
    get_tree().change_scene_to_file("res://scenes/main.tscn")
