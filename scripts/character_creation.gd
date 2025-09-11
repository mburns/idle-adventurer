extends Control

func _ready():
	# Wait a frame to ensure all autoloads are ready
	await get_tree().process_frame
	populate_dropdowns()
	generate_random_character()
	update_ability_modifiers()
	update_description()

func populate_dropdowns():
	# Populate race dropdown
	var races = DataLoader.get_race_names()
	print("Available races: " + str(races))
	if races.size() > 0:
		for race in races:
			%RaceOptionButton.add_item(race)
		%RaceOptionButton.selected = 0
		print("Race dropdown populated with " + str(races.size()) + " options")

	# Populate class dropdown
	var classes = DataLoader.get_class_names()
	print("Available classes: " + str(classes))
	if classes.size() > 0:
		for class_type in classes:
			%ClassOptionButton.add_item(class_type)
		%ClassOptionButton.selected = 0
		print("Class dropdown populated with " + str(classes.size()) + " options")

	# Populate background dropdown
	var backgrounds = DataLoader.get_background_names()
	print("Available backgrounds: " + str(backgrounds))
	if backgrounds.size() > 0:
		for background in backgrounds:
			%BackgroundOptionButton.add_item(background)
		%BackgroundOptionButton.selected = 0
		print("Background dropdown populated with " + str(backgrounds.size()) + " options")

func generate_random_character():
	"""Generate random character stats and appearance"""
	# Generate random name
	var names_data = DataLoader.load_json_data("names")
	if names_data and names_data.has("first_names") and names_data.has("last_names"):
		var first_names = names_data["first_names"]
		var last_names = names_data["last_names"]
		var random_first = first_names[randi() % first_names.size()]
		var random_last = last_names[randi() % last_names.size()]
		%CharacterNameInput.text = random_first + " " + random_last

	# Generate random race
	var races = DataLoader.get_race_names()
	if races.size() > 0:
		var random_race = races[randi() % races.size()]
		%RaceOptionButton.selected = races.find(random_race)

	# Generate random class
	var classes = DataLoader.get_class_names()
	if classes.size() > 0:
		var random_class = classes[randi() % classes.size()]
		%ClassOptionButton.selected = classes.find(random_class)

	# Generate random background
	var backgrounds = DataLoader.get_background_names()
	if backgrounds.size() > 0:
		var random_background = backgrounds[randi() % backgrounds.size()]
		%BackgroundOptionButton.selected = backgrounds.find(random_background)

	# Generate random ability scores (4d6 drop lowest)
	%StrengthSpinBox.value = roll_4d6_drop_lowest()
	%DexteritySpinBox.value = roll_4d6_drop_lowest()
	%ConstitutionSpinBox.value = roll_4d6_drop_lowest()
	%IntelligenceSpinBox.value = roll_4d6_drop_lowest()
	%WisdomSpinBox.value = roll_4d6_drop_lowest()
	%CharismaSpinBox.value = roll_4d6_drop_lowest()

	# Generate random height and weight based on race
	generate_random_height_weight()

func roll_4d6_drop_lowest() -> int:
	"""Roll 4d6 and drop the lowest die"""
	var rolls = []
	for i in range(4):
		rolls.append(randi_range(1, 6))
	rolls.sort()
	rolls.pop_front() # Remove lowest
	return rolls[0] + rolls[1] + rolls[2]

func generate_random_height_weight():
	"""Generate random height and weight based on selected race"""
	var selected_race = %RaceOptionButton.get_item_text(%RaceOptionButton.selected)
	var race_data = DataLoader.get_race_data(selected_race)

	if race_data.has("height_range") and race_data.has("weight_range"):
		var height_range = race_data["height_range"]
		var weight_range = race_data["weight_range"]

		var random_height = randi_range(height_range["min"], height_range["max"])
		var random_weight = randi_range(weight_range["min"], weight_range["max"])

		%HeightSpinBox.value = random_height
		%WeightSpinBox.value = random_weight

func update_ability_modifiers():
	# Update ability modifier labels
	%StrengthModifierLabel.text = "(%+d)" % calculate_modifier(%StrengthSpinBox.value)
	%DexterityModifierLabel.text = "(%+d)" % calculate_modifier(%DexteritySpinBox.value)
	%ConstitutionModifierLabel.text = "(%+d)" % calculate_modifier(%ConstitutionSpinBox.value)
	%IntelligenceModifierLabel.text = "(%+d)" % calculate_modifier(%IntelligenceSpinBox.value)
	%WisdomModifierLabel.text = "(%+d)" % calculate_modifier(%WisdomSpinBox.value)
	%CharismaModifierLabel.text = "(%+d)" % calculate_modifier(%CharismaSpinBox.value)

