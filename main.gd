extends Control

@onready var coins_value_text = %CoinsValueText
@onready var character_name_label = %CharacterNameLabel
@onready var character_level_label = %CharacterLevelLabel
@onready var character_class_label = %CharacterClassLabel
@onready var current_activity_label = %CurrentActivityLabel
@onready var activity_progress_bar = %ActivityProgressBar

var character: Character

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
	update_ui()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if character != null:
		# Check if current activity is complete
		if character.is_activity_complete():
			var rewards = IdleMechanics.complete_activity(character)
			if rewards.xp > 0 or rewards.gold > 0:
				print("Activity completed! Gained %d XP and %d gold" % [rewards.xp, rewards.gold])
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

# Update activity progress bar
func update_activity_progress():
	if character == null or character.current_activity == "" or not activity_progress_bar:
		return

	var time_remaining = character.get_activity_time_remaining()
	var total_duration = character.activity_duration
	var progress = 1.0 - (time_remaining / total_duration)

	activity_progress_bar.value = progress * 100

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
	if character != null and IdleMechanics.start_activity(activity_name, character):
		update_ui()
		print("Started activity: %s" % activity_name)
	else:
		print("Cannot start activity: %s" % activity_name)

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
