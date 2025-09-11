extends Control

@onready var coins_value_text = %CoinsValueText
@onready var character_name_label = %CharacterNameLabel
@onready var character_level_label = %CharacterLevelLabel
@onready var character_class_label = %CharacterClassLabel
@onready var current_activity_label = %CurrentActivityLabel
@onready var activity_progress_bar = %ActivityProgressBar

var character: Character
var active_button: Button = null
var button_progress_bars: Dictionary = {} # activity_name -> progress_bar

# Called when the node enters the scene tree for the first time.
func _ready():
	# Wait a frame to ensure all autoloads are ready
	await get_tree().process_frame

	# Connect to character manager signals
	CharacterManager.character_changed.connect(_on_character_changed)

	# Load character or create default
	if CharacterManager.has_save_file():
		CharacterManager.load_character()
	else:
		CharacterManager.create_default_character()

	character = CharacterManager.get_current_character()
	setup_button_progress_bars()
	update_ui()

func setup_button_progress_bars():
	"""Setup progress bars for each activity button"""
	# Map activity names to progress bar node paths
	var activity_to_progress_bar = {
		# Strength activities
		"Push a Rock": "TabContainer/Strength/PushARock/PushARockProgressBar",
		"Tip Over a Statue": "TabContainer/Strength/TipOverAStatue/TipOverAStatueProgressBar",
		"Lift Weights": "TabContainer/Strength/Athletics/AthleticsProgressBar",

		# Dexterity activities
		"Do a Kickflip": "TabContainer/Dexterity/DoAKickflip/DoAKickflipProgressBar",
		"Practice Acrobatics": "TabContainer/Dexterity/Acrobatics/AcrobaticsProgressBar",
		"Pick Locks": "TabContainer/Dexterity/PickALock/PickALockProgressBar",
		"Stealth Training": "TabContainer/Dexterity/Stealth/StealthProgressBar",
		"Play Instrument": "TabContainer/Dexterity/PlayStringedInstrument/PlayStringedInstrumentProgressBar",

		# Constitution activities
		"Hold Your Breath": "TabContainer/Constitution/HoldYourBreath/HoldYourBreathProgressBar",
		"Drink Ale": "TabContainer/Constitution/QuaffAnAle/QuaffAnAleProgressBar",

		# Intelligence activities
		"Study Arcana": "TabContainer/Intelligence/Arcana/ArcanaProgressBar",
		"Research History": "TabContainer/Intelligence/History/HistoryProgressBar",
		"Investigate": "TabContainer/Intelligence/Investigation/InvestigationProgressBar",
		"Study Nature": "TabContainer/Intelligence/Nature/NatureProgressBar",
		"Research Religion": "TabContainer/Intelligence/Religion/ReligionProgressBar",
		"Forge Document": "TabContainer/Intelligence/ForgeADocument/ForgeADocumentProgressBar",

		# Wisdom activities
		"Animal Handling": "TabContainer/Wisdom/AnimalHandling/AnimalHandlingProgressBar",
		"Practice Insight": "TabContainer/Wisdom/Insight/InsightProgressBar",
		"Study Medicine": "TabContainer/Wisdom/Medicine/MedicineProgressBar",
		"Practice Perception": "TabContainer/Wisdom/Perception/PerceptionProgressBar",
		"Survival Training": "TabContainer/Wisdom/Survival/SurvivalProgressBar",

		# Charisma activities
		"Practice Deception": "TabContainer/Charisma/Deception/DeceptionProgressBar",
		"Practice Intimidation": "TabContainer/Charisma/Intimidation/IntimidationProgressBar",
		"Performance Practice": "TabContainer/Charisma/Performance/PerformanceProgressBar",
		"Practice Persuasion": "TabContainer/Charisma/Persuasion/PersuasionProgressBar",

		# Crafting activities
		"Blacksmithing": "TabContainer/Crafting/Blacksmithing/BlacksmithingProgressBar",
		"Jewelry Making": "TabContainer/Crafting/JewelryMaking/JewelryMakingProgressBar",
		"Leatherworking": "TabContainer/Crafting/Leatherworking/LeatherworkingProgressBar",
		"Pottery": "TabContainer/Crafting/Pottery/PotteryProgressBar",
		"Weaving": "TabContainer/Crafting/Weaving/WeavingProgressBar",
		"Woodworking": "TabContainer/Crafting/Woodworking/WoodworkingProgressBar",

		# Profession activities
		"Artisan": "TabContainer/Profession/Artisan/ArtisanProgressBar",
		"Merchant": "TabContainer/Profession/Merchant/MerchantProgressBar",
		"Scholar": "TabContainer/Profession/Scholar/ScholarProgressBar",
		"Guard": "TabContainer/Profession/Guard/GuardProgressBar",
		"Priest": "TabContainer/Profession/Priest/PriestProgressBar",
		"Entertainer": "TabContainer/Profession/Entertainer/EntertainerProgressBar",

		# Training activities
		"Learn Language": "TabContainer/Training/LearnLanguage/LearnLanguageProgressBar",
		"Tool Proficiency": "TabContainer/Training/ToolProficiency/ToolProficiencyProgressBar",
		"Skill Training": "TabContainer/Training/SkillTraining/SkillTrainingProgressBar"
	}

	for activity_name in activity_to_progress_bar.keys():
		var progress_bar_path = activity_to_progress_bar[activity_name]
		var progress_bar = get_node_or_null(progress_bar_path)
		if progress_bar:
			button_progress_bars[activity_name] = progress_bar
			# Style the progress bar to be more visible
			progress_bar.add_theme_color_override("background_color", Color(0.3, 0.3, 0.3, 0.9))
			progress_bar.add_theme_color_override("fill_color", Color(0.0, 1.0, 0.0, 0.9))
			# Make sure the progress bar is visible
			progress_bar.visible = true
			progress_bar.modulate = Color(1.0, 1.0, 1.0, 0.7) # Semi-transparent

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if character != null:
		# Check if current activity is complete
		if character.is_activity_complete():
			var rewards = IdleMechanics.complete_activity(character)
			if rewards.xp > 0 or rewards.gold > 0:
				print("Activity completed! Gained %d XP and %d gold" % [rewards.xp, rewards.gold])

			# Restart the same activity automatically
			if character.current_activity != "":
				var activity_name = character.current_activity
				clear_all_button_progress()
				IdleMechanics.start_activity(activity_name, character)

			update_ui()
		else:
			# Update activity progress
			update_activity_progress()

