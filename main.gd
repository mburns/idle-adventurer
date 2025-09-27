extends Control

@onready var coins_value_text = %CoinsValueText
@onready var character_name_label = %CharacterNameLabel
@onready var character_level_label = %CharacterLevelLabel
@onready var character_class_label = %CharacterClassLabel
@onready var current_activity_label = %CurrentActivityLabel
@onready var activity_progress_bar = %ActivityProgressBar

var character: Character
var active_button: Button = null
var activity_buttons: Dictionary = {} # activity_name -> button
var enhanced_activities: EnhancedActivities
# DebugConfig is available as autoload

# Called when the node enters the scene tree for the first time.
func _ready():
	# Debug configuration is now available as autoload

	# Wait a frame to ensure all autoloads are ready
	await get_tree().process_frame

	# Connect to character manager signals
	CharacterManager.character_changed.connect(_on_character_changed)

	# Load character or create default
	if CharacterManager.has_save_file():
		CharacterManager.load_character()
	else:
		CharacterManager.create_default_character()

	character = CharacterManager.get_current_character()
	# DebugConfig.debug_character_msg("Character loaded: " + (character.name if character else "None"))
	# if character:
	#	DebugConfig.debug_character_msg("Character XP: " + str(character.experience_points) + ", Level: " + str(character.level))

	# Wait for dynamic UI to be created
	await get_tree().process_frame
	await get_tree().process_frame

	# Initialize EnhancedActivities after autoloads are ready
	enhanced_activities = EnhancedActivities.new()
	add_child(enhanced_activities)

	# Wait for EnhancedActivities to be ready
	await get_tree().process_frame
	await get_tree().process_frame

	# setup_button_progress_bars()  # Disabled - dynamic UI handles progress bar creation and registration
	# setup_dynamic_button_connections()  # Disabled - dynamic UI handles button connections

	# Test: Start an activity automatically to see if the system works
	DebugConfig.debug_activities_msg("Testing activity system by starting Blacksmithing...")
	# Give character enough gold for testing
	character.add_gold(50)
	DebugConfig.debug_character_msg("Character gold: " + str(character.gold))
	print("DEBUG: Starting activity 'Blacksmithing'")
	var result = start_activity("Blacksmithing")
	print("DEBUG: Activity start result: ", result)

	DebugConfig.debug_ui_msg("Main ready complete - character: " + (character.name if character else "None") + ", enhanced_activities: " + str(enhanced_activities != null) + ", progress_bar: " + str(activity_progress_bar != null))

	# Configure progress bar if it exists
	if activity_progress_bar:
		activity_progress_bar.min_value = 0
		activity_progress_bar.max_value = 100
		activity_progress_bar.value = 0
		print("DEBUG: Progress bar configured - min: ", activity_progress_bar.min_value, ", max: ", activity_progress_bar.max_value)

	update_ui()


func register_activity_button(activity_name: String, button: Button):
	"""Register an activity button for progress tracking"""
	# print("Registering activity button for: ", activity_name)
	activity_buttons[activity_name] = button
	# Set initial button styling
	button.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	button.add_theme_color_override("font_hover_color", Color(1, 1, 1, 1))
	button.add_theme_color_override("font_pressed_color", Color(1, 1, 1, 1))
	button.add_theme_color_override("font_disabled_color", Color(1, 1, 1, 1))

	# Set button background colors
	button.add_theme_color_override("bg_color", Color(0.2, 0.2, 0.2, 1.0))
	button.add_theme_color_override("bg_color_hover", Color(0.3, 0.3, 0.3, 1.0))
	button.add_theme_color_override("bg_color_pressed", Color(0.4, 0.4, 0.4, 1.0))
	button.add_theme_color_override("bg_color_disabled", Color(0.1, 0.1, 0.1, 1.0))

	# print("Activity button registered. Total buttons: ", activity_buttons.size())
	# print("Available buttons: ", activity_buttons.keys())


func setup_dynamic_button_connections():
	"""Automatically connect activity buttons to the dynamic handler"""
	# Get all activities from JSON data to know which buttons to look for
	var enhanced_activities_instance = EnhancedActivities.new()
	var all_activities = enhanced_activities_instance.get_all_activities()

	# Find and connect all activity buttons
	_connect_activity_buttons_recursively(self, all_activities)

func _connect_activity_buttons_recursively(node: Node, all_activities: Dictionary):
	"""Recursively find and connect activity buttons"""
	if node is Button:
		# Check if this button corresponds to an activity
		var activity_name = _find_activity_name_for_button(node.name)
		if activity_name != "":
			# Connect the button to our dynamic handler
			if not node.pressed.is_connected(_on_activity_button_pressed):
				node.pressed.connect(func(): _on_activity_button_pressed(node.name))
				print("Connected button '", node.name, "' to activity '", activity_name, "'")

	# Recursively search children
	for child in node.get_children():
		_connect_activity_buttons_recursively(child, all_activities)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if character != null and enhanced_activities != null:
		# Update activity progress
		update_activity_progress()

