extends Node

# Activity button creation and styling system
# Handles creation, styling, and content generation for activity buttons

class_name ActivityButtonCreator

# Ability icons mapping
var ability_icons: Dictionary = {
	"strength": "💪",
	"dexterity": "🏃",
	"intelligence": "🧠",
	"wisdom": "🦉",
	"charisma": "😎",
	"constitution": "🫀",
	"general": "🌍"
}

# Create an activity button
func create_activity_button(_parent: GridContainer, ability: String, activity_id: String, activity: Dictionary) -> Button:
	var button = Button.new()
	button.custom_minimum_size = Vector2(200, 120)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.size_flags_vertical = Control.SIZE_EXPAND_FILL

	# Create button content
	var content = create_button_content(activity)
	button.add_child(content)

	# Style the button
	style_activity_button(button, activity)

	# Connect button press
	button.pressed.connect(_on_activity_button_pressed.bind(activity_id, ability))

	# Add tooltip
	var tooltip = create_detailed_tooltip(activity)
	button.tooltip_text = tooltip

	return button

# Create button content (title, emoji, metadata)
func create_button_content(activity: Dictionary) -> VBoxContainer:
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 4)

	# Activity name
	var name_label = Label.new()
	name_label.text = activity.get("name", "Unknown Activity")
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 12)
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(name_label)

	# Activity emoji
	var emoji_label = Label.new()
	emoji_label.text = get_activity_emoji(activity)
	emoji_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	emoji_label.add_theme_font_size_override("font_size", 24)
	vbox.add_child(emoji_label)

	# Activity metadata (duration, requirements, etc.)
	var metadata = create_activity_metadata(activity)
	vbox.add_child(metadata)

	return vbox

# Create activity metadata display
func create_activity_metadata(activity: Dictionary) -> VBoxContainer:
	var metadata_vbox = VBoxContainer.new()
	metadata_vbox.add_theme_constant_override("separation", 2)

	# Duration
	var duration = activity.get("duration", 0)
	if duration > 0:
		var duration_label = Label.new()
		duration_label.text = "⏱️ " + format_duration(duration)
		duration_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		duration_label.add_theme_font_size_override("font_size", 10)
		metadata_vbox.add_child(duration_label)

	# Requirements indicator
	var requirements = activity.get("requirements", {})
	if not requirements.is_empty():
		var req_label = Label.new()
		req_label.text = "📋 Requirements"
		req_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		req_label.add_theme_font_size_override("font_size", 9)
		req_label.modulate = Color(0.8, 0.8, 0.8)
		metadata_vbox.add_child(req_label)

	# Rewards indicator
	var rewards = activity.get("rewards", {})
	if not rewards.is_empty():
		var reward_label = Label.new()
		reward_label.text = "🎁 Rewards"
		reward_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		reward_label.add_theme_font_size_override("font_size", 9)
		reward_label.modulate = Color(0.8, 1.0, 0.8)
		metadata_vbox.add_child(reward_label)

	return metadata_vbox

# Style activity button based on activity properties
func style_activity_button(button: Button, activity: Dictionary) -> void:
	# Base styling
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color.WHITE)

	# Color based on activity type or rarity
	var _activity_type = activity.get("type", "general")
	var rarity = activity.get("rarity", "common")

	match rarity:
		"common":
			button.modulate = Color(0.9, 0.9, 0.9)
		"uncommon":
			button.modulate = Color(0.8, 1.0, 0.8)
		"rare":
			button.modulate = Color(0.8, 0.8, 1.0)
		"epic":
			button.modulate = Color(1.0, 0.8, 1.0)
		"legendary":
			button.modulate = Color(1.0, 1.0, 0.8)

	# Add border for special activities
	if activity.get("special", false):
		button.add_theme_constant_override("border_width", 2)
		button.add_theme_color_override("border_color", Color.GOLD)

# Get activity emoji based on activity data
func get_activity_emoji(activity: Dictionary) -> String:
	# Check for explicit emoji
	var emoji = activity.get("emoji", "")
	if emoji != "":
		return emoji

	# Check for activity type
	var activity_type = activity.get("type", "")
	match activity_type:
		"combat":
			return "⚔️"
		"exploration":
			return "🗺️"
		"social":
			return "💬"
		"crafting":
			return "🔨"
		"magic":
			return "✨"
		"rest":
			return "😴"
		"training":
			return "💪"
		"research":
			return "📚"
		"trade":
			return "💰"
		"adventure":
			return "🗡️"
		_:
			return "⭐"