# Update UI elements
func update_ui():
	if character == null:
		return

	# Update character info
	if character_name_label:
		character_name_label.text = character.name
	if character_level_label:
		character_level_label.text = "Level %d" % character.level
	if character_class_label:
		character_class_label.text = "%s %s" % [character.race, character.character_class]

	# Update coins
	if coins_value_text:
		coins_value_text.text = str(character.gold)

	# Update current activity
	if current_activity_label:
		if character.current_activity != "":
			current_activity_label.text = "Currently: %s" % character.current_activity
		else:
			current_activity_label.text = "Idle"

	# Update level progress
	update_level_progress()

# Update activity progress bar
func update_activity_progress():
	if character == null or character.current_activity == "":
		return

	var time_remaining = character.get_activity_time_remaining()
	var total_duration = character.activity_duration
	var progress = 1.0 - (time_remaining / total_duration)

	# Update the button progress bar for the current activity
	if character.current_activity in button_progress_bars:
		var progress_bar = button_progress_bars[character.current_activity]
		if progress_bar:
			progress_bar.value = progress

	# Update the main progress bar to show level progress
	update_level_progress()

func update_level_progress():
	"""Update the main progress bar to show level progress"""
	if character == null or not activity_progress_bar:
		return

	# Calculate level progress (assuming 1000 XP per level)
	var current_level_xp = character.experience_points % 1000
	var level_progress = float(current_level_xp) / 1000.0
	activity_progress_bar.value = level_progress * 100

# Handle character changes
func _on_character_changed(new_character: Character):
	character = new_character
	update_ui()

# Button handlers
func _on_grant_coins_button_pressed():
	if character != null:
		character.add_gold(1)
		update_ui()

# Start an activity
func start_activity(activity_name: String):
	if character != null:
		# Clear all button progress bars
		clear_all_button_progress()

		if IdleMechanics.start_activity(activity_name, character):
			update_ui()

func clear_all_button_progress():
	"""Clear progress from all button progress bars"""
	for activity_name in button_progress_bars.keys():
		var progress_bar = button_progress_bars[activity_name]
		if progress_bar:
			progress_bar.value = 0.0

# Get character for other scripts
func get_character() -> Character:
	return character

# Navigation button handlers
func _on_character_profile_button_pressed():
	get_tree().change_scene_to_file("res://scenes/character_profile.tscn")

func _on_equipment_button_pressed():
	get_tree().change_scene_to_file("res://scenes/equipment_screen.tscn")

func _on_journal_button_pressed():
	get_tree().change_scene_to_file("res://scenes/journal_screen.tscn")