func calculate_modifier(score: int) -> int:
	return floor((score - 10) / 2.0)

func _on_strength_spin_box_value_changed(_value: float):
	update_ability_modifiers()

func _on_dexterity_spin_box_value_changed(_value: float):
	update_ability_modifiers()

func _on_constitution_spin_box_value_changed(_value: float):
	update_ability_modifiers()

func _on_intelligence_spin_box_value_changed(_value: float):
	update_ability_modifiers()

func _on_wisdom_spin_box_value_changed(_value: float):
	update_ability_modifiers()

func _on_charisma_spin_box_value_changed(_value: float):
	update_ability_modifiers()

func _on_race_option_button_item_selected(_index: int):
	update_description()

func _on_class_option_button_item_selected(_index: int):
	update_description()

func _on_background_option_button_item_selected(_index: int):
	update_description()

func update_description():
	var description_text = ""

	# Get selected values
	if %RaceOptionButton.get_item_count() > 0:
		var race = %RaceOptionButton.get_item_text(%RaceOptionButton.selected)
		var race_data = DataLoader.get_race_data(race)
		if not race_data.is_empty():
			description_text += "RACE: " + race + "\n"
			description_text += race_data.get("description", "No description available") + "\n\n"

	if %ClassOptionButton.get_item_count() > 0:
		var character_class = %ClassOptionButton.get_item_text(%ClassOptionButton.selected)
		var class_data = DataLoader.get_class_data(character_class)
		if not class_data.is_empty():
			description_text += "CLASS: " + character_class + "\n"
			description_text += class_data.get("description", "No description available") + "\n\n"

	if %BackgroundOptionButton.get_item_count() > 0:
		var background = %BackgroundOptionButton.get_item_text(%BackgroundOptionButton.selected)
		var background_data = DataLoader.get_background_data(background)
		if not background_data.is_empty():
			description_text += "BACKGROUND: " + background + "\n"
			description_text += background_data.get("description", "No description available") + "\n\n"

	%DescriptionTextArea.text = description_text

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/start_screen.tscn")

func _on_create_character_button_pressed():
	print("Create Character button pressed!")

	# Validate input
	if %CharacterNameInput.text.strip_edges() == "":
		print("Please enter a character name")
		return

	# Check if CharacterManager is available
	if CharacterManager == null:
		print("CharacterManager not available yet, please wait")
		return

	# Check if dropdowns have items
	if %RaceOptionButton.get_item_count() == 0 or %ClassOptionButton.get_item_count() == 0 or %BackgroundOptionButton.get_item_count() == 0:
		print("Dropdowns not populated yet, please wait")
		return

	# Get selected values
	var character_name = %CharacterNameInput.text.strip_edges()
	var race = %RaceOptionButton.get_item_text(%RaceOptionButton.selected)
	var character_class = %ClassOptionButton.get_item_text(%ClassOptionButton.selected)
	var background = %BackgroundOptionButton.get_item_text(%BackgroundOptionButton.selected)

	print("Creating character: %s (%s %s %s)" % [character_name, race, character_class, background])

	# Get ability scores
	var strength = int(%StrengthSpinBox.value)
	var dexterity = int(%DexteritySpinBox.value)
	var constitution = int(%ConstitutionSpinBox.value)
	var intelligence = int(%IntelligenceSpinBox.value)
	var wisdom = int(%WisdomSpinBox.value)
	var charisma = int(%CharismaSpinBox.value)

	# Get physical characteristics
	var height = int(%HeightSpinBox.value)
	var weight = int(%WeightSpinBox.value)

	# Create character
	print("Calling CharacterManager.create_character...")
	var character = CharacterManager.create_character(character_name, race, character_class, background)

	if character == null:
		print("ERROR: Character creation failed!")
		return

	print("Character created successfully, setting ability scores...")

	# Set ability scores
	character.strength = strength
	character.dexterity = dexterity
	character.constitution = constitution
	character.intelligence = intelligence
	character.wisdom = wisdom
	character.charisma = charisma

	# Set physical characteristics
	character.height = height
	character.weight = weight

	# Update derived stats
	character.update_derived_stats()

	# Set as current character
	print("Setting as current character...")
	CharacterManager.set_current_character(character)

	# Save character
	print("Saving character...")
	CharacterManager.save_character()

	print("Character created: %s" % character.get_summary())

	# Go to main game
	print("Changing to main scene...")
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_randomize_button_pressed():
	"""Generate a new random character"""
	generate_random_character()
	update_ability_modifiers()
	update_description()
