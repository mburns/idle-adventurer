extends Node

# Dynamic UI generator for main scene - eliminates hardcoded buttons!
# Generates all activity buttons from data/activities/*.json files

var tab_container: TabContainer
var ability_icons: Dictionary = {
	"strength": "💪",
	"dexterity": "🏃",
	"intelligence": "🧠",
	"wisdom": "👁️",
	"charisma": "🗣️",
	"constitution": "💪",
	"general": "🌍"
}

func _ready():
	# Get reference to tab container
	tab_container = get_node("../TabContainer")
	if not tab_container:
		print("Error: Could not find TabContainer")
		return

	# Connect to character manager signals to regenerate UI when character changes
	CharacterManager.character_changed.connect(_on_character_changed)

	# Wait a bit for character to be ready, then generate UI
	await get_tree().process_frame
	await get_tree().process_frame
	generate_dynamic_main_ui()

	# Create a test progress bar to verify visibility
	create_test_progress_bar()

func _on_character_changed(_new_character: Character):
	"""Regenerate UI when character changes"""
	generate_dynamic_main_ui()

func generate_dynamic_main_ui():
	"""Generate the entire main UI dynamically from JSON data"""
	# Clear existing tabs (except special ones like Rest, Journal)
	clear_activity_tabs()

	# Add progress bars to Rest activities
	setup_rest_progress_bars()

	# Get all activities from JSON data
	var enhanced_activities = EnhancedActivities.new()
	var all_activities = enhanced_activities.get_all_activities()

	# Create tabs for each ability that has activities
	for ability in all_activities.keys():
		var activities = all_activities[ability]
		if activities.size() > 0:
			create_ability_tab(ability, activities)

func clear_activity_tabs():
	"""Clear activity-related tabs, keeping special tabs like Rest"""
	var tabs_to_keep = ["Rest"]
	var tabs_to_remove = []

	for i in range(tab_container.get_tab_count()):
		var tab_title = tab_container.get_tab_title(i)
		if not tab_title in tabs_to_keep:
			tabs_to_remove.append(i)

	# Remove tabs in reverse order to maintain indices
	tabs_to_remove.reverse()
	for tab_index in tabs_to_remove:
		var tab = tab_container.get_tab_control(tab_index)
		tab.queue_free()

func create_ability_tab(ability: String, activities: Dictionary):
	"""Create a tab and buttons for a specific ability"""
	# Create the tab container (GridContainer)
	var grid_container = GridContainer.new()
	grid_container.columns = 3
	grid_container.add_theme_constant_override("h_separation", 10)
	grid_container.add_theme_constant_override("v_separation", 10)
	grid_container.name = ability + "Tab" # Store ability name in the container

	# Add tab to container
	var tab_title = ability_icons.get(ability, "📋") + " " + ability.capitalize()
	tab_container.add_child(grid_container)
	tab_container.set_tab_title(tab_container.get_tab_count() - 1, tab_title)

	# Create buttons for each activity
	for activity_id in activities.keys():
		var activity = activities[activity_id]
		create_activity_button(grid_container, ability, activity_id, activity)

func create_activity_button(parent: GridContainer, ability: String, activity_id: String, activity: Dictionary):
	"""Create a button for a specific activity"""
	var button = Button.new()
	button.custom_minimum_size = Vector2(200, 60)
	button.text = activity.get("name", "Unknown Activity")

	# Improve text readability
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	button.add_theme_color_override("font_hover_color", Color(1, 1, 1, 1))
	button.add_theme_color_override("font_pressed_color", Color(1, 1, 1, 1))

	# Check if character can perform this activity
	var character = get_character()
	var can_perform = _check_activity_requirements(character, activity)

	# Check if character is available
	if not character:
		print("Warning: No character found when creating button for: ", activity.get("name", "Unknown"))

	# Temporarily disable requirement checking for testing
	can_perform = true

	# Add tooltip with requirements for all buttons
	var requirements_text = _get_requirements_text(activity)
	var tooltip_text = activity.get("description", "")
	if requirements_text != "":
		tooltip_text += "\n\nRequirements: " + requirements_text
	button.tooltip_text = tooltip_text

	if not can_perform:
		# Gray out the button and disable it
		button.disabled = true
		button.modulate = Color(0.5, 0.5, 0.5, 1.0)
	else:
		# Connect button to dynamic handler only if character can perform it
		button.pressed.connect(func(): _on_activity_button_pressed(activity_id, ability))

	# Add button to grid
	parent.add_child(button)

	# Create progress bar for this activity
	create_progress_bar_for_button(button, activity_id, ability)

