extends Control

@onready var coins_value_text = %CoinsValueText
@onready var character_name_label = %CharacterNameLabel
@onready var character_level_label = %CharacterLevelLabel
@onready var character_class_label = %CharacterClassLabel
@onready var current_activity_label = %CurrentActivityLabel
@onready var activity_progress_bar = %ActivityProgressBar

var character: Character
var active_button: Button = null
var button_progress_bars: Dictionary = {} # activity_name -> progress_bar

# Called when the node enters the scene tree for the first time.
func _ready():
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

	# Wait for dynamic UI to be created
	await get_tree().process_frame
	await get_tree().process_frame

	# setup_button_progress_bars()  # Disabled - dynamic UI handles progress bar creation and registration
	# setup_dynamic_button_connections()  # Disabled - dynamic UI handles button connections
	update_ui()

func setup_button_progress_bars():
	"""Setup progress bars dynamically from JSON data - no more hardcoded mappings!"""
	# Clear existing progress bars
	button_progress_bars.clear()

	# Get all activities from the enhanced activities system
	var enhanced_activities = EnhancedActivities.new()
	var all_activities = enhanced_activities.get_all_activities()

	# Find progress bars dynamically by searching for nodes with "ProgressBar" in their name
	_find_progress_bars_recursively(self, all_activities)

	# Style all found progress bars
	print("Found ", button_progress_bars.size(), " progress bars")
	for activity_name in button_progress_bars.keys():
		var progress_bar = button_progress_bars[activity_name]
		if progress_bar and is_instance_valid(progress_bar):
			print("Setting up progress bar for: ", activity_name)
			# Style the progress bar to be more visible
			progress_bar.add_theme_color_override("background_color", Color(0.2, 0.2, 0.2, 1.0))
			progress_bar.add_theme_color_override("fill_color", Color(0.0, 0.8, 0.0, 1.0))
			# Make sure the progress bar is visible
			progress_bar.visible = true
			progress_bar.modulate = Color(1.0, 1.0, 1.0, 1.0) # Fully opaque
			# Start with empty progress bar
			progress_bar.value = 0.0

func _find_progress_bars_recursively(node: Node, all_activities: Dictionary):
	"""Recursively find progress bar nodes and match them to activities"""
	if node is ProgressBar:
		print("Found ProgressBar: ", node.name)
		# Try to match this progress bar to an activity
		var activity_name = _match_progress_bar_to_activity(node, all_activities)
		if activity_name != "":
			print("Matched progress bar to activity: ", activity_name)
			button_progress_bars[activity_name] = node
		else:
			print("Could not match progress bar: ", node.name)

	# Recursively search children
	for child in node.get_children():
		_find_progress_bars_recursively(child, all_activities)

func register_progress_bar(activity_name: String, progress_bar: ProgressBar):
	"""Register a progress bar created by the dynamic UI"""
	print("Registering progress bar for activity: ", activity_name)
	button_progress_bars[activity_name] = progress_bar
	# Style the progress bar
	progress_bar.add_theme_color_override("background_color", Color(0.2, 0.2, 0.2, 1.0))
	progress_bar.add_theme_color_override("fill_color", Color(0.0, 0.8, 0.0, 1.0))
	progress_bar.modulate = Color(1.0, 1.0, 1.0, 1.0)
	progress_bar.visible = true
	progress_bar.value = 0.0
	print("Progress bar registered. Total progress bars: ", button_progress_bars.size())

func _match_progress_bar_to_activity(progress_bar: ProgressBar, all_activities: Dictionary) -> String:
	"""Try to match a progress bar node to an activity name"""
	var node_name = progress_bar.name

	# Remove "ProgressBar" suffix if present
	var activity_name = node_name.replace("ProgressBar", "")

	# Check if this matches any activity name in our data
	for ability in all_activities.keys():
		for activity_id in all_activities[ability].keys():
			var activity_data = all_activities[ability][activity_id]
			var activity_name_from_data = activity_data.get("name", "")

			# Try exact match first
			if activity_name == activity_name_from_data:
				return activity_name_from_data

			# Try partial match (remove spaces, special chars)
			var clean_activity_name = activity_name.replace(" ", "").replace("_", "").to_lower()
			var clean_data_name = activity_name_from_data.replace(" ", "").replace("_", "").to_lower()

			if clean_activity_name == clean_data_name:
				return activity_name_from_data

	return ""

func setup_dynamic_button_connections():
	"""Automatically connect activity buttons to the dynamic handler"""
	# Get all activities from JSON data to know which buttons to look for
	var enhanced_activities = EnhancedActivities.new()
	var all_activities = enhanced_activities.get_all_activities()

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
	if character != null:
		# Check if current activity is complete
		if character.is_activity_complete():
			var rewards = IdleMechanics.complete_activity(character)
			if rewards.xp > 0 or rewards.gold > 0:
				print("Activity completed! Gained %d XP and %d gold" % [rewards.xp, rewards.gold])

			# Restart the same activity automatically
			if character.current_activity != "":
				var activity_name = character.current_activity
				clear_all_button_progress()
				IdleMechanics.start_activity(activity_name, character)

			update_ui()
		else:
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
		if character.current_activity != "":
			current_activity_label.text = "Currently: %s" % character.current_activity
		else:
			current_activity_label.text = "Idle"

	# Update level progress
	update_level_progress()

# Update activity progress bar
func update_activity_progress():
	if character == null or character.current_activity == "":
		return

	var time_remaining = character.get_activity_time_remaining()
	var total_duration = character.activity_duration
	var progress = 1.0 - (time_remaining / total_duration)

	# Update the button progress bar for the current activity
	if character.current_activity in button_progress_bars:
		var progress_bar = button_progress_bars[character.current_activity]
		if progress_bar:
			progress_bar.value = progress
			print("Updated progress bar for ", character.current_activity, " to ", progress)
	else:
		print("No progress bar found for activity: ", character.current_activity)
		print("Available progress bars: ", button_progress_bars.keys())

	# Update the main progress bar to show level progress
	update_level_progress()

func update_level_progress():
	"""Update the main progress bar to show level progress"""
	if character == null or not activity_progress_bar:
		return

	# Calculate level progress (assuming 1000 XP per level)
	var current_level_xp = character.experience_points % 1000
	var level_progress = float(current_level_xp) / 1000.0
	activity_progress_bar.value = level_progress * 100

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
	if character != null:
		# Clear all button progress bars
		clear_all_button_progress()

		if IdleMechanics.start_activity(activity_name, character):
			update_ui()

func clear_all_button_progress():
	"""Clear progress from all button progress bars"""
	for activity_name in button_progress_bars.keys():
		var progress_bar = button_progress_bars[activity_name]
		if progress_bar:
			progress_bar.value = 0.0

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
	get_tree().change_scene_to_file("res://scenes/activities_screen.tscn")

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
	var enhanced_activities = EnhancedActivities.new()
	var all_activities = enhanced_activities.get_all_activities()

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
