extends Node

# Dynamic UI generator for main scene - eliminates hardcoded buttons!
# Generates all activity buttons from data/activities/*.yaml files

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

	# Connect to window resize events
	get_viewport().size_changed.connect(_on_viewport_size_changed)

	# Wait a bit for character to be ready, then generate UI
	await get_tree().process_frame
	await get_tree().process_frame
	generate_dynamic_main_ui()

func _on_character_changed(_new_character: Character):
	"""Regenerate UI when character changes"""
	generate_dynamic_main_ui()

func _on_viewport_size_changed():
	"""Update grid columns when window is resized"""
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

func _on_resize_timeout():
	"""Handle resize timeout - update all grid columns"""
	# Update all grid containers in all tabs
	for i in range(tab_container.get_tab_count()):
		var tab = tab_container.get_tab_control(i)
		if tab and is_instance_valid(tab):
			for child in tab.get_children():
				if child is ScrollContainer and is_instance_valid(child):
					for grandchild in child.get_children():
						if grandchild is GridContainer and is_instance_valid(grandchild) and grandchild.name.ends_with("Tab"):
							update_grid_columns(grandchild)

	# Clean up timer
	if has_meta("resize_timer"):
		var timer = get_meta("resize_timer")
		if is_instance_valid(timer):
			timer.queue_free()
		remove_meta("resize_timer")

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
	# Create a scroll container for responsive layout
	var scroll_container = ScrollContainer.new()
	scroll_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO

	# Create a grid container for responsive multi-column layout
	var grid_container = GridContainer.new()
	grid_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	grid_container.add_theme_constant_override("h_separation", 15)
	grid_container.add_theme_constant_override("v_separation", 15)
	grid_container.name = ability + "Tab" # Store ability name in the container

	# Set a reasonable default number of columns
	grid_container.columns = 3

	scroll_container.add_child(grid_container)

	# Add tab to container
	var tab_title = ability_icons.get(ability, "📋") + " " + ability.capitalize()
	tab_container.add_child(scroll_container)
	tab_container.set_tab_title(tab_container.get_tab_count() - 1, tab_title)

	# Create buttons for each activity
	for activity_id in activities.keys():
		var activity = activities[activity_id]
		create_activity_button(grid_container, ability, activity_id, activity)

	# Store reference for later column updates
	grid_container.set_meta("needs_column_update", true)

func create_activity_button(parent: GridContainer, ability: String, activity_id: String, activity: Dictionary):
	"""Create an enhanced square activity button with integrated metadata"""
	# Create a square button with integrated metadata
	var button = Button.new()
	button.custom_minimum_size = Vector2(200, 200)  # Square button
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	# Create the button content with metadata integrated
	var button_content = create_button_content(activity)
	button.add_child(button_content)

	# Style the button
	button.add_theme_font_size_override("font_size", 14)
	button.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	button.add_theme_color_override("font_hover_color", Color(1, 1, 1, 1))
	button.add_theme_color_override("font_pressed_color", Color(1, 1, 1, 1))
	button.add_theme_color_override("font_disabled_color", Color(1, 1, 1, 1))
	button.add_theme_constant_override("outline_size", 0)
	button.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)

	# Set button background colors
	button.add_theme_color_override("bg_color", Color(0.2, 0.2, 0.2, 1.0))
	button.add_theme_color_override("bg_color_hover", Color(0.3, 0.3, 0.3, 1.0))
	button.add_theme_color_override("bg_color_pressed", Color(0.4, 0.4, 0.4, 1.0))
	button.add_theme_color_override("bg_color_disabled", Color(0.1, 0.1, 0.1, 1.0))

	# Check if character can perform this activity
	var character = get_character()
	var can_perform = _check_activity_requirements(character, activity)

	# Temporarily disable requirement checking for testing
	can_perform = true

	# Add tooltip with improved formatting
	var tooltip_text = create_detailed_tooltip(activity)
	button.tooltip_text = tooltip_text

	if not can_perform:
		# Gray out the button and disable it
		button.disabled = true
		button.modulate = Color(0.5, 0.5, 0.5, 1.0)
	else:
		# Connect button to dynamic handler only if character can perform it
		button.pressed.connect(func(): _on_activity_button_pressed(activity_id, ability))

	# Add button to grid container
	parent.add_child(button)

	# Store button reference for progress tracking
	button.set_meta("activity_id", activity_id)
	button.set_meta("ability", ability)
	button.set_meta("activity_name", get_activity_name_by_id(activity_id, ability))

	# Register the button with the main script
	var main_script = get_node("../")
	if main_script and main_script.has_method("register_activity_button"):
		var activity_name = get_activity_name_by_id(activity_id, ability)
		main_script.register_activity_button(activity_name, button)