# Update UI elements
func update_ui():
	if character == null:
		return

	# Update character info
	if character_name_label:
		character_name_label.text = character.name
	if character_level_label:
		character_level_label.text = "Level %d" % character.level
	if character_class_label:
		character_class_label.text = "%s %s" % [character.race, character.character_class]

	# Update coins
	if coins_value_text:
		coins_value_text.text = str(character.gold)

	# Update current activity
	if current_activity_label:
		# Get current activity from EnhancedActivities
		if enhanced_activities != null:
			var active_activities = enhanced_activities.active_activities

			if character.name in active_activities:
				var activity_data = active_activities[character.name]
				var activity_name = activity_data.get("name", "")
				current_activity_label.text = "Currently: %s" % activity_name
			else:
				current_activity_label.text = "Idle"
		else:
			current_activity_label.text = "Idle"

	# Update level progress
	update_level_progress()

# Update activity progress bar
func update_activity_progress():
	if character == null or enhanced_activities == null:
		DebugConfig.debug_ui_msg("update_activity_progress - character or enhanced_activities is null")
		return

	# Get active activities from EnhancedActivities
	var active_activities = enhanced_activities.active_activities
	print("DEBUG: Active activities: ", active_activities.keys())
	print("DEBUG: Character name: ", character.name)

	if character in active_activities:
		var activity_data = active_activities[character]
		var activity_name = activity_data.get("name", "")
		var progress = activity_data.get("progress", 0.0)

		# DebugConfig.debug_activities_msg("Activity progress for " + character.name + " - " + activity_name + ": " + str(progress))

		# Update the button background for the current activity
		# print("DEBUG: Looking for activity_name '", activity_name, "' in activity_buttons: ", activity_buttons.keys())
		if activity_name in activity_buttons:
			var button = activity_buttons[activity_name]
			if button:
				# Create a progress bar overlay
				var progress_bar = button.get_node_or_null("ProgressOverlay")
				if not progress_bar:
					# Create progress bar overlay
					progress_bar = ColorRect.new()
					progress_bar.name = "ProgressOverlay"
					progress_bar.color = Color(0.0, 1.0, 0.0, 0.6)  # Green with transparency
					button.add_child(progress_bar)

					# Position it to cover the button
					progress_bar.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
					progress_bar.offset_left = 2
					progress_bar.offset_top = 2
					progress_bar.offset_right = -2
					progress_bar.offset_bottom = -2

				# Update progress bar width
				var button_width = button.size.x
				progress_bar.size.x = button_width * progress
				progress_bar.position.x = 0
				print("Updated button progress bar for " + activity_name + " - width: " + str(progress_bar.size.x))
	else:
		print("No active activity for character: " + character.name)

	# Update the main progress bar to show level progress
	update_level_progress()

func update_level_progress():
	"""Update the main progress bar to show level progress"""
	if character == null or not activity_progress_bar:
		DebugConfig.debug_ui_msg("update_level_progress - character or progress bar is null")
		return

	# Calculate level progress (assuming 1000 XP per level)
	var current_level_xp = character.experience_points % 1000
	var level_progress = float(current_level_xp) / 1000.0
	var progress_value = level_progress * 100

	DebugConfig.debug_ui_msg("Level progress - XP: " + str(character.experience_points) + ", Level XP: " + str(current_level_xp) + ", Progress: " + str(level_progress) + ", Value: " + str(progress_value))
	DebugConfig.debug_ui_msg("Progress bar min: " + str(activity_progress_bar.min_value) + ", max: " + str(activity_progress_bar.max_value) + ", current value: " + str(activity_progress_bar.value))

	activity_progress_bar.value = progress_value
	DebugConfig.debug_ui_msg("Progress bar value after setting: " + str(activity_progress_bar.value))

# Handle character changes
func _on_character_changed(new_character: Character):
	character = new_character
	update_ui()

# Button handlers
func _on_grant_coins_button_pressed():
	if character != null:
		character.add_gold(1)
		update_ui()

# Start an activity
func start_activity(activity_name: String):
	print("DEBUG: start_activity called with: '", activity_name, "'")
	if character != null:
		print("DEBUG: Character is available: ", character.name)
		# Clear all button progress bars
		clear_all_button_progress()

		# Use EnhancedActivities to start the activity
		if enhanced_activities != null:
			print("DEBUG: EnhancedActivities is available, calling start_activity")
			var result = enhanced_activities.start_activity(character, activity_name, "general")
			if result:
				print("DEBUG: Activity started successfully: ", activity_name)
				update_ui()
			else:
				print("DEBUG: Failed to start activity: ", activity_name)
		else:
			print("DEBUG: EnhancedActivities not initialized!")
	else:
		print("DEBUG: Character is null!")

