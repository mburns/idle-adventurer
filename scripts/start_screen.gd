extends Control

func _ready():
	# Check if there's a save file and enable/disable load button accordingly
	var character_manager = CharacterManager.new()
	if character_manager.has_save_file():
		%LoadCharacterButton.disabled = false
	else:
		%LoadCharacterButton.disabled = true

func _on_new_character_button_pressed():
	# Switch to character creation screen
	get_tree().change_scene_to_file("res://character_creation.tscn")

func _on_load_character_button_pressed():
	# Load character and go to main game
	var character_manager = CharacterManager.new()
	if character_manager.load_character():
		get_tree().change_scene_to_file("res://main.tscn")
	else:
		print("Failed to load character")

func _on_settings_button_pressed():
	# Switch to settings screen
	get_tree().change_scene_to_file("res://settings_screen.tscn")

func _on_quit_button_pressed():
	# Quit the game
	get_tree().quit()
