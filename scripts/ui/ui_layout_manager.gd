extends Node

# UI Layout management system
# Handles responsive grid layouts, tab management, and UI organization

class_name UILayoutManager

var tab_container: TabContainer
var current_grid_columns: int = 3

# Initialize layout manager
func initialize(tab_container_ref: TabContainer) -> void:
	tab_container = tab_container_ref

	# Connect to viewport resize events
	get_viewport().size_changed.connect(_on_viewport_size_changed)

# UI configuration loaded from resource
var ui_config: Dictionary = {}

# Load UI configuration from resource
func load_ui_config() -> void:
	var resource_path = "res://data/types/ui_layout_types.tres"
	var resource = load(resource_path)

	if resource == null:
		print("Warning: Could not load UI config from ", resource_path)
		load_default_ui_config()
		return

	var resource_data = resource.get("metadata/yaml_data")
	if resource_data == null:
		resource_data = {}
	if resource_data.size() > 0:
		ui_config = resource_data
		print("Loaded UI configuration with ", ui_config.size(), " categories")
	else:
		print("No UI config found, using defaults")
		load_default_ui_config()

# Parse UI config YAML (simplified parser)
func parse_ui_config_yaml(yaml_content: String) -> Dictionary:
	var config = {}
	var lines = yaml_content.split("\n")
	var current_section = ""
	var current_dict = {}

	for line in lines:
		line = line.strip()
		if line == "" or line.begins_with("#"):
			continue

		if line.ends_with(":"):
			# Save previous section
			if current_section != "":
				config[current_section] = current_dict

			# Start new section
			current_section = line.rstrip(":")
			current_dict = {}
		elif ":" in line and current_section != "":
			var parts = line.split(":", 1)
			var key = parts[0].strip()
			var value = parts[1].strip()

			# Parse array values
			if value.starts_with("[") and value.ends_with("]"):
				var array_content = value.substr(1, value.length() - 2)
				var array_items = array_content.split(",")
				var parsed_array = []
				for item in array_items:
					var trimmed_item = item.strip()
					if trimmed_item.is_valid_float():
						parsed_array.append(trimmed_item.to_float())
					elif trimmed_item.is_valid_int():
						parsed_array.append(trimmed_item.to_int())
					else:
						parsed_array.append(trimmed_item)
				current_dict[key] = parsed_array
			elif value.is_valid_float():
				current_dict[key] = value.to_float()
			elif value.is_valid_int():
				current_dict[key] = value.to_int()
			else:
				current_dict[key] = value

	# Save last section
	if current_section != "":
		config[current_section] = current_dict

	return config

# Load default UI config if YAML fails
func load_default_ui_config() -> void:
	ui_config = {
		"button_sizes": {
			"small": [100, 40],
			"medium": [150, 50],
			"large": [200, 60],
			"square": [200, 200],
			"activity": [200, 120]
		},
		"panel_sizes": {
			"small": [200, 100],
			"medium": [300, 200],
			"large": [400, 300]
		},
		"grid_configs": {
			"mobile": 1,
			"tablet": 2,
			"small_desktop": 3,
			"medium_desktop": 4,
			"large_desktop": 5
		},
		"breakpoints": {
			"mobile": 600,
			"tablet": 900,
			"small_desktop": 1200,
			"medium_desktop": 1600
		}
	}
# Update grid columns based on viewport size
func update_grid_columns(grid_container: GridContainer) -> void:
	var viewport_width = get_viewport().size.x
	var new_columns = calculate_grid_columns(viewport_width)

	if new_columns != current_grid_columns:
		current_grid_columns = new_columns
		grid_container.columns = current_grid_columns
		print("Updated grid columns to: " + str(current_grid_columns))

# Calculate optimal number of grid columns based on viewport width
func calculate_grid_columns(viewport_width: float) -> int:
	# Responsive breakpoints
	if viewport_width < 600:
		return 1  # Mobile
	elif viewport_width < 900:
		return 2  # Tablet
	elif viewport_width < 1200:
		return 3  # Small desktop
	elif viewport_width < 1600:
		return 4  # Medium desktop
	else:
		return 5  # Large desktop

# Create ability tab with proper layout
func create_ability_tab(_ability: String, activities: Dictionary) -> Control:
	var scroll_container = ScrollContainer.new()
	scroll_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var grid_container = GridContainer.new()
	grid_container.columns = current_grid_columns
	grid_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	grid_container.add_theme_constant_override("h_separation", 10)
	grid_container.add_theme_constant_override("v_separation", 10)

	scroll_container.add_child(grid_container)

	# Add activities to grid
	for activity_id in activities:
		var _activity = activities[activity_id]
		# This would create the actual button - delegated to ActivityButtonCreator
		# grid_container.add_child(button_creator.create_activity_button(grid_container, ability, activity_id, activity))

	return scroll_container