func clear_all_button_progress():
	"""Clear progress from all activity buttons"""
	for activity_name in activity_buttons.keys():
		var button = activity_buttons[activity_name]
		if button:
			# Remove progress overlay
			var progress_bar = button.get_node_or_null("ProgressOverlay")
			if progress_bar:
				progress_bar.queue_free()
			# Reset button to normal appearance
			button.modulate = Color(1.0, 1.0, 1.0, 1.0)

func clear_activity_progress(activity_name: String):
	"""Clear progress from a specific activity's button"""
	if activity_name in activity_buttons:
		var button = activity_buttons[activity_name]
		if button:
			# Remove progress overlay
			var progress_bar = button.get_node_or_null("ProgressOverlay")
			if progress_bar:
				progress_bar.queue_free()
			# Reset button to normal appearance
			button.modulate = Color(1.0, 1.0, 1.0, 1.0)
			print("Cleared button progress for: ", activity_name)

# Get character for other scripts
func get_character() -> Character:
	return character

# Navigation button handlers
func _on_character_profile_button_pressed():
	get_tree().change_scene_to_file("res://scenes/character_profile.tscn")

func _on_equipment_button_pressed():
	get_tree().change_scene_to_file("res://scenes/equipment_screen.tscn")

func _on_journal_button_pressed():
	get_tree().change_scene_to_file("res://scenes/journal_screen.tscn")

func _on_activities_button_pressed():
	# Activities are now integrated into main screen - no separate navigation needed
	print("Activities are now integrated into the main screen")

func _on_general_store_button_pressed():
	get_tree().change_scene_to_file("res://scenes/general_store_screen.tscn")

func _on_inventory_button_pressed():
	get_tree().change_scene_to_file("res://scenes/inventory_screen.tscn")

func _on_monster_glossary_button_pressed():
	get_tree().change_scene_to_file("res://scenes/monster_glossary_screen.tscn")

func _on_leveling_button_pressed():
	get_tree().change_scene_to_file("res://scenes/leveling_screen.tscn")

func _on_settings_button_pressed():
	get_tree().change_scene_to_file("res://scenes/settings_screen.tscn")

func _on_character_display_button_pressed():
	get_tree().change_scene_to_file("res://scenes/character_display.tscn")

func _on_character_sheet_button_pressed():
	get_tree().change_scene_to_file("res://scenes/character_sheet.tscn")

func _on_faction_button_pressed():
	get_tree().change_scene_to_file("res://scenes/faction_screen.tscn")

func _on_achievements_button_pressed():
	get_tree().change_scene_to_file("res://scenes/achievements_screen.tscn")

func _on_spellbook_button_pressed():
	get_tree().change_scene_to_file("res://scenes/spellbook_screen.tscn")

# Dynamic activity button handler - replaces all individual handlers!
func _on_activity_button_pressed(button_name: String):
	"""Dynamic handler for all activity button presses"""
	var activity_name = _find_activity_name_for_button(button_name)
	if activity_name != "":
		start_activity(activity_name)
	else:
		print("Warning: Could not find activity for button: ", button_name)

func _find_activity_name_for_button(button_name: String) -> String:
	"""Find the activity name that corresponds to a button name"""
	# Get all activities from JSON data
	var enhanced_activities_instance = EnhancedActivities.new()
	var all_activities = enhanced_activities_instance.get_all_activities()

	# Clean the button name for matching
	var clean_button_name = button_name.replace("_", " ").to_lower()

	# Search through all activities to find a match
	for ability in all_activities.keys():
		for activity_id in all_activities[ability].keys():
			var activity_data = all_activities[ability][activity_id]
			var activity_name = activity_data.get("name", "")
			var clean_activity_name = activity_name.replace(" ", " ").to_lower()

			# Try exact match first
			if clean_button_name == clean_activity_name:
				return activity_name

			# Try partial match (remove common prefixes/suffixes)
			var button_words = clean_button_name.split(" ")
			var activity_words = clean_activity_name.split(" ")

			# Check if button name is contained in activity name
			if _is_button_name_in_activity_name(button_words, activity_words):
				return activity_name

	return ""

func _is_button_name_in_activity_name(button_words: Array, activity_words: Array) -> bool:
	"""Check if button name words are contained in activity name"""
	for button_word in button_words:
		var found = false
		for activity_word in activity_words:
			if button_word == activity_word or activity_word.begins_with(button_word):
				found = true
				break
		if not found:
			return false
	return true
