extends Control

# Character selection screen for managing multiple characters

signal character_selected(character: Character)
signal character_created(character: Character)
signal character_deleted(character_name: String)

var characters: Array[Character] = []
var selected_character_index: int = -1
var character_manager: CharacterManager

func _ready():
	# Apply theme
	ThemeManager.apply_theme_to_children(self)

	character_manager = CharacterManager
	load_all_characters()
	update_character_list()

func load_all_characters():
	"""Load all saved characters"""
	characters.clear()

	# Load characters from save directory
	var save_dir = "user://characters/"
	var dir = DirAccess.open("user://")

	if not dir.dir_exists("characters"):
		dir.make_dir("characters")
		return

	var characters_dir = DirAccess.open(save_dir)
	if characters_dir:
		for file_name in characters_dir.get_files():
			if file_name.ends_with(".dat"):
				var character_name = file_name.get_basename()
				var character = load_character(character_name)
				if character:
					characters.append(character)

func load_character(character_name: String) -> Character:
	"""Load a specific character by name"""
	var file_path = "user://characters/" + character_name + ".dat"
	var file = FileAccess.open(file_path, FileAccess.READ)

	if file:
		var json_string = file.get_as_text()
		file.close()

		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			var data = json.get_data()
			if data is Dictionary:
				var character = Character.new()
				character.from_dict(data)
				return character

	return null

func save_character(character: Character):
	"""Save a character to file"""
	var save_dir = "user://characters/"
	var dir = DirAccess.open("user://")

	if not dir.dir_exists("characters"):
		dir.make_dir("characters")

	var file_path = save_dir + character.name + ".dat"
	var file = FileAccess.open(file_path, FileAccess.WRITE)

	if file:
		file.store_string(JSON.stringify(character.to_dict()))
		file.close()
		print("Character saved: " + character.name)

func update_character_list():
	"""Update the character list display"""
	var character_list = %CharacterList
	if not character_list:
		return

	# Clear existing items
	for child in character_list.get_children():
		child.queue_free()

	# Add character buttons
	for i in range(characters.size()):
		var character = characters[i]
		var character_button = create_character_button(character, i)
		character_list.add_child(character_button)

	# Add create new character button
	var create_button = create_new_character_button()
	character_list.add_child(create_button)

func create_character_button(character: Character, index: int) -> Button:
	"""Create a button for a character"""
	var button = Button.new()
	button.text = character.name + " (Level " + str(character.level) + " " + character.character_class + ")"
	button.custom_minimum_size = Vector2(300, 60)
	button.pressed.connect(func(): select_character(index))

	# Add context menu for delete
	button.gui_input.connect(func(event): handle_character_button_input(event, index))

	return button

func create_new_character_button() -> Button:
	"""Create a button for creating a new character"""
	var button = Button.new()
	button.text = "+ Create New Character"
	button.custom_minimum_size = Vector2(300, 60)
	button.pressed.connect(create_new_character)

	# Style the button differently
	button.add_theme_color_override("font_color", Color.GREEN)

	return button

func handle_character_button_input(event: InputEvent, index: int):
	"""Handle right-click context menu for character buttons"""
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		show_character_context_menu(index, event.global_position)

func show_character_context_menu(index: int, position: Vector2):
	"""Show context menu for character actions"""
	var context_menu = PopupMenu.new()
	add_child(context_menu)

	context_menu.add_item("Select Character")
	context_menu.add_item("Delete Character")
	context_menu.add_separator()
	context_menu.add_item("Cancel")

	context_menu.popup_on_parent = true
	context_menu.position = position
	context_menu.popup()

	context_menu.id_pressed.connect(func(id): handle_context_menu_action(id, index))

func handle_context_menu_action(action_id: int, character_index: int):
	"""Handle context menu actions"""
	match action_id:
		0:  # Select Character
			select_character(character_index)
		1:  # Delete Character
			confirm_delete_character(character_index)
		2:  # Cancel
			pass

func select_character(index: int):
	"""Select a character"""
	if index >= 0 and index < characters.size():
		selected_character_index = index
		var character = characters[index]

		# Set as current character in CharacterManager
		character_manager.current_character = character

		# Emit signal
		character_selected.emit(character)

		# Go to main game
		get_tree().change_scene_to_file("res://scenes/main.tscn")

func create_new_character():
	"""Create a new character"""
	get_tree().change_scene_to_file("res://scenes/character_creation.tscn")

func confirm_delete_character(index: int):
	"""Show confirmation dialog for deleting a character"""
	if index >= 0 and index < characters.size():
		var character = characters[index]
		var dialog = ConfirmationDialog.new()
		add_child(dialog)

		dialog.dialog_text = "Are you sure you want to delete " + character.name + "? This action cannot be undone."
		dialog.popup_centered()

		dialog.confirmed.connect(func(): delete_character(index))

func delete_character(index: int):
	"""Delete a character"""
	if index >= 0 and index < characters.size():
		var character = characters[index]
		var character_name = character.name

		# Remove from list
		characters.remove_at(index)

		# Delete save file
		var file_path = "user://characters/" + character_name + ".dat"
		var dir = DirAccess.open("user://")
		if dir.file_exists(file_path):
			dir.remove(file_path)

		# Update display
		update_character_list()

		# Emit signal
		character_deleted.emit(character_name)

		print("Character deleted: " + character_name)

func _on_back_button_pressed():
	"""Return to start screen"""
	get_tree().change_scene_to_file("res://scenes/start_screen.tscn")

func _on_character_created(character: Character):
	"""Handle character creation from character creation screen"""
	characters.append(character)
	save_character(character)
	update_character_list()
	character_created.emit(character)

func get_character_count() -> int:
	"""Get the number of saved characters"""
	return characters.size()

func get_character_names() -> Array[String]:
	"""Get list of character names"""
	var names = []
	for character in characters:
		names.append(character.name)
	return names
