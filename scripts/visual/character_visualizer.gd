class_name CharacterVisualizer
extends Node2D

# Character visualization system that renders character based on stats and equipment

@onready var character_sprite: Sprite2D
@onready var equipment_sprites: Dictionary = {}
@onready var animation_player: AnimationPlayer
@onready var animation_tree: AnimationTree

# Character reference
var character: Character

# Visual components
var base_character_texture: Texture2D
var equipment_textures: Dictionary = {}
var character_parts: Dictionary = {}

# Animation states
enum VisualState {
    IDLE,
    WORKING,
    COMBAT_READY,
    CASTING,
    RESTING
}

var current_visual_state: VisualState = VisualState.IDLE

# Character appearance based on stats
var character_height: float = 1.0
var character_width: float = 1.0
var character_pose: String = "standing"
var character_expression: String = "neutral"

func _ready():
    setup_character_visualization()
    connect_to_character_events()

func setup_character_visualization():
    # Create base character sprite
    character_sprite = Sprite2D.new()
    add_child(character_sprite)

    # Create equipment sprites
    create_equipment_slots()

    # Setup animation system
    setup_animation_system()

    # Load default textures
    load_default_textures()

func create_equipment_slots():
    # Create sprite nodes for each equipment slot
    var equipment_slots = [
        "head", "chest", "legs", "feet", "hands",
        "main_hand", "off_hand", "back", "waist"
    ]

    for slot in equipment_slots:
        var equipment_sprite = Sprite2D.new()
        equipment_sprite.name = slot
        equipment_sprite.z_index = get_equipment_z_index(slot)
        add_child(equipment_sprite)
        equipment_sprites[slot] = equipment_sprite

func get_equipment_z_index(slot: String) -> int:
    match slot:
        "back":
            return 1
        "legs":
            return 2
        "chest":
            return 3
        "head":
            return 4
        "hands":
            return 5
        "main_hand", "off_hand":
            return 6
        "feet":
            return 7
        "waist":
            return 8
        _:
            return 0

func setup_animation_system():
    # Create animation player for character animations
    animation_player = AnimationPlayer.new()
    add_child(animation_player)

    # Create basic animations
    create_idle_animation()
    create_working_animation()
    create_combat_animation()

func create_idle_animation():
    var animation = Animation.new()
    var track_index = animation.add_track(Animation.TYPE_POSITION_3D)
    animation.track_set_path(track_index, NodePath("."))

    # Add keyframes for idle breathing motion
    animation.track_insert_key(track_index, 0.0, Vector3(0, 0, 0))
    animation.track_insert_key(track_index, 1.0, Vector3(0, -2, 0))
    animation.track_insert_key(track_index, 2.0, Vector3(0, 0, 0))

    animation_player.add_animation("idle", animation)

func create_working_animation():
    var animation = Animation.new()
    var track_index = animation.add_track(Animation.TYPE_ROTATION_3D)
    animation.track_set_path(track_index, NodePath("."))

    # Add keyframes for working motion
    animation.track_insert_key(track_index, 0.0, Vector3(0, 0, 0))
    animation.track_insert_key(track_index, 0.5, Vector3(0, 0, 0.1))
    animation.track_insert_key(track_index, 1.0, Vector3(0, 0, 0))

    animation_player.add_animation("working", animation)

func create_combat_animation():
    var animation = Animation.new()
    var track_index = animation.add_track(Animation.TYPE_SCALE_3D)
    animation.track_set_path(track_index, NodePath("."))

    # Add keyframes for combat ready pose
    animation.track_insert_key(track_index, 0.0, Vector3(1.1, 1.1, 1.0))

    animation_player.add_animation("combat_ready", animation)

func load_default_textures():
    # Load base character textures based on race and class
    # This would typically load from a texture atlas or individual files
    base_character_texture = load("res://assets/characters/default_character.png")

    if base_character_texture:
        character_sprite.texture = base_character_texture

func update_character_visualization(new_character: Character):
    character = new_character
    if character == null:
        return

    # Update character appearance based on stats
    update_character_appearance()

    # Update equipment display
    update_equipment_display()

    # Update character pose based on current activity
    update_character_pose()

    # Update character expression
    update_character_expression()

func update_character_appearance():
    if character == null:
        return

    # Adjust character size based on Constitution
    var con_modifier = character.get_constitution_modifier()
    character_height = 1.0 + (con_modifier * 0.05)
    character_width = 1.0 + (con_modifier * 0.03)

    # Apply size scaling
    scale = Vector2(character_width, character_height)

    # Update character texture based on race and class
    update_character_texture()