func update_grid_columns(grid_container: GridContainer):
	"""Update grid columns based on available width"""
	# Check if the container is still valid
	if not grid_container or not is_instance_valid(grid_container):
		return

	# Get the available width from the scroll container
	var scroll_container = grid_container.get_parent()
	if not scroll_container or not is_instance_valid(scroll_container):
		return

	var available_width = scroll_container.size.x - 40  # 40px for margins and padding

	# Ensure we have a reasonable width
	if available_width <= 0:
		return

	# Calculate how many 200px buttons can fit (with 15px separation)
	var button_width = 200
	var separation = 15
	var columns = int((available_width + separation) / (button_width + separation))

	# Ensure at least 1 column, but not more than 8 for readability
	columns = max(1, min(columns, 8))

	# Only update if the column count has changed
	if grid_container.columns != columns:
		grid_container.columns = columns
		print("Updated grid columns to: ", columns, " (available width: ", available_width, ")")

func _on_activity_button_pressed(activity_id: String, ability: String):
	"""Handle activity button press"""
	print("Activity button pressed: ", activity_id, " (", ability, ")")
	var focused_button = get_viewport().gui_get_focus_owner()
	print("Button state before activity start - disabled: ", focused_button.disabled if focused_button else "no focus")

	# Debug: Check what activities are available
	var enhanced_activities = EnhancedActivities.new()
	var all_activities = enhanced_activities.get_all_activities()
	print("Available activities: ", all_activities.keys())
	if ability in all_activities:
		print("Activities for ", ability, ": ", all_activities[ability].keys())
	else:
		print("No activities found for ability: ", ability)

	# Get the main script to start the activity
	var main_script = get_node("../")
	if main_script and main_script.has_method("start_activity"):
		var activity_name = get_activity_name_by_id(activity_id, ability)
		print("Starting activity: ", activity_name)
		if activity_name != "":
			main_script.start_activity(activity_name)
			print("Activity started, checking button state after...")
		else:
			print("Warning: Could not find activity name for ID: ", activity_id)
	else:
		print("Error: Main script not found or start_activity method not available")

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
		# Style the button to match other activity buttons
		style_rest_button(short_rest_button)
		# Connect the button to a rest handler
		short_rest_button.pressed.connect(func(): _on_rest_button_pressed("short_rest"))
		# Register with main script for progress tracking
		var main_script = get_node("../")
		if main_script and main_script.has_method("register_activity_button"):
			main_script.register_activity_button("Short Rest", short_rest_button)

	if long_rest_button:
		# Style the button to match other activity buttons
		style_rest_button(long_rest_button)
		# Connect the button to a rest handler
		long_rest_button.pressed.connect(func(): _on_rest_button_pressed("long_rest"))
		# Register with main script for progress tracking
		var main_script = get_node("../")
		if main_script and main_script.has_method("register_activity_button"):
			main_script.register_activity_button("Long Rest", long_rest_button)

func style_rest_button(button: Button):
	"""Style rest buttons to match other activity buttons"""
	# Improve text readability
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	button.add_theme_color_override("font_hover_color", Color(1, 1, 1, 1))
	button.add_theme_color_override("font_pressed_color", Color(1, 1, 1, 1))
	button.add_theme_color_override("font_disabled_color", Color(1, 1, 1, 1))

	# Set button background colors
	button.add_theme_color_override("bg_color", Color(0.2, 0.2, 0.2, 1.0))
	button.add_theme_color_override("bg_color_hover", Color(0.3, 0.3, 0.3, 1.0))
	button.add_theme_color_override("bg_color_pressed", Color(0.4, 0.4, 0.4, 1.0))
	button.add_theme_color_override("bg_color_disabled", Color(0.1, 0.1, 0.1, 1.0))

