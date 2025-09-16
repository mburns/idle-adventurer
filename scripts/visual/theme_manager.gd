extends Node

# Theme manager for consistent UI styling across the game

signal theme_changed(new_theme: Theme)

var current_theme: Theme
var themes: Dictionary = {}
var current_theme_name: String = "default"

func _ready():
    load_themes()
    apply_theme("default")

func load_themes():
    """Load all available themes"""
    themes["default"] = create_default_theme()
    themes["dark"] = create_dark_theme()
    themes["dnd_classic"] = create_dnd_classic_theme()
    themes["medieval"] = create_medieval_theme()

func apply_theme(theme_name: String):
    """Apply a theme to the entire game"""
    if theme_name in themes:
        current_theme = themes[theme_name]
        current_theme_name = theme_name
        update_all_ui_elements()
        theme_changed.emit(current_theme)
        print("Applied theme: " + theme_name)

func create_default_theme() -> Theme:
    """Create the default D&D-inspired theme"""
    var theme = Theme.new()

    # Colors
    var primary_color = Color(0.2, 0.4, 0.8) # Deep blue
    var _secondary_color = Color(0.8, 0.6, 0.2) # Gold
    var _accent_color = Color(0.9, 0.9, 0.9) # Light gray
    var background_color = Color(0.95, 0.95, 0.95) # Very light gray
    var text_color = Color(0.1, 0.1, 0.1) # Dark gray
    var _button_color = Color(0.7, 0.7, 0.7) # Medium gray
    var _button_hover_color = Color(0.8, 0.8, 0.8) # Light gray
    var _button_pressed_color = Color(0.6, 0.6, 0.6) # Dark gray

    # Font
    var font = load("res://assets/Grundschrift-Normal.otf")

    # Button styling
    theme.set_color("font_color", "Button", text_color)
    theme.set_color("font_hover_color", "Button", text_color)
    theme.set_color("font_pressed_color", "Button", text_color)
    theme.set_color("font_focus_color", "Button", text_color)
    theme.set_color("font_disabled_color", "Button", Color(0.5, 0.5, 0.5))

    # Panel styling
    theme.set_color("panel", "Panel", background_color)
    theme.set_color("panel", "PanelContainer", background_color)

    # Label styling
    theme.set_color("font_color", "Label", text_color)
    theme.set_color("font_shadow_color", "Label", Color(0.8, 0.8, 0.8))
    theme.set_constant("shadow_offset_x", "Label", 1)
    theme.set_constant("shadow_offset_y", "Label", 1)

    # LineEdit styling
    theme.set_color("font_color", "LineEdit", text_color)
    theme.set_color("font_selected_color", "LineEdit", Color.WHITE)
    theme.set_color("font_uneditable_color", "LineEdit", Color(0.5, 0.5, 0.5))
    theme.set_color("selection_color", "LineEdit", primary_color)

    # OptionButton styling
    theme.set_color("font_color", "OptionButton", text_color)
    theme.set_color("font_hover_color", "OptionButton", text_color)
    theme.set_color("font_pressed_color", "OptionButton", text_color)
    theme.set_color("font_focus_color", "OptionButton", text_color)
    theme.set_color("font_disabled_color", "OptionButton", Color(0.5, 0.5, 0.5))

    # ProgressBar styling
    theme.set_color("fill", "ProgressBar", primary_color)
    theme.set_color("background", "ProgressBar", Color(0.8, 0.8, 0.8))

    # TabContainer styling
    theme.set_color("font_color", "TabContainer", text_color)
    theme.set_color("font_selected_color", "TabContainer", primary_color)

    # Set font
    if font:
        theme.set_font("font", "Button", font)
        theme.set_font("font", "Label", font)
        theme.set_font("font", "LineEdit", font)
        theme.set_font("font", "OptionButton", font)
        theme.set_font("font", "TabContainer", font)

    return theme

func create_dark_theme() -> Theme:
    """Create a dark theme variant"""
    var theme = create_default_theme()

    # Dark theme colors
    var _dark_bg = Color(0.1, 0.1, 0.1)
    var dark_panel = Color(0.15, 0.15, 0.15)
    var light_text = Color(0.9, 0.9, 0.9)
    var accent = Color(0.3, 0.6, 1.0)

    # Update colors
    theme.set_color("panel", "Panel", dark_panel)
    theme.set_color("panel", "PanelContainer", dark_panel)
    theme.set_color("font_color", "Label", light_text)
    theme.set_color("font_color", "Button", light_text)
    theme.set_color("font_color", "LineEdit", light_text)
    theme.set_color("font_color", "OptionButton", light_text)
    theme.set_color("font_color", "TabContainer", light_text)
    theme.set_color("selection_color", "LineEdit", accent)
    theme.set_color("fill", "ProgressBar", accent)

    return theme