# Create detailed tooltip for activity
func create_detailed_tooltip(activity: Dictionary) -> String:
	var tooltip = ""

	# Activity name
	tooltip += activity.get("name", "Unknown Activity") + "\n\n"

	# Description
	var description = activity.get("description", "")
	if description != "":
		tooltip += description + "\n\n"

	# Duration
	var duration = activity.get("duration", 0)
	if duration > 0:
		tooltip += "Duration: " + format_duration(duration) + "\n"

	# Requirements
	var requirements = activity.get("requirements", {})
	if not requirements.is_empty():
		tooltip += "\nRequirements:\n"
		tooltip += _get_requirements_text(requirements)

	# Rewards
	var rewards = activity.get("rewards", {})
	if not rewards.is_empty():
		tooltip += "\nRewards:\n"
		tooltip += _get_rewards_text(rewards)

	# Activity type and rarity
	var activity_type = activity.get("type", "general")
	var rarity = activity.get("rarity", "common")
	tooltip += "\nType: " + activity_type.capitalize()
	tooltip += "\nRarity: " + rarity.capitalize()

	return tooltip

# Format duration in human-readable format
func format_duration(seconds: int) -> String:
	if seconds < 60:
		return str(seconds) + "s"
	elif seconds < 3600:
		var minutes = int(seconds / 60)
		return str(minutes) + "m"
	else:
		var hours = int(seconds / 3600)
		var minutes = int((seconds % 3600) / 60)
		if minutes > 0:
			return str(hours) + "h " + str(minutes) + "m"
		else:
			return str(hours) + "h"

# Get requirements text for tooltip
func _get_requirements_text(requirements: Dictionary) -> String:
	var text = ""

	for req_type in requirements:
		var req_value = requirements[req_type]
		match req_type:
			"level":
				text += "• Level " + str(req_value) + "\n"
			"gold":
				text += "• " + str(req_value) + " gold\n"
			"items":
				if req_value is Array:
					for item in req_value:
						text += "• " + str(item) + "\n"
				else:
					text += "• " + str(req_value) + "\n"
			"skills":
				if req_value is Array:
					for skill in req_value:
						text += "• " + str(skill) + " proficiency\n"
				else:
					text += "• " + str(req_value) + " proficiency\n"
			_:
				text += "• " + str(req_type) + ": " + str(req_value) + "\n"

	return text

# Get rewards text for tooltip
func _get_rewards_text(rewards: Dictionary) -> String:
	var text = ""

	for reward_type in rewards:
		var reward_value = rewards[reward_type]
		match reward_type:
			"experience":
				text += "• " + str(reward_value) + " XP\n"
			"gold":
				text += "• " + str(reward_value) + " gold\n"
			"items":
				if reward_value is Array:
					for item in reward_value:
						text += "• " + str(item) + "\n"
				else:
					text += "• " + str(reward_value) + "\n"
			"reputation":
				if reward_value is Dictionary:
					for faction in reward_value:
						text += "• " + str(reward_value[faction]) + " " + str(faction) + " reputation\n"
				else:
					text += "• " + str(reward_value) + " reputation\n"
			_:
				text += "• " + str(reward_type) + ": " + str(reward_value) + "\n"

	return text

# Signal handler for activity button press
func _on_activity_button_pressed(activity_id: String, ability: String) -> void:
	print("Activity button pressed: " + activity_id + " (" + ability + ")")

	# Get character
	var character = get_character()
	if character == null:
		print("No character available")
		return

	# Get activity data
	var activity_data = {}
	if Engine.has_singleton("DataLoader"):
		var data_loader = Engine.get_singleton("DataLoader")
		activity_data = data_loader.get_activity_data(activity_id)

	if activity_data.is_empty():
		print("Activity data not found: " + activity_id)
		return

	# Check requirements
	if not _check_activity_requirements(character, activity_data):
		print("Activity requirements not met")
		return

	# Start activity
	var enhanced_activities = get_node("/root/EnhancedActivities")
	if enhanced_activities:
		enhanced_activities.start_activity(character.name, activity_id, ability)
	else:
		print("EnhancedActivities not found")

# Get current character
func get_character() -> Character:
	# Try to access AutoloadManager, fallback to null if not available
	var autoload_manager = null
	if Engine.has_singleton("AutoloadManager"):
		autoload_manager = Engine.get_singleton("AutoloadManager")

	if autoload_manager and autoload_manager.character_manager:
		return autoload_manager.character_manager.get_current_character()
	return null

# Check if character meets activity requirements
func _check_activity_requirements(character: Character, activity: Dictionary) -> bool:
	var requirements = activity.get("requirements", {})

	# Check level requirement
	if requirements.has("level"):
		if character.level < requirements["level"]:
			return false

	# Check gold requirement
	if requirements.has("gold"):
		if character.gold < requirements["gold"]:
			return false

	# Check item requirements
	if requirements.has("items"):
		var required_items = requirements["items"]
		if required_items is Array:
			for item in required_items:
				# This would check if character has the item
				# For now, just return true
				pass

	# Check skill requirements
	if requirements.has("skills"):
		var required_skills = requirements["skills"]
		if required_skills is Array:
			for skill in required_skills:
				if skill not in character.skill_proficiencies:
					return false

	return true