func _on_rest_button_pressed(rest_type: String):
	"""Handle rest button press"""
	print("Rest button pressed: ", rest_type)

	# Map rest types to activity names
	var activity_name = ""
	match rest_type:
		"short_rest":
			activity_name = "Short Rest"
		"long_rest":
			activity_name = "Long Rest"

	if activity_name != "":
		# Get the main script to start the activity
		var main_script = get_node("../")
		if main_script and main_script.has_method("start_activity"):
			print("Starting rest activity: ", activity_name)
			main_script.start_activity(activity_name)
		else:
			print("Error: Main script not found or start_activity method not available")

func update_progress_bars():
	"""Update all progress bars with current activity progress"""
	# This would be called by the main script to update progress
	# Implementation would depend on how the main script tracks active activities
	pass

func create_button_content(activity: Dictionary) -> VBoxContainer:
	"""Create the content for a square activity button with integrated metadata"""
	var content_container = VBoxContainer.new()
	content_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	content_container.add_theme_constant_override("separation", 4)

	# Activity name with emoji
	var name_label = Label.new()
	var activity_name = activity.get("name", "Unknown Activity")
	var emoji = get_activity_emoji(activity)
	name_label.text = emoji + " " + activity_name
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.add_theme_color_override("font_color", Color.WHITE)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.add_theme_constant_override("outline_size", 0)
	name_label.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
	content_container.add_child(name_label)

	# Requirements with emoji
	var requirements = activity.get("requirements", {})
	if not requirements.is_empty():
		var req_label = Label.new()
		req_label.text = "🔒 " + _get_requirements_text(activity)
		req_label.add_theme_font_size_override("font_size", 12)
		req_label.add_theme_color_override("font_color", Color.YELLOW)
		req_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		req_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		req_label.add_theme_constant_override("outline_size", 0)
		req_label.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
		content_container.add_child(req_label)

	# Progress info with emoji
	var progress_label = Label.new()
	var progress_percent = int(activity.get("daily_progress", 0.0) * 100)
	progress_label.text = "📈 " + str(progress_percent) + "%/day"
	progress_label.add_theme_font_size_override("font_size", 12)
	progress_label.add_theme_color_override("font_color", Color.CYAN)
	progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	progress_label.add_theme_constant_override("outline_size", 0)
	progress_label.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
	content_container.add_child(progress_label)

	# Cost/Reward info with emoji
	var cost_label = Label.new()
	var cost = activity.get("cost_per_day", 0.0)
	if cost > 0:
		cost_label.text = "💰 " + str(cost) + " gp/day"
		cost_label.add_theme_color_override("font_color", Color.RED)
	else:
		cost_label.text = "💵 Earns money"
		cost_label.add_theme_color_override("font_color", Color.GREEN)
	cost_label.add_theme_font_size_override("font_size", 12)
	cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cost_label.add_theme_constant_override("outline_size", 0)
	cost_label.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
	content_container.add_child(cost_label)

	# Rewards with emoji
	var rewards = activity.get("rewards", {})
	if not rewards.is_empty():
		var rewards_label = Label.new()
		rewards_label.text = "🎁 " + _get_rewards_text(rewards)
		rewards_label.add_theme_font_size_override("font_size", 11)
		rewards_label.add_theme_color_override("font_color", Color.LIGHT_GREEN)
		rewards_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		rewards_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		rewards_label.add_theme_constant_override("outline_size", 0)
		rewards_label.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
		content_container.add_child(rewards_label)

	return content_container

func get_activity_emoji(activity: Dictionary) -> String:
	"""Get an appropriate emoji for the activity based on its type or name"""
	var activity_name = activity.get("name", "").to_lower()
	var _description = activity.get("description", "").to_lower()

	# Check for specific activity types
	if "training" in activity_name or "practice" in activity_name:
		return "🏋️"
	elif "study" in activity_name or "research" in activity_name or "learn" in activity_name:
		return "📚"
	elif "craft" in activity_name or "smith" in activity_name or "forge" in activity_name:
		return "🔨"
	elif "hunt" in activity_name or "track" in activity_name:
		return "🏹"
	elif "meditate" in activity_name or "pray" in activity_name:
		return "🧘"
	elif "perform" in activity_name or "entertain" in activity_name:
		return "🎭"
	elif "trade" in activity_name or "merchant" in activity_name:
		return "💼"
	elif "explore" in activity_name or "adventure" in activity_name:
		return "🗺️"
	elif "rest" in activity_name or "sleep" in activity_name:
		return "😴"
	elif "eat" in activity_name or "drink" in activity_name:
		return "🍽️"
	elif "magic" in activity_name or "spell" in activity_name:
		return "✨"
	elif "combat" in activity_name or "fight" in activity_name:
		return "⚔️"
	else:
		# Default emoji based on ability type
		return "⭐"

