extends Control

# Monster glossary screen for browsing D&D monsters

var monster_glossary: MonsterGlossary
var selected_monster: String = ""
var monster_buttons: Dictionary = {} # monster_name -> button reference

func _ready():
    # Apply theme
    ThemeManager.apply_theme_to_children(self)

    # Initialize monster glossary
    monster_glossary = MonsterGlossary.new()
    add_child(monster_glossary)

    # Connect to glossary signals
    monster_glossary.monster_loaded.connect(_on_monster_loaded)
    monster_glossary.glossary_updated.connect(_on_glossary_updated)

    # Setup UI
    setup_filters()
    display_monsters()

func setup_filters():
    """Setup filter dropdowns"""
    setup_type_filter()
    setup_cr_filter()
    setup_size_filter()

func setup_type_filter():
    """Setup monster type filter"""
    var type_filter = %TypeFilter
    type_filter.clear()

    type_filter.add_item("All Types")
    var types = monster_glossary.get_monster_types()
    types.sort()

    for type_name in types:
        type_filter.add_item(type_name.capitalize())

func setup_cr_filter():
    """Setup challenge rating filter"""
    var cr_filter = %CRFilter
    cr_filter.clear()

    cr_filter.add_item("All CRs")
    var crs = monster_glossary.get_challenge_ratings()

    for cr in crs:
        cr_filter.add_item("CR " + cr)

func setup_size_filter():
    """Setup size filter"""
    var size_filter = %SizeFilter
    size_filter.clear()

    size_filter.add_item("All Sizes")
    var sizes = ["Tiny", "Small", "Medium", "Large", "Huge", "Gargantuan"]

    for size in sizes:
        size_filter.add_item(size)

func display_monsters():
    """Display filtered monsters"""
    var monster_list_container = %MonsterListContainer

    # Clear existing monsters
    for child in monster_list_container.get_children():
        child.queue_free()
    monster_buttons.clear()

    # Get filtered monsters
    var monsters = get_filtered_monsters()

    if monsters.is_empty():
        var no_monsters_label = Label.new()
        no_monsters_label.text = "No monsters found matching your filters."
        no_monsters_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        no_monsters_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        monster_list_container.add_child(no_monsters_label)
        return

    # Create monster buttons
    for monster_name in monsters:
        var monster_button = create_monster_button(monster_name)
        monster_list_container.add_child(monster_button)
        monster_buttons[monster_name] = monster_button

func create_monster_button(monster_name: String) -> Button:
    """Create a button for a monster"""
    var button = Button.new()
    button.custom_minimum_size = Vector2(200, 60)
    button.toggle_mode = true
    button.button_group = ButtonGroup.new()

    # Create monster display container
    var container = VBoxContainer.new()
    container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

    # Monster name
    var name_label = Label.new()
    name_label.text = monster_name.replace("_", " ").capitalize()
    name_label.add_theme_font_size_override("font_size", 14)
    name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    name_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
    container.add_child(name_label)

    # Monster type and CR
    var monster_data = monster_glossary.get_monster(monster_name)
    var type = monster_data.get("type", "Unknown")
    var cr = monster_data.get("challenge_rating", 0)

    var info_label = Label.new()
    info_label.text = type + " • CR " + str(cr)
    info_label.add_theme_font_size_override("font_size", 10)
    info_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
    info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    container.add_child(info_label)

    button.add_child(container)

    # Connect button signal
    button.pressed.connect(func(): select_monster(monster_name))

    return button

func select_monster(monster_name: String):
    """Select a monster and display its details"""
    selected_monster = monster_name

    # Update button appearance
    for name in monster_buttons.keys():
        var button = monster_buttons[name]
        button.button_pressed = (name == monster_name)

    # Display monster details
    display_monster_details(monster_name)

