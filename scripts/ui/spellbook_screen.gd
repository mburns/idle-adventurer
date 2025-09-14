extends Control

# Spellbook screen for viewing known spells and learning new ones

var character: Character
var all_spells: Dictionary = {}
var filtered_spells: Dictionary = {}

func _ready():
    # Apply theme
    ThemeManager.apply_theme_to_children(self)

    # Get current character
    character = CharacterManager.current_character

    # Load all spells from wiki
    load_spells_from_wiki()

    # Setup filter dropdown
    setup_filter_dropdown()

    # Display spells
    display_spells()

func load_spells_from_wiki():
    """Load all spells from the wiki directory"""
    # Note: Spell loading from wiki not implemented in DataLoader yet
    all_spells = {}
    print("⚠️  Spell loading from wiki not implemented in DataLoader yet")

func setup_filter_dropdown():
    """Setup the spell level filter dropdown"""
    var filter_dropdown = %FilterDropdown
    filter_dropdown.clear()

    filter_dropdown.add_item("All Levels")
    for level in range(10): # Spell levels 0-9
        if level == 0:
            filter_dropdown.add_item("Cantrips (Level 0)")
        else:
            filter_dropdown.add_item("Level " + str(level))

func display_spells():
    """Display spells in the spell container"""
    var spell_container = %SpellContainer

    # Clear existing spell buttons
    for child in spell_container.get_children():
        child.queue_free()

    # Get spells to display based on filter
    var spells_to_show = get_filtered_spells()

    if spells_to_show.is_empty():
        var no_spells_label = Label.new()
        no_spells_label.text = "No spells found matching the current filter."
        no_spells_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        spell_container.add_child(no_spells_label)
        return

    # Create spell buttons
    for spell_name in spells_to_show.keys():
        var spell_data = spells_to_show[spell_name]
        var spell_button = create_spell_button(spell_name, spell_data)
        spell_container.add_child(spell_button)

func get_filtered_spells() -> Dictionary:
    """Get spells based on current filter"""
    var filter_dropdown = %FilterDropdown
    var selected_index = filter_dropdown.selected

    if selected_index == 0: # All levels
        return all_spells

    var target_level = selected_index - 1 # Adjust for "All Levels" option
    var filtered = {}

    for spell_name in all_spells.keys():
        var spell_data = all_spells[spell_name]
        if spell_data.get("level", 0) == target_level:
            filtered[spell_name] = spell_data

    return filtered

func create_spell_button(spell_name: String, spell_data: Dictionary) -> Button:
    """Create a button for a spell"""
    var button = Button.new()
    button.custom_minimum_size = Vector2(0, 60)
    button.alignment = HORIZONTAL_ALIGNMENT_LEFT

    # Create spell info container
    var container = HBoxContainer.new()
    container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

    # Spell level indicator
    var level_label = Label.new()
    var level = spell_data.get("level", 0)
    if level == 0:
        level_label.text = "C" # Cantrip
        level_label.add_theme_color_override("font_color", Color.CYAN)
    else:
        level_label.text = str(level)
        level_label.add_theme_color_override("font_color", get_spell_level_color(level))

    level_label.custom_minimum_size = Vector2(30, 0)
    level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    level_label.add_theme_font_size_override("font_size", 18)
    container.add_child(level_label)

    # Spell info
    var info_container = VBoxContainer.new()
    info_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL

    # Spell name
    var name_label = Label.new()
    name_label.text = spell_name
    name_label.add_theme_font_size_override("font_size", 16)

    # Check if character knows this spell
    var is_known = character and spell_name in character.known_spells
    if is_known:
        name_label.add_theme_color_override("font_color", Color.GREEN)

    info_container.add_child(name_label)

    # Spell school and casting time
    var details_label = Label.new()
    var school = spell_data.get("school", "evocation")
    var casting_time = spell_data.get("casting_time", "1 action")
    details_label.text = school.capitalize() + " • " + casting_time
    details_label.add_theme_font_size_override("font_size", 12)
    details_label.add_theme_color_override("font_color", Color.GRAY)
    info_container.add_child(details_label)

    container.add_child(info_container)

    # Learn/Forget button
    var action_button = Button.new()
    action_button.custom_minimum_size = Vector2(80, 0)

    if is_known:
        action_button.text = "Forget"
        action_button.add_theme_color_override("font_color", Color.RED)
        action_button.pressed.connect(func(): forget_spell(spell_name))
    else:
        action_button.text = "Learn"
        action_button.add_theme_color_override("font_color", Color.GREEN)
        action_button.pressed.connect(func(): learn_spell(spell_name, spell_data))

    container.add_child(action_button)

    button.add_child(container)

    # Connect to show spell details
    button.pressed.connect(func(): show_spell_details(spell_name, spell_data))

    return button

