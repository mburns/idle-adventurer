extends Node

# Enhanced UI components for consistent styling

class_name UIComponents

# Create a styled button with consistent theming
static func create_styled_button(text: String, callback: Callable = Callable()) -> Button:
    var button = Button.new()
    button.text = text
    button.custom_minimum_size = Vector2(120, 40)

    if callback.is_valid():
        button.pressed.connect(callback)

    # Apply theme styling
    var style = ThemeManager.create_custom_button_style()
    button.add_theme_stylebox_override("normal", style)

    var hover_style = style.duplicate()
    hover_style.bg_color = hover_style.bg_color.lightened(0.1)
    button.add_theme_stylebox_override("hover", hover_style)

    var pressed_style = style.duplicate()
    pressed_style.bg_color = pressed_style.bg_color.darkened(0.1)
    button.add_theme_stylebox_override("pressed", pressed_style)

    return button

# Create a styled panel with consistent theming
static func create_styled_panel() -> Panel:
    var panel = Panel.new()
    var style = ThemeManager.create_custom_panel_style()
    panel.add_theme_stylebox_override("panel", style)
    return panel

# Create a styled label with consistent theming
static func create_styled_label(text: String, font_size: int = 16) -> Label:
    var label = Label.new()
    label.text = text
    label.add_theme_font_size_override("font_size", font_size)
    return label

# Create a styled progress bar with consistent theming
static func create_styled_progress_bar() -> ProgressBar:
    var progress_bar = ProgressBar.new()
    progress_bar.min_value = 0
    progress_bar.max_value = 100
    progress_bar.value = 0
    progress_bar.custom_minimum_size = Vector2(200, 20)
    return progress_bar

# Create a character stat display panel
static func create_character_stat_panel(character: Character) -> Panel:
    var panel = create_styled_panel()
    panel.custom_minimum_size = Vector2(300, 200)

    var vbox = VBoxContainer.new()
    panel.add_child(vbox)

    # Character name
    var name_label = create_styled_label(character.name, 20)
    vbox.add_child(name_label)

    # Character level and class
    var level_label = create_styled_label("Level " + str(character.level) + " " + character.character_class, 14)
    vbox.add_child(level_label)

    # Stats
    var stats_container = HBoxContainer.new()
    vbox.add_child(stats_container)

    var left_stats = VBoxContainer.new()
    var right_stats = VBoxContainer.new()
    stats_container.add_child(left_stats)
    stats_container.add_child(right_stats)

    # Left column stats
    left_stats.add_child(create_stat_label("STR", character.strength, character.get_strength_modifier()))
    left_stats.add_child(create_stat_label("DEX", character.dexterity, character.get_dexterity_modifier()))
    left_stats.add_child(create_stat_label("CON", character.constitution, character.get_constitution_modifier()))

    # Right column stats
    right_stats.add_child(create_stat_label("INT", character.intelligence, character.get_intelligence_modifier()))
    right_stats.add_child(create_stat_label("WIS", character.wisdom, character.get_wisdom_modifier()))
    right_stats.add_child(create_stat_label("CHA", character.charisma, character.get_charisma_modifier()))

    return panel

# Create a stat label with value and modifier
static func create_stat_label(stat_name: String, value: int, modifier: int) -> Label:
    var label = create_styled_label(stat_name + ": " + str(value) + " (" + ("+" if modifier >= 0 else "") + str(modifier) + ")", 12)
    return label

# Create a skill activity button
static func create_skill_button(skill_name: String, callback: Callable) -> Button:
    var button = create_styled_button(skill_name, callback)
    button.custom_minimum_size = Vector2(150, 50)
    return button

# Create a themed container with title
static func create_themed_container(title: String) -> Panel:
    var container = create_styled_panel()
    container.custom_minimum_size = Vector2(400, 300)

    var vbox = VBoxContainer.new()
    container.add_child(vbox)

    # Title
    var title_label = create_styled_label(title, 18)
    title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vbox.add_child(title_label)

    # Separator
    var separator = HSeparator.new()
    vbox.add_child(separator)

    return container

# Create a dice roll display
static func create_dice_roll_display() -> Panel:
    var panel = create_styled_panel()
    panel.custom_minimum_size = Vector2(200, 100)

    var vbox = VBoxContainer.new()
    panel.add_child(vbox)

    var title = create_styled_label("Dice Roll", 16)
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vbox.add_child(title)

    var result_label = create_styled_label("Roll some dice!", 14)
    result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    result_label.name = "ResultLabel"
    vbox.add_child(result_label)

    return panel

# Create a character equipment slot
static func create_equipment_slot(slot_name: String) -> Panel:
    var panel = create_styled_panel()
    panel.custom_minimum_size = Vector2(80, 80)

    var vbox = VBoxContainer.new()
    panel.add_child(vbox)

    var slot_label = create_styled_label(slot_name, 10)
    slot_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vbox.add_child(slot_label)

    var item_label = create_styled_label("Empty", 8)
    item_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    item_label.name = "ItemLabel"
    vbox.add_child(item_label)

    return panel

# Create a notification popup
static func create_notification_popup(message: String) -> Panel:
    var panel = create_styled_panel()
    panel.custom_minimum_size = Vector2(300, 100)

    var vbox = VBoxContainer.new()
    panel.add_child(vbox)

    var message_label = create_styled_label(message, 14)
    message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    vbox.add_child(message_label)

    # Auto-hide after 3 seconds
    var timer = Timer.new()
    timer.wait_time = 3.0
    timer.one_shot = true
    timer.timeout.connect(func(): panel.queue_free())
    panel.add_child(timer)
    timer.start()

    return panel

# Create a themed scroll container
static func create_themed_scroll_container() -> ScrollContainer:
    var scroll = ScrollContainer.new()
    scroll.custom_minimum_size = Vector2(400, 300)

    var vbox = VBoxContainer.new()
    vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    scroll.add_child(vbox)

    return scroll

# Create a character portrait placeholder
static func create_character_portrait() -> Panel:
    var panel = create_styled_panel()
    panel.custom_minimum_size = Vector2(120, 120)

    var label = create_styled_label("Portrait", 12)
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    panel.add_child(label)

    return panel

# Apply theme to all children of a node
static func apply_theme_to_children(node: Node):
    for child in node.get_children():
        if child.has_method("set_theme"):
            child.set_theme(ThemeManager.current_theme)
        apply_theme_to_children(child)
