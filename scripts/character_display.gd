extends Control

# Character display screen that shows a visual representation of the character

@onready var character_visualizer: CharacterVisualizer
@onready var character_info_panel: VBoxContainer
@onready var equipment_panel: VBoxContainer

# Character reference
var character: Character
var character_manager: CharacterManager

# UI elements
@onready var name_label: Label
@onready var level_class_label: Label
@onready var race_label: Label
@onready var strength_label: Label
@onready var dexterity_label: Label
@onready var constitution_label: Label
@onready var intelligence_label: Label
@onready var wisdom_label: Label
@onready var charisma_label: Label
@onready var hit_points_label: Label
@onready var armor_class_label: Label
@onready var proficiency_label: Label

# Equipment display
var equipment_labels: Dictionary = {}

func _ready():
    # Get character manager
    character_manager = CharacterManager.new()
    character = character_manager.get_current_character()

    # Get UI references
    setup_ui_references()

    # Setup character visualizer
    setup_character_visualizer()

    # Connect to character events
    connect_to_character_events()

    # Update display
    update_character_display()

func setup_ui_references():
    # Get main info labels
    name_label = %NameLabel
    level_class_label = %LevelClassLabel
    race_label = %RaceLabel

    # Get stat labels
    strength_label = %StrengthLabel
    dexterity_label = %DexterityLabel
    constitution_label = %ConstitutionLabel
    intelligence_label = %IntelligenceLabel
    wisdom_label = %WisdomLabel
    charisma_label = %CharismaLabel

    # Get combat stat labels
    hit_points_label = %HitPointsLabel
    armor_class_label = %ArmorClassLabel
    proficiency_label = %ProficiencyLabel

    # Get equipment labels
    equipment_labels = {
        "head": %HeadItem,
        "chest": %ChestItem,
        "main_hand": %MainHandItem,
        "off_hand": %OffHandItem
    }

func setup_character_visualizer():
    # Find or create character visualizer
    character_visualizer = %CharacterVisualizer
    if not character_visualizer:
        character_visualizer = CharacterVisualizer.new()
        %CharacterContainer.add_child(character_visualizer)

func connect_to_character_events():
    # Connect to character manager events
    if character_manager:
        character_manager.character_changed.connect(_on_character_changed)

func update_character_display():
    if character == null:
        show_default_character()
        return

    # Update character info
    update_character_info()

    # Update stats display
    update_stats_display()

    # Update equipment display
    update_equipment_display()

    # Update character visualizer
    if character_visualizer:
        character_visualizer.update_character_visualization(character)

func show_default_character():
    # Show default character when none is loaded
    name_label.text = "No Character"
    level_class_label.text = "Create a character to begin"
    race_label.text = ""

    # Clear all stats
    clear_stats_display()
    clear_equipment_display()

func update_character_info():
    if character == null:
        return

    name_label.text = character.name
    level_class_label.text = "Level %d %s" % [character.level, character.character_class.capitalize()]
    race_label.text = character.race.capitalize()

func update_stats_display():
    if character == null:
        return

    # Update ability scores
    strength_label.text = "STR: %d (%+d)" % [character.strength, character.get_strength_modifier()]
    dexterity_label.text = "DEX: %d (%+d)" % [character.dexterity, character.get_dexterity_modifier()]
    constitution_label.text = "CON: %d (%+d)" % [character.constitution, character.get_constitution_modifier()]
    intelligence_label.text = "INT: %d (%+d)" % [character.intelligence, character.get_intelligence_modifier()]
    wisdom_label.text = "WIS: %d (%+d)" % [character.wisdom, character.get_wisdom_modifier()]
    charisma_label.text = "CHA: %d (%+d)" % [character.charisma, character.get_charisma_modifier()]

    # Update combat stats
    hit_points_label.text = "HP: %d/%d" % [character.hit_points, character.max_hit_points]
    armor_class_label.text = "AC: %d" % character.armor_class
    proficiency_label.text = "Proficiency: %+d" % character.proficiency_bonus