func create_dnd_classic_theme() -> Theme:
    """Create a classic D&D themed UI"""
    var theme = create_default_theme()

    # D&D classic colors
    var parchment = Color(0.98, 0.95, 0.85)
    var ink = Color(0.1, 0.1, 0.1)
    var gold = Color(0.8, 0.6, 0.2)
    var _red = Color(0.6, 0.1, 0.1)
    var _blue = Color(0.1, 0.3, 0.6)

    # Update colors
    theme.set_color("panel", "Panel", parchment)
    theme.set_color("panel", "PanelContainer", parchment)
    theme.set_color("font_color", "Label", ink)
    theme.set_color("font_color", "Button", ink)
    theme.set_color("font_color", "LineEdit", ink)
    theme.set_color("font_color", "OptionButton", ink)
    theme.set_color("font_color", "TabContainer", ink)
    theme.set_color("selection_color", "LineEdit", gold)
    theme.set_color("fill", "ProgressBar", gold)

    return theme

func create_medieval_theme() -> Theme:
    """Create a medieval fantasy themed UI"""
    var theme = create_default_theme()

    # Medieval colors
    var stone = Color(0.6, 0.6, 0.5)
    var _wood = Color(0.4, 0.3, 0.2)
    var metal = Color(0.7, 0.7, 0.8)
    var text = Color(0.9, 0.9, 0.8)

    # Update colors
    theme.set_color("panel", "Panel", stone)
    theme.set_color("panel", "PanelContainer", stone)
    theme.set_color("font_color", "Label", text)
    theme.set_color("font_color", "Button", text)
    theme.set_color("font_color", "LineEdit", text)
    theme.set_color("font_color", "OptionButton", text)
    theme.set_color("font_color", "TabContainer", text)
    theme.set_color("selection_color", "LineEdit", metal)
    theme.set_color("fill", "ProgressBar", metal)

    return theme

func update_all_ui_elements():
    """Update all UI elements with the current theme"""
    var root = get_tree().current_scene
    if root:
        apply_theme_to_node(root)

func apply_theme_to_node(node: Node):
    """Recursively apply theme to a node and its children"""
    if node.has_method("set_theme"):
        node.set_theme(current_theme)

    for child in node.get_children():
        apply_theme_to_node(child)

func apply_theme_to_children(node: Node):
    """Apply theme to all children of a node (alias for apply_theme_to_node)"""
    apply_theme_to_node(node)

func get_theme_color(color_name: String, control_type: String = "Label") -> Color:
    """Get a color from the current theme"""
    return current_theme.get_color(color_name, control_type)

func get_theme_font(control_type: String = "Label") -> Font:
    """Get a font from the current theme"""
    return current_theme.get_font("font", control_type)

func create_custom_button_style() -> StyleBox:
    """Create a custom button style"""
    var style = StyleBoxFlat.new()
    style.bg_color = get_theme_color("font_color", "Button")
    style.border_width_left = 2
    style.border_width_right = 2
    style.border_width_top = 2
    style.border_width_bottom = 2
    style.border_color = get_theme_color("font_color", "Button").darkened(0.3)
    style.corner_radius_top_left = 4
    style.corner_radius_top_right = 4
    style.corner_radius_bottom_left = 4
    style.corner_radius_bottom_right = 4
    return style

func create_custom_panel_style() -> StyleBox:
    """Create a custom panel style"""
    var style = StyleBoxFlat.new()
    style.bg_color = get_theme_color("panel", "Panel")
    style.border_width_left = 1
    style.border_width_right = 1
    style.border_width_top = 1
    style.border_width_bottom = 1
    style.border_color = get_theme_color("font_color", "Label").lightened(0.5)
    style.corner_radius_top_left = 6
    style.corner_radius_top_right = 6
    style.corner_radius_bottom_left = 6
    style.corner_radius_bottom_right = 6
    return style

func get_available_themes() -> Array[String]:
    """Get list of available theme names"""
    return themes.keys()

func save_theme_preference():
    """Save the current theme preference"""
    var config = ConfigFile.new()
    config.set_value("ui", "theme", current_theme_name)
    config.save("user://settings.cfg")

func load_theme_preference():
    """Load the saved theme preference"""
    var config = ConfigFile.new()
    var err = config.load("user://settings.cfg")
    if err == OK:
        var saved_theme = config.get_value("ui", "theme", "default")
        apply_theme(saved_theme)
