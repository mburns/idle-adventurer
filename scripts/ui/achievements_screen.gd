extends Control

# Dictionarys screen for displaying character achievements

signal achievement_selected(achievement: Dictionary)

var character: Character
var achievement_system: AchievementSystem
var achievement_buttons: Array[Button] = []

func _ready():
	# Apply theme
	ThemeManager.apply_theme_to_children(self)

	# Get character and achievement system
	character = CharacterManager.current_character
	achievement_system = AchievementSystem.new()

	if character:
		load_achievements()
	else:
		print("No character selected for achievements screen")

func load_achievements():
	"""Load and display achievements for the current character"""
	if not character:
		return

	# Clear existing achievement buttons
	clear_achievement_buttons()

	# Get character achievements
	var achievements = achievement_system.get_character_achievements(character)
	var unlocked_achievements = achievement_system.get_unlocked_achievements(character)

	# Update statistics
	update_statistics(unlocked_achievements.size(), achievements.size())

	# Create achievement buttons
	create_achievement_buttons(achievements)

func clear_achievement_buttons():
	"""Clear all existing achievement buttons"""
	var _container = %DictionaryContainer
	for button in achievement_buttons:
		if button and is_instance_valid(button):
			button.queue_free()
	achievement_buttons.clear()

func create_achievement_buttons(achievements: Dictionary):
	"""Create buttons for all achievements"""
	var _container = %DictionaryContainer

	# Sort achievements by category and rarity
	var sorted_achievements = []
	for achievement in achievements.values():
		sorted_achievements.append(achievement)

	sorted_achievements.sort_custom(func(a, b): return compare_achievements(a, b))

	for achievement in sorted_achievements:
		var button = create_achievement_button(achievement)
		_container.add_child(button)
		achievement_buttons.append(button)

func create_achievement_button(achievement: Dictionary) -> Button:
	"""Create a button for a specific achievement"""
	var button = Button.new()
	button.custom_minimum_size = Vector2(0, 80)
	button.text = ""
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT

	# Create achievement content
	var content = create_achievement_content(achievement)
	button.add_child(content)

	# Style based on unlock status
	if achievement.unlocked:
		style_unlocked_achievement(button, achievement)
	else:
		style_locked_achievement(button, achievement)

	# Connect signal
	button.pressed.connect(func(): select_achievement(achievement))

	return button

func create_achievement_content(achievement: Dictionary) -> Control:
	"""Create the content for an achievement button"""
	var container = HBoxContainer.new()
	container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Dictionary icon
	var icon = TextureRect.new()
	icon.custom_minimum_size = Vector2(60, 60)
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	if achievement.unlocked:
		icon.texture = get_achievement_icon(achievement.rarity)
	else:
		icon.texture = get_locked_achievement_icon()

	container.add_child(icon)

	# Dictionary info
	var info_container = VBoxContainer.new()
	info_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# Name and rarity
	var name_container = HBoxContainer.new()

	var name_label = Label.new()
	name_label.text = achievement.name
	name_label.add_theme_font_size_override("font_size", 18)
	if achievement.unlocked:
		name_label.add_theme_color_override("font_color", get_rarity_color(achievement.rarity))
	else:
		name_label.add_theme_color_override("font_color", Color.GRAY)

	name_container.add_child(name_label)

	# Rarity indicator
	var rarity_label = Label.new()
	rarity_label.text = get_rarity_name(achievement.rarity)
	rarity_label.add_theme_font_size_override("font_size", 12)
	rarity_label.add_theme_color_override("font_color", get_rarity_color(achievement.rarity))
	rarity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	rarity_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	name_container.add_child(rarity_label)
	info_container.add_child(name_container)

	# Description
	var desc_label = Label.new()
	desc_label.text = achievement.description
	desc_label.add_theme_font_size_override("font_size", 14)
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.size_flags_vertical = Control.SIZE_EXPAND_FILL

	if not achievement.unlocked:
		desc_label.add_theme_color_override("font_color", Color.GRAY)

	info_container.add_child(desc_label)

	# Progress bar (for locked achievements)
	if not achievement.unlocked:
		var progress_container = HBoxContainer.new()

		var progress_label = Label.new()
		progress_label.text = "Progress: "
		progress_label.add_theme_font_size_override("font_size", 12)
		progress_container.add_child(progress_label)

		var progress_bar = ProgressBar.new()
		progress_bar.value = achievement.progress * 100
		progress_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		progress_container.add_child(progress_bar)

		info_container.add_child(progress_container)

	# Rewards (for unlocked achievements)
	if achievement.unlocked and achievement.rewards.size() > 0:
		var rewards_label = Label.new()
		rewards_label.text = "Rewards: " + format_rewards(achievement.rewards)
		rewards_label.add_theme_font_size_override("font_size", 12)
		rewards_label.add_theme_color_override("font_color", Color.GREEN)
		info_container.add_child(rewards_label)

	container.add_child(info_container)

	return container

