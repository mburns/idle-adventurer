extends Control

# Leveling UI for character progression with class feature choices

class_name LevelingUI

signal level_up_completed(character: Character, new_level: int)
signal feature_selected(character: Character, feature: Dictionary)

var character: Character
var leveling_system: LevelingSystem
var current_level_up_data: Dictionary = {}

func _ready():
    # Apply theme
    ThemeManager.apply_theme_to_children(self)

    # Initialize systems
    leveling_system = LevelingSystem.new()
    add_child(leveling_system)

    # Connect to leveling signals
    leveling_system.level_up_completed.connect(_on_level_up_completed)

    # Setup UI
    setup_leveling_ui()

func setup_leveling_ui():
    """Setup the leveling UI components"""
    # This would be called when the leveling screen is opened
    pass

func show_level_up_options(character: Character, new_level: int):
    """Show level up options for a character"""
    self.character = character
    current_level_up_data = get_level_up_data(character, new_level)

    # Show the leveling dialog
    show_leveling_dialog()

func get_level_up_data(character: Character, new_level: int) -> Dictionary:
    """Get all available level up options for a character"""
    var class_type = character.character_class
    var level_data = {
        "new_level": new_level,
        "hit_point_increase": calculate_hit_point_increase(character, new_level),
        "ability_score_improvements": get_ability_score_improvements(character, new_level),
        "class_features": get_class_features(character, new_level),
        "spell_slots": get_spell_slot_increases(character, new_level),
        "proficiency_bonus": leveling_system.get_proficiency_bonus(new_level)
    }

    return level_data

func calculate_hit_point_increase(character: Character, new_level: int) -> int:
    """Calculate hit point increase for the new level"""
    var hit_die = get_class_hit_die(character.character_class)
    var constitution_modifier = character.get_constitution_modifier()

    # Roll hit die + constitution modifier
    var roll = randi() % hit_die + 1
    return roll + constitution_modifier

func get_class_hit_die(class_type: String) -> int:
    """Get hit die for a class"""
    match class_type.to_lower():
        "fighter", "paladin", "ranger":
            return 10
        "barbarian":
            return 12
        "wizard", "sorcerer":
            return 6
        "cleric", "druid", "monk", "rogue":
            return 8
        "bard", "warlock":
            return 8
        _:
            return 8

func get_ability_score_improvements(character: Character, new_level: int) -> Array:
    """Get ability score improvements available at this level"""
    var improvements = []

    # Check if this level grants ability score improvements
    if should_grant_ability_score_improvement(character.character_class, new_level):
        improvements.append({
            "type": "ability_score_improvement",
            "description": "Increase one ability score by 2 or two ability scores by 1",
            "choices": get_ability_score_choices()
        })

    return improvements

func should_grant_ability_score_improvement(class_type: String, level: int) -> bool:
    """Check if this level grants ability score improvements"""
    # Most classes get ASI at levels 4, 8, 12, 16, 19
    var asi_levels = [4, 8, 12, 16, 19]
    return level in asi_levels

func get_ability_score_choices() -> Array:
    """Get ability score improvement choices"""
    return [
        {"ability": "strength", "increase": 2},
        {"ability": "dexterity", "increase": 2},
        {"ability": "constitution", "increase": 2},
        {"ability": "intelligence", "increase": 2},
        {"ability": "wisdom", "increase": 2},
        {"ability": "charisma", "increase": 2},
        {"ability": "two_abilities", "increase": 1}
    ]

func get_class_features(character: Character, new_level: int) -> Array:
    """Get class features available at this level"""
    var class_type = character.character_class
    var features = []

    # Get features using Resource manager
    var class_resource = AutoloadManager.get_class_manager().get_class_resource(class_type)
    var class_data = {}
    if class_resource:
        class_data = {"features": class_resource.features}

    var class_features = class_data.get("features", {})

    # Check for features at this level
    for feature_name in class_features.keys():
        var feature_data = class_features[feature_name]
        var feature_level = feature_data.get("level", 1)

        if feature_level == new_level:
            features.append({
                "name": feature_name,
                "description": feature_data.get("description", ""),
                "type": feature_data.get("type", "feature"),
                "choices": feature_data.get("choices", [])
            })

    return features

