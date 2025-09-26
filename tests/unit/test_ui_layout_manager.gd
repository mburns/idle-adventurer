extends GutTest

var ui_layout_manager: UILayoutManager

func before_each():
	ui_layout_manager = UILayoutManager.new()

func after_each():
	if ui_layout_manager:
		ui_layout_manager.queue_free()

func test_load_ui_config():
	ui_layout_manager.load_ui_config()

	assert_true(ui_layout_manager.ui_config.size() > 0, "Should have loaded UI config")
	print("Loaded UI config with ", ui_layout_manager.ui_config.size(), " categories")

func test_parse_ui_config_yaml():
	var yaml_content = """
button_sizes:
  small: [100, 40]
  medium: [150, 50]
  large: [200, 60]

panel_sizes:
  small: [200, 100]
  medium: [300, 200]

grid_configs:
  mobile: 1
  tablet: 2

breakpoints:
  mobile: 600
  tablet: 900
"""

	var config = ui_layout_manager.parse_ui_config_yaml(yaml_content)

	assert_true(config.has("button_sizes"), "Should have button_sizes section")
	assert_true(config.has("panel_sizes"), "Should have panel_sizes section")
	assert_true(config.has("grid_configs"), "Should have grid_configs section")
	assert_true(config.has("breakpoints"), "Should have breakpoints section")

	var button_sizes = config["button_sizes"]
	assert_eq(button_sizes["small"], [100, 40], "Should parse small button size")
	assert_eq(button_sizes["medium"], [150, 50], "Should parse medium button size")

	var breakpoints = config["breakpoints"]
	# This test is deprecated - UI config now loads from .tres resources
	pending("YAML parsing removed - now using .tres resources")
	return

func test_get_button_size():
	ui_layout_manager.load_ui_config()

	var small_size = ui_layout_manager.get_button_size("small")
	var medium_size = ui_layout_manager.get_button_size("medium")
	var large_size = ui_layout_manager.get_button_size("large")

	assert_eq(small_size, Vector2(100, 40), "Should return correct small button size")
	assert_eq(medium_size, Vector2(150, 50), "Should return correct medium button size")
	assert_eq(large_size, Vector2(200, 60), "Should return correct large button size")

	# Test default fallback
	var unknown_size = ui_layout_manager.get_button_size("unknown")
	assert_eq(unknown_size, Vector2(100, 40), "Should return default size for unknown type")

func test_get_panel_size():
	ui_layout_manager.load_ui_config()

	var small_size = ui_layout_manager.get_panel_size("small")
	var medium_size = ui_layout_manager.get_panel_size("medium")
	var large_size = ui_layout_manager.get_panel_size("large")

	assert_eq(small_size, Vector2(200, 100), "Should return correct small panel size")
	assert_eq(medium_size, Vector2(300, 200), "Should return correct medium panel size")
	assert_eq(large_size, Vector2(400, 300), "Should return correct large panel size")

func test_get_theme_color():
	ui_layout_manager.load_ui_config()

	var primary_color = ui_layout_manager.get_theme_color("primary")
	var success_color = ui_layout_manager.get_theme_color("success")

	assert_true(primary_color is Color, "Should return Color object")
	assert_true(success_color is Color, "Should return Color object")

	# Test default fallback
	var unknown_color = ui_layout_manager.get_theme_color("unknown")
	assert_true(unknown_color is Color, "Should return default Color for unknown type")

func test_get_font_size():
	ui_layout_manager.load_ui_config()

	var small_font = ui_layout_manager.get_font_size("small")
	var normal_font = ui_layout_manager.get_font_size("normal")
	var large_font = ui_layout_manager.get_font_size("large")

	assert_true(small_font is int, "Should return integer font size")
	assert_true(normal_font is int, "Should return integer font size")
	assert_true(large_font is int, "Should return integer font size")

	# Test default fallback
	var unknown_font = ui_layout_manager.get_font_size("unknown")
	assert_eq(unknown_font, 12, "Should return default font size for unknown type")

