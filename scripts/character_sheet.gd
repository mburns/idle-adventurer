extends Control

# D&D Character Sheet with dice rolling functionality

@onready var character: Character
var character_manager: CharacterManager

# UI References
@onready var name_label: Label
@onready var level_class_label: Label
@onready var race_background_label: Label

# Ability Score UI
var ability_containers: Dictionary = {}
var ability_values: Dictionary = {}
var ability_modifiers: Dictionary = {}

# Combat Stats UI
@onready var hit_points_value: Label
@onready var armor_class_value: Label
@onready var initiative_value: Label
@onready var proficiency_value: Label

# Dice Roller UI
@onready var dice_input: LineEdit
@onready var roll_result: Label

# Dice rolling system
var dice_history: Array[Dictionary] = []

func _ready():
    # Get character manager and current character
    character_manager = CharacterManager.new()
    character = character_manager.get_current_character()

    # Setup UI references
    setup_ui_references()

    # Connect to character events
    connect_to_character_events()

    # Update display
    update_character_sheet()

func setup_ui_references():
    # Get main info labels
    name_label = %NameLabel
    level_class_label = %LevelClassLabel
    race_background_label = %RaceBackgroundLabel

    # Get ability score UI
    ability_containers = {
        "strength": %StrengthContainer,
        "dexterity": %DexterityContainer,
        "constitution": %ConstitutionContainer,
        "intelligence": %IntelligenceContainer,
        "wisdom": %WisdomContainer,
        "charisma": %CharismaContainer
    }

    ability_values = {
        "strength": %StrengthValue,
        "dexterity": %DexterityValue,
        "constitution": %ConstitutionValue,
        "intelligence": %IntelligenceValue,
        "wisdom": %WisdomValue,
        "charisma": %CharismaValue
    }

    ability_modifiers = {
        "strength": %StrengthModifier,
        "dexterity": %DexterityModifier,
        "constitution": %ConstitutionModifier,
        "intelligence": %IntelligenceModifier,
        "wisdom": %WisdomModifier,
        "charisma": %CharismaModifier
    }

    # Get combat stats UI
    hit_points_value = %HitPointsValue
    armor_class_value = %ArmorClassValue
    initiative_value = %InitiativeValue
    proficiency_value = %ProficiencyValue

    # Get dice roller UI
    dice_input = %DiceInput
    roll_result = %RollResult

func connect_to_character_events():
    if character_manager:
        character_manager.character_changed.connect(_on_character_changed)

func update_character_sheet():
    if character == null:
        show_default_sheet()
        return

    # Update character info
    update_character_info()

    # Update ability scores
    update_ability_scores()

    # Update combat stats
    update_combat_stats()

func show_default_sheet():
    name_label.text = "No Character"
    level_class_label.text = "Create a character to begin"
    race_background_label.text = ""

    # Clear all values
    for ability in ability_values.keys():
        ability_values[ability].text = "--"
        ability_modifiers[ability].text = "(+0)"

    hit_points_value.text = "--/--"
    armor_class_value.text = "--"
    initiative_value.text = "+0"
    proficiency_value.text = "+0"

func update_character_info():
    if character == null:
        return

    name_label.text = character.name
    level_class_label.text = "Level %d %s" % [character.level, character.character_class.capitalize()]
    race_background_label.text = "%s • %s" % [character.race.capitalize(), character.background.capitalize()]

func update_ability_scores():
    if character == null:
        return

    var abilities = ["strength", "dexterity", "constitution", "intelligence", "wisdom", "charisma"]

    for ability in abilities:
        var score = character.get(ability)
        var modifier = character.get_ability_modifier(score)

        ability_values[ability].text = str(score)
        ability_modifiers[ability].text = "(%+d)" % modifier

func update_combat_stats():
    if character == null:
        return

    hit_points_value.text = "%d/%d" % [character.hit_points, character.max_hit_points]
    armor_class_value.text = str(character.armor_class)
    initiative_value.text = "%+d" % character.get_dexterity_modifier()
    proficiency_value.text = "%+d" % character.proficiency_bonus

func _on_character_changed(new_character: Character):
    character = new_character
    update_character_sheet()

# Dice Rolling System
func roll_dice(dice_string: String) -> Dictionary:
    # Parse dice string like "1d20+5" or "2d6+3"
    var regex = RegEx.new()
    regex.compile("(\\d+)d(\\d+)([+-]?\\d+)?")
    var result = regex.search(dice_string)

    if not result:
        return {"error": "Invalid dice format"}

    var num_dice = int(result.get_string(1))
    var dice_size = int(result.get_string(2))
    var modifier = 0

    if result.get_string(3) != "":
        modifier = int(result.get_string(3))

    var rolls = []
    var total = 0

    # Roll the dice
    for i in range(num_dice):
        var roll = randi_range(1, dice_size)
        rolls.append(roll)
        total += roll

    total += modifier

    var roll_result = {
        "dice_string": dice_string,
        "rolls": rolls,
        "modifier": modifier,
        "total": total,
        "timestamp": Time.get_unix_time_from_system()
    }

    # Add to history
    dice_history.append(roll_result)

    return roll_result

func roll_ability_check(ability: String) -> Dictionary:
    if character == null:
        return {"error": "No character loaded"}

    var ability_score = character.get(ability)
    var modifier = character.get_ability_modifier(ability_score)
    var dice_string = "1d20+%d" % modifier

    return roll_dice(dice_string)

