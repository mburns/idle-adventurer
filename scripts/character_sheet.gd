extends BaseScreen

# D&D Character Sheet with dice rolling functionality

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

# Class Abilities UI
@onready var class_abilities_container: VBoxContainer
@onready var spell_slots_container: HBoxContainer
@onready var active_buffs_container: VBoxContainer

# Dice Roller UI
@onready var dice_input: LineEdit
@onready var roll_result: Label

# Dice rolling system
var dice_history: Array[Dictionary] = []

func on_screen_ready() -> void:
	"""Override base screen ready for character sheet specific setup"""
	# Setup UI references
	setup_ui_references()

	# Update display
	update_character_sheet()

	# Setup timers for buffs and abilities
	setup_timers()

func setup_ui_references():
	# Get main info labels
	name_label = %NameLabel
	level_class_label = %LevelClassLabel
	race_background_label = %RaceBackgroundLabel

	# Check if elements exist
	if not name_label:
		print("Warning: NameLabel not found in character sheet")
	if not level_class_label:
		print("Warning: LevelClassLabel not found in character sheet")
	if not race_background_label:
		print("Warning: RaceBackgroundLabel not found in character sheet")

	# Get ability score UI
	ability_containers = {
		"strength": get_node("MainContainer/LeftPanel/AbilityScores/AbilityScoresContainer/StrengthContainer"),
		"dexterity": get_node("MainContainer/LeftPanel/AbilityScores/AbilityScoresContainer/DexterityContainer"),
		"constitution": get_node("MainContainer/LeftPanel/AbilityScores/AbilityScoresContainer/ConstitutionContainer"),
		"intelligence": get_node("MainContainer/LeftPanel/AbilityScores/AbilityScoresContainer/IntelligenceContainer"),
		"wisdom": get_node("MainContainer/LeftPanel/AbilityScores/AbilityScoresContainer/WisdomContainer"),
		"charisma": get_node("MainContainer/LeftPanel/AbilityScores/AbilityScoresContainer/CharismaContainer")
	}

	ability_values = {
		"strength": get_node("MainContainer/LeftPanel/AbilityScores/AbilityScoresContainer/StrengthContainer/StrengthValue"),
		"dexterity": get_node("MainContainer/LeftPanel/AbilityScores/AbilityScoresContainer/DexterityContainer/DexterityValue"),
		"constitution": get_node("MainContainer/LeftPanel/AbilityScores/AbilityScoresContainer/ConstitutionContainer/ConstitutionValue"),
		"intelligence": get_node("MainContainer/LeftPanel/AbilityScores/AbilityScoresContainer/IntelligenceContainer/IntelligenceValue"),
		"wisdom": get_node("MainContainer/LeftPanel/AbilityScores/AbilityScoresContainer/WisdomContainer/WisdomValue"),
		"charisma": get_node("MainContainer/LeftPanel/AbilityScores/AbilityScoresContainer/CharismaContainer/CharismaValue")
	}

	ability_modifiers = {
		"strength": get_node("MainContainer/LeftPanel/AbilityScores/AbilityScoresContainer/StrengthContainer/StrengthModifier"),
		"dexterity": get_node("MainContainer/LeftPanel/AbilityScores/AbilityScoresContainer/DexterityContainer/DexterityModifier"),
		"constitution": get_node("MainContainer/LeftPanel/AbilityScores/AbilityScoresContainer/ConstitutionContainer/ConstitutionModifier"),
		"intelligence": get_node("MainContainer/LeftPanel/AbilityScores/AbilityScoresContainer/IntelligenceContainer/IntelligenceModifier"),
		"wisdom": get_node("MainContainer/LeftPanel/AbilityScores/AbilityScoresContainer/WisdomContainer/WisdomModifier"),
		"charisma": get_node("MainContainer/LeftPanel/AbilityScores/AbilityScoresContainer/CharismaContainer/CharismaModifier")
	}

	# Get combat stats UI
	hit_points_value = %HitPointsValue
	armor_class_value = %ArmorClassValue
	initiative_value = %InitiativeValue
	proficiency_value = %ProficiencyValue

	# Get dice roller UI
	dice_input = %DiceInput
	roll_result = %RollResult

func connect_signals() -> void:
	"""Override base screen signals for character sheet specific connections"""
	super.connect_signals()
	# Additional character sheet specific signals can be added here

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

	# Update class abilities and buffs
	update_class_abilities()
	update_spell_slots()
	update_active_buffs()

func show_default_sheet():
	if name_label:
		name_label.text = "No Character"
	if level_class_label:
		level_class_label.text = "Create a character to begin"
	if race_background_label:
		race_background_label.text = ""

	# Clear all values
	for ability in ability_values.keys():
		ability_values[ability].text = "--"
		ability_modifiers[ability].text = "(+0)"

	if hit_points_value:
		hit_points_value.text = "--/--"
	if armor_class_value:
		armor_class_value.text = "--"
	if initiative_value:
		initiative_value.text = "+0"
	if proficiency_value:
		proficiency_value.text = "+0"