func style_unlocked_achievement(button: Button, achievement: Dictionary):
	"""Style an unlocked achievement button"""
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.3, 0.2, 0.8)  # Green tint
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = get_rarity_color(achievement.rarity)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4

	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", style)

func style_locked_achievement(button: Button, _achievement: Dictionary):
	"""Style a locked achievement button"""
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.2, 0.2, 0.8)  # Dark tint
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_color = Color.GRAY
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4

	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", style)

func get_achievement_icon(_rarity: AchievementSystem.AchievementRarity) -> Texture2D:
	"""Get icon for achievement based on rarity"""
	# This would load actual icons based on rarity
	# For now, return a placeholder
	return null

func get_locked_achievement_icon() -> Texture2D:
	"""Get icon for locked achievement"""
	# This would load a locked achievement icon
	return null

func get_rarity_color(rarity: AchievementSystem.AchievementRarity) -> Color:
	"""Get color for achievement rarity"""
	match rarity:
		AchievementSystem.AchievementRarity.COMMON:
			return Color.WHITE
		AchievementSystem.AchievementRarity.UNCOMMON:
			return Color.GREEN
		AchievementSystem.AchievementRarity.RARE:
			return Color.BLUE
		AchievementSystem.AchievementRarity.EPIC:
			return Color.PURPLE
		AchievementSystem.AchievementRarity.LEGENDARY:
			return Color.ORANGE
		_:
			return Color.WHITE

func get_rarity_name(rarity: AchievementSystem.AchievementRarity) -> String:
	"""Get name for achievement rarity"""
	match rarity:
		AchievementSystem.AchievementRarity.COMMON:
			return "Common"
		AchievementSystem.AchievementRarity.UNCOMMON:
			return "Uncommon"
		AchievementSystem.AchievementRarity.RARE:
			return "Rare"
		AchievementSystem.AchievementRarity.EPIC:
			return "Epic"
		AchievementSystem.AchievementRarity.LEGENDARY:
			return "Legendary"
		_:
			return "Unknown"

func format_rewards(rewards: Dictionary) -> String:
	"""Format rewards for display"""
	var reward_strings = []

	if "xp" in rewards:
		reward_strings.append(str(rewards.xp) + " XP")

	if "gold" in rewards:
		reward_strings.append(str(rewards.gold) + " gold")

	if "title" in rewards:
		reward_strings.append("Title: " + rewards.title)

	return ", ".join(reward_strings)

func compare_achievements(a: Dictionary, b: Dictionary) -> bool:
	"""Compare achievements for sorting"""
	# Sort by unlocked status first, then by rarity, then by name
	if a.unlocked != b.unlocked:
		return a.unlocked

	if a.rarity != b.rarity:
		return a.rarity > b.rarity

	return a.name < b.name

func update_statistics(unlocked_count: int, total_count: int):
	"""Update achievement statistics display"""
	var percentage = 0.0
	if total_count > 0:
		percentage = (float(unlocked_count) / float(total_count)) * 100.0

	%StatsLabel.text = "Unlocked: %d/%d (%.1f%%)" % [unlocked_count, total_count, percentage]

func select_achievement(achievement: Dictionary):
	"""Handle achievement selection"""
	achievement_selected.emit(achievement)
	print("Selected achievement: " + achievement.name)

func _on_back_button_pressed():
	"""Return to main screen"""
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func refresh_achievements():
	"""Refresh the achievements display"""
	load_achievements()
