extends Control

func _ready():
	# Apply theme
	ThemeManager.apply_theme_to_children(self)

	# Check if there's a save file and enable/disable load button accordingly
	if CharacterManager.has_save_file():
		%LoadCharacterButton.disabled = false
	else:
		%LoadCharacterButton.disabled = true

	# Add some visual polish
	add_visual_effects()

func _on_new_character_button_pressed():
	# Switch to character creation screen
	get_tree().change_scene_to_file("res://scenes/character_creation.tscn")

func _on_load_character_button_pressed():
	# Go to character selection screen
	get_tree().change_scene_to_file("res://scenes/character_selection.tscn")

func _on_settings_button_pressed():
	# Switch to settings screen
	get_tree().change_scene_to_file("res://scenes/settings_screen.tscn")

func _on_quit_button_pressed():
	# Quit the game
	get_tree().quit()

func add_visual_effects():
	"""Add visual effects to enhance the UI"""
	# Add subtle animation to buttons
	var buttons = [%NewCharacterButton, %LoadCharacterButton, %SettingsButton, %QuitButton]
	for button in buttons:
		if button:
			add_button_hover_effect(button)

func add_button_hover_effect(button: Button):
	"""Add hover effect to a button"""
	button.mouse_entered.connect(func():
		AnimationManager.animate_bounce(button)
	)
	button.mouse_exited.connect(func():
		AnimationManager.animate_bounce(button)
	)