func get_spell_slot_increases(character: Character, new_level: int) -> Dictionary:
    """Get spell slot increases for this level"""
    var class_type = character.character_class
    var spellcasting_classes = ["wizard", "sorcerer", "cleric", "druid", "bard", "warlock"]

    if class_type.to_lower() in spellcasting_classes:
        return calculate_spell_slot_progression(class_type, new_level)

    return {}

func calculate_spell_slot_progression(class_type: String, new_level: int) -> Dictionary:
    """Calculate spell slot progression for a class"""
    # This would use the standard D&D spell slot progression
    var spell_slots = {}

    # Level 1-20 spell slot progression
    var progression = {
        1: {"1st": 2},
        2: {"1st": 3},
        3: {"1st": 4, "2nd": 2},
        4: {"1st": 4, "2nd": 3},
        5: {"1st": 4, "2nd": 3, "3rd": 2},
        6: {"1st": 4, "2nd": 3, "3rd": 3},
        7: {"1st": 4, "2nd": 3, "3rd": 3, "4th": 1},
        8: {"1st": 4, "2nd": 3, "3rd": 3, "4th": 2},
        9: {"1st": 4, "2nd": 3, "3rd": 3, "4th": 3, "5th": 1},
        10: {"1st": 4, "2nd": 3, "3rd": 3, "4th": 3, "5th": 2},
        11: {"1st": 4, "2nd": 3, "3rd": 3, "4th": 3, "5th": 2, "6th": 1},
        12: {"1st": 4, "2nd": 3, "3rd": 3, "4th": 3, "5th": 2, "6th": 1},
        13: {"1st": 4, "2nd": 3, "3rd": 3, "4th": 3, "5th": 2, "6th": 1, "7th": 1},
        14: {"1st": 4, "2nd": 3, "3rd": 3, "4th": 3, "5th": 2, "6th": 1, "7th": 1},
        15: {"1st": 4, "2nd": 3, "3rd": 3, "4th": 3, "5th": 2, "6th": 1, "7th": 1, "8th": 1},
        16: {"1st": 4, "2nd": 3, "3rd": 3, "4th": 3, "5th": 2, "6th": 1, "7th": 1, "8th": 1},
        17: {"1st": 4, "2nd": 3, "3rd": 3, "4th": 3, "5th": 2, "6th": 1, "7th": 1, "8th": 1, "9th": 1},
        18: {"1st": 4, "2nd": 3, "3rd": 3, "4th": 3, "5th": 2, "6th": 1, "7th": 1, "8th": 1, "9th": 1},
        19: {"1st": 4, "2nd": 3, "3rd": 3, "4th": 3, "5th": 2, "6th": 1, "7th": 1, "8th": 1, "9th": 1},
        20: {"1st": 4, "2nd": 3, "3rd": 3, "4th": 3, "5th": 2, "6th": 1, "7th": 1, "8th": 1, "9th": 1}
    }

    return progression.get(new_level, {})

func show_leveling_dialog():
    """Show the leveling dialog with choices"""
    # Create leveling dialog
    var dialog = AcceptDialog.new()
    dialog.title = "Level Up! - Level " + str(current_level_up_data["new_level"])
    dialog.size = Vector2(800, 600)

    var container = VBoxContainer.new()
    container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

    # Level info
    var level_info = Label.new()
    level_info.text = "Congratulations! " + character.name + " has reached level " + str(current_level_up_data["new_level"]) + "!"
    level_info.add_theme_font_size_override("font_size", 18)
    container.add_child(level_info)

    container.add_child(HSeparator.new())

    # Hit point increase
    var hp_section = create_hit_point_section()
    container.add_child(hp_section)

    # Ability score improvements
    var asi_improvements = current_level_up_data.get("ability_score_improvements", [])
    if not asi_improvements.is_empty():
        var asi_section = create_ability_score_section(asi_improvements[0])
        container.add_child(asi_section)

    # Class features
    var class_features = current_level_up_data.get("class_features", [])
    if not class_features.is_empty():
        var features_section = create_class_features_section(class_features)
        container.add_child(features_section)

    # Spell slots
    var spell_slots = current_level_up_data.get("spell_slots", {})
    if not spell_slots.is_empty():
        var spells_section = create_spell_slots_section(spell_slots)
        container.add_child(spells_section)

    dialog.add_child(container)
    add_child(dialog)

    # Connect dialog signals
    dialog.confirmed.connect(func(): apply_level_up_choices())
    dialog.popup_centered()