func get_spell_level_color(level: int) -> Color:
    """Get color for spell level"""
    match level:
        1: return Color.WHITE
        2: return Color.YELLOW
        3: return Color.ORANGE
        4: return Color.MAGENTA
        5: return Color.RED
        6: return Color.PURPLE
        7: return Color.BLUE
        8: return Color.DARK_BLUE
        9: return Color.GOLD
        _: return Color.WHITE

func learn_spell(spell_name: String, spell_data: Dictionary):
    """Learn a new spell"""
    if not character:
        print("No character loaded")
        return

    # Check if character can learn this spell (class restrictions, etc.)
    if can_character_learn_spell(spell_name, spell_data):
        character.learn_spell(spell_name, spell_data)
        print("Learned spell: " + spell_name)
        display_spells() # Refresh display
    else:
        print("Character cannot learn this spell")

func forget_spell(spell_name: String):
    """Forget a known spell"""
    if not character:
        print("No character loaded")
        return

    character.forget_spell(spell_name)
    print("Forgot spell: " + spell_name)
    display_spells() # Refresh display

func can_character_learn_spell(spell_name: String, spell_data: Dictionary) -> bool:
    """Check if character can learn this spell"""
    if not character:
        return false

    # For now, allow learning any spell
    # In a full implementation, this would check:
    # - Class spell list restrictions
    # - Character level vs spell level
    # - Available spell slots
    # - Prerequisites

    return true

func show_spell_details(spell_name: String, spell_data: Dictionary):
    """Show detailed information about a spell"""
    var dialog = AcceptDialog.new()
    dialog.title = spell_name

    var content = VBoxContainer.new()

    # Spell level and school
    var level_school = Label.new()
    var level = spell_data.get("level", 0)
    var level_text = "Cantrip" if level == 0 else "Level " + str(level)
    level_school.text = level_text + " " + spell_data.get("school", "evocation").capitalize()
    level_school.add_theme_font_size_override("font_size", 14)
    content.add_child(level_school)

    # Casting details
    var casting_details = Label.new()
    casting_details.text = "Casting Time: " + spell_data.get("casting_time", "1 action") + "\n"
    casting_details.text += "Range: " + spell_data.get("range", "60 feet") + "\n"
    casting_details.text += "Components: " + spell_data.get("components", "V, S") + "\n"
    casting_details.text += "Duration: " + spell_data.get("duration", "instantaneous")
    casting_details.add_theme_font_size_override("font_size", 12)
    content.add_child(casting_details)

    # Description
    var description = RichTextLabel.new()
    description.text = spell_data.get("description", "No description available.")
    description.custom_minimum_size = Vector2(400, 200)
    description.fit_content = true
    content.add_child(description)

    dialog.add_child(content)
    add_child(dialog)
    dialog.popup_centered()

func _on_filter_selected(index: int):
    """Handle filter dropdown selection"""
    display_spells()

func _on_back_button_pressed():
    """Return to main screen"""
    get_tree().change_scene_to_file("res://scenes/main.tscn")
