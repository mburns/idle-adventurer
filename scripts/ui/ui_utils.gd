extends RefCounted
class_name UIUtils

## Utility class for common UI operations and patterns

static func create_label(text: String, font_size: int = 16) -> Label:
	"""Create a styled label with common properties"""
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	return label

static func create_button(text: String, callback: Callable = Callable()) -> Button:
	"""Create a styled button with common properties"""
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(100, 40)

	if callback.is_valid():
		button.pressed.connect(callback)

	return button

static func create_container(orientation: int = 0) -> Container:  # 0 = VERTICAL, 1 = HORIZONTAL
	"""Create a container with common properties"""
	var container: Container
	if orientation == 0:  # VERTICAL
		container = VBoxContainer.new()
	else:  # HORIZONTAL
		container = HBoxContainer.new()

	container.add_theme_constant_override("separation", 5)
	return container

static func create_progress_bar(min_value: float = 0.0, max_value: float = 100.0) -> ProgressBar:
	"""Create a styled progress bar"""
	var progress_bar = ProgressBar.new()
	progress_bar.min_value = min_value
	progress_bar.max_value = max_value
	progress_bar.value = 0.0
	progress_bar.custom_minimum_size = Vector2(200, 20)
	return progress_bar

static func create_panel() -> Panel:
	"""Create a styled panel"""
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(200, 100)
	return panel

static func create_scroll_container() -> ScrollContainer:
	"""Create a scroll container with common properties"""
	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(400, 300)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	return scroll

static func create_style_box(color: Color = Color.WHITE, border_width: int = 1) -> StyleBoxFlat:
	"""Create a styled box for UI elements"""
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.border_width_left = border_width
	style.border_width_right = border_width
	style.border_width_top = border_width
	style.border_width_bottom = border_width
	style.border_color = Color.BLACK
	return style

static func format_ability_score(score: int) -> String:
	"""Format an ability score with modifier"""
	var modifier = (score - 10) / 2
	var sign_str = "+" if modifier >= 0 else ""
	return "%d (%s%d)" % [score, sign_str, modifier]

static func format_percentage(value: float, max_value: float) -> String:
	"""Format a value as a percentage"""
	var percentage = (value / max_value) * 100.0
	return "%.1f%%" % percentage

static func format_currency(amount: int) -> String:
	"""Format currency amount"""
	if amount >= 1000:
		return "%d.%dk gp" % [amount / 1000, (amount % 1000) / 100]
	else:
		return "%d gp" % amount

static func format_time(seconds: int) -> String:
	"""Format time in seconds to readable format"""
	var hours = seconds / 3600
	var minutes = (seconds % 3600) / 60
	var secs = seconds % 60

	if hours > 0:
		return "%dh %dm %ds" % [hours, minutes, secs]
	elif minutes > 0:
		return "%dm %ds" % [minutes, secs]
	else:
		return "%ds" % secs

static func create_dialog(title: String, message: String) -> AcceptDialog:
	"""Create a simple dialog"""
	var dialog = AcceptDialog.new()
	dialog.title = title
	dialog.dialog_text = message
	dialog.size = Vector2(400, 200)
	return dialog

static func create_confirmation_dialog(title: String, message: String, callback: Callable) -> ConfirmationDialog:
	"""Create a confirmation dialog"""
	var dialog = ConfirmationDialog.new()
	dialog.title = title
	dialog.dialog_text = message
	dialog.size = Vector2(400, 200)
	dialog.confirmed.connect(callback)
	return dialog

static func animate_fade_in(node: Node, duration: float = 0.5) -> void:
	"""Animate a node fading in"""
	node.modulate.a = 0.0
	var tween = node.create_tween()
	tween.tween_property(node, "modulate:a", 1.0, duration)

static func animate_fade_out(node: Node, duration: float = 0.5) -> void:
	"""Animate a node fading out"""
	var tween = node.create_tween()
	tween.tween_property(node, "modulate:a", 0.0, duration)
	tween.tween_callback(node.queue_free)

static func animate_scale(node: Node, target_scale: Vector2, duration: float = 0.3) -> void:
	"""Animate a node scaling"""
	var tween = node.create_tween()
	tween.tween_property(node, "scale", target_scale, duration)

static func create_tooltip(text: String) -> Control:
	"""Create a tooltip control"""
	var tooltip = Panel.new()
	tooltip.custom_minimum_size = Vector2(200, 50)

	var label = Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 12)

	tooltip.add_child(label)
	return tooltip