func create_progress_bar_for_button(button: Button, activity_id: String, ability: String = ""):
	"""Create a progress bar for an activity button"""
	var progress_bar = ProgressBar.new()
	progress_bar.custom_minimum_size = Vector2(180, 16)
	progress_bar.max_value = 1.0
	progress_bar.value = 0.0
	progress_bar.show_percentage = false

	# Set the name to match the activity name for the main script to find it
	var activity_name = get_activity_name_by_id(activity_id, ability)
	progress_bar.name = activity_name + "ProgressBar"

	# Style the progress bar
	progress_bar.add_theme_color_override("background_color", Color(0.2, 0.2, 0.2, 1.0))
	progress_bar.add_theme_color_override("fill_color", Color(0.0, 0.8, 0.0, 1.0))
	progress_bar.modulate = Color(1.0, 1.0, 1.0, 1.0)

	# Add progress bar directly to the button for simplicity
	button.add_child(progress_bar)

	# Position it at the bottom of the button
	progress_bar.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	progress_bar.offset_top = -10
	progress_bar.offset_bottom = -2
	progress_bar.offset_left = 5
	progress_bar.offset_right = -5

	# Register the progress bar with the main script
	var main_script = get_node("../")
	if main_script and main_script.has_method("register_progress_bar"):
		main_script.register_progress_bar(activity_name, progress_bar)

	# Debug: Make progress bar very visible for testing
	progress_bar.value = 0.7
	progress_bar.visible = true
	progress_bar.modulate = Color(1.0, 1.0, 1.0, 1.0)
	print("Created progress bar for: ", activity_name, " at position: ", progress_bar.position, " size: ", progress_bar.size)

func _on_activity_button_pressed(activity_id: String, ability: String):
	"""Handle activity button press"""
	print("Activity button pressed: ", activity_id, " (", ability, ")")
	# Get the main script to start the activity
	var main_script = get_node("../")
	if main_script and main_script.has_method("start_activity"):
		var activity_name = get_activity_name_by_id(activity_id, ability)
		print("Starting activity: ", activity_name)
		if activity_name != "":
			main_script.start_activity(activity_name)
		else:
			print("Warning: Could not find activity name for ID: ", activity_id)

func get_activity_name_by_id(activity_id: String, ability: String) -> String:
	"""Get activity name by ID and ability"""
	var enhanced_activities = EnhancedActivities.new()
	var all_activities = enhanced_activities.get_all_activities()

	if ability in all_activities and activity_id in all_activities[ability]:
		return all_activities[ability][activity_id].get("name", "")

	return ""

func get_ability_from_tab() -> String:
	"""Get the ability name from the current tab context"""
	# This is a simplified approach - in a real implementation you'd track the current tab
	# For now, we'll return a default that works with the matching system
	return "general"

func get_character():
	"""Get the current character from the main script"""
	var main_script = get_node("../")
	if main_script and main_script.has_method("get_character"):
		return main_script.get_character()
	return null

func _check_activity_requirements(character, activity: Dictionary) -> bool:
	"""Check if character meets activity requirements"""
	if not character:
		return false

	var requirements = activity.get("requirements", {})

	# If no requirements, allow the activity
	if requirements.is_empty():
		return true

	for req_type in requirements.keys():
		var required_value = requirements[req_type]

		match req_type:
			"strength", "dexterity", "constitution", "intelligence", "wisdom", "charisma":
				var current_value = character.get(req_type)
				if current_value < required_value:
					return false
			"gold":
				if character.gold < required_value:
					return false
			"tools":
				# For now, assume character has tools if they have enough gold
				if character.gold < 50:
					return false

	return true