func create_activity_metadata(activity: Dictionary) -> VBoxContainer:
	"""Create metadata display for an activity"""
	var metadata_container = VBoxContainer.new()
	metadata_container.add_theme_constant_override("separation", 2)

	# Requirements display
	var requirements = activity.get("requirements", {})
	if not requirements.is_empty():
		var req_label = Label.new()
		req_label.text = "Req: " + _get_requirements_text(activity)
		req_label.add_theme_font_size_override("font_size", 10)
		req_label.add_theme_color_override("font_color", Color.YELLOW)
		req_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		metadata_container.add_child(req_label)

	# Progress and cost info
	var info_container = HBoxContainer.new()

	# Daily progress
	var progress_label = Label.new()
	var progress_percent = int(activity.get("daily_progress", 0.0) * 100)
	progress_label.text = str(progress_percent) + "%/day"
	progress_label.add_theme_font_size_override("font_size", 10)
	progress_label.add_theme_color_override("font_color", Color.CYAN)
	info_container.add_child(progress_label)

	# Cost info
	var cost_label = Label.new()
	var cost = activity.get("cost_per_day", 0.0)
	if cost > 0:
		cost_label.text = str(cost) + " gp/day"
		cost_label.add_theme_color_override("font_color", Color.RED)
	else:
		cost_label.text = "Earns money"
		cost_label.add_theme_color_override("font_color", Color.GREEN)
	cost_label.add_theme_font_size_override("font_size", 10)
	info_container.add_child(cost_label)

	metadata_container.add_child(info_container)

	# Rewards display
	var rewards = activity.get("rewards", {})
	if not rewards.is_empty():
		var rewards_label = Label.new()
		rewards_label.text = _get_rewards_text(rewards)
		rewards_label.add_theme_font_size_override("font_size", 10)
		rewards_label.add_theme_color_override("font_color", Color.LIGHT_GREEN)
		rewards_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		metadata_container.add_child(rewards_label)

	return metadata_container


func create_detailed_tooltip(activity: Dictionary) -> String:
	"""Create a detailed tooltip with all activity information"""
	var emoji = get_activity_emoji(activity)
	var tooltip = emoji + " " + activity.get("name", "Unknown Activity")

	# Add separator line
	tooltip += "\n" + "──────────────────────────────"

	# Add description
	var description = activity.get("description", "")
	if description != "":
		tooltip += "\n\nDESCRIPTION:\n" + description

	# Add requirements
	var requirements_text = _get_requirements_text(activity)
	if requirements_text != "":
		tooltip += "\n\nREQUIREMENTS:\n" + requirements_text

	# Add progress info
	var progress_percent = int(activity.get("daily_progress", 0.0) * 100)
	tooltip += "\n\nDAILY PROGRESS:\n" + str(progress_percent) + "% per day"

	# Add cost info
	var cost = activity.get("cost_per_day", 0.0)
	if cost > 0:
		tooltip += "\n\nDAILY COST:\n" + str(cost) + " gp per day"
	else:
		tooltip += "\n\nEARNINGS:\nEarns money"

	# Add rewards
	var rewards = activity.get("rewards", {})
	if not rewards.is_empty():
		tooltip += "\n\nREWARDS:\n" + _get_rewards_text(rewards)

	return tooltip

func _get_rewards_text(rewards: Dictionary) -> String:
	"""Format rewards into a readable string"""
	var reward_parts = []

	for reward_type in rewards.keys():
		var value = rewards[reward_type]
		match reward_type:
			"xp":
				reward_parts.append(str(value) + " XP")
			"gold":
				reward_parts.append(str(value) + " gp")
			"items":
				if value is Array:
					for item in value:
						reward_parts.append(item)
				else:
					reward_parts.append(str(value))
			"ability_increase":
				if value is Dictionary:
					for ability in value.keys():
						var increase = value[ability]
						reward_parts.append("+" + str(increase) + " " + ability.capitalize())
			_:
				reward_parts.append(str(value) + " " + reward_type)

	return ", ".join(reward_parts)