func _on_activities_button_pressed():
	get_tree().change_scene_to_file("res://scenes/activities_screen.tscn")

func _on_general_store_button_pressed():
	get_tree().change_scene_to_file("res://scenes/general_store_screen.tscn")

func _on_inventory_button_pressed():
	get_tree().change_scene_to_file("res://scenes/inventory_screen.tscn")

func _on_monster_glossary_button_pressed():
	get_tree().change_scene_to_file("res://scenes/monster_glossary_screen.tscn")

func _on_leveling_button_pressed():
	get_tree().change_scene_to_file("res://scenes/leveling_screen.tscn")

func _on_settings_button_pressed():
	get_tree().change_scene_to_file("res://scenes/settings_screen.tscn")

func _on_character_display_button_pressed():
	get_tree().change_scene_to_file("res://scenes/character_display.tscn")

func _on_character_sheet_button_pressed():
	get_tree().change_scene_to_file("res://scenes/character_sheet.tscn")

func _on_faction_button_pressed():
	get_tree().change_scene_to_file("res://scenes/faction_screen.tscn")

func _on_achievements_button_pressed():
	get_tree().change_scene_to_file("res://scenes/achievements_screen.tscn")

func _on_spellbook_button_pressed():
	get_tree().change_scene_to_file("res://scenes/spellbook_screen.tscn")

# Activity button handlers
func _on_push_a_rock_pressed():
	start_activity("Push a Rock")

func _on_tip_over_statue_pressed():
	start_activity("Tip Over a Statue")

func _on_athletics_pressed():
	start_activity("Lift Weights")

# Dexterity activity handlers
func _on_do_a_kickflip_pressed():
	start_activity("Do a Kickflip")

func _on_practice_acrobatics_pressed():
	start_activity("Practice Acrobatics")

func _on_pick_locks_pressed():
	start_activity("Pick Locks")

func _on_stealth_training_pressed():
	start_activity("Stealth Training")

func _on_play_instrument_pressed():
	start_activity("Play Instrument")

# Constitution activity handlers
func _on_hold_your_breath_pressed():
	start_activity("Hold Your Breath")

func _on_drink_ale_pressed():
	start_activity("Drink Ale")

# Intelligence activity handlers
func _on_study_arcana_pressed():
	start_activity("Study Arcana")

func _on_research_history_pressed():
	start_activity("Research History")

func _on_investigate_pressed():
	start_activity("Investigate")

func _on_study_nature_pressed():
	start_activity("Study Nature")

func _on_research_religion_pressed():
	start_activity("Research Religion")

func _on_forge_document_pressed():
	start_activity("Forge Document")

# Wisdom activity handlers
func _on_animal_handling_pressed():
	start_activity("Animal Handling")

func _on_practice_insight_pressed():
	start_activity("Practice Insight")

func _on_study_medicine_pressed():
	start_activity("Study Medicine")

func _on_practice_perception_pressed():
	start_activity("Practice Perception")

# Charisma activity handlers
func _on_practice_deception_pressed():
	start_activity("Practice Deception")

func _on_practice_intimidation_pressed():
	start_activity("Practice Intimidation")

func _on_performance_practice_pressed():
	start_activity("Performance Practice")

func _on_practice_persuasion_pressed():
	start_activity("Practice Persuasion")

# Crafting activity handlers
func _on_blacksmithing_pressed():
	start_activity("Blacksmithing")

func _on_jewelry_making_pressed():
	start_activity("Jewelry Making")

func _on_leatherworking_pressed():
	start_activity("Leatherworking")

func _on_pottery_pressed():
	start_activity("Pottery")

func _on_weaving_pressed():
	start_activity("Weaving")

func _on_woodworking_pressed():
	start_activity("Woodworking")

# Profession activity handlers
func _on_artisan_pressed():
	start_activity("Artisan")

func _on_merchant_pressed():
	start_activity("Merchant")

func _on_scholar_pressed():
	start_activity("Scholar")

func _on_guard_pressed():
	start_activity("Guard")

func _on_priest_pressed():
	start_activity("Priest")

func _on_entertainer_pressed():
	start_activity("Entertainer")

# Training activity handlers
func _on_learn_language_pressed():
	start_activity("Learn Language")

func _on_tool_proficiency_pressed():
	start_activity("Tool Proficiency")

func _on_skill_training_pressed():
	start_activity("Skill Training")

# Generic activity handler for all other activities
func _on_activity_button_pressed(button_name: String):
	"""Handle any activity button press"""
	var activity_name = button_name.replace("_", " ").capitalize()
	start_activity(activity_name)
