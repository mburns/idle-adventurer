extends Control

var character_manager: CharacterManager

func _ready():
    character_manager = CharacterManager.new()
    populate_dropdowns()
    update_ability_modifiers()

func populate_dropdowns():
    # Populate race dropdown
    var races = DnDData.get_race_names()
    for race in races:
        %RaceOptionButton.add_item(race)

    # Populate class dropdown
    var classes = DnDData.get_class_names()
    for class_name in classes:
        %ClassOptionButton.add_item(class_name)

    # Populate background dropdown
    var backgrounds = DnDData.get_background_names()
    for background in backgrounds:
        %BackgroundOptionButton.add_item(background)

    # Set default selections
    %RaceOptionButton.selected = 0
    %ClassOptionButton.selected = 0
    %BackgroundOptionButton.selected = 0

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

func _on_strength_spin_box_value_changed(value: float):
    update_ability_modifiers()

func _on_dexterity_spin_box_value_changed(value: float):
    update_ability_modifiers()

func _on_constitution_spin_box_value_changed(value: float):
    update_ability_modifiers()

func _on_intelligence_spin_box_value_changed(value: float):
    update_ability_modifiers()

func _on_wisdom_spin_box_value_changed(value: float):
    update_ability_modifiers()

func _on_charisma_spin_box_value_changed(value: float):
    update_ability_modifiers()

func _on_back_button_pressed():
    get_tree().change_scene_to_file("res://scenes/start_screen.tscn")

func _on_create_character_button_pressed():
    # Validate input
    if %CharacterNameInput.text.strip_edges() == "":
        print("Please enter a character name")
        return

    # Get selected values
    var character_name = %CharacterNameInput.text.strip_edges()
    var race = %RaceOptionButton.get_item_text(%RaceOptionButton.selected)
    var character_class = %ClassOptionButton.get_item_text(%ClassOptionButton.selected)
    var background = %BackgroundOptionButton.get_item_text(%BackgroundOptionButton.selected)

    # Get ability scores
    var strength = int(%StrengthSpinBox.value)
    var dexterity = int(%DexteritySpinBox.value)
    var constitution = int(%ConstitutionSpinBox.value)
    var intelligence = int(%IntelligenceSpinBox.value)
    var wisdom = int(%WisdomSpinBox.value)
    var charisma = int(%CharismaSpinBox.value)

    # Create character
    var character = character_manager.create_character(character_name, race, character_class, background)

    # Set ability scores
    character.strength = strength
    character.dexterity = dexterity
    character.constitution = constitution
    character.intelligence = intelligence
    character.wisdom = wisdom
    character.charisma = charisma

    # Update derived stats
    character.update_derived_stats()

    # Save character
    character_manager.save_character()

    print("Character created: %s" % character.get_summary())

    # Go to main game
    get_tree().change_scene_to_file("res://scenes/main.tscn")