func display_monster_details(monster_name: String):
    """Display detailed information about the selected monster"""
    var details_container = %MonsterDetailsContainer

    # Clear existing details
    for child in details_container.get_children():
        child.queue_free()

    var monster_data = monster_glossary.get_monster(monster_name)
    if monster_data.is_empty():
        return

    # Monster name and basic info
    var name_label = Label.new()
    name_label.text = monster_data.get("name", monster_name).replace("_", " ").capitalize()
    name_label.add_theme_font_size_override("font_size", 24)
    name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    details_container.add_child(name_label)

    # Basic stats
    var stats_container = VBoxContainer.new()
    stats_container.add_child(HSeparator.new())

    var type_label = Label.new()
    type_label.text = "Type: " + monster_data.get("type", "Unknown")
    stats_container.add_child(type_label)

    var size_label = Label.new()
    size_label.text = "Size: " + monster_data.get("size", "Medium")
    stats_container.add_child(size_label)

    var cr_label = Label.new()
    cr_label.text = "Challenge Rating: " + str(monster_data.get("challenge_rating", 0))
    stats_container.add_child(cr_label)

    var hp_label = Label.new()
    hp_label.text = "Hit Points: " + str(monster_data.get("hit_points", 0))
    stats_container.add_child(hp_label)

    var ac_label = Label.new()
    ac_label.text = "Armor Class: " + str(monster_data.get("armor_class", 10))
    stats_container.add_child(ac_label)

    var speed_label = Label.new()
    speed_label.text = "Speed: " + str(monster_data.get("speed", 30)) + " ft."
    stats_container.add_child(speed_label)

    details_container.add_child(stats_container)

    # Abilities
    var abilities = monster_data.get("abilities", {})
    if not abilities.is_empty():
        details_container.add_child(HSeparator.new())

        var abilities_label = Label.new()
        abilities_label.text = "Ability Scores"
        abilities_label.add_theme_font_size_override("font_size", 16)
        details_container.add_child(abilities_label)

        var abilities_text = ""
        for ability in ["STR", "DEX", "CON", "INT", "WIS", "CHA"]:
            if abilities.has(ability):
                abilities_text += ability + ": " + str(abilities[ability]) + "  "

        var abilities_display = Label.new()
        abilities_display.text = abilities_text
        abilities_display.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        details_container.add_child(abilities_display)

    # Traits
    var traits = monster_data.get("traits", [])
    if not traits.is_empty():
        details_container.add_child(HSeparator.new())

        var traits_label = Label.new()
        traits_label.text = "Traits"
        traits_label.add_theme_font_size_override("font_size", 16)
        details_container.add_child(traits_label)

        for monster_trait in traits:
            var trait_label = Label.new()
            trait_label.text = "• " + monster_trait.get("name", "") + ": " + monster_trait.get("description", "")
            trait_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
            details_container.add_child(trait_label)

    # Actions
    var actions = monster_data.get("actions", [])
    if not actions.is_empty():
        details_container.add_child(HSeparator.new())

        var actions_label = Label.new()
        actions_label.text = "Actions"
        actions_label.add_theme_font_size_override("font_size", 16)
        details_container.add_child(actions_label)

        for action in actions:
            var action_label = Label.new()
            action_label.text = "• " + action.get("name", "") + ": " + action.get("description", "")
            action_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
            details_container.add_child(action_label)

    # Legendary Actions
    var legendary_actions = monster_data.get("legendary_actions", [])
    if not legendary_actions.is_empty():
        details_container.add_child(HSeparator.new())

        var legendary_label = Label.new()
        legendary_label.text = "Legendary Actions"
        legendary_label.add_theme_font_size_override("font_size", 16)
        details_container.add_child(legendary_label)

        for action in legendary_actions:
            var action_label = Label.new()
            action_label.text = "• " + action.get("name", "") + ": " + action.get("description", "")
            action_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
            details_container.add_child(action_label)

    # Description
    var description = monster_data.get("description", "")
    if description != "":
        details_container.add_child(HSeparator.new())

        var desc_label = Label.new()
        desc_label.text = "Description"
        desc_label.add_theme_font_size_override("font_size", 16)
        details_container.add_child(desc_label)

        var desc_text = Label.new()
        desc_text.text = description
        desc_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        details_container.add_child(desc_text)

func get_filtered_monsters() -> Array:
    """Get monsters filtered by current criteria"""
    var filters = {}

    # Search filter
    var search_text = %SearchInput.text
    if search_text != "":
        filters["keyword"] = search_text

    # Type filter
    var type_filter = %TypeFilter
    var selected_type = type_filter.get_item_text(type_filter.selected)
    if selected_type != "All Types":
        filters["type"] = selected_type

    # CR filter
    var cr_filter = %CRFilter
    var selected_cr = cr_filter.get_item_text(cr_filter.selected)
    if selected_cr != "All CRs":
        var cr_text = selected_cr.replace("CR ", "")
        filters["min_cr"] = cr_text.to_float()
        filters["max_cr"] = cr_text.to_float()

    # Size filter
    var size_filter = %SizeFilter
    var selected_size = size_filter.get_item_text(size_filter.selected)
    if selected_size != "All Sizes":
        filters["size"] = selected_size

    return monster_glossary.filter_monsters(filters)

func _on_search_text_changed(new_text: String):
    """Handle search text change"""
    display_monsters()

func _on_type_filter_selected(index: int):
    """Handle type filter selection"""
    display_monsters()

func _on_cr_filter_selected(index: int):
    """Handle CR filter selection"""
    display_monsters()

func _on_size_filter_selected(index: int):
    """Handle size filter selection"""
    display_monsters()

func _on_random_monster_button_pressed():
    """Show a random monster"""
    var random_monster = monster_glossary.get_random_monster()
    if not random_monster.is_empty():
        var monster_name = random_monster.get("name", "")
        if monster_name != "":
            select_monster(monster_name)

func _on_export_button_pressed():
    """Export selected monster data"""
    if selected_monster != "":
        var json_data = monster_glossary.export_monster_data(selected_monster)
        if json_data != "":
            # In a real implementation, this would save to file or copy to clipboard
            print("Exported monster data:")
            print(json_data)

func _on_monster_loaded(monster: Dictionary):
    """Handle monster loaded signal"""
    # Refresh display if needed
    pass

func _on_glossary_updated():
    """Handle glossary updated signal"""
    display_monsters()

func _on_back_button_pressed():
    """Return to main screen"""
    get_tree().change_scene_to_file("res://scenes/main.tscn")