func update_equipment_display():
    if character == null or character.equipment.is_empty():
        clear_equipment_display()
        return

    # Update each equipment slot
    for slot in equipment_labels.keys():
        var item_name = character.equipment.get(slot, "None")
        equipment_labels[slot].text = item_name

func clear_stats_display():
    strength_label.text = "STR: --"
    dexterity_label.text = "DEX: --"
    constitution_label.text = "CON: --"
    intelligence_label.text = "INT: --"
    wisdom_label.text = "WIS: --"
    charisma_label.text = "CHA: --"
    hit_points_label.text = "HP: --/--"
    armor_class_label.text = "AC: --"
    proficiency_label.text = "Proficiency: --"

func clear_equipment_display():
    for label in equipment_labels.values():
        label.text = "None"

func _on_character_changed(new_character: Character):
    character = new_character
    update_character_display()

func _on_back_button_pressed():
    # Return to main screen
    get_tree().change_scene_to_file("res://scenes/main.tscn")

# Animation and visual effects
func animate_character_level_up():
    if character_visualizer:
        character_visualizer.set_visual_state(CharacterVisualizer.VisualState.COMBAT_READY)

        # Add level up particle effect
        create_level_up_effect()

func create_level_up_effect():
    # Create a simple particle effect for level up
    var effect = create_particle_effect()
    effect.position = character_visualizer.position
    add_child(effect)

func create_particle_effect() -> Node2D:
    # Simple particle effect using Godot's built-in particles
    var particles = GPUParticles2D.new()
    particles.emitting = true
    particles.amount = 50
    particles.lifetime = 2.0

    # Auto-remove after effect
    var timer = Timer.new()
    timer.wait_time = 3.0
    timer.one_shot = true
    timer.timeout.connect(func(): particles.queue_free())
    particles.add_child(timer)
    timer.start()

    return particles

# Equipment interaction
func highlight_equipment_slot(slot: String):
    if character_visualizer:
        character_visualizer.highlight_equipment(slot, true)

func unhighlight_equipment_slot(slot: String):
    if character_visualizer:
        character_visualizer.highlight_equipment(slot, false)

# Character pose controls
func set_character_pose(pose: String):
    if character_visualizer:
        match pose:
            "idle":
                character_visualizer.set_visual_state(CharacterVisualizer.VisualState.IDLE)
            "working":
                character_visualizer.set_visual_state(CharacterVisualizer.VisualState.WORKING)
            "combat":
                character_visualizer.set_visual_state(CharacterVisualizer.VisualState.COMBAT_READY)
            "casting":
                character_visualizer.set_visual_state(CharacterVisualizer.VisualState.CASTING)
            "resting":
                character_visualizer.set_visual_state(CharacterVisualizer.VisualState.RESTING)

# Input handling for character interaction
func _input(event):
    if event is InputEventMouseButton and event.pressed:
        if event.button_index == MOUSE_BUTTON_LEFT:
            handle_character_click(event.position)

func handle_character_click(click_position: Vector2):
    if not character_visualizer:
        return

    # Convert screen position to local position
    var local_pos = character_visualizer.to_local(click_position)

    # Check if clicking on equipment
    var equipment_slot = character_visualizer.get_equipment_at_position(local_pos)
    if equipment_slot != "":
        on_equipment_clicked(equipment_slot)

func on_equipment_clicked(slot: String):
    # Handle equipment interaction
    var item_name = character.equipment.get(slot, "")
    if item_name != "":
        show_equipment_info(slot, item_name)
    else:
        show_equipment_slot_info(slot)

func show_equipment_info(slot: String, item_name: String):
    # Show detailed equipment information
    print("Equipment info: %s - %s" % [slot, item_name])
    # TODO: Show equipment tooltip or popup

func show_equipment_slot_info(slot: String):
    # Show information about empty equipment slot
    print("Empty slot: %s" % slot)
    # TODO: Show slot information tooltip