# Clear all activity tabs
func clear_activity_tabs() -> void:
	if not tab_container:
		return

	# Remove all tabs except the first one (if it exists)
	var tab_count = tab_container.get_tab_count()
	for i in range(tab_count - 1, 0, -1):  # Remove from end to beginning
		tab_container.remove_child(tab_container.get_child(i))

# Add ability tab to tab container
func add_ability_tab(ability: String, activities: Dictionary) -> void:
	if not tab_container:
		print("Error: TabContainer not found")
		return

	var tab_content = create_ability_tab(ability, activities)
	tab_container.add_child(tab_content)
	var tab_index = tab_container.get_child_count() - 1

	# Set tab title with icon
	var ability_icon = get_ability_icon(ability)
	var tab_title = ability_icon + " " + ability.capitalize()
	tab_container.set_tab_title(tab_index, tab_title)

# Get ability icon
func get_ability_icon(ability: String) -> String:
    # TODO this gets defined multiple times in different places
	var ability_icons = {
		"strength": "💪",
		"dexterity": "🏃",
		"intelligence": "🧠",
		"wisdom": "🦉",
		"charisma": "😎",
		"constitution": "🫀",
		"general": "🌍"
	}
	return ability_icons.get(ability, "⭐")

# Setup responsive layout for rest buttons
func setup_rest_progress_bars() -> void:
	# This would setup rest/progress UI elements
	# Implementation depends on specific UI requirements
	pass

# Style rest button
func style_rest_button(button: Button) -> void:
	button.custom_minimum_size = Vector2(150, 60)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color.WHITE)
	button.modulate = Color(0.8, 1.0, 0.8)  # Light green

# Update progress bars layout
func update_progress_bars() -> void:
	# This would update progress bar layouts
	# Implementation depends on specific UI requirements
	pass

# Handle viewport size changes with debouncing
func _on_viewport_size_changed() -> void:
	# Use a timer to avoid updating too frequently
	if has_meta("resize_timer"):
		get_meta("resize_timer").timeout.disconnect(_on_resize_timeout)

	var timer = Timer.new()
	timer.wait_time = 0.1  # 100ms delay
	timer.one_shot = true
	timer.timeout.connect(_on_resize_timeout)
	add_child(timer)
	timer.start()

	set_meta("resize_timer", timer)

# Handle resize timeout
func _on_resize_timeout() -> void:
	# Update all grid containers
	update_all_grid_containers()

# Update all grid containers in the UI
func update_all_grid_containers() -> void:
	if not tab_container:
		return

	# Find all grid containers and update their columns
	update_grid_containers_recursive(tab_container)

# Recursively update grid containers
func update_grid_containers_recursive(node: Node) -> void:
	if node is GridContainer:
		update_grid_columns(node)

	for child in node.get_children():
		update_grid_containers_recursive(child)

# Get current grid columns setting
func get_current_grid_columns() -> int:
	return current_grid_columns

# Set grid columns manually
func set_grid_columns(columns: int) -> void:
	current_grid_columns = max(1, min(10, columns))  # Clamp between 1 and 10
	update_all_grid_containers()

# Create responsive container
func create_responsive_container() -> Container:
	var container = Container.new()
	container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Add responsive behavior
	container.resized.connect(_on_container_resized.bind(container))

	return container

# Handle container resize
func _on_container_resized(container: Container) -> void:
	# Update layout based on container size
	var container_width = container.size.x
	var new_columns = calculate_grid_columns(container_width)

	if new_columns != current_grid_columns:
		current_grid_columns = new_columns
		update_all_grid_containers()

# Get optimal button size based on viewport
func get_optimal_button_size() -> Vector2:
	var viewport_width = get_viewport().size.x
	var _viewport_height = get_viewport().size.y

	# Calculate button size based on viewport and grid columns
	var button_width = (viewport_width - 40) / current_grid_columns - 20  # Account for margins and gaps
	var button_height = max(100, button_width * 0.6)  # Maintain aspect ratio

	return Vector2(button_width, button_height)

# Create adaptive grid container
func create_adaptive_grid_container() -> GridContainer:
	var grid = GridContainer.new()
	grid.columns = current_grid_columns
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)

	# Connect to resize events
	grid.resized.connect(_on_grid_resized.bind(grid))

	return grid

# Handle grid resize
func _on_grid_resized(grid: GridContainer) -> void:
	update_grid_columns(grid)