func create_hit_point_section() -> VBoxContainer:
    """Create hit point increase section"""
    var section = VBoxContainer.new()

    var title = Label.new()
    title.text = "Hit Point Increase"
    title.add_theme_font_size_override("font_size", 16)
    section.add_child(title)

    var hp_increase = current_level_up_data.get("hit_point_increase", 0)
    var hp_label = Label.new()
    hp_label.text = "Rolled: " + str(hp_increase) + " hit points"
    section.add_child(hp_label)

    return section

func create_ability_score_section(asi_data: Dictionary) -> VBoxContainer:
    """Create ability score improvement section"""
    var section = VBoxContainer.new()

    var title = Label.new()
    title.text = "Ability Score Improvement"
    title.add_theme_font_size_override("font_size", 16)
    section.add_child(title)

    var description = Label.new()
    description.text = asi_data.get("description", "")
    section.add_child(description)

    # Create choice buttons
    var choices_container = HBoxContainer.new()
    for choice in asi_data.get("choices", []):
        var button = Button.new()
        button.text = choice["ability"].capitalize() + " +" + str(choice["increase"])
        button.pressed.connect(func(): select_ability_score_improvement(choice))
        choices_container.add_child(button)

    section.add_child(choices_container)
    return section

func create_class_features_section(features: Array) -> VBoxContainer:
    """Create class features section"""
    var section = VBoxContainer.new()

    var title = Label.new()
    title.text = "New Class Features"
    title.add_theme_font_size_override("font_size", 16)
    section.add_child(title)

    for feature in features:
        var feature_label = Label.new()
        feature_label.text = "• " + feature.get("name", "") + ": " + feature.get("description", "")
        feature_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        section.add_child(feature_label)

    return section

func create_spell_slots_section(spell_slots: Dictionary) -> VBoxContainer:
    """Create spell slots section"""
    var section = VBoxContainer.new()

    var title = Label.new()
    title.text = "New Spell Slots"
    title.add_theme_font_size_override("font_size", 16)
    section.add_child(title)

    var slots_text = ""
    for level in spell_slots.keys():
        var count = spell_slots[level]
        slots_text += level + " level: " + str(count) + " slots  "

    var slots_label = Label.new()
    slots_label.text = slots_text
    section.add_child(slots_label)

    return section

func select_ability_score_improvement(choice: Dictionary):
    """Handle ability score improvement selection"""
    var ability = choice.get("ability", "")
    var increase = choice.get("increase", 1)

    if ability == "two_abilities":
        # Handle two ability improvement
        show_two_ability_selection()
    else:
        # Single ability improvement
        character.set(ability, character.get(ability) + increase)
        print(character.name + " increased " + ability + " by " + str(increase))

func show_two_ability_selection():
    """Show selection for two ability improvements"""
    # This would show a dialog to select two different abilities
    print("Two ability selection not yet implemented")

func apply_level_up_choices():
    """Apply all level up choices to the character"""
    # Apply hit point increase
    var hp_increase = current_level_up_data.get("hit_point_increase", 0)
    character.max_hit_points += hp_increase
    character.hit_points += hp_increase

    # Apply spell slot increases
    var spell_slots = current_level_up_data.get("spell_slots", {})
    if not spell_slots.is_empty():
        character.spell_slots = spell_slots

    # Update character level
    character.level = current_level_up_data["new_level"]

    # Emit completion signal
    level_up_completed.emit(character, character.level)

    print(character.name + " has reached level " + str(character.level) + "!")

func _on_level_up_completed(character: Character, new_level: int):
    """Handle level up completion"""
    show_level_up_options(character, new_level)