func update_character_texture():
    if character == null:
        return

    # Load race-specific base texture
    var race_texture_path = "res://assets/characters/%s_base.png" % character.race.to_lower()
    var race_texture = load(race_texture_path)

    if race_texture:
        character_sprite.texture = race_texture
    else:
        # Fallback to default texture
        character_sprite.texture = base_character_texture

    # Apply class-specific color tinting
    apply_class_tinting()

func apply_class_tinting():
    if character == null:
        return

    var class_color = get_class_color(character.character_class)
    character_sprite.modulate = class_color

func get_class_color(class_type: String) -> Color:
    match class_type.to_lower():
        "barbarian":
            return Color(0.8, 0.2, 0.2) # Red
        "bard":
            return Color(0.8, 0.2, 0.8) # Purple
        "cleric":
            return Color(1.0, 1.0, 0.2) # Yellow
        "druid":
            return Color(0.2, 0.8, 0.2) # Green
        "fighter":
            return Color(0.5, 0.5, 0.5) # Gray
        "monk":
            return Color(0.8, 0.6, 0.2) # Orange
        "paladin":
            return Color(0.2, 0.2, 0.8) # Blue
        "ranger":
            return Color(0.2, 0.6, 0.2) # Dark Green
        "rogue":
            return Color(0.3, 0.3, 0.3) # Dark Gray
        "sorcerer":
            return Color(0.8, 0.4, 0.8) # Magenta
        "warlock":
            return Color(0.4, 0.2, 0.8) # Dark Purple
        "wizard":
            return Color(0.2, 0.4, 0.8) # Light Blue
        _:
            return Color.WHITE

func update_equipment_display():
    if character == null or character.equipment.is_empty():
        clear_equipment_display()
        return

    # Display each equipped item
    for slot in character.equipment.keys():
        var item_name = character.equipment[slot]
        display_equipment_item(slot, item_name)

func display_equipment_item(slot: String, item_name: String):
    if not equipment_sprites.has(slot):
        return

    var equipment_sprite = equipment_sprites[slot]
    var item_texture = load_equipment_texture(slot, item_name)

    if item_texture:
        equipment_sprite.texture = item_texture
        equipment_sprite.visible = true
    else:
        equipment_sprite.visible = false

func load_equipment_texture(slot: String, item_name: String) -> Texture2D:
    var texture_path = "res://assets/equipment/%s/%s.png" % [slot, item_name.to_lower().replace(" ", "_")]
    return load(texture_path)

func clear_equipment_display():
    for equipment_sprite in equipment_sprites.values():
        equipment_sprite.visible = false

func update_character_pose():
    if character == null:
        return

    # Determine pose based on current activity
    if character.current_activity != "":
        character_pose = "working"
        play_animation("working")
    elif character.level >= 5:
        character_pose = "confident"
        play_animation("idle")
    else:
        character_pose = "standing"
        play_animation("idle")

func update_character_expression():
    if character == null:
        return

    # Determine expression based on character stats and current state
    var charisma_modifier = character.get_charisma_modifier()

    if charisma_modifier >= 3:
        character_expression = "confident"
    elif charisma_modifier <= -2:
        character_expression = "shy"
    elif character.current_activity != "":
        character_expression = "focused"
    else:
        character_expression = "neutral"

func play_animation(animation_name: String):
    if animation_player and animation_player.has_animation(animation_name):
        animation_player.play(animation_name)

func connect_to_character_events():
    # Connect to character manager events
    if has_node("/root/CharacterManager"):
        var character_manager = get_node("/root/CharacterManager")
        character_manager.character_changed.connect(_on_character_changed)

func _on_character_changed(new_character: Character):
    update_character_visualization(new_character)

# Public methods for external control
func set_visual_state(state: VisualState):
    current_visual_state = state
    match state:
        VisualState.IDLE:
            play_animation("idle")
        VisualState.WORKING:
            play_animation("working")
        VisualState.COMBAT_READY:
            play_animation("combat_ready")
        VisualState.CASTING:
            play_animation("casting")
        VisualState.RESTING:
            play_animation("resting")

func get_character_bounds() -> Rect2:
    var bounds = Rect2()
    if character_sprite and character_sprite.texture:
        bounds = Rect2(Vector2.ZERO, character_sprite.texture.get_size() * scale)
    return bounds

func get_equipment_at_position(pos: Vector2) -> String:
    # Check which equipment is at the given position
    for slot in equipment_sprites.keys():
        var sprite = equipment_sprites[slot]
        if sprite.visible and sprite.get_rect().has_point(pos):
            return slot
    return ""

func highlight_equipment(slot: String, highlight: bool = true):
    if equipment_sprites.has(slot):
        var sprite = equipment_sprites[slot]
        if highlight:
            sprite.modulate = Color.YELLOW
        else:
            sprite.modulate = Color.WHITE