func update_character_info():
	if character == null:
		return

	if name_label:
		name_label.text = character.name
	if level_class_label:
		level_class_label.text = "Level %d %s" % [character.level, character.character_class.capitalize()]
	if race_background_label:
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

	if hit_points_value:
		hit_points_value.text = "%d/%d" % [character.hit_points, character.max_hit_points]
	if armor_class_value:
		armor_class_value.text = str(character.armor_class)
	if initiative_value:
		initiative_value.text = "%+d" % character.get_dexterity_modifier()
	if proficiency_value:
		proficiency_value.text = "%+d" % character.proficiency_bonus

func on_character_updated() -> void:
	"""Override base screen character update for character sheet specific behavior"""
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

	var dice_result = {
		"dice_string": dice_string,
		"rolls": rolls,
		"modifier": modifier,
		"total": total,
		"timestamp": Time.get_unix_time_from_system()
	}

	# Add to history
	dice_history.append(dice_result)

	return dice_result

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

# Back button is handled by base class

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

func update_class_abilities():
	"""Update class abilities display"""
	if not class_abilities_container:
		return

	# Clear existing abilities
	for child in class_abilities_container.get_children():
		child.queue_free()

	# Get class features for current level
	var class_data = DataLoader.get_class_data(character.character_class)
	var all_features = class_data.get("features", {})

	# Show features up to current level
	for feature_name in all_features.keys():
		var feature_data = all_features[feature_name]
		var feature_level = feature_data.get("level", 1)

		if feature_level <= character.level:
			var feature_label = Label.new()
			feature_label.text = feature_name + " (Level " + str(feature_level) + ")"
			feature_label.add_theme_font_size_override("font_size", 14)
			class_abilities_container.add_child(feature_label)

			var description_label = Label.new()
			description_label.text = "  " + feature_data.get("description", "")
			description_label.add_theme_font_size_override("font_size", 12)
			description_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
			description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			class_abilities_container.add_child(description_label)

func update_spell_slots():
	"""Update spell slots display"""
	if not spell_slots_container:
		return

	# Clear existing slots
	for child in spell_slots_container.get_children():
		child.queue_free()

	# Check if character is a spellcaster
	var spellcasting_classes = ["wizard", "sorcerer", "cleric", "druid", "bard", "warlock"]
	if not character.character_class.to_lower() in spellcasting_classes:
		var no_spells_label = Label.new()
		no_spells_label.text = "Not a spellcasting class"
		no_spells_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
		spell_slots_container.add_child(no_spells_label)
		return

	# Display spell slots
	var spell_slots = character.spell_slots
	if spell_slots.is_empty():
		# Calculate spell slots for current level
		var leveling_system = LevelingSystem.new()
		spell_slots = leveling_system.calculate_spell_slots(character.character_class, character.level)

	for level in spell_slots.keys():
		var count = spell_slots[level]
		if count > 0:
			var slot_container = VBoxContainer.new()

			var level_label = Label.new()
			level_label.text = level
			level_label.add_theme_font_size_override("font_size", 12)
			level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			slot_container.add_child(level_label)

			var count_label = Label.new()
			count_label.text = str(count)
			count_label.add_theme_font_size_override("font_size", 16)
			count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			slot_container.add_child(count_label)

			spell_slots_container.add_child(slot_container)

func update_active_buffs():
	"""Update active buffs display with timers"""
	if not active_buffs_container:
		return

	# Clear existing buffs
	for child in active_buffs_container.get_children():
		child.queue_free()

	var active_buffs = character.active_buffs
	if active_buffs.is_empty():
		var no_buffs_label = Label.new()
		no_buffs_label.text = "No active buffs"
		no_buffs_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
		active_buffs_container.add_child(no_buffs_label)
		return

	for buff in active_buffs:
		var buff_container = HBoxContainer.new()

		var buff_name_label = Label.new()
		buff_name_label.text = buff.get("name", "Unknown Buff")
		buff_name_label.add_theme_font_size_override("font_size", 14)
		buff_container.add_child(buff_name_label)

		var buff_timer_label = Label.new()
		var expires_at = buff.get("expires_at", 0)
		var time_remaining = expires_at - Time.get_unix_time_from_system()

		if time_remaining > 0:
			var minutes = int(time_remaining / 60)
			var seconds = int(time_remaining) % 60
			buff_timer_label.text = str(minutes) + ":" + str(seconds).pad_zeros(2)
			buff_timer_label.add_theme_color_override("font_color", Color.GREEN)
		else:
			buff_timer_label.text = "Expired"
			buff_timer_label.add_theme_color_override("font_color", Color.RED)

		buff_timer_label.add_theme_font_size_override("font_size", 12)
		buff_container.add_child(buff_timer_label)

		active_buffs_container.add_child(buff_container)

func setup_timers():
	"""Setup timers for updating buffs and abilities"""
	# Create a timer to update buff timers every second
	var buff_timer = Timer.new()
	buff_timer.wait_time = 1.0
	buff_timer.timeout.connect(_on_buff_timer_timeout)
	buff_timer.autostart = true
	add_child(buff_timer)

func _on_buff_timer_timeout():
	"""Update buff timers every second"""
	if character and active_buffs_container:
		update_active_buffs()