func roll_attack_roll() -> Dictionary:
    if character == null:
        return {"error": "No character loaded"}

    var strength_modifier = character.get_strength_modifier()
    var proficiency_bonus = character.proficiency_bonus
    var attack_bonus = strength_modifier + proficiency_bonus
    var dice_string = "1d20+%d" % attack_bonus

    return roll_dice(dice_string)

func roll_damage_roll() -> Dictionary:
    if character == null:
        return {"error": "No character loaded"}

    var strength_modifier = character.get_strength_modifier()
    var dice_string = "1d8+%d" % strength_modifier

    return roll_dice(dice_string)

func roll_saving_throw(ability: String) -> Dictionary:
    if character == null:
        return {"error": "No character loaded"}

    var ability_score = character.get(ability)
    var modifier = character.get_ability_modifier(ability_score)
    var proficiency_bonus = character.proficiency_bonus

    # Check if character is proficient in this saving throw
    var is_proficient = ability in character.saving_throws
    if is_proficient:
        modifier += proficiency_bonus

    var dice_string = "1d20+%d" % modifier

    return roll_dice(dice_string)

func roll_initiative() -> Dictionary:
    if character == null:
        return {"error": "No character loaded"}

    var dexterity_modifier = character.get_dexterity_modifier()
    var dice_string = "1d20+%d" % dexterity_modifier

    return roll_dice(dice_string)

# UI Event Handlers
func _on_strength_roll_pressed():
    var result = roll_ability_check("strength")
    display_roll_result("Strength Check", result)

func _on_dexterity_roll_pressed():
    var result = roll_ability_check("dexterity")
    display_roll_result("Dexterity Check", result)

func _on_constitution_roll_pressed():
    var result = roll_ability_check("constitution")
    display_roll_result("Constitution Check", result)

func _on_intelligence_roll_pressed():
    var result = roll_ability_check("intelligence")
    display_roll_result("Intelligence Check", result)

func _on_wisdom_roll_pressed():
    var result = roll_ability_check("wisdom")
    display_roll_result("Wisdom Check", result)

func _on_charisma_roll_pressed():
    var result = roll_ability_check("charisma")
    display_roll_result("Charisma Check", result)

func _on_initiative_roll_pressed():
    var result = roll_initiative()
    display_roll_result("Initiative", result)

func _on_roll_button_pressed():
    var dice_string = dice_input.text.strip_edges()
    if dice_string == "":
        roll_result.text = "Enter a dice string (e.g., 1d20+5)"
        return

    var result = roll_dice(dice_string)
    display_roll_result("Custom Roll", result)

func _on_attack_roll_pressed():
    var result = roll_attack_roll()
    display_roll_result("Attack Roll", result)

func _on_damage_roll_pressed():
    var result = roll_damage_roll()
    display_roll_result("Damage Roll", result)

func _on_saving_throw_pressed():
    var result = roll_saving_throw("constitution")
    display_roll_result("Constitution Saving Throw", result)

func display_roll_result(roll_type: String, result: Dictionary):
    if result.has("error"):
        roll_result.text = "Error: %s" % result.error
        return

    var rolls_text = str(result.rolls)
    var modifier_text = ""
    if result.modifier != 0:
        modifier_text = " %+d" % result.modifier

    roll_result.text = "%s: %s%s = %d" % [roll_type, rolls_text, modifier_text, result.total]

    # Add visual feedback
    animate_roll_result()

func animate_roll_result():
    # Simple animation for roll result
    var tween = create_tween()
    tween.tween_property(roll_result, "modulate", Color.YELLOW, 0.1)
    tween.tween_property(roll_result, "modulate", Color.WHITE, 0.1)

func _on_back_button_pressed():
    get_tree().change_scene_to_file("res://scenes/main.tscn")

# Additional D&D functionality
func get_skill_modifier(skill: String) -> int:
    if character == null:
        return 0

    var ability = get_skill_ability(skill)
    var ability_modifier = character.get_ability_modifier(character.get(ability))
    var proficiency_bonus = 0

    if skill in character.skill_proficiencies:
        proficiency_bonus = character.proficiency_bonus

    return ability_modifier + proficiency_bonus

func get_skill_ability(skill: String) -> String:
    var skill_abilities = {
        "athletics": "strength",
        "acrobatics": "dexterity",
        "sleight_of_hand": "dexterity",
        "stealth": "dexterity",
        "arcana": "intelligence",
        "history": "intelligence",
        "investigation": "intelligence",
        "nature": "intelligence",
        "religion": "intelligence",
        "animal_handling": "wisdom",
        "insight": "wisdom",
        "medicine": "wisdom",
        "perception": "wisdom",
        "survival": "wisdom",
        "deception": "charisma",
        "intimidation": "charisma",
        "performance": "charisma",
        "persuasion": "charisma"
    }

    return skill_abilities.get(skill, "strength")

func roll_skill_check(skill: String) -> Dictionary:
    if character == null:
        return {"error": "No character loaded"}

    var modifier = get_skill_modifier(skill)
    var dice_string = "1d20+%d" % modifier

    return roll_dice(dice_string)

# Export character sheet as PDF (future feature)
func export_character_sheet():
    # TODO: Implement PDF export
    print("Exporting character sheet...")

# Print character sheet (for physical use)
func print_character_sheet():
    # TODO: Implement print functionality
    print("Printing character sheet...")
