extends BaseScreen

# Character display screen that shows a visual representation of the character

@onready var character_visualizer: CharacterVisualizer3D
@onready var character_info_panel: VBoxContainer
@onready var equipment_panel: VBoxContainer

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

func on_screen_ready() -> void:
    """Override base screen ready for character display specific setup"""
    # Get UI references
    setup_ui_references()

    # Setup character visualizer
    setup_character_visualizer()

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
    character_visualizer = %CharacterVisualizer3D
    if not character_visualizer:
        character_visualizer = CharacterVisualizer3D.new()
        %SubViewport.add_child(character_visualizer)

func connect_signals() -> void:
    """Override base screen signals for character display specific connections"""
    super.connect_signals()
    # Additional character display specific signals can be added here

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
    if name_label:
        name_label.text = "No Character"
    if level_class_label:
        level_class_label.text = "Create a character to begin"
    if race_label:
        race_label.text = ""

    # Clear all stats
    clear_stats_display()
    clear_equipment_display()

func update_character_info():
    if character == null:
        return

    if name_label:
        name_label.text = character.name
    if level_class_label:
        level_class_label.text = "Level %d %s" % [character.level, character.character_class.capitalize()]
    if race_label:
        race_label.text = character.race.capitalize()

    # Update physical characteristics
    update_physical_characteristics()

func update_physical_characteristics():
    """Update physical characteristics display"""
    if character == null:
        return

    # Convert height from inches to feet and inches
    var height_inches = int(character.height)
    var feet = height_inches / 12.0
    var inches = height_inches % 12
    var height_text = "Height: %d'%d\"" % [feet, inches]

    # Update height label
    var height_label = %HeightLabel
    if height_label:
        height_label.text = height_text

    # Update weight label
    var weight_label = %WeightLabel
    if weight_label:
        weight_label.text = "Weight: %d lbs" % character.weight

func update_stats_display():
    if character == null:
        return

    # Update ability scores
    if strength_label:
        strength_label.text = "STR: %d (%+d)" % [character.strength, character.get_strength_modifier()]
    if dexterity_label:
        dexterity_label.text = "DEX: %d (%+d)" % [character.dexterity, character.get_dexterity_modifier()]
    if constitution_label:
        constitution_label.text = "CON: %d (%+d)" % [character.constitution, character.get_constitution_modifier()]
    if intelligence_label:
        intelligence_label.text = "INT: %d (%+d)" % [character.intelligence, character.get_intelligence_modifier()]
    if wisdom_label:
        wisdom_label.text = "WIS: %d (%+d)" % [character.wisdom, character.get_wisdom_modifier()]
    if charisma_label:
        charisma_label.text = "CHA: %d (%+d)" % [character.charisma, character.get_charisma_modifier()]

    # Update combat stats
    if hit_points_label:
        hit_points_label.text = "HP: %d/%d" % [character.hit_points, character.max_hit_points]
    if armor_class_label:
        armor_class_label.text = "AC: %d" % character.armor_class
    if proficiency_label:
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
    if strength_label:
        strength_label.text = "STR: --"
    if dexterity_label:
        dexterity_label.text = "DEX: --"
    if constitution_label:
        constitution_label.text = "CON: --"
    if intelligence_label:
        intelligence_label.text = "INT: --"
    if wisdom_label:
        wisdom_label.text = "WIS: --"
    if charisma_label:
        charisma_label.text = "CHA: --"
    if hit_points_label:
        hit_points_label.text = "HP: --/--"
    if armor_class_label:
        armor_class_label.text = "AC: --"
    if proficiency_label:
        proficiency_label.text = "Proficiency: --"

func clear_equipment_display():
    for label in equipment_labels.values():
        label.text = "None"

func on_character_updated() -> void:
    """Override base screen character update for character display specific behavior"""
    update_character_display()

# Animation and visual effects
func animate_character_level_up():
    if character_visualizer:
        character_visualizer.set_visual_state(CharacterVisualizer3D.VisualState.COMBAT_READY)

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
                character_visualizer.set_visual_state(CharacterVisualizer3D.VisualState.IDLE)
            "working":
                character_visualizer.set_visual_state(CharacterVisualizer3D.VisualState.WORKING)
            "combat":
                character_visualizer.set_visual_state(CharacterVisualizer3D.VisualState.COMBAT_READY)
            "casting":
                character_visualizer.set_visual_state(CharacterVisualizer3D.VisualState.CASTING)
            "resting":
                character_visualizer.set_visual_state(CharacterVisualizer3D.VisualState.RESTING)

# Input handling for character interaction
func _input(event):
    if event is InputEventMouseButton and event.pressed:
        if event.button_index == MOUSE_BUTTON_LEFT:
            handle_character_click(event.position)

func handle_character_click(click_position: Vector2):
    if not character_visualizer:
        return

    # Convert screen position to 3D world position
    var camera = %Camera3D
    if camera:
        var from = camera.project_ray_origin(click_position)
        var to = from + camera.project_ray_normal(click_position) * 1000
        var space_state = %SubViewport.get_world_3d().direct_space_state
        var query = PhysicsRayQueryParameters3D.create(from, to)
        var result = space_state.intersect_ray(query)

        if result:
            var world_pos = result.position
            var equipment_slot = character_visualizer.get_equipment_at_position(world_pos)
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
