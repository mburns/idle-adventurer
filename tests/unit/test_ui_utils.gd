extends GutTest

## Test suite for UIUtils class

const UIUtilsClass = preload("res://scripts/ui_utils.gd")

func test_create_label():
	"""Test label creation with default and custom properties"""
	var label = UIUtilsClass.create_label("Test Label")

	assert_not_null(label, "Label should be created")
	assert_eq(label.text, "Test Label", "Label text should match")
	assert_true(label is Label, "Should be instance of Label")

	# Test with custom font size
	var custom_label = UIUtilsClass.create_label("Custom", 24)
	assert_eq(custom_label.get_theme_font_size("font_size"), 24, "Font size should be set")

func test_create_button():
	"""Test button creation with and without callback"""
	var button = UIUtilsClass.create_button("Test Button")

	assert_not_null(button, "Button should be created")
	assert_eq(button.text, "Test Button", "Button text should match")
	assert_true(button is Button, "Should be instance of Button")
	assert_ge(button.custom_minimum_size.x, 100, "Button should have minimum width")
	assert_ge(button.custom_minimum_size.y, 40, "Button should have minimum height")

func test_create_container():
	"""Test container creation for both orientations"""
	var vbox = UIUtilsClass.create_container(0)  # VERTICAL = 0
	var hbox = UIUtilsClass.create_container(1)  # HORIZONTAL = 1

	assert_true(vbox is VBoxContainer, "Should create VBoxContainer for vertical")
	assert_true(hbox is HBoxContainer, "Should create HBoxContainer for horizontal")

func test_create_progress_bar():
	"""Test progress bar creation with custom values"""
	var progress_bar = UIUtilsClass.create_progress_bar(0.0, 100.0)

	assert_not_null(progress_bar, "Progress bar should be created")
	assert_eq(progress_bar.min_value, 0.0, "Min value should be set")
	assert_eq(progress_bar.max_value, 100.0, "Max value should be set")
	assert_eq(progress_bar.value, 0.0, "Initial value should be 0")
	assert_true(progress_bar is ProgressBar, "Should be instance of ProgressBar")

func test_create_panel():
	"""Test panel creation"""
	var panel = UIUtilsClass.create_panel()

	assert_not_null(panel, "Panel should be created")
	assert_true(panel is Panel, "Should be instance of Panel")
	assert_ge(panel.custom_minimum_size.x, 200, "Panel should have minimum width")
	assert_ge(panel.custom_minimum_size.y, 100, "Panel should have minimum height")

func test_create_scroll_container():
	"""Test scroll container creation"""
	var scroll = UIUtilsClass.create_scroll_container()

	assert_not_null(scroll, "Scroll container should be created")
	assert_true(scroll is ScrollContainer, "Should be instance of ScrollContainer")
	assert_ge(scroll.custom_minimum_size.x, 400, "Scroll container should have minimum width")
	assert_ge(scroll.custom_minimum_size.y, 300, "Scroll container should have minimum height")

func test_create_style_box():
	"""Test style box creation with custom properties"""
	var style = UIUtilsClass.create_style_box(Color.RED, 2)

	assert_not_null(style, "Style box should be created")
	assert_true(style is StyleBoxFlat, "Should be instance of StyleBoxFlat")
	assert_eq(style.bg_color, Color.RED, "Background color should be set")
	assert_eq(style.border_width_left, 2, "Border width should be set")

func test_format_ability_score():
	"""Test ability score formatting"""
	# Test positive modifier
	var result = UIUtilsClass.format_ability_score(15)
	assert_eq(result, "15 (+2)", "Should format positive modifier correctly")

	# Test negative modifier
	result = UIUtilsClass.format_ability_score(8)
	assert_eq(result, "8 (-1)", "Should format negative modifier correctly")

	# Test zero modifier
	result = UIUtilsClass.format_ability_score(10)
	assert_eq(result, "10 (+0)", "Should format zero modifier correctly")

func test_format_percentage():
	"""Test percentage formatting"""
	var result = UIUtilsClass.format_percentage(75.0, 100.0)
	assert_eq(result, "75.0%", "Should format percentage correctly")

	result = UIUtilsClass.format_percentage(50.0, 200.0)
	assert_eq(result, "25.0%", "Should calculate percentage correctly")

func test_format_currency():
	"""Test currency formatting"""
	# Test small amount
	var result = UIUtilsClass.format_currency(50)
	assert_eq(result, "50 gp", "Should format small amount correctly")

	# Test large amount
	result = UIUtilsClass.format_currency(1500)
	assert_eq(result, "1.5k gp", "Should format large amount correctly")

	# Test very large amount
	result = UIUtilsClass.format_currency(2500)
	assert_eq(result, "2.5k gp", "Should format very large amount correctly")

func test_format_time():
	"""Test time formatting"""
	# Test seconds only
	var result = UIUtilsClass.format_time(30)
	assert_eq(result, "30s", "Should format seconds only correctly")

	# Test minutes and seconds
	result = UIUtilsClass.format_time(90)
	assert_eq(result, "1m 30s", "Should format minutes and seconds correctly")

	# Test hours, minutes, and seconds
	result = UIUtilsClass.format_time(3661)
	assert_eq(result, "1h 1m 1s", "Should format hours, minutes, and seconds correctly")

func test_create_dialog():
	"""Test dialog creation"""
	var dialog = UIUtilsClass.create_dialog("Test Title", "Test Message")

	assert_not_null(dialog, "Dialog should be created")
	assert_true(dialog is AcceptDialog, "Should be instance of AcceptDialog")
	assert_eq(dialog.title, "Test Title", "Dialog title should be set")
	assert_eq(dialog.dialog_text, "Test Message", "Dialog text should be set")

func test_create_confirmation_dialog():
	"""Test confirmation dialog creation"""
	var callback_called = false
	var callback = func(): callback_called = true
	var dialog = UIUtilsClass.create_confirmation_dialog("Test Title", "Test Message", callback)

	assert_not_null(dialog, "Confirmation dialog should be created")
	assert_true(dialog is ConfirmationDialog, "Should be instance of ConfirmationDialog")
	assert_eq(dialog.title, "Test Title", "Dialog title should be set")
	assert_eq(dialog.dialog_text, "Test Message", "Dialog text should be set")

	# Test callback connection
	dialog.confirmed.emit()
	assert_true(callback_called, "Callback should be called when confirmed")
