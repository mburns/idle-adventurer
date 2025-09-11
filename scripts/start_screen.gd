extends Control

func _ready():
	# Apply theme
	ThemeManager.apply_theme_to_node(self)

	# Check if there's a save file and enable/disable load button accordingly
	var load_button = get_node("VBoxContainer/LoadCharacterButton")
	if CharacterManager.has_save_file():
		load_button.disabled = false
	else:
		load_button.disabled = true

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
	var buttons = [
		get_node("VBoxContainer/NewCharacterButton"),
		get_node("VBoxContainer/LoadCharacterButton"),
		get_node("VBoxContainer/SettingsButton"),
		get_node("VBoxContainer/QuitButton")
	]
	for button in buttons:
		if button:
			add_button_hover_effect(button)

func add_button_hover_effect(button: Button):
	"""Add hover effect to a button"""
	# Store button reference in a way that won't cause lambda capture issues
	var button_ref = weakref(button)
	button.mouse_entered.connect(func(): _on_button_mouse_entered(button_ref))
	button.mouse_exited.connect(func(): _on_button_mouse_exited(button_ref))

func _on_button_mouse_entered(button_ref: WeakRef):
	"""Handle button mouse entered"""
	var button = button_ref.get_ref()
	if button and is_instance_valid(button):
		AnimationManager.animate_bounce(button)

func _on_button_mouse_exited(button_ref: WeakRef):
	"""Handle button mouse exited"""
	var button = button_ref.get_ref()
	if button and is_instance_valid(button):
		AnimationManager.animate_bounce(button)