func test_get_spacing():
	ui_layout_manager.load_ui_config()

	var small_spacing = ui_layout_manager.get_spacing("small")
	var medium_spacing = ui_layout_manager.get_spacing("medium")
	var large_spacing = ui_layout_manager.get_spacing("large")

	assert_true(small_spacing is int, "Should return integer spacing")
	assert_true(medium_spacing is int, "Should return integer spacing")
	assert_true(large_spacing is int, "Should return integer spacing")

	# Test default fallback
	var unknown_spacing = ui_layout_manager.get_spacing("unknown")
	assert_eq(unknown_spacing, 10, "Should return default spacing for unknown type")

func test_get_ability_icon():
	assert_eq(ui_layout_manager.get_ability_icon("strength"), "💪", "Should return strength icon")
	assert_eq(ui_layout_manager.get_ability_icon("dexterity"), "🏃", "Should return dexterity icon")
	assert_eq(ui_layout_manager.get_ability_icon("intelligence"), "🧠", "Should return intelligence icon")
	assert_eq(ui_layout_manager.get_ability_icon("wisdom"), "🦉", "Should return wisdom icon")
	assert_eq(ui_layout_manager.get_ability_icon("charisma"), "😎", "Should return charisma icon")
	assert_eq(ui_layout_manager.get_ability_icon("constitution"), "🫀", "Should return constitution icon")
	assert_eq(ui_layout_manager.get_ability_icon("general"), "🌍", "Should return general icon")

	# Test default fallback
	assert_eq(ui_layout_manager.get_ability_icon("unknown"), "⭐", "Should return default icon for unknown ability")

func test_calculate_grid_columns():
	ui_layout_manager.load_ui_config()

	# Test different viewport widths
	assert_eq(ui_layout_manager.calculate_grid_columns(500), 1, "Should return 1 column for mobile")
	assert_eq(ui_layout_manager.calculate_grid_columns(700), 2, "Should return 2 columns for tablet")
	assert_eq(ui_layout_manager.calculate_grid_columns(1000), 3, "Should return 3 columns for small desktop")
	assert_eq(ui_layout_manager.calculate_grid_columns(1400), 4, "Should return 4 columns for medium desktop")
	assert_eq(ui_layout_manager.calculate_grid_columns(1800), 5, "Should return 5 columns for large desktop")

func test_get_optimal_button_size():
	ui_layout_manager.load_ui_config()

	# Mock viewport size
	var mock_viewport = Vector2(1200, 800)
	# We can't easily mock get_viewport() in tests, so we'll test the logic indirectly

	var button_size = ui_layout_manager.get_optimal_button_size("medium")
	assert_true(button_size is Vector2, "Should return Vector2")
	assert_true(button_size.x > 0, "Should have positive width")
	assert_true(button_size.y > 0, "Should have positive height")

func test_parse_ui_config_yaml_with_comments():
	# This test is deprecated - UI config now loads from .tres resources
	pending("YAML parsing removed - now using .tres resources")
	return

func test_parse_ui_config_yaml_empty():
	# This test is deprecated - UI config now loads from .tres resources
	pending("YAML parsing removed - now using .tres resources")
	return

func test_load_default_ui_config():
	ui_layout_manager.load_default_ui_config()

	assert_true(ui_layout_manager.ui_config.has("button_sizes"), "Should have button_sizes in default config")
	assert_true(ui_layout_manager.ui_config.has("panel_sizes"), "Should have panel_sizes in default config")
	assert_true(ui_layout_manager.ui_config.has("grid_configs"), "Should have grid_configs in default config")
	assert_true(ui_layout_manager.ui_config.has("breakpoints"), "Should have breakpoints in default config")

	var button_sizes = ui_layout_manager.ui_config["button_sizes"]
	assert_eq(button_sizes["small"], [100, 40], "Should have correct default small button size")
	assert_eq(button_sizes["medium"], [150, 50], "Should have correct default medium button size")