func _get_requirements_text(activity: Dictionary) -> String:
	"""Get human-readable requirements text"""
	var requirements = activity.get("requirements", {})
	var req_parts = []

	for req_type in requirements.keys():
		var required_value = requirements[req_type]

		match req_type:
			"strength", "dexterity", "constitution", "intelligence", "wisdom", "charisma":
				req_parts.append(req_type.capitalize() + ": " + str(required_value))
			"gold":
				req_parts.append("Gold: " + str(required_value))
			"tools":
				req_parts.append("Tools: Required")

	return ", ".join(req_parts)

func setup_rest_progress_bars():
	"""Add progress bars to Rest activities"""
	var rest_tab = tab_container.get_node("Rest")
	if not rest_tab:
		return

	# Add progress bars to Short Rest and Long Rest buttons
	var short_rest_button = rest_tab.get_node("ShortRest")
	var long_rest_button = rest_tab.get_node("LongRest")

	if short_rest_button:
		create_rest_progress_bar(short_rest_button, "Short Rest")
		# Connect the button to a rest handler
		short_rest_button.pressed.connect(func(): _on_rest_button_pressed("short_rest"))

	if long_rest_button:
		create_rest_progress_bar(long_rest_button, "Long Rest")
		# Connect the button to a rest handler
		long_rest_button.pressed.connect(func(): _on_rest_button_pressed("long_rest"))

func create_rest_progress_bar(button: Button, activity_name: String):
	"""Create a progress bar for Rest activities (always enabled)"""
	# Style the Rest button for better readability
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	button.add_theme_color_override("font_hover_color", Color(1, 1, 1, 1))
	button.add_theme_color_override("font_pressed_color", Color(1, 1, 1, 1))

	var progress_bar = ProgressBar.new()
	progress_bar.custom_minimum_size = Vector2(180, 12)
	progress_bar.max_value = 1.0
	progress_bar.value = 0.0
	progress_bar.show_percentage = false
	progress_bar.name = activity_name

	# Style the progress bar
	progress_bar.add_theme_color_override("background_color", Color(0.2, 0.2, 0.2, 1.0))
	progress_bar.add_theme_color_override("fill_color", Color(0.0, 0.8, 0.0, 1.0))
	progress_bar.modulate = Color(1.0, 1.0, 1.0, 1.0)

	# Add progress bar as child of button
	button.add_child(progress_bar)

	# Position progress bar at bottom of button, leaving space for text
	progress_bar.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	progress_bar.offset_top = -8
	progress_bar.offset_bottom = -2

	# Register the progress bar with the main script
	var main_script = get_node("../")
	if main_script and main_script.has_method("register_progress_bar"):
		main_script.register_progress_bar(activity_name, progress_bar)

func _on_rest_button_pressed(rest_type: String):
	"""Handle rest button press"""
	print("Rest button pressed: ", rest_type)
	# TODO: Implement rest functionality

func update_progress_bars():
	"""Update all progress bars with current activity progress"""
	# This would be called by the main script to update progress
	# Implementation would depend on how the main script tracks active activities
	pass

func create_test_progress_bar():
	"""Create a test progress bar to verify visibility"""
	var test_bar = ProgressBar.new()
	test_bar.custom_minimum_size = Vector2(300, 30)
	test_bar.max_value = 1.0
	test_bar.value = 0.7
	test_bar.show_percentage = true
	test_bar.name = "TestProgressBar"

	# Make it extremely visible
	test_bar.add_theme_color_override("background_color", Color(0.0, 0.0, 0.0, 1.0))
	test_bar.add_theme_color_override("fill_color", Color(1.0, 0.0, 0.0, 1.0))
	test_bar.modulate = Color(1.0, 1.0, 1.0, 1.0)

	# Add to the tab container for better visibility
	if tab_container:
		tab_container.add_child(test_bar)
		test_bar.position = Vector2(100, 100)
		print("Created test progress bar in tab container at position: ", test_bar.position)
	else:
		# Fallback: add to main scene
		var main_scene = get_node("../")
		if main_scene:
			main_scene.add_child(test_bar)
			test_bar.position = Vector2(50, 50)
			print("Created test progress bar in main scene at position: ", test_bar.position)
		else:
			print("Could not find any parent for test progress bar")
